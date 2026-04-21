/*
INVENTORY ANALYSIS - DVD Rental Project

This script evaluates inventory efficiency across stores to identify
stocking imbalances, underutilized assets, and revenue opportunities.

Questions:
1. Which films are not stocked in any store, representing lost revenue potential?
2. Are there inventory items that have never been rented?
3. Which films are overstocked relative to demand (low rent_per_copy)?
4. Which films are understocked relative to demand (high rent_per_copy)?
*/

/*
1. Films with zero inventory
- These films exist in the catalog but have no physical copies in any store.
- They represent immediate revenue opportunities if stocked.
- Films with zero inventory but high rental rates in 
  similar categories represent the biggest missed opportunity.
*/

SELECT f.film_id, f.title, c.name
FROM film f
JOIN film_category fc
	ON f.film_id = fc.film_id
JOIN category c
	ON fc.category_id = c.category_id
WHERE f.film_id NOT IN (SELECT film_id FROM inventory)
;

/*
2. Inventory items never rented
- Identifies specific physical inventory items that have never generated revenue.
- Result shows that there is one item in the inventory that has never been rented. 

*/

SELECT f.film_id, f.title, i.inventory_id, i.store_id
FROM film f
LEFT JOIN inventory i
	ON f.film_id = i.film_id
LEFT JOIN rental r
	ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL AND i.inventory_id IS NOT NULL
;

/*
3. Rentals per copy analysis
- Find the rental counts per copy of each film
- rent_per_copy = Total Rentals / Number of Copies in Inventory
- A high rent_per_copy suggests the film is popular but understocked
- A low rent_per_copy suggests the film is unpopular or overstocked
*/

WITH 
-- Find the number of times each film is rented per store
	rent_count_pstore_cte AS(
		SELECT f.film_id, f.title, c.name AS film_genre, s.store_id,
			COUNT(r.rental_id) AS times_rented
		FROM store s
		CROSS JOIN film f
		LEFT JOIN inventory i
			ON i.store_id = s.store_id
			AND i.film_id = f.film_id
		LEFT JOIN rental r
			ON i.inventory_id = r.inventory_id
		JOIN film_category fc
			ON f.film_id = fc.film_id
		JOIN category c
			ON fc.category_id = c.category_id
		GROUP BY f.film_id, f.title, film_genre, s.store_id
		),
-- Find how many copies of each film are stored in each store
	stored_count_pstore_cte AS(
		SELECT f.film_id, s.store_id, COUNT(i.inventory_id) AS copy_count
		FROM store s
		CROSS JOIN film f
		LEFT JOIN inventory i
			ON i.store_id = s.store_id
			AND i.film_id = f.film_id
		GROUP BY f.film_id, s.store_id
		),
-- Find the rent per copy of each store
	rent_per_copy_pstore_cte AS(
		SELECT rcp.film_id, rcp.title, rcp.film_genre, rcp.store_id,
			rcp.times_rented, scp.copy_count,
			CASE 
				WHEN copy_count = 0 THEN 0
				ELSE ROUND(1.0 * times_rented / copy_count, 2)
			END AS rent_per_copy
		FROM rent_count_pstore_cte rcp
		JOIN stored_count_pstore_cte scp
			ON rcp.film_id = scp.film_id
			AND rcp.store_id = scp.store_id
		)
SELECT rcp.film_id, rcp.title, rcp.film_genre, rcp.store_id, 
	rcp.times_rented, scp.copy_count, rpc.rent_per_copy,
	CASE
	-- Thresholds is decided based on the observed distribution of rent_per_copy
		WHEN rpc.rent_per_copy >= 4.50 THEN 'Understocked'
		WHEN rpc.rent_per_copy <= 2.50 AND scp.copy_count != 0 THEN 'Overstocked'
		WHEN scp.copy_count = 0 THEN 'Not stocked'
		ELSE 'No change'
	END AS inventory
FROM rent_count_pstore_cte rcp
JOIN stored_count_pstore_cte scp
	ON rcp.film_id = scp.film_id
	AND rcp.store_id = scp.store_id
JOIN rent_per_copy_pstore_cte rpc
	ON rcp.film_id = rpc.film_id 
	AND rcp.store_id = rpc.store_id
ORDER BY rpc.rent_per_copy DESC
;
