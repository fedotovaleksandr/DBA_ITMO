CREATE FUNCTION get_function_code(_schema TEXT, _func_name TEXT)
  RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE result TEXT;
BEGIN
  EXECUTE format('SELECT
      pg_get_functiondef(p.oid) as definition
  FROM pg_proc p
  JOIN pg_type t
    ON p.prorettype = t.oid
  LEFT OUTER
  JOIN pg_description d
    ON p.oid = d.objoid
  LEFT OUTER
  JOIN pg_namespace n
    ON n.oid = p.pronamespace
 WHERE n.nspname~%L
   AND proname~%L;', _schema, _func_name)
  INTO result;
  result := replace(result, 'CREATE FUNCTION', 'CREATE OR REPLACE FUNCTION');
  RETURN result;
END;
$$;

