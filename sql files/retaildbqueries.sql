use retail_db;

-- 3.1 SELECT, WHERE, ORDER BY (Warm-up)

-- 1.	List all customers from the “West” region, sorted alphabetically by CustomerName.

select customername , 
region
from customers 
where region="west" 
order by customername asc;

-- 2.	Find all products priced above ₹10,000, showing ProductName, Category and UnitPrice.

select productname,
 category ,
 unitprice from
 products
 where unitprice>10000;
 
 -- 3.	List all orders shipped using “Same Day” shipping, along with OrderDate and ShipDate.
 
select orderid , orderdate , shipdate, shipmode
from orders 
where shipmode ="same day"
order by orderdate desc;

-- 4.	Find all distinct product categories in the Products table.

select distinct category 
from products;

-- 3.2 Aggregate Functions + GROUP BY

-- 5.	For each Region, calculate total number of orders and total revenue (use OrderDetails).

select c.region , sum(od.quantity * od.unitprice * (1-od.discount)) as total_revenue from customers c
join 
orders o on 
c.customerid = o.customerid
join 
orderdetails od
on 
o.orderid = od.orderid
group by c.region;

-- 6.	For each ProductCategory, find the average discount given.

select p.category , avg(od.discount) as average_discount from products p
join 
orderdetails od 
on p.productid = od.productid
group by p.category;

-- 7.	For each CustomerSegment, find the total quantity of items purchased.

select c.customersegment ,
sum(od.quantity) as total_quantity 
from customers c 
join 
orders o 
on c.customerid = o.customerid 
join
orderdetails od 
on o.orderid = od.orderid
group by c.customersegment
order by total_quantity desc;

-- 8.	For each Employee, count the number of orders they have processed.

select e.EmployeeName , count(o.orderid) as count_of_orders from employees e
join orders o
on 
e.employeeid = o.employeeid
group by e.employeeid , e.employeename
order by count_of_orders desc;

-- 3.3 HAVING (Filtering Aggregated Data)

-- 9.List only the regions where total revenue exceeds ₹1,00,000 (use GROUP BY + HAVING).

select c.region , sum(od.quantity * od.unitprice *(1 - od.discount)) as total_revenue from customers c
join orders o 
on c.customerid = o.customerid
join 
orderdetails od 
on o.orderid = od.orderid 
group by c.region
having total_revenue > 100000
order by total_revenue desc;

-- 10.	List customers who have placed more than 5 orders.

select c.customername , count(od.orderid) as orders_placed from customers c
join 
orders o 
on c.customerid = o.customerid
join 
orderdetails od 
on o.orderid = od.orderid
group by c.customername
having orders_placed > 5
order by orders_placed desc;

-- 11.	List product categories where the average unit price is above ₹10,000.

select p.category ,avg(od.unitprice) as avg_unitprice from products p 
join 
orderdetails od 
on p.productid = od.productid
group by p.category
having avg_unitprice > 10000;

-- 3.4 Joins

-- 12.	INNER JOIN: Show OrderID, CustomerName, OrderDate and Region for every order.

select o.orderid , 
c.customername , 
o.orderdate , 
c.region from customers c
join 
orders o 
on c.customerid = o.customerid;

-- 13.	INNER JOIN (3+ tables): Show OrderID, CustomerName, ProductName, Quantity and line revenue for every order line.

select o.orderid , c.customername , p.productname ,od.quantity , od.quantity* od.unitprice*(1-discount) as TotalRevenue
 from orders o
inner join 
customers c on
o.customerid = c.customerid
inner join 
orderdetails od on
o.orderid = od.orderid
inner join
products p 
on 
od.productid = p.productid;

-- 14.	LEFT JOIN: List every employee and the number of orders they have handled, including employees with zero orders.

select *from employees e
left join 
orders o
on e.employeeid = o.employeeid;

-- 15.	SELF JOIN: List every employee along with their manager's name (using Employees.ManagerID).
with t1 as(
select employeeid ,
 employeename 
 from employees
 ), 
 t2 as (
 select employeeid,
 managerid,
 employeename 
 from 
 employees
 ) 
select t2.employeeid , 
t2.employeename , 
t1.employeename as manager_names 
from t2
left join
t1
on t2.managerid = t1.employeeid;

-- 3.5 Subqueries and Views

-- 16.	Find customers whose total spend is greater than the average total spend of all customers (subquery in WHERE).

SELECT 
c.CustomerID,
c.CustomerName,
SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSpending
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
JOIN OrderDetails od
ON o.OrderID = od.OrderID
WHERE
(
select sum(od2.Quantity * od2.UnitPrice * (1 - od2.Discount))
from Orders o2
join OrderDetails od2
on o2.OrderID = od2.OrderID
where o2.CustomerID = c.CustomerID
)
>
(select avg(CustomerTotal)
from
(
select
o3.CustomerID,
SUM(od3.Quantity * od3.UnitPrice * (1 - od3.Discount)) as CustomerTotal
from Orders o3
join OrderDetails od3
on o3.OrderID = od3.OrderID
group by o3.CustomerID
) as t
)
group by c.CustomerID, c.CustomerName;

-- 17.	Find the product that generated the highest total revenue (subquery or ORDER BY + LIMIT).

select
p.ProductID,
p.ProductName,
sum(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue
from Products p
join OrderDetails od
on p.ProductID = od.ProductID
group by p.ProductID, p.ProductName
having TotalRevenue = (
select 
max(productrevenue)
from 
(select
 od.ProductID,
SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS ProductRevenue 
from orderdetails od
group by od.ProductID) 
as productRevenue);

-- 18.	(Bonus, +5) Create a VIEW called vw_OrderSummary 
-- that joins Orders, OrderDetails, Customers and Products and 
-- exposes OrderID, CustomerName, ProductName, Quantity, Discount and LineRevenue. 
-- You will reuse this view as the data source for the Excel ETL stage in Part B.--

create view vw_OrderSummary as
select
o.OrderID,
c.CustomerName,
p.ProductName,
od.Quantity,
od.Discount,
od.Quantity * od.UnitPrice * (1 - od.Discount) as LineRevenue
from Orders o
join OrderDetails od
on o.OrderID = od.OrderID
join Customers c
on o.CustomerID = c.CustomerID
JOIN Products p
on od.ProductID = p.ProductID;

select *from vw_OrderSummary;
