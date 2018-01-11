CREATE FUNCTION sync_olap(last_seconds INTEGER)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  PERFORM olap.sync_dim('public', 'category', 'olap', 'category_dim',
                        ARRAY ['id', 'name'],
                        last_seconds
  );
  PERFORM olap.sync_dim('public', 'customer', 'olap', 'customer_dim',
                        ARRAY ['id', 'pasport', 'name', 'surname', 'address', 'zip_code', 'country_code'],
                        last_seconds
  );
  PERFORM olap.sync_dim('synchronization', 'departament', 'olap', 'departament_dim',
                        ARRAY ['id', 'name'],
                        last_seconds
  );
  PERFORM olap.sync_dim('public', 'employee', 'olap', 'employee_dim',
                        ARRAY ['id', 'name', 'surname', 'pasport', 'hire_date'],
                        last_seconds
  );
  PERFORM olap.sync_dim('public', 'product', 'olap', 'product_dim',
                        ARRAY ['id', 'ean', 'name', 'description', 'price', 'views'],
                        last_seconds
  );
  PERFORM olap.sync_order('public', 'order', 'olap', 'order_fact', last_seconds);
  RETURN 1;
END;
$$;

