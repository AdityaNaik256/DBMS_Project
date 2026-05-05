# Tournament & League Management System

A full-stack web application for managing sports tournaments, teams, players, matches, and standings.

## Tech Stack
- **Frontend**: Vanilla HTML / CSS / JavaScript (SPA, no framework)
- **Backend**: Node.js + Express
- **Database**: MySQL 8.0+

## Features
- Dashboard with live stats (tournaments, teams, players, matches)
- Tournament list with standings, fixtures, and registered teams
- Teams directory with squad roster and recent matches
- Players directory with career stats, filterable by tournament
- Matches list with scores and player stats
- Responsive design (desktop + mobile)

## Setup

### Local Development

#### 1. Database
```sql
-- Run these in order in MySQL:
source database/schema.sql
source database/functions.sql
source database/procedures.sql
source database/triggers.sql
source database/sample_data.sql   -- optional sample data
```

#### 2. Backend
```bash
cd backend
cp ../.env.example .env           # edit .env with your DB credentials
npm install
npm start                          # runs on http://localhost:3000
```

Open **http://localhost:3000** in your browser.

---

### Deploy to Railway (Public URL)

[Railway](https://railway.app) hosts both Node.js and MySQL for free and gives you a public `https://<app>.up.railway.app` URL accessible from any laptop.

1. **Sign up** at [railway.app](https://railway.app) (free with GitHub login).

2. **New Project → Deploy from GitHub repo** → select `AdityaNaik256/DBMS_Project`.  
   Railway will pick up `railway.json` automatically — no root-directory setting needed.

3. **Add a MySQL database**: inside the project click **"+ New" → "Database" → "MySQL"**.  
   Railway injects the `MYSQLHOST`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`, and `MYSQLPORT` env vars automatically — no manual configuration needed.

4. **Seed the database**: use the connection details shown in Railway's MySQL service panel to connect with any MySQL client (e.g. TablePlus, DBeaver, or the `mysql` CLI) and run:
   ```sql
   source database/schema.sql
   source database/functions.sql
   source database/procedures.sql
   source database/triggers.sql
   source database/sample_data.sql   -- optional
   ```

5. **Generate a public domain**: in the Railway service panel click **"Settings" → "Networking" → "Generate Domain"**.

Your app will be live at `https://<your-app>.up.railway.app` — shareable with anyone.

## Project Structure
```
DBMS_Project/
├── backend/
│   ├── config/database.js        # MySQL connection pool
│   ├── routes/                   # API route handlers
│   │   ├── tournaments.js
│   │   ├── teams.js
│   │   ├── players.js
│   │   ├── matches.js
│   │   └── standings.js
│   └── server.js
├── database/
│   ├── schema.sql                # Tables & indexes
│   ├── functions.sql             # GetTeamForm, GetTopScorer
│   ├── procedures.sql            # GenerateFixtures, UpdateStandings
│   ├── triggers.sql              # Auto standings update on score insert/update
│   └── sample_data.sql           # Sample sports data
├── frontend/
│   ├── index.html
│   ├── css/style.css
│   └── js/app.js
└── .env.example
```

## API Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/stats | Dashboard counts |
| GET | /api/tournaments | All tournaments |
| GET | /api/tournaments/:id | Tournament detail |
| GET | /api/tournaments/:id/teams | Teams in tournament |
| GET | /api/tournaments/:id/matches | Matches in tournament |
| GET | /api/tournaments/:id/standings | Standings |
| POST | /api/tournaments | Create tournament |
| POST | /api/tournaments/:id/teams | Register team |
| POST | /api/tournaments/:id/generate-fixtures | Generate round-robin fixtures |
| GET | /api/teams | All teams |
| GET | /api/teams/:id | Team detail |
| GET | /api/teams/:id/players | Team squad |
| GET | /api/teams/:id/matches | Team matches |
| POST | /api/teams | Create team |
| GET | /api/players | All players |
| GET | /api/players/:id | Player detail + stats |
| GET | /api/players/top-scorers/:tournament_id | Top scorers |
| POST | /api/players | Create player |
| GET | /api/matches | All matches |
| GET | /api/matches/:id | Match detail + player stats |
| POST | /api/matches | Create match |
| POST | /api/matches/:id/result | Record match result |
| GET | /api/standings/:tournament_id | Tournament standings with form |
