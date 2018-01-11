CREATE FUNCTION get_table_columns(_schema TEXT, _table_name TEXT)
  RETURNS TEXT []
LANGUAGE plpgsql
AS $$
DECLARE result TEXT ARRAY;
BEGIN
  EXECUTE format('SELECT  array_agg(column_name::text)
FROM information_schema.columns
WHERE table_schema = %L
  AND table_name   = %L', _schema, _table_name)
  INTO result;
  RETURN result;
END;
$$;

