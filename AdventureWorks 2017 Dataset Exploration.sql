/*
AdventureWorks 2017 Dataset Exploration 
Showcasing SQL skills I have learned to date, with commants.

Skills used: ISNULL FUNCTION, Convert Fuction, Round Function, SUBSTRING Function, 
DATE and Time Functions, Subqueries, IN and NOT IN Operators,NOT EXISTS and EXISTS,
INNER JOIN, OUTER JOIN, CROSS JOIN, OUTER JOIN, Aggregate Functions, GROUP BY Clause,
HAVING Clause, GROUP BY CUBE, ROLLUP, Temporary Tables, CREATE TABLE, CTE, DYANMIC SQL,
Windowing, T-SQL Programmimg.
*/

----ISNULL FUNCTION---
/*The ISNULL function has be untizied to replace any NULL values in the MiddleName column with 
an empty string, therefor no error will acure when casting the Fullname column.*/

----Example 1---
SELECT BusinessEntityId, FirstName, MiddleName, LastName,
       FirstName + ISNULL(' ' + MiddleName, '') + ' ' + LastName AS FullName 
FROM Person.Person

--- Empty String is not a NULL value. '' ---
--- + ' ' + Creates a gap between the names----

----Example 2---

SELECT ProductID, ISNULL(Color, 'No Color'), Name
FROM Production.Product;

----Example 3---
SELECT AddressID, 
	AddressLine1 + ISNULL(' ' + AddressLine2, '') + ', ' + City + ' ' + PostalCode as FullAddress
	FROM Person.Address
WHERE City = 'London';


----CONVERT Fuction---
/*CONVERT function converts one data type to another*/

--- Example 1---

SELECT SalesOrderID, TotalDue,
	CONVERT(decimal(10,2), TotalDue) AS TotalDue2,
	CONVERT(int, TotalDue) AS TotalDue3
From Sales.SalesOrderHeader;

--- Example 2---

SELECT SalesOrderID,  
	'Total Due: $' + CONVERT(varchar(10), TotalDue) AS TotaldueString
From Sales.SalesOrderHeader;

---Example 3--- 

Select Name, ListPrice,
	Name + ' - $' + CONVERT(varchar(10), ListPrice)
from Production.Product
Where ListPrice > 0;

---Example 4--- 
---The CONVERT function can be used to change the format of a date--

SELECT SalesOrderID, OrderDate,
    CONVERT(VARCHAR,OrderDate,0) AS "0", 
	CONVERT(VARCHAR,OrderDate,1) AS "1",
    CONVERT(VARCHAR,OrderDate,2) AS "2"
FROM Sales.SalesOrderHeader;

---Round Function---

/*The ROUND function is used here to round numeric value to 2 decimal places (SubTotal_2)
and 0 decimal places (SubTotal_3).*/

SELECT SalesOrderID, SubTotal, 
	ROUND (SubTotal,2) AS SubTotal_2,
	ROUND (SubTotal,0) AS SubTotal_3
FROM Sales.SalesOrderHeader

----SUBSTRING FUNCTION---

/*
SUBSTRING is used to extract a substring with the start and end of the string difined numerically
*/

SELECT SUBSTRING(FirstName,1,1) AS Initial, LastName
FROM Person.Person
ORDER BY LastName;

---DATE and Time Functions---
/*
DATEADD adds or subtracks a specified time from a given date
*/

SELECT SalesOrderID, OrderDate,
	DATEADD(day,3,OrderDate) AS PromisedShipDate
FROM Sales.SalesOrderHeader;

/*
DATEDIFF function returns the difference between the dates on an
order two given dates. 
*/
----Example 1---
----shows number of days between OrderDate and ShipDate---

SELECT SalesOrderID, OrderDate, ShipDate,
	DATEDIFF(day, OrderDate, ShipDate) as NumberOfDays
FROM Sales.SalesOrderHeader

----Example 2---
/*shows number of year,month,days,hours between OrderDate 
and todays date GETDATE()*/

SElECT OrderDate,
	DATEDIFF(year,OrderDate,GETDATE()) as YearDiff,
	DATEDIFF(month,OrderDate,GETDATE()) as monthDiff,		
	DATEDIFF(day,OrderDate,GETDATE()) as dayDiff,
	DATEDIFF(hour,OrderDate,GETDATE()) as HourDiff
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43768

/*
DATENAME function returns the part of the date specified
*/

SElECT SalesOrderID, OrderDate,
	DATENAME(year,OrderDate) as OrderYear,
	DATENAME(month,OrderDate) as OrderMonth,
	DATENAME(day,OrderDate) as OrderDay,
	DATENAME(weekday,OrderDate) as OrderWeekDay
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 54321

/*
DATEPART also returns the part of the date specified
as a integer value
*/

SELECT SalesOrderID, OrderDate,
	DATEPART(year, OrderDate) as OrderYear,
	DATEPART(month, OrderDate) as OrderMonth
FROM Sales.SalesOrderHeader

----Subquery---
/*
Subquery is a nested query is an query inside another query
*/
---Example 1---
---Returns the the only products whose list price is greater than the average list price---

SELECT  ProductID, Name, ListPrice
FROM Production.Product
WHERE ListPrice>(SELECT AVG(ListPrice) From Production.Product)

---Example 2---
SELECT SalesOrderID, OrderDate, TerritoryID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TerritoryID = (SELECT TerritoryID FROM Sales.SalesTerritory WHERE NAME='United Kingdom');

----Subqueries with IN and NOT IN Operators-----

----IN---
---Example 1---
SELECT ProductID, Name, ListPrice
FROM Production.Product
WHERE ProductID IN (SELECT ProductID FROM Sales.SalesOrderDetail);

---Example 2---
SELECT CustomerID, PersonID, TerritoryID, AccountNumber
FROM Sales.Customer
WHERE CustomerID IN (SELECT CustomerID FROM Sales.SalesOrderHeader Where TerritoryID = 4);

----NOT IN------
----Example 1---
SELECT CustomerID, PersonID, TerritoryID, AccountNumber
FROM Sales.Customer
WHERE CustomerID NOT IN (SELECT CustomerID FROM Sales.SalesOrderHeader Where TerritoryID = 4);

----Example 2---
SELECT  BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE BusinessEntityID NOT IN (SELECT PersonID FROM Sales.Customer WHERE PersonID IS NOT NULL);

----NOT EXISTS and EXISTS---
/*
The EXISTS predicate accepts a subquery as input and will return true when the 
subquery returns at least one row and false otherwise
*/
----Example 1---
/*
this query returns a list of persons from the Person.Person table who exists 
within the Sales.Customer table
*/
SELECT  BusinessEntityID, FirstName, LastName
FROM Person.Person AS p
WHERE EXISTS(SELECT PersonID FROM Sales.Customer AS c WHERE c.PersonID = p.BusinessEntityID)

----Example 2---
/*
This query returns a list of persons who are not in the Sales.Customer table.
*/
SELECT  BusinessEntityID, FirstName, LastName
FROM Person.Person AS p
WHERE NOT EXISTS(SELECT PersonID FROM Sales.Customer AS c WHERE c.PersonID = p.BusinessEntityID);

----INNER JOIN---
/*
INNER JOIN returns all the columns in both tables and returns only the row which have matching values
within the joined column 
*/
----Example 1---
SELECT pod.PurchaseOrderID, pod.ProductID, p.Name, p.ListPrice, pod.OrderQty
FROM Purchasing.PurchaseOrderDetail AS pod
INNER JOIN Production.Product AS p ON pod.ProductID = p.ProductID
WHERE pod.PurchaseOrderID = 8;

----Example 2---
/*
INNER JOIN with more than two tables
*/
SELECT soh.SalesOrderID, soh.OrderDate, p.ProductID, p.Name
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE soh.SalesOrderID =44098

---LEFT OUTER JOIN---
/*
OUTER JOIN can retrieve all the rows from the table along with any rows that match
from the over table. 
There is three ways of using an OUTER JOIN RIGHT,LETF and FULL.
*/

SELECT h.JobTitle, h.BirthDate, b.FirstName, b.LastName, b.BusinessEntityID
FROM HumanResources.Employee AS h
LEFT OUTER JOIN Person.Person as b on h.BusinessEntityID= b.BusinessEntityID

----CROSS JOIN---
/*
The CROSS JOIN produces a result set which is the number of rows in the first table
multipilied by the number of rows in the second table if no WHERE clausse is used 
along with the CROSS JOIN. 
*/
SELECT p.ProductID, p.Name, p.ListPrice, c.CustomerID, c.AccountNumber
FROM Production.Product AS p
CROSS JOIN Sales.Customer as c
ORDER BY ProductID, CustomerID;

--------Aggregate Functions---
/*
Aggergate Functions can be used to summarize data in queries.
These Function operate on sets of values from multiple rows all at once.
*/
SELECT COUNT(*) AS CountOfRows,
	MAX(TotalDue) AS MaxTotal,
	Min(TotalDue) as MinToyal,
	SUM(TotalDue) as SumOfTotal,
	AVG(TotalDue) as AvgTotal
FROM Sales.SalesOrderHeader;

----Example 2---

SELECT COUNT(*) AS ProductPrice,
	MAX(ListPrice) AS MaxTotal,
	Min(ListPrice) as MinToyal,
	AVG(ListPrice) as AvgTotal
FROM Production.Product;

-----GROUP BY Clause------
/*
GROUP BY is used to group data so the aggregate functions apply to groups
of values instead of the entire result set.
*/
----Example 1---

SELECT CustomerID, SUM(TotalDue) AS Total
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

----Example 2---

SELECT CountryRegionName, COUNT(BusinessEntityID) AS NumberOfCustomers
FROM Sales.vIndividualCustomer
GROUP BY CountryRegionName;

----Example 3---

SELECT YEAR(OrderDate) AS OrderYear, Count(*) AS NumerOfOrders
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)  
ORDER BY YEAR(OrderDate);

----Example 4---

SELECT MONTH(OrderDate) AS OrderMonth,
	SUM(SubTotal) AS Total
FROM Sales.SalesOrderHeader
WHERE YEAR (OrderDate) = 2012
GROUP BY MONTH(OrderDate)
ORDER BY OrderMonth;

----Example 5---

SELECT s.ProductID, p.Name as ProductName,
	SUM(LineTotal) as SaleTotal
FROM Sales.SalesOrderDetail as s
LEFT JOIN Sales.SalesOrderHeader AS h on s.SalesOrderID = h.SalesOrderID
LEFT JOIN Production.Product AS p on s.ProductID = p.ProductID
GROUP BY s.ProductID, p.Name
Order BY p.Name;

----Exammple 6---

SELECT h.SalesOrderID, p.FirstName, p.LastName,
	SUM(TotalDue) as SalesAmount
FROM Sales.SalesOrderHeader as h
LEFT JOIN  Person.Person  as p on p.BusinessEntityID = h.SalesPersonID
GROUP BY h.SalesOrderID, p.FirstName, p.LastName;

----Having Clause---
/*
HAVING CLAUSE can be used to filter rows bases on an aggregate expression.
*/
----Example 1---

SELECT CustomerID, SUM(TotalDue) AS Total
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING SUM(TotalDue) >= 50000;

---Example 2---

SELECT SalesOrderID, COUNT(*) AS CountOfRows
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(*) > 10
ORDER BY CountOfRows;

----GROUP BY CUBE---
/*
GROUP BY CUBE creates groups for all possible combinations of columns
*/
----Example 1---

SELECT CountryRegionName, SUM(SalesYTD) as SalesTotal
FROM Sales.vSalesPerson
Group By Cube(CountryRegionName);

----Example 2---

SELECT CountryRegionName, City, SUM(SalesYTD) as SalesTotal
FROM Sales.vSalesPerson
Group By Cube(CountryRegionName, City);

----ROLLUP---
/*
Group By ROLLUP creates a group for each combination of columns expressions
*/
----Example 1---

SELECT CountryRegionName, SUM(SalesYTD) as SalesTotal
FROM Sales.vSalesPerson
Group By ROLLUP(CountryRegionName);

----Example 2---

SELECT CountryRegionName, City, SUM(SalesYTD) as SalesTotal
FROM Sales.vSalesPerson
Group By ROLLUP(CountryRegionName, City);

----Temporary Table---
/*
Creating Temporary Tables provides a powerful tool for 
managing complex data queries and optimizing query performance
*/

CREATE TABLE #CustomerTotalDue(
	CustomerID int,
	TotalDue money
);
----Loading Data---
INSERT INTO  #CustomerTotalDue
SELECT CustomerID, SUM(TotalDue) as Total
from Sales.SalesOrderHeader
group by CustomerID

SELECT * FROM #CustomerTotalDue;

DROP TABLE #CustomerTotalDue;

---CREATE TABLE----

CREATE TABLE #CustomerInfo(
CustomerID int,
FirstName varchar(50),
LastNme varchar(50),
CountOfSales int,
SumOfTotalDue money
); 
INSERT INTO #CustomerInfo
SELECT C.CustomerID, FirstName, LastName, COUNT(*), SUM(TotalDue) 
FROM Sales.Customer AS C
INNER JOIN Person.Person as P ON  C.CustomerID = P.BusinessEntityID
INNER JOIN  Sales.SalesOrderHeader as SOH ON C.CustomerID = SOH.CustomerID
Group BY C.CustomerID, FirstName, LastName

SELECT * 
FROM #CustomerInfo

DROP TABLE #CustomerInfo

----CTE-----
/*
CTE's offers a logical and easily readable approach to write
queries that can break the complex queries down to a series of logical steps.
Helps to improve the readability of the query and achieve more complex result sets.
*/

WITH Simple_CTE
AS
(
SELECT soh.SalesOrderID, soh.OrderDate, p.ProductID, p.Name
FROM Sales.SalesOrderHeader AS soh
INNER JOIN  Sales.SalesOrderDetail as sod ON soh.salesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p ON sod.ProductID =p.ProductID
)
SELECT *
FROM Simple_CTE WHERE SalesOrderID = 60001

----DYANMIC SQL---
/*
Dynamic SQL allows you to create SQL statements based on user input
or other dynamic factors, which can make your database applications 
more flexible and adaptable.
*/
DECLARE @sql nvarchar(1000)
DECLARE @pId varchar(50)

SET @pId = '518'
SET @sql = 'SELECT ProductID, Name, Listprice FROM
Production.Product WHERE ProductID = ' + @pId
---PRINT @sql---
EXEC (@sql)

----Windowing---
/*
Window functions are commonly used in analytical queries and reporting, 
where you need to calculate running totals, rankings, and other metrics
over subsets of data. By using window functions, you can avoid the need
to use self-joins or subqueries, which can be more complex and less efficient.
*/
---Example--
SELECT SalesOrderID, CustomerID,
	   ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNum,
	   RANK() OVER(ORDER BY CustomerID) AS RankNum,
	   DENSE_RANK() OVER(ORDER BY CustomerID) AS DenseRankNum
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 11000 AND 11200
ORDER BY CustomerID;

----T-SQL Programmimg---

/*
T-SQL Programmimg is an extension of the standard SQL language,
that provides additional programming constructs.
*/
---Example--
DECLARE @result INT

SET @result = 100

IF (@result > 75)
	PRINT'I have really enjoy seeing the skills you have displayed, thanks'
ELSE 
	PRINT'Sorry, I did not enjoy this'