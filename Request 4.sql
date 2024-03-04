/*
	-Query 4-
    Incremental Sold Quantity % for each product category for Diwali campaign
*/
WITH CTE AS
(
	SELECT *,
		ROUND((gb.incremental_sold_quantity/gb.quantity_sold_before_promo)*100, 1) AS incremental_sold_quantity_pct
	FROM
    (
		SELECT
			p.category,
			SUM(e.quantity_sold_before_promo) AS quantity_sold_before_promo,
			SUM(e.quantity_sold_after_promo) AS quantity_sold_after_promo,
            SUM(e.quantity_sold_after_promo) - SUM(e.quantity_sold_before_promo) AS incremental_sold_quantity
		FROM fact_events e
		JOIN dim_products p ON e.product_code = p.product_code
		WHERE e.campaign_id LIKE 'CAMP_DIW_01'
		GROUP BY p.category
	)gb
)
SELECT 
	CTE.category,
    CTE.incremental_sold_quantity_pct AS 'isu%',
	DENSE_RANK()
		OVER(ORDER BY CTE.incremental_sold_quantity_pct DESC) AS 'rank_order'
FROM CTE;


/* Query 4 extra: Performance of the products of `Grocery & Staples` with incremental sold quantity during Diwali Campaign. */
SELECT 
	isu.product_name,
    isu.promo_type,
    isu.incremental_sold_quantity,
    isu.`isu%`,
	DENSE_RANK()
		OVER(ORDER BY isu.`isu%` DESC) AS rnk,
	isu.base_price
FROM
(
	SELECT *,
		(gb.quantity_sold_after_promo - gb.quantity_sold_before_promo) AS incremental_sold_quantity,
		ROUND(((gb.quantity_sold_after_promo - gb.quantity_sold_before_promo)/gb.quantity_sold_before_promo)*100, 1) AS 'isu%'
	FROM
    (
		SELECT
			p.category,
			p.product_name,
            e.base_price,
            e.promo_type,
			SUM(e.quantity_sold_before_promo) AS quantity_sold_before_promo,
			SUM(e.quantity_sold_after_promo) AS quantity_sold_after_promo
		FROM fact_events e
		JOIN dim_products p ON e.product_code = p.product_code
		WHERE e.campaign_id LIKE 'CAMP_DIW_01'
        AND p.category = 'Grocery & Staples'
		GROUP BY p.product_name
	)gb
)isu;