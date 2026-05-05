const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(express.static(path.join(__dirname, '../frontend')));

const tournamentsRouter = require('./routes/tournaments');
const teamsRouter = require('./routes/teams');
const playersRouter = require('./routes/players');
const matchesRouter = require('./routes/matches');
const standingsRouter = require('./routes/standings');

app.use('/api/tournaments', tournamentsRouter);
app.use('/api/teams', teamsRouter);
app.use('/api/players', playersRouter);
app.use('/api/matches', matchesRouter);
app.use('/api/standings', standingsRouter);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/stats', async (req, res) => {
  try {
    const pool = require('./config/database');
    const [[tournaments], [teams], [players], [matches]] = await Promise.all([
      pool.query('SELECT COUNT(*) AS count FROM tournaments'),
      pool.query('SELECT COUNT(*) AS count FROM teams'),
      pool.query('SELECT COUNT(*) AS count FROM players'),
      pool.query('SELECT COUNT(*) AS count FROM matches'),
    ]);
    res.json({
      tournaments: tournaments[0].count,
      teams: teams[0].count,
      players: players[0].count,
      matches: matches[0].count,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

module.exports = app;
