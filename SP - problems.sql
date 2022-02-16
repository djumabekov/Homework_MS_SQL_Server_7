---------------------------------------------------------------------
-- Stored procedures (SP)
---------------------------------------------------------------------

USE Northwind;
GO


--Problem 
--Создайте и протестируйте хранимую процедуру GetMaxMin, вычисляющую минимальное и максимальное значения из трех переданных ей вещественных чисел.

USE Northwind;
GO

DROP PROC IF EXISTS dbo.GetMaxMin;
GO
CREATE PROC dbo.GetMaxMin
  @a AS FLOAT,
  @b AS FLOAT,
  @c AS FLOAT,
  @sum AS FLOAT OUTPUT,
  @diff AS FLOAT OUTPUT
AS BEGIN
	SET @sum = @a + @b + @c; 
	SET @diff = @a - @b - @c;
END	
GO

DECLARE  @s FLOAT, @d FLOAT;

EXEC dbo.GetMaxMin 1, 2, 3, @s OUTPUT, @d OUTPUT;
--EXEC dbo.uspSumDifference 1, 2, @s OUT, @d OUT;

SELECT @s;
SELECT @d;
PRINT @s;
PRINT @d;

--Problem 
--Создайте и протестируйте хранимую процедуру, возвращающую наименьший и наибольшие года сделанных заказов.

USE Northwind;
GO

DROP PROC IF EXISTS dbo.GetMaxMinYear;
GO
CREATE PROC dbo.GetMaxMinYear
  @min AS DATE OUTPUT,
  @max AS DATE OUTPUT
AS BEGIN
	SET @min  = (SELECT Min(OrderDate) FROM Orders); 
	SET @max  = (SELECT Max(OrderDate) FROM Orders); 
END	
GO

DECLARE  @min DATE, @max DATE;

EXEC dbo.GetMaxMinYear @min OUTPUT, @max OUTPUT;

SELECT @min;
SELECT @max;
PRINT @min;
PRINT @max;
 

--Problem
--Создайте хранимую процедуру, возвращающую количество и общую сумму заказов по базе.
 
USE Northwind;
GO

DROP PROC IF EXISTS dbo.GetCountAndSumOrders;
GO
CREATE PROC dbo.GetCountAndSumOrders
  @count AS INT OUTPUT,
  @sum AS Money OUTPUT
AS BEGIN
	SET @count  = (SELECT DISTINCT Count(OrderID) FROM OrderDetails); 
	SET @sum  = (SELECT SUM(UnitPrice*Quantity*(1-Discount)) FROM OrderDetails); 
END	
GO

DECLARE  @count INT, @sum Money;

EXEC dbo.GetCountAndSumOrders @count OUTPUT, @sum OUTPUT;

SELECT @count  AS 'Orders';
SELECT @sum  AS 'SUM';
PRINT @count;
PRINT @sum;

--Problem
--Создайте хранимую процедуру, возвращающую количество и общую сумму заказов для заданного года.

USE Northwind;
GO

DROP PROC IF EXISTS dbo.GetCountAndSumOrdersByYear;
GO
CREATE PROC dbo.GetCountAndSumOrdersByYear
  @fromdate  AS DATETIME = '19980101',
  @todate   AS DATETIME = '19981231',
  @count AS INT OUTPUT,
  @sum AS Money OUTPUT
AS BEGIN
	SET @count  = (SELECT COUNT(O.OrderID) AS 'TotalOrders' FROM Orders AS O  
		   --JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID  		
		   WHERE O.OrderDate >= @fromdate  AND O.OrderDate < @todate
		); 

   SET @sum  = (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS 'Sum' FROM OrderDetails AS OD  
		   JOIN Orders AS O ON O.OrderID = OD.OrderID  
		   WHERE O.OrderDate >= @fromdate  AND O.OrderDate < @todate
		); 

END	
GO

DECLARE @fromdate DATETIME,  @todate DATETIME,  @count INT, @sum Money;

EXEC dbo.GetCountAndSumOrdersByYear '19980101', '19981231', @count OUTPUT, @sum OUTPUT;

SELECT @count  AS 'Orders';
SELECT @sum  AS 'SUM';

PRINT @count;
PRINT @sum;


--Problem
--Создайте хранимую процедуру, возвращающую общую количество и сумму заказов для покупателя с заданным CustomerID.

USE Northwind;
GO

DROP PROC IF EXISTS dbo.GetCountAndSumOrdersByCustomerID;
GO
CREATE PROC dbo.GetCountAndSumOrdersByCustomerID
  @custid  AS NVARCHAR(5) = 'TORTU',
  @count AS INT OUTPUT,
  @sum AS Money OUTPUT
AS BEGIN
	SET @count  = (SELECT COUNT(O.OrderID) AS 'TotalOrders' FROM Orders AS O  
		   --JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID  		
		   WHERE O.CustomerID = @custid 
		); 

   SET @sum  = (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS 'Sum' FROM OrderDetails AS OD  
		   JOIN Orders AS O ON O.OrderID = OD.OrderID  
		   WHERE O.CustomerID = @custid 
		); 

END	
GO

DECLARE @custid NVARCHAR(5), @count INT, @sum Money;

EXEC dbo.GetCountAndSumOrdersByCustomerID 'TORTU', @count OUTPUT, @sum OUTPUT;

SELECT @count  AS 'Orders';
SELECT @sum  AS 'SUM';

PRINT @count;
PRINT @sum;


--Problem
--Создайте хранимую процедуру, возвращающую количество покупателей:
--сделавших заказ (dbo.usp_NumCustomersWithOrders;
--без заказов (dbo.usp_NumCustomersWithoutOrders).

--сделавших заказ (dbo.usp_NumCustomersWithOrders;
USE Northwind;
GO

DROP PROC IF EXISTS dbo.usp_NumCustomersWithOrders;
GO
CREATE PROC dbo.usp_NumCustomersWithOrders
  @count AS INT OUTPUT
AS BEGIN
	SET @count  = (SELECT  COUNT(DISTINCT O.CustomerID) AS 'TotalCustomersWithOrders'  
	  FROM Orders AS O  
		   --JOIN Customers AS O ON C.CustomerID = O.CustomerID  
	); 
END	
GO

DECLARE @count INT;

EXEC dbo.usp_NumCustomersWithOrders @count OUTPUT;

SELECT @count  AS 'TotalCustomersWithOrders';

PRINT @count;

--без заказов (dbo.usp_NumCustomersWithoutOrders).
USE Northwind;
GO

DROP PROC IF EXISTS dbo.usp_NumCustomersWithoutOrders;
GO
CREATE PROC dbo.usp_NumCustomersWithoutOrders
  @count AS INT OUTPUT
AS BEGIN
	SET @count  = (SELECT COUNT(DISTINCT C.CustomerID) AS 'TotalCustomersWithoutOrders'  
	  FROM Customers  AS C   
		   LEFT JOIN Orders AS O ON C.CustomerID = O.CustomerID  
		   WHERE NOT EXISTS (SELECT O.CustomerID FROM Orders WHERE C.CustomerID = O.CustomerID )
	); 
END	
GO

DECLARE @count INT;

EXEC dbo.usp_NumCustomersWithoutOrders @count OUTPUT;

SELECT @count  AS 'TotalCustomersWithoutOrders';

PRINT @count;

--Problem
--Создайте хранимые процедуры:
--dbo.usp_Customer_TotalSum -  по заданному CustomerId покупателя возвращающую количество и общую сумму его покупок;
--dbo.usp_Customer_Year_TotalSum -  по заданному CustomerId покупателя возвращающую количество и общую сумму его покупок за данный год.

--dbo.usp_Customer_TotalSum -  по заданному CustomerId покупателя возвращающую количество и общую сумму его покупок;
USE Northwind;
GO

DROP PROC IF EXISTS dbo.usp_Customer_TotalSum;
GO
CREATE PROC dbo.usp_Customer_TotalSum
  @custid  AS NVARCHAR(5) = 'TORTU',
  @count AS INT OUTPUT,
  @sum AS Money OUTPUT
AS BEGIN
	SET @count  = (SELECT COUNT(O.OrderID) AS 'TotalOrders' FROM Orders AS O  
		   --JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID  		
		   WHERE O.CustomerID = @custid 
		); 

   SET @sum  = (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS 'Sum' FROM OrderDetails AS OD  
		   JOIN Orders AS O ON O.OrderID = OD.OrderID  
		   WHERE O.CustomerID = @custid 
		); 

END	
GO

DECLARE @custid NVARCHAR(5), @count INT, @sum Money;

EXEC dbo.usp_Customer_TotalSum 'TORTU', @count OUTPUT, @sum OUTPUT;

SELECT @count  AS 'Orders';
SELECT @sum  AS 'SUM';

PRINT @count;
PRINT @sum;

--dbo.usp_Customer_Year_TotalSum -  по заданному CustomerId покупателя возвращающую количество и общую сумму его покупок за данный год.
USE Northwind;
GO

DROP PROC IF EXISTS dbo.usp_Customer_Year_TotalSum;
GO
CREATE PROC dbo.usp_Customer_Year_TotalSum
  @fromdate  AS DATETIME = '19980101',
  @todate   AS DATETIME = '19981231',
  @custid  AS NVARCHAR(5) = 'TORTU',
  @count AS INT OUTPUT,
  @sum AS Money OUTPUT
AS BEGIN
	SET @count  = (SELECT COUNT(O.OrderID) AS 'TotalOrders' FROM Orders AS O  
		   --JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID  		
		   WHERE O.CustomerID = @custid AND(O.OrderDate >= @fromdate  AND O.OrderDate < @todate)
		); 

   SET @sum  = (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS 'Sum' FROM OrderDetails AS OD  
		   JOIN Orders AS O ON O.OrderID = OD.OrderID  
		   WHERE O.CustomerID = @custid AND(O.OrderDate >= @fromdate  AND O.OrderDate < @todate)
		); 

END	
GO

DECLARE @fromdate DATETIME,  @todate DATETIME, @custid NVARCHAR(5), @count INT, @sum Money;

EXEC dbo.usp_Customer_Year_TotalSum '19980101', '19981231', 'TORTU', @count OUTPUT, @sum OUTPUT;

SELECT @count  AS 'Orders';
SELECT @sum  AS 'SUM';

PRINT @count;
PRINT @sum;


--Problem
--Создайте хранимые процедуры:
--dbo.usp_Region_TotalSum - по названию региона возвращающую количество и сумму заказов в данном регионе;
--dbo.usp_Territory_TotalSum - по TerritoryId возвращающую количество и сумму заказов по данной территории.

--dbo.usp_Region_TotalSum - по названию региона возвращающую количество и сумму заказов в данном регионе;
USE Northwind;
GO

DROP PROC IF EXISTS dbo.usp_Region_TotalSum;
GO
CREATE PROC dbo.usp_Region_TotalSum
  @region  AS NVARCHAR(5) = 'SP',
  @count AS INT OUTPUT,
  @sum AS Money OUTPUT
AS BEGIN
	SET @count  = (SELECT COUNT(O.OrderID) AS 'TotalOrders' FROM Orders AS O  
		   JOIN Employees AS E ON O.EmployeeID = E.EmployeeID 
		   JOIN EmployeeTerritories AS ET ON ET.EmployeeID = E.EmployeeID 
		   JOIN Territories AS T ON T.TerritoryID = ET.TerritoryID  
		   JOIN Region AS R ON R.RegionID = T.RegionID  	
		   WHERE O.ShipRegion = @region 
		); 

   SET @sum  = (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS 'Sum' FROM OrderDetails AS OD  
		   JOIN Orders AS O ON O.OrderID = OD.OrderID
		   JOIN Employees AS E ON O.EmployeeID = E.EmployeeID 
		   JOIN EmployeeTerritories AS ET ON ET.EmployeeID = E.EmployeeID 
		   JOIN Territories AS T ON T.TerritoryID = ET.TerritoryID  
		   JOIN Region AS R ON R.RegionID = T.RegionID  
		   WHERE O.ShipRegion = @region 
		); 

END	
GO

DECLARE @region NVARCHAR(5), @count INT, @sum Money;

EXEC dbo.usp_Region_TotalSum 'SP', @count OUTPUT, @sum OUTPUT;

SELECT @count  AS 'Orders';
SELECT @sum  AS 'SUM';

PRINT @count;
PRINT @sum;

--dbo.usp_Territory_TotalSum - по TerritoryId возвращающую количество и сумму заказов по данной территории.
USE Northwind;
GO

DROP PROC IF EXISTS dbo.usp_Territory_TotalSum;
GO
CREATE PROC dbo.usp_Territory_TotalSum
  @territory  AS NVARCHAR(5) = '01581',
  @count AS INT OUTPUT,
  @sum AS Money OUTPUT
AS BEGIN
	SET @count  = (SELECT COUNT(O.OrderID) AS 'TotalOrders' FROM Orders AS O  
		   JOIN Employees AS E ON O.EmployeeID = E.EmployeeID 
		   JOIN EmployeeTerritories AS ET ON ET.EmployeeID = E.EmployeeID 
		   JOIN Territories AS T ON T.TerritoryID = ET.TerritoryID  
		   WHERE T.TerritoryID = @territory 
		); 

   SET @sum  = (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS 'Sum' FROM OrderDetails AS OD  
		   JOIN Orders AS O ON O.OrderID = OD.OrderID
		   JOIN Employees AS E ON O.EmployeeID = E.EmployeeID 
		   JOIN EmployeeTerritories AS ET ON ET.EmployeeID = E.EmployeeID 
		   JOIN Territories AS T ON T.TerritoryID = ET.TerritoryID  
		   WHERE T.TerritoryID = @territory 
		); 

END	
GO

DECLARE @territory NVARCHAR(5), @count INT, @sum Money;

EXEC dbo.usp_Territory_TotalSum '01581', @count OUTPUT, @sum OUTPUT;

SELECT @count  AS 'Orders';
SELECT @sum  AS 'SUM';

PRINT @count;
PRINT @sum;

