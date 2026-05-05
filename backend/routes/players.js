const express = require('express');
const router = express.Router();
const pool = require('../config/database');

// GET /top-scorers/:tournament_id — MUST be defined before /:id to avoid conflicts
router.get('/top-scorers/:tournament_id', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        p.player_id,
        p.player_name,
        te.team_name,
        SUM(ps.goals_scored) AS total_goals
      FROM player_stats ps
      JOIN players p     ON ps.player_id = p.player_id
      JOIN teams te      ON p.team_id    = te.team_id
      JOIN matches m     ON ps.match_id  = m.match_id
      WHERE m.tournament_id = ?
      GROUP BY p.player_id, p.player_name, te.team_name
      ORDER BY total_goals DESC
      LIMIT 10
    `, [req.params.tournament_id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET / — list all players; optional ?tournament_id= and ?team_id= filters
router.get('/', async (req, res) => {
  try {
    const { tournament_id, team_id } = req.query;
    const params = [];
    const conditions = [];
    let joinClause = '';

    if (tournament_id) {
      joinClause = 'JOIN tournament_teams tt ON p.team_id = tt.team_id';
      conditions.push('tt.tournament_id = ?');
      params.push(tournament_id);
    }

    if (team_id) {
      conditions.push('p.team_id = ?');
      params.push(team_id);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const [rows] = await pool.query(`
      SELECT
        p.player_id,
        p.player_name,
        p.position,
        p.nationality,
        p.age,
        p.jersey_number,
        te.team_name,
        s.sport_name
      FROM players p
      JOIN teams  te ON p.team_id  = te.team_id
      JOIN sports s  ON p.sport_id = s.sport_id
      ${joinClause}
      ${whereClause}
      ORDER BY te.team_name, p.jersey_number
    `, params);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /:id — single player with aggregate career stats
router.get('/:id', async (req, res) => {
  try {
    const [playerRows] = await pool.query(`
      SELECT
        p.player_id,
        p.player_name,
        p.position,
        p.nationality,
        p.age,
        p.jersey_number,
        te.team_name,
        s.sport_name
      FROM players p
      JOIN teams  te ON p.team_id  = te.team_id
      JOIN sports s  ON p.sport_id = s.sport_id
      WHERE p.player_id = ?
    `, [req.params.id]);

    if (playerRows.length === 0) return res.status(404).json({ error: 'Player not found' });

    const [statsRows] = await pool.query(`
      SELECT
        COALESCE(SUM(ps.goals_scored), 0) AS total_goals,
        COALESCE(SUM(ps.assists), 0) AS total_assists,
        COUNT(ps.stat_id)            AS matches_played
      FROM player_stats ps
      WHERE ps.player_id = ?
    `, [req.params.id]);

    res.json({ ...playerRows[0], stats: statsRows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST / — create a new player
router.post('/', async (req, res) => {
  const { player_name, team_id, sport_id, position, nationality, age, jersey_number } = req.body;

  if (!player_name || !team_id || !sport_id) {
    return res.status(400).json({ error: 'player_name, team_id, and sport_id are required' });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [player_name, team_id, sport_id, position || null, nationality || null, age || null, jersey_number || null]
    );
    res.status(201).json({ player_id: result.insertId, message: 'Player created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
