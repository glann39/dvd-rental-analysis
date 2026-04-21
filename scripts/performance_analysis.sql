/*
PERFORMANCE ANALYSIS - DVD Rental Project

This script analyzes revenue drivers across films, categories, and
actors to inform content acquisition and promotional strategies.

Questions:
1. Which film categories generate the highest revenue and rental volume?
2. Which individual films are top performers by revenue?
3. Which actors drive the most revenue, and does film count correlate with earnings?
4. What percentage of customers have seen each actor's films (audience reach)?
5. What are the monthly revenue trends over time?
*/

/*
1. Category performance analysis
- Identifies which film categories generates the most revenue.
- Top film categories should receive priority in inventory investment. 
*/

SELECT c.name AS category,
	COUNT(DISTINCT(i.film_id)) AS total_films,
	COUNT(r.rental_id) AS total_rentals,
	ROUND(SUM(p.amount), 2) AS total_revenue,
	ROUND(SUM(p.amount) / COUNT(DISTINCT(i.film_id)), 2) AS revenue_per_film
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
ORDER BY total_revenue DESC
;

/*
2. Actor performance analysis
- Determines which actors generates the most revenue.
*/

WITH 
	film_count_cte AS(
-- Find the number of films each actor performed in
		SELECT fa.actor_id, COUNT(DISTINCT(fa.film_id)) AS films_appeared_in
		FROM inventory i
		JOIN film f
			ON i.film_id = f.film_id
		JOIN film_actor fa
			ON f.film_id = fa.film_id
		GROUP BY fa.actor_id),
	actor_revenue_cte AS(
-- Find the revenue each actor generated
		SELECT a.actor_id, 
			CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
			SUM(p.amount) AS total_revenue
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
		GROUP BY a.actor_id, actor_name),
	revenue_per_film_cte AS(
-- Find the revenue per film of each actor
		SELECT fcc.actor_id, 
			ROUND(1.0 * arc.total_revenue / fcc.films_appeared_in, 2) AS revenue_per_film
		FROM film_count_cte fcc
		JOIN actor_revenue_cte arc
			ON fcc.actor_id = arc.actor_id)
SELECT fcc.actor_id, arc.actor_name, fcc.films_appeared_in,
	arc.total_revenue, rpvc.revenue_per_film
FROM film_count_cte fcc
JOIN actor_revenue_cte arc
	ON fcc.actor_id = arc.actor_id
JOIN revenue_per_film_cte rpvc
	ON fcc.actor_id = rpvc.actor_id
ORDER BY revenue_per_film DESC
;

/*
3. Customer penetration analysis
- Measures the percentage of the total customer base that has rented at least
  one film featuring each actor. 
- Can be compared with actor performance analysis query.
- An actor with high reach but low revenue per film 
  might suggests popular but low-priced content.
- An actor with low reach but high revenue might suggest
  a dedicated fan base willing to pay high rental rates.
*/

WITH customer_count_cte AS(
	SELECT a.actor_id, 
		CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
		COUNT(DISTINCT(c.customer_id)) AS customer_count
	FROM actor a
	JOIN film_actor fa
		ON a.actor_id = fa.actor_id
	JOIN inventory i
		ON fa.film_id = i.film_id
	JOIN rental r
		ON i.inventory_id = r.inventory_id
	JOIN customer c
		ON r.customer_id = c.customer_id
	GROUP BY a.actor_id, actor_name)
SELECT actor_id, actor_name, 
	ROUND(100.0 * customer_count / (SELECT COUNT(customer_id) FROM customer), 2) 
		AS actor_reach
FROM customer_count_cte
ORDER BY actor_id DESC
;

/*
4. Film revenue by number of actors 
- Find the revenue per actor of each film: revenue / number of actors.
- This shows how revenue is divided among actors within each individual film.
- Films with high revenue_per_actor might suggest an actor that
  can generate a lot of revenue by themself.
- Films with low values despite high total revenue have a large
  cast spreading the revenue_per_actor thin.
*/

WITH film_revenue_cte AS(
-- Find the revenue of each film
		SELECT i.film_id, SUM(amount) AS total_revenue
		FROM inventory i
		JOIN rental r
			ON i.inventory_id = r.inventory_id
		JOIN payment p
			ON r.rental_id = p.rental_id
		GROUP BY i.film_id)
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

/*
5. Monthly revenue 
- Identify the revenue generated each month.
*/

SELECT DATE_TRUNC('month', p.payment_date) AS month, 
	COUNT(DISTINCT r.rental_id) AS monthly_rentals,
	COUNT(DISTINCT r.customer_id) AS unique_customers,
	ROUND(SUM(p.amount), 2) AS monthly_revenue,
	ROUND(AVG(p.amount), 2) AS avg_revenue_per_rental
FROM payment p
JOIN rental r 
	ON p.rental_id = r.rental_id
GROUP BY DATE_TRUNC('month', p.payment_date)
ORDER BY month
;
