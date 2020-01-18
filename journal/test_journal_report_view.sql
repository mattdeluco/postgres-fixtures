CREATE OR REPLACE FUNCTION tests.test_journal_report_view()
RETURNS SETOF TEXT AS
$testsuite$
DECLARE
BEGIN
    INSERT INTO pay_group.pay_group VALUES
        ('A', 30.00), ('B', 25.00);

    PERFORM journal.add_entries(ARRAY[
        ROW('2020-01-12', 35.00, 1, 'A'),
        ROW('2020-01-13', 35.00, 1, 'A'),
        ROW('2020-01-14', 35.00, 1, 'A'),
        ROW('2020-01-12', 30.00, 2, 'A'),
        ROW('2020-01-13', 30.00, 2, 'A'),
        ROW('2020-01-14', 30.00, 2, 'B'),
        ROW('2020-01-14', 20.00, 3, 'A'),
        ROW('2020-01-17', 20.00, 3, 'B')
    ]::journal.journal_type[],
    3);

    RETURN QUERY SELECT results_eq(
        format($$
            SELECT * FROM journal.report;
        $$),
        $$ VALUES
            (1::BIGINT, '2020-01-01'::DATE, '2020-01-15'::DATE, 3150.00),
            (2::BIGINT, '2020-01-01'::DATE, '2020-01-15'::DATE, 2550.00),
            (3::BIGINT, '2020-01-01'::DATE, '2020-01-15'::DATE, 600.00),
            (3::BIGINT, '2020-01-16'::DATE, '2020-01-31'::DATE, 500.00)
        $$,
        'Test report view'
    );
END;
$testsuite$ LANGUAGE plpgsql;
