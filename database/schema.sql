-- ============================================================
-- Tournament & League Management System - Database Schema
-- MySQL 8.0+
-- Description : Defines all tables, constraints, and indexes
--               for managing sports tournaments and leagues.
-- ============================================================

CREATE DATABASE IF NOT EXISTS tournament_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tournament_db;

-- ------------------------------------------------------------
-- Table: sports
-- Stores the types of sports supported by the system.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sports (
    sport_id    INT          NOT NULL AUTO_INCREMENT,
    sport_name  VARCHAR(50)  NOT NULL,
    description TEXT,
    PRIMARY KEY (sport_id),
    UNIQUE KEY uq_sport_name (sport_name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Supported sport types';

-- ------------------------------------------------------------
-- Table: venues
-- Stores stadium / arena information.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS venues (
    venue_id   INT          NOT NULL AUTO_INCREMENT,
    venue_name VARCHAR(100) NOT NULL,
    city       VARCHAR(100),
    country    VARCHAR(100),
    capacity   INT,
    PRIMARY KEY (venue_id),
    INDEX idx_venues_city    (city),
    INDEX idx_venues_country (country)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Stadium and arena information';

-- ------------------------------------------------------------
-- Table: sponsors
-- Stores sponsor / commercial partner information.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sponsors (
    sponsor_id    INT          NOT NULL AUTO_INCREMENT,
    sponsor_name  VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    website       VARCHAR(200),
    PRIMARY KEY (sponsor_id),
    INDEX idx_sponsors_name (sponsor_name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Sponsor and commercial partner information';

-- ------------------------------------------------------------
-- Table: tournaments
-- Stores tournament / league editions.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tournaments (
    tournament_id   INT          NOT NULL AUTO_INCREMENT,
    tournament_name VARCHAR(100) NOT NULL,
    sport_id        INT,
    season          VARCHAR(20),
    start_date      DATE,
    end_date        DATE,
    format          ENUM('Round Robin','Knockout','League+Knockout'),
    description     TEXT,
    PRIMARY KEY (tournament_id),
    CONSTRAINT fk_tournament_sport
        FOREIGN KEY (sport_id) REFERENCES sports (sport_id)
        ON DELETE CASCADE,
    INDEX idx_tournaments_sport  (sport_id),
    INDEX idx_tournaments_season (season)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Tournament and league editions';

-- ------------------------------------------------------------
-- Table: teams
-- Stores participating team information.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS teams (
    team_id       INT          NOT NULL AUTO_INCREMENT,
    team_name     VARCHAR(100) NOT NULL,
    sport_id      INT,
    city          VARCHAR(100),
    home_venue_id INT,
    founded_year  INT,
    PRIMARY KEY (team_id),
    CONSTRAINT fk_team_sport
        FOREIGN KEY (sport_id) REFERENCES sports (sport_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_team_venue
        FOREIGN KEY (home_venue_id) REFERENCES venues (venue_id)
        ON DELETE SET NULL,
    INDEX idx_teams_sport (sport_id),
    INDEX idx_teams_venue (home_venue_id),
    INDEX idx_teams_city  (city)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Team information';

-- ------------------------------------------------------------
-- Table: players
-- Stores individual player profiles.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS players (
    player_id     INT          NOT NULL AUTO_INCREMENT,
    player_name   VARCHAR(100) NOT NULL,
    team_id       INT,
    sport_id      INT,
    position      VARCHAR(50),
    nationality   VARCHAR(100),
    age           INT,
    jersey_number INT,
    PRIMARY KEY (player_id),
    CONSTRAINT fk_player_team
        FOREIGN KEY (team_id) REFERENCES teams (team_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_player_sport
        FOREIGN KEY (sport_id) REFERENCES sports (sport_id)
        ON DELETE CASCADE,
    INDEX idx_players_team        (team_id),
    INDEX idx_players_sport       (sport_id),
    INDEX idx_players_nationality (nationality)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Player profiles';

-- ------------------------------------------------------------
-- Table: tournament_teams  (junction)
-- Maps which teams participate in which tournament.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tournament_teams (
    tournament_id INT NOT NULL,
    team_id       INT NOT NULL,
    PRIMARY KEY (tournament_id, team_id),
    CONSTRAINT fk_tt_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments (tournament_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_tt_team
        FOREIGN KEY (team_id) REFERENCES teams (team_id)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Teams registered in each tournament (many-to-many)';

-- ------------------------------------------------------------
-- Table: tournament_sponsors  (junction)
-- Maps sponsors to tournaments with deal details.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tournament_sponsors (
    tournament_id      INT            NOT NULL,
    sponsor_id         INT            NOT NULL,
    sponsorship_amount DECIMAL(15,2),
    contract_type      VARCHAR(50),
    PRIMARY KEY (tournament_id, sponsor_id),
    CONSTRAINT fk_ts_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments (tournament_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ts_sponsor
        FOREIGN KEY (sponsor_id) REFERENCES sponsors (sponsor_id)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Sponsorship deals per tournament (many-to-many)';

-- ------------------------------------------------------------
-- Table: matches
-- Stores the fixture schedule and current status.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS matches (
    match_id     INT      NOT NULL AUTO_INCREMENT,
    tournament_id INT,
    home_team_id INT,
    away_team_id INT,
    venue_id     INT,
    match_date   DATETIME,
    round_number INT,
    match_status ENUM('Scheduled','In Progress','Completed','Postponed')
                 DEFAULT 'Scheduled',
    PRIMARY KEY (match_id),
    CONSTRAINT fk_match_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments (tournament_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_match_home_team
        FOREIGN KEY (home_team_id) REFERENCES teams (team_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_match_away_team
        FOREIGN KEY (away_team_id) REFERENCES teams (team_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_match_venue
        FOREIGN KEY (venue_id) REFERENCES venues (venue_id)
        ON DELETE SET NULL,
    INDEX idx_matches_tournament (tournament_id),
    INDEX idx_matches_home_team  (home_team_id),
    INDEX idx_matches_away_team  (away_team_id),
    INDEX idx_matches_date       (match_date),
    INDEX idx_matches_status     (match_status)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Fixture schedule and live status';

-- ------------------------------------------------------------
-- Table: match_scores
-- Stores final or live scores for a match (1-to-1 with matches).
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS match_scores (
    score_id       INT  NOT NULL AUTO_INCREMENT,
    match_id       INT  NOT NULL,
    home_score     INT  DEFAULT 0,
    away_score     INT  DEFAULT 0,
    winner_team_id INT,
    match_notes    TEXT,
    PRIMARY KEY (score_id),
    UNIQUE KEY uq_match_score (match_id),
    CONSTRAINT fk_ms_match
        FOREIGN KEY (match_id) REFERENCES matches (match_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ms_winner
        FOREIGN KEY (winner_team_id) REFERENCES teams (team_id)
        ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Match results and final scores';

-- ------------------------------------------------------------
-- Table: standings
-- Stores the running league table per tournament.
-- goal_difference is a generated (virtual) column.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS standings (
    standing_id     INT NOT NULL AUTO_INCREMENT,
    tournament_id   INT,
    team_id         INT,
    played          INT DEFAULT 0,
    won             INT DEFAULT 0,
    drawn           INT DEFAULT 0,
    lost            INT DEFAULT 0,
    goals_for       INT DEFAULT 0,
    goals_against   INT DEFAULT 0,
    points          INT DEFAULT 0,
    goal_difference INT GENERATED ALWAYS AS (goals_for - goals_against) STORED,
    PRIMARY KEY (standing_id),
    UNIQUE KEY uq_standing (tournament_id, team_id),
    CONSTRAINT fk_standing_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments (tournament_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_standing_team
        FOREIGN KEY (team_id) REFERENCES teams (team_id)
        ON DELETE CASCADE,
    INDEX idx_standings_tournament (tournament_id),
    INDEX idx_standings_points     (tournament_id, points DESC)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='League table / standings per tournament';

-- ------------------------------------------------------------
-- Table: player_stats
-- Stores per-match statistics for each player.
-- special_stat is sport-specific:
--   Football  -> not used (0)
--   Cricket   -> wickets taken
--   Kabaddi   -> tackle points
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS player_stats (
    stat_id        INT NOT NULL AUTO_INCREMENT,
    player_id      INT,
    match_id       INT,
    tournament_id  INT,
    goals_scored   INT DEFAULT 0,
    assists        INT DEFAULT 0,
    yellow_cards   INT DEFAULT 0,
    red_cards      INT DEFAULT 0,
    minutes_played INT DEFAULT 0,
    special_stat   INT DEFAULT 0
        COMMENT 'wickets for cricket, raid/tackle points for kabaddi',
    PRIMARY KEY (stat_id),
    CONSTRAINT fk_ps_player
        FOREIGN KEY (player_id) REFERENCES players (player_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ps_match
        FOREIGN KEY (match_id) REFERENCES matches (match_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ps_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments (tournament_id)
        ON DELETE CASCADE,
    INDEX idx_ps_player     (player_id),
    INDEX idx_ps_match      (match_id),
    INDEX idx_ps_tournament (tournament_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Per-match player statistics';


-- ============================================================
-- COMPLEX ANALYTICAL QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Teams that have won MORE matches than the average
--          wins across ALL teams in the same tournament.
--          Uses a correlated subquery.
-- ------------------------------------------------------------
/*
SELECT  t.team_name,
        s.won          AS wins,
        s.tournament_id,
        tr.tournament_name
FROM    standings s
JOIN    teams       t  ON s.team_id       = t.team_id
JOIN    tournaments tr ON s.tournament_id = tr.tournament_id
WHERE   s.won > (
            SELECT AVG(s2.won)
            FROM   standings s2
            WHERE  s2.tournament_id = s.tournament_id
        )
ORDER BY s.tournament_id, s.won DESC;
*/

-- ------------------------------------------------------------
-- Query 2: Players who scored in EVERY match they played
--          (i.e. no match exists where they scored 0 goals).
--          Uses a nested NOT EXISTS subquery.
-- ------------------------------------------------------------
/*
SELECT  p.player_name,
        t.team_name,
        COUNT(ps.match_id) AS matches_played
FROM    players      p
JOIN    teams        t  ON p.team_id   = t.team_id
JOIN    player_stats ps ON p.player_id = ps.player_id
WHERE   NOT EXISTS (
            SELECT 1
            FROM   player_stats ps2
            WHERE  ps2.player_id   = p.player_id
              AND  ps2.goals_scored = 0
        )
GROUP BY p.player_id, p.player_name, t.team_name
HAVING  COUNT(ps.match_id) > 0
ORDER BY matches_played DESC;
*/

-- ------------------------------------------------------------
-- Query 3: Top 4 teams in a given tournament using
--          ROW_NUMBER() in a derived (nested) query.
-- ------------------------------------------------------------
/*
SELECT  team_name,
        points,
        won,
        drawn,
        lost,
        goals_for,
        goals_against,
        goal_difference,
        `rank`
FROM (
    SELECT  t.team_name,
            s.points,
            s.won,
            s.drawn,
            s.lost,
            s.goals_for,
            s.goals_against,
            s.goal_difference,
            ROW_NUMBER() OVER (
                PARTITION BY s.tournament_id
                ORDER BY s.points DESC,
                         s.goal_difference DESC,
                         s.goals_for DESC
            ) AS `rank`
    FROM    standings s
    JOIN    teams t ON s.team_id = t.team_id
    WHERE   s.tournament_id = 1          -- change to desired tournament
) ranked
WHERE  `rank` <= 4;
*/

-- ------------------------------------------------------------
-- Query 4: Matches where BOTH teams scored more than their
--          respective average home/away score in that
--          tournament. Uses two correlated subqueries.
-- ------------------------------------------------------------
/*
SELECT  m.match_id,
        ht.team_name  AS home_team,
        at.team_name  AS away_team,
        ms.home_score,
        ms.away_score,
        m.match_date
FROM    matches      m
JOIN    match_scores ms ON m.match_id      = ms.match_id
JOIN    teams        ht ON m.home_team_id  = ht.team_id
JOIN    teams        at ON m.away_team_id  = at.team_id
WHERE   ms.home_score > (
            SELECT  AVG(ms2.home_score)
            FROM    matches      m2
            JOIN    match_scores ms2 ON m2.match_id     = ms2.match_id
            WHERE   m2.tournament_id  = m.tournament_id
              AND   m2.home_team_id   = m.home_team_id
        )
  AND   ms.away_score > (
            SELECT  AVG(ms3.away_score)
            FROM    matches      m3
            JOIN    match_scores ms3 ON m3.match_id     = ms3.match_id
            WHERE   m3.tournament_id  = m.tournament_id
              AND   m3.away_team_id   = m.away_team_id
        )
ORDER BY m.match_date;
*/

-- ------------------------------------------------------------
-- Query 5: Player with the most goals in each team,
--          using a correlated subquery with GROUP BY.
-- ------------------------------------------------------------
/*
SELECT  p.player_name,
        t.team_name,
        SUM(ps.goals_scored) AS total_goals
FROM    players      p
JOIN    player_stats ps ON p.player_id = ps.player_id
JOIN    teams        t  ON p.team_id   = t.team_id
GROUP BY p.player_id, p.player_name, p.team_id, t.team_name
HAVING  SUM(ps.goals_scored) = (
            SELECT  MAX(sub.total)
            FROM (
                SELECT  p2.team_id,
                        SUM(ps2.goals_scored) AS total
                FROM    players      p2
                JOIN    player_stats ps2 ON p2.player_id = ps2.player_id
                GROUP BY p2.player_id, p2.team_id
            ) sub
            WHERE sub.team_id = p.team_id
        )
ORDER BY total_goals DESC, t.team_name;
*/
