CREATE VIEW current_year_products_revenue AS
  SELECT
    pd.ean,
    sum(orf.quantity)                    AS quantity_summ,
    sum(orf.line_price)                  AS total_cost_prime,
    sum(orf.discount)                    AS total_discount,
    sum((orf.line_price - orf.discount)) AS total_benefit
  FROM ((olap.order_fact orf
    LEFT JOIN olap.time_dim td ON ((td.id = orf.time_id)))
    LEFT JOIN olap.product_dim pd ON ((pd.id = orf.product_id)))
  WHERE ((td.year) :: DOUBLE PRECISION = date_part('year' :: TEXT, CURRENT_DATE))
  GROUP BY pd.ean;

