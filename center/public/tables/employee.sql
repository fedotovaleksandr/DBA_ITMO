CREATE TABLE employee
(
  id          INTEGER                   NOT NULL
    CONSTRAINT employee_pkey
    PRIMARY KEY,
  name        VARCHAR(255),
  surname     VARCHAR(255),
  pasport     VARCHAR(12)               NOT NULL,
  hire_date   DATE,
  date_update DATE DEFAULT CURRENT_DATE NOT NULL,
  date_delete DATE
);

