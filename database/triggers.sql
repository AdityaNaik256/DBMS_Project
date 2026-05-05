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

        -- Delegate per-team rebuild to the helper procedure
        CALL RebuildTeamStandings(v_tournament_id, v_home_team_id);
        CALL RebuildTeamStandings(v_tournament_id, v_away_team_id);

    END IF;
END$$

DELIMITER ;
