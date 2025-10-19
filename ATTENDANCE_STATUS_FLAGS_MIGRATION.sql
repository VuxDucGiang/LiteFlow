-- Migration script to add status flags to EmployeeAttendance table
-- Run this if you already have the EmployeeAttendance table created

USE LiteFlow;
GO

-- Check if columns don't exist before adding them
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('EmployeeAttendance') AND name = 'IsLate')
BEGIN
    ALTER TABLE EmployeeAttendance ADD IsLate BIT NULL;
    PRINT 'Added IsLate column';
END
ELSE
BEGIN
    PRINT 'IsLate column already exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('EmployeeAttendance') AND name = 'IsOvertime')
BEGIN
    ALTER TABLE EmployeeAttendance ADD IsOvertime BIT NULL;
    PRINT 'Added IsOvertime column';
END
ELSE
BEGIN
    PRINT 'IsOvertime column already exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('EmployeeAttendance') AND name = 'IsEarlyLeave')
BEGIN
    ALTER TABLE EmployeeAttendance ADD IsEarlyLeave BIT NULL;
    PRINT 'Added IsEarlyLeave column';
END
ELSE
BEGIN
    PRINT 'IsEarlyLeave column already exists';
END
GO

PRINT 'Migration completed successfully';
GO

