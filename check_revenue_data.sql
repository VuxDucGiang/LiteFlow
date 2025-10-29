-- ================================================
-- SCRIPT KIỂM TRA DỮ LIỆU CHO BÁO CÁO DOANH THU
-- ================================================

USE LiteFlow;
GO

PRINT '========================================';
PRINT '1. KIỂM TRA CẤU TRÚC TABLE Orders';
PRINT '========================================';

-- Xem structure của Orders table
SELECT TOP 5 
    OrderID,
    OrderNumber,
    OrderDate,
    SubTotal,
    VAT,
    TotalAmount,
    Status,
    PaymentStatus,
    PaymentMethod
FROM Orders
ORDER BY OrderDate DESC;

PRINT '';
PRINT '========================================';
PRINT '2. THỐNG KÊ STATUS CỦA ORDERS';
PRINT '========================================';

-- Đếm số orders theo status
SELECT 
    Status,
    PaymentStatus,
    COUNT(*) as OrderCount,
    SUM(TotalAmount) as TotalRevenue
FROM Orders
GROUP BY Status, PaymentStatus
ORDER BY OrderCount DESC;

PRINT '';
PRINT '========================================';
PRINT '3. ORDERS ĐÃ THANH TOÁN (30 NGÀY GẦN NHẤT)';
PRINT '========================================';

-- Orders đã thanh toán trong 30 ngày gần nhất
SELECT 
    COUNT(*) as PaidOrderCount,
    SUM(TotalAmount) as TotalRevenue,
    MIN(OrderDate) as EarliestOrder,
    MAX(OrderDate) as LatestOrder
FROM Orders
WHERE PaymentStatus = 'Paid'
  AND OrderDate >= DATEADD(DAY, -30, GETDATE());

PRINT '';
PRINT '========================================';
PRINT '4. CHI TIẾT 5 ORDERS GẦN NHẤT ĐÃ THANH TOÁN';
PRINT '========================================';

SELECT TOP 5
    o.OrderNumber,
    o.OrderDate,
    o.Status,
    o.PaymentStatus,
    o.SubTotal,
    o.VAT,
    o.TotalAmount,
    COUNT(od.OrderDetailID) as ItemCount
FROM Orders o
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE o.PaymentStatus = 'Paid'
GROUP BY 
    o.OrderNumber,
    o.OrderDate,
    o.Status,
    o.PaymentStatus,
    o.SubTotal,
    o.VAT,
    o.TotalAmount
ORDER BY o.OrderDate DESC;

PRINT '';
PRINT '========================================';
PRINT '5. KIỂM TRA OrderDetails';
PRINT '========================================';

-- Kiểm tra OrderDetails structure
SELECT TOP 5
    od.OrderDetailID,
    od.OrderID,
    od.ProductVariantID,
    od.Quantity,
    od.UnitPrice,
    od.TotalPrice,
    od.Status
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.PaymentStatus = 'Paid'
ORDER BY od.CreatedAt DESC;

PRINT '';
PRINT '========================================';
PRINT '6. DOANH THU THEO NGÀY (7 NGÀY GẦN NHẤT)';
PRINT '========================================';

SELECT 
    CAST(OrderDate AS DATE) as OrderDay,
    COUNT(*) as OrderCount,
    SUM(TotalAmount) as DailyRevenue
FROM Orders
WHERE PaymentStatus = 'Paid'
  AND OrderDate >= DATEADD(DAY, -7, GETDATE())
GROUP BY CAST(OrderDate AS DATE)
ORDER BY OrderDay DESC;

PRINT '';
PRINT '========================================';
PRINT '✅ HOÀN TẤT KIỂM TRA';
PRINT '========================================';

