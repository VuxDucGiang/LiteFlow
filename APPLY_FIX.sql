-- ============================================================
-- APPLY FIX FOR PO APPROVAL BUG
-- Run this script to update database trigger
-- ============================================================

USE LiteFlowDBO;
GO

-- Step 1: Ensure all existing Suppliers have SupplierSLA records
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'Step 1: Creating missing SupplierSLA records...';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

INSERT INTO SupplierSLA (SupplierID, TotalOrders, OnTimeDeliveries, AvgDelayDays, LastEvaluated)
SELECT 
    s.SupplierID,
    0,
    0,
    0,
    SYSUTCDATETIME()
FROM Suppliers s
WHERE NOT EXISTS (
    SELECT 1 FROM SupplierSLA sla 
    WHERE sla.SupplierID = s.SupplierID
);

DECLARE @MissingCount INT = @@ROWCOUNT;
PRINT '✅ Created ' + CAST(@MissingCount AS VARCHAR(10)) + ' missing SupplierSLA records';
GO

-- Step 2: Drop and recreate trigger with fix
PRINT '';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'Step 2: Updating trigger tr_UpdateSupplierSLA...';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

IF OBJECT_ID('tr_UpdateSupplierSLA', 'TR') IS NOT NULL 
BEGIN
    DROP TRIGGER tr_UpdateSupplierSLA;
    PRINT '✅ Dropped old trigger';
END
GO

CREATE TRIGGER tr_UpdateSupplierSLA
ON PurchaseOrders
AFTER UPDATE
AS
BEGIN
    -- CRITICAL: Prevent extra result sets that can confuse JPA/Hibernate
    SET NOCOUNT ON;
    
    -- Only proceed if Status column was actually updated
    IF UPDATE(Status)
    BEGIN
        -- Ensure SupplierSLA records exist for all suppliers
        -- (Create missing ones to prevent silent failures)
        INSERT INTO SupplierSLA (SupplierID, TotalOrders, OnTimeDeliveries, AvgDelayDays, LastEvaluated)
        SELECT DISTINCT i.SupplierID, 0, 0, 0, SYSUTCDATETIME()
        FROM inserted i
        WHERE i.Status IN ('COMPLETED', 'APPROVED', 'REJECTED')
          AND NOT EXISTS (
              SELECT 1 FROM SupplierSLA sla 
              WHERE sla.SupplierID = i.SupplierID
          );
        
        -- Update SLA for suppliers with status changes
        UPDATE sla
        SET 
            TotalOrders = (
                SELECT COUNT(*) 
                FROM PurchaseOrders po 
                WHERE po.SupplierID = sla.SupplierID
            ),
            OnTimeDeliveries = (
                SELECT COUNT(*) 
                FROM PurchaseOrders po 
                WHERE po.SupplierID = sla.SupplierID 
                AND po.Status = 'COMPLETED'
                AND po.ExpectedDelivery >= po.CreateDate
            ),
            LastEvaluated = SYSUTCDATETIME()
        FROM SupplierSLA sla
        WHERE sla.SupplierID IN (
            SELECT DISTINCT SupplierID 
            FROM inserted 
            WHERE Status IN ('COMPLETED', 'APPROVED', 'REJECTED')
        );
    END
END
GO

PRINT '✅ Created new trigger with SET NOCOUNT ON and auto-create logic';
GO

-- Step 3: Verify fix
PRINT '';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'Step 3: Verification';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @SupplierCount INT, @SLACount INT;
SELECT @SupplierCount = COUNT(*) FROM Suppliers WHERE IsActive = 1;
SELECT @SLACount = COUNT(*) FROM SupplierSLA;

PRINT 'Active Suppliers: ' + CAST(@SupplierCount AS VARCHAR(10));
PRINT 'SupplierSLA Records: ' + CAST(@SLACount AS VARCHAR(10));

IF @SupplierCount = @SLACount
    PRINT '✅ All suppliers have SupplierSLA records';
ELSE
    PRINT '⚠️  WARNING: Mismatch detected!';

PRINT '';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT '✅ DATABASE FIX COMPLETE!';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT 'Next steps:';
PRINT '  1. RESTART Tomcat server';
PRINT '  2. Hard refresh browser (Ctrl+Shift+R)';
PRINT '  3. Test PO approval';
PRINT '  4. Check console logs for:';
PRINT '     - "🔥 USING NATIVE SQL UPDATE..."';
PRINT '     - "📌 Native SQL UPDATE executed - Rows affected: 1"';
PRINT '     - "📌 VERIFICATION: Status in DB = APPROVED"';
PRINT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

