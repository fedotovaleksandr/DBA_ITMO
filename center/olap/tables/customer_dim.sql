CREATE TABLE customer_dim
(
  id           INTEGER      NOT NULL
    CONSTRAINT customer_dim_pkey
    PRIMARY KEY,
  pasport      VARCHAR(12)  NOT NULL,
  name         VARCHAR(255) NOT NULL,
  surname      VARCHAR(255) NOT NULL,
  address      VARCHAR(511) NOT NULL,
  zip_code     VARCHAR(20)  NOT NULL,
  country_code VARCHAR(3)   NOT NULL
);

