/* ============================================================
   Tournament & League Management System — Frontend App
   ============================================================ */

'use strict';

// ---- API helper ----
const API = {
  base: '/api',
  async get(path) {
    const res = await fetch(this.base + path);
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: res.statusText }));
      throw new Error(err.error || res.statusText);
    }
    return res.json();
  },
};

// ---- DOM refs ----
const contentEl   = document.getElementById('content');
const pageTitleEl = document.getElementById('pageTitle');
const modalOverlay = document.getElementById('modalOverlay');
const modalContent = document.getElementById('modalContent');
const modalClose   = document.getElementById('modalClose');
const sidebar      = document.getElementById('sidebar');
const menuToggle   = document.getElementById('menuToggle');

// ---- Modal helpers ----
function openModal(html) {
  modalContent.innerHTML = html;
  modalOverlay.hidden = false;
  document.body.style.overflow = 'hidden';
}
function closeModal() {
  modalOverlay.hidden = true;
  document.body.style.overflow = '';
}
modalClose.addEventListener('click', closeModal);
modalOverlay.addEventListener('click', (e) => { if (e.target === modalOverlay) closeModal(); });

// ---- Loader ----
function showLoader() {
  contentEl.innerHTML = '<div class="loader-wrap"><div class="loader"></div></div>';
}
function showError(msg) {
  contentEl.innerHTML = `<div class="empty-state"><div class="icon">⚠️</div><p>${msg}</p></div>`;
}

// ---- Sidebar toggle (mobile) ----
menuToggle.addEventListener('click', () => sidebar.classList.toggle('open'));
document.addEventListener('click', (e) => {
  if (window.innerWidth <= 768 && !sidebar.contains(e.target) && e.target !== menuToggle) {
    sidebar.classList.remove('open');
  }
});

// ---- Nav routing ----
const pages = {
  dashboard: renderDashboard,
  tournaments: renderTournaments,
  teams: renderTeams,
  players: renderPlayers,
  matches: renderMatches,
};

document.querySelectorAll('.nav-link').forEach(link => {
  link.addEventListener('click', (e) => {
    e.preventDefault();
    const page = link.dataset.page;
    navigate(page);
    sidebar.classList.remove('open');
  });
});

function navigate(page, params = {}) {
  document.querySelectorAll('.nav-link').forEach(l => l.classList.toggle('active', l.dataset.page === page));
  pageTitleEl.textContent = page.charAt(0).toUpperCase() + page.slice(1);
  if (pages[page]) pages[page](params);
}

// ============================================================
// DASHBOARD
// ============================================================
async function renderDashboard() {
  showLoader();
  pageTitleEl.textContent = 'Dashboard';
  try {
    const [stats, tournaments] = await Promise.all([
      API.get('/stats'),
      API.get('/tournaments'),
    ]);

    const recentTournaments = tournaments.slice(0, 4);

    contentEl.innerHTML = `
      <div class="stats-grid">
        <div class="stat-card">
          <span class="stat-icon">🏆</span>
          <span class="stat-label">Tournaments</span>
          <span class="stat-value">${stats.tournaments}</span>
        </div>
        <div class="stat-card">
          <span class="stat-icon">👥</span>
          <span class="stat-label">Teams</span>
          <span class="stat-value">${stats.teams}</span>
        </div>
        <div class="stat-card">
          <span class="stat-icon">⚽</span>
          <span class="stat-label">Players</span>
          <span class="stat-value">${stats.players}</span>
        </div>
        <div class="stat-card">
          <span class="stat-icon">📅</span>
          <span class="stat-label">Matches</span>
          <span class="stat-value">${stats.matches}</span>
        </div>
      </div>

      <div class="section-header">
        <span class="section-title">Recent Tournaments</span>
        <a href="#" class="nav-link" data-page="tournaments" style="font-size:.85rem">View All →</a>
      </div>
      <div class="cards-grid" id="dashTournaments">
        ${recentTournaments.length === 0
          ? '<div class="empty-state"><div class="icon">📭</div><p>No tournaments yet.</p></div>'
          : recentTournaments.map(t => tournamentCardHTML(t)).join('')
        }
      </div>
    `;

    // re-attach nav on "View All"
    contentEl.querySelectorAll('.nav-link[data-page]').forEach(l => {
      l.addEventListener('click', (e) => { e.preventDefault(); navigate(l.dataset.page); });
    });
    attachTournamentCardEvents();
  } catch (err) {
    showError('Failed to load dashboard: ' + err.message);
  }
}

// ============================================================
// TOURNAMENTS
// ============================================================
function tournamentCardHTML(t) {
  const start = t.start_date ? new Date(t.start_date).toLocaleDateString() : '—';
  const end   = t.end_date   ? new Date(t.end_date).toLocaleDateString()   : '—';
  return `
    <div class="card" data-tid="${t.tournament_id}">
      <div class="card-title">${esc(t.tournament_name)}</div>
      <span class="badge">${esc(t.sport_name || '—')}</span>
      <div class="card-meta">
        <span>📅 ${start} – ${end}</span>
        <span>👥 ${t.team_count} teams</span>
        <span>🆚 ${t.match_count} matches</span>
        ${t.format ? `<span>📋 ${esc(t.format)}</span>` : ''}
      </div>
    </div>`;
}

function attachTournamentCardEvents() {
  contentEl.querySelectorAll('.card[data-tid]').forEach(card => {
    card.addEventListener('click', () => renderTournamentDetail(card.dataset.tid));
  });
}

async function renderTournaments() {
  showLoader();
  pageTitleEl.textContent = 'Tournaments';
  try {
    const tournaments = await API.get('/tournaments');

    contentEl.innerHTML = `
      <div class="filter-row">
        <input class="search-bar" id="tSearch" placeholder="Search tournaments…" />
      </div>
      <div class="cards-grid" id="tGrid">
        ${tournaments.length === 0
          ? '<div class="empty-state"><div class="icon">📭</div><p>No tournaments found.</p></div>'
          : tournaments.map(t => tournamentCardHTML(t)).join('')
        }
      </div>`;

    attachTournamentCardEvents();

    document.getElementById('tSearch').addEventListener('input', (e) => {
      const q = e.target.value.toLowerCase();
      contentEl.querySelectorAll('.card[data-tid]').forEach(card => {
        card.style.display = card.textContent.toLowerCase().includes(q) ? '' : 'none';
      });
    });
  } catch (err) {
    showError('Failed to load tournaments: ' + err.message);
  }
}

async function renderTournamentDetail(id) {
  showLoader();
  pageTitleEl.textContent = 'Tournament';
  try {
    const [t, teams, matches, standings] = await Promise.all([
      API.get(`/tournaments/${id}`),
      API.get(`/tournaments/${id}/teams`),
      API.get(`/tournaments/${id}/matches`),
      API.get(`/standings/${id}`),
    ]);

    const start = t.start_date ? new Date(t.start_date).toLocaleDateString() : '—';
    const end   = t.end_date   ? new Date(t.end_date).toLocaleDateString()   : '—';

    contentEl.innerHTML = `
      <button class="btn-back" id="backBtn">← Back to Tournaments</button>
      <div class="detail-header">
        <div>
          <h2>${esc(t.tournament_name)}</h2>
          <div class="meta-row">
            <span>🏅 ${esc(t.sport_name || '—')}</span>
            <span>📅 ${start} – ${end}</span>
            <span>📋 ${esc(t.format || '—')}</span>
            <span>🗓 Season: ${esc(t.season || '—')}</span>
          </div>
          ${t.description ? `<p style="margin-top:10px;font-size:.88rem;color:var(--text-muted)">${esc(t.description)}</p>` : ''}
        </div>
        <div style="display:flex;gap:16px;flex-wrap:wrap">
          <div class="stat-card" style="min-width:100px">
            <span class="stat-label">Teams</span>
            <span class="stat-value" style="font-size:1.5rem">${t.team_count}</span>
          </div>
          <div class="stat-card" style="min-width:100px">
            <span class="stat-label">Matches</span>
            <span class="stat-value" style="font-size:1.5rem">${t.match_count}</span>
          </div>
        </div>
      </div>

      <div class="tabs">
        <button class="tab-btn active" data-tab="standings">Standings</button>
        <button class="tab-btn" data-tab="fixtures">Fixtures</button>
        <button class="tab-btn" data-tab="squad">Teams</button>
      </div>

      <div class="tab-panel active" id="tab-standings">
        ${renderStandingsTable(standings)}
      </div>
      <div class="tab-panel" id="tab-fixtures">
        ${renderMatchList(matches)}
      </div>
      <div class="tab-panel" id="tab-squad">
        ${renderTeamCards(teams)}
      </div>
    `;

    document.getElementById('backBtn').addEventListener('click', () => renderTournaments());
    setupTabs();
    attachMatchEvents();
    attachTeamCardEvents();
  } catch (err) {
    showError('Failed to load tournament: ' + err.message);
  }
}

// ============================================================
// STANDINGS TABLE
// ============================================================
function renderStandingsTable(rows) {
  if (!rows || rows.length === 0) {
    return '<div class="empty-state"><div class="icon">📊</div><p>No standings data yet.</p></div>';
  }
  return `
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Team</th>
            <th>P</th><th>W</th><th>D</th><th>L</th>
            <th>GF</th><th>GA</th><th>GD</th><th>Pts</th>
            <th>Form</th>
          </tr>
        </thead>
        <tbody>
          ${rows.map((r, i) => `
            <tr>
              <td class="${rankClass(i + 1)}">${i + 1}</td>
              <td><strong>${esc(r.team_name)}</strong></td>
              <td>${r.played}</td>
              <td>${r.won}</td>
              <td>${r.drawn}</td>
              <td>${r.lost}</td>
              <td>${r.goals_for}</td>
              <td>${r.goals_against}</td>
              <td>${r.goal_difference}</td>
              <td><strong>${r.points}</strong></td>
              <td>${renderForm(r.form)}</td>
            </tr>`).join('')}
        </tbody>
      </table>
    </div>`;
}

function rankClass(n) {
  if (n === 1) return 'rank-gold';
  if (n === 2) return 'rank-silver';
  if (n === 3) return 'rank-bronze';
  return '';
}

function renderForm(form) {
  if (!form || form === 'N/A') return '<span style="color:var(--text-muted)">—</span>';
  return form.split('').map(c =>
    `<span class="form-char form-${c}">${c}</span>`
  ).join('');
}

// ============================================================
// MATCH LIST
// ============================================================
function renderMatchList(matches) {
  if (!matches || matches.length === 0) {
    return '<div class="empty-state"><div class="icon">📅</div><p>No matches scheduled yet.</p></div>';
  }
  return matches.map(m => matchCardHTML(m)).join('');
}

function matchCardHTML(m) {
  const date = m.match_date ? new Date(m.match_date).toLocaleDateString() : '—';
  const hasScore = m.home_score !== null && m.home_score !== undefined;
  return `
    <div class="match-card" data-mid="${m.match_id}">
      <div class="match-teams">
        <span class="match-team">${esc(m.home_team)}</span>
        <span class="match-score">
          ${hasScore
            ? `${m.home_score}<span class="score-sep">:</span>${m.away_score}`
            : '<span style="color:var(--text-muted);font-size:.85rem">vs</span>'}
        </span>
        <span class="match-team away">${esc(m.away_team)}</span>
      </div>
      <div class="match-info">
        <div>${date}</div>
        ${m.venue_name ? `<div>📍 ${esc(m.venue_name)}</div>` : ''}
        ${m.round_number ? `<div>Round ${m.round_number}</div>` : ''}
      </div>
    </div>`;
}

function attachMatchEvents() {
  contentEl.querySelectorAll('.match-card[data-mid]').forEach(card => {
    card.addEventListener('click', () => openMatchModal(card.dataset.mid));
  });
}

async function openMatchModal(id) {
  openModal('<div class="loader-wrap"><div class="loader"></div></div>');
  try {
    const m = await API.get(`/matches/${id}`);
    const date = m.match_date ? new Date(m.match_date).toLocaleString() : '—';
    const hasScore = m.home_score !== null && m.home_score !== undefined;

    const statsHTML = m.player_stats && m.player_stats.length > 0
      ? `<div class="modal-section">
          <h4>Player Stats</h4>
          <div class="table-wrap">
            <table>
              <thead><tr><th>Player</th><th>Team</th><th>G</th><th>A</th><th>YC</th><th>RC</th><th>Min</th></tr></thead>
              <tbody>
                ${m.player_stats.map(s => `
                  <tr>
                    <td>${esc(s.player_name)}</td>
                    <td>${esc(s.team_name)}</td>
                    <td>${s.goals_scored}</td>
                    <td>${s.assists}</td>
                    <td>${s.yellow_cards}</td>
                    <td>${s.red_cards}</td>
                    <td>${s.minutes_played}</td>
                  </tr>`).join('')}
              </tbody>
            </table>
          </div>
        </div>`
      : '';

    openModal(`
      <div class="modal-title">Match Details</div>
      <div class="modal-section">
        <div style="text-align:center;padding:18px 0">
          <div style="font-size:1.1rem;font-weight:600">${esc(m.home_team)}</div>
          <div style="font-size:2rem;font-weight:700;color:var(--accent-lite);margin:8px 0">
            ${hasScore ? `${m.home_score} : ${m.away_score}` : 'vs'}
          </div>
          <div style="font-size:1.1rem;font-weight:600">${esc(m.away_team)}</div>
          ${m.match_notes ? `<p style="margin-top:10px;font-size:.83rem;color:var(--text-muted)">${esc(m.match_notes)}</p>` : ''}
        </div>
      </div>
      <div class="info-grid modal-section">
        <div class="info-item"><div class="label">Tournament</div>${esc(m.tournament_name)}</div>
        <div class="info-item"><div class="label">Date</div>${date}</div>
        <div class="info-item"><div class="label">Venue</div>${esc(m.venue_name || '—')}</div>
        <div class="info-item"><div class="label">Round</div>${m.round_number || '—'}</div>
      </div>
      ${statsHTML}
    `);
  } catch (err) {
    openModal(`<div class="empty-state"><div class="icon">⚠️</div><p>${err.message}</p></div>`);
  }
}

// ============================================================
// TEAMS
// ============================================================
function renderTeamCards(teams) {
  if (!teams || teams.length === 0) {
    return '<div class="empty-state"><div class="icon">👥</div><p>No teams found.</p></div>';
  }
  return `<div class="cards-grid">${teams.map(t => `
    <div class="card" data-team-id="${t.team_id}">
      <div class="card-title">${esc(t.team_name)}</div>
      <span class="badge">${esc(t.sport_name || '—')}</span>
      <div class="card-meta">
        ${t.city ? `<span>📍 ${esc(t.city)}</span>` : ''}
        ${t.founded_year ? `<span>🗓 Est. ${t.founded_year}</span>` : ''}
      </div>
    </div>`).join('')}</div>`;
}

function attachTeamCardEvents() {
  contentEl.querySelectorAll('.card[data-team-id]').forEach(card => {
    card.addEventListener('click', () => openTeamModal(card.dataset.teamId));
  });
}

async function renderTeams() {
  showLoader();
  pageTitleEl.textContent = 'Teams';
  try {
    const teams = await API.get('/teams');
    contentEl.innerHTML = `
      <div class="filter-row">
        <input class="search-bar" id="teamSearch" placeholder="Search teams…" />
      </div>
      ${renderTeamCards(teams)}
    `;
    attachTeamCardEvents();
    document.getElementById('teamSearch').addEventListener('input', (e) => {
      const q = e.target.value.toLowerCase();
      contentEl.querySelectorAll('.card[data-team-id]').forEach(card => {
        card.style.display = card.textContent.toLowerCase().includes(q) ? '' : 'none';
      });
    });
  } catch (err) {
    showError('Failed to load teams: ' + err.message);
  }
}

async function openTeamModal(id) {
  openModal('<div class="loader-wrap"><div class="loader"></div></div>');
  try {
    const [team, players, matches] = await Promise.all([
      API.get(`/teams/${id}`),
      API.get(`/teams/${id}/players`),
      API.get(`/teams/${id}/matches`),
    ]);

    const playersHTML = players.length === 0
      ? '<p style="color:var(--text-muted);font-size:.87rem">No players listed.</p>'
      : `<div class="table-wrap"><table>
          <thead><tr><th>#</th><th>Name</th><th>Position</th><th>Nationality</th><th>Age</th></tr></thead>
          <tbody>${players.map(p => `
            <tr>
              <td>${p.jersey_number ?? '—'}</td>
              <td>${esc(p.player_name)}</td>
              <td>${esc(p.position || '—')}</td>
              <td>${esc(p.nationality || '—')}</td>
              <td>${p.age ?? '—'}</td>
            </tr>`).join('')}
          </tbody>
        </table></div>`;

    const recent = matches.slice(0, 5).map(m => {
      const date = m.match_date ? new Date(m.match_date).toLocaleDateString() : '—';
      const hasScore = m.home_score !== null && m.home_score !== undefined;
      return `<div style="display:flex;justify-content:space-between;align-items:center;padding:7px 0;border-bottom:1px solid var(--border);font-size:.86rem">
        <span>${esc(m.home_team)} <strong>${hasScore ? m.home_score + ':' + m.away_score : 'vs'}</strong> ${esc(m.away_team)}</span>
        <span style="color:var(--text-muted)">${date}</span>
      </div>`;
    }).join('');

    openModal(`
      <div class="modal-title">${esc(team.team_name)}</div>
      <div class="info-grid modal-section">
        <div class="info-item"><div class="label">Sport</div>${esc(team.sport_name || '—')}</div>
        <div class="info-item"><div class="label">City</div>${esc(team.city || '—')}</div>
        <div class="info-item"><div class="label">Home Venue</div>${esc(team.home_venue_name || '—')}</div>
        <div class="info-item"><div class="label">Capacity</div>${team.capacity ? team.capacity.toLocaleString() : '—'}</div>
        <div class="info-item"><div class="label">Founded</div>${team.founded_year || '—'}</div>
      </div>
      <div class="modal-section"><h4>Squad (${players.length})</h4>${playersHTML}</div>
      ${matches.length > 0 ? `<div class="modal-section"><h4>Recent Matches</h4>${recent}</div>` : ''}
    `);
  } catch (err) {
    openModal(`<div class="empty-state"><div class="icon">⚠️</div><p>${err.message}</p></div>`);
  }
}

// ============================================================
// PLAYERS
// ============================================================
async function renderPlayers() {
  showLoader();
  pageTitleEl.textContent = 'Players';
  try {
    const [players, tournaments] = await Promise.all([
      API.get('/players'),
      API.get('/tournaments'),
    ]);

    contentEl.innerHTML = `
      <div class="filter-row">
        <input class="search-bar" id="playerSearch" placeholder="Search players…" />
        <select class="select-filter" id="tourneyFilter">
          <option value="">All Tournaments</option>
          ${tournaments.map(t => `<option value="${t.tournament_id}">${esc(t.tournament_name)}</option>`).join('')}
        </select>
      </div>
      <div class="cards-grid" id="playerGrid">
        ${renderPlayerCards(players)}
      </div>`;

    document.getElementById('playerSearch').addEventListener('input', filterPlayers);
    document.getElementById('tourneyFilter').addEventListener('change', async () => {
      const tid = document.getElementById('tourneyFilter').value;
      const grid = document.getElementById('playerGrid');
      grid.innerHTML = '<div class="loader-wrap"><div class="loader"></div></div>';
      try {
        const url = tid ? `/players?tournament_id=${tid}` : '/players';
        const p = await API.get(url);
        grid.innerHTML = renderPlayerCards(p);
        attachPlayerEvents();
        filterPlayers();
      } catch (e) {
        grid.innerHTML = `<div class="empty-state"><p>${e.message}</p></div>`;
      }
    });
    attachPlayerEvents();
  } catch (err) {
    showError('Failed to load players: ' + err.message);
  }
}

function filterPlayers() {
  const q = document.getElementById('playerSearch').value.toLowerCase();
  contentEl.querySelectorAll('.player-card').forEach(card => {
    card.style.display = card.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
}

function renderPlayerCards(players) {
  if (!players || players.length === 0) {
    return '<div class="empty-state"><div class="icon">⚽</div><p>No players found.</p></div>';
  }
  return players.map(p => `
    <div class="player-card" data-pid="${p.player_id}">
      <div class="player-name">${p.jersey_number ? `<span style="color:var(--text-muted);font-size:.85rem">#${p.jersey_number}</span> ` : ''}${esc(p.player_name)}</div>
      <div class="player-meta">
        <span>👥 ${esc(p.team_name || '—')}</span>
        ${p.position ? `<span>🎯 ${esc(p.position)}</span>` : ''}
        ${p.nationality ? `<span>🌍 ${esc(p.nationality)}</span>` : ''}
        ${p.age ? `<span>📅 Age ${p.age}</span>` : ''}
        <span class="badge" style="margin-left:auto">${esc(p.sport_name || '—')}</span>
      </div>
    </div>`).join('');
}

function attachPlayerEvents() {
  contentEl.querySelectorAll('.player-card[data-pid]').forEach(card => {
    card.addEventListener('click', () => openPlayerModal(card.dataset.pid));
  });
}

async function openPlayerModal(id) {
  openModal('<div class="loader-wrap"><div class="loader"></div></div>');
  try {
    const p = await API.get(`/players/${id}`);
    openModal(`
      <div class="modal-title">${esc(p.player_name)}</div>
      <div class="info-grid modal-section">
        <div class="info-item"><div class="label">Team</div>${esc(p.team_name || '—')}</div>
        <div class="info-item"><div class="label">Sport</div>${esc(p.sport_name || '—')}</div>
        <div class="info-item"><div class="label">Position</div>${esc(p.position || '—')}</div>
        <div class="info-item"><div class="label">Nationality</div>${esc(p.nationality || '—')}</div>
        <div class="info-item"><div class="label">Age</div>${p.age || '—'}</div>
        <div class="info-item"><div class="label">Jersey #</div>${p.jersey_number || '—'}</div>
      </div>
      <div class="modal-section">
        <h4>Career Stats</h4>
        <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
          <div class="stat-card">
            <span class="stat-label">Goals</span>
            <span class="stat-value" style="font-size:1.6rem">${p.stats?.total_goals ?? 0}</span>
          </div>
          <div class="stat-card">
            <span class="stat-label">Assists</span>
            <span class="stat-value" style="font-size:1.6rem">${p.stats?.total_assists ?? 0}</span>
          </div>
          <div class="stat-card">
            <span class="stat-label">Matches</span>
            <span class="stat-value" style="font-size:1.6rem">${p.stats?.matches_played ?? 0}</span>
          </div>
        </div>
      </div>
    `);
  } catch (err) {
    openModal(`<div class="empty-state"><div class="icon">⚠️</div><p>${err.message}</p></div>`);
  }
}

// ============================================================
// MATCHES
// ============================================================
async function renderMatches() {
  showLoader();
  pageTitleEl.textContent = 'Matches';
  try {
    const [matches, tournaments] = await Promise.all([
      API.get('/matches'),
      API.get('/tournaments'),
    ]);

    contentEl.innerHTML = `
      <div class="filter-row">
        <input class="search-bar" id="matchSearch" placeholder="Search teams, venues…" />
        <select class="select-filter" id="matchTourneyFilter">
          <option value="">All Tournaments</option>
          ${tournaments.map(t => `<option value="${t.tournament_id}">${esc(t.tournament_name)}</option>`).join('')}
        </select>
      </div>
      <div id="matchList">
        ${renderMatchList(matches)}
      </div>`;

    document.getElementById('matchSearch').addEventListener('input', () => {
      const q = document.getElementById('matchSearch').value.toLowerCase();
      contentEl.querySelectorAll('.match-card').forEach(c => {
        c.style.display = c.textContent.toLowerCase().includes(q) ? '' : 'none';
      });
    });

    document.getElementById('matchTourneyFilter').addEventListener('change', async () => {
      const tid = document.getElementById('matchTourneyFilter').value;
      const list = document.getElementById('matchList');
      list.innerHTML = '<div class="loader-wrap"><div class="loader"></div></div>';
      try {
        const url = tid ? `/matches?tournament_id=${tid}` : '/matches';
        const m = await API.get(url);
        list.innerHTML = renderMatchList(m);
        attachMatchEvents();
      } catch (e) {
        list.innerHTML = `<div class="empty-state"><p>${e.message}</p></div>`;
      }
    });

    attachMatchEvents();
  } catch (err) {
    showError('Failed to load matches: ' + err.message);
  }
}

// ============================================================
// UTILITIES
// ============================================================
function esc(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function setupTabs() {
  const tabs    = contentEl.querySelectorAll('.tab-btn');
  const panels  = contentEl.querySelectorAll('.tab-panel');
  tabs.forEach(btn => {
    btn.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      panels.forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      const panel = contentEl.querySelector(`#tab-${btn.dataset.tab}`);
      if (panel) panel.classList.add('active');
    });
  });
}

// ============================================================
// BOOTSTRAP
// ============================================================
navigate('dashboard');
