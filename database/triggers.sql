-- ============================================================
-- Tournament & League Management System - Triggers
-- MySQL 8.0+
-- Triggers:
--   1. after_match_score_insert - auto-update standings & status
--   2. after_match_score_update - full recalc of standings
-- ============================================================
-- NOTE: Both triggers respect the session variable
--   SET @DISABLE_TRIGGER = 1;
-- which allows bulk data loading (e.g. sample_data.sql) to
-- bypass automatic standings calculation.
-- ============================================================

USE tournament_db;

DELIMITER $$

-- ------------------------------------------------------------
-- Trigger 1: after_match_score_insert
-- Fires after a new score row is inserted.
--   • Calls UpdateStandings to credit both teams.
--   • Marks the parent match as 'Completed'.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_match_score_insert$$

CREATE TRIGGER after_match_score_insert
AFTER INSERT ON match_scores
FOR EACH ROW
BEGIN
    IF COALESCE(@DISABLE_TRIGGER, 0) = 0 THEN
        CALL UpdateStandings(NEW.match_id);
        UPDATE matches
           SET match_status = 'Completed'
         WHERE match_id = NEW.match_id;
    END IF;
END$$


-- ------------------------------------------------------------
-- Trigger 2: after_match_score_update
-- Fires after an existing score row is updated (score correction).
--   • Deletes the current standing rows for both teams in the
--     tournament, then rebuilds them from scratch by aggregating
--     ALL completed match results, ensuring full accuracy.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_match_score_update$$

CREATE TRIGGER after_match_score_update
AFTER UPDATE ON match_scores
FOR EACH ROW
BEGIN
    DECLARE v_home_team_id  INT;
    DECLARE v_away_team_id  INT;
    DECLARE v_tournament_id INT;

    IF COALESCE(@DISABLE_TRIGGER, 0) = 0 THEN

        -- Identify the teams and tournament for this match
        SELECT  home_team_id,
                away_team_id,
                tournament_id
        INTO    v_home_team_id,
                v_away_team_id,
                v_tournament_id
        FROM    matches
        WHERE   match_id = NEW.match_id;

        -- Remove stale standing rows for both teams
        DELETE FROM standings
        WHERE  tournament_id = v_tournament_id
          AND  team_id IN (v_home_team_id, v_away_team_id);

        -- Rebuild standings for home team from all completed matches
        INSERT INTO standings
            (tournament_id, team_id, played, won, drawn, lost,
             goals_for, goals_against, points)
        SELECT
            m.tournament_id,
            v_home_team_id,
            COUNT(*)                                                          AS played,
            SUM(CASE
                    WHEN m.home_team_id = v_home_team_id
                         AND ms2.home_score > ms2.away_score                 THEN 1
                    WHEN m.away_team_id = v_home_team_id
                         AND ms2.away_score > ms2.home_score                 THEN 1
                    ELSE 0 END)                                               AS won,
            SUM(CASE WHEN ms2.home_score = ms2.away_score                    THEN 1
                     ELSE 0 END)                                             AS drawn,
            SUM(CASE
                    WHEN m.home_team_id = v_home_team_id
                         AND ms2.home_score < ms2.away_score                 THEN 1
                    WHEN m.away_team_id = v_home_team_id
                         AND ms2.away_score < ms2.home_score                 THEN 1
                    ELSE 0 END)                                               AS lost,
            SUM(CASE
                    WHEN m.home_team_id = v_home_team_id THEN ms2.home_score
                    ELSE ms2.away_score END)                                  AS goals_for,
            SUM(CASE
                    WHEN m.home_team_id = v_home_team_id THEN ms2.away_score
                    ELSE ms2.home_score END)                                  AS goals_against,
            SUM(CASE
                    WHEN m.home_team_id = v_home_team_id
                         AND ms2.home_score > ms2.away_score                 THEN 3
                    WHEN m.away_team_id = v_home_team_id
                         AND ms2.away_score > ms2.home_score                 THEN 3
                    WHEN ms2.home_score = ms2.away_score                     THEN 1
                    ELSE 0 END)                                               AS points
        FROM    matches      m
        JOIN    match_scores ms2 ON m.match_id = ms2.match_id
        WHERE   m.tournament_id = v_tournament_id
          AND   m.match_status  = 'Completed'
          AND   (m.home_team_id = v_home_team_id
              OR m.away_team_id = v_home_team_id)
        GROUP BY m.tournament_id;

        -- Rebuild standings for away team from all completed matches
        INSERT INTO standings
            (tournament_id, team_id, played, won, drawn, lost,
             goals_for, goals_against, points)
        SELECT
            m.tournament_id,
            v_away_team_id,
            COUNT(*)                                                          AS played,
            SUM(CASE
                    WHEN m.home_team_id = v_away_team_id
                         AND ms2.home_score > ms2.away_score                 THEN 1
                    WHEN m.away_team_id = v_away_team_id
                         AND ms2.away_score > ms2.home_score                 THEN 1
                    ELSE 0 END)                                               AS won,
            SUM(CASE WHEN ms2.home_score = ms2.away_score                    THEN 1
                     ELSE 0 END)                                             AS drawn,
            SUM(CASE
                    WHEN m.home_team_id = v_away_team_id
                         AND ms2.home_score < ms2.away_score                 THEN 1
                    WHEN m.away_team_id = v_away_team_id
                         AND ms2.away_score < ms2.home_score                 THEN 1
                    ELSE 0 END)                                               AS lost,
            SUM(CASE
                    WHEN m.home_team_id = v_away_team_id THEN ms2.home_score
                    ELSE ms2.away_score END)                                  AS goals_for,
            SUM(CASE
                    WHEN m.home_team_id = v_away_team_id THEN ms2.away_score
                    ELSE ms2.home_score END)                                  AS goals_against,
            SUM(CASE
                    WHEN m.home_team_id = v_away_team_id
                         AND ms2.home_score > ms2.away_score                 THEN 3
                    WHEN m.away_team_id = v_away_team_id
                         AND ms2.away_score > ms2.home_score                 THEN 3
                    WHEN ms2.home_score = ms2.away_score                     THEN 1
                    ELSE 0 END)                                               AS points
        FROM    matches      m
        JOIN    match_scores ms2 ON m.match_id = ms2.match_id
        WHERE   m.tournament_id = v_tournament_id
          AND   m.match_status  = 'Completed'
          AND   (m.home_team_id = v_away_team_id
              OR m.away_team_id = v_away_team_id)
        GROUP BY m.tournament_id;

    END IF;
END$$

DELIMITER ;
