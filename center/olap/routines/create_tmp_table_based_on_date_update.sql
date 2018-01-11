CREATE FUNCTION create_tmp_table_based_on_date_update(_schema TEXT, _table TEXT, lastseconds INTEGER)
  RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  uniq_table_name TEXT;
  _query          TEXT;
  result_date     TIMESTAMP;
BEGIN
  --   better solution use uuid-ossp module;
  uniq_table_name := '_' || md5(
      concat(random() :: TEXT, random() :: TEXT, random() :: TEXT, random() :: TEXT, random() :: TEXT)
  );
  result_date := current_timestamp - lastseconds * ('1 second' :: INTERVAL);
  _query := format('CREATE TABLE %I.%I AS SELECT * FROM %I.%I WHERE date_update >= %L;', _schema, uniq_table_name,
                   _schema, _table,
                   result_date);
  RAISE NOTICE 'Create temp table : % ;', _query;
  EXECUTE _query;


  RETURN uniq_table_name;
END;
$$;

