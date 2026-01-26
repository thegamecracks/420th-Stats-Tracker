CREATE TABLE stat_player (
    steam_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE stat (
    stat_id VARCHAR(32) PRIMARY KEY,
    score_multiplier BIGINT NOT NULL
);

INSERT INTO stat VALUES ('deaths',      -1);
INSERT INTO stat VALUES ('incaps',      -1);
INSERT INTO stat VALUES ('kills',        1);
INSERT INTO stat VALUES ('kills_air',    1);
INSERT INTO stat VALUES ('kills_cars',   1);
INSERT INTO stat VALUES ('kills_ships',  1);
INSERT INTO stat VALUES ('kills_tanks',  1);
INSERT INTO stat VALUES ('playtime',     0);
INSERT INTO stat VALUES ('revives',      1);
INSERT INTO stat VALUES ('score',        0);
INSERT INTO stat VALUES ('transports',   1);

CREATE TABLE stat_server (
    server_id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO stat_server VALUES ('main', 'Main Server');

CREATE TABLE stat_player_daily (
    created_at DATE,
    steam_id VARCHAR(20) REFERENCES stat_player (steam_id),
    stat_id VARCHAR(32) REFERENCES stat (stat_id),
    server_id VARCHAR(32) REFERENCES stat_server (server_id),
    amount BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (created_at, steam_id, stat_id, server_id)
);

-- Would prefer materialized view, but is not supported in MariaDB
CREATE TABLE stat_player_weekly (
    -- created_at TINYINT CHECK (created_at BETWEEN 0 AND 53), -- WEEK()
    created_at DATE CHECK (DAYOFWEEK(created_at) = 1),
    steam_id VARCHAR(20) REFERENCES stat_player (steam_id),
    stat_id VARCHAR(32) REFERENCES stat (stat_id),
    server_id VARCHAR(32) REFERENCES stat_server (server_id),
    amount BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (created_at, steam_id, stat_id, server_id)
);

-- Would prefer materialized view, but is not supported in MariaDB
CREATE TABLE stat_player_monthly (
    -- created_at TINYINT CHECK (created_at BETWEEN 1 AND 12), -- MONTH()
    created_at DATE CHECK (DAY(created_at) = 1),
    steam_id VARCHAR(20) REFERENCES stat_player (steam_id),
    stat_id VARCHAR(32) REFERENCES stat (stat_id),
    server_id VARCHAR(32) REFERENCES stat_server (server_id),
    amount BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (created_at, steam_id, stat_id, server_id)
);

CREATE TABLE stat_player_alltime (
    steam_id VARCHAR(20) REFERENCES stat_player (steam_id),
    stat_id VARCHAR(32) REFERENCES stat (stat_id),
    server_id VARCHAR(32) REFERENCES stat_server (server_id),
    amount BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (steam_id, stat_id, server_id)
);

-- https://mariadb.com/docs/server/server-usage/stored-routines/stored-procedures/stored-procedure-overview
DELIMITER //

CREATE PROCEDURE add_player_stat(
    p_steam_id VARCHAR(20),
    p_name VARCHAR(255), -- nullable
    p_stat_id VARCHAR(32),
    p_server_id VARCHAR(32),
    p_amount BIGINT
)
    MODIFIES SQL DATA
    BEGIN
        -- https://mariadb.com/docs/server/reference/sql-statements/data-manipulation/inserting-loading-data/insert-on-duplicate-key-update
        INSERT INTO stat_player (steam_id, name)
            VALUES (p_steam_id, COALESCE(p_name, 'Unknown Player'))
            ON DUPLICATE KEY UPDATE
                name = COALESCE(p_name, name);
        INSERT INTO stat_player_daily (created_at, steam_id, stat_id, server_id, amount)
            VALUES (CURRENT_DATE, p_steam_id, p_stat_id, p_server_id, p_amount)
            ON DUPLICATE KEY UPDATE
                amount = amount + p_amount;
        CALL add_stat_player_daily_score(CURRENT_DATE, p_steam_id, p_stat_id, p_server_id, p_amount);
    END;
//

CREATE PROCEDURE prune_stat_player()
    MODIFIES SQL DATA
    BEGIN
        DELETE FROM stat_player_daily WHERE created_at < DATE_SUB(NOW(), INTERVAL 2 MONTH);
        DELETE FROM stat_player_weekly WHERE created_at < DATE_SUB(NOW(), INTERVAL 2 MONTH);
        DELETE FROM stat_player_monthly WHERE created_at < DATE_SUB(NOW(), INTERVAL 2 MONTH);
    END;
//

CREATE PROCEDURE add_stat_player_daily_score(
    p_created_at DATE,
    p_steam_id VARCHAR(20),
    p_stat_id VARCHAR(32),
    p_server_id VARCHAR(32),
    p_amount BIGINT
)
    MODIFIES SQL DATA
    proc_label:BEGIN
        INSERT INTO stat_player_daily (created_at, steam_id, stat_id, server_id, amount)
            VALUES (CURRENT_DATE, p_steam_id, 'score', p_server_id, p_amount * stat_score_multiplier(p_stat_id))
            ON DUPLICATE KEY UPDATE
                amount = amount + p_amount * stat_score_multiplier(p_stat_id);
    END;
//

-- https://mariadb.com/docs/server/server-usage/stored-routines/stored-functions/stored-function-overview
CREATE FUNCTION stat_score_multiplier(
    p_stat_id VARCHAR(32)
)
    RETURNS BIGINT
    READS SQL DATA
    BEGIN
        RETURN (SELECT score_multiplier FROM stat WHERE stat_id = p_stat_id);
    END;
//

DELIMITER ;

-- https://mariadb.com/docs/server/server-usage/triggers-events/triggers/trigger-overview
-- -- FIXME: SQL Error [1442] [HY000]: (conn=6) Can't update table 'stat_player_daily' in stored function/trigger because it is already used by statement which invoked this stored function/trigger
-- CREATE TRIGGER tg_add_stat_player_daily_score
--     AFTER INSERT OR UPDATE ON stat_player_daily
--     FOR EACH ROW
--     CALL add_stat_player_daily_score(
--         NEW.created_at,
--         NEW.steam_id,
--         NEW.stat_id,
--         NEW.server_id,
--         NEW.amount - COALESCE(OLD.amount, 0)
--     );

CREATE TRIGGER tg_add_stat_player_weekly
    AFTER INSERT OR UPDATE ON stat_player_daily
    FOR EACH ROW
    INSERT INTO stat_player_weekly (created_at, steam_id, stat_id, server_id, amount)
        -- FIXME: convert NEW.created_at to last week as DATE
        VALUES (NEW.created_at, NEW.steam_id, NEW.stat_id, NEW.server_id, NEW.amount)
        ON DUPLICATE KEY UPDATE
            amount = amount + NEW.amount - COALESCE(OLD.amount, 0);

CREATE TRIGGER tg_add_stat_player_monthly
    AFTER INSERT OR UPDATE ON stat_player_daily
    FOR EACH ROW
    INSERT INTO stat_player_monthly (created_at, steam_id, stat_id, server_id, amount)
        -- FIXME: convert NEW.created_at to last month as DATE
        VALUES (NEW.created_at, NEW.steam_id, NEW.stat_id, NEW.server_id, NEW.amount)
        ON DUPLICATE KEY UPDATE
            amount = amount + NEW.amount - COALESCE(OLD.amount, 0);

-- https://mariadb.com/docs/server/server-usage/triggers-events/event-scheduler/events
CREATE EVENT prune_stat_player_event
  ON SCHEDULE EVERY 1 MONTH
  DO CALL prune_stat_player();
