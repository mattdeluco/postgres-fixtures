\set QUIET 1
\timing off

SELECT '_' || md5(random()::text) AS db_name
\gset
\i database.sql

--
-- Tests for pgTAP.
--
--
-- Format the output for nice TAP.
\pset format unaligned
\pset tuples_only true
\pset pager off

-- Revert all changes on failure.
\set ON_ERROR_ROLLBACK 1
--\set ON_ERROR_STOP true


CREATE SCHEMA IF NOT EXISTS tests;
CREATE SCHEMA IF NOT EXISTS pgtap;

SELECT set_config('search_path', 'pgtap, tests, ' || current_setting('search_path'), FALSE);

DO LANGUAGE plpgsql $$
BEGIN
    RAISE NOTICE 'SEARCH PATH: %', current_setting('search_path');
END
$$;

CREATE EXTENSION IF NOT EXISTS pgtap;

BEGIN;

    \i pay_group/test_pay_group.sql
    \i journal/test_journal.sql
    \i journal/test_journal_date_range.sql
    \i journal/test_journal_report_view.sql
    \i journal/test_journal_add_entries.sql

    SELECT * FROM runtests('tests'::name);

ROLLBACK;

\c template1;
DROP DATABASE :db_name;

\pset format aligned
\pset tuples_only false
\set QUIET 0
\timing on