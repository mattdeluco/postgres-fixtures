CREATE OR REPLACE FUNCTION tests.test_journal_date_range()
RETURNS SETOF TEXT AS
$testsuite$
DECLARE
BEGIN

    RETURN QUERY SELECT is(
        journal.date_start('2020-01-15'::DATE),
        '2020-01-01'::DATE,
        'Test date_low() <= 15'
    );

    RETURN QUERY SELECT is(
        journal.date_start('2020-01-16'::DATE),
        '2020-01-16'::DATE,
        'Test date_low() > 15'
    );

    RETURN QUERY SELECT is(
        journal.date_end('2020-01-15'::DATE),
        '2020-01-15'::DATE,
        'Test date_high() <= 15'
    );

    RETURN QUERY SELECT is(
        journal.date_end('2020-01-16'::DATE),
        '2020-01-31'::DATE,
        'Test date_high() > 15'
    );

END;
$testsuite$ LANGUAGE plpgsql;
