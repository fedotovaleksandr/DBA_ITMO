CREATE VIEW current_year_employee_sell AS
  SELECT
    emd.pasport,
    max((emd.name) :: TEXT)              AS name,
    max((emd.surname) :: TEXT)           AS surname,
    max((depd.name) :: TEXT)             AS dep_name,
    sum(orf.quantity)                    AS quantity_summ,
    sum(orf.discount)                    AS total_discount,
    sum((orf.line_price - orf.discount)) AS total_sell
  FROM (((olap.order_fact orf
    LEFT JOIN olap.time_dim td ON ((td.id = orf.time_id)))
    LEFT JOIN olap.employee_dim emd ON ((emd.id = orf.employee_id)))
    LEFT JOIN olap.departament_dim depd ON ((depd.id = orf.departament_id)))
  WHERE ((td.year) :: DOUBLE PRECISION = date_part('year' :: TEXT, CURRENT_DATE))
  GROUP BY emd.pasport;

