CREATE FUNCTION get_or_create_time_dim(_date TIMESTAMP WITHOUT TIME ZONE)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  year         INTEGER;
  month        INTEGER;
  week         INTEGER;
  day_of_month INTEGER;
  hour_of_day  INTEGER;
  time_id      INTEGER DEFAULT NULL;
BEGIN
  RAISE NOTICE 'parse date: %', _date :: TEXT;
  EXECUTE format('select extract(YEAR FROM TIMESTAMP %L);', _date)
  INTO year;
  EXECUTE format('select extract(MONTH FROM TIMESTAMP %L);', _date)
  INTO month;
  EXECUTE format('select extract(WEEK FROM TIMESTAMP %L);', _date)
  INTO week;
  EXECUTE format('select extract(DAY FROM TIMESTAMP %L);', _date)
  INTO day_of_month;
  EXECUTE format('select extract(HOUR FROM TIMESTAMP %L);', _date)
  INTO hour_of_day;
  EXECUTE format('SELECT id FROM olap.time_dim' ||
                 ' WHERE year = %L ' ||
                 ' AND month = %L ' ||
                 ' AND week = %L ' ||
                 ' AND day_of_month = %L ' ||
                 ' AND hour_of_day=%L ;',
                 year, month, week, day_of_month, hour_of_day
  )
  INTO time_id;
  RAISE NOTICE 'time_dim founded: %', time_id :: TEXT;
  IF time_id NOTNULL
  THEN
    RETURN time_id;
  END IF;

  EXECUTE format('INSERT INTO olap.time_dim (year,month,week,day_of_month,hour_of_day)' ||
                 'VALUES (%L,%L,%L,%L,%L) RETURNING id', year, month, week, day_of_month, hour_of_day
  )
  INTO time_id;
  RAISE NOTICE 'time_dim id: %', time_id :: TEXT;
  RETURN time_id;
END;
$$;

