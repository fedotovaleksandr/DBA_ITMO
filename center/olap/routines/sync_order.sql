CREATE FUNCTION sync_order(schema_from TEXT, table_from TEXT, schema_to TEXT, table_to TEXT, last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  tmp_query     TEXT;
  tmp_table     TEXT;
  tmp_record    RECORD;
  updated_count INTEGER;
  time_id       INTEGER;
  tmp_values    TEXT ARRAY;
  colums_order  TEXT ARRAY DEFAULT ARRAY [
  'time_id',
  'order_id',
  'departament_id',
  'product_id',
  'category_id',
  'employee_id',
  'customer_id',
  'line_price',
  'discount',
  'quantity',
  'date_shipment'
  ];
BEGIN
  RAISE NOTICE 'sync_order';
  EXECUTE
  format('SELECT synchronization.create_tmp_table_based_on_date_update(%L,%L,%L);', schema_from, table_from,
         last_seconds)
  INTO tmp_table;
  tmp_query := format('SELECT o.date_payment,' ||
                      ' o.id AS order_id,' ||
                      'dep.id AS departament_id,' ||
                      ' p.id as product_id,' ||
                      ' c.id AS category_id,' ||
                      'o.employee_id,' ||
                      'o.customer_id,' ||
                      'od.line_price,' ||
                      'od.discount,' ||
                      'od.quantity,' ||
                      'o.date_shipment' ||
                      ' FROM %s.%s as o ' ||
                      ' LEFT JOIN %s.order_detail as od ON od.order_id = o.id ' ||
                      ' LEFT JOIN %s.product as p ON od.product_id = p.id ' ||
                      ' LEFT JOIN %s.category as c ON p.category_id = c.id ' ||
                      ' LEFT JOIN synchronization.departament as dep ON dep.start_id <= o.id AND dep.end_id >= o.id;',
                      schema_from,
                      tmp_table,
                      schema_from,
                      schema_from,
                      schema_from
  );
  RAISE NOTICE 'Order sync query: %', tmp_query;
  FOR tmp_record IN EXECUTE tmp_query LOOP
    --- get or create time dim
    time_id := olap.get_or_create_time_dim(tmp_record.date_payment);
    RAISE NOTICE 'time id: %', time_id;
    tmp_values := synchronization.extract_record_values_from_record_text(tmp_record :: TEXT);
    tmp_values [1] := format('%L', time_id);

    --- Update query
    tmp_query := format('UPDATE %s.%s SET (%s) = (%s) WHERE order_id = %L RETURNING 1;',
                        schema_to,
                        table_to,
                        array_to_string(colums_order, ','),
                        array_to_string(tmp_values, ','),
                        tmp_record.order_id
    );
    RAISE NOTICE 'Try update: %', tmp_query;
    -- first try to update
    EXECUTE tmp_query
    INTO updated_count;
    IF updated_count > 0
    THEN
      CONTINUE;
    END IF;
    --- Create query
    tmp_query := format('INSERT INTO %s.%s (%s) VALUES (%s);',
                        schema_to,
                        table_to,
                        array_to_string(colums_order, ','),
                        array_to_string(tmp_values, ',')
    );
    RAISE NOTICE 'Try create: %', tmp_query;
    -- first try to create
    EXECUTE tmp_query;
  END LOOP;

  RAISE NOTICE 'Drop TEMP Table: DROP TABLE %.%;', schema_from, tmp_table;
  EXECUTE format('DROP TABLE %s.%s;', schema_from, tmp_table);
  RETURN 1;
END;
$$;

