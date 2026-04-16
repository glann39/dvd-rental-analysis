-- Find the most popular film categories
SELECT c.name AS category,
	COUNT(r.rental_id) AS rent_count,
	ROUND((100.0 * COUNT(r.rental_id) / (SELECT COUNT(rental_id) FROM rental)), 2) AS rental_perc
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN film f
	ON fc.film_id = f.film_id
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
-- JOIN payment p
-- 	ON r.rental_id = p.rental_id
GROUP BY category
ORDER BY rent_count DESC
;

-- Find the top grossing film categories
SELECT c.name AS category,
	SUM(p.amount) AS total_paid,
	ROUND((100.0 * COUNT(r.rental_id) / (SELECT COUNT(rental_id) FROM rental)), 2) AS rental_perc
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN film f
	ON fc.film_id = f.film_id
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN payment p
 	ON r.rental_id = p.rental_id
GROUP BY category
ORDER BY total_paid DESC
;

-- Find the top grossing actors
SELECT a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS full_name, 
	SUM(p.amount) AS gross_total
FROM actor a
JOIN film_actor fa
	ON a.actor_id = fa.actor_id
JOIN film f
	ON fa.film_id = f.film_id
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN payment p
	ON r.rental_id = p.rental_id
GROUP BY a.actor_id, full_name
ORDER BY gross_total DESC
LIMIT 5
;

-- Find the percentage of customers that rented at least one of each actor's films
WITH customer_count_cte AS(
	SELECT a.actor_id, COUNT(DISTINCT(c.customer_id)) AS customer_count
	FROM actor a
	JOIN film_actor fa
		ON a.actor_id = fa.actor_id
	JOIN inventory i
		ON fa.film_id = i.film_id
	JOIN rental r
		ON i.inventory_id = r.inventory_id
	JOIN customer c
		ON r.customer_id = c.customer_id
	GROUP BY a.actor_id
	ORDER BY a.actor_id
	)
SELECT actor_id, 
	ROUND(100.0 * customer_count / (SELECT COUNT(customer_id) FROM customer), 2) 
		AS reach
FROM customer_count_cte
ORDER BY reach DESC
;

-- Find the revenue per actor of each film - revenue/number of actors
WITH film_revenue_cte AS(
-- Find the revenue of each film
		SELECT i.film_id, SUM(amount) AS total_revenue
		FROM inventory i
		JOIN rental r
			ON i.inventory_id = r.inventory_id
		JOIN payment p
			ON r.rental_id = p.rental_id
		GROUP BY i.film_id
		)
SELECT fr.film_id, fr.total_revenue,
	COUNT(DISTINCT(fa.actor_id)) AS actor_count,
	ROUND(1.0 * fr.total_revenue / COUNT(DISTINCT(fa.actor_id)), 2)
		AS revenue_per_actor,
	ARRAY_AGG(fa.actor_id) AS actors
FROM film_revenue_cte fr
JOIN film f
	ON fr.film_id = f.film_id
JOIN film_actor fa
	ON f.film_id = fa.film_id
GROUP BY fr.film_id, total_revenue
ORDER BY revenue_per_actor DESC
;
