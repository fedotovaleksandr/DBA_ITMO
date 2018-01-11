CREATE TABLE order_detail
(
  id          INTEGER                   NOT NULL
    CONSTRAINT order_detail_pkey
    PRIMARY KEY,
  line_price  DOUBLE PRECISION          NOT NULL,
  quantity    INTEGER                   NOT NULL,
  discount    DOUBLE PRECISION,
  order_id    INTEGER                   NOT NULL,
  product_id  INTEGER                   NOT NULL,
  date_update DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete DATE
);

