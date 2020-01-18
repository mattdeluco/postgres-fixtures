CREATE OR REPLACE FUNCTION tests.test_pay_group()
RETURNS SETOF TEXT AS
$testsuite$
DECLARE
BEGIN
    -- Test creation
    RETURN QUERY SELECT row_eq(
        $$ SELECT pay_group.create_or_update('A', 35.00) $$,
        ROW(1::BIGINT),
        'Create one pay group'
    );

    RETURN QUERY SELECT results_eq(
        $$ SELECT * FROM pay_group.pay_group $$,
        $$ VALUES ('A', 35.00) $$,
        'Verify created pay groups'
    );

    -- Test "upsert"
    RETURN QUERY SELECT row_eq(
        $$ SELECT pay_group.create_or_update('A', 30.00) $$,
        ROW(1::BIGINT),
        'Update one pay group'
    );

    RETURN QUERY SELECT results_eq(
        $$ SELECT * FROM pay_group.pay_group $$,
        $$ VALUES ('A', 30.00) $$,
        'Verify updated pay groups'
    );
END;
$testsuite$ LANGUAGE plpgsql;
