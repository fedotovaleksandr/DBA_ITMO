CREATE FUNCTION sync_all(last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE format('SELECT synchronization.sync_to_departaments(%L);', last_seconds);
  EXECUTE format('SELECT synchronization.sync_from_departaments(%L);', last_seconds);
  EXECUTE format('SELECT olap.sync_olap(%L);', last_seconds);
  RETURN 1;
END;
$$;

