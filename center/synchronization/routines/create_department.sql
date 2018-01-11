CREATE FUNCTION create_department(departament_name TEXT, host TEXT DEFAULT 'departaments' :: TEXT,
                                  dbname           TEXT DEFAULT 'departament1' :: TEXT,
                                  password         TEXT DEFAULT 'postgres' :: TEXT,
                                  _user            TEXT DEFAULT 'postgres' :: TEXT)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  _range      INTEGER DEFAULT 1000000;
  last_dep    RECORD;
  end_id      INTEGER DEFAULT 0;
  lat_dep_id  INTEGER DEFAULT 0;
  conn_string TEXT;
  tmp_query   TEXT;
  connections TEXT ARRAY;
BEGIN
  RAISE NOTICE 'Create Department %', departament_name;
  conn_string := format(
      'dbname=%s port=5432 host=%s user=%s password=%s',
      dbname,
      host,
      _user,
      password
  );
  EXECUTE 'SELECT dblink.dblink_get_connections();'
  INTO connections;
  IF connections @> ARRAY ['create_dep']
  THEN
    RAISE NOTICE 'At currently has db2 connection';
    EXECUTE format('SELECT dblink.dblink_disconnect(%L);', 'create_dep');
  END IF;
  --TO DO replace connection name
  RAISE NOTICE 'connstring: %', format('select dblink.dblink_connect(%L, %L);', 'create_dep', conn_string);
  EXECUTE format('select dblink.dblink_connect(%L, %L);', 'create_dep', conn_string);
  tmp_query := format(
      'SELECT dblink.dblink_exec(%L,%L,%s);',
      'create_dep',
      format('CREATE SCHEMA %s;', departament_name),
      'TRUE'
  );
  RAISE NOTICE 'Create Schema query %', tmp_query;
  EXECUTE tmp_query;
  tmp_query := format(
      'SELECT dblink.dblink_exec(%L,%L,%s);',
      'create_dep',
      synchronization.get_schema_create_tables(departament_name),
      'TRUE'
  );
  EXECUTE tmp_query;
  tmp_query := format(
      'SELECT dblink.dblink_exec(%L,%L,%s);',
      'create_dep',
      synchronization.get_schema_create_relations(departament_name),
      'TRUE'
  );
  EXECUTE tmp_query;
  EXECUTE format('SELECT end_id FROM synchronization.departament
  ORDER BY end_id DESC
  LIMIT 1;')
  INTO lat_dep_id;
  IF lat_dep_id > 0
  THEN
    end_id := lat_dep_id;
  END IF;
  RAISE NOTICE 'NEXT range % - %', end_id + 1, end_id + _range;
  tmp_query := format(
      'SELECT dblink.dblink_exec(%L,%L,%s);',
      'create_dep',
      synchronization.get_schema_create_sequences(
          departament_name,
          ARRAY ['order', 'product', 'customer', 'order_detail', 'employee'],
          end_id + 1,
          end_id + _range
      ),
      'TRUE'
  );
  EXECUTE tmp_query;
  tmp_query := format(
      'INSERT INTO synchronization.departament (host,database,name,"user",password,start_id,end_id)' ||
      ' VALUES (%L,%L,%L,%L,%L,%L,%L);',
      host,
      dbname,
      departament_name,
      _user,
      password,
      end_id + 1,
      end_id + _range
  );
  RAISE NOTICE 'ADD new departament % ', tmp_query;
  EXECUTE tmp_query;

  RETURN 1;
END;
$$;

