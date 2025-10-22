-- ============================================================
-- SAMPLE DATA FOR PROCUREMENT MODULE - UPDATED
-- Based on current system implementation
-- ============================================================

USE LiteFlowDBO;
GO

-- ============================================================
-- 1️⃣ SUPPLIERS (Nhà cung cấp) - Current Data
-- ============================================================
-- Clear existing data first
DELETE FROM SupplierSLA WHERE SupplierID IN (SELECT SupplierID FROM Suppliers);
DELETE FROM PurchaseOrderItems WHERE POID IN (SELECT POID FROM PurchaseOrders);
DELETE FROM GoodsReceipts WHERE POID IN (SELECT POID FROM PurchaseOrders);
DELETE FROM Invoices WHERE POID IN (SELECT POID FROM PurchaseOrders);
DELETE FROM PurchaseOrders;
DELETE FROM Suppliers;

-- Insert current suppliers
INSERT INTO Suppliers (Name, Contact, Email, Phone, Address, Rating, OnTimeRate, DefectRate, IsActive, CreatedBy)
VALUES
(N'Công ty Cà phê Trung Nguyên', N'Nguyễn Văn A', 'contact@trungnguyen.com.vn', '028-1234567', N'123 Nguyễn Văn Cừ, Q.5, TP.HCM', 4.5, 95.0, 2.0, 1, 
 (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn')),

(N'Nhà cung cấp Sữa Vinamilk', N'Trần Thị B', 'sales@vinamilk.com.vn', '028-2345678', N'456 Lê Văn Việt, Q.9, TP.HCM', 4.8, 98.0, 1.5, 1,
 (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn')),

(N'Bánh kẹo Kinh Đô', N'Lê Văn C', 'kinhdo@kinhdo.com.vn', '028-3456789', N'789 Điện Biên Phủ, Q.Bình Thạnh, TP.HCM', 4.2, 90.0, 3.0, 1,
 (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn')),

(N'Nhà cung cấp Trái cây tươi', N'Phạm Thị D', 'fruits@fresh.com.vn', '028-4567890', N'321 Cách Mạng Tháng 8, Q.10, TP.HCM', 4.0, 85.0, 5.0, 1,
 (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn')),

(N'Nguyên liệu pha chế ABC', N'Hoàng Văn E', 'abc@ingredients.com.vn', '028-5678901', N'654 Nguyễn Thị Minh Khai, Q.3, TP.HCM', 4.6, 92.0, 2.5, 1,
 (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn')),

-- Additional suppliers for testing
(N'Công ty Thực phẩm Đông lạnh XYZ', N'Võ Thị F', 'frozen@xyz.com.vn', '028-6789012', N'987 Võ Văn Tần, Q.3, TP.HCM', 4.3, 88.0, 4.0, 1,
 (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn')),

(N'Nhà cung cấp Đồ uống Pepsi', N'Đặng Văn G', 'pepsi@pepsi.com.vn', '028-7890123', N'147 Nguyễn Huệ, Q.1, TP.HCM', 4.7, 96.0, 1.8, 1,
 (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn'));
GO

-- ============================================================
-- 2️⃣ SUPPLIER SLA (Theo dõi hiệu suất)
-- ============================================================
INSERT INTO SupplierSLA (SupplierID, TotalOrders, OnTimeDeliveries, AvgDelayDays, LastEvaluated)
SELECT 
    s.SupplierID,
    CASE s.Name
        WHEN N'Công ty Cà phê Trung Nguyên' THEN 25
        WHEN N'Nhà cung cấp Sữa Vinamilk' THEN 30
        WHEN N'Bánh kẹo Kinh Đô' THEN 15
        WHEN N'Nhà cung cấp Trái cây tươi' THEN 20
        WHEN N'Nguyên liệu pha chế ABC' THEN 18
        WHEN N'Công ty Thực phẩm Đông lạnh XYZ' THEN 12
        WHEN N'Nhà cung cấp Đồ uống Pepsi' THEN 22
    END,
    CASE s.Name
        WHEN N'Công ty Cà phê Trung Nguyên' THEN 24
        WHEN N'Nhà cung cấp Sữa Vinamilk' THEN 29
        WHEN N'Bánh kẹo Kinh Đô' THEN 13
        WHEN N'Nhà cung cấp Trái cây tươi' THEN 17
        WHEN N'Nguyên liệu pha chế ABC' THEN 16
        WHEN N'Công ty Thực phẩm Đông lạnh XYZ' THEN 10
        WHEN N'Nhà cung cấp Đồ uống Pepsi' THEN 21
    END,
    CASE s.Name
        WHEN N'Công ty Cà phê Trung Nguyên' THEN 0.5
        WHEN N'Nhà cung cấp Sữa Vinamilk' THEN 0.2
        WHEN N'Bánh kẹo Kinh Đô' THEN 1.0
        WHEN N'Nhà cung cấp Trái cây tươi' THEN 1.5
        WHEN N'Nguyên liệu pha chế ABC' THEN 0.8
        WHEN N'Công ty Thực phẩm Đông lạnh XYZ' THEN 1.2
        WHEN N'Nhà cung cấp Đồ uống Pepsi' THEN 0.3
    END,
    DATEADD(DAY, -7, SYSDATETIME())
FROM Suppliers s;
GO

-- ============================================================
-- 3️⃣ PURCHASE ORDERS (Đơn đặt hàng) - Various Status
-- ============================================================

-- APPROVED Orders
INSERT INTO PurchaseOrders (SupplierID, CreatedBy, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
SELECT 
    s.SupplierID,
    (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn'),
    DATEADD(DAY, 7, SYSDATETIME()),
    CASE s.Name
        WHEN N'Công ty Cà phê Trung Nguyên' THEN 2500000
        WHEN N'Nhà cung cấp Sữa Vinamilk' THEN 1800000
        WHEN N'Bánh kẹo Kinh Đô' THEN 1200000
        WHEN N'Nhà cung cấp Trái cây tươi' THEN 800000
        WHEN N'Nguyên liệu pha chế ABC' THEN 1500000
        WHEN N'Công ty Thực phẩm Đông lạnh XYZ' THEN 1100000
        WHEN N'Nhà cung cấp Đồ uống Pepsi' THEN 2000000
    END,
    'APPROVED',
    1,
    N'Đơn hàng tháng ' + CAST(MONTH(SYSDATETIME()) AS NVARCHAR(2)) + N'/' + CAST(YEAR(SYSDATETIME()) AS NVARCHAR(4))
FROM Suppliers s
WHERE s.Name IN (N'Công ty Cà phê Trung Nguyên', N'Nhà cung cấp Sữa Vinamilk', N'Nguyên liệu pha chế ABC', N'Nhà cung cấp Đồ uống Pepsi');
GO

-- PENDING Orders
INSERT INTO PurchaseOrders (SupplierID, CreatedBy, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
SELECT 
    s.SupplierID,
    (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn'),
    DATEADD(DAY, 14, SYSDATETIME()),
    CASE s.Name
        WHEN N'Bánh kẹo Kinh Đô' THEN 900000
        WHEN N'Nhà cung cấp Trái cây tươi' THEN 750000
        WHEN N'Công ty Thực phẩm Đông lạnh XYZ' THEN 650000
    END,
    'PENDING',
    1,
    N'Đơn hàng bổ sung nguyên liệu - chờ duyệt'
FROM Suppliers s
WHERE s.Name IN (N'Bánh kẹo Kinh Đô', N'Nhà cung cấp Trái cây tươi', N'Công ty Thực phẩm Đông lạnh XYZ');
GO

-- REJECTED Orders
INSERT INTO PurchaseOrders (SupplierID, CreatedBy, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
SELECT 
    s.SupplierID,
    (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn'),
    DATEADD(DAY, 10, SYSDATETIME()),
    500000,
    'REJECTED',
    1,
    N'Đơn hàng bị từ chối - giá quá cao'
FROM Suppliers s
WHERE s.Name = N'Bánh kẹo Kinh Đô';
GO

-- RECEIVING Orders
INSERT INTO PurchaseOrders (SupplierID, CreatedBy, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
SELECT 
    s.SupplierID,
    (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn'),
    DATEADD(DAY, 3, SYSDATETIME()),
    1300000,
    'RECEIVING',
    1,
    N'Đang nhận hàng - kiểm tra chất lượng'
FROM Suppliers s
WHERE s.Name = N'Nguyên liệu pha chế ABC';
GO

-- COMPLETED Orders
INSERT INTO PurchaseOrders (SupplierID, CreatedBy, ExpectedDelivery, TotalAmount, Status, ApprovalLevel, Notes)
SELECT 
    s.SupplierID,
    (SELECT UserID FROM Users WHERE Email = 'procurement@liteflow.vn'),
    DATEADD(DAY, -5, SYSDATETIME()),
    1600000,
    'COMPLETED',
    1,
    N'Đơn hàng đã hoàn thành'
FROM Suppliers s
WHERE s.Name = N'Công ty Cà phê Trung Nguyên';
GO

-- ============================================================
-- 4️⃣ PURCHASE ORDER ITEMS (Chi tiết đơn hàng)
-- ============================================================

-- Cà phê Trung Nguyên (APPROVED)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Cà phê Arabica Premium',
    50,
    25000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Công ty Cà phê Trung Nguyên' AND po.Status = 'APPROVED';

INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Cà phê Robusta Đặc biệt',
    30,
    20000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Công ty Cà phê Trung Nguyên' AND po.Status = 'APPROVED';

-- Cà phê Trung Nguyên (COMPLETED)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Cà phê Espresso',
    40,
    30000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Công ty Cà phê Trung Nguyên' AND po.Status = 'COMPLETED';

-- Sữa Vinamilk (APPROVED)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Sữa tươi Vinamilk 1L',
    100,
    18000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Nhà cung cấp Sữa Vinamilk' AND po.Status = 'APPROVED';

-- Bánh kẹo Kinh Đô (PENDING)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Bánh quy Kinh Đô',
    200,
    6000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Bánh kẹo Kinh Đô' AND po.Status = 'PENDING';

INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Bánh mì sandwich',
    100,
    9000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Bánh kẹo Kinh Đô' AND po.Status = 'PENDING';

-- Bánh kẹo Kinh Đô (REJECTED)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Kẹo dẻo',
    50,
    10000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Bánh kẹo Kinh Đô' AND po.Status = 'REJECTED';

-- Trái cây tươi (PENDING)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Xoài tươi',
    50,
    16000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Nhà cung cấp Trái cây tươi' AND po.Status = 'PENDING';

-- Nguyên liệu pha chế (APPROVED)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Syrup vani',
    20,
    75000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Nguyên liệu pha chế ABC' AND po.Status = 'APPROVED';

-- Nguyên liệu pha chế (RECEIVING)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Syrup chocolate',
    15,
    80000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Nguyên liệu pha chế ABC' AND po.Status = 'RECEIVING';

-- Thực phẩm đông lạnh (PENDING)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Thịt bò đông lạnh',
    30,
    22000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Công ty Thực phẩm Đông lạnh XYZ' AND po.Status = 'PENDING';

-- Đồ uống Pepsi (APPROVED)
INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
SELECT 
    po.POID,
    N'Pepsi 330ml',
    200,
    10000
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name = N'Nhà cung cấp Đồ uống Pepsi' AND po.Status = 'APPROVED';
GO

-- ============================================================
-- 5️⃣ GOODS RECEIPTS (Phiếu nhận hàng)
-- ============================================================
INSERT INTO GoodsReceipts (POID, ReceivedBy, ReceiveDate, Notes, Status)
SELECT 
    po.POID,
    (SELECT UserID FROM Users WHERE Email = 'inventory@liteflow.vn'),
    DATEADD(DAY, -2, SYSDATETIME()),
    N'Đã nhận đầy đủ hàng hóa, chất lượng tốt',
    'FULL'
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name IN (N'Công ty Cà phê Trung Nguyên', N'Nhà cung cấp Sữa Vinamilk') AND po.Status = 'APPROVED';
GO

-- ============================================================
-- 6️⃣ INVOICES (Hóa đơn)
-- ============================================================
INSERT INTO Invoices (POID, SupplierID, InvoiceDate, TotalAmount, Matched, MatchNote)
SELECT 
    po.POID,
    po.SupplierID,
    DATEADD(DAY, -1, SYSDATETIME()),
    po.TotalAmount,
    1,
    N'Khớp với đơn hàng'
FROM PurchaseOrders po
JOIN Suppliers s ON s.SupplierID = po.SupplierID
WHERE s.Name IN (N'Công ty Cà phê Trung Nguyên', N'Nhà cung cấp Sữa Vinamilk') AND po.Status = 'APPROVED';
GO

-- ============================================================
-- 7️⃣ UPDATE PURCHASE ORDER TOTALS
-- ============================================================
UPDATE po 
SET TotalAmount = (
    SELECT ISNULL(SUM(Quantity * UnitPrice), 0)
    FROM PurchaseOrderItems poi 
    WHERE poi.POID = po.POID
)
FROM PurchaseOrders po;
GO

-- ============================================================
-- 8️⃣ SUMMARY AND VERIFICATION
-- ============================================================
DECLARE @SupplierCount INT, @POCount INT, @POItemCount INT, @GRCount INT, @InvoiceCount INT;

SELECT @SupplierCount = COUNT(*) FROM Suppliers;
SELECT @POCount = COUNT(*) FROM PurchaseOrders;
SELECT @POItemCount = COUNT(*) FROM PurchaseOrderItems;
SELECT @GRCount = COUNT(*) FROM GoodsReceipts;
SELECT @InvoiceCount = COUNT(*) FROM Invoices;

PRINT '========================================';
PRINT 'PROCUREMENT SAMPLE DATA INSERTED SUCCESSFULLY!';
PRINT '========================================';
PRINT 'Total Suppliers: ' + CAST(@SupplierCount AS NVARCHAR(10));
PRINT 'Total Purchase Orders: ' + CAST(@POCount AS NVARCHAR(10));
PRINT 'Total Purchase Order Items: ' + CAST(@POItemCount AS NVARCHAR(10));
PRINT 'Total Goods Receipts: ' + CAST(@GRCount AS NVARCHAR(10));
PRINT 'Total Invoices: ' + CAST(@InvoiceCount AS NVARCHAR(10));
PRINT '========================================';

-- Display status breakdown
SELECT 
    Status,
    COUNT(*) as Count,
    SUM(TotalAmount) as TotalValue
FROM PurchaseOrders 
GROUP BY Status
ORDER BY Status;

PRINT '========================================';
PRINT 'Purchase Orders by Status:';
PRINT '========================================';
GO