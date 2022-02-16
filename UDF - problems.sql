---------------------------------------------------------------------
-- User-defined functions (UDF)
---------------------------------------------------------------------

--Problem
--В базе данных Test создайте и протестируйте функцию udfGetMaxFrom3, возвращающую минимальное значение из трех переданных ей вещественных чисел.

USE Northwind;
DROP FUNCTION IF EXISTS dbo.udfGetMaxFrom3;
GO
CREATE FUNCTION dbo.udfGetMaxFrom3 (@a AS FLOAT,@b AS FLOAT,@c AS FLOAT) 
RETURNS FLOAT AS
BEGIN
  DECLARE @min AS FLOAT;
  SET @min =  IIF(@a > @b,	@b, @a);
  SET @min =  IIF(@b > @c,	@c, @b);
  SET @min =  IIF(@a > @c,	@c, @a);
  RETURN @min;
END;
GO

USE Northwind;
--USE Test;
DECLARE @x AS FLOAT;
SET @x = dbo.udfGetMaxFrom3(10.2, 20.4, 8.4);
PRINT @x; 

--Problem
--Используя dbo.GetGlobal из скрипта UDF.sql, напишите функции без параметров:
--dbo.GetFirmName()
--dbo.GetChief()
--dbo.GetCurrentDollarRate()
--dbo.GetCurrentEuroRate()

USE Northwind;
DROP TABLE IF EXISTS Globals;
GO
CREATE TABLE Globals (
  Name NVARCHAR(20) PRIMARY KEY,
  Val SQL_VARIANT NOT NULL
);
GO
 
INSERT INTO Globals(Name, Val) VALUES ('FirmName', 'Tesla');
INSERT INTO Globals(Name, Val) VALUES ('Chief', 'Mask');
INSERT INTO Globals(Name, Val) VALUES ('CurrentDollarRate', 420);
INSERT INTO Globals(Name, Val) VALUES ('CurrentEuroRate', 450); 

--dbo.GetFirmName()
DROP FUNCTION IF EXISTS dbo.GetFirmName;
GO
CREATE FUNCTION dbo.GetFirmName (@Name AS NVARCHAR(20))
  RETURNS SQL_VARIANT AS
BEGIN
  DECLARE @Val SQL_VARIANT;
  SELECT @Val = Val FROM  Globals WHERE Name = @Name;
  RETURN  @Val;
END;
GO

SELECT dbo.GetFirmName('FirmName');

--dbo.GetChief()
DROP FUNCTION IF EXISTS dbo.GetChief;
GO
CREATE FUNCTION dbo.GetChief (@Name AS NVARCHAR(20))
  RETURNS SQL_VARIANT AS
BEGIN
  DECLARE @Val SQL_VARIANT;
  SELECT @Val = Val FROM  Globals WHERE Name = @Name;
  RETURN  @Val;
END;
GO

SELECT dbo.GetChief('Chief');

--dbo.GetCurrentDollarRate()
DROP FUNCTION IF EXISTS dbo.GetCurrentDollarRate;
GO
CREATE FUNCTION dbo.GetCurrentDollarRate (@Name AS NVARCHAR(20))
  RETURNS SQL_VARIANT AS
BEGIN
  DECLARE @Val SQL_VARIANT;
  SELECT @Val = Val FROM  Globals WHERE Name = @Name;
  RETURN  @Val;
END;
GO

SELECT dbo.GetCurrentDollarRate('CurrentDollarRate');

--dbo.GetCurrentEuroRate()
DROP FUNCTION IF EXISTS dbo.GetCurrentEuroRate;
GO
CREATE FUNCTION dbo.GetCurrentEuroRate (@Name AS NVARCHAR(20))
  RETURNS SQL_VARIANT AS
BEGIN
  DECLARE @Val SQL_VARIANT;
  SELECT @Val = Val FROM  Globals WHERE Name = @Name;
  RETURN  @Val;
END;
GO

SELECT dbo.GetCurrentEuroRate('CurrentEuroRate');

--Problem
--В базе данных Northwind создайте функцию udfGetLastOrderId, возвращающую OrderId последнего заказа.

USE Northwind;
DROP FUNCTION IF EXISTS dbo.udfGetLastOrderId;
GO
CREATE FUNCTION dbo.udfGetLastOrderId()
RETURNS INT AS
BEGIN
	DECLARE @OrderId AS INT;
	SET @OrderId = (SELECT MAX(OrderId) FROM dbo.Orders);
  RETURN @OrderId;
END;
GO

USE Northwind;
PRINT dbo.udfGetLastOrderId();

--Problem
--В базе данных Northwind создайте функцию udfGetCountOrders, возвращающую общее количество заказов за заданный год.
USE Northwind;
DROP FUNCTION IF EXISTS dbo.udfGetCountOrders;
GO
CREATE FUNCTION dbo.udfGetCountOrders()
RETURNS INT AS
BEGIN
	DECLARE @CountOrders AS INT;
	SET @CountOrders = (SELECT COUNT(OrderId) FROM dbo.Orders WHERE (YEAR(OrderDate) = 1998));
  RETURN @CountOrders;
END;
GO

USE Northwind;
PRINT dbo.udfGetCountOrders();


--Problem
--В базе данных Northwind создайте функцию dbo.ufnCustomers_OrderCount, возвращающую таблицу ВСЕХ покупателей с полями CustomerID, ContactName, и OrdersCount (суммарное количество заказов покупателя).
--Продемонстрируйде работу функции.
--Пользуясь данной функцией, найдите число заказов покупателя 'Alejandra Camino'.
--Пользуясь данной функцией, выведите покупателей без заказов.

USE Northwind;
DROP FUNCTION IF EXISTS dbo.ufnCustomers_OrderCount;  
GO  
CREATE FUNCTION dbo.ufnCustomers_OrderCount()  
RETURNS TABLE AS  
RETURN (  
	SELECT C.CustomerID, C.ContactName, COUNT(O.OrderID) AS 'TotalOrders'  
	  FROM Customers AS C  
		   JOIN Orders AS O ON C.CustomerID = O.CustomerID  
		GROUP BY C.CustomerID,  C.ContactName
    );  
GO

USE Northwind;
SELECT * FROM dbo.ufnCustomers_OrderCount();

--Пользуясь данной функцией, найдите число заказов покупателя 'Alejandra Camino'.
SELECT * FROM dbo.ufnCustomers_OrderCount() WHERE ContactName = 'Alejandra Camino';

--Пользуясь данной функцией, выведите покупателей без заказов.
 SELECT CustomerID, ContactName FROM Customers WHERE NOT EXISTS ( SELECT * FROM dbo.ufnCustomers_OrderCount() WHERE CustomerID = Customers.CustomerID);


--Problem
--В базе данных Northwind создайте функцию dbo.ufnCustomers_OrderCount_Sum(@year AS INT), возвращающую таблицу ВСЕХ покупателей c их количеством заказов и общей суммой заказов за заданный год.
--Продемонстрируйде работу функции.
--Пользуясь данной функцией, найдите суммарное количество заказов всех покупателей и их сумму за заданный год.

USE Northwind;
DROP FUNCTION IF EXISTS dbo.ufnCustomers_OrderCount_Sum;  
GO  
CREATE FUNCTION dbo.ufnCustomers_OrderCount_Sum(@year AS INT) 
RETURNS TABLE AS  
RETURN (  
	SELECT C.CustomerID, C.ContactName, COUNT(O.OrderID) AS 'TotalOrders', SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) AS 'TotalCost' 
	  FROM Customers AS C  
		   JOIN Orders AS O ON C.CustomerID = O.CustomerID  
		   JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID  
		   WHERE YEAR(O.OrderDate) = @year  
		GROUP BY C.CustomerID,  C.ContactName
    );  
GO

USE Northwind;
SELECT * FROM dbo.ufnCustomers_OrderCount_Sum(1998);

--Пользуясь данной функцией, найдите суммарное количество заказов всех покупателей и их сумму за заданный год.
SELECT COUNT(TotalOrders) AS 'TotalOrders', SUM(TotalCost) AS 'TotalCost' FROM dbo.ufnCustomers_OrderCount_Sum(1998);


--Problem
--В базе данных Northwind создайте функцию dbo.ufnCustomers_Employees, возвращающую таблицу ВСЕХ покупателей и их Employees.

USE Northwind;
DROP FUNCTION IF EXISTS dbo.ufnCustomers_Employees;  
GO  
CREATE FUNCTION dbo.ufnCustomers_Employees()  
RETURNS TABLE AS  
RETURN (  
	SELECT C.CustomerID, C.ContactName AS 'CostumerName', E.EmployeeID, E.LastName AS 'EmployeeName'
	  FROM Customers AS C  
		   INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID  
		   INNER JOIN Employees AS E ON O.EmployeeID = E.EmployeeID  
		GROUP BY C.CustomerID,  C.ContactName, E.EmployeeID, E.LastName
    );  
GO
USE Northwind;
SELECT * FROM dbo.ufnCustomers_Employees();

--Problem
--В базе данных Northwind создайте функцию dbo.ufnSuppliers_Products_Sum(@year AS INT), возвращающую таблицу поставщиков, продуктов и сумм продаж по заданному году.

USE Northwind;
DROP FUNCTION IF EXISTS dbo.ufnSuppliers_Products_Sum;  
GO  
CREATE FUNCTION dbo.ufnSuppliers_Products_Sum(@year AS INT) 
RETURNS TABLE AS  
RETURN (  
	SELECT P.ProductID, P.ProductName, S.SupplierID, S.ContactName, SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) AS 'TotaSum' 
	  FROM Suppliers AS S  
		   JOIN Products AS P ON P.SupplierID = S.SupplierID  
		   JOIN OrderDetails AS OD ON OD.ProductID = P.ProductID  
		   JOIN Orders AS O ON O.OrderID = OD.OrderID  
		   WHERE YEAR(O.OrderDate) = @year  
		GROUP BY P.ProductID, P.ProductName, S.SupplierID, S.ContactName
    );  
GO

USE Northwind;
SELECT * FROM dbo.ufnSuppliers_Products_Sum(1998);

--13-3
--Problem
--Напишите функцию dbo.temperature. Она должна принимать DECIMAL (5,3) и символ F или C, обозначающий, в какой системе (Фаренгейт, Цельсий) ответ должен быть возвращен.

USE Northwind;
DROP FUNCTION IF EXISTS dbo.temperature;
GO
CREATE FUNCTION dbo.temperature (@a AS DECIMAL(3,1), @b AS NVARCHAR) 
RETURNS NVARCHAR(10) AS
BEGIN
  DECLARE @res AS NVARCHAR(10);
  SET @res = CAST(@a AS NVARCHAR(10)) + @b;
  RETURN @res;
END;
GO

USE Northwind;
--USE Test;
DECLARE @x AS NVARCHAR(10);
SET @x = dbo.temperature(5.3, 'F');
PRINT @x; 

--Problem
--Напишите функцию с именем dbo.fn_FormatPhone, которая принимает строку из десяти чисел. Функция должна отформатировать строку в формат: (###) ### - ####. Протестируйте функцию.
USE Northwind;
DROP FUNCTION IF EXISTS dbo.fn_FormatPhone;
GO
CREATE FUNCTION dbo.fn_FormatPhone (@a AS NVARCHAR(10)) 
RETURNS NVARCHAR(16) AS
BEGIN
  DECLARE @res AS NVARCHAR(16);
  DECLARE @temp1 AS BIGINT;
  DECLARE @temp2 AS BIGINT;
  DECLARE @temp3 AS BIGINT;
  SET @res = CAST(@a AS BIGINT);
  SET @temp1 = @res/10000000;
  SET @temp2 = (@res - (@temp1*10000000))/10000;
  SET @temp3 = (@res - (@temp1*1000+@temp2)*10000);
  SET @res = '(' + CAST(@temp1 AS NVARCHAR(10)) + ') ' + CAST(@temp2 AS NVARCHAR(10)) + ' - ' + CAST(@temp3 AS NVARCHAR(10));
  RETURN @res;
END;
GO

USE Northwind;
--USE Test;
DECLARE @x AS NVARCHAR(16);
SET @x = dbo.fn_FormatPhone('1234567890');
PRINT @x; 
