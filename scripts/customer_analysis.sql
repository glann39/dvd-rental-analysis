/*
CUSTOMER ANALYSIS - DVD Rental Project

This script analyzes customer lifecycle and purchasing behavior to
identify our most valuable customer segments and understand their preferences.

Questions:
1. What is the customer lifetime value and purchase frequency?
2. How much time passes between a customer's first and most recent rental?
3. What are the preferred film ratings and categories of customers?
4. What are the preferrences of the top customers?
*/

WITH 
-- Find the customer_id, first order and most recent order of each customer
	order_cte AS(
		SELECT cus.customer_id, 
			MIN(ren.rental_date) AS first_order, 
			MAX(ren.rental_date) AS most_recent_order,
			COUNT(ren.rental_id) AS orders_made
		FROM customer cus
		JOIN rental ren
			ON cus.customer_id = ren.customer_id
		GROUP BY cus.customer_id),
-- Calculate the total money spent per customer
	total_spent_cte AS(
		SELECT cus.customer_id, SUM(pay.amount) AS total_money_spent
		FROM customer cus
		JOIN payment pay 
			ON cus.customer_id = pay.customer_id
		GROUP BY cus.customer_id),
-- Find the preferred movie rating of each customer
	preferred_rating_cte AS(
		SELECT customer_id, ARRAY_AGG(rating) AS preferred_movie_rating
		FROM (SELECT ren.customer_id, fil.rating, 
				COUNT(fil.rating) AS rating_count, 
				RANK() OVER(PARTITION BY ren.customer_id 
					ORDER BY COUNT(fil.rating) DESC) AS rating_rank
				FROM inventory inv
				JOIN film fil
					ON inv.film_id = fil.film_id
				JOIN rental ren
					ON inv.inventory_id = ren.inventory_id
				GROUP BY ren.customer_id, fil.rating) AS rating_pref_subq
		WHERE rating_rank = 1
		GROUP BY rating_pref_subq.customer_id),
-- Find all the ratings of the movies each customer rented from
	all_ratings_cte AS(
		SELECT ren.customer_id, 
			ARRAY_AGG(DISTINCT(fil.rating)) AS movie_ratings_rented
		FROM inventory inv
		JOIN film fil
			ON inv.film_id = fil.film_id
		JOIN rental ren
			ON inv.inventory_id = ren.inventory_id
		GROUP BY ren.customer_id),
-- Find the film category each customer rented the most
	fav_movie_cte AS(
		SELECT customer_id, name AS favourite_film_category
		FROM (SELECT cus.customer_id, cat.category_id, cat.name,
				COUNT(cat.category_id) AS rent_count,
				RANK() OVER(PARTITION BY cus.customer_id ORDER BY COUNT(cat.category_id) DESC) AS cat_rank
				FROM category cat
				JOIN film_category fcat
					ON cat.category_id = fcat.category_id
				JOIN film fil
					ON fcat.film_id = fil.film_id
				JOIN inventory inv
					ON fil.film_id = inv.film_id
				JOIN rental ren
					ON inv.inventory_id = ren.inventory_id
				JOIN customer cus 
					ON ren.customer_id = cus.customer_id
				GROUP BY cus.customer_id, cat.category_id, cat.name) AS fav_cat_subq
		WHERE cat_rank = 1)
SELECT ord.customer_id, first_order, most_recent_order, 
	most_recent_order - first_order AS customer_lifetime,
	orders_made, total_money_spent, 
	ROUND(total_money_spent / orders_made, 2) AS avg_order_value, 
	preferred_movie_rating, movie_ratings_rented, favourite_film_category
FROM order_cte ord
LEFT JOIN total_spent_cte tspend
	ON ord.customer_id = tspend.customer_id
LEFT JOIN preferred_rating_cte pref
	ON ord.customer_id = pref.customer_id
LEFT JOIN all_ratings_cte arat
	ON ord.customer_id = arat.customer_id
LEFT JOIN fav_movie_cte favm
	ON ord.customer_id = favm.customer_id
--------------------------------
---- View the top customers ----
--------------------------------
-- SELECT ord.customer_id, first_order, most_recent_order, 
-- 	most_recent_order - first_order AS customer_lifetime,
-- 	orders_made, total_money_spent, 
-- 	ROUND(total_money_spent / orders_made, 2) AS avg_order_value, 
-- 	preferred_movie_rating, movie_ratings_rented, favourite_film_category,
-- 	RANK() OVER(ORDER BY total_money_spent DESC) AS top_customers 
-- FROM order_cte ord
-- JOIN total_spent_cte tspend
-- 	ON ord.customer_id = tspend.customer_id
-- JOIN preferred_rating_cte pref
-- 	ON ord.customer_id = pref.customer_id
-- JOIN all_ratings_cte arat
-- 	ON ord.customer_id = arat.customer_id
-- JOIN fav_movie_cte favm
-- 	ON ord.customer_id = favm.customer_id
-- LIMIT 100
;
