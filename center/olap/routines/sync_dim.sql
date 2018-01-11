CREATE FUNCTION sync_dim(schema_from  TEXT, table_from TEXT, schema_to TEXT, table_to TEXT, column_names TEXT [],
                         last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  tmp_table     TEXT;
  tmp_record    RECORD;
  updated_count INTEGER;
  tmp_query     TEXT;
BEGIN
  RAISE NOTICE 'sync_table_with_temp_to';
  EXECUTE
  format('SELECT olap.create_tmp_table_based_on_date_update(%L,%L,%L);', schema_from, table_from, last_seconds)
  INTO tmp_table;
  tmp_query := format('SELECT %s FROM %s.%s;', array_to_string(column_names, ','), schema_from, tmp_table);
  FOR tmp_record IN EXECUTE tmp_query LOOP
    --- Update query
    tmp_query := format('UPDATE %s.%s SET (%s) = (%s) WHERE id = %L RETURNING 1;',
                        schema_to,
                        table_to,
                        array_to_string(column_names, ','),
                        array_to_string(synchronization.extract_record_values_from_record_text(tmp_record :: TEXT),
                                        ','),
                        tmp_record.id
    );
    RAISE NOTICE 'Try update: %', tmp_query;
    -- first try to update
    EXECUTE tmp_query
    INTO updated_count;
    IF updated_count > 0
    THEN
      CONTINUE;
    END IF;
    --- Create query
    tmp_query := format('INSERT INTO %s.%s (%s) VALUES (%s);',
                        schema_to,
                        table_to,
                        array_to_string(column_names, ','),
                        array_to_string(synchronization.extract_record_values_from_record_text(tmp_record :: TEXT), ',')
    );
    RAISE NOTICE 'Try create: %', tmp_query;
    -- first try to create
    EXECUTE tmp_query;
  END LOOP;

  RAISE NOTICE 'Drop TEMP Table: DROP TABLE %.%;', schema_from, tmp_table;
  EXECUTE format('DROP TABLE %s.%s;', schema_from, tmp_table);
  RETURN 1;
END;
$$;

