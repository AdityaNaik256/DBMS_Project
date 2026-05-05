const express = require('express');
const router = express.Router();
const pool = require('../config/database');

// GET / — list all teams; optional ?sport_id= filter
router.get('/', async (req, res) => {
  try {
    const { sport_id } = req.query;
    const params = [];
    let whereClause = '';

    if (sport_id) {
      whereClause = 'WHERE t.sport_id = ?';
      params.push(sport_id);
    }

    const [rows] = await pool.query(`
      SELECT
        t.team_id,
        t.team_name,
        t.city,
        t.founded_year,
        s.sport_name
      FROM teams t
      LEFT JOIN sports s ON t.sport_id = s.sport_id
      ${whereClause}
      ORDER BY t.team_name
    `, params);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id — single team with sport and home venue details
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        t.team_id,
        t.team_name,
        t.city,
        t.founded_year,
        s.sport_name,
        v.venue_name AS home_venue_name,
        v.city       AS venue_city,
        v.capacity
      FROM teams t
      LEFT JOIN sports s ON t.sport_id       = s.sport_id
      LEFT JOIN venues v ON t.home_venue_id  = v.venue_id
      WHERE t.team_id = ?
    `, [req.params.id]);

    if (rows.length === 0) return res.status(404).json({ error: 'Team not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id/players — all players belonging to a team
router.get('/:id/players', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        p.player_id,
        p.player_name,
        p.position,
        p.nationality,
        p.age,
        p.jersey_number
      FROM players p
      WHERE p.team_id = ?
      ORDER BY p.jersey_number, p.player_name
    `, [req.params.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id/matches — recent matches for a team (home or away)
router.get('/:id/matches', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        m.match_id,
        m.match_date,
        m.round_number,
        ht.team_name         AS home_team,
        at.team_name         AS away_team,
        ms.home_score,
        ms.away_score,
        ms.winner_team_id,
        t.tournament_name
      FROM matches m
      JOIN teams ht          ON m.home_team_id = ht.team_id
      JOIN teams at          ON m.away_team_id = at.team_id
      JOIN tournaments t     ON m.tournament_id = t.tournament_id
      LEFT JOIN match_scores ms ON m.match_id  = ms.match_id
      WHERE m.home_team_id = ? OR m.away_team_id = ?
      ORDER BY m.match_date DESC
      LIMIT 20
    `, [req.params.id, req.params.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST / — create a new team
router.post('/', async (req, res) => {
  const { team_name, sport_id, city, home_venue_id, founded_year } = req.body;

  if (!team_name || !sport_id) {
    return res.status(400).json({ error: 'team_name and sport_id are required' });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO teams (team_name, sport_id, city, home_venue_id, founded_year)
       VALUES (?, ?, ?, ?, ?)`,
      [team_name, sport_id, city || null, home_venue_id || null, founded_year || null]
    );
    res.status(201).json({ team_id: result.insertId, message: 'Team created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
