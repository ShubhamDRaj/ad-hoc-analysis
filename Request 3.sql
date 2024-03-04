/* -Query 3-
    Show each campaign along with total_revenue(before promotion) and total_revenue(after promotion)
    *display the values in Million
*/
SELECT 
	c.campaign_name,
	ROUND(SUM(base_price*quantity_sold_before_promo)/1000000, 1) AS 'total_revenue(before promo)',
    ROUND(SUM(base_price*quantity_sold_after_promo)/1000000, 1) AS 'total_revenue(after promo)'
FROM fact_events e
JOIN dim_campaigns c ON e.campaign_id = c.campaign_id
GROUP BY e.campaign_id;


/* Incremental revenue for each promotion type */
SELECT
	promo_type,
    SUM(base_price * quantity_sold_after_promo) - SUM(base_price * quantity_sold_before_promo) AS incremental_revenue
FROM fact_events
GROUP BY promo_type
ORDER BY 2 DESC;


/* Incremental_sold_unit for each promo_type*/
SELECT
	promo_type,
    SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo) AS incremental_sold_unit
FROM fact_events
GROUP BY promo_type
ORDER BY 2 DESC;