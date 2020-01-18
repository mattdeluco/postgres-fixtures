# Postgres Fixtures

This project defines two fixtures, for loading and testing PostgreSQL
databases. I built these fixtures to facilitate rapid and iterative
database development for my personal projects.

The fixtures are documented below, testing is accomplished using
[pgTAP](https://pgxn.org/dist/pgtap/).

## Fixtures

### Database Fixture

As SQL files are added to the project, they can be included in the
database fixture `database.sql` near the top of the file - for example,
`\i journal/journal.sql`.

Database files may optionally define a schema that is to be set at the
beggining of the `search_path` variable. After the database fixture has
loaded all SQL files, it then reorders `search_path` such that schemas
are in the order their files were loaded.

For example, in this project `journal` depends on `pay_group` so `pay_group`
is loaded first. After `pay_group` is loaded `search_path` is set to
`pay_group, "$user", public`. `journal` is then loaded, setting `search_path`
to `journal, pay_group, "$user", public`. Finally, the database fixture
reverses the order to `pay_group, journal, "$user", public`.

### Test Fixture

[pgTAP](https://pgxn.org/dist/pgtap/) is a fantastic tool for
rapid iteration during database development.

This "test fixture" allows one to quickly execute `\i test.sql`
in a `psql` session to quickly test well formed SQL in the
creation of a database, and to test using pgTAP functions any
desired assertions (regarding schemas, tables, permissions, or
function execution.)

At its most basic, the test fixture can be used just to verify
the SQL for creating schemas, tables, etc. I personally find
this useful because I've yet to find an IDE I like for developing
a PostgreSQL database and PL/pgSQL (the latter, specifically.)

As test SQL files are added, they may be included in the test fixture
`test.sql` in the body of the anonymous `DO` function - for example,
`\i journal/test_journal.sql`.

## Installation

The following instructions pertain to a Mac running macOS 10.15.2
(Catalina) with the latest Xcode and Command Line Tools installed.

### PostgreSQL

- Download [Postgres.app with PostgreSQL 12](https://postgresapp.com/downloads.html)
  - Open the dmg file and copy Postgres.app to /Applications
  - Run Postgres.app from /Applications
  - Create and run a Postgres 12 instance at port 5432 (default)
  - In any new terminal session, update your PATH
    - Or update your shell rc files
  ```
  $ export PATH=/Applications/Postgres.app/Contents/Versions/12/bin:$PATH
  ```

### pgTAP

- Download [pgTAP](https://pgxn.org/dist/pgtap/)
  - Choose release `pgTAP 1.1.0 - 2019-11-25`, click download (top right)
  - Open a terminal and run the following commands
  ```
  $ cd <path to downloads>
  $ unzip pgtap-1.1.0.zip && cd pgtap-1.1.0
  $ make && make install
  ```

### Database

An example of these instructions can be found below.

- In the project root directory run `psql`
- To run the test fixture, execute `\i test.sql`
  - This can be run at any time
  - It creates a randomly named database and loads the DB from scratch
- To load the "database fixture"
  - Set a database name variable `\set db_name my_db_name`
  - Load the fixture `\i database.sql`
  - If there are no problems with the SQL, the database is now fully
    loaded and ready to use

```
$ cd <path to project>
$ psql
Timing is on.
psql (12.1)
Type "help" for help.

mdeluco=# \i test.sql
         set_config
----------------------------
 pay_group, "$user", public
(1 row)

             set_config
-------------------------------------
 journal, pay_group, "$user", public
(1 row)

pgtap, tests, pay_group, journal, "$user", public
psql:test.sql:31: NOTICE:  SEARCH PATH: pgtap, tests, pay_group, journal, "$user", public
    # Subtest: tests.test_journal()
    ok 1 - Throws on duplicate report id
    ok 2 - Does not throw on unique report id
    ok 3 - Throws on duplicate report id
    ok 4 - Report id not recorded after failure
    ok 5 - Adds 6 entries to the journal
    1..5
ok 1 - tests.test_journal
    # Subtest: tests.test_journal_add_entries()
    ok 1 - Correct number of entries added from JSON
    ok 2 - Test report view
    1..2
ok 2 - tests.test_journal_add_entries
    # Subtest: tests.test_journal_date_range()
    ok 1 - Test date_low() <= 15
    ok 2 - Test date_low() > 15
    ok 3 - Test date_high() <= 15
    ok 4 - Test date_high() > 15
    1..4
ok 3 - tests.test_journal_date_range
    # Subtest: tests.test_journal_report_view()
    ok 1 - Test report view
    1..1
ok 4 - tests.test_journal_report_view
    # Subtest: tests.test_pay_group()
    ok 1 - Create one pay group
    ok 2 - Verify created pay groups
    ok 3 - Update one pay group
    ok 4 - Verify updated pay groups
    1..4
ok 5 - tests.test_pay_group
1..5
Timing is on.
template1=#
template1=# \set db_name my_db_name
template1=# \i database.sql
my_db_name=#
```
