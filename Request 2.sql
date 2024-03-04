/*
	-Query 2- 
	Show the total count of stores in each city.
*/
SELECT 
	city, 
    COUNT(store_id) AS store_count
FROM dim_stores
GROUP BY city
ORDER BY 2 DESC;


/* Top 10 stores in terms of incremental revenue after promotion. */
SELECT s.city, e.store_id, ROUND(SUM(e.base_price*e.quantity_sold_after_promo)/1000000, 2) AS `total_revenue(M)`
FROM fact_events e
JOIN dim_stores s ON e.store_id = s.store_id
GROUP BY store_id
ORDER BY 3 DESC
LIMIT 10;


/* Now let's see top 5 products of the top store, shall we? */
SELECT 
	p.product_name,
    SUM(quantity_sold_after_promo) AS total_sold_quantity, -- after promos
    ROUND(SUM(e.base_price*e.quantity_sold_after_promo)/1000000, 2) AS `total_revenue(M)`
FROM fact_events e
JOIN dim_products p ON e.product_code = p.product_code
WHERE e.store_id LIKE 'STMYS-1'
GROUP BY e.product_code
ORDER BY 3 DESC
LIMIT 5;


/* I wonder what is the top product of each store. */
WITH CTE AS
(
SELECT *,
 	DENSE_RANK()	
		OVER(PARTITION BY t1.store_id ORDER BY t1.total_revenue DESC) AS `rank`
FROM
	(
	SELECT
		s.store_id,
		p.product_name,
		SUM(e.base_price*e.quantity_sold_after_promo) AS total_revenue
	FROM fact_events e
	JOIN dim_products p ON e.product_code = p.product_code
	JOIN dim_stores s ON e.store_id = s.store_id
	GROUP BY e.store_id, e.product_code
	) AS t1
)
SELECT * FROM CTE
WHERE `rank` = 1
ORDER BY 3 DESC;

/* Bottom 10 stores in terms of incremental sold units(ISU) during promo. */
SELECT
	s.city,
	s.store_id,
    SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo) AS incremental_sold_units
FROM dim_stores s
JOIN fact_events e ON s.store_id = e.store_id
GROUP BY s.store_id
ORDER BY 3
LIMIT 10;