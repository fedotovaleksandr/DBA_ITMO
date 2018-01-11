CREATE FUNCTION load_init_data(_schema       TEXT, count_customer INTEGER DEFAULT 5, count_empoyee INTEGER DEFAULT 5,
                               count_product INTEGER DEFAULT 5)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  item                RECORD;
  i                   INTEGER DEFAULT 1;
  tmp_query           TEXT;
  pasport_values      TEXT ARRAY DEFAULT ARRAY ['4323 123465', '4323 173411', '4323 111465', '4323 444465', '4323 123777', '4323 129995', '4323 128765', '8723 123465'];
  name_values         TEXT ARRAY DEFAULT ARRAY ['Mike', 'James', 'Vasya', 'Petya', 'Michael', 'Ben', 'Bob', 'Alex'];
  surname_values      TEXT ARRAY DEFAULT ARRAY ['Brooke', 'Lorence', 'Satan', 'Lollypop', 'Klomb', 'Slider', 'Fixer'];
  address_values      TEXT ARRAY DEFAULT ARRAY ['1 street', 'last hope 2', 'Xavier street', 'Book house', 'Razor street', 'Bug street', 'FP street'];
  zip_values          TEXT ARRAY DEFAULT ARRAY ['122493', '367821', '456867', '2346781', '246924', '7642113', '187948'];
  counry_values       TEXT ARRAY DEFAULT ARRAY ['USA', 'RUS', 'MIT', 'GIT', 'PUT', 'GET', 'LOR', 'GOR'];
  ean_values          TEXT ARRAY DEFAULT ARRAY ['654243456', '345363456', '3456343468', '1212361246', '164628468146', '94857628435', '68364982346', '05486765742', '758697684', '8475646573', '9385849213'];
  product_name_values TEXT ARRAY DEFAULT ARRAY ['Eggs', 'Lays', 'Meat', 'Socks', 'Fox', 'Cat', 'Pants', 'Cheese', 'Books', 'Fish'];
  category_ids        TEXT ARRAY;
  price_values        TEXT ARRAY DEFAULT ARRAY ['423', '432', '654', '345', '12', '34', '786', '54', '56', '987'];
  views_values        TEXT ARRAY DEFAULT ARRAY ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];


BEGIN
  RAISE NOTICE 'Init data: %', _schema;
  --- INIT CUSTOMERS
  RAISE NOTICE 'INIT CUSTOMERS: %', _schema;
  WHILE (i < count_customer) LOOP
    tmp_query := format(
        'INSERT INTO %s.customer (pasport,name,surname,address,zip_code,country_code) VALUES (%L,%L,%L,%L,%L,%L);',
        _schema,
        pasport_values [random() * (array_length(pasport_values, 1) - 1) + 1],
        name_values [random() * (array_length(name_values, 1) - 1) + 1],
        surname_values [random() * (array_length(surname_values, 1) - 1) + 1],
        address_values [random() * (array_length(address_values, 1) - 1) + 1],
        zip_values [random() * (array_length(zip_values, 1) - 1) + 1],
        counry_values [random() * (array_length(counry_values, 1) - 1) + 1]
    );
    RAISE NOTICE 'insert query: %', tmp_query;
    EXECUTE tmp_query;
    i := i + 1;
  END LOOP;
  --- INIT EMPLOYEE
  RAISE NOTICE 'INIT EMPLOYEE: %', _schema;
  i := 0;
  WHILE (i < count_empoyee) LOOP
    tmp_query := format(
        'INSERT INTO %s.employee (name,surname,pasport,hire_date) VALUES (%L,%L,%L,%L);',
        _schema,
        name_values [random() * (array_length(name_values, 1) - 1) + 1],
        surname_values [random() * (array_length(surname_values, 1) - 1) + 1],
        pasport_values [random() * (array_length(pasport_values, 1) - 1) + 1],
        current_timestamp - (random() * 300 + 1 || ' day') :: INTERVAL
    );
    RAISE NOTICE 'insert query: %', tmp_query;
    EXECUTE tmp_query;
    i := i + 1;
  END LOOP;

  --- INIT PRODUCT
  RAISE NOTICE 'INIT PRODUCT: %', _schema;
  FOR item IN EXECUTE format('SELECT id FROM %s.category', _schema) LOOP
    category_ids := array_append(category_ids, item.id :: TEXT);
  END LOOP;
  i := 0;
  WHILE (i < count_product) LOOP
    tmp_query := format(
        'INSERT INTO %s.product (ean, name, category_id, price, views) VALUES (%L,%L,%L,%L,%L);',
        _schema,
        ean_values [random() * (array_length(ean_values, 1) - 1) + 1],
        product_name_values [random() * (array_length(product_name_values, 1) - 1) + 1],
        category_ids [random() * (array_length(category_ids, 1) - 1) + 1],
        price_values [random() * (array_length(price_values, 1) - 1) + 1],
        views_values [random() * (array_length(views_values, 1) - 1) + 1]
    );
    RAISE NOTICE 'insert query: %', tmp_query;
    EXECUTE tmp_query;
    i := i + 1;
  END LOOP;
  RETURN 1;

END;
$$;

