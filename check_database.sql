-- =====================================================
-- DIAGNOSTIC SCRIPT: Kiểm tra Database cho Invoice Matching
-- =====================================================

PRINT '========================================';
PRINT 'STEP 1: Kiểm tra Tables tồn tại';
PRINT '========================================';

SELECT 
    t.name AS TableName,
    SUM(p.rows) AS [RowCount]
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE t.name IN ('Suppliers', 'PurchaseOrders', 'PurchaseOrderItems', 'Invoices', 'InvoiceItems', 'GoodsReceipts', 'GoodsReceiptItems')
    AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name;

PRINT '';
PRINT '========================================';
PRINT 'STEP 2: Kiểm tra POs APPROVED';
PRINT '========================================';

SELECT 
    COUNT(*) AS Total_APPROVED_POs,
    MIN(CreateDate) AS Oldest_PO,
    MAX(CreateDate) AS Newest_PO
FROM PurchaseOrders
WHERE Status = 'APPROVED';

PRINT '';
PRINT '========================================';
PRINT 'STEP 3: Chi tiết POs APPROVED (top 5)';
PRINT '========================================';

SELECT TOP 5
    PO.POID,
    CAST(PO.POID AS NVARCHAR(50)) AS POID_String,
    S.Name AS SupplierName,
    PO.TotalAmount,
    PO.Status,
    PO.CreateDate,
    (SELECT COUNT(*) FROM PurchaseOrderItems WHERE POID = PO.POID) AS ItemsCount
FROM PurchaseOrders PO
LEFT JOIN Suppliers S ON PO.SupplierID = S.SupplierID
WHERE PO.Status = 'APPROVED'
ORDER BY PO.CreateDate DESC;

PRINT '';
PRINT '========================================';
PRINT 'STEP 4: Kiểm tra Items cho PO đầu tiên';
PRINT '========================================';

DECLARE @TestPOID UNIQUEIDENTIFIER;
SELECT TOP 1 @TestPOID = POID FROM PurchaseOrders WHERE Status = 'APPROVED';

IF @TestPOID IS NOT NULL
BEGIN
    PRINT 'Testing with POID: ' + CAST(@TestPOID AS NVARCHAR(50));
    
    SELECT 
        ItemID,
        POID,
        ItemName,
        Quantity,
        UnitPrice,
        (Quantity * UnitPrice) AS Subtotal
    FROM PurchaseOrderItems
    WHERE POID = @TestPOID
    ORDER BY ItemID;
    
    PRINT '';
    PRINT 'Total items for this PO: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT 'ERROR: No APPROVED PO found!';
END

PRINT '';
PRINT '========================================';
PRINT 'STEP 5: Kiểm tra Indexes';
PRINT '========================================';

SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name = 'PurchaseOrderItems'
    AND i.name IS NOT NULL
ORDER BY t.name, i.name, ic.key_ordinal;

PRINT '';
PRINT '========================================';
PRINT 'STEP 6: Performance Test Query';
PRINT '========================================';

DECLARE @StartTime DATETIME2 = SYSDATETIME();
DECLARE @TestPOID2 UNIQUEIDENTIFIER;
SELECT TOP 1 @TestPOID2 = POID FROM PurchaseOrders WHERE Status = 'APPROVED';

SELECT 
    ItemID,
    ItemName,
    Quantity,
    UnitPrice
FROM PurchaseOrderItems
WHERE POID = @TestPOID2
ORDER BY ItemID;

DECLARE @EndTime DATETIME2 = SYSDATETIME();
DECLARE @Duration INT = DATEDIFF(MILLISECOND, @StartTime, @EndTime);

PRINT 'Query execution time: ' + CAST(@Duration AS NVARCHAR(10)) + ' ms';

IF @Duration > 1000
BEGIN
    PRINT 'WARNING: Query is SLOW (>1000ms)!';
END
ELSE
BEGIN
    PRINT 'OK: Query performance is acceptable';
END

PRINT '';
PRINT '========================================';
PRINT 'STEP 7: Check for NULL/Invalid POIDs';
PRINT '========================================';

SELECT 
    'PurchaseOrders' AS TableName,
    COUNT(*) AS Total_Records,
    COUNT(CASE WHEN POID IS NULL THEN 1 END) AS NULL_POIDs
FROM PurchaseOrders
UNION ALL
SELECT 
    'PurchaseOrderItems' AS TableName,
    COUNT(*) AS Total_Records,
    COUNT(CASE WHEN POID IS NULL THEN 1 END) AS NULL_POIDs
FROM PurchaseOrderItems;

PRINT '';
PRINT '========================================';
PRINT 'STEP 8: Orphaned Items Check';
PRINT '========================================';

SELECT 
    POI.ItemID,
    POI.POID,
    POI.ItemName
FROM PurchaseOrderItems POI
LEFT JOIN PurchaseOrders PO ON POI.POID = PO.POID
WHERE PO.POID IS NULL;

IF @@ROWCOUNT = 0
    PRINT 'OK: No orphaned items found';
ELSE
    PRINT 'WARNING: Orphaned items detected!';

PRINT '';
PRINT '========================================';
PRINT 'DIAGNOSTIC COMPLETE';
PRINT '========================================';

