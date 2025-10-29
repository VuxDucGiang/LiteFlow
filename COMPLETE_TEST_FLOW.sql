-- ============================================================
-- COMPLETE TEST FLOW FOR PO PENDING NOTIFICATIONS
-- Run this in SQL Server Management Studio
-- ============================================================

USE LiteFlowDBO;
GO

SET NOCOUNT ON;

PRINT '╔════════════════════════════════════════════════════════╗';
PRINT '║  PO PENDING NOTIFICATION - COMPLETE TEST FLOW         ║';
PRINT '╚════════════════════════════════════════════════════════╝';
PRINT '';

-- ============================================================
-- STEP 1: Clean up old test data
-- ============================================================
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'STEP 1: Cleaning up old test data...';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

-- Delete old test POs
DELETE FROM PurchaseOrders WHERE Notes LIKE '%Test PO%';
PRINT '✅ Old test POs deleted';

-- Delete old PO_PENDING alerts
DELETE FROM AlertHistory WHERE AlertType = 'PO_PENDING';
PRINT '✅ Old PO_PENDING alerts deleted';

PRINT '';

-- ============================================================
-- STEP 2: Create test supplier
-- ============================================================
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'STEP 2: Creating test supplier...';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @SupplierID UNIQUEIDENTIFIER;
DECLARE @UserID UNIQUEIDENTIFIER;

-- Get or create test supplier
IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE Name = N'Test Supplier - Auto')
BEGIN
    SET @SupplierID = NEWID();
    INSERT INTO Suppliers (SupplierID, Name, Contact, Email, Phone, IsActive, CreatedAt)
    VALUES (@SupplierID, N'Test Supplier - Auto', N'Test Contact', 'test@supplier.com', '0987654321', 1, GETDATE());
    PRINT '✅ New test supplier created';
END
ELSE
BEGIN
    SELECT @SupplierID = SupplierID FROM Suppliers WHERE Name = N'Test Supplier - Auto';
    PRINT '✅ Using existing test supplier';
END

-- Get a user ID
SELECT TOP 1 @UserID = UserID FROM Users WHERE IsActive = 1;
IF @UserID IS NULL
BEGIN
    PRINT '❌ ERROR: No active users found in database!';
    PRINT '   Please create a user first';
    RETURN;
END

PRINT '   Supplier ID: ' + CAST(@SupplierID AS NVARCHAR(50));
PRINT '   User ID: ' + CAST(@UserID AS NVARCHAR(50));
PRINT '';

-- ============================================================
-- STEP 3: Create test pending POs
-- ============================================================
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'STEP 3: Creating test pending POs...';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

-- PO 1: CRITICAL (Board approval)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(), @SupplierID, @UserID, GETDATE(), DATEADD(DAY, 7, GETDATE()),
    55000000, 'PENDING', 3, 
    N'Test PO 1 - CRITICAL (55M, Level 3)'
);
PRINT '✅ Created PO 1: 55M VND, Level 3 (CRITICAL)';

-- PO 2: HIGH (Director approval)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(), @SupplierID, @UserID, GETDATE(), DATEADD(DAY, 10, GETDATE()),
    12500000, 'PENDING', 2,
    N'Test PO 2 - HIGH (12.5M, Level 2)'
);
PRINT '✅ Created PO 2: 12.5M VND, Level 2 (HIGH)';

-- PO 3: MEDIUM (Manager approval)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(), @SupplierID, @UserID, GETDATE(), DATEADD(DAY, 14, GETDATE()),
    3500000, 'PENDING', 1,
    N'Test PO 3 - MEDIUM (3.5M, Level 1)'
);
PRINT '✅ Created PO 3: 3.5M VND, Level 1 (MEDIUM)';

PRINT '';

-- ============================================================
-- STEP 4: Verify data creation
-- ============================================================
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'STEP 4: Verifying created data...';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @PendingCount INT;
SELECT @PendingCount = COUNT(*) FROM PurchaseOrders WHERE Status = 'PENDING';

PRINT 'Total Pending POs: ' + CAST(@PendingCount AS NVARCHAR(10));

IF @PendingCount >= 3
BEGIN
    PRINT '✅ Data creation successful';
    PRINT '';
    PRINT 'Pending POs Summary:';
    SELECT 
        SUBSTRING(CAST(POID AS NVARCHAR(50)), 1, 8) + '...' AS POID,
        TotalAmount,
        Status,
        ApprovalLevel,
        CASE 
            WHEN TotalAmount >= 50000000 OR ApprovalLevel >= 3 THEN 'CRITICAL'
            WHEN TotalAmount >= 10000000 OR ApprovalLevel >= 2 THEN 'HIGH'
            ELSE 'MEDIUM'
        END AS ExpectedPriority
    FROM PurchaseOrders
    WHERE Status = 'PENDING'
    ORDER BY TotalAmount DESC;
END
ELSE
BEGIN
    PRINT '❌ ERROR: Not enough pending POs created';
END

PRINT '';

-- ============================================================
-- STEP 5: Instructions for manual trigger
-- ============================================================
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'STEP 5: NEXT ACTIONS REQUIRED';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT '';
PRINT '📋 Data is ready! Now follow these steps:';
PRINT '';
PRINT '1️⃣  GO TO TEST PAGE:';
PRINT '   http://localhost:8080/LiteFlow/alert/test';
PRINT '';
PRINT '2️⃣  CLICK BUTTON:';
PRINT '   📋 Check PO Pending';
PRINT '';
PRINT '3️⃣  CHECK TOMCAT CONSOLE LOGS:';
PRINT '   Should see:';
PRINT '   - "Found 3 pending POs"';
PRINT '   - "Summary alert sent: [UUID]"';
PRINT '   - "Critical: 1, High: 1, Medium: 1"';
PRINT '';
PRINT '4️⃣  REFRESH DASHBOARD:';
PRINT '   http://localhost:8080/LiteFlow/dashboard';
PRINT '   Press Ctrl + Shift + R (hard refresh)';
PRINT '';
PRINT '5️⃣  CHECK NOTIFICATION BELL:';
PRINT '   - Look at top right corner';
PRINT '   - Should see badge with number (e.g., 1)';
PRINT '   - Click bell to see dropdown';
PRINT '   - Should show: "Có 3 đơn hàng đang chờ duyệt"';
PRINT '';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT '';
PRINT '💡 TIP: If notification still not showing:';
PRINT '   - Check browser console (F12) for errors';
PRINT '   - Try: fetch(''/LiteFlow/alert/api/unread-count'').then(r=>r.json()).then(console.log)';
PRINT '';
PRINT '✅ Setup complete! Ready for testing.';
PRINT '';

GO


