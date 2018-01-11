CREATE TABLE time_dim
(
  year         INTEGER NOT NULL,
  month        INTEGER NOT NULL,
  week         INTEGER NOT NULL,
  day_of_month INTEGER NOT NULL,
  hour_of_day  INTEGER NOT NULL,
  id           SERIAL  NOT NULL
    CONSTRAINT time_dim_id_pk
    PRIMARY KEY
);

CREATE UNIQUE INDEX time_dim_id_uindex
  ON time_dim (id);

