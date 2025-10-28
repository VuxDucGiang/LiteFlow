-- ============================================================
-- TEST DATA FLOW - Kiểm tra từng bước
-- ============================================================
USE LiteFlowDBO;
GO

PRINT '========================================';
PRINT 'TEST 1: Check APPROVED POs';
PRINT '========================================';

SELECT 
    POID,
    CAST(POID AS NVARCHAR(50)) AS POID_String,
    Status,
    TotalAmount,
    CreateDate
FROM PurchaseOrders
WHERE Status = 'APPROVED';

PRINT '';
PRINT '========================================';
PRINT 'TEST 2: Check Items for FIRST APPROVED PO';
PRINT '========================================';

DECLARE @TestPOID UNIQUEIDENTIFIER;
SELECT TOP 1 @TestPOID = POID FROM PurchaseOrders WHERE Status = 'APPROVED';

IF @TestPOID IS NOT NULL
BEGIN
    PRINT 'Testing with POID: ' + CAST(@TestPOID AS NVARCHAR(50));
    
    SELECT 
        ItemID,
        CAST(POID AS NVARCHAR(50)) AS POID_String,
        ItemName,
        Quantity,
        UnitPrice
    FROM PurchaseOrderItems
    WHERE POID = @TestPOID;
    
    IF @@ROWCOUNT = 0
        PRINT '❌ ERROR: No items found for this PO!';
    ELSE
        PRINT '✅ Found ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' items';
END
ELSE
BEGIN
    PRINT '❌ ERROR: No APPROVED PO found!';
END

PRINT '';
PRINT '========================================';
PRINT 'TEST 3: Simulate JPA Query';
PRINT '========================================';

-- This is exactly what JPA does
SELECT 
    p.ItemID,
    p.ItemName,
    p.Quantity,
    p.UnitPrice
FROM PurchaseOrderItems p
WHERE p.POID = @TestPOID
ORDER BY p.ItemID;

PRINT '';
PRINT '========================================';
PRINT 'TEST 4: Check Users table';
PRINT '========================================';

SELECT 
    UserID,
    Email,
    CAST(UserID AS NVARCHAR(50)) AS UserID_String
FROM Users
WHERE Email IN ('procurement@liteflow.vn', 'inventory@liteflow.vn')
   OR Email LIKE '%@liteflow%';

IF @@ROWCOUNT = 0
BEGIN
    PRINT '❌ ERROR: No users found! This will cause foreign key errors!';
    PRINT 'You need to create users first:';
    PRINT '  INSERT INTO Users (Email, ...) VALUES (''procurement@liteflow.vn'', ...);';
END
ELSE
BEGIN
    PRINT '✅ Users exist';
END

PRINT '';
PRINT '========================================';
PRINT 'TEST 5: Check Foreign Key Integrity';
PRINT '========================================';

-- Check if all POs have valid users
SELECT 
    'PurchaseOrders with invalid CreatedBy' AS Issue,
    COUNT(*) AS [Count]
FROM PurchaseOrders po
LEFT JOIN Users u ON po.CreatedBy = u.UserID
WHERE u.UserID IS NULL;

-- Check if all Suppliers have valid CreatedBy
SELECT 
    'Suppliers with invalid CreatedBy' AS Issue,
    COUNT(*) AS [Count]
FROM Suppliers s
LEFT JOIN Users u ON s.CreatedBy = u.UserID
WHERE u.UserID IS NULL;

PRINT '';
PRINT '========================================';
PRINT 'SUMMARY';
PRINT '========================================';

SELECT 
    'Suppliers' AS TableName,
    COUNT(*) AS [RowCount]
FROM Suppliers
UNION ALL
SELECT 'PurchaseOrders', COUNT(*) FROM PurchaseOrders
UNION ALL
SELECT 'PurchaseOrderItems', COUNT(*) FROM PurchaseOrderItems
UNION ALL
SELECT 'APPROVED POs', COUNT(*) FROM PurchaseOrders WHERE Status = 'APPROVED'
UNION ALL
SELECT 'Items for APPROVED POs', COUNT(*) 
FROM PurchaseOrderItems poi
JOIN PurchaseOrders po ON poi.POID = po.POID
WHERE po.Status = 'APPROVED';

PRINT '========================================';
PRINT 'TEST COMPLETE';
PRINT '========================================';
GO

