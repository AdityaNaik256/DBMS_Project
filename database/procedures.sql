-- ============================================================
-- Tournament & League Management System - Stored Procedures
-- MySQL 8.0+
-- Procedures:
--   1. GenerateFixtures   - Round-robin fixture generation
--   2. UpdateStandings    - Recalculate standings after a result
-- ============================================================

USE tournament_db;

DELIMITER $$

-- ------------------------------------------------------------
-- Procedure: GenerateFixtures
-- Generates home-and-away round-robin fixtures for every team
-- registered in the given tournament.
-- Each pair plays twice: once as home and once as away.
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS GenerateFixtures$$

CREATE PROCEDURE GenerateFixtures(IN p_tournament_id INT)
BEGIN
    DECLARE v_team_count INT DEFAULT 0;
    DECLARE i            INT DEFAULT 1;
    DECLARE j            INT DEFAULT 1;

    -- Build a numbered temporary table of team IDs for this tournament
    DROP TEMPORARY TABLE IF EXISTS temp_teams;
    CREATE TEMPORARY TABLE temp_teams AS
        SELECT  team_id,
                ROW_NUMBER() OVER (ORDER BY team_id) AS rn
        FROM    tournament_teams
        WHERE   tournament_id = p_tournament_id;

    SELECT COUNT(*) INTO v_team_count FROM temp_teams;

    IF v_team_count < 2 THEN
        DROP TEMPORARY TABLE IF EXISTS temp_teams;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tournament must have at least 2 teams to generate fixtures.';
    END IF;

    -- Round-robin: each ordered pair (i, j) where i < j generates
    -- one home fixture (i hosts j) and one away fixture (j hosts i).
    SET i = 1;
    outer_loop: WHILE i <= v_team_count DO
        SET j = i + 1;
        inner_loop: WHILE j <= v_team_count DO

            -- Home fixture: team i hosts team j
            INSERT INTO matches
                (tournament_id, home_team_id, away_team_id, round_number, match_status)
            SELECT  p_tournament_id,
                    t1.team_id,
                    t2.team_id,
                    i,
                    'Scheduled'
            FROM    temp_teams t1
            JOIN    temp_teams t2 ON t1.rn = i AND t2.rn = j;

            -- Away fixture: team j hosts team i (second half of the season)
            INSERT INTO matches
                (tournament_id, home_team_id, away_team_id, round_number, match_status)
            SELECT  p_tournament_id,
                    t2.team_id,
                    t1.team_id,
                    i + v_team_count,
                    'Scheduled'
            FROM    temp_teams t1
            JOIN    temp_teams t2 ON t1.rn = i AND t2.rn = j;

            SET j = j + 1;
        END WHILE inner_loop;
        SET i = i + 1;
    END WHILE outer_loop;

    DROP TEMPORARY TABLE IF EXISTS temp_teams;
END$$


-- ------------------------------------------------------------
-- Procedure: UpdateStandings
-- Recalculates and persists the standings for both the home
-- and away team of a given match after a score is recorded.
--
-- Uses INSERT ... ON DUPLICATE KEY UPDATE so it is safe to
-- call when a standing row does not yet exist.
--
-- Points awarded (football default):
--   Win  -> 3 pts  |  Draw -> 1 pt  |  Loss -> 0 pts
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS UpdateStandings$$

CREATE PROCEDURE UpdateStandings(IN p_match_id INT)
BEGIN
    DECLARE v_home_team_id  INT;
    DECLARE v_away_team_id  INT;
    DECLARE v_tournament_id INT;
    DECLARE v_home_score    INT;
    DECLARE v_away_score    INT;

    -- Fetch match context
    SELECT  m.home_team_id,
            m.away_team_id,
            m.tournament_id
    INTO    v_home_team_id,
            v_away_team_id,
            v_tournament_id
    FROM    matches m
    WHERE   m.match_id = p_match_id;

    -- Fetch score
    SELECT  ms.home_score,
            ms.away_score
    INTO    v_home_score,
            v_away_score
    FROM    match_scores ms
    WHERE   ms.match_id = p_match_id;

    -- ---- HOME TEAM ----
    INSERT INTO standings
        (tournament_id, team_id, played, won, drawn, lost,
         goals_for, goals_against, points)
    VALUES (
        v_tournament_id,
        v_home_team_id,
        1,
        IF(v_home_score >  v_away_score, 1, 0),
        IF(v_home_score =  v_away_score, 1, 0),
        IF(v_home_score <  v_away_score, 1, 0),
        v_home_score,
        v_away_score,
        IF(v_home_score >  v_away_score, 3,
            IF(v_home_score = v_away_score, 1, 0))
    )
    ON DUPLICATE KEY UPDATE
        played        = played        + 1,
        won           = won           + IF(v_home_score >  v_away_score, 1, 0),
        drawn         = drawn         + IF(v_home_score =  v_away_score, 1, 0),
        lost          = lost          + IF(v_home_score <  v_away_score, 1, 0),
        goals_for     = goals_for     + v_home_score,
        goals_against = goals_against + v_away_score,
        points        = points        + IF(v_home_score >  v_away_score, 3,
                                          IF(v_home_score = v_away_score, 1, 0));

    -- ---- AWAY TEAM ----
    INSERT INTO standings
        (tournament_id, team_id, played, won, drawn, lost,
         goals_for, goals_against, points)
    VALUES (
        v_tournament_id,
        v_away_team_id,
        1,
        IF(v_away_score >  v_home_score, 1, 0),
        IF(v_away_score =  v_home_score, 1, 0),
        IF(v_away_score <  v_home_score, 1, 0),
        v_away_score,
        v_home_score,
        IF(v_away_score >  v_home_score, 3,
            IF(v_away_score = v_home_score, 1, 0))
    )
    ON DUPLICATE KEY UPDATE
        played        = played        + 1,
        won           = won           + IF(v_away_score >  v_home_score, 1, 0),
        drawn         = drawn         + IF(v_away_score =  v_home_score, 1, 0),
        lost          = lost          + IF(v_away_score <  v_home_score, 1, 0),
        goals_for     = goals_for     + v_away_score,
        goals_against = goals_against + v_home_score,
        points        = points        + IF(v_away_score >  v_home_score, 3,
                                          IF(v_away_score = v_home_score, 1, 0));
END$$

DELIMITER ;
