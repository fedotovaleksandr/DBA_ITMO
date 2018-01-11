CREATE FUNCTION create_order(_schema TEXT, product_count INTEGER DEFAULT 2)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  i               INTEGER DEFAULT 0;
  order_id        TEXT;
  tmp_query       TEXT;
  item            RECORD;
  product_ids     TEXT ARRAY;
  customer_ids    TEXT ARRAY;
  employee_ids    TEXT ARRAY;
  product_price   FLOAT;
  line_price      FLOAT;
  product_id      TEXT;
  qauntity        INT;
  quantity_values INT ARRAY DEFAULT ARRAY [1, 2, 3, 4, 5];
  discount_values INT ARRAY DEFAULT ARRAY [11, 9, 15, 17, 19];
BEGIN
  FOR item IN EXECUTE format('SELECT id FROM %s.product;', _schema) LOOP
    product_ids := array_append(product_ids, item.id :: TEXT);
  END LOOP;
  FOR item IN EXECUTE format('SELECT id FROM %s.customer;', _schema) LOOP
    customer_ids := array_append(customer_ids, item.id :: TEXT);
  END LOOP;
  FOR item IN EXECUTE format('SELECT id FROM %s.employee;', _schema) LOOP
    employee_ids := array_append(employee_ids, item.id :: TEXT);
  END LOOP;
  tmp_query := format(
      'INSERT INTO %s.order (customer_id,employee_id,date_payment,date_shipment) VALUES (%L,%L,%L,%L) RETURNING id;',
      _schema,
      customer_ids [random() * (array_length(customer_ids, 1) - 1) + 1],
      employee_ids [random() * (array_length(employee_ids, 1) - 1) + 1],
      current_timestamp - (random() * 300 + 1 || ' day') :: INTERVAL,
      current_timestamp - (random() * 300 + 1 || ' day') :: INTERVAL
  );
  RAISE NOTICE 'new _order: %', tmp_query;
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS dblink;');
  EXECUTE format('CREATE EXTENSION IF NOT EXISTS dblink SCHEMA dblink');
  EXECUTE format('select id from dblink.dblink(%L, %L) as t1(id INT);',
                 'dbname=' || current_database(),
                 tmp_query
  )
  INTO order_id;
  PERFORM pg_sleep(1);

  RAISE NOTICE 'new _order id: %', order_id;
  WHILE (i < product_count) LOOP
    product_id := product_ids [random() * (array_length(product_ids, 1) - 1) + 1];
    EXECUTE format('SELECT price FROM %s.product', _schema)
    INTO product_price;
    qauntity := quantity_values [random() * (array_length(quantity_values, 1) - 1) + 1];
    line_price := product_price :: FLOAT * qauntity;
    tmp_query := format(
        'INSERT INTO %s.order_detail (line_price, quantity, discount, order_id, product_id) VALUES (%L,%L,%L,%L,%L);',
        _schema,
        line_price,
        qauntity,
        discount_values [random() * (array_length(discount_values, 1) - 1) + 1],
        order_id,
        product_id
    );
    RAISE NOTICE 'insert order_detail: %', tmp_query;
    EXECUTE tmp_query;
    i := i + 1;
  END LOOP;
  RETURN 1;
END;
$$;

