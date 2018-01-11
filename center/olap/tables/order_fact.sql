CREATE TABLE order_fact
(
  time_id        INTEGER          NOT NULL,
  order_id       INTEGER          NOT NULL,
  departament_id INTEGER          NOT NULL,
  product_id     INTEGER          NOT NULL,
  category_id    INTEGER          NOT NULL,
  employee_id    INTEGER          NOT NULL,
  line_price     DOUBLE PRECISION NOT NULL,
  discount       DOUBLE PRECISION NOT NULL,
  quantity       INTEGER          NOT NULL,
  date_shipment  TIMESTAMP,
  customer_id    INTEGER          NOT NULL
);

