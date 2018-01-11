CREATE FUNCTION sync_functions_to_departaments()
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  dep         RECORD;
  connections TEXT ARRAY;
  conn_string TEXT;
  tmp_query   TEXT;
  func_code   TEXT;
  func_schema TEXT DEFAULT 'synchronization';
  func_name   TEXT;
  _functions  TEXT ARRAY DEFAULT ARRAY [
  'create_order',
  'load_init_data',
  'create_tmp_table_based_on_date_update',
  'get_table_column_types',
  'get_table_columns'
  ];
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
    RAISE NOTICE 'sync_table_with_sync_func';
    EXECUTE 'SELECT dblink.dblink_get_connections();'
    INTO connections;
    IF connections @> ARRAY ['sync_func']
    THEN
      RAISE NOTICE 'At currently has sync_func connection';
      EXECUTE format('SELECT dblink.dblink_disconnect(%L);', 'sync_func');
    END IF;

    --TO DO replace connection name to unique
    RAISE NOTICE 'connstring: %', format('select dblink_connect(%L, %L);', 'sync_func', conn_string);
    EXECUTE format('select dblink.dblink_connect(%L, %L);', 'sync_func', conn_string);


    FOREACH func_name IN ARRAY _functions LOOP
      EXECUTE format('SELECT synchronization.get_function_code(%L,%L)',
                     func_schema,
                     func_name
      )
      INTO func_code;
      tmp_query := format(
          'SELECT dblink.dblink_exec(%L,%L,%s);',
          'sync_func',
          replace(func_code, func_schema || '.' || func_name, dep.name || '.' || func_name),
          'TRUE'
      );
      RAISE NOTICE 'Update: % ', dep.name || '.' || func_name;
      EXECUTE tmp_query;

    END LOOP;
    PERFORM dblink.dblink_disconnect('sync_func');
  END LOOP;
  RETURN 1;
END;
$$;

