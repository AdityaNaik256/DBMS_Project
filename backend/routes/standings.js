const express = require('express');
const router = express.Router();
const pool = require('../config/database');

// GET /:tournament_id — standings for a tournament with rank and optional team form
router.get('/:tournament_id', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        ROW_NUMBER() OVER (
          ORDER BY st.points DESC, st.goal_difference DESC
        )                    AS rank,
        st.standing_id,
        st.team_id,
        te.team_name,
        st.played,
        st.won,
        st.drawn,
        st.lost,
        st.goals_for,
        st.goals_against,
        st.goal_difference,
        st.points
      FROM standings st
      JOIN teams te ON st.team_id = te.team_id
      WHERE st.tournament_id = ?
      ORDER BY st.points DESC, st.goal_difference DESC
    `, [req.params.tournament_id]);

    // Attempt to enrich each row with team form from the GetTeamForm function.
    // This is optional; if the function is unavailable the response still succeeds.
    const enriched = await Promise.all(
      rows.map(async (row) => {
        try {
          const [[formRows]] = await pool.query(
            'SELECT GetTeamForm(?, ?) AS form',
            [row.team_id, req.params.tournament_id]
          );
          return { ...row, form: formRows ? formRows.form : null };
        } catch {
          return { ...row, form: null };
        }
      })
    );

    res.json(enriched);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
