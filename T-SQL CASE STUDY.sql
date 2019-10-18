/*1. Month End Orders
Show all orders made on the last day of the month.Order by EmployeeID and OrderID */
---------------------------------------------------------------------------------------
Select EmployeeID,OrderId,OrderDate From Orders 
where OrderDate= EOMONTH(orderDate)
Order By EmployeeID,OrderID;
-- Using Date Diff and Date Add functions 
Select EmployeeID,OrderId,OrderDate From Orders 
where OrderDate= dateadd(month,1+datediff(month,0,orderDate),-1)
Order By EmployeeID,OrderID;
----------------------------------------------------------------------------------
/*2. Orders-Accidental Double Entry
One of the sales employee has double entered-line item on an order with different Product ID but same qauntity.She remembers
that the quantity was 60 or more. Show all the OrderIDs with line items that match this, in order of OrderID. */

Select OrderID,Quantity from [Order Details]
where Quantity >= 60
group by OrderID,Quantity
having Count(*)>1
-----------------------------------------------------------------------------------
/*3.Orders-Accidental Double Entry Details
we now want to show details of the order, for orders that match the above criteria*/
with Duplicates as(
Select OrderID,Quantity from [Order Details]
where Quantity >= 60
group by OrderID,Quantity
having Count(*)>1)
select OrderID,productID,Quantity,Discount from [Order Details]
where OrderID in (Select OrderID from Duplicates)
order by OrderID,quantity;
----------------------------------------------------------------------------------------------
/*4.First Order in each country 
Query ShipCountry,CustomerID,orderID,orderDate should be first order from that country */
with OrderByCountry as
(
SELECT ShipCountry,CustomerID,OrderID,OrderDate=convert(date,OrderDate),
RowNumberPerCountry= row_number() over (Partition by ShipCountry 
Order By Shipcountry,OrderID)from Orders
)
select shipCountry,CustomerID,orderID,OrderDate from OrderByCountry 
where RowNumberPerCountry=1
order by ShipCountry;
-------------------------------------------------------------------------------------------------
/*5.Late orders By employees 
Some salespeople have more orders arriving late than others.Which salespeople have the most orders arriving late? */
Select Employees.EmployeeID,LastName,TotalLateOrders = Count(*)  From Orders Join Employees on Employees.EmployeeID = Orders.EmployeeID 
Where RequiredDate <= ShippedDate 
Group By Employees.EmployeeID,Employees.LastName 
Order by TotalLateOrders desc 
--------------------------------------------------------------------------------------------------
/*6.Late Orders vs Total Orders 
The VP of sales needs to compare late orders against the total number of orders per salesperson. 
Return results 
*/
;With LateOrders as 
( Select EmployeeID,TotalOrders = Count(*) From Orders 
Where RequiredDate <= ShippedDate 
Group By EmployeeID ) 
,AllOrders as (Select EmployeeID,TotalOrders = Count(*) From Orders 
Group By EmployeeID) 
Select Employees.EmployeeID,LastName,AllOrders = AllOrders.TotalOrders,LateOrders = LateOrders.TotalOrders 
From Employees Join AllOrders on AllOrders.EmployeeID = Employees.EmployeeID     
Join LateOrders on LateOrders.EmployeeID = Employees.EmployeeID 
-----------------------------------------------------------------------------------------------------------------
/* 7. High Value Customers
Send all of our high-value customers a special VIP gift. 
We're defining high-value customers as those who've made at least 1 order with a total value 
(not including the discount) equal to $10,000 or more. We only want to consider orders made in the year 2016. */

Select Customers.CustomerID,Customers.CompanyName,Orders.OrderID,TotalAmount = (Quantity * UnitPrice) From Customers     
join Orders on Orders.CustomerID = Customers.CustomerID
join [Order Details] on Orders.OrderID = [Order Details].OrderID 
Where OrderDate >= '20160101'and OrderDate  < '20170101'
group by Customers.CustomerID,Customers.CompanyName,Orders.OrderID having SUM(Quantity * UnitPrice)>10000
order by TotalAmount;
 -------------------------------------------------------------------------------------------------------------------------
 /* 8. High freight charges - last year 
 get the three ship countries with the highest average freight charges.use the last 12 months of order data, using 
 as the end date the last OrderDate in Orders */
Select TOP (3)ShipCountry,AverageFreight = Avg(freight) From Orders
Where OrderDate >= Dateadd(yy, -1, (Select max(OrderDate) from Orders))
Group by ShipCountry Order by AverageFreight desc;

