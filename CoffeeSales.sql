# Coffee Data Analysis

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

################################################################################################################################################
########################################################## Reports and Data Analysis ###########################################################
################################################################################################################################################

################################################################################################################################################

# How many people in each city consume coffee based on the average of 25% of the population being coffee consumers

SELECT
	city_name,
	ROUND((population * 0.25)/1000000, 2) as coffee_consumers_in_mil,
	city_rank
FROM city
ORDER BY 2 DESC;

# Top 5 cities with highest number of consumers: Delhi, Mumbai, Kolkata, Bangalore, Chennai

################################################################################################################################################

# Total Revenue from coffee sales in the last quarter of 2023

SELECT *,
	YEAR(sale_date) as yr,
    QUARTER(sale_date) as qtr
FROM sales
WHERE
	YEAR(sale_date) = 2023
    AND
    QUARTER(sale_date) = 4;
    
SELECT 
	ci.city_name,
	SUM(sa.total) as total_revenue 
FROM sales as sa
JOIN customers as cu
	ON sa.customer_id = cu.customer_id
JOIN city as ci
	ON ci.city_id = cu.city_id
WHERE 
	QUARTER(sa.sale_date) = 4
    AND
	YEAR(sa.sale_date) = 2023
GROUP BY 1
ORDER BY 2 DESC;

# Top five cities with the highest revenue: Pune, Chennai, Bangalore, Jaipur, Delhi

################################################################################################################################################

# Sales count for each product to show how many units have been sold

SELECT 
	pr.product_name,
    COUNT(sa.sale_id) as total_orders
FROM products as pr
LEFT JOIN sales as sa
	ON sa.product_id = pr.product_id
GROUP BY 1
ORDER BY 2 DESC;

# Top ten products by units sold: 
#1. Cold Brew Coffee Pack (6 Bottles)
#2. Ground Espresso Coffee (250g)
#3. Instant Coffee Powder (100g)
#4. Coffee Beans (500g)
#5. Tote Bag with Coffee Design
#6. Vanilla Coffee Syrup (250ml)
#7. Cold Brew Concentrate (500ml)
#8. Organic Green Coffee Beans (500g)
#9. Coffee Art Print
#10. Flavored Coffee Pods (Pack of 10)

################################################################################################################################################

# Average sales amount per city
# Average sales amount per customer in each city

SELECT 
	ci.city_name,
	SUM(sa.total) as total_revenue,
    COUNT(DISTINCT(sa.customer_id)) as total_cust,
    ROUND(
		SUM(sa.total)/
			COUNT(DISTINCT(sa.customer_id))
		, 2) as avg_sale_per_cust
FROM sales as sa
JOIN customers as cu
	ON sa.customer_id = cu.customer_id
JOIN city as ci
	ON ci.city_id = cu.city_id
GROUP BY 1
ORDER BY 2 DESC;

# Highest average sales per customer: Pune, Chennai, Bangalore, Jaipur, Delhi

################################################################################################################################################

# Finding cities with populations and estimated coffee consumers (25% of population)

WITH city_table as
(
	SELECT 
		city_name, 
		ROUND((population * 0.25)/1000000, 2) as coffee_consumers_in_mil
	FROM city
),
customers_table AS
(
	SELECT 
		ci.city_name, 
		COUNT(DISTINCT(cu.customer_id)) as unique_cust
	FROM sales as sa
	JOIN customers as cu
		ON sa.customer_id = cu.customer_id
	JOIN city as ci
		ON ci.city_id = cu.city_id
	GROUP BY 1
)
SELECT 
	cut.city_name,
    ct.coffee_consumers_in_mil,
    cut.unique_cust
FROM city_table as ct
JOIN 
	customers_table as cut
	ON cut.city_name = ct.city_name;
    
# Top five cities with average estimated coffee consumers in millions: Delhi, Mumbai, Kolkata, Bangalore, Chennai

################################################################################################################################################

# Finding the top 3 selling products in each city based on sales volume

SELECT * 
FROM 
(
SELECT 
	ci.city_name, 
    pr.product_name,
    COUNT(DISTINCT(sa.sale_id)) as total_orders,
    DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(DISTINCT(sa.sale_id)) DESC) as R
FROM sales as sa
JOIN products as pr
	ON sa.product_id = pr.product_id
JOIN customers as cu
	ON cu.customer_id = sa.customer_id
JOIN city as ci
	ON ci.city_id = cu.city_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC
) as T1
WHERE R <= 3;

# Top 3 selling products per city: 
# Ahmedabad: Cold Brew Coffee Pack (6 Bottles), Coffee Beans (500g), Instant Coffee Powder (100g)
# Bangalore: Cold Brew Coffee Pack (6 Bottles), Ground Espresso Coffee (250g), Instant Coffee Powder (100g)
# Etc... 

################################################################################################################################################

# How many unique customers in each city that purchased coffee products

SELECT *
FROM products;
# This tells me the coffee products have a product id of 1 through 14

SELECT 
	ci.city_name,
    COUNT(DISTINCT(cu.customer_id)) as unique_cust
FROM city as ci
JOIN customers as cu
	ON ci.city_id = cu.city_id
JOIN sales as sa
	ON sa.customer_id = cu.customer_id
WHERE
	sa.product_id BETWEEN 0 AND 14
GROUP BY 1;

################################################################################################################################################

# Average sales per customers and average rent per customers

WITH city_table as 
(
	SELECT 
		ci.city_name,
		SUM(sa.total) as total_revenue,
		COUNT(DISTINCT(sa.customer_id)) as total_cust,
		ROUND(
			SUM(sa.total)/
				COUNT(DISTINCT(sa.customer_id))
			, 2) as avg_sale_per_cust
		
	FROM sales as sa
	JOIN customers as cu
		ON sa.customer_id = cu.customer_id
	JOIN city as ci
		ON ci.city_id = cu.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent as
(
	SELECT 
		city_name, 
		estimated_rent
	FROM city
)

SELECT
	cr.city_name,
    cr.estimated_rent,
    ct.total_cust,
    ct.avg_sale_per_cust,
    ROUND(cr.estimated_rent/ct.total_cust, 2) as avg_rent_per_cust
FROM city_rent as cr
JOIN city_table as ct
	ON cr.city_name = ct.city_name
ORDER BY 4 DESC;

# Highest sales are generally in areas where rent is lower

################################################################################################################################################

# Finding the monthly sales growth rate for each city

WITH
monthly_sales as
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(YEAR FROM sale_date) as year, 
		SUM(sa.total) as total_sale
	FROM sales as sa
	JOIN customers as cu
		ON sa.customer_id = cu.customer_id
	JOIN city as ci
		ON ci.city_id = cu.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
),
growth_ratio as
(
	SELECT
		city_name,
		month,
		year,
		total_sale as curr_month_sale,
		LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sales
	FROM monthly_sales
)
SELECT
	city_name,
    month,
    year,
    curr_month_sale,
    last_month_sales,
    ROUND(
		(curr_month_sale - last_month_sales)/ last_month_sales * 100
		, 2
        ) as growth_ratio
FROM growth_ratio
WHERE
	last_month_sales IS NOT NULL;

################################################################################################################################################

# Identifing the three best cities based on all factors

WITH city_table as 
(
	SELECT 
		ci.city_name,
		SUM(sa.total) as total_revenue,
		COUNT(DISTINCT(sa.customer_id)) as total_cust,
		ROUND(
			SUM(sa.total)/
				COUNT(DISTINCT(sa.customer_id))
			, 2) as avg_sale_per_cust
		
	FROM sales as sa
	JOIN customers as cu
		ON sa.customer_id = cu.customer_id
	JOIN city as ci
		ON ci.city_id = cu.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent as
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as est_coffee_consumers_in_mil
	FROM city
)

SELECT
	cr.city_name,
    total_revenue,
    cr.estimated_rent as total_rent,
    ct.total_cust,
    est_coffee_consumers_in_mil,
    ct.avg_sale_per_cust,
    ROUND(cr.estimated_rent/ct.total_cust, 2) as avg_rent_per_cust
FROM city_rent as cr
JOIN city_table as ct
	ON cr.city_name = ct.city_name
ORDER BY 2 DESC;

# 1. Pune:
#	Avg rent is relatively low, which affects sales
#	Highest total revenue
#	Avg sales per customer are also high

# 2. Dehli:
#	Highest estimated coffee consumers - 7.7mil
#	Highest total customers - 68mil
#	Avg rent is relatively low, which affects sales

# 3. Jaipur:
#	Highest number of customers
#	Avg rent per customer is very low
#	Avg sales per customer is still pretty good - 11.6k

# Alternative city: Chennai

























