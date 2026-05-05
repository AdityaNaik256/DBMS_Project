const express = require('express');
const router = express.Router();
const pool = require('../config/database');

// GET / — list all tournaments with sport name, team count, match count
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        t.tournament_id,
        t.tournament_name,
        t.season,
        t.start_date,
        t.end_date,
        t.format,
        t.description,
        s.sport_name,
        COUNT(DISTINCT tt.team_id)  AS team_count,
        COUNT(DISTINCT m.match_id)  AS match_count
      FROM tournaments t
      LEFT JOIN sports s            ON t.sport_id = s.sport_id
      LEFT JOIN tournament_teams tt ON t.tournament_id = tt.tournament_id
      LEFT JOIN matches m           ON t.tournament_id = m.tournament_id
      GROUP BY
        t.tournament_id, t.tournament_name, t.season,
        t.start_date, t.end_date, t.format, t.description, s.sport_name
      ORDER BY t.start_date DESC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id — single tournament details
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        t.tournament_id,
        t.tournament_name,
        t.season,
        t.start_date,
        t.end_date,
        t.format,
        t.description,
        s.sport_name,
        COUNT(DISTINCT tt.team_id)  AS team_count,
        COUNT(DISTINCT m.match_id)  AS match_count
      FROM tournaments t
      LEFT JOIN sports s            ON t.sport_id = s.sport_id
      LEFT JOIN tournament_teams tt ON t.tournament_id = tt.tournament_id
      LEFT JOIN matches m           ON t.tournament_id = m.tournament_id
      WHERE t.tournament_id = ?
      GROUP BY
        t.tournament_id, t.tournament_name, t.season,
        t.start_date, t.end_date, t.format, t.description, s.sport_name
    `, [req.params.id]);

    if (rows.length === 0) return res.status(404).json({ error: 'Tournament not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id/teams — teams registered in a tournament
router.get('/:id/teams', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        te.team_id,
        te.team_name,
        te.city,
        te.founded_year,
        s.sport_name
      FROM tournament_teams tt
      JOIN teams  te ON tt.team_id  = te.team_id
      JOIN sports s  ON te.sport_id = s.sport_id
      WHERE tt.tournament_id = ?
      ORDER BY te.team_name
    `, [req.params.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id/standings — standings for a tournament
router.get('/:id/standings', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        st.standing_id,
        st.tournament_id,
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
    `, [req.params.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id/matches — all matches in a tournament
router.get('/:id/matches', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        m.match_id,
        m.match_date,
        m.round_number,
        ht.team_name  AS home_team,
        at.team_name  AS away_team,
        v.venue_name,
        ms.home_score,
        ms.away_score,
        ms.winner_team_id,
        ms.match_notes
      FROM matches m
      JOIN teams ht        ON m.home_team_id = ht.team_id
      JOIN teams at        ON m.away_team_id = at.team_id
      LEFT JOIN venues v   ON m.venue_id     = v.venue_id
      LEFT JOIN match_scores ms ON m.match_id = ms.match_id
      WHERE m.tournament_id = ?
      ORDER BY m.match_date ASC, m.round_number ASC
    `, [req.params.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST / — create a tournament
router.post('/', async (req, res) => {
  const { tournament_name, sport_id, season, start_date, end_date, format, description } = req.body;

  if (!tournament_name || !sport_id) {
    return res.status(400).json({ error: 'tournament_name and sport_id are required' });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO tournaments (tournament_name, sport_id, season, start_date, end_date, format, description)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [tournament_name, sport_id, season || null, start_date || null, end_date || null, format || null, description || null]
    );
    res.status(201).json({ tournament_id: result.insertId, message: 'Tournament created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /:id/generate-fixtures — call the GenerateFixtures stored procedure
router.post('/:id/generate-fixtures', async (req, res) => {
  try {
    await pool.query('CALL GenerateFixtures(?)', [req.params.id]);
    res.json({ message: 'Fixtures generated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /:id/teams — register a team in a tournament
router.post('/:id/teams', async (req, res) => {
  const { team_id } = req.body;

  if (!team_id) return res.status(400).json({ error: 'team_id is required' });

  try {
    await pool.query(
      'INSERT INTO tournament_teams (tournament_id, team_id) VALUES (?, ?)',
      [req.params.id, team_id]
    );
    res.status(201).json({ message: 'Team added to tournament successfully' });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Team is already registered in this tournament' });
    }
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
