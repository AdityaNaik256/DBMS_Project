-- ============================================================
-- Tournament & League Management System - Functions
-- MySQL 8.0+
-- Functions:
--   1. GetTeamForm    - Last 5 results as "WWDLW" string
--   2. GetTopScorer   - Player name with most goals in a tournament
-- ============================================================

USE tournament_db;

DELIMITER $$

-- ------------------------------------------------------------
-- Function: GetTeamForm
-- Returns the last 5 completed match results for a team in a
-- tournament as a single character string, e.g. 'WWDLW'.
--   W = Win  |  D = Draw  |  L = Loss
-- Returns 'N/A' if no completed matches are found.
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS GetTeamForm$$

CREATE FUNCTION GetTeamForm(
    p_team_id       INT,
    p_tournament_id INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_form       VARCHAR(20) DEFAULT '';
    DECLARE v_result     CHAR(1);
    DECLARE v_match_id   INT;
    DECLARE v_home_team  INT;
    DECLARE v_home_score INT;
    DECLARE v_away_score INT;
    DECLARE v_count      INT     DEFAULT 0;
    DECLARE v_done       BOOLEAN DEFAULT FALSE;

    -- Cursor: last 5 completed matches for the team, newest first
    DECLARE cur CURSOR FOR
        SELECT  m.match_id,
                m.home_team_id,
                ms.home_score,
                ms.away_score
        FROM    matches      m
        JOIN    match_scores ms ON m.match_id = ms.match_id
        WHERE   m.tournament_id = p_tournament_id
          AND   (m.home_team_id = p_team_id OR m.away_team_id = p_team_id)
          AND   m.match_status  = 'Completed'
        ORDER BY m.match_date DESC
        LIMIT 5;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_match_id, v_home_team, v_home_score, v_away_score;

        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Determine result from the perspective of p_team_id
        IF v_home_team = p_team_id THEN
            IF    v_home_score > v_away_score THEN SET v_result = 'W';
            ELSEIF v_home_score = v_away_score THEN SET v_result = 'D';
            ELSE                                    SET v_result = 'L';
            END IF;
        ELSE
            IF    v_away_score > v_home_score THEN SET v_result = 'W';
            ELSEIF v_away_score = v_home_score THEN SET v_result = 'D';
            ELSE                                    SET v_result = 'L';
            END IF;
        END IF;

        SET v_form  = CONCAT(v_form, v_result);
        SET v_count = v_count + 1;

        IF v_count >= 5 THEN
            LEAVE read_loop;
        END IF;
    END LOOP read_loop;

    CLOSE cur;

    RETURN IF(v_form = '', 'N/A', v_form);
END$$


-- ------------------------------------------------------------
-- Function: GetTopScorer
-- Returns the name of the player with the highest total goals
-- in a given tournament across all their match appearances.
-- Returns 'N/A' if no player stats exist for the tournament.
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS GetTopScorer$$

CREATE FUNCTION GetTopScorer(p_tournament_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_player_name VARCHAR(100) DEFAULT NULL;

    SELECT  p.player_name
    INTO    v_player_name
    FROM    player_stats ps
    JOIN    players      p  ON ps.player_id    = p.player_id
    WHERE   ps.tournament_id = p_tournament_id
    GROUP BY ps.player_id, p.player_name
    ORDER BY SUM(ps.goals_scored) DESC
    LIMIT 1;

    RETURN COALESCE(v_player_name, 'N/A');
END$$

DELIMITER ;
