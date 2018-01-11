CREATE TABLE product_dim
(
  id          INTEGER          NOT NULL
    CONSTRAINT product_pkey
    PRIMARY KEY,
  ean         VARCHAR(13)      NOT NULL,
  name        VARCHAR(255)     NOT NULL,
  description VARCHAR(255),
  price       DOUBLE PRECISION NOT NULL,
  views       INTEGER
);

