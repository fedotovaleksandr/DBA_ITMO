CREATE TABLE "order"
(
  id            INTEGER                   NOT NULL
    CONSTRAINT order_pkey
    PRIMARY KEY,
  customer_id   INTEGER                   NOT NULL,
  employee_id   INTEGER,
  date_payment  DATE,
  date_shipment DATE,
  date_update   DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete   DATE
);

