CREATE FUNCTION get_schema_create_tables(departament_name TEXT)
  RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  tables_query TEXT DEFAULT 'CREATE TABLE -schema-.customer
(
  id           INTEGER                    NOT NULL
    PRIMARY KEY,
  pasport      VARCHAR(12)               NOT NULL,
  name         VARCHAR(255)              NOT NULL,
  surname      VARCHAR(255)              NOT NULL,
  address       VARCHAR(511)              NOT NULL,
  zip_code     VARCHAR(20)               NOT NULL,
  country_code VARCHAR(3)                NOT NULL,
  date_update  DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete  DATE
);

CREATE TABLE -schema-."order"
(
  id            INTEGER                    NOT NULL
    PRIMARY KEY,
  customer_id   INTEGER                   NOT NULL,
  employee_id   INTEGER,
  date_payment  DATE,
  date_shipment DATE,
  date_update   DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete   DATE
);

CREATE TABLE -schema-.order_detail
(
  id          INTEGER                    NOT NULL
    PRIMARY KEY,
  line_price  DOUBLE PRECISION          NOT NULL,
  quantity    INTEGER                   NOT NULL,
  discount    DOUBLE PRECISION,
  order_id    INTEGER                   NOT NULL,
  product_id   INTEGER                   NOT NULL,
  date_update DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete DATE
);

CREATE TABLE -schema-.product
(
  id          INTEGER                              NOT NULL
    PRIMARY KEY,
  ean         VARCHAR(13)                         NOT NULL,
  name        VARCHAR(255)                        NOT NULL,
  description VARCHAR(255),
  price       DOUBLE PRECISION                    NOT NULL,
  views       INTEGER,
  category_id INTEGER                             NOT NULL,
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  date_delete TIMESTAMP
);

CREATE TABLE -schema-.employee
(
  id          INTEGER                    NOT NULL
    PRIMARY KEY,
  name        VARCHAR(255),
  surname     VARCHAR(255),
  pasport     VARCHAR(12)               NOT NULL,
  hire_date   DATE,
  date_update DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete DATE
);

CREATE TABLE -schema-.category
(
  id          INTEGER NOT NULL
    PRIMARY KEY,
  name        VARCHAR(255),
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);';
  _key         TEXT DEFAULT '-schema-';
BEGIN
  RAISE NOTICE 'Get Schema queries %', departament_name;

  RETURN replace(tables_query, _key, departament_name);
END;
$$;

