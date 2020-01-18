----------
-- Schema
----------
CREATE SCHEMA IF NOT EXISTS pay_group;
SELECT set_config('search_path', 'pay_group, ' || current_setting('search_path'), FALSE);

----------
-- Tables
----------
CREATE TABLE IF NOT EXISTS pay_group (
    id TEXT PRIMARY KEY,
    rate NUMERIC(18,2)
);

----------
-- API
----------
CREATE OR REPLACE FUNCTION create_or_update (
    in_id TEXT,
    in_rate NUMERIC(18,2)
) RETURNS BIGINT
AS $$
DECLARE
    row_count BIGINT;
BEGIN
    INSERT INTO pay_group.pay_group
        VALUES (in_id, in_rate)
        ON CONFLICT (id)
        DO UPDATE SET rate=in_rate;
    
    GET DIAGNOSTICS row_count = ROW_COUNT;

    RETURN row_count;
END;
$$ LANGUAGE plpgsql;