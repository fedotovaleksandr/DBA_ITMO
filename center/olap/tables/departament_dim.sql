CREATE TABLE departament_dim
(
  id          INTEGER                             NOT NULL
    CONSTRAINT departament_pkey
    PRIMARY KEY,
  date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  name        VARCHAR(255)
);

