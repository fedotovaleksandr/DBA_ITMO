CREATE FUNCTION extract_record_values_from_record_text(_record TEXT)
  RETURNS TEXT []
LANGUAGE plpgsql
AS $$
DECLARE
  _tmp_array TEXT ARRAY;
  _tmp_val   TEXT;
BEGIN
  RAISE NOTICE 'record: %', _record;
  FOREACH _tmp_val IN ARRAY regexp_split_to_array(right(left(_record, -1), -1), E',') LOOP
    IF length(_tmp_val) > 0
    THEN
      _tmp_array := array_append(_tmp_array, format('%L', replace(_tmp_val, '"', '')));
    ELSE
      _tmp_array := array_append(_tmp_array, 'NULL');
    END IF;
  END LOOP;
  RAISE NOTICE 'record_values: %', array_to_string(_tmp_array, ',');
  RETURN _tmp_array;
END;
$$;

