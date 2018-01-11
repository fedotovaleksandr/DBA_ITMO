CREATE FUNCTION sync_table_with_temp_to(schema_from       TEXT, table_from TEXT, schema_to TEXT, table_to TEXT,
                                        connection_string TEXT, last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  tmp_table TEXT;
  tmp_query TEXT;
BEGIN
  RAISE NOTICE 'sync_table_with_temp_to';
  EXECUTE
  format('SELECT synchronization.create_tmp_table_based_on_date_update(%L,%L,%L);', schema_from, table_from,
         last_seconds)
  INTO tmp_table;
  RAISE NOTICE 'Generated temp table: %', tmp_table;
  tmp_query := format('select synchronization.sync_table_to(%L, %L, %L, %L, %L);',
                      schema_from,
                      tmp_table,
                      schema_to,
                      table_to,
                      connection_string
  );
  EXECUTE tmp_query;
  RAISE NOTICE 'Drop TEMP Table: DROP TABLE %.%;', schema_from, tmp_table;
  EXECUTE format('DROP TABLE %s.%s;', schema_from, tmp_table);
  RETURN 1;
END;
$$;

