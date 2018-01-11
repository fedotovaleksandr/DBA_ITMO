CREATE FUNCTION sync_to_departaments(last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  dep           RECORD;
  conn_string   TEXT;
  tmp_query     TEXT;
  target_schema TEXT DEFAULT 'public';
  table_names   TEXT ARRAY DEFAULT ARRAY ['category'];
  _table_name   TEXT;
BEGIN
  FOR dep IN SELECT *
             FROM synchronization.departament LOOP
    conn_string := format(
        'dbname=%s port=5432 host=%s user=%s password=%s',
        dep.database,
        dep.host,
        dep.user,
        dep.password
    );
    FOREACH _table_name IN ARRAY table_names LOOP
      tmp_query := format('select synchronization.sync_table_with_temp_to(%L, %L, %L, %L, %L, %L);',
                          target_schema,
                          _table_name,
                          dep.name,
                          _table_name,
                          conn_string,
                          last_seconds
      );
      EXECUTE tmp_query;
    END LOOP;
  END LOOP;
  RETURN 1;
END;
$$;

