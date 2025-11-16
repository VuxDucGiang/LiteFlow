-- ============================================================
-- MIGRATION: Add SUPPLIER_MAPPING category
-- Di chuyển po.supplier_mapping từ PO_AUTO sang SUPPLIER_MAPPING
-- ============================================================

USE LiteFlowDBO;
GO

-- Step 1: Update CHECK constraint to allow new category
-- Note: SQL Server doesn't support ALTER CHECK constraint directly
-- You may need to drop and recreate the constraint if it exists
-- This is a manual step if the constraint already exists

-- Step 2: Update existing po.supplier_mapping config to new category
IF EXISTS (SELECT 1 FROM AIAgentConfigurations WHERE ConfigKey = 'po.supplier_mapping' AND Category = 'PO_AUTO')
BEGIN
    UPDATE AIAgentConfigurations
    SET Category = 'SUPPLIER_MAPPING',
        UpdatedAt = SYSDATETIME()
    WHERE ConfigKey = 'po.supplier_mapping' AND Category = 'PO_AUTO';
    
    PRINT '✅ Updated po.supplier_mapping category from PO_AUTO to SUPPLIER_MAPPING';
END
ELSE
BEGIN
    -- If config doesn't exist, insert it
    DECLARE @AdminUserID UNIQUEIDENTIFIER;
    SELECT TOP 1 @AdminUserID = u.UserID 
    FROM Users u
    INNER JOIN UserRoles ur ON u.UserID = ur.UserID
    INNER JOIN Roles r ON ur.RoleID = r.RoleID
    WHERE r.Name = 'ADMIN' AND ur.IsActive = 1
    ORDER BY u.CreatedAt;
    
    IF @AdminUserID IS NULL
    BEGIN
        SELECT TOP 1 @AdminUserID = UserID FROM Users ORDER BY CreatedAt;
    END;
    
    IF NOT EXISTS (SELECT 1 FROM AIAgentConfigurations WHERE ConfigKey = 'po.supplier_mapping')
    BEGIN
        INSERT INTO AIAgentConfigurations (ConfigKey, ConfigValue, ConfigType, Category, DisplayName, Description, MinValue, MaxValue, DefaultValue, IsActive, UpdatedBy)
        VALUES
            ('po.supplier_mapping', '{}', 'JSON', 'SUPPLIER_MAPPING', N'Ánh xạ nhà cung cấp theo danh mục', N'Thiết lập nhà cung cấp cho từng danh mục sản phẩm (JSON: {"CategoryName": "SupplierID"})', NULL, NULL, '{}', 1, @AdminUserID);
        
        PRINT '✅ Inserted po.supplier_mapping config with SUPPLIER_MAPPING category';
    END
END
GO

PRINT '✅ Migration completed: SUPPLIER_MAPPING category added';
GO

