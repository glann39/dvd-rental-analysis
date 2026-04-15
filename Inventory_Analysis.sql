-- Check the amount of distinct films stored
SELECT COUNT(DISTINCT(film_id))
FROM inventory

SELECT COUNT(DISTINCT(film_id))
FROM film
;

-- Find the films that are not stored in the inventory
SELECT film_id, title
FROM film
WHERE film_id NOT IN (SELECT film_id FROM inventory)
;

-- Find if there is a stored item which has never been rented
SELECT f.film_id, f.title, i.inventory_id, i.store_id
FROM film f
LEFT JOIN inventory i
	ON f.film_id = i.film_id
LEFT JOIN rental r
	ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL AND i.inventory_id IS NOT NULL
-- Result shows that there is one item in the inventory that has never been rented 
;

-- Find the rental counts per copy of each film
WITH 
-- Find the number of times each film is rented
	rent_count_cte AS(
		SELECT f.film_id, f.title, c.name AS film_genre, COUNT(r.rental_id) AS times_rented
		FROM film f
		LEFT JOIN inventory i
			ON f.film_id = i.film_id
		LEFT JOIN rental r
			ON i.inventory_id = r.inventory_id
		JOIN film_category fc
			ON f.film_id = fc.film_id
		JOIN category c
			ON fc.category_id = c.category_id
		WHERE i.inventory_id IS NOT NULL -- Filter out the films that are not stored
		GROUP BY f.film_id, f.title, film_genre
		),
-- Check how many copies of each film is stored
	stored_count_cte AS(
		SELECT f.film_id, f.title, COUNT(i.inventory_id) AS copy_count
		FROM film f
		LEFT JOIN inventory i
			ON f.film_id = i.film_id
		GROUP BY f.film_id, f.title
		)
SELECT rc.film_id, rc.title, rc.times_rented, sc.copy_count,
	ROUND(1.0 * times_rented / copy_count, 2) AS rent_per_copy
FROM rent_count_cte rc
JOIN stored_count_cte sc
	ON rc.film_id = sc.film_id
ORDER BY rent_per_copy DESC
;

-- Find how many copies of each film are stored in each store
-- Also show it if a store does not store any copies
SELECT f.film_id, s.store_id, COUNT(i.inventory_id) AS copy_count
FROM store s
CROSS JOIN film f
LEFT JOIN inventory i
	ON i.store_id = s.store_id
	AND i.film_id = f.film_id
GROUP BY f.film_id, s.store_id
ORDER BY f.film_id, s.store_id
;

-- Find the rental counts per copy of each film
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
		)
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
ORDER BY rcp.film_id
;

-- Find the rental counts per copy of each film
-- CREATE VIEW final_table AS -- Create a view to conduct further analysis
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
		)
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
ORDER BY rcp.film_id
;

-- SELECT *
-- FROM final_table
-- WHERE rent_per_copy > 4.50 -- Find understocked movies
-- WHERE rent_per_copy < 2.50 AND copy_count != 0 -- Find overstocked movies
-- ORDER BY rent_per_copy
-- ;