USE AdventureWorks2025;
GO

/************************************************************************/
 -- Task 1 – Basic Execution Logging
/************************************************************************/

-- In Reporting.ExecutionLog I have: ProcedureName
-- I need ExecutionStatus, ParameterValues, ExecutionTime

-- I need to validate the existence of the table and fields
--  Execution_Status
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Reporting.ExecutionLog') AND name = 'Execution_Status')
BEGIN
    ALTER TABLE Reporting.ExecutionLog ADD  Execution_Status NVARCHAR(20)  NULL   
    CONSTRAINT CHK_Execution_Status CHECK (Execution_Status IN ('Success', 'Failed', 'Rejected'));
     
     PRINT 'Column Execution_Status added successfully';
END
ELSE
BEGIN
    PRINT 'Column Execution_Status already exists';
END
GO

-- Parameter_Values
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Reporting.ExecutionLog') AND name = 'Parameter_Values')
BEGIN
    ALTER TABLE Reporting.ExecutionLog ADD Parameter_Values NVARCHAR(MAX) NULL

    PRINT 'Column Parameter_Values added successfully';
END
ELSE
BEGIN
    PRINT 'Column Parameter_Values already exists';
END
GO

-- Execution_Time
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Reporting.ExecutionLog') AND name = 'Execution_Time')
BEGIN
    ALTER TABLE Reporting.ExecutionLog ADD Execution_Time INT NULL

    PRINT 'Column Execution_Time added successfully';
END
ELSE
BEGIN
     PRINT 'Column Execution_Time already exists';
END    
GO


