--Упаковывается в единый файл Homework_xx_LastName_FirstName.zip.

--Problem 00
--Восстановите из backup AdventureWorks2019.bak. Выполните run.sql.

USE AdventureWorks2019;
GO

--12-1
--Напишите скрипт, который объявляет две целочисленные переменные с именем @MaxID и @MinID. Используйте переменные для вывода самого большого и самого маленького низкого значения SalesOrderID из таблицы Sales.SalesOrderHeader.

DECLARE @MaxID AS INT = (SELECT MAX(SalesOrderID) FROM Sales.SalesOrderHeader);
DECLARE @MinID AS INT = (SELECT MIN(SalesOrderID) FROM Sales.SalesOrderHeader);

PRINT @MaxID;
PRINT @MinID;

--Напишите скрипт, объявляющий целочисленную переменную с именем @ID. Присвойте переменной значение 70000. Используйте переменную в операторе SELECT, возвращающим все строки из Sales.SalesOrderHeader, у которых SalesOrderID больше, чем значение переменной.

DECLARE @ID AS INT = 70000;
SELECT * FROM Sales.SalesOrderHeader WHERE SalesOrderID > @ID

--Напишите скрипт, который объявляет три переменные: одну целочисленную @ID, NVARCHAR (50) с именем @FirstName и
--NVARCHAR (50) с именем @LastName. Используйте оператор SELECT для установки значения переменных из Person.Person с BusinessEntityID = 1. Распечатайте в формате BusinessEntityID: FirstName LastName.
DECLARE @ID AS INT;
DECLARE @FirstName AS  NVARCHAR(50);
DECLARE @LastName AS  NVARCHAR(50);
SET @ID = 1;
SET @FirstName = (SELECT FirstName FROM Person.Person WHERE Person.BusinessEntityID = @ID);
SET @LastName = (SELECT LastName FROM Person.Person WHERE Person.BusinessEntityID = @ID);

PRINT STR(@ID) +': ' + @FirstName +' '+ @LastName;

--12-2
--Напишите скрипт, который приравнивает целочисленную переменную @Count количеству всех записей в  Sales.SalesOrderDetail. Добавьте конструкцию IF, которая печатает «Более 100 000», если значение превышает 100 000. В противном случае выведите «100 000 или меньше».

DECLARE @Count AS INT = (SELECT COUNT(SalesOrderID) FROM Sales.SalesOrderDetail);
IF (@count > 100000) BEGIN
	--PRINT @count;
	PRINT N'Более 100 000';
END ELSE BEGIN
	--PRINT @count;
	PRINT N'100 000 или меньше';
END

--Напишите скрипт, который использует IF EXISTS, чтобы проверить, есть ли строка в таблице Sales.SalesOrderHeader, в которой SalesOrderID = 1. Распечатайте "Имеется SalesOrderID = 1" или "Отсутствует SalesOrderID = 1" в зависимости от результата.

IF EXISTS (SELECT * FROM Sales.SalesOrderHeader WHERE SalesOrderID = 1) 
BEGIN
   PRINT N'Имеется SalesOrderID = 1';
END
ELSE
BEGIN
    PRINT N'Отсутствует SalesOrderID = 1';
END

--12-3
--Напишите скрипт, содержащий цикл WHILE, который распечатывает буквы От A до Z. Используйте функцию CHAR, чтобы преобразовать число в букву. Начните цикл со значением 65.
DECLARE @number INT
SET @number = 65;

WHILE (@number < 91) BEGIN
	PRINT CHAR(@number)
  SET @number = @number + 1
END;


--Напишите скрипт, содержащий цикл WHILE, вложенный в другой WHILE цикл. Счетчик внешнего цикла должен отсчитывать от 1
--до 100. Счетчик внутреннего цикла должен отсчитывать от 1 до 5. Выводите произведение двух счетчиков внутри внутреннего цикла.
DECLARE @number1 INT
DECLARE @number2 INT
SET @number1 = 1;
SET @number2 = 1;

WHILE (@number1 <= 100) 
	BEGIN
		WHILE (@number2 <= 5) 
		BEGIN
			PRINT @number1 * @number2
			SET @number2 = @number2 + 1
		END
	SET @number1 = @number1 + 1
END;


--Измените предыдущий скрипт так, чтобы происходил выход из внутреннего цикла, когда счетчик внешнего цикла делится без остатка на 5.
DECLARE @number1 INT
DECLARE @number2 INT
SET @number1 = 1;
SET @number2 = 1;

WHILE (@number1 <= 100) 
	BEGIN
		WHILE (@number2 % 5 != 0) 
		BEGIN
			PRINT @number1 * @number2
			SET @number2 = @number2 + 1
		END
	SET @number1 = @number1 + 1
END;


--Напишите скрипт, содержащий цикл WHILE, который считает от 1 до 100. Выводите «Нечетный» или «Четный» в зависимости от значения счетчика.
DECLARE @number INT
SET @number = 1;

WHILE (@number <= 100) BEGIN
	IF(@number%2 = 0) 
	BEGIN
		PRINT N'Четный';
	END 
	ELSE
	BEGIN
		PRINT N'Нечетный';
	END
  SET @number = @number + 1;
END



--12-4
--Создайте временную таблицу под названием #CustomerInfo, содержащую столбцы CustomerID (INT), FirstName и LastName (NVARCHAR (50) для каждого),CountOfSales (INT) и SumOfTotalDue (MONEY). 
--Заполните таблицу с помощью запроса с использованием Sales.Customer, Person.Person и Sales.SalesOrderHeader.
--INSERT INTO #CustomerInfo(CustomerID, . . . )
--SELECT . . . FROM . . .

USE AdventureWorks2019;
GO
DROP TABLE IF EXISTS #CustomerInfo;
GO
CREATE TABLE #CustomerInfo (
 CustomerID INT,
 FirstName NVARCHAR(50),
 LastName NVARCHAR(50),
 CountOfSales INT,
 SumOfTotalDue MONEY
);
INSERT INTO #CustomerInfo (CustomerID, FirstName, LastName, CountOfSales, SumOfTotalDue)
  SELECT SC.CustomerID, PP.FirstName, PP.LastName, COUNT(SS.CustomerID), SUM(TotalDue)
  FROM Sales.Customer AS SC
  JOIN Person.Person AS PP ON PP.BusinessEntityID = SC.CustomerID
  JOIN Sales.SalesOrderHeader AS SS ON SS.CustomerID = PP.BusinessEntityID
  GROUP BY SC.CustomerID, PP.FirstName, PP.LastName;

  SELECT CustomerID, FirstName, LastName, CountOfSales, SumOfTotalDue FROM #CustomerInfo;
GO

--Измените код предыдущего запроса так, чтобы использовать табличную переменную вместо временной таблицы.
DECLARE @CustomerInfo TABLE (CustomerID INT, FirstName VARCHAR(50), LastName VARCHAR(50), CountOfSales INT, SumOfTotalDue MONEY);
INSERT INTO @CustomerInfo(CustomerID, FirstName, LastName, CountOfSales, SumOfTotalDue)
  SELECT SC.CustomerID, PP.FirstName, PP.LastName, COUNT(SS.CustomerID), SUM(TotalDue)
  FROM Sales.Customer AS SC
  JOIN Person.Person AS PP ON PP.BusinessEntityID = SC.CustomerID
  JOIN Sales.SalesOrderHeader AS SS ON SS.CustomerID = PP.BusinessEntityID
  GROUP BY SC.CustomerID, PP.FirstName, PP.LastName;

  SELECT CustomerID, FirstName, LastName, CountOfSales, SumOfTotalDue FROM @CustomerInfo;
GO


--Создайте табличную переменную с двумя целочисленными столбцами, один из которых IDENTITY. 
--Используйте цикл WHILE для заполнения таблицы 1000 случайными целыми числами по следующей формуле:
--CAST(RAND() * 10000 AS INT) + 1.
USE AdventureWorks2019;
GO
DECLARE @TableVar TABLE (Num1 INT IDENTITY, Num2 INT);

DECLARE @Num1 INT ;
SET @Num1= 1;
DECLARE @Num2 INT;
SET @Num2= 1;

WHILE (@Num1 <=1000)
	BEGIN
		INSERT INTO @TableVar(Num2) VALUES(@Num2)
		SET @Num2 = CAST(RAND() * 10000 AS INT) + 1		
		SET @Num1 = @Num1 + 1
	END
	
	SELECT * FROM @TableVar


--13-2 (Views)
--Создайте view с именем dbo.vw_Products, который отображает список продуктов из таблицы Production.Product присоединенной к Production.ProductCostHistory. 
--Включите столбцы, которые описывают продукт и покажите историю цен для каждого продукта. Протестируйте представление, создав запрос, который извлекает данные из представления.

USE AdventureWorks2019;
DROP VIEW	IF	EXISTS	dbo.vw_Products;
GO

CREATE VIEW	dbo.vw_Products
AS
SELECT PP.Name, PP.Color, PP.Size, PPCH.StandardCost
  FROM Production.Product AS PP
  JOIN Production.ProductCostHistory AS PPCH ON PPCH.ProductID = PP.ProductID
  GROUP BY PP.Name, PP.Color, PP.Size, PPCH.StandardCost
GO
SELECT * FROM dbo.vw_Products


--Создайте представление с именем dbo.vw_CustomerTotals, которое отображает общий объем продаж из столбца TotalDue за год и месяц для каждого клиента. Протестируйте представление, создав запрос, который извлекает данные из него.
USE AdventureWorks2019;
DROP VIEW	IF	EXISTS	dbo.vw_CustomerTotals;
GO

CREATE VIEW	dbo.vw_CustomerTotals
AS
SELECT SS.CustomerID, SS.TotalDue
  FROM Sales.SalesOrderHeader AS SS WHERE YEAR(OrderDate) = 2011 
  --FROM Sales.SalesOrderHeader AS SS WHERE MONTH(OrderDate) = 3 

GO
SELECT * FROM dbo.vw_CustomerTotals

--6-1 (Subqueries)

--Используя подзапрос, включающего Sales.SalesOrderDetail, отобразите названия продуктов и идентификационные номера продуктов изтаблица Production.Product, которые были заказаны.
USE AdventureWorks2019;
SELECT ProductID, Name
 FROM Production.Product AS PP
 WHERE EXISTS
   (SELECT SS.ProductID
    FROM Sales.SalesOrderDetail AS SS
    WHERE PP.ProductID = SS.ProductID)


--Измените запрос, указанный в предыдущем вопросе так, чтобы отображать продукты, которые не были заказаны.

USE AdventureWorks2019;
SELECT ProductID, Name
 FROM Production.Product AS PP
 WHERE NOT EXISTS
   (SELECT SS.ProductID
    FROM Sales.SalesOrderDetail AS SS
    WHERE PP.ProductID = SS.ProductID)


--Выполните:
DROP TABLE IF EXISTS Production.ProductColor;
CREATE table Production.ProductColor
(Color nvarchar(15) NOT NULL PRIMARY KEY);
GO

INSERT INTO Production.ProductColor
SELECT DISTINCT Color
FROM Production.Product
WHERE Color IS NOT NULL and Color <> 'Silver';

INSERT INTO Production.ProductColor
VALUES ('Green'),('Orange'),('Purple');

--Напишите запрос, используя подзапрос, который возвращает строки из таблицы Production.ProductColor, которые не используется в таблице Production.Product.
USE AdventureWorks2019;
SELECT Color
 FROM Production.ProductColor AS PPC
 WHERE NOT EXISTS
   (SELECT PP.Color
    FROM Production.Product AS PP
    WHERE PPC.Color = PP.Color)


--Напишите запрос, который отображает цвета, используемые Production.Product, не указанных в Production.ProductColor с помощью подзапроса. Используйте ключевое слово DISTINCT перед именем столбца, чтобы возвращать каждый цвет только один раз. Используйте NOT EXISTS в запросе.

USE AdventureWorks2019;
SELECT DISTINCT PP.Color
 FROM Production.Product AS PP 
 WHERE NOT EXISTS
   (SELECT  PPC.Color
    FROM Production.ProductColor AS PPC
    WHERE PPC.Color = PP.Color)

--Напишите запрос, который объединяет ModifiedDate от Person.Person и HireDate из HumanResources.Employee без
--дублирования результатов.
USE AdventureWorks2019;
SELECT  PP.ModifiedDate
 FROM Person.Person AS PP 
 WHERE PP.ModifiedDate = 
   (SELECT DISTINCT HR.HireDate
    FROM HumanResources.Employee AS HR
    WHERE HR.HireDate = PP.ModifiedDate)


--6-2 (Derived Tables and Common Table Expressions)
--Используя производную таблицу, присоедините таблицу Sales.SalesOrderHeader к таблица Sales.SalesOrderDetail. 
--Отобразите SalesOrderID, OrderDate и ProductID в результате. 
---Таблица Sales.SalesOrderDetail должна находиться внутри производной таблицы.

USE AdventureWorks2019;
SELECT SSOH.SalesOrderID, SSOH.OrderDate, dOrders.ProductID
  FROM Sales.SalesOrderHeader AS SSOH LEFT OUTER JOIN 
  /* start our derived table */
  (SELECT SSOD.ProductID,  SSOD.SalesOrderID FROM Sales.SalesOrderDetail AS SSOD) AS dOrders
  /* end our derived table */
  ON SSOH.SalesOrderID = dOrders.SalesOrderID
  GROUP BY SSOH.SalesOrderID, SSOH.OrderDate, dOrders.ProductID


--Перепишите предыдущий скрипт с использованием CTE.
USE AdventureWorks2019;
WITH OrdersInfo AS (
  SELECT SSOH.SalesOrderID, SSOH.OrderDate, dOrders.ProductID
  FROM Sales.SalesOrderHeader AS SSOH LEFT OUTER JOIN 
  /* start our derived table */
  (SELECT SSOD.ProductID,  SSOD.SalesOrderID FROM Sales.SalesOrderDetail AS SSOD) AS dOrders
  /* end our derived table */
  ON SSOH.SalesOrderID = dOrders.SalesOrderID
  GROUP BY SSOH.SalesOrderID, SSOH.OrderDate, dOrders.ProductID
)
SELECT * FROM OrdersInfo;


--Напишите запрос, который отображает всех клиентов вместе с заказами 2011 года. 
--Используйте общее табличное выражение для написания запроса и включите CustomerID, SalesOrderID и OrderDate в результат.

USE AdventureWorks2019;
DROP VIEW	IF	EXISTS	dbo.vw_CustomerOrders;
GO

CREATE VIEW	dbo.vw_CustomerOrders
AS
SELECT SS.CustomerID, SS.SalesOrderID, SS.OrderDate
  FROM Sales.SalesOrderHeader AS SS WHERE YEAR(OrderDate) = 2011 

GO
SELECT * FROM dbo.vw_CustomerOrders



 

























