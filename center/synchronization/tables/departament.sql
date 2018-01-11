CREATE TABLE departament
(
  id          SERIAL  NOT NULL
    CONSTRAINT departament_pkey
    PRIMARY KEY,
  host        VARCHAR(511),
  database    VARCHAR(255),
  date_update TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  name        VARCHAR(255),
  "user"      VARCHAR(255) DEFAULT 'postgres' :: CHARACTER VARYING,
  password    VARCHAR(255) DEFAULT 'postgres' :: CHARACTER VARYING,
  start_id    INTEGER NOT NULL,
  end_id      INTEGER
);