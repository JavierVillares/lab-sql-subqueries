USE sakila;
-- 1.
SELECT 
    COUNT(*) AS number_of_copies
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
WHERE 
    f.title = 'Hunchback Impossible';

-- 2. 
SELECT 
    title,
    length
FROM 
    film
WHERE 
    length > (SELECT AVG(length) FROM film);

-- 3. 
SELECT 
    actor.actor_id,
    actor.first_name,
    actor.last_name
FROM 
    actor
WHERE 
    actor.actor_id IN (
        SELECT 
            film_actor.actor_id
        FROM 
            film_actor
        JOIN 
            film ON film_actor.film_id = film.film_id
        WHERE 
            film.title = 'Alone Trip'
    );

-- 4.
SELECT 
    f.title AS film_title
FROM 
    film f
JOIN 
    film_category fc ON f.film_id = fc.film_id
JOIN 
    category c ON fc.category_id = c.category_id
WHERE 
    c.name = 'Family';
    
-- 5. 
SELECT 
    first_name,
    last_name,
    email
FROM 
    customer
WHERE 
    address_id IN (
        SELECT 
            address_id
        FROM 
            address
        WHERE 
            city_id IN (
                SELECT 
                    city_id
                FROM 
                    city
                WHERE 
                    country_id IN (
                        SELECT 
                            country_id
                        FROM 
                            country
                        WHERE 
                            country = 'Canada'
                    )
            )
    );

-- 6.
USE sakila;

-- Step 1: Find the most prolific actor
SELECT 
    actor_id
FROM 
    (
        SELECT 
            actor_id,
            COUNT(*) AS film_count
        FROM 
            film_actor
        GROUP BY 
            actor_id
        ORDER BY 
            film_count DESC
        LIMIT 1
    ) AS most_prolific_actor;

-- Step 2: Find the films starred by the most prolific actor
SELECT 
    f.title AS film_title
FROM 
    film f
JOIN 
    film_actor fa ON f.film_id = fa.film_id
WHERE 
    fa.actor_id = (
        SELECT 
            actor_id
        FROM 
            (
                SELECT 
                    actor_id,
                    COUNT(*) AS film_count
                FROM 
                    film_actor
                GROUP BY 
                    actor_id
                ORDER BY 
                    film_count DESC
                LIMIT 1
            ) AS most_prolific_actor
    );

-- 7.
SELECT 
    customer_id
FROM 
    (
        SELECT 
            customer_id,
            SUM(amount) AS total_payments
        FROM 
            payment
        GROUP BY 
            customer_id
        ORDER BY 
            total_payments DESC
        LIMIT 1
    ) AS most_profitable_customer;

-- Step 2: Find the films rented by the most profitable customer
SELECT 
    f.title AS film_title
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
JOIN 
    (
        SELECT 
            customer_id
        FROM 
            (
                SELECT 
                    customer_id,
                    SUM(amount) AS total_payments
                FROM 
                    payment
                GROUP BY 
                    customer_id
                ORDER BY 
                    total_payments DESC
                LIMIT 1
            ) AS most_profitable_customer
    ) AS mp_customer ON r.customer_id = mp_customer.customer_id;
    
-- 8.
SELECT 
    customer_id AS client_id,
    total_amount_spent
FROM (
    SELECT 
        customer_id,
        SUM(amount) AS total_amount_spent
    FROM 
        payment
    GROUP BY 
        customer_id
) AS customer_payments
WHERE 
    total_amount_spent > (
        SELECT 
            AVG(total_amount_spent)
        FROM (
            SELECT 
                customer_id,
                SUM(amount) AS total_amount_spent
            FROM 
                payment
            GROUP BY 
                customer_id
        ) AS avg_total_amount_spent 
    );
