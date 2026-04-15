-- Customer analysis

WITH 
-- Find the customer_id, first order and most recent order of each customer
	order_cte AS(
		SELECT cus.customer_id, 
			MIN(ren.rental_date) AS first_order, 
			MAX(ren.rental_date) AS most_recent_order
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
		GROUP BY ren.customer_id
		)
SELECT ord.customer_id, first_order, most_recent_order, 
	total_money_spent, preferred_movie_rating, movie_ratings_rented
FROM order_cte ord
JOIN total_spent_cte tspend
	ON ord.customer_id = tspend.customer_id
JOIN preferred_rating_cte pref
	ON ord.customer_id = pref.customer_id
JOIN all_ratings_cte arat
	ON ord.customer_id = arat.customer_id
;
