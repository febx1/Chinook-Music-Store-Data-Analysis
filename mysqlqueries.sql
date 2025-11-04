-- 1.	Does any table have missing values or duplicates? If yes how would you handle it ?
use chinook;
-- Counting null values on all tables with column name
SELECT
    table_name,
    column_name,
    null_count
FROM
    (
		-- Table: album
        SELECT 'album' AS table_name, 'name' AS column_name, COUNT(*) as null_count
        from album where title is NULL 
        union all
    
        -- Table: artist
        SELECT 'artist' AS table_name, 'name' AS column_name, COUNT(*) AS null_count FROM artist WHERE name IS NULL
        UNION ALL
        
        -- Table: customer
        SELECT 'customer', 'company', COUNT(*) FROM customer WHERE company IS NULL
        UNION ALL
        SELECT 'customer', 'address', COUNT(*) FROM customer WHERE address IS NULL
        UNION ALL
        SELECT 'customer', 'city', COUNT(*) FROM customer WHERE city IS NULL
        UNION ALL
        SELECT 'customer', 'state', COUNT(*) FROM customer WHERE state IS NULL
        UNION ALL
        SELECT 'customer', 'country', COUNT(*) FROM customer WHERE country IS NULL
        UNION ALL
        SELECT 'customer', 'postal_code', COUNT(*) FROM customer WHERE postal_code IS NULL
        UNION ALL
        SELECT 'customer', 'phone', COUNT(*) FROM customer WHERE phone IS NULL
        UNION ALL
        SELECT 'customer', 'fax', COUNT(*) FROM customer WHERE fax IS NULL
        UNION ALL
        SELECT 'customer', 'support_rep_id', COUNT(*) FROM customer WHERE support_rep_id IS NULL
        UNION ALL
        
        -- Table: employee
        SELECT 'employee', 'title', COUNT(*) FROM employee WHERE title IS NULL
        UNION ALL
        SELECT 'employee', 'reports_to', COUNT(*) FROM employee WHERE reports_to IS NULL
        UNION ALL
        SELECT 'employee', 'birthdate', COUNT(*) FROM employee WHERE birthdate IS NULL
        UNION ALL
        SELECT 'employee', 'hire_date', COUNT(*) FROM employee WHERE hire_date IS NULL
        UNION ALL
        SELECT 'employee', 'address', COUNT(*) FROM employee WHERE address IS NULL
        UNION ALL
        SELECT 'employee', 'city', COUNT(*) FROM employee WHERE city IS NULL
        UNION ALL
        SELECT 'employee', 'state', COUNT(*) FROM employee WHERE state IS NULL
        UNION ALL
        SELECT 'employee', 'country', COUNT(*) FROM employee WHERE country IS NULL
        UNION ALL
        SELECT 'employee', 'postal_code', COUNT(*) FROM employee WHERE postal_code IS NULL
        UNION ALL
        SELECT 'employee', 'phone', COUNT(*) FROM employee WHERE phone IS NULL
        UNION ALL
        SELECT 'employee', 'fax', COUNT(*) FROM employee WHERE fax IS NULL
        UNION ALL
        SELECT 'employee', 'email', COUNT(*) FROM employee WHERE email IS NULL
        UNION ALL
        
        -- Table: genre
        SELECT 'genre', 'name', COUNT(*) FROM genre WHERE name IS NULL
        UNION ALL
        
        -- Table: invoice
        SELECT 'invoice', 'billing_address', COUNT(*) FROM invoice WHERE billing_address IS NULL
        UNION ALL
        SELECT 'invoice', 'billing_city', COUNT(*) FROM invoice WHERE billing_city IS NULL
        UNION ALL
        SELECT 'invoice', 'billing_state', COUNT(*) FROM invoice WHERE billing_state IS NULL
        UNION ALL
        SELECT 'invoice', 'billing_country', COUNT(*) FROM invoice WHERE billing_country IS NULL
        UNION ALL
        SELECT 'invoice', 'billing_postal_code', COUNT(*) FROM invoice WHERE billing_postal_code IS NULL
        UNION ALL
        
        -- Table: media_type
        SELECT 'media_type', 'name', COUNT(*) FROM media_type WHERE name IS NULL
        UNION ALL
        
        -- Table: playlist
        SELECT 'playlist', 'name', COUNT(*) FROM playlist WHERE name IS NULL
        UNION ALL
        
        -- Table: track
        SELECT 'track', 'album_id', COUNT(*) FROM track WHERE album_id IS NULL
        UNION ALL
        SELECT 'track', 'genre_id', COUNT(*) FROM track WHERE genre_id IS NULL
        UNION ALL
        SELECT 'track', 'composer', COUNT(*) FROM track WHERE composer IS NULL
        UNION ALL
        SELECT 'track', 'bytes', COUNT(*) FROM track WHERE bytes IS NULL
    ) AS null_counts_by_column
WHERE
    null_count > 0
ORDER BY
    table_name, null_count DESC;
    
-- 2.	Find the top-selling tracks and top artist in the USA and identify their most famous genres.
 
 -- A. Top selling Tracks in USA
 
SELECT 
	t.track_id,
    t.name as track_name,
    g.name as genre,
    a.name as artist_name,
    sum(il.quantity)total_units_sold
FROM invoice i 
JOIN invoice_line il
on i.invoice_id=il.invoice_id
join track t 
on il.track_id=t.track_id
join genre g 
on t.genre_id=g.genre_id
join album al 
on t.album_id = al.album_id
join artist a 
on al.artist_id = a.artist_id
where i.billing_country="USA"
group by t.track_id,t.name,g.name,a.name
order by total_units_sold desc,t.track_id
limit 10;

-- B. Top selling artists in USA

SELECT
  ar.name AS ArtistName,
  SUM(il.Quantity) AS TotalTracksSold
FROM invoice_line AS il
JOIN Invoice AS I
  ON IL.Invoice_Id = I.Invoice_Id
JOIN Track AS T
  ON IL.Track_Id = T.Track_Id
JOIN Album AS A
  ON T.Album_Id = A.Album_Id
JOIN Artist AS AR
  ON A.Artist_Id = AR.Artist_Id
WHERE
  I.Billing_Country = 'USA'
GROUP BY
  ArtistName
ORDER BY
  TotalTracksSold DESC
LIMIT 10;

-- C. Most popular genres in USA

SELECT 
    g.genre_id,
    g.name as genre_name,
    COUNT(DISTINCT t.track_id) as unique_tracks_sold,
    SUM(il.quantity) as total_units_sold,
    SUM(il.quantity * il.unit_price) as total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name
ORDER BY total_revenue desc
LIMIT 10;

-- 3.	What is the customer demographic breakdown (age, gender, location) of Chinook's customer base?

SELECT country,COUNT(*) customer_count,
ROUND(COUNT(customer_id) * 100.0 / (SELECT COUNT(*) FROM customer), 2) as percentage
FROM CUSTOMER
GROUP BY country
ORDER BY customer_count desc;

-- 4.	Calculate the total revenue and number of invoices for each country, state, and city:
use chinook;

SELECT 
    billing_country as country,                                                                                                            
    COALESCE(billing_state, 'Not Specified') as state,
    COALESCE(billing_city, 'Not Specified') as city,
    COUNT(invoice_id) as number_of_invoices,
    ROUND(SUM(total), 2) as total_revenue
FROM invoice
GROUP BY billing_country, billing_state, billing_city
ORDER BY total_revenue DESC;

-- 5.	Find the top 5 customers by total revenue in each country

WITH customer_revenue_by_country AS (
    SELECT 
        c.customer_id,
        concat(c.first_name," ", c.last_name) as customer_name,
        c.country,
        c.city,
        COUNT(i.invoice_id) as total_invoices,
        ROUND(SUM(i.total), 2) as total_revenue,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(i.total) DESC) as revenue_rank
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country, c.city, c.company
)
SELECT 
    country,
    customer_name,
    city,
    total_invoices,
    total_revenue,
    revenue_rank
FROM customer_revenue_by_country
WHERE revenue_rank <= 5
ORDER BY country, revenue_rank;

-- 6.	Identify the top-selling track for each customer

WITH customer_track_purchases AS (
    SELECT 
        c.customer_id,
        concat(c.first_name," ", c.last_name) as customer_name,
        t.track_id,
        t.name as track_name,
        ar.name as artist_name,
        g.name as genre,
        COUNT(il.invoice_line_id) as times_purchased,
        SUM(il.quantity) as total_units,
        ROUND(SUM(il.quantity * il.unit_price), 2) as total_spent,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY SUM(il.quantity*il.unit_price) DESC, COUNT(il.invoice_line_id) DESC) as track_rank
    FROM customer c
    JOIN invoice i 
    ON c.customer_id = i.customer_id
    JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
    JOIN track t 
    ON il.track_id = t.track_id
    JOIN album al 
    ON t.album_id = al.album_id
    JOIN artist ar 
    ON al.artist_id = ar.artist_id
    JOIN genre g 
    ON t.genre_id = g.genre_id
    GROUP BY c.customer_id, c.first_name, c.last_name,
             t.track_id, t.name, ar.name, g.name
)
SELECT 
customer_id,
    customer_name,
    track_name,
    artist_name,
    genre,
    times_purchased,
    total_units,
    total_spent
FROM customer_track_purchases
WHERE track_rank = 1
ORDER BY customer_name;

-- 7.	Are there any patterns or trends in customer purchasing behavior (e.g., frequency of purchases, preferred payment methods, average order value)?

WITH customer_purchase_patterns AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        c.country,
        -- Purchase metrics
        COUNT(i.invoice_id) as total_orders,
        ROUND(SUM(i.total), 2) as total_spent,
        ROUND(AVG(i.total), 2) as avg_order_value,
        -- Time-based metrics
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) as customer_tenure_days,
        -- Recency
        DATEDIFF(CURRENT_DATE(), MAX(i.invoice_date)) as days_since_last_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT 
    customer_name,
    country,
    total_orders,
    total_spent,
    avg_order_value,
    customer_tenure_days,
    days_since_last_purchase
FROM customer_purchase_patterns
ORDER BY total_spent DESC;

 -- Geographic Purchase Behavior Patterns
SELECT 
    billing_country as country,
    COUNT(invoice_id) as total_orders,
    ROUND(SUM(total), 2) as total_revenue,
    ROUND(AVG(total), 2) as avg_order_value,
    ROUND(MAX(total), 2) as max_order_value,
    ROUND(MIN(total), 2) as min_order_value,
    COUNT(DISTINCT customer_id) as unique_customers,
    ROUND(COUNT(invoice_id) * 1.0 / COUNT(DISTINCT customer_id), 2) as orders_per_customer,
    ROUND(SUM(total) / COUNT(DISTINCT customer_id), 2) as revenue_per_customer
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;



-- 8.	What is the customer churn rate?
WITH latest_date AS (
    SELECT MAX(invoice_date) as max_date FROM invoice
),
customer_status AS (
    SELECT 
        c.customer_id,
        CASE 
            WHEN MAX(i.invoice_date) >= DATE_SUB((SELECT max_date FROM latest_date) , INTERVAL 180 day )
            THEN 'Active'
            ELSE 'Churned'
        END as status
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
)
SELECT 
    COUNT(*) as total_customers,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) as active_customers,
    SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) as churned_customers,
    ROUND((SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as churn_rate_percentage
FROM customer_status;

-- 9.	Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.

WITH usa_sales AS (
    SELECT 
        g.genre_id,
        g.name as genre_name,
        COUNT(il.invoice_line_id) as total_tracks_sold,
        ROUND(SUM(il.quantity * il.unit_price), 2) as total_revenue
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country = 'USA'
    GROUP BY g.genre_id, g.name
)

SELECT 
    genre_name,
    total_tracks_sold,
    total_revenue,
    ROUND((total_revenue / (SELECT sum(total_revenue) from usa_sales )) * 100, 2) as percentage_of_revenue
FROM usa_sales
ORDER BY total_revenue DESC;


-- Top artists within each genre in USA
WITH genre_artist_sales AS (
    SELECT 
        g.genre_id,
        g.name as genre_name,
        ar.artist_id,
        ar.name as artist_name,
        COUNT(il.invoice_line_id) as tracks_sold,
        SUM(il.quantity) as total_units,
        ROUND(SUM(il.quantity * il.unit_price), 2) as total_revenue,
        ROW_NUMBER() OVER (PARTITION BY g.genre_id ORDER BY SUM(il.quantity * il.unit_price) DESC) as artist_rank
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    WHERE i.billing_country = 'USA'
    GROUP BY g.genre_id, g.name, ar.artist_id, ar.name
)
SELECT 
    genre_name,
    artist_name,
    tracks_sold,
    total_units,
    total_revenue,
    ROUND((total_revenue / SUM(total_revenue) OVER (PARTITION BY genre_name)) * 100, 2) as genre_market_share
FROM genre_artist_sales
WHERE artist_rank <= 5  
ORDER BY genre_name, total_revenue DESC;


-- 10.	Find customers who have purchased tracks from at least 3 different genres

SELECT c.customer_id,
concat(c.first_name," ",c.last_name)as customer_name ,
count(distinct g.genre_id) genre_count
FROM customer c 
join invoice i 
on c.customer_id = i.customer_id
join invoice_line il 
on i.invoice_id=il.invoice_id
join track t 
on t.track_id=il.track_id
join genre g 
on g.genre_id=t.genre_id
group by c.customer_id,first_name
having genre_count>=3
order by genre_count desc;

-- 11.	Rank genres based on their sales performance in the USA


    SELECT 
        g.genre_id,
        g.name as genre_name,
        ROUND(SUM(il.quantity * il.unit_price), 2) as total_sales_revenue,
        rank() over(order by sum(il.quantity*il.unit_price) desc) genre_rank
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country = 'USA'
    GROUP BY g.genre_id, g.name
    ORDER BY  total_sales_revenue DESC;

-- 12.	Identify customers who have not made a purchase in the last 3 months

with not_in as(
SELECT c.customer_id
FROM customer c 
join invoice i 
on c.customer_id=i.customer_id
group by c.customer_id
having max(invoice_date)>=(select date_sub(max(invoice_date),interval 3 month) from invoice)
)
SELECT customer_id,
CONCAT(first_name," ",last_name) full_name
FROM customer 
WHERE customer_id not in(select * from not_in);

-- SUBJECTIVE QUESTION/ANSWERS

-- 1.	Recommend the three albums from the new record label that should be prioritised for advertising and promotion in the USA based on genre sales analysis.

-- Genre Sales Analysis
with top_genre as(
SELECT 
g.genre_id,
    g.name AS genre_name,
    SUM(il.quantity) AS tracks_sold
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id
ORDER BY tracks_sold DESC 
limit 3)

-- Finding Top latest albums in top genres 

select al.title album_title,g.name Genre,ar.name artist_name,
sum(il.quantity) quantity_sold
from album al
join track t 
on al.album_id =t.album_id
join genre g 
on g.genre_id=t.genre_id
join artist ar 
on al.artist_id=ar.artist_id
join invoice_line il 
on il.track_id=t.track_id
where g.genre_id in (select genre_id from top_genre) and al.album_id>=(select max(al.album_id)-100 from album)
group by g.name,al.title,ar.name
order by quantity_sold desc
limit 3;


-- 2.	Determine the top-selling genres in countries other than the USA and identify any commonalities or differences

-- GENRE performance in USA

SELECT 
    g.name AS genre_name,
    SUM(il.quantity) AS tracks_sold,
    ROUND(SUM(il.quantity * il.unit_price), 2) AS revenue,
    rank() over(order by sum(il.quantity* il.unit_price) desc) genre_rank
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id
ORDER BY tracks_sold DESC;

-- GENRE performance other than USA

SELECT 
    g.name AS genre_name,
    SUM(il.quantity) AS tracks_sold,
    ROUND(SUM(il.quantity * il.unit_price), 2) AS revenue,
    rank() over(order by sum(il.quantity* il.unit_price) desc) genre_rank
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country != 'USA'
GROUP BY g.genre_id
ORDER BY tracks_sold DESC;


-- 3.	Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ from those of new customers? What insights can these patterns provide about customer loyalty and retention strategies?

select min(invoice_date),max(invoice_date) from invoice;

select case 
       when year(i.invoice_date) in (2017,2018) then 'Long-Term'
       else 'New' end as customer_segment,
       count(distinct i.invoice_id) as total_orders,
       sum(total) as total_spent,
       round(avg(total),2) as avg_spent_value
from invoice i join customer c 
on i.customer_id = c.customer_id
group by customer_segment;

-- 4.

-- Genre Wise
with affinity_cte as(
select i.invoice_id,
	g.name genre_name, 
    a1.name artist_name,
    a.title from invoice i 
join invoice_line il 
on i.invoice_id = il.invoice_id
join track t 
on il.track_id = t.track_id
join genre g 
on t.genre_id = g.genre_id
join album a 
on t.album_id = a.album_id
join artist a1 
on a.artist_id = a1.artist_id
) 

select ac.genre_name genre_1,
 ac1.genre_name genre_2, 
count(*) as number_of_purchases
from affinity_cte ac 
join affinity_cte ac1 
on ac.invoice_id = ac1.invoice_id and ac.genre_name<ac1.genre_name
group by ac.genre_name, ac1.genre_name
order by number_of_purchases desc
limit 5;

-- Album Wise
with affinity_cte as(
select i.invoice_id,g.name as genre_name, a1.name as artist_name,a.title as album_name from invoice i 
join invoice_line il on i.invoice_id = il.invoice_id
join track t 
on il.track_id = t.track_id
join genre g 
on t.genre_id = g.genre_id
join album a 
on t.album_id = a.album_id
join artist a1 on a.artist_id = a1.artist_id
) 
select ac1.album_name as album_1, ac2.album_name as album_2, count(*) as number_of_purchases
from affinity_cte ac1 
join affinity_cte ac2 on ac1.invoice_id = ac2.invoice_id and ac1.album_name<>ac2.album_name
group by ac1.album_name, ac2.album_name
order by number_of_purchases desc
limit 5;

-- Artist Wise
with affinity_cte as(
select i.invoice_id,g.name as genre_name, a1.name as artist_name,a.title from invoice i 
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
join album a on t.album_id = a.album_id
join artist a1 on a.artist_id = a1.artist_id
) 
select ac1.artist_name as artist_1, ac2.artist_name as artist_2, count(*) as number_of_purchases
from affinity_cte ac1
join affinity_cte ac2 on ac1.invoice_id = ac2.invoice_id and ac1.artist_name<ac2.artist_name
group by ac1.artist_name, ac2.artist_name
order by number_of_purchases desc
limit 5;

-- 5

WITH latest_date AS (
    SELECT MAX(invoice_date) AS max_date FROM invoice
),
customer_detailed_metrics AS (
    SELECT 
        c.customer_id,
        c.country,
        COUNT(i.invoice_id) AS total_orders,
        SUM(i.total) AS total_revenue,
        MAX(i.invoice_date) AS last_purchase_date,
        MIN(i.invoice_date) AS first_purchase_date,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS customer_tenure_days,
        CASE 
            WHEN DATEDIFF((SELECT max_date FROM latest_date), MAX(i.invoice_date)) <= 180 THEN 'Active'
            ELSE 'Churned'
        END AS status
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
),
country_analysis AS (
    SELECT 
        country,
        -- Customer counts
        COUNT(customer_id) AS total_customers,
        SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_users,
        SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) AS churned_users,
        
        -- Order metrics
        SUM(total_orders) AS total_orders,
        ROUND(AVG(total_orders), 1) AS avg_orders_per_customer,
        
        -- Revenue metrics
        ROUND(SUM(total_revenue), 2) AS total_revenue,
        ROUND(SUM(total_revenue) / COUNT(customer_id), 2) AS avg_customer_value,
        ROUND(SUM(total_revenue) / SUM(total_orders), 2) AS avg_order_value,
        
        -- Tenure metrics
        ROUND(AVG(customer_tenure_days), 0) AS avg_customer_tenure_days,
        
        -- Churn rate
        ROUND(SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(customer_id), 2) AS churn_rate_percentage
    FROM customer_detailed_metrics
    GROUP BY country
)
SELECT 
    country,
    total_customers,
    active_users,
    churned_users,
    churn_rate_percentage,
    total_orders,
    avg_orders_per_customer,
    total_revenue,
    avg_customer_value,
    avg_order_value,
    concat(avg_customer_tenure_days,"  days") AS avg_tenure
FROM country_analysis
ORDER BY total_revenue DESC;

-- 6

WITH customer_risk AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.country,
        COALESCE(SUM(i.total), 0) as total_spent,
        CASE 
            WHEN COALESCE(SUM(i.total), 0) < AVG(COALESCE(SUM(i.total), 0)) OVER (PARTITION BY c.country) 
            THEN 'High Risk to Churn'
            ELSE 'Low Risk to Churn'
        END as churn_risk_segment
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.country
)
SELECT 
    country,
    COUNT(*) as total_customers,
    SUM(CASE WHEN churn_risk_segment = 'High Risk to Churn' THEN 1 ELSE 0 END) as high_risk_count,
    SUM(CASE WHEN churn_risk_segment = 'Low Risk to Churn' THEN 1 ELSE 0 END) as low_risk_count,
    ROUND(SUM(CASE WHEN churn_risk_segment = 'High Risk to Churn' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as high_risk_percentage
FROM customer_risk
GROUP BY country
ORDER BY high_risk_percentage DESC, high_risk_count DESC;

-- 7 

 -- Find the latest date in the dataset
WITH latest_date AS (
    SELECT MAX(invoice_date) as max_date FROM invoice
),
customer_analysis AS (
    SELECT 
        c.customer_id,
        c.first_name,
        -- Calculate customer metrics
        COUNT(i.invoice_id) as total_invoices,
        SUM(i.total) as lifetime_value,
        AVG(i.total) as avg_invoice_value,
        MIN(i.invoice_date) as first_purchase_date,
        MAX(i.invoice_date) as last_purchase_date,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) as tenure_days,
        -- Days since last purchase from latest date
        DATEDIFF((SELECT max_date FROM latest_date), MAX(i.invoice_date)) as days_since_last_purchase,
        -- Purchase frequency metrics
        COUNT(i.invoice_id) / NULLIF(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) / 30.0, 0) as invoices_per_month,
        -- Engagement metrics
        COUNT(il.track_id) as total_tracks_purchased,
        COUNT(DISTINCT il.track_id) as unique_tracks_purchased,
        COUNT(DISTINCT t.genre_id) as genres_purchased,
        COUNT(DISTINCT t.album_id) as albums_purchased,
        COUNT(DISTINCT a.artist_id) as artists_followed,
        CASE 
            WHEN DATEDIFF((SELECT max_date FROM latest_date), MAX(i.invoice_date)) > 90 
            THEN 'Churned' 
            ELSE 'Active' 
        END as churn_status
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN album a ON t.album_id = a.album_id
    GROUP BY c.customer_id, c.first_name
)

-- select round(avg(case when churn_status="Active" then lifetime_value else null end),2)as Active_lifetime_value,
-- round(avg(case when churn_status<>"Active" then lifetime_value else null end),2)as Churned_lifetime_value
--  from customer_analysis;
-- Show detailed customer breakdown
SELECT 
    customer_id,
    first_name,
    churn_status,
    total_invoices,
    ROUND(lifetime_value, 2) as lifetime_value,
    ROUND(avg_invoice_value, 2) as avg_invoice_value,
    tenure_days,
    days_since_last_purchase,
    ROUND(invoices_per_month, 2) as invoices_per_month,
    total_tracks_purchased,
    unique_tracks_purchased,
    genres_purchased,
    albums_purchased,
    artists_followed
FROM customer_analysis
ORDER BY churn_status, lifetime_value DESC;


-- 10
desc album;

ALTER TABLE album
ADD ReleaseYear INT NOT NULL;

desc album;


-- 11
SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) as number_of_customers,
    ROUND(AVG(customer_totals.total_spent), 2) as avg_amount_spent,
    ROUND(AVG(customer_totals.tracks_purchased), 2) as avg_tracks_per_customer
FROM customer c
JOIN (
    SELECT 
        i.customer_id,
        SUM(i.total) as total_spent,
        COUNT(il.track_id) as tracks_purchased
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY i.customer_id
) customer_totals ON c.customer_id = customer_totals.customer_id
GROUP BY c.country
ORDER BY avg_amount_spent DESC;


SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) as total_customers,
    COUNT(i.invoice_id) as total_invoices,
    SUM(i.total) as total_revenue,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer,
    ROUND(AVG(i.total), 2) as avg_invoice_value
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;






