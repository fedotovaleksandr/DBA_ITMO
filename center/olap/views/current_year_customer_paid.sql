CREATE VIEW current_year_customer_paid AS
  SELECT
    cd.pasport,
    max((cd.name) :: TEXT)               AS name,
    max((cd.surname) :: TEXT)            AS surname,
    max((cd.address) :: TEXT)            AS address,
    sum(orf.quantity)                    AS quantity_summ,
    sum((orf.line_price - orf.discount)) AS total_paid
  FROM ((olap.order_fact orf
    LEFT JOIN olap.time_dim td ON ((td.id = orf.time_id)))
    LEFT JOIN olap.customer_dim cd ON ((cd.id = orf.customer_id)))
  WHERE ((td.year) :: DOUBLE PRECISION = date_part('year' :: TEXT, CURRENT_DATE))
  GROUP BY cd.pasport;

