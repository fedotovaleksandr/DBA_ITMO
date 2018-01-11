CREATE FUNCTION sync_from_departaments(last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  dep           RECORD;
  conn_string   TEXT;
  tmp_query     TEXT;
  target_schema TEXT DEFAULT 'public';
  table_names   TEXT ARRAY DEFAULT ARRAY ['customer', 'employee', 'order', 'order_detail', 'product'];
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
      tmp_query := format('select synchronization.sync_table_with_temp_from(%L, %L, %L, %L, %L, %L);',
                          dep.name,
                          _table_name,
                          target_schema,
                          _table_name,
                          conn_string,
                          last_seconds
      );
      EXECUTE tmp_query;
    END LOOP;
    tmp_query := format('UPDATE synchronization.departament SET date_update = %L WHERE id = %L;',
                        current_timestamp,
                        dep.id);
    RAISE NOTICE 'Update dep date: %', tmp_query;
    EXECUTE tmp_query;
  END LOOP;
  RETURN 1;
END;
$$;

