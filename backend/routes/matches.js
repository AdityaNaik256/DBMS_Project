const express = require('express');
const router = express.Router();
const pool = require('../config/database');

// GET / — list all matches; optional ?tournament_id= filter
router.get('/', async (req, res) => {
  try {
    const { tournament_id } = req.query;
    const params = [];
    let whereClause = '';

    if (tournament_id) {
      whereClause = 'WHERE m.tournament_id = ?';
      params.push(tournament_id);
    }

    const [rows] = await pool.query(`
      SELECT
        m.match_id,
        m.match_date,
        m.round_number,
        ht.team_name       AS home_team,
        at.team_name       AS away_team,
        v.venue_name,
        t.tournament_name,
        ms.home_score,
        ms.away_score,
        ms.winner_team_id,
        ms.match_notes
      FROM matches m
      JOIN teams ht          ON m.home_team_id = ht.team_id
      JOIN teams at          ON m.away_team_id = at.team_id
      JOIN tournaments t     ON m.tournament_id = t.tournament_id
      LEFT JOIN venues v     ON m.venue_id      = v.venue_id
      LEFT JOIN match_scores ms ON m.match_id   = ms.match_id
      ${whereClause}
      ORDER BY m.match_date DESC, m.round_number ASC
    `, params);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id — single match with full details and player stats
router.get('/:id', async (req, res) => {
  try {
    const [matchRows] = await pool.query(`
      SELECT
        m.match_id,
        m.match_date,
        m.round_number,
        ht.team_name       AS home_team,
        ht.team_id         AS home_team_id,
        at.team_name       AS away_team,
        at.team_id         AS away_team_id,
        v.venue_name,
        t.tournament_name,
        t.tournament_id,
        ms.home_score,
        ms.away_score,
        ms.winner_team_id,
        ms.match_notes
      FROM matches m
      JOIN teams ht          ON m.home_team_id = ht.team_id
      JOIN teams at          ON m.away_team_id = at.team_id
      JOIN tournaments t     ON m.tournament_id = t.tournament_id
      LEFT JOIN venues v     ON m.venue_id      = v.venue_id
      LEFT JOIN match_scores ms ON m.match_id   = ms.match_id
      WHERE m.match_id = ?
    `, [req.params.id]);

    if (matchRows.length === 0) return res.status(404).json({ error: 'Match not found' });

    const [statsRows] = await pool.query(`
      SELECT
        ps.stat_id,
        p.player_name,
        te.team_name,
        ps.goals,
        ps.assists,
        ps.yellow_cards,
        ps.red_cards,
        ps.minutes_played
      FROM player_stats ps
      JOIN players p ON ps.player_id = p.player_id
      JOIN teams te  ON p.team_id    = te.team_id
      WHERE ps.match_id = ?
      ORDER BY te.team_name, p.player_name
    `, [req.params.id]);

    res.json({ ...matchRows[0], player_stats: statsRows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST / — create a new match
router.post('/', async (req, res) => {
  const { tournament_id, home_team_id, away_team_id, venue_id, match_date, round_number } = req.body;

  if (!tournament_id || !home_team_id || !away_team_id) {
    return res.status(400).json({ error: 'tournament_id, home_team_id, and away_team_id are required' });
  }

  if (home_team_id === away_team_id) {
    return res.status(400).json({ error: 'home_team_id and away_team_id must be different' });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO matches (tournament_id, home_team_id, away_team_id, venue_id, match_date, round_number)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [tournament_id, home_team_id, away_team_id, venue_id || null, match_date || null, round_number || null]
    );
    res.status(201).json({ match_id: result.insertId, message: 'Match created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /:id/result — record match result
router.post('/:id/result', async (req, res) => {
  const { home_score, away_score, match_notes } = req.body;

  if (home_score === undefined || away_score === undefined) {
    return res.status(400).json({ error: 'home_score and away_score are required' });
  }

  try {
    // Fetch match to resolve team IDs for winner determination
    const [matchRows] = await pool.query(
      'SELECT home_team_id, away_team_id FROM matches WHERE match_id = ?',
      [req.params.id]
    );

    if (matchRows.length === 0) return res.status(404).json({ error: 'Match not found' });

    const { home_team_id, away_team_id } = matchRows[0];
    const homeGoals = parseInt(home_score, 10);
    const awayGoals = parseInt(away_score, 10);

    let winner_team_id = null;
    if (homeGoals > awayGoals) {
      winner_team_id = home_team_id;
    } else if (awayGoals > homeGoals) {
      winner_team_id = away_team_id;
    }
    // NULL winner_team_id represents a draw

    const [result] = await pool.query(
      `INSERT INTO match_scores (match_id, home_score, away_score, winner_team_id, match_notes)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         home_score      = VALUES(home_score),
         away_score      = VALUES(away_score),
         winner_team_id  = VALUES(winner_team_id),
         match_notes     = VALUES(match_notes)`,
      [req.params.id, homeGoals, awayGoals, winner_team_id, match_notes || null]
    );

    res.json({ message: 'Match result recorded successfully', winner_team_id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
