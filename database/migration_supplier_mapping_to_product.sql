-- ============================================================
-- MIGRATION: Convert supplier mapping from category to product
-- Chuyển đổi format từ {"CategoryName": "SupplierID"} 
-- sang {"ProductName": "SupplierID"}
-- ============================================================

USE LiteFlowDBO;
GO

-- Note: Migration này không tự động convert data vì:
-- 1. Không thể tự động map category -> products (cần user chọn)
-- 2. Một category có thể có nhiều products với suppliers khác nhau
-- 3. User cần tự cấu hình lại mapping theo từng sản phẩm

-- Script này chỉ để thông báo và hướng dẫn
PRINT '============================================================';
PRINT 'MIGRATION: Supplier Mapping Format Change';
PRINT '============================================================';
PRINT '';
PRINT 'Format cũ: {"CategoryName": "SupplierID"}';
PRINT 'Format mới: {"ProductName": "SupplierID"}';
PRINT '';
PRINT 'LƯU Ý:';
PRINT '- Format mapping đã thay đổi từ category sang product';
PRINT '- Data cũ sẽ không tự động convert';
PRINT '- Vui lòng vào Settings -> AI Agent -> Ánh xạ Nhà cung cấp';
PRINT '  để cấu hình lại mapping theo từng sản phẩm';
PRINT '';
PRINT '- Hệ thống vẫn hỗ trợ backward compatibility:';
PRINT '  Nếu không tìm thấy product mapping, sẽ fallback về category mapping';
PRINT '';
PRINT '============================================================';
GO

-- Optional: Clear old mapping data nếu muốn bắt đầu từ đầu
-- UNCOMMENT dòng dưới nếu muốn xóa data cũ:
-- UPDATE AIAgentConfigurations 
-- SET ConfigValue = '{}', UpdatedAt = SYSDATETIME()
-- WHERE ConfigKey = 'po.supplier_mapping';

PRINT '✅ Migration script completed';
PRINT '   Please reconfigure supplier mapping in Settings -> AI Agent -> Ánh xạ Nhà cung cấp';
GO

