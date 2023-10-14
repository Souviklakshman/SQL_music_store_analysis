--Who is the  most  senior employee based on Job title

select * from employee
order by levels desc
limit 1;

--Which Country have most invoice?

select count(*) as total, billing_country from invoice
group by 2
order by total desc;

--What are top 3 values of the total invoice?

 select total from invoice 
 order by total desc
 limit 3;
 
 --Which city has the best customers? We would like to throw a promotional music festival in the city we made the most money.
 
 
 select sum(total) as invoice_total, billing_city 
 from invoice
 group by 2
 order by 1 desc;
 
 --Who is the best customers? The customer who has spent most money will be decleared as best customer;

 select * from customer
 select c.customer_id,c.first_name,sum(i.total) as total from customer as c 
 join invoice as i
 on i.customer_id = c.customer_id
 group by 1
 order by total desc
 limit 1
 

--Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 


SELECT DISTINCT email,first_name, last_name
FROM customer as c
JOIN invoice as i  ON c.customer_id = i.customer_id
JOIN invoice_line as il ON i.invoice_id = il.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track as t
	JOIN genre as g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY email;


--Let's invite the top 10 artists who have written the most rock music in our dataset. 


SELECT a.artist_id, a.name,COUNT(a.artist_id) AS number_of_songs
FROM track t
JOIN album al ON al.album_id = t.album_id
JOIN artist a ON a.artist_id = al.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

 --All the track names that have a song length longer than the average song length. 

select * from track
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY 2 DESC;



--Find how much amount spent by each customer on artists? 


WITH best_selling_artist AS (
	SELECT a.artist_id AS artist_id, a.name AS artist_name, SUM(il.unit_price*il.quantity) AS total_sales
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album al ON al.album_id = t.album_id
	JOIN artist a ON a.artist_id = al.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--We want to find out the most popular music Genre for each country.

WITH popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo 
    FROM invoice_line il
	JOIN invoice i ON i.invoice_id = il.invoice_id
	JOIN customer c ON c.customer_id = i.customer_id
	JOIN track t ON t.track_id = il.track_id
	JOIN genre g ON g.genre_id = t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

--the customer that has spent the most on music for each country. 


WITH Customter_with_country AS (
		SELECT c.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice i
		JOIN customer c ON c.customer_id = i.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


