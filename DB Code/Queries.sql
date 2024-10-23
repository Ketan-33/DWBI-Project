--Query 1
--"Update the Store Table so that all stores have opening date on or after 1-Jan-2014, Populate random dates."

SELECT * FROM DIMSTORE;

UPDATE DIMSTORE 
SET STOREOPENINGDATE = DATEADD(DAY, UNIFORM(0, 3800, RANDOM()), '2014-01-01');

SELECT DATEDIFF(DAY, '2014-01-01', CURRENT_DATE) 

SELECT DATEADD(DAY, UNIFORM(0, 3800, RANDOM()), '2014-01-01');

COMMIT;

--Query 2
--"Update the Store Table so that stores with storied between 91 and 100 are opened in the last 12 months."

SELECT * FROM DIMSTORE where storeid between 91 and 100;
UPDATE DIMSTORE SET STOREOPENINGDATE =DATEADD (DAY, UNIFORM (0,360, RANDOM()),'2023-07-30');

SELECT DATEADD (year.-1.current_date)
select DATEADD (DAY, UNIFORM (0,360, RANDOM()).'2023-07-30')
COMMIT;



--Query 3
--Update the Customer Table so that all customers are at least 12 years old, Any customer that is less than 12 years old Subtract 12 years from there DOB.


SELECT * FROM DIMCUSTOMER where dateofbirth >=dateadd(year,-12, current_date);
UPDATE DIMCUSTOMER set dateofbirth =dateadd(year, -12, dateofbirth) where dateofbirth >= dateadd(year, -12, current_date); 
commit;


--Query 4
--We may have some orders in the Fact Table that may have a DatelD which contains a value even before the store was opened.


update FACTORDERS f
set f.dateid =
r.dateid from
(select orderid,d.dateid from
(
SELECT orderid,
Dateadd(day,
DATEDIFF (DAY, S.STOREOPENINGDATE, CURRENT_DATE)* UNIFORM (1,10, RANDOM())*.1,S.STOREOPENINGDATE) as new_Date
FROM FACTORDERS F
JOIN DIMDATE D ON F.DATEID=D.DATEID
JOIN DIMSTORE S ON F.STOREID=S.STOREID
WHERE D.DATE<S.STOREOPENINGDATE) o join dimdate d on o.new_Date=d.date)r where f.orderid=r.orderid

COMMIT;

--Query 5
--List customers who havent placed an order in last 30 days

SELECT * 
FROM dimcustomer 
WHERE customerid NOT IN (
    SELECT DISTINCT c.Customerid 
    FROM dimcustomer c
    JOIN factorders f ON c.customerid = f.customerid
    JOIN dimdate d ON f.dateid = d.dateid
    WHERE d.date >= DATEADD(month, -1, CURRENT_DATE)
);

COMMIT;

--Query 6
--Find customers who have ordered products from more than three categories in last 6 months
WITH base_data AS (
    SELECT O.CUSTOMERID, P.CATEGORY 
    FROM FACTORDERS O
    JOIN DIMDATE D ON O.DATEID = D.DATEID
    JOIN DIMPRODUCT P ON O.PRODUCTID = P.PRODUCTID
    WHERE D.DATE >= DATEADD(MONTH, -6, CURRENT_DATE)
    GROUP BY O.CUSTOMERID, P.CATEGORY
)
SELECT CUSTOMERID
FROM base_data
GROUP BY CUSTOMERID
HAVING COUNT(DISTINCT CATEGORY) > 3;

COMMIT;

--Query 7
--Get monthly total sales for current year

SELECT MONTH, SUM(TOTALAMOUNT) AS MONTHLY_AMOUNT
FROM FACTORDERS O
JOIN DIMDATE D ON O.DATEID = D.DATEID
WHERE D.YEAR = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY MONTH
ORDER BY MONTH;

COMMIT;

--Query 8
--Calculate the total sales

SELECT SUM(quantityordered * unitprice)
FROM factorders o
JOIN dimproduct p ON o.productid = p.productid;

COMMIT;

--Query 9
--List the customer who has placed maximum number of orders till date

WITH base_data AS (
    SELECT customerid, COUNT(orderid) AS order_count 
    FROM factorders f 
    GROUP BY customerid
),
order_rank_data AS (
    SELECT b.*, ROW_NUMBER() OVER (ORDER BY order_count DESC) AS order_rank 
    FROM base_data b
)
SELECT customerid, order_count 
FROM order_rank_data 
WHERE order_rank = 1;

COMMIT;

--Query 10
--Top 3 brands based on sales from last 3 years
WITH brand_sales AS (
    SELECT brand, SUM(totalamount) AS total_sales 
    FROM factorders f 
    JOIN dimdate d ON f.dateid = d.dateid 
    JOIN dimproduct p ON f.productid = p.productid 
    WHERE d.date >= DATEADD(year, -1, current_date)
    GROUP BY brand
),
brand_sales_rank AS (
    SELECT s.*, ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS sales_rank 
    FROM brand_sales s
)
SELECT * 
FROM brand_sales_rank 
WHERE sales_rank <= 3;

COMMIT;