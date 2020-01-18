----------
-- Schema
----------
CREATE SCHEMA IF NOT EXISTS journal;
SELECT set_config('search_path', 'journal, ' || current_setting('search_path'), FALSE);

----------
-- Types
----------
CREATE TYPE journal_type AS (
    entry_date DATE,
    hours_worked NUMERIC(18, 2),
    employee_id BIGINT,
    rate_group TEXT
);

----------
-- Tables
----------
CREATE TABLE IF NOT EXISTS journal (
    employee_id BIGINT,
    entry_date DATE,
    hours_worked NUMERIC(18, 2) NOT NULL,
    pay_group_id TEXT NOT NULL REFERENCES pay_group.pay_group(id),
    report_id BIGINT NOT NULL,
    PRIMARY KEY (employee_id, entry_date)
);

CREATE INDEX IF NOT EXISTS report_id_idx ON journal.journal (report_id);

----------
-- API
----------
CREATE OR REPLACE FUNCTION journal.add_entries (
    in_entries journal_type[],
    in_report_id BIGINT
) RETURNS BIGINT
AS $$
DECLARE
    row_count BIGINT;
BEGIN
    PERFORM
        DISTINCT(report_id)
    FROM
        journal.journal
    WHERE report_id=in_report_id;

    IF FOUND THEN
        RAISE EXCEPTION 'Duplicate report id %', in_report_id
            USING ERRCODE = 'unique_violation';
    END IF;

    INSERT INTO journal.journal (
        entry_date, hours_worked, employee_id, pay_group_id, report_id
    )
        SELECT *, in_report_id FROM UNNEST(in_entries);

    GET DIAGNOSTICS row_count = ROW_COUNT;

    RETURN row_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION journal.add_entries (
    in_json_txt JSON,
    in_report_id BIGINT
) RETURNS BIGINT
AS $$
DECLARE
    row_count BIGINT;
BEGIN
    WITH journal_entries AS (
        SELECT
            to_date(rec->>0, 'DD/MM/YYYY'),
            (rec->>1)::NUMERIC(18, 2),
            (rec->>2)::BIGINT,
            (rec->>3)::TEXT
        FROM
            json_array_elements(in_json_txt) AS rec
    )
    SELECT
        journal.add_entries(array_agg(journal_entries::journal_type), in_report_id)
    INTO
        row_count
    FROM
        journal_entries;

    RETURN row_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION journal.date_start (
    in_date DATE
) RETURNS DATE
AS $$
BEGIN
    IF EXTRACT(day from in_date) <= 15 THEN
        RETURN date_trunc('month', in_date)::DATE;
    END IF;

    RETURN to_char(in_date, 'yyyy-mm-16')::DATE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION journal.date_end (
    in_date DATE
) RETURNS DATE
AS $$
BEGIN
    IF EXTRACT(day from in_date) <= 15 THEN
        RETURN to_char(in_date, 'yyyy-mm-15')::DATE;
    END IF;

    RETURN (date_trunc('month', in_date) + interval '1 month' - interval '1 day')::DATE;
END;
$$ LANGUAGE plpgsql;

----------
-- Views
----------
CREATE OR REPLACE VIEW journal.report AS
    SELECT
        j.employee_id,
        journal.date_start(j.entry_date) AS pay_start,
        journal.date_end(j.entry_date) AS pay_end,
        sum(j.hours_worked * p.rate)::NUMERIC(18,2)
    FROM
        journal.journal AS j
    JOIN
        pay_group.pay_group AS p
    ON (j.pay_group_id = p.id)
    GROUP BY
        j.employee_id, pay_start, pay_end
    ORDER BY
        j.employee_id, pay_start;
