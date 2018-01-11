CREATE TABLE category
(
  id          SERIAL NOT NULL
    CONSTRAINT category_pkey
    PRIMARY KEY,
  name        VARCHAR(255),
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

