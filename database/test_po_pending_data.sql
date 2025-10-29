-- ============================================================
-- TEST DATA FOR PO_PENDING ALERTS
-- Insert sample pending purchase orders for testing
-- ============================================================

USE LiteFlowDBO;
GO

-- Insert test supplier if not exists
DECLARE @TestSupplierID UNIQUEIDENTIFIER;

IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE Name = N'Công ty TNHH Test Supplier')
BEGIN
    SET @TestSupplierID = NEWID();
    
    INSERT INTO Suppliers (SupplierID, Name, Contact, Email, Phone, Address, Rating, IsActive, CreatedAt)
    VALUES (
        @TestSupplierID,
        N'Công ty TNHH Test Supplier',
        N'Nguyễn Văn A',
        'contact@testsupplier.com',
        '0987654321',
        N'123 Đường Test, Quận 1, TP.HCM',
        4.5,
        1,
        GETDATE()
    );
    
    -- CRITICAL: Create SupplierSLA record to prevent trigger failure
    INSERT INTO SupplierSLA (SupplierID, TotalOrders, OnTimeDeliveries, AvgDelayDays, LastEvaluated)
    VALUES (@TestSupplierID, 0, 0, 0, GETDATE());
    
    PRINT '✅ Test supplier created';
    PRINT '✅ SupplierSLA record created';
END
GO

-- Get supplier ID
DECLARE @SupplierID UNIQUEIDENTIFIER;
SELECT @SupplierID = SupplierID FROM Suppliers WHERE Name = N'Công ty TNHH Test Supplier';

-- Get a user ID for CreatedBy (first user from Users table)
DECLARE @UserID UNIQUEIDENTIFIER;
SELECT TOP 1 @UserID = UserID FROM Users WHERE IsActive = 1;

-- Insert test PO - PENDING for 3 days (should trigger HIGH alert)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(),
    @SupplierID,
    @UserID,
    DATEADD(DAY, -3, GETDATE()), -- Created 3 days ago
    DATEADD(DAY, 7, GETDATE()),  -- Expected in 7 days
    12500000, -- 12.5M VND
    'PENDING',
    2, -- Director approval
    N'Test PO - Should trigger HIGH priority alert (3 days pending, >10M)'
);
PRINT '✅ Test PO 1 created: 3 days pending, 12.5M VND (HIGH priority)';

-- Insert test PO - PENDING for 5 days (should trigger CRITICAL alert)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(),
    @SupplierID,
    @UserID,
    DATEADD(DAY, -5, GETDATE()), -- Created 5 days ago
    DATEADD(DAY, 5, GETDATE()),
    55000000, -- 55M VND
    'PENDING',
    3, -- Board approval
    N'Test PO - Should trigger CRITICAL alert (5 days pending, >50M)'
);
PRINT '✅ Test PO 2 created: 5 days pending, 55M VND (CRITICAL priority)';

-- Insert test PO - PENDING for 2 days, small amount (should trigger MEDIUM alert)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(),
    @SupplierID,
    @UserID,
    DATEADD(DAY, -2, GETDATE()), -- Created 2 days ago
    DATEADD(DAY, 10, GETDATE()),
    3500000, -- 3.5M VND
    'PENDING',
    1, -- Manager approval
    N'Test PO - Should trigger MEDIUM priority alert (2 days pending, <10M)'
);
PRINT '✅ Test PO 3 created: 2 days pending, 3.5M VND (MEDIUM priority)';

-- Insert test PO - PENDING for 1 day
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(),
    @SupplierID,
    @UserID,
    DATEADD(DAY, -1, GETDATE()), -- Created 1 day ago
    DATEADD(DAY, 14, GETDATE()),
    8000000, -- 8M VND
    'PENDING',
    1,
    N'Test PO - Should trigger MEDIUM alert (1 day pending, <10M, Level 1)'
);
PRINT '✅ Test PO 4 created: 1 day pending, 8M VND (MEDIUM priority)';

-- Insert test PO - JUST CREATED (0 days - immediate alert test)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(),
    @SupplierID,
    @UserID,
    GETDATE(), -- Created NOW
    DATEADD(DAY, 7, GETDATE()),
    6500000, -- 6.5M VND
    'PENDING',
    1,
    N'Test PO - Vừa mới tạo - Should trigger IMMEDIATE alert (0 days, <10M, Level 1)'
);
PRINT '✅ Test PO 5 created: JUST CREATED (0 days), 6.5M VND - IMMEDIATE ALERT';

-- Insert test PO - NEW with Board Approval (should be CRITICAL due to approval level)
INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, CreateDate, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
VALUES (
    NEWID(),
    @SupplierID,
    @UserID,
    GETDATE(), -- Created NOW
    DATEADD(DAY, 30, GETDATE()),
    35000000, -- 35M VND
    'PENDING',
    3, -- Board approval
    N'Test PO - Vừa mới tạo - Should trigger CRITICAL (Board approval required)'
);
PRINT '✅ Test PO 6 created: JUST CREATED, 35M VND, Level 3 - CRITICAL (Board Approval)';

-- Verify test data
PRINT '';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'TEST DATA SUMMARY:';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
SELECT 
    POID,
    CreateDate,
    DATEDIFF(DAY, CreateDate, GETDATE()) AS DaysPending,
    TotalAmount,
    Status,
    ApprovalLevel,
    CASE 
        WHEN DATEDIFF(DAY, CreateDate, GETDATE()) >= 5 OR TotalAmount >= 50000000 THEN 'CRITICAL'
        WHEN DATEDIFF(DAY, CreateDate, GETDATE()) >= 3 OR TotalAmount >= 10000000 THEN 'HIGH'
        WHEN DATEDIFF(DAY, CreateDate, GETDATE()) >= 2 THEN 'MEDIUM'
        ELSE 'NO ALERT'
    END AS ExpectedPriority,
    Notes
FROM PurchaseOrders
WHERE SupplierID = @SupplierID
ORDER BY CreateDate ASC;

PRINT '';
PRINT '✅ Test data inserted successfully!';
PRINT '';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT '📋 EXPECTED RESULTS (IMMEDIATE ALERT MODE - No waiting period):';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT '   🚨 PO 2 (5 days, 55M, Level 3): CRITICAL (old + high value + Board)';
PRINT '   🚨 PO 6 (NEW, 35M, Level 3): CRITICAL (Board approval required)';
PRINT '   ⚠️  PO 1 (3 days, 12.5M, Level 2): HIGH (old + high value)';
PRINT '   ⏳ PO 3 (2 days, 3.5M, Level 1): MEDIUM';
PRINT '   ⏳ PO 4 (1 day, 8M, Level 1): MEDIUM';
PRINT '   ⏳ PO 5 (NEW, 6.5M, Level 1): MEDIUM';
PRINT '';
PRINT 'Total: 6 POs → 6 alerts (all PENDING trigger immediately)';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT '';
PRINT '🔍 Next steps:';
PRINT '   1. Go to: http://localhost:8080/LiteFlow/alert/test';
PRINT '   2. Click "📋 Check PO Pending" button';
PRINT '   3. Check console for: "Mode: IMMEDIATE alert (no waiting period)"';
PRINT '   4. Refresh dashboard → Click notification bell 🔔';
PRINT '   5. Should see 6 alerts (2 CRITICAL, 1 HIGH, 3 MEDIUM)';
PRINT '';
PRINT '⚡ NEW FEATURE: Alerts trigger IMMEDIATELY when PO status = PENDING';
PRINT '   (No longer need to wait 2 days!)';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

