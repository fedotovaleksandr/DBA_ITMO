CREATE FUNCTION get_table_column_types(_schema TEXT, _table_name TEXT)
  RETURNS TEXT []
LANGUAGE plpgsql
AS $$
DECLARE result TEXT ARRAY;
BEGIN
  EXECUTE format('select array(select
case
    when domain_name is not null then domain_name
    when data_type=''character varying'' THEN ''varchar(''||character_maximum_length||'')''
    when data_type=''numeric'' THEN ''numeric(''||numeric_precision||'',''||numeric_scale||'')''
    else data_type
end as arraytype
from information_schema.columns
  WHERE table_schema = %L
 AND table_name   = %L);', _schema, _table_name)
  INTO result;
  RETURN result;
END;
$$;

