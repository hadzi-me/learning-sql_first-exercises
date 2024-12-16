USE magist;

# provided tables
SELECT * FROM customers;
SELECT * FROM geo;
SELECT * FROM order_items;
SELECT * FROM order_payments;
SELECT * FROM order_reviews;
SELECT * FROM orders;
SELECT * FROM product_category_name_translation;
SELECT * FROM products;
SELECT * FROM sellers;

SELECT 
    city
FROM
    geo
GROUP BY city;

---------------------------------------------   
# exploring data around all products

SELECT 
    COUNT(product_id) AS products_count
FROM
    products;
## result: number of products 32951

SELECT 
    product_category_name_english,
    COUNT(DISTINCT p.product_id) AS amount
FROM
    products p
        LEFT JOIN
    product_category_name_translation ptr USING (product_category_name)
GROUP BY p.product_category_name
ORDER BY amount DESC;
##  result: overview of number of products per category

---------------------------------------------   
# exploring data around orders and ordered items
SELECT 
    COUNT(DISTINCT order_id) AS orders_count
FROM
    orders;
## result: total number of orders: 99441

SELECT 
    COUNT(*) AS count_of_ordered_items
FROM
    order_items;
## result: total number of items handled through orders: 112650

SELECT 
    order_status, 
    COUNT(order_status) AS count
FROM
    orders
GROUP BY order_status
ORDER BY count DESC;
SELECT 
    YEAR(order_purchase_timestamp) AS year,
    MONTH(order_purchase_timestamp) AS month,
    COUNT(DISTINCT order_id) AS orders_count
FROM
    orders
GROUP BY year , month
ORDER BY year , month;
## result: number of orders each month (over provided timespan)

---------------------------------------------
# exploring data with focus on delivery performance
SELECT 
    COUNT(DISTINCT order_id) AS orders_count
FROM
   orders o
WHERE
    order_status != 'unavailable' OR order_status != 'canceled';
## result: number of succesful orders: 99441

SELECT 
    COUNT(DISTINCT order_id) AS orders_count
FROM
   orders o
WHERE
    order_status = 'delivered';
## result: number of delivered orders: 96478

SELECT 
    product_category_name_english,
    o.order_status,
    COUNT(DISTINCT o.order_id) AS count_of_orders
FROM
    orders o
        LEFT JOIN order_items oi USING (order_id)
        LEFT JOIN products p USING (product_id)
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
WHERE
    o.order_status != 'unavailable'
        AND o.order_status != 'canceled'
GROUP BY product_category_name_english , o.order_status
ORDER BY product_category_name_english;
## result: delivery status of orders per product category

---------------------------------------------
# exploring product prices and payments 
SELECT 
    MIN(price) AS cheapest_item_price, 
    MAX(price) AS most_expensive_item_price
FROM
    order_items;
## result: cheapest and most expensive ordered product prices

SELECT 
    MAX(payment_value) AS highest, 
    MIN(payment_value) AS lowest
FROM
    order_payments
WHERE
    payment_value > 0;
## result: highest and lowest order payment

SELECT 
    order_id, 
    ROUND(SUM(payment_value),2) AS highest_order
FROM
    order_payments
GROUP BY order_id
ORDER BY highest_order DESC
LIMIT 1;
## result: identifying the order with highest payment

SELECT 
    CASE
        WHEN price > 1000 THEN 'expensive'
        WHEN price > 50 AND price < 1000 THEN 'mid-range'
        ELSE 'low price'
    END AS price_category,
	COUNT(DISTINCT oit.product_id) AS number_of_products
FROM
    order_items oit
        LEFT JOIN
    products p USING (product_id)
GROUP BY price_category
ORDER BY price_category DESC;
## result: number of products sorted in price ranges

---------------------------------------------
# exploring product weight
SELECT 
    product_category_name_english,
	ROUND(MIN(product_weight_g),0) AS min_product_weight_g,
    ROUND(MAX(product_weight_g),0) AS max_product_weight_g,
    ROUND(AVG(product_weight_g),0) AS avg_product_weight_g
FROM
    products p
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
GROUP BY p.product_category_name
ORDER BY avg_product_weight_g DESC
LIMIT 10;
## result: min., max., and average product weight in g per category

---------------------------------------------
# exploring delivery times
SELECT 
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM
    orders;

SELECT 
    order_status,
	ROUND(AVG(TIMESTAMPDIFF(DAY,
			order_purchase_timestamp,
			order_delivered_customer_date)),0) AS avg_time_from_purchase_to_delivery
FROM
    orders
WHERE
    order_status = 'delivered'
GROUP BY order_status;
## result: average time from purchase to delivery: 12 days

---------------------------------------------
# exploring data regarding tech categories
SELECT 
    COUNT(DISTINCT product_id) AS count_of_tech_products
FROM
    order_items
        LEFT JOIN products p USING (product_id)
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
WHERE
    product_category_name_english IN (
		'audio' , 
        'computers',
        'computers_accessories',
        'electronics',
        'telephony',
        'watches_gifts');
## result: total number of products in tech category: 4707

SELECT 
    #product_category_name_english, 
    COUNT(DISTINCT p.product_id) AS count_of_products
FROM
    products p
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
WHERE
    product_category_name_english IN (
		'audio' , 
		'computers',
        'computers_accessories',
        'electronics',
        'telephony',
		'watches_gifts')
#GROUP BY product_category_name_english
ORDER BY count_of_products DESC;
## result: number of products per tech category

SELECT 
    product_category_name_english,
    COUNT(DISTINCT product_id) AS amount
FROM
    order_items
        LEFT JOIN products USING (product_id)
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
        LEFT JOIN orders o USING (order_id)
WHERE
    order_status != 'unavailable'
        AND product_category_name_english IN (
        'audio' , 
        'computers',
        'computers_accessories',
        'electronics',
        'telephony',
        'watches_gifts')
GROUP BY product_category_name
ORDER BY product_category_name_english;
## result: number of succesfully sold products per tech category: 4706

SELECT 
    product_category_name_english,
    COUNT(DISTINCT order_id) AS amount
FROM
    order_items
        LEFT JOIN products USING (product_id)
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
        LEFT JOIN orders o USING (order_id)
WHERE
    order_status != 'unavailable'
        AND product_category_name_english IN (
        'audio' , 
        'computers',
        'computers_accessories',
        'electronics',
        'telephony',
        'watches_gifts')
GROUP BY product_category_name
ORDER BY product_category_name_english;
## result: number of succesful orders in tech categories: 19592

SELECT 
    product_category_name_english,
	ROUND(MIN(oit.price), 2) AS min_price,
    ROUND(MAX(oit.price), 2) AS max_price,
    ROUND(AVG(oit.price), 2) AS avg_price
FROM
    products p
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
        LEFT JOIN order_items oit USING (product_id)
WHERE
    product_category_name_english IN (
		'audio' , 
        'computers',
        'computers_accessories',
        'electronics',
        'telephony',
        'watches_gifts')
GROUP BY product_category_name_english
ORDER BY avg_price DESC;
## result: min., max., and average product price per tech category

SELECT 
    product_category_name_english,
    MAX(payment_value) AS highest_payment
FROM
    products p
        LEFT JOIN product_category_name_translation ptr USING (product_category_name)
        LEFT JOIN order_items oit USING (product_id)
        LEFT JOIN order_payments op USING (order_id)
WHERE
    product_category_name_english IN (
		'audio' , 
        'computers',
        'computers_accessories',
        'electronics',
        'telephony',
        'watches_gifts')
GROUP BY product_category_name_english
ORDER BY highest_payment DESC;
## result: highest payment per tech category