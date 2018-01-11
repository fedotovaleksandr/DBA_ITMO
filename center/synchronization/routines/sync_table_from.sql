CREATE FUNCTION sync_table_from(schema_from       TEXT, table_from TEXT, schema_to TEXT, table_to TEXT,
                                connection_string TEXT, batch_size INTEGER DEFAULT 100)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  full_table_from TEXT;
  full_table_to   REGCLASS;
  _row_count      INTEGER;
  current_row     INTEGER DEFAULT 0;
  tmp_query       TEXT;
  as_query_types  TEXT ARRAY;
  iterator        INTEGER;
  item            RECORD;
  column_names    TEXT ARRAY;
  column_name     TEXT;
  column_types    TEXT ARRAY;
  connections     TEXT ARRAY;
  updated_count   INTEGER DEFAULT 0;
BEGIN
  full_table_from := schema_from || '.' || table_from;
  full_table_to := schema_to || '.' || table_to;
  RAISE NOTICE 'Sync Tables % -> % ...', full_table_from, full_table_to;

  EXECUTE 'SELECT dblink.dblink_get_connections();'
  INTO connections;
  IF connections @> ARRAY ['table_from']
  THEN
    RAISE NOTICE 'At currently has table_from connection';
    EXECUTE format('SELECT dblink.dblink_disconnect(%L);', 'table_from');
  END IF;

  --TO DO replace connection name to unique
  RAISE NOTICE 'connstring: %', format('select dblink.dblink_connect(%L, %L);', 'table_from', connection_string);
  EXECUTE format('select dblink.dblink_connect(%L, %L);', 'table_from', connection_string);
  -- count of from table
  tmp_query := format('select count from dblink.dblink(%L,%L,%s) as t1(count int);',
                      'table_from',
                      format(
                          'SELECT count(*) FROM %s;',
                          full_table_from
                      ),
                      'TRUE');
  RAISE NOTICE 'Count query: %', tmp_query;
  EXECUTE tmp_query
  INTO _row_count;
  RAISE NOTICE 'Count : %', _row_count;
  -- get types
  tmp_query := format('select types from dblink.dblink(%L,%L,%s) as t1(types text[]);',
                      'table_from',
                      format(
                          'SELECT %s.get_table_column_types(%L,%L);',
                          schema_from,
                          schema_from,
                          table_from
                      ),
                      'TRUE');
  RAISE NOTICE 'Get Types query: %', tmp_query;
  EXECUTE tmp_query
  INTO column_types;
  RAISE NOTICE 'Types : %', array_to_string(column_types, ',');
  --- get column names
  tmp_query := format('select names from dblink.dblink(%L,%L,%s) as t1(names text[]);',
                      'table_from',
                      format(
                          'SELECT %s.get_table_columns(%L,%L);',
                          schema_from,
                          schema_from,
                          table_from
                      ),
                      'TRUE');
  RAISE NOTICE 'Names query: %', tmp_query;
  EXECUTE tmp_query
  INTO column_names;
  RAISE NOTICE 'Names : %', array_to_string(column_names, ',');

  iterator := 1;
  FOREACH column_name IN ARRAY column_names LOOP
    as_query_types := array_append(as_query_types, format('%s %s', column_name, column_types [iterator]));
    iterator := iterator + 1;
  END LOOP;


  WHILE current_row <= _row_count LOOP
    --- get records
    tmp_query := format('select * from dblink.dblink(%L,%L,%s) as t1(%s);',
                        'table_from',
                        format(
                            'SELECT * FROM %s.%s;',
                            schema_from,
                            table_from
                        ),
                        'TRUE',
                        array_to_string(as_query_types, ',')
    );
    RAISE NOTICE 'Get records query: %', tmp_query;
    FOR item IN EXECUTE tmp_query LOOP
      --- Update query
      tmp_query := format('UPDATE %s.%s SET (%s) = (%s) WHERE id = %L RETURNING 1;',
                          schema_to,
                          table_to,
                          array_to_string(column_names, ','),
                          array_to_string(synchronization.extract_record_values_from_record_text(item :: TEXT), ','),
                          item.id
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
                          array_to_string(synchronization.extract_record_values_from_record_text(item :: TEXT), ',')
      );
      RAISE NOTICE 'Try create: %', tmp_query;
      -- first try to create
      EXECUTE tmp_query;
    END LOOP;
    current_row := current_row + batch_size;
  END LOOP;
  PERFORM dblink.dblink_disconnect('table_from');
  RETURN 1;
END;
$$;

