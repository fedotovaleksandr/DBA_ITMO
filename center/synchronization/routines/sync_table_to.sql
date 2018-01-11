CREATE FUNCTION sync_table_to(schema_from TEXT, table_from TEXT, schema_to TEXT, table_to TEXT, connection_string TEXT,
                              batch_size  INTEGER DEFAULT 100)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  full_table_from REGCLASS;
  full_table_to   TEXT;
  _row_count      INTEGER;
  current_row     INTEGER DEFAULT 0;
  ids             INT ARRAY;
  id              TEXT;
  _query          TEXT DEFAULT '';
  _tmp_query      TEXT;
  _tmp_array      TEXT ARRAY;
  create_ids      INT ARRAY;
  update_ids      INT ARRAY;
  update_item     RECORD;
  create_item     RECORD;
  column_names    TEXT ARRAY;
  connections     TEXT ARRAY;
BEGIN
  full_table_from := (schema_from || '.' || table_from) :: TEXT;
  full_table_to := (schema_to || '.' || table_to) :: TEXT;
  RAISE NOTICE 'Sync Data bases % -> % ...', full_table_from, full_table_to;
  EXECUTE format('SELECT count(*) FROM %s', full_table_from)
  INTO _row_count;
  RAISE NOTICE '% row_count', _row_count;
  IF _row_count < 1
  THEN
    RETURN 1;
  END IF;

  EXECUTE format('SELECT synchronization.get_table_columns(%L,%L);',
                 schema_from,
                 table_from
  )
  INTO column_names;
  RAISE NOTICE 'column names: %', array_to_string(column_names, ',');

  EXECUTE 'SELECT dblink.dblink_get_connections();'
  INTO connections;
  IF connections @> ARRAY ['table_to']
  THEN
    RAISE NOTICE 'At currently has table_to connection';
    EXECUTE format('SELECT dblink.dblink_disconnect(%L);', 'table_to');
  END IF;
  --TO DO replace connection name
  RAISE NOTICE 'connstring: %', format('select dblink.dblink_connect(%L, %L);', 'table_to', connection_string);
  EXECUTE format('select dblink.dblink_connect(%L, %L);', 'table_to', connection_string);
  WHILE current_row <= _row_count LOOP
    -- get all ids
    EXECUTE format('SELECT array_agg(id) FROM %s;', full_table_from)
    INTO ids;
    RAISE NOTICE 'ids: %', array_to_string(ids, ',');
    -- fetch ids for update
    _tmp_query := format('select array_agg(id) from dblink.dblink(%L,%L,%s) as t1(id int);',
                         'table_to',
                         format(
                             'SELECT id FROM %s WHERE id = ANY (ARRAY[%s]);',
                             full_table_to,
                             array_to_string(ids, ',')
                         ),
                         'TRUE');
    RAISE NOTICE 'fetch ids for update: %', _tmp_query;
    EXECUTE _tmp_query
    INTO update_ids;
    RAISE NOTICE 'update_ids: %', array_to_string(update_ids, ',');
    -- set new items ids
    IF array_length(update_ids, 1) > 0
    THEN
      FOREACH id IN ARRAY ids LOOP
        IF NOT update_ids @> ARRAY [id :: INT]
        THEN
          create_ids := array_append(create_ids, id :: INT);
        END IF;
      END LOOP;
    ELSE
      create_ids := ids;
    END IF;
    RAISE NOTICE 'create_ids: %', array_to_string(create_ids, ',');
    -- create Items
    _tmp_query := format(
        'SELECT * FROM %s WHERE id = ANY (ARRAY[%s]);',
        full_table_from,
        array_to_string(create_ids, ',')
    );

    --- create Items
    IF array_length(create_ids, 1) > 0
    THEN
      RAISE NOTICE 'items for create: %', _tmp_query;
      FOR create_item IN EXECUTE _tmp_query LOOP
        EXECUTE format('select synchronization.extract_record_values_from_record_text(%L)', create_item :: TEXT)
        INTO _tmp_array;
        _tmp_query := format(
            'INSERT INTO %s (%s) VALUES (%s);',
            full_table_to, array_to_string(column_names, ','),
            array_to_string(_tmp_array, ',')
        );
        RAISE NOTICE '_tmp_query create: %', _tmp_query;
        _query := _query || _tmp_query;
      END LOOP;
    END IF;

    ---- update Items
    IF array_length(update_ids, 1) > 0
    THEN
      FOR update_item IN EXECUTE format(
          'SELECT * FROM %s WHERE id = ANY (ARRAY[%s]);',
          full_table_from,
          array_to_string(update_ids, ',')
      ) LOOP
        EXECUTE format('select synchronization.extract_record_values_from_record_text(%L)', update_item :: TEXT)
        INTO _tmp_array;
        _tmp_query := format(
            'UPDATE %s SET (%s) = (%s) WHERE id = %s;',
            full_table_to,
            array_to_string(column_names, ','),
            array_to_string(_tmp_array, ','),
            _tmp_array [1]
        );
        RAISE NOTICE '_tmp_query update: %', _tmp_query;
        _query := _query || _tmp_query;
      END LOOP;
    END IF;

    _tmp_query := format(
        'SELECT dblink.dblink_exec(%L,%L,%s);',
        'table_to',
        _query,
        'TRUE'
    );
    RAISE NOTICE 'query: %', _tmp_query;
    IF length(_query) > 0
    THEN
      EXECUTE _tmp_query;
    END IF;
    _query := '';
    current_row := current_row + batch_size;
  END LOOP;

  PERFORM dblink.dblink_disconnect('table_to');
  RETURN 1;
END;
$$;

