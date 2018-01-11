CREATE FUNCTION get_schema_create_sequences(departament_name TEXT, tables TEXT [], _start INTEGER, _end INTEGER)
  RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  sequence_query TEXT DEFAULT 'create SEQUENCE -schema-.-table-_id_seq
--- custom start value
  start -start-
  maxvalue -end-
  no cycle
  increment 1;
ALTER TABLE -schema-.-table- ADD CONSTRAINT check_id check (id >= -start- and id <= -end-);
ALTER TABLE -schema-.-table- ALTER COLUMN id SET DEFAULT nextval(''-schema-.-table-_id_seq'');
ALTER SEQUENCE -schema-.-table-_id_seq OWNED BY -schema-.-table-.id;';
  schema_key     TEXT DEFAULT '-schema-';
  table_key      TEXT DEFAULT '-table-';
  start_key      TEXT DEFAULT '-start-';
  end_key        TEXT DEFAULT '-end-';
  tmp_result     TEXT;
  result         TEXT DEFAULT '';
  table_name     TEXT;
BEGIN
  RAISE NOTICE 'Build sequences query: %', departament_name;
  FOREACH table_name IN ARRAY tables LOOP
    tmp_result := sequence_query;
    tmp_result := replace(tmp_result, schema_key, departament_name);
    tmp_result := replace(tmp_result, table_key, table_name);
    tmp_result := replace(tmp_result, start_key, _start :: TEXT);
    tmp_result := replace(tmp_result, end_key, _end :: TEXT);
    result := result || tmp_result;
  END LOOP;

  RETURN result;
END;
$$;

