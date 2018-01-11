CREATE VIEW current_year_products AS
  SELECT
    pd.ean,
    pd.name AS name_in_dep,
    orf.quantity,
    depd.name
  FROM (((olap.order_fact orf
    LEFT JOIN olap.time_dim td ON ((td.id = orf.time_id)))
    LEFT JOIN olap.product_dim pd ON ((pd.id = orf.product_id)))
    LEFT JOIN olap.departament_dim depd ON ((depd.id = orf.departament_id)))
  WHERE ((td.year) :: DOUBLE PRECISION = date_part('year' :: TEXT, CURRENT_DATE));

