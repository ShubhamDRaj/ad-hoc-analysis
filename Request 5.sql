/*
	-Query 5-
    Top 5 products ranked by Incremental Revenue Percentage(IR%) across both campaigns.
    Fields: product_name, category, ir%
*/
SELECT
	revenue.product_name,
    revenue.category,
    ROUND(((revenue_after_promo - revenue_before_promo) / revenue_before_promo) *100, 1) AS 'ir%',
    ROUND((revenue.revenue_after_promo / 1000000), 2) AS `total_revenue(M)`
FROM
(
	SELECT
		p.product_name,
		p.category,
		SUM((e.base_price * e.quantity_sold_before_promo)) AS revenue_before_promo,
		SUM((e.base_price * e.quantity_sold_after_promo)) AS revenue_after_promo
	FROM fact_events e
	JOIN dim_products p ON e.product_code = p.product_code
	GROUP BY e.product_code
    ORDER BY revenue_after_promo DESC
) AS revenue
ORDER BY `ir%` DESC
LIMIT 5;


/* let's check the bottom 5 products as well*/
SELECT
	p.product_name,
    p.category,
    e.promo_type,
    SUM(e.quantity_sold_after_promo) - SUM(e.quantity_sold_before_promo) AS incremental_sold_unit,
    ROUND((SUM(e.base_price*e.quantity_sold_after_promo) - SUM(e.base_price*e.quantity_sold_before_promo))/SUM(e.base_price*e.quantity_sold_before_promo)*100, 1) AS 'ir%'
FROM dim_products p
JOIN fact_events e ON p.product_code = e.product_code
GROUP BY e.product_code
ORDER BY 4
limit 5;

/*				END				*/