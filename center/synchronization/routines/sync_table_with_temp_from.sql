CREATE FUNCTION sync_table_with_temp_from(schema_from       TEXT, table_from TEXT, schema_to TEXT, table_to TEXT,
                                          connection_string TEXT, last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  tmp_table   TEXT;
  tmp_query   TEXT;
  connections TEXT ARRAY;
BEGIN
  RAISE NOTICE 'sync_table_with_temp_from';
  EXECUTE 'SELECT dblink.dblink_get_connections();'
  INTO connections;
  IF connections @> ARRAY ['temp_from']
  THEN
    RAISE NOTICE 'At currently has temp_from connection';
    EXECUTE format('SELECT dblink.dblink_disconnect(%L);', 'temp_from');
  END IF;

  --TO DO replace connection name to unique
  RAISE NOTICE 'connstring: %', format('select dblink.dblink_connect(%L, %L);', 'temp_from', connection_string);
  EXECUTE format('select dblink.dblink_connect(%L, %L);', 'temp_from', connection_string);

  tmp_query := format('select tmp_table from dblink.dblink(%L,%L,%s) as t1(tmp_table text);',
                      'temp_from',
                      format('SELECT %s.create_tmp_table_based_on_date_update(%L,%L,%L);',
                             schema_from,
                             schema_from,
                             table_from,
                             last_seconds
                      ),
                      'TRUE');
  RAISE NOTICE 'Create tmp table query: %', tmp_query;
  EXECUTE tmp_query
  INTO tmp_table;

  RAISE NOTICE 'Generated temp table: %', tmp_table;
  tmp_query := format('select synchronization.sync_table_from(%L, %L, %L, %L, %L);',
                      schema_from,
                      tmp_table,
                      schema_to,
                      table_to,
                      connection_string
  );
  EXECUTE tmp_query;

  tmp_query := format(
      'SELECT dblink.dblink_exec(%L,%L,%s);',
      'temp_from',
      format('DROP TABLE %s.%s;', schema_from, tmp_table),
      'TRUE'
  );
  RAISE NOTICE 'Drop TEMP Table: %', tmp_query;
  EXECUTE tmp_query;
  PERFORM dblink.dblink_disconnect('temp_from');
  RETURN 1;
END;
$$;

