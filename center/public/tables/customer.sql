CREATE TABLE customer
(
  id           INTEGER                   NOT NULL
    CONSTRAINT customer_pkey
    PRIMARY KEY,
  pasport      VARCHAR(12)               NOT NULL,
  name         VARCHAR(255)              NOT NULL,
  surname      VARCHAR(255)              NOT NULL,
  address      VARCHAR(511)              NOT NULL,
  zip_code     VARCHAR(20)               NOT NULL,
  country_code VARCHAR(3)                NOT NULL,
  date_update  DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete  DATE
);

