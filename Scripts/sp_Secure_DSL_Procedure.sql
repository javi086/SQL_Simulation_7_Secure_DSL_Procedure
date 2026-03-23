USE AdventureWorks2025;
GO

CREATE OR ALTER PROCEDURE Reporting.sp_Secure_DSL_Procedure
    @Territory_Name NVARCHAR(50) = NULL,
    @Sales_Person_Name NVARCHAR(100) = NULL,
    @Product_Category NVARCHAR(50) = NULL,
    @Start_Date DATE = NULL,
    @End_Date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2 = SYSDATETIME(); -- I will use this to calculate the time
    DECLARE @SQL NVARCHAR(MAX) = N'
            SELECT 
            st.Name AS TerritoryName,
            p.FirstName AS SalesPersonName,
            cat.Name AS ProductCategory,
            soh.OrderDate,
            SUM(sod.LineTotal) AS TotalSales,
            SUM(sod.OrderQty) AS TotalQuantity
        FROM Sales.SalesOrderHeader soh
            INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
            INNER JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
            INNER JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
            INNER JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
            INNER JOIN Production.Product prod ON sod.ProductID = prod.ProductID
            INNER JOIN Production.ProductSubcategory sub ON prod.ProductSubcategoryID = sub.ProductSubcategoryID
            INNER JOIN Production.ProductCategory cat ON sub.ProductCategoryID = cat.ProductCategoryID
        WHERE 1=1';

   
    IF @Territory_Name IS NOT NULL SET @SQL += N' AND st.Name = @Territory_Name';
    IF @Sales_Person_Name IS NOT NULL SET @SQL += N' AND (p.FirstName) = @Sales_Person_Name';
    IF @Product_Category IS NOT NULL SET @SQL += N' AND cat.Name = @Product_Category';
    IF @Start_Date IS NOT NULL SET @SQL += N' AND soh.OrderDate >= @Start_Date';
    IF @End_Date IS NOT NULL SET @SQL += N' AND soh.OrderDate <= @End_Date';

    SET @SQL += N' GROUP BY st.Name, p.FirstName, cat.Name, soh.OrderDate';
    
    DECLARE @EndTime DATETIME2 = SYSDATETIME(); -- This will be to determine the duration
    DECLARE @Duration INT = DATEDIFF(millisecond, @StartTime, @EndTime);

    BEGIN TRY
        EXEC sp_executesql
            @SQL,
            N'@Territory_Name NVARCHAR(50), @Sales_Person_Name NVARCHAR(100), @Product_Category NVARCHAR(50), @Start_Date DATE, @End_Date DATE',
            @Territory_Name, @Sales_Person_Name, @Product_Category, @Start_Date, @End_Date;

            INSERT INTO Reporting.ExecutionLog (ProcedureName, ExecutedSQL,  Execution_Status, Execution_Time)
        VALUES ('Reporting.sp_Secure_DSL_Procedure',@SQL, 'SUCCESS', @Duration);
    END TRY
    BEGIN CATCH

        INSERT INTO Reporting.ExecutionLog (ProcedureName, ExecutedSQL, ErrorMessage, Execution_Status, Execution_Time)
        VALUES ('Reporting.sp_Secure_DSL_Procedure', @SQL, ERROR_MESSAGE(), 'Failed', @Duration);
    END CATCH;
END;

-- Using only territory
EXEC Reporting.sp_Secure_DSL_Procedure 
    @Territory_Name = 'Northwest'

-- Using territory and ccategory
EXEC Reporting.sp_Secure_DSL_Procedure 
    @Territory_Name = 'Northwest', 
    @Product_Category = 'Bikes';
    
-- Catergory onluy
EXEC Reporting.sp_Secure_DSL_Procedure 
    @Product_Category = 'Accessories';

-- Person & category
EXEC Reporting.sp_Secure_DSL_Procedure 
    @Sales_Person_Name = 'Jae', 
    @Product_Category = 'Bikes';

-- Checking performanc date range
EXEC Reporting.sp_Secure_DSL_Procedure 
    @Sales_Person_Name = 'Jae',
    @Start_Date = '2023-01-01',
    @End_Date = '2025-12-31';

    SELECT *  FROM Person.person;

-- Check logs if a failure occurs
SELECT * FROM Reporting.ExecutionLog;
