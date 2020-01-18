CREATE DATABASE :db_name;
\c :db_name

\i pay_group/pay_group.sql
\i journal/journal.sql

DO $$
DECLARE
    new_search_path TEXT[];
    current_search_path TEXT[] := regexp_split_to_array(current_setting('search_path'), ', ?');
BEGIN
    IF array_length(current_search_path, 1) < 3 THEN
        EXECUTE format('ALTER DATABASE %I SET search_path="$user",public', current_database());
        RETURN;
    END IF;

    FOR i IN REVERSE array_length(current_search_path, 1)-2..1 LOOP
        new_search_path[array_length(current_search_path, 1)-i+1] := current_search_path[i];
    END LOOP;

    new_search_path := array_cat(new_search_path, ARRAY['"$user"', 'public']);

    EXECUTE format('SET search_path TO %s;', array_to_string(new_search_path, ','));
    EXECUTE format('ALTER DATABASE %I SET search_path=%s', current_database(), array_to_string(new_search_path, ','));
END;
$$;
