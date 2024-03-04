/*
	-Query 1- 
    Return a list of products with a base price greater than 500
    having promo type of 'BOGOF'(Buy One Get One Free).
*/
SELECT 
	DISTINCT(p.product_name),
    e.base_price,
    e.promo_type 
FROM dim_products p
LEFT JOIN fact_events e ON p.product_code = e.product_code
WHERE e.base_price > 500
AND e.promo_type LIKE 'BOGOF';


/* how much these two products were sold in both campaigns: */
WITH CTE AS(
	SELECT
		p.product_name,
		c.campaign_name,
		SUM(quantity_sold_before_promo) AS quantity_sold_before_promo,
		SUM(quantity_sold_after_promo) AS quantity_sold_after_promo
	FROM dim_products p
	LEFT JOIN fact_events e ON p.product_code = e.product_code
	JOIN dim_campaigns c ON e.campaign_id = c.campaign_id
	WHERE e.base_price > 500
	AND e.promo_type LIKE 'BOGOF'
	GROUP BY e.product_code, e.campaign_id
	ORDER BY 2, 1
)
SELECT 
	CTE.campaign_name,
	CTE.product_name,
    CTE.quantity_sold_after_promo,
	ROUND((CTE.quantity_sold_after_promo - CTE.quantity_sold_before_promo)/CTE.quantity_sold_before_promo * 100, 1) AS 'incremental_sold_quantity%'
FROM CTE;