CREATE OR REPLACE FUNCTION tests.test_journal_add_entries()
RETURNS SETOF TEXT AS
$testsuite$
DECLARE
BEGIN

    INSERT INTO pay_group.pay_group VALUES
        ('A', 30.00), ('B', 25.00);

    RETURN QUERY SELECT is(
        journal.add_entries('[
            ["12/1/2020", "35", "1", "A"],
            ["13/1/2020", "35.5", "1", "A"],
            ["14/1/2020", "35.00", "1", "A"],
            ["12/1/2020", "30.00", "2", "A"],
            ["13/1/2020", "30.00", "2", "A"],
            ["14/1/2020", "30.00", "2", "B"],
            ["14/1/2020", "20.00", "3", "A"],
            ["17/1/2020", "20.00", "3", "B"]
        ]'::JSON, 3),
        8::BIGINT,
        'Correct number of entries added from JSON'
    );

    RETURN QUERY SELECT results_eq(
        format($$
            SELECT * FROM journal.report;
        $$),
        $$ VALUES
            (1::BIGINT, '2020-01-01'::DATE, '2020-01-15'::DATE, 3165.00),
            (2::BIGINT, '2020-01-01'::DATE, '2020-01-15'::DATE, 2550.00),
            (3::BIGINT, '2020-01-01'::DATE, '2020-01-15'::DATE, 600.00),
            (3::BIGINT, '2020-01-16'::DATE, '2020-01-31'::DATE, 500.00)
        $$,
        'Test report view'
    );
END;
$testsuite$ LANGUAGE plpgsql;
