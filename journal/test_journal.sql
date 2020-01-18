CREATE OR REPLACE FUNCTION tests.test_journal()
RETURNS SETOF TEXT AS
$testsuite$
DECLARE
BEGIN
    -- Test duplicate report_id
    INSERT INTO pay_group.pay_group VALUES (
        'A', 30.00
    );

    INSERT INTO journal.journal VALUES (
        1, '2020-01-11', 35.00, 'A', 1
    );

    RETURN QUERY SELECT throws_ok(
        format($$
            SELECT journal.add_entries(ARRAY[
                ROW('2020-01-11', 35.00, 2, 'A')
            ]::journal.journal_type[],
            1)
        $$),
        '23505',
        'Duplicate report id 1',
        'Throws on duplicate report id'
    );

    RETURN QUERY SELECT lives_ok(
        format($$
            SELECT journal.add_entries(ARRAY[
                ROW('2020-01-11', 35.00, 2, 'A')
            ]::journal.journal_type[],
            2)
        $$),
        'Does not throw on unique report id'
    );

    -- Test primary key (employee_id, entry_date)
    RETURN QUERY SELECT throws_ok(
        format($$
            SELECT journal.add_entries(ARRAY[
                ROW('2018-01-11', 35.00, 1, 'A'),
                ROW('2020-01-11', 35.00, 1, 'A')
            ]::journal.journal_type[],
            3)
        $$),
        '23505',
        'duplicate key value violates unique constraint "journal_pkey"',
        'Throws on duplicate report id'
    );

    RETURN QUERY SELECT set_eq(
        'SELECT DISTINCT(report_id) FROM journal.journal',
        ARRAY[1, 2],
        'Report id not recorded after failure'
    );

    -- Test add_entries()
    RETURN QUERY SELECT row_eq(
        format($$
            SELECT journal.add_entries(ARRAY[
                ROW('2020-01-12', 35.00, 1, 'A'),
                ROW('2020-01-13', 35.00, 1, 'A'),
                ROW('2020-01-14', 35.00, 1, 'A'),
                ROW('2020-01-12', 30.00, 2, 'A'),
                ROW('2020-01-13', 30.00, 2, 'A'),
                ROW('2020-01-14', 20.00, 3, 'A')
            ]::journal.journal_type[],
            3)
        $$),
        ROW(6::BIGINT),
        'Adds 6 entries to the journal'
    );
END;
$testsuite$ LANGUAGE plpgsql;
