/*
GEOGRAPHIC REVENUE ANALYSIS - DVD Rental Project

This query evaluates customer distribution and revenue performance by country
to identify high-volume markets and high-value (revenue per customer) markets.

Questions:
1. Which countries have the largest customer bases?
2. Which countries generate the highest total revenue?
3. Which countries have the highest revenue per customer?

- High revenue_per_customer suggests a premium market willing to pay more
- Countries with high customer_count but low revenue_per_customer are volume markets. 
- Countries with low customer_count but high revenue_per_customer are premium markets.
*/

WITH base_cte AS(
		SELECT cu.customer_id, cu.first_name, cu.last_name, 
			co.country_id, co.country
		FROM customer cu
		JOIN address ad
			ON cu.address_id = ad.address_id
		JOIN city ci
			ON ad.city_id = ci.city_id
		JOIN country co
			ON ci.country_id = co.country_id),
	customer_count_cte AS(
		SELECT country_id, country, 
			COUNT(customer_id) AS customer_count
		FROM base_cte
		GROUP BY country_id, country),
	country_revenue_cte AS(
		SELECT country_id, country, 
			SUM(pa.amount) total_revenue
		FROM base_cte ba
		JOIN rental re
			ON ba.customer_id = re.customer_id
		JOIN payment pa
			ON re.rental_id = pa.rental_id
		GROUP BY country_id, country)
SELECT ccc.country_id, ccc.country, 
	ccc.customer_count, crc.total_revenue,
	ROUND(crc.total_revenue / ccc.customer_count, 2) AS revenue_per_customer
FROM customer_count_cte ccc
JOIN country_revenue_cte crc
	ON ccc.country_id = crc.country_id
ORDER BY revenue_per_customer DESC
;
