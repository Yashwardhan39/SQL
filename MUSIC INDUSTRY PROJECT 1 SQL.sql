-- EASY LEVEL --

-- 1) Who is the senior most employee based on job title
Select * from employee 
order by levels desc limit 1

-- Which country has the most invoices
Select COUNT(*) AS C, BILLING_COUNTRY FROM INVOICE GROUP BY BILLING_COUNTRY 
ORDER BY C DESC LIMIT 1

-- 3) What are the top 3 values of total invoices
select * from invoice order by total desc limit 3

-- 4) Which city has the best customers? Throw a party in top 3 city we made the most money.

Select billing_city, sum(total) as invoice_total from invoice
group by billing_city
order by invoice_total desc limit 3

-- 5) Write a query to find our best customer
select customer.customer_id,customer.first_name,customer.last_name, sum (invoice.total) as total_amount_paid 
from customer 
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total_amount_paid desc
limit 1

-- MODERATE LEVEL --
-- 1) Write a query to return the email,first name,last name and genre of all
--rock music listners, return your list ordered alphabetically by email starting with A

SELECT DISTINCT EMAIL,FIRST_NAME,LAST_NAME 
FROM CUSTOMER
JOIN INVOICE ON CUSTOMER.CUSTOMER_ID=INVOICE.CUSTOMER_ID
Join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in (
select track_id from track 
join genre on track.genre_id=genre.genre_id
where genre.name LIKE 'Rock'
)
order by email


-- 2) Write a query that returns the artist 
-- name and total track count of the top 10 rock bands

select artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs
from track
Join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10

-- 3) Return song name and its time which are greater than the average song length --

SELECT NAME,MILLISECONDS FROM TRACK 
WHERE MILLISECONDS > (SELECT AVG(MILLISECONDS) AS AVG_TRACK_LENGTH
FROM TRACK)
ORDER BY MILLISECONDS DESC


-- ADVANCE LEVEL  --
-- 1) Find Amount spent by Each customer on Artists

with best_selling_artist AS (
SELECT ARTIST.ARTIST_ID AS ARTIST_ID, ARTIST.NAME AS ARTIST_NAME,
SUM(INVOICE_LINE.UNIT_PRICE*INVOICE_LINE.QUANTITY) AS AMOUNT_SPENT
from invoice_line
JOIN TRACK ON TRACK.TRACK_ID=INVOICE_LINE.TRACK_ID
JOIN ALBUM ON ALBUM.ALBUM_ID=TRACK.ALBUM_ID
JOIN ARTIST ON ARTIST.ARTIST_ID=ALBUM.ARTIST_ID
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)




SELECT C.CUSTOMER_ID, C.FIRST_NAME,C.LAST_NAME,BSA.ARTIST_NAME,
SUM(IL.UNIT_PRICE*IL.QUANTITY) AS AMOUNT_SPENT
FROM INVOICE I
JOIN CUSTOMER C ON C.CUSTOMER_ID=I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID=I.INVOICE_ID
JOIN track t on t.track_id=il.track_id
JOIN ALBUM ALB ON ALB.ALBUM_ID=T.ALBUM_ID
JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID=ALB.ARTIST_ID
Group by 1,2,3,4
order by 5 desc;


-- 2) Write a query that returns each country along with the top Genre.
-- for the countries where the maximum number of purchases is shared return all Genres

with popular_genre AS 
(
SELECT COUNT(INVOICE_LINE.QUANTITY) AS PURCHASES,CUSTOMER.COUNTRY,GENRE.NAME,GENRE.GENRE_ID,
ROW_NUMBER() OVER (PARTITION BY CUSTOMER.COUNTRY 
ORDER BY COUNT (INVOICE_LINE.QUANTITY) DESC) 
AS ROWNO FROM INVOICE_LINE
JOIN INVOICE ON INVOICE.INVOICE_ID=INVOICE_LINE.INVOICE_ID
JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID=INVOICE.CUSTOMER_ID
JOIN TRACK ON TRACK.TRACK_ID=INVOICE_LINE.TRACK_ID
JOIN GENRE ON GENRE.GENRE_ID=TRACK.GENRE_ID
GROUP BY 2,3,4
ORDER BY 2 ASC,1 DESC
)
SELECT * FROM POPULAR_GENRE WHERE ROWNO <= 1

-- 3) Write a query that determines the customer that has spent the most on music for each country

WITH customer_with_country as ( SELECT CUSTOMER.CUSTOMER_ID,FIRST_NAME,LAST_NAME,BILLING_COUNTRY,
SUM(TOTAL)AS TOTAL_SPENDING,ROW_NUMBER() OVER(PARTITION BY BILLING_COUNTRY ORDER BY SUM(TOTAL)DESC)AS 
ROWNO
FROM INVOICE
JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID=INVOICE.CUSTOMER_ID
GROUP BY 1,2,3,4
ORDER BY 4 ASC,5 DESC)

SELECT * FROM CUSTOMER_WITH_COUNTRY WHERE ROWNO<=1

-- KHATAM TATA GUD BYE --
