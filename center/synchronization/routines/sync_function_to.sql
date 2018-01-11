CREATE FUNCTION sync_function_to(schema_from TEXT, schema_to TEXT, function_name TEXT, connection_string TEXT)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  _tmp_query    TEXT;
  connections   TEXT ARRAY;
  function_code TEXT;
BEGIN
  RAISE NOTICE 'Sync schemas bases % -> % Function: %', schema_from, schema_to, function_name;

  -- function code
  _tmp_query := format('select get_function_code(%L,%L);',
                       schema_from,
                       function_name);
  RAISE NOTICE 'Function query: %', _tmp_query;
  EXECUTE _tmp_query
  INTO function_code;
  RAISE NOTICE 'Function code : %', function_code :: TEXT;
  EXECUTE format(
      'select replace(%L, %L, %L);',
      function_code,
      schema_from || '.' || function_name,
      schema_to || '.' || function_name
  )
  INTO function_code;

  RAISE NOTICE 'Function code : %', function_code :: TEXT;
  ---- connect
  EXECUTE 'SELECT dblink.dblink_get_connections();'
  INTO connections;
  IF connections @> ARRAY ['db2']
  THEN
    RAISE NOTICE 'At currently has db2 connection';
    EXECUTE format('SELECT dblink.dblink_disconnect(%L);', 'db2');
  END IF;

  --TO DO replace connection name to unique
  RAISE NOTICE 'connstring: %', format('select dblink.dblink_connect(%L, %L);', 'db2', connection_string);
  EXECUTE format('select dblink.dblink_connect(%L, %L);', 'db2', connection_string);

  _tmp_query := format('select dblink.dblink_exec(%L,%L,%s);',
                       'db2',
                       function_code,
                       'TRUE');
  EXECUTE _tmp_query;
  PERFORM dblink.dblink_disconnect('db2');

  RETURN 1;
END;
$$;

