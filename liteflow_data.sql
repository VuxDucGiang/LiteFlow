-- ================================
-- SAMPLE DATA FOR LITEFLOW CAFE ☕
-- Version: 2025-10
-- ================================

USE LiteFlowDBO;
GO

-- ============================================================
-- 🗑️ DELETE ALL EXISTING DATA (CLEAN SLATE)
-- ============================================================
-- Delete in reverse order of dependencies to avoid foreign key constraints

-- Delete payment transactions first
DELETE FROM PaymentTransactions;
GO

-- Delete order details
DELETE FROM OrderDetails;
GO

-- Delete orders
DELETE FROM Orders;
GO

-- Delete table sessions
DELETE FROM TableSessions;
GO

-- Delete scheduling data (shifts -> assignments -> templates)
DELETE FROM EmployeeShifts;
GO
DELETE FROM EmployeeShiftAssignments;
GO
DELETE FROM ShiftTemplates;
GO

-- Delete employees
DELETE FROM Employees;
GO

-- Delete user roles
DELETE FROM UserRoles;
GO

-- Delete users
DELETE FROM Users;
GO

-- Delete roles
DELETE FROM Roles;
GO

-- Delete product stock
DELETE FROM ProductStock;
GO

-- Delete inventory
DELETE FROM Inventory;
GO

-- Delete product categories mapping
DELETE FROM ProductsCategories;
GO

-- Delete product variants
DELETE FROM ProductVariant;
GO

-- Delete products
DELETE FROM Products;
GO

-- Delete categories
DELETE FROM Categories;
GO

-- Delete tables
DELETE FROM Tables;
GO

-- Delete rooms
DELETE FROM Rooms;
GO

-- ============================================================
-- 1️⃣ CATEGORIES
-- ============================================================
INSERT INTO Categories (Name, Description) VALUES
(N'Cà phê', N'Các loại cà phê truyền thống và hiện đại'),
(N'Trà', N'Trà hoa quả, trà sữa, trà thảo mộc'),
(N'Sinh tố & Nước ép', N'Nước ép trái cây tươi, sinh tố dinh dưỡng'),
(N'Bánh ngọt', N'Bánh ngọt dùng kèm cà phê, trà'),
(N'Snack', N'Đồ ăn nhẹ kèm đồ uống');
GO


-- ============================================================
-- 2️⃣ PRODUCTS
-- ============================================================
INSERT INTO Products (Name, Description, ImageURL) VALUES
(N'Cà phê đen', N'Cà phê phin truyền thống Việt Nam, đậm vị', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Cà phê sữa đá', N'Cà phê phin pha sữa đặc, vị ngọt béo', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Latte', N'Cà phê espresso với sữa nóng và lớp foam', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Trà đào cam sả', N'Trà đào kết hợp cam và sả, vị thanh mát', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Trà sữa trân châu', N'Trà sữa ngọt dịu kèm trân châu đen', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Sinh tố xoài', N'Sinh tố xoài tươi, ngọt mát', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Nước ép cam', N'Nước cam vắt tươi nguyên chất', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Bánh tiramisu', N'Bánh tiramisu Ý, mềm xốp, vị cà phê', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Croissant bơ', N'Bánh croissant Pháp, giòn thơm vị bơ', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F'),
(N'Khoai tây chiên', N'Khoai tây chiên giòn vàng', 'https://www.eatright.org/-/media/images/eatright-articles/eatright-article-feature-images/benefitsofcoffee_600x450.jpg?h=450&w=600&rev=6c8a9cd4a94d4cac8af8543054fd7b07&hash=F64F1F79DE48F33E3FB6A4FD5979C51F');
GO


-- ============================================================
-- 3️⃣ PRODUCT VARIANTS
-- ============================================================
-- Cà phê đen
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'S', 15000, 20000 FROM Products WHERE Name = N'Cà phê đen';
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'M', 20000, 25000 FROM Products WHERE Name = N'Cà phê đen';

-- Cà phê sữa đá
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'S', 20000, 25000 FROM Products WHERE Name = N'Cà phê sữa đá';
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'M', 25000, 30000 FROM Products WHERE Name = N'Cà phê sữa đá';

-- Latte
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'M', 35000, 40000 FROM Products WHERE Name = N'Latte';
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'L', 40000, 45000 FROM Products WHERE Name = N'Latte';

-- Trà đào cam sả
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'M', 30000, 35000 FROM Products WHERE Name = N'Trà đào cam sả';
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'L', 35000, 40000 FROM Products WHERE Name = N'Trà đào cam sả';

-- Trà sữa trân châu
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'M', 30000, 35000 FROM Products WHERE Name = N'Trà sữa trân châu';
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'L', 35000, 40000 FROM Products WHERE Name = N'Trà sữa trân châu';

-- Sinh tố xoài
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'M', 35000, 40000 FROM Products WHERE Name = N'Sinh tố xoài';

-- Nước ép cam
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'M', 25000, 30000 FROM Products WHERE Name = N'Nước ép cam';

-- Bánh tiramisu
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, '1 miếng', 40000, 45000 FROM Products WHERE Name = N'Bánh tiramisu';

-- Croissant bơ
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, '1 cái', 20000, 25000 FROM Products WHERE Name = N'Croissant bơ';

-- Khoai tây chiên
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'Phần nhỏ', 20000, 25000 FROM Products WHERE Name = N'Khoai tây chiên';
INSERT INTO ProductVariant (ProductID, Size, OriginalPrice, Price)
SELECT ProductID, 'Phần lớn', 30000, 35000 FROM Products WHERE Name = N'Khoai tây chiên';
GO


-- ============================================================
-- 4️⃣ PRODUCT - CATEGORY MAPPING
-- ============================================================
INSERT INTO ProductsCategories (ProductID, CategoryID)
SELECT p.ProductID, c.CategoryID FROM Products p JOIN Categories c ON c.Name = N'Cà phê'
WHERE p.Name IN (N'Cà phê đen', N'Cà phê sữa đá', N'Latte');

INSERT INTO ProductsCategories (ProductID, CategoryID)
SELECT p.ProductID, c.CategoryID FROM Products p JOIN Categories c ON c.Name = N'Trà'
WHERE p.Name IN (N'Trà đào cam sả', N'Trà sữa trân châu');

INSERT INTO ProductsCategories (ProductID, CategoryID)
SELECT p.ProductID, c.CategoryID FROM Products p JOIN Categories c ON c.Name = N'Sinh tố & Nước ép'
WHERE p.Name IN (N'Sinh tố xoài', N'Nước ép cam');

INSERT INTO ProductsCategories (ProductID, CategoryID)
SELECT p.ProductID, c.CategoryID FROM Products p JOIN Categories c ON c.Name = N'Bánh ngọt'
WHERE p.Name IN (N'Bánh tiramisu', N'Croissant bơ');

INSERT INTO ProductsCategories (ProductID, CategoryID)
SELECT p.ProductID, c.CategoryID FROM Products p JOIN Categories c ON c.Name = N'Snack'
WHERE p.Name IN (N'Khoai tây chiên');
GO


-- ============================================================
-- 5️⃣ INVENTORY & PRODUCT STOCK
-- ============================================================
INSERT INTO Inventory (StoreLocation) VALUES (N'Kho chính');

INSERT INTO ProductStock (ProductVariantID, InventoryID, Amount)
SELECT pv.ProductVariantID, i.InventoryID, 100
FROM ProductVariant pv CROSS JOIN Inventory i;
GO


-- ============================================================
-- 6️⃣ USERS, ROLES, USERROLES, ADMIN
-- ============================================================
-- USERS
INSERT INTO Users (Email, Phone, GoogleID, PasswordHash, TwoFactorSecret, DisplayName, IsActive, Meta)
VALUES
('owner@liteflow.vn', '0901000001', 'google-oauth2|1234567890', '$2a$12$CrcHqEZraWVdxVOSE2w28uT2NVJjrxDekdHKsXygHbGpMiUCXhmUW', '2FA1', N'Nguyễn Văn A - Owner', 1, N'{"role":"Owner"}'),
('cashier1@liteflow.vn', '0901000002', NULL, '$2a$12$CrcHqEZraWVdxVOSE2w28uT2NVJjrxDekdHKsXygHbGpMiUCXhmUW', NULL, N'Trần Thị B - Cashier', 1, N'{"role":"Cashier"}'),
('inventory@liteflow.vn', '0901000003', NULL, '$2a$12$CrcHqEZraWVdxVOSE2w28uT2NVJjrxDekdHKsXygHbGpMiUCXhmUW', '2FA3', N'Lê Văn C - Inventory', 1, N'{"role":"Inventory Manager"}'),
('procurement@liteflow.vn', '0901000004', NULL, '$2a$12$CrcHqEZraWVdxVOSE2w28uT2NVJjrxDekdHKsXygHbGpMiUCXhmUW', NULL, N'Phạm Thị D - Procurement', 1, N'{"role":"Procurement Officer"}'),
('hr@liteflow.vn', '0901000005', 'google-oauth2|987654321', '$2a$12$CrcHqEZraWVdxVOSE2w28uT2NVJjrxDekdHKsXygHbGpMiUCXhmUW', '2FA5', N'Hoàng Văn E - HR', 1, N'{"role":"HR Officer"}'),
('employee1@liteflow.vn', '0901000006', NULL, '$2a$12$CrcHqEZraWVdxVOSE2w28uT2NVJjrxDekdHKsXygHbGpMiUCXhmUW', NULL, N'Đỗ Thị F - Staff', 1, N'{"role":"Employee"}');
GO

-- ROLES
INSERT INTO Roles (Name, Description) VALUES
('Owner', 'System owner/manager'),
('Cashier', 'Point of Sale operator'),
('Inventory Manager', 'Manage stock and products'),
('Procurement Officer', 'Manage purchase orders and suppliers'),
('HR Officer', 'Handle HR and payroll'),
('Employee', 'General staff'),
('Admin', 'Administrator with full access');
GO

-- USERROLES
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID FROM Users u JOIN Roles r ON u.Meta LIKE '%Owner%' AND r.Name = 'Owner'
UNION ALL
SELECT u.UserID, r.RoleID FROM Users u JOIN Roles r ON u.Meta LIKE '%Cashier%' AND r.Name = 'Cashier'
UNION ALL
SELECT u.UserID, r.RoleID FROM Users u JOIN Roles r ON u.Meta LIKE '%Inventory%' AND r.Name = 'Inventory Manager'
UNION ALL
SELECT u.UserID, r.RoleID FROM Users u JOIN Roles r ON u.Meta LIKE '%Procurement%' AND r.Name = 'Procurement Officer'
UNION ALL
SELECT u.UserID, r.RoleID FROM Users u JOIN Roles r ON u.Meta LIKE '%HR%' AND r.Name = 'HR Officer'
UNION ALL
SELECT u.UserID, r.RoleID FROM Users u JOIN Roles r ON u.Meta LIKE '%Employee%' AND r.Name = 'Employee';
GO

-- ADMIN DEV ACCOUNT
DECLARE @AdminID UNIQUEIDENTIFIER = NEWID();
DECLARE @AdminEmail NVARCHAR(320) = N'admin@liteflow.com';
DECLARE @AdminHash NVARCHAR(MAX) = N'$2a$12$bSyne//LHFXF0lzzK4jBbu./rIRSHdTcH7VuMMQLk7U9hPMtK5BgC'; -- password = "1"

IF NOT EXISTS (SELECT 1 FROM Users WHERE LOWER(Email) = LOWER(@AdminEmail))
BEGIN
    INSERT INTO Users (UserID, Email, Phone, PasswordHash, DisplayName, IsActive, Meta)
    VALUES (@AdminID, @AdminEmail, N'0901000000', @AdminHash, N'LiteFlow Admin', 1, N'{}');
END
ELSE
BEGIN
    SELECT @AdminID = UserID FROM Users WHERE LOWER(Email) = LOWER(@AdminEmail);
    UPDATE Users
    SET PasswordHash = @AdminHash,
        IsActive = 1,
        DisplayName = N'LiteFlow Admin'
    WHERE UserID = @AdminID;
END

INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID
FROM Users u
JOIN Roles r ON r.Name = 'Admin'
WHERE u.Email = 'admin@liteflow.com';
GO


-- ============================================================
-- 7️⃣ ROOMS & TABLES - QUÁN ĂN THỰC TẾ
-- ============================================================
INSERT INTO Rooms (Name, Description, TableCount, TotalCapacity) VALUES
(N'Khu Vực Lễ Tân', N'Khu vực gần lễ tân, tiện lợi cho khách hàng vãng lai', 8, 32),
(N'Phòng Gia Đình', N'Phòng dành cho gia đình, không gian ấm cúng, phù hợp cho trẻ em', 6, 24),
(N'Phòng Họp', N'Phòng họp riêng tư cho khách VIP, trang bị đầy đủ tiện nghi', 4, 20),
(N'Phòng Ngoài Trời', N'Khu vực ngoài trời, thoáng mát, phù hợp cho khách hàng thích không gian tự nhiên', 5, 20),
(N'Phòng Làm Việc', N'Phòng yên tĩnh cho khách hàng làm việc, có wifi tốt', 8, 32),
(N'Khu Vực Bar', N'Khu vực bar với không gian mở, phù hợp cho nhóm bạn', 6, 24),
(N'Phòng VIP', N'Phòng VIP cao cấp, không gian sang trọng, phục vụ khách hàng đặc biệt', 3, 12),
(N'Tầng 2', N'Tầng 2 với view đẹp, không gian yên tĩnh và riêng tư', 7, 28);
GO

INSERT INTO Tables (RoomID, TableNumber, TableName, Capacity, Status) VALUES
-- Khu Vực Lễ Tân (8 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-01', N'Bàn Lễ Tân 1', 2, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-02', N'Bàn Lễ Tân 2', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-03', N'Bàn Lễ Tân 3', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-04', N'Bàn Lễ Tân 4', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-05', N'Bàn Lễ Tân 5', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-06', N'Bàn Lễ Tân 6', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-07', N'Bàn Lễ Tân 7', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-08', N'Bàn Lễ Tân 8', 4, 'Available'),

-- Phòng Gia Đình (6 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Gia Đình'), 'GD-01', N'Bàn Gia Đình 1', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Gia Đình'), 'GD-02', N'Bàn Gia Đình 2', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Gia Đình'), 'GD-03', N'Bàn Gia Đình 3', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Gia Đình'), 'GD-04', N'Bàn Gia Đình 4', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Gia Đình'), 'GD-05', N'Bàn Gia Đình 5', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Gia Đình'), 'GD-06', N'Bàn Gia Đình 6', 2, 'Available'),

-- Phòng Họp (4 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Họp'), 'H-01', N'Bàn Họp 1', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Họp'), 'H-02', N'Bàn Họp 2', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Họp'), 'H-03', N'Bàn Họp 3', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Họp'), 'H-04', N'Bàn Họp 4', 4, 'Available'),

-- Phòng Ngoài Trời (5 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-01', N'Bàn Ngoài Trời 1', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-02', N'Bàn Ngoài Trời 2', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-03', N'Bàn Ngoài Trời 3', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-04', N'Bàn Ngoài Trời 4', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-05', N'Bàn Ngoài Trời 5', 4, 'Available'),

-- Phòng Làm Việc (8 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-01', N'Bàn Làm Việc 1', 2, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-02', N'Bàn Làm Việc 2', 2, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-03', N'Bàn Làm Việc 3', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-04', N'Bàn Làm Việc 4', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-05', N'Bàn Làm Việc 5', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-06', N'Bàn Làm Việc 6', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-07', N'Bàn Làm Việc 7', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Làm Việc'), 'LV-08', N'Bàn Làm Việc 8', 4, 'Available'),

-- Khu Vực Bar (6 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Bar'), 'B-01', N'Bàn Bar 1', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Bar'), 'B-02', N'Bàn Bar 2', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Bar'), 'B-03', N'Bàn Bar 3', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Bar'), 'B-04', N'Bàn Bar 4', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Bar'), 'B-05', N'Bàn Bar 5', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Bar'), 'B-06', N'Bàn Bar 6', 2, 'Available'),

-- Phòng VIP (3 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng VIP'), 'VIP-01', N'Bàn VIP 1', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng VIP'), 'VIP-02', N'Bàn VIP 2', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng VIP'), 'VIP-03', N'Bàn VIP 3', 4, 'Available'),

-- Tầng 2 (7 bàn)
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-01', N'Bàn Tầng 2 - 1', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-02', N'Bàn Tầng 2 - 2', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-03', N'Bàn Tầng 2 - 3', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-04', N'Bàn Tầng 2 - 4', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-05', N'Bàn Tầng 2 - 5', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-06', N'Bàn Tầng 2 - 6', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-07', N'Bàn Tầng 2 - 7', 2, 'Available');
GO
-- ============================================================
-- 8️⃣ EMPLOYEES (Liên kết 1-1 với bảng Users)
-- ============================================================

INSERT INTO Employees 
(UserID, EmployeeCode, FullName, Gender, BirthDate, NationalID, Phone, Email, Address, AvatarURL, 
 HireDate, EmploymentStatus, Position, Salary, BankAccount, BankName, Notes)
SELECT 
    u.UserID,
    'EMP001',
    N'Nguyễn Văn A',
    N'Nam',
    '1990-03-15',
    '012345678901',
    u.Phone,
    u.Email,
    N'123 Nguyễn Trãi, Q.1, TP.HCM',
    N'images/employee_owner.jpg',
    '2020-01-10',
    N'Đang làm',
    N'Chủ quán / Owner',
    30000000,
    '0011223344',
    N'Vietcombank - CN TP.HCM',
    N'Người sáng lập và quản lý chính'
FROM Users u WHERE u.Email = 'owner@liteflow.vn';


INSERT INTO Employees 
(UserID, EmployeeCode, FullName, Gender, BirthDate, NationalID, Phone, Email, Address, AvatarURL, 
 HireDate, EmploymentStatus, Position, Salary, BankAccount, BankName, Notes)
SELECT 
    u.UserID,
    'EMP002',
    N'Trần Thị B',
    N'Nữ',
    '1995-07-20',
    '045678901234',
    u.Phone,
    u.Email,
    N'56 Lê Lợi, Q.1, TP.HCM',
    N'images/employee_cashier.jpg',
    '2022-05-01',
    N'Đang làm',
    N'Thu ngân / Cashier',
    12000000,
    '1234567890',
    N'Techcombank - CN Sài Gòn',
    N'Phụ trách thu ngân và POS'
FROM Users u WHERE u.Email = 'cashier1@liteflow.vn';

INSERT INTO Employees 
(UserID, EmployeeCode, FullName, Gender, BirthDate, NationalID, Phone, Email, Address, AvatarURL, 
 HireDate, EmploymentStatus, Position, Salary, BankAccount, BankName, Notes)
SELECT 
    u.UserID,
    'EMP003',
    N'Lê Văn C',
    N'Nam',
    '1992-11-02',
    '098765432109',
    u.Phone,
    u.Email,
    N'12 Nguyễn Văn Linh, Q.7, TP.HCM',
    N'images/employee_inventory.jpg',
    '2021-09-15',
    N'Đang làm',
    N'Quản lý kho / Inventory Manager',
    15000000,
    '222333444',
    N'ACB - CN Nam Sài Gòn',
    N'Kiểm soát nhập, xuất và tồn kho'
FROM Users u WHERE u.Email = 'inventory@liteflow.vn';

INSERT INTO Employees 
(UserID, EmployeeCode, FullName, Gender, BirthDate, NationalID, Phone, Email, Address, AvatarURL, 
 HireDate, EmploymentStatus, Position, Salary, BankAccount, BankName, Notes)
SELECT 
    u.UserID,
    'EMP004',
    N'Phạm Thị D',
    N'Nữ',
    '1994-06-05',
    '067890123456',
    u.Phone,
    u.Email,
    N'78 Võ Văn Kiệt, Q.5, TP.HCM',
    N'images/employee_procurement.jpg',
    '2021-03-01',
    N'Tạm nghỉ',
    N'Nhân viên mua hàng / Procurement Officer',
    13000000,
    '5566778899',
    N'Sacombank - CN Quận 5',
    N'Tạm nghỉ phép 2 tuần do lý do cá nhân'
FROM Users u WHERE u.Email = 'procurement@liteflow.vn';

INSERT INTO Employees 
(UserID, EmployeeCode, FullName, Gender, BirthDate, NationalID, Phone, Email, Address, AvatarURL, 
 HireDate, EmploymentStatus, Position, Salary, BankAccount, BankName, Notes)
SELECT 
    u.UserID,
    'EMP005',
    N'Hoàng Văn E',
    N'Nam',
    '1991-01-25',
    '054321098765',
    u.Phone,
    u.Email,
    N'21 Bạch Đằng, Bình Thạnh, TP.HCM',
    N'images/employee_hr.jpg',
    '2020-07-01',
    N'Đang làm',
    N'Nhân sự / HR Officer',
    14000000,
    '4455667788',
    N'Vietinbank - CN Bình Thạnh',
    N'Phụ trách chấm công, lương thưởng và tuyển dụng'
FROM Users u WHERE u.Email = 'hr@liteflow.vn';

INSERT INTO Employees 
(UserID, EmployeeCode, FullName, Gender, BirthDate, NationalID, Phone, Email, Address, AvatarURL, 
 HireDate, EmploymentStatus, Position, Salary, BankAccount, BankName, Notes)
SELECT 
    u.UserID,
    'EMP006',
    N'Đỗ Thị F',
    N'Nữ',
    '1999-09-15',
    '098123456789',
    u.Phone,
    u.Email,
    N'19 Hai Bà Trưng, Quận 3, TP.HCM',
    N'images/employee_staff.jpg',
    '2023-02-01',
    N'Đang làm',
    N'Nhân viên pha chế / Barista',
    10000000,
    '6677889900',
    N'MB Bank - CN Quận 3',
    N'Pha chế đồ uống, hỗ trợ khách hàng tại quầy'
FROM Users u WHERE u.Email = 'employee1@liteflow.vn';
GO

-- ============================================================
-- 9️⃣.1 SCHEDULING - SHIFT TEMPLATES, ASSIGNMENTS, SHIFTS
-- ============================================================
-- Create shift templates
INSERT INTO ShiftTemplates (Name, Description, StartTime, EndTime, BreakMinutes, IsActive, CreatedBy)
SELECT N'Ca Sáng', N'7:00 - 12:00', '07:00', '12:00', 15, 1, u.UserID
FROM Users u WHERE u.Email = 'hr@liteflow.vn';

INSERT INTO ShiftTemplates (Name, Description, StartTime, EndTime, BreakMinutes, IsActive, CreatedBy)
SELECT N'Ca Chiều', N'12:00 - 17:00', '12:00', '17:00', 15, 1, u.UserID
FROM Users u WHERE u.Email = 'hr@liteflow.vn';

INSERT INTO ShiftTemplates (Name, Description, StartTime, EndTime, BreakMinutes, IsActive, CreatedBy)
SELECT N'Ca Tối', N'17:00 - 22:00', '17:00', '22:00', 15, 1, u.UserID
FROM Users u WHERE u.Email = 'hr@liteflow.vn';
GO

-- Assign templates to employees by weekdays
-- Employee1 (Barista): Ca Sáng từ Thứ 2 - Thứ 6
INSERT INTO EmployeeShiftAssignments (EmployeeID, TemplateID, Weekday, EffectiveFrom, EffectiveTo, IsActive, CreatedBy)
SELECT e.EmployeeID, t.TemplateID, v.Weekday, CAST(SYSDATETIME() AS DATE), NULL, 1, uHR.UserID
FROM Employees e
JOIN Users uEmp ON uEmp.UserID = e.UserID AND uEmp.Email = 'employee1@liteflow.vn'
JOIN ShiftTemplates t ON t.Name = N'Ca Sáng'
CROSS JOIN (VALUES (1),(2),(3),(4),(5)) v(Weekday)
CROSS JOIN Users uHR
WHERE uHR.Email = 'hr@liteflow.vn';

-- Cashier: Ca Tối vào Thứ 2, 4, 6
INSERT INTO EmployeeShiftAssignments (EmployeeID, TemplateID, Weekday, EffectiveFrom, EffectiveTo, IsActive, CreatedBy)
SELECT e.EmployeeID, t.TemplateID, v.Weekday, CAST(SYSDATETIME() AS DATE), NULL, 1, uHR.UserID
FROM Employees e
JOIN Users uEmp ON uEmp.UserID = e.UserID AND uEmp.Email = 'cashier1@liteflow.vn'
JOIN ShiftTemplates t ON t.Name = N'Ca Tối'
CROSS JOIN (VALUES (1),(3),(5)) v(Weekday)
CROSS JOIN Users uHR
WHERE uHR.Email = 'hr@liteflow.vn';
GO

-- Concrete shifts for current week (sample)
DECLARE @HR UNIQUEIDENTIFIER = (SELECT TOP 1 UserID FROM Users WHERE Email = 'hr@liteflow.vn');
DECLARE @today DATE = CAST(SYSDATETIME() AS DATE);

-- Employee1 today morning shift
INSERT INTO EmployeeShifts (EmployeeID, Title, Notes, StartAt, EndAt, Location, Status, CreatedBy)
SELECT e.EmployeeID, N'Ca Sáng', N'Phân công mẫu',
       DATEADD(HOUR, 7, CAST(@today AS DATETIME2)),
       DATEADD(HOUR, 12, CAST(@today AS DATETIME2)),
       N'Cửa hàng chính', 'Scheduled', @HR
FROM Employees e
JOIN Users u ON u.UserID = e.UserID
WHERE u.Email = 'employee1@liteflow.vn';

-- Employee1 tomorrow afternoon shift
INSERT INTO EmployeeShifts (EmployeeID, Title, Notes, StartAt, EndAt, Location, Status, CreatedBy)
SELECT e.EmployeeID, N'Ca Chiều', N'Phân công mẫu',
       DATEADD(HOUR, 12, DATEADD(DAY, 1, CAST(@today AS DATETIME2))),
       DATEADD(HOUR, 17, DATEADD(DAY, 1, CAST(@today AS DATETIME2))),
       N'Cửa hàng chính', 'Scheduled', @HR
FROM Employees e
JOIN Users u ON u.UserID = e.UserID
WHERE u.Email = 'employee1@liteflow.vn';

-- Cashier day after tomorrow evening shift
INSERT INTO EmployeeShifts (EmployeeID, Title, Notes, StartAt, EndAt, Location, Status, CreatedBy)
SELECT e.EmployeeID, N'Ca Tối', N'Phân công mẫu',
       DATEADD(HOUR, 17, DATEADD(DAY, 2, CAST(@today AS DATETIME2))),
       DATEADD(HOUR, 22, DATEADD(DAY, 2, CAST(@today AS DATETIME2))),
       N'Cửa hàng chính', 'Scheduled', @HR
FROM Employees e
JOIN Users u ON u.UserID = e.UserID
WHERE u.Email = 'cashier1@liteflow.vn';
GO

-- ============================================================
-- 9️⃣ CAFE MANAGEMENT - TABLE SESSIONS & ORDERS
-- ============================================================

-- Sample Table Sessions (Phiên làm việc của các bàn)
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, Status, CreatedBy)
SELECT 
    t.TableID,
    N'Khách hàng A',
    '0901234567',
    DATEADD(HOUR, -2, SYSDATETIME()), -- 2 giờ trước
    'Active',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn 1' AND u.Email = 'cashier1@liteflow.vn';

INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, Status, CreatedBy)
SELECT 
    t.TableID,
    N'Khách hàng B',
    '0907654321',
    DATEADD(MINUTE, -30, SYSDATETIME()), -- 30 phút trước
    'Active',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn 2' AND u.Email = 'cashier1@liteflow.vn';

-- Sample Orders (Đơn hàng trong phiên)
INSERT INTO Orders (SessionID, OrderNumber, SubTotal, VAT, TotalAmount, Status, CreatedBy)
SELECT 
    ts.SessionID,
    'ORD001',
    75000, -- 2 cà phê sữa đá M + 1 bánh tiramisu
    7500,  -- VAT 10%
    82500, -- Tổng
    'Served',
    u.UserID
FROM TableSessions ts
CROSS JOIN Users u
WHERE ts.CustomerName = N'Khách hàng A' AND u.Email = 'cashier1@liteflow.vn';

INSERT INTO Orders (SessionID, OrderNumber, SubTotal, VAT, TotalAmount, Status, CreatedBy)
SELECT 
    ts.SessionID,
    'ORD002',
    105000, -- 1 latte L + 1 trà sữa trân châu L + 1 khoai tây chiên lớn
    10500,  -- VAT 10%
    115500, -- Tổng
    'Preparing',
    u.UserID
FROM TableSessions ts
CROSS JOIN Users u
WHERE ts.CustomerName = N'Khách hàng B' AND u.Email = 'cashier1@liteflow.vn';

-- Sample Order Details (Chi tiết món trong đơn)
INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    2, -- Số lượng
    pv.Price,
    pv.Price * 2, -- Tổng tiền
    'Served'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD001' 
    AND p.Name = N'Cà phê sữa đá' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = 'M';

INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    1, -- Số lượng
    pv.Price,
    pv.Price, -- Tổng tiền
    'Served'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD001' 
    AND p.Name = N'Bánh tiramisu' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = '1 miếng';

INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    1, -- Số lượng
    pv.Price,
    pv.Price, -- Tổng tiền
    'Preparing'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD002' 
    AND p.Name = N'Latte' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = 'L';

INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    1, -- Số lượng
    pv.Price,
    pv.Price, -- Tổng tiền
    'Preparing'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD002' 
    AND p.Name = N'Trà sữa trân châu' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = 'L';

INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    1, -- Số lượng
    pv.Price,
    pv.Price, -- Tổng tiền
    'Pending'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD002' 
    AND p.Name = N'Khoai tây chiên' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = 'Phần lớn';

-- Sample Payment Transactions (Giao dịch thanh toán)
INSERT INTO PaymentTransactions (SessionID, OrderID, Amount, PaymentMethod, PaymentStatus, ProcessedBy)
SELECT 
    ts.SessionID,
    o.OrderID,
    o.TotalAmount,
    'Cash',
    'Completed',
    u.UserID
FROM TableSessions ts
CROSS JOIN Orders o
CROSS JOIN Users u
WHERE ts.CustomerName = N'Khách hàng A' 
    AND o.OrderNumber = 'ORD001'
    AND u.Email = 'cashier1@liteflow.vn';

-- Update table status to Occupied for active sessions
UPDATE Tables 
SET Status = 'Occupied'
WHERE TableID IN (
    SELECT DISTINCT ts.TableID 
    FROM TableSessions ts 
    WHERE ts.Status = 'Active'
);
GO

-- ============================================================
-- 2️⃣ THÊM TABLE SESSIONS MẪU (Lịch sử giao dịch)
-- ============================================================

-- Session đã hoàn thành (Completed)
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
SELECT 
    t.TableID,
    N'Nguyễn Văn An',
    '0901111111',
    DATEADD(HOUR, -24, SYSDATETIME()), -- 1 ngày trước
    DATEADD(HOUR, -23, SYSDATETIME()), -- 1 tiếng sau
    'Completed',
    150000,
    'Cash',
    'Paid',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn 1' AND u.Email = 'cashier1@liteflow.vn';

-- Session đã hủy (Cancelled)
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
SELECT 
    t.TableID,
    N'Trần Thị Bình',
    '0902222222',
    DATEADD(HOUR, -12, SYSDATETIME()), -- 12 tiếng trước
    DATEADD(HOUR, -11, SYSDATETIME()), -- 1 tiếng sau
    'Cancelled',
    75000,
    'Card',
    'Paid',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn 2' AND u.Email = 'cashier1@liteflow.vn';

-- Session với khách hàng VIP
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
SELECT 
    t.TableID,
    N'Lê Văn Cường',
    '0903333333',
    DATEADD(DAY, -3, SYSDATETIME()), -- 3 ngày trước
    DATEADD(DAY, -3, DATEADD(HOUR, 2, SYSDATETIME())), -- 2 tiếng sau
    'Completed',
    450000,
    'Transfer',
    'Paid',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn VIP 1' AND u.Email = 'cashier1@liteflow.vn';

-- Session với thanh toán một phần
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
SELECT 
    t.TableID,
    N'Phạm Thị Dung',
    '0904444444',
    DATEADD(DAY, -2, SYSDATETIME()), -- 2 ngày trước
    DATEADD(DAY, -2, DATEADD(HOUR, 3, SYSDATETIME())), -- 3 tiếng sau
    'Completed',
    200000,
    'Cash',
    'Partial',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn 3' AND u.Email = 'cashier1@liteflow.vn';

-- Session với ghi chú
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, Notes, CreatedBy)
SELECT 
    t.TableID,
    N'Hoàng Văn Em',
    '0905555555',
    DATEADD(DAY, -1, SYSDATETIME()), -- 1 ngày trước
    DATEADD(DAY, -1, DATEADD(HOUR, 1, SYSDATETIME())), -- 1 tiếng sau
    'Completed',
    120000,
    'Wallet',
    'Paid',
    N'Khách hàng thân thiết, yêu cầu cà phê ít đường',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn 4' AND u.Email = 'cashier1@liteflow.vn';

-- Session với khách vãng lai (không có thông tin)
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
SELECT 
    t.TableID,
    NULL, -- Khách vãng lai
    NULL,
    DATEADD(HOUR, -6, SYSDATETIME()), -- 6 tiếng trước
    DATEADD(HOUR, -5, SYSDATETIME()), -- 1 tiếng sau
    'Completed',
    85000,
    'Cash',
    'Paid',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn 5' AND u.Email = 'cashier1@liteflow.vn';

GO

-- ============================================================
-- 3️⃣ THÊM ORDERS VÀ ORDER DETAILS CHO CÁC SESSION
-- ============================================================

-- Order cho session đã hoàn thành
INSERT INTO Orders (SessionID, OrderNumber, SubTotal, VAT, TotalAmount, Status, CreatedBy)
SELECT 
    ts.SessionID,
    'ORD-HISTORY-001',
    135000,
    13500,
    148500,
    'Served',
    u.UserID
FROM TableSessions ts
CROSS JOIN Users u
WHERE ts.CustomerName = N'Nguyễn Văn An' AND u.Email = 'cashier1@liteflow.vn';

-- Order cho session VIP
INSERT INTO Orders (SessionID, OrderNumber, SubTotal, VAT, TotalAmount, Status, CreatedBy)
SELECT 
    ts.SessionID,
    'ORD-HISTORY-002',
    405000,
    40500,
    445500,
    'Served',
    u.UserID
FROM TableSessions ts
CROSS JOIN Users u
WHERE ts.CustomerName = N'Lê Văn Cường' AND u.Email = 'cashier1@liteflow.vn';

-- Order Details cho session đã hoàn thành
INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    3,
    pv.Price,
    pv.Price * 3,
    'Served'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD-HISTORY-001' 
    AND p.Name = N'Cà phê sữa đá' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = 'M';

INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    2,
    pv.Price,
    pv.Price * 2,
    'Served'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD-HISTORY-001' 
    AND p.Name = N'Bánh tiramisu' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = '1 miếng';

-- Order Details cho session VIP
INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    5,
    pv.Price,
    pv.Price * 5,
    'Served'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD-HISTORY-002' 
    AND p.Name = N'Latte' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = 'L';

INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice, Status)
SELECT 
    o.OrderID,
    pv.ProductVariantID,
    3,
    pv.Price,
    pv.Price * 3,
    'Served'
FROM Orders o
CROSS JOIN Products p
CROSS JOIN ProductVariant pv
WHERE o.OrderNumber = 'ORD-HISTORY-002' 
    AND p.Name = N'Bánh tiramisu' 
    AND pv.ProductID = p.ProductID 
    AND pv.Size = '1 miếng';

GO

-- ============================================================
-- 4️⃣ THÊM PAYMENT TRANSACTIONS
-- ============================================================

-- Payment cho session đã hoàn thành
INSERT INTO PaymentTransactions (SessionID, OrderID, Amount, PaymentMethod, PaymentStatus, ProcessedBy)
SELECT 
    ts.SessionID,
    o.OrderID,
    o.TotalAmount,
    'Cash',
    'Completed',
    u.UserID
FROM TableSessions ts
CROSS JOIN Orders o
CROSS JOIN Users u
WHERE ts.CustomerName = N'Nguyễn Văn An' 
    AND o.OrderNumber = 'ORD-HISTORY-001'
    AND u.Email = 'cashier1@liteflow.vn';

-- Payment cho session VIP
INSERT INTO PaymentTransactions (SessionID, OrderID, Amount, PaymentMethod, PaymentStatus, ProcessedBy)
SELECT 
    ts.SessionID,
    o.OrderID,
    o.TotalAmount,
    'Transfer',
    'Completed',
    u.UserID
FROM TableSessions ts
CROSS JOIN Orders o
CROSS JOIN Users u
WHERE ts.CustomerName = N'Lê Văn Cường' 
    AND o.OrderNumber = 'ORD-HISTORY-002'
    AND u.Email = 'cashier1@liteflow.vn';

GO

-- ============================================================
-- 5️⃣ CẬP NHẬT TRẠNG THÁI BÀN
-- ============================================================

-- Cập nhật trạng thái bàn dựa trên sessions
UPDATE Tables 
SET Status = 'Occupied'
WHERE TableID IN (
    SELECT DISTINCT ts.TableID 
    FROM TableSessions ts 
    WHERE ts.Status = 'Active'
);

-- Cập nhật một số bàn thành Reserved để test
UPDATE Tables 
SET Status = 'Reserved'
WHERE TableName IN ('Bàn Ngoài Trời 3', 'Bàn Họp 2');

-- Cập nhật một số bàn thành Maintenance để test
UPDATE Tables 
SET Status = 'Maintenance'
WHERE TableName IN ('Bàn Ngoài Trời 4');

-- Cập nhật một số bàn thành Available để test
UPDATE Tables 
SET Status = 'Available'
WHERE TableName IN ('Bàn Ngoài Trời 1', 'Bàn Họp 1', 'Bàn Họp 3', 'Bàn Lễ Tân 1', 'Bàn Lễ Tân 3');

GO

-- ============================================================
-- 6️⃣ THÊM DỮ LIỆU TEST CHO CÁC TRƯỜNG HỢP ĐẶC BIỆT
-- ============================================================

-- Session với null values để test error handling
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
SELECT 
    t.TableID,
    N'Test Null Values',
    NULL,
    DATEADD(HOUR, -1, SYSDATETIME()),
    NULL, -- CheckOutTime null để test
    'Active',
    NULL, -- TotalAmount null để test
    NULL, -- PaymentMethod null để test
    'Unpaid',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn Không Phòng 1' AND u.Email = 'cashier1@liteflow.vn';

-- Session với số tiền 0
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
SELECT 
    t.TableID,
    N'Khách Hàng Miễn Phí',
    '0900000000',
    DATEADD(HOUR, -3, SYSDATETIME()),
    DATEADD(HOUR, -2, SYSDATETIME()),
    'Completed',
    0, -- Số tiền 0
    'Cash',
    'Paid',
    u.UserID
FROM Tables t
CROSS JOIN Users u
WHERE t.TableName = 'Bàn Không Phòng 2' AND u.Email = 'cashier1@liteflow.vn';

GO

-- ============================================================
-- 7️⃣ THÊM DỮ LIỆU TEST CHO PERFORMANCE
-- ============================================================

-- Thêm nhiều sessions cũ để test pagination và performance
DECLARE @counter INT = 1;
DECLARE @maxCounter INT = 50;

WHILE @counter <= @maxCounter
BEGIN
    INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, CreatedBy)
    SELECT 
        t.TableID,
        N'Khách Hàng Test ' + CAST(@counter AS NVARCHAR(10)),
        '090' + RIGHT('0000000' + CAST(@counter AS NVARCHAR(10)), 7),
        DATEADD(DAY, -@counter, SYSDATETIME()),
        DATEADD(DAY, -@counter, DATEADD(HOUR, 2, SYSDATETIME())),
        'Completed',
        50000 + (@counter * 1000),
        CASE (@counter % 4)
            WHEN 0 THEN 'Cash'
            WHEN 1 THEN 'Card'
            WHEN 2 THEN 'Transfer'
            ELSE 'Wallet'
        END,
        'Paid',
        u.UserID
    FROM Tables t
    CROSS JOIN Users u
    WHERE t.TableName = 'Bàn 1' AND u.Email = 'cashier1@liteflow.vn';
    
END

GO

-- ============================================================
-- 8️⃣ DỮ LIỆU MẪU CHI TIẾT CHO TABLE HISTORY
-- ============================================================

-- Kiểm tra và xóa dữ liệu cũ nếu có để tránh conflict (theo thứ tự foreign key)
-- Xóa PaymentTransactions trước (có FK đến Orders)
DELETE FROM PaymentTransactions WHERE TransactionReference IN ('CASH001', 'CARD001', 'TRF001', 'CARD002', 'CASH002', 'TRF002', 'TRF003', 'CARD003', 'WALLET001', 'CASH003', 'TRF004');
-- Xóa OrderDetails (có FK đến Orders)
DELETE FROM OrderDetails WHERE OrderID IN (SELECT OrderID FROM Orders WHERE OrderNumber IN ('ORD001', 'ORD002', 'ORD003', 'ORD004', 'ORD005', 'ORD006', 'ORD007', 'ORD008', 'ORD009', 'ORD010', 'ORD011'));
-- Xóa Orders (có FK đến TableSessions)
DELETE FROM Orders WHERE OrderNumber IN ('ORD001', 'ORD002', 'ORD003', 'ORD004', 'ORD005', 'ORD006', 'ORD007', 'ORD008', 'ORD009', 'ORD010', 'ORD011');
-- Xóa TableSessions cuối cùng
DELETE FROM TableSessions WHERE CustomerName IN (N'Nguyễn Văn An', N'Trần Thị Bình', N'Lê Văn Cường', N'Phạm Thị Dung', N'Hoàng Văn Em', N'Vũ Thị Phương', N'Đặng Văn Giang', N'Bùi Thị Hoa', N'Ngô Văn Ích', N'Dương Thị Kim', N'Lý Văn Lâm', N'Mai Thị Nga', N'Phan Văn Oanh', N'Võ Thị Phượng', N'Đinh Văn Quang', N'Trương Thị Rinh', N'Lưu Văn Sơn', N'Chu Thị Tuyết', N'Lâm Văn Uyên', N'Nguyễn Thị Vân', N'Trần Văn Xuyên');

-- Lấy Table IDs từ database hiện tại
DECLARE @LT01_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'LT-01');
DECLARE @LT02_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'LT-02');
DECLARE @LT03_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'LT-03');
DECLARE @LT04_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'LT-04');
DECLARE @LT05_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'LT-05');
DECLARE @GD01_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'GD-01');
DECLARE @GD02_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'GD-02');
DECLARE @GD03_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'GD-03');
DECLARE @H01_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'H-01');
DECLARE @H02_TableID UNIQUEIDENTIFIER = (SELECT TOP 1 TableID FROM Tables WHERE TableNumber = 'H-02');

-- Lấy User ID (giả sử có user admin)
DECLARE @AdminUserID UNIQUEIDENTIFIER = (SELECT TOP 1 UserID FROM Users WHERE Email LIKE '%admin%' OR DisplayName LIKE '%admin%');

-- Kiểm tra xem có đủ dữ liệu cần thiết không
IF @AdminUserID IS NULL
BEGIN
    PRINT '⚠️ Cảnh báo: Không tìm thấy user admin. Sử dụng user đầu tiên có sẵn.';
    SET @AdminUserID = (SELECT TOP 1 UserID FROM Users);
END

-- Kiểm tra xem có đủ ProductVariant không
IF NOT EXISTS (SELECT 1 FROM ProductVariant WHERE Size = 'Nhỏ' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen'))
BEGIN
    PRINT '⚠️ Cảnh báo: Không tìm thấy ProductVariant cho Cà phê đen Nhỏ. Sẽ bỏ qua OrderDetails.';
END

-- Insert Table Sessions chi tiết
INSERT INTO TableSessions (TableID, CustomerName, CustomerPhone, CheckInTime, CheckOutTime, Status, TotalAmount, PaymentMethod, PaymentStatus, Notes, CreatedBy) VALUES

-- Bàn LT-01 (Lễ Tân 1) - 3 phiên
(@LT01_TableID, N'Nguyễn Văn An', '0901234567', DATEADD(day, -5, GETDATE()), DATEADD(day, -5, DATEADD(hour, 2, GETDATE())), 'Completed', 150000.00, 'Cash', 'Paid', N'Khách VIP, phục vụ đặc biệt', @AdminUserID),
(@LT01_TableID, N'Trần Thị Bình', '0902345678', DATEADD(day, -3, GETDATE()), DATEADD(day, -3, DATEADD(hour, 1, GETDATE())), 'Completed', 85000.00, 'Card', 'Paid', N'Khách thường', @AdminUserID),
(@LT01_TableID, N'Lê Văn Cường', '0903456789', DATEADD(day, -1, GETDATE()), NULL, 'Active', 0.00, NULL, 'Unpaid', N'Đang phục vụ', @AdminUserID),

-- Bàn LT-02 (Lễ Tân 2) - 2 phiên
(@LT02_TableID, N'Phạm Thị Dung', '0904567890', DATEADD(day, -4, GETDATE()), DATEADD(day, -4, DATEADD(hour, 3, GETDATE())), 'Completed', 220000.00, 'Transfer', 'Paid', N'Tiệc sinh nhật nhỏ', @AdminUserID),
(@LT02_TableID, N'Hoàng Văn Em', '0905678901', DATEADD(day, -2, GETDATE()), DATEADD(day, -2, DATEADD(hour, 1, GETDATE())), 'Completed', 95000.00, 'Cash', 'Paid', N'Cà phê buổi sáng', @AdminUserID),

-- Bàn LT-03 (Lễ Tân 3) - 4 phiên
(@LT03_TableID, N'Vũ Thị Phương', '0906789012', DATEADD(day, -6, GETDATE()), DATEADD(day, -6, DATEADD(hour, 2, GETDATE())), 'Completed', 180000.00, 'Card', 'Paid', N'Họp mặt gia đình', @AdminUserID),
(@LT03_TableID, N'Đặng Văn Giang', '0907890123', DATEADD(day, -4, GETDATE()), DATEADD(day, -4, DATEADD(hour, 1, GETDATE())), 'Completed', 75000.00, 'Cash', 'Paid', N'Ăn trưa nhanh', @AdminUserID),
(@LT03_TableID, N'Bùi Thị Hoa', '0908901234', DATEADD(day, -2, GETDATE()), DATEADD(day, -2, DATEADD(hour, 4, GETDATE())), 'Completed', 320000.00, 'Transfer', 'Paid', N'Tiệc cưới nhỏ', @AdminUserID),
(@LT03_TableID, N'Ngô Văn Ích', '0909012345', DATEADD(hour, -2, GETDATE()), NULL, 'Active', 0.00, NULL, 'Unpaid', N'Đang phục vụ', @AdminUserID),

-- Bàn LT-04 (Lễ Tân 4) - 2 phiên
(@LT04_TableID, N'Dương Thị Kim', '0910123456', DATEADD(day, -3, GETDATE()), DATEADD(day, -3, DATEADD(hour, 2, GETDATE())), 'Completed', 165000.00, 'Card', 'Paid', N'Tiệc công ty', @AdminUserID),
(@LT04_TableID, N'Lý Văn Lâm', '0911234567', DATEADD(day, -1, GETDATE()), DATEADD(day, -1, DATEADD(hour, 1, GETDATE())), 'Completed', 88000.00, 'Cash', 'Paid', N'Ăn tối', @AdminUserID),

-- Bàn LT-05 (Lễ Tân 5) - 1 phiên
(@LT05_TableID, N'Mai Thị Nga', '0912345678', DATEADD(day, -2, GETDATE()), DATEADD(day, -2, DATEADD(hour, 3, GETDATE())), 'Completed', 195000.00, 'Wallet', 'Paid', N'Tiệc sinh nhật', @AdminUserID),

-- Bàn GD-01 (Gia Đình 1) - 3 phiên
(@GD01_TableID, N'Phan Văn Oanh', '0913456789', DATEADD(day, -5, GETDATE()), DATEADD(day, -5, DATEADD(hour, 2, GETDATE())), 'Completed', 145000.00, 'Cash', 'Paid', N'Gia đình 4 người', @AdminUserID),
(@GD01_TableID, N'Võ Thị Phượng', '0914567890', DATEADD(day, -3, GETDATE()), DATEADD(day, -3, DATEADD(hour, 1, GETDATE())), 'Completed', 92000.00, 'Card', 'Paid', N'Ăn trưa gia đình', @AdminUserID),
(@GD01_TableID, N'Đinh Văn Quang', '0915678901', DATEADD(hour, -1, GETDATE()), NULL, 'Active', 0.00, NULL, 'Unpaid', N'Đang phục vụ', @AdminUserID),

-- Bàn GD-02 (Gia Đình 2) - 2 phiên
(@GD02_TableID, N'Trương Thị Rinh', '0916789012', DATEADD(day, -4, GETDATE()), DATEADD(day, -4, DATEADD(hour, 3, GETDATE())), 'Completed', 280000.00, 'Transfer', 'Paid', N'Tiệc gia đình lớn', @AdminUserID),
(@GD02_TableID, N'Lưu Văn Sơn', '0917890123', DATEADD(day, -1, GETDATE()), DATEADD(day, -1, DATEADD(hour, 2, GETDATE())), 'Completed', 175000.00, 'Cash', 'Paid', N'Họp mặt bạn bè', @AdminUserID),

-- Bàn GD-03 (Gia Đình 3) - 1 phiên
(@GD03_TableID, N'Chu Thị Tuyết', '0918901234', DATEADD(day, -2, GETDATE()), DATEADD(day, -2, DATEADD(hour, 1, GETDATE())), 'Completed', 105000.00, 'Card', 'Paid', N'Ăn tối gia đình', @AdminUserID),

-- Bàn H-01 (Họp 1) - 2 phiên
(@H01_TableID, N'Lâm Văn Uyên', '0919012345', DATEADD(day, -3, GETDATE()), DATEADD(day, -3, DATEADD(hour, 4, GETDATE())), 'Completed', 350000.00, 'Transfer', 'Paid', N'Họp công ty quan trọng', @AdminUserID),
(@H01_TableID, N'Nguyễn Thị Vân', '0920123456', DATEADD(day, -1, GETDATE()), DATEADD(day, -1, DATEADD(hour, 2, GETDATE())), 'Completed', 185000.00, 'Card', 'Paid', N'Họp dự án', @AdminUserID),

-- Bàn H-02 (Họp 2) - 1 phiên
(@H02_TableID, N'Trần Văn Xuyên', '0921234567', DATEADD(day, -2, GETDATE()), DATEADD(day, -2, DATEADD(hour, 3, GETDATE())), 'Completed', 240000.00, 'Cash', 'Paid', N'Họp ban giám đốc', @AdminUserID);

-- Lấy Session IDs vừa tạo
DECLARE @Session1 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Nguyễn Văn An' ORDER BY CheckInTime DESC);
DECLARE @Session2 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Trần Thị Bình' ORDER BY CheckInTime DESC);
DECLARE @Session3 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Phạm Thị Dung' ORDER BY CheckInTime DESC);
DECLARE @Session4 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Vũ Thị Phương' ORDER BY CheckInTime DESC);
DECLARE @Session5 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Đặng Văn Giang' ORDER BY CheckInTime DESC);
DECLARE @Session6 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Bùi Thị Hoa' ORDER BY CheckInTime DESC);
DECLARE @Session7 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Dương Thị Kim' ORDER BY CheckInTime DESC);
DECLARE @Session8 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Mai Thị Nga' ORDER BY CheckInTime DESC);
DECLARE @Session9 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Phan Văn Oanh' ORDER BY CheckInTime DESC);
DECLARE @Session10 UNIQUEIDENTIFIER = (SELECT TOP 1 SessionID FROM TableSessions WHERE CustomerName = N'Trương Thị Rinh' ORDER BY CheckInTime DESC);

-- Insert Orders chi tiết
INSERT INTO Orders (SessionID, OrderNumber, OrderDate, SubTotal, VAT, Discount, TotalAmount, Status, PaymentMethod, PaymentStatus, Notes, CreatedBy) VALUES

-- Phiên 1 - Nguyễn Văn An (LT-01)
(@Session1, 'ORD001', DATEADD(day, -5, GETDATE()), 150000.00, 15000.00, 0.00, 150000.00, 'Served', 'Cash', 'Paid', N'Đơn hàng VIP', @AdminUserID),

-- Phiên 2 - Trần Thị Bình (LT-01)
(@Session2, 'ORD002', DATEADD(day, -3, GETDATE()), 85000.00, 8500.00, 0.00, 85000.00, 'Served', 'Card', 'Paid', N'Đơn hàng thường', @AdminUserID),

-- Phiên 3 - Phạm Thị Dung (LT-02)
(@Session3, 'ORD003', DATEADD(day, -4, GETDATE()), 200000.00, 20000.00, 0.00, 220000.00, 'Served', 'Transfer', 'Paid', N'Tiệc sinh nhật', @AdminUserID),

-- Phiên 4 - Vũ Thị Phương (LT-03)
(@Session4, 'ORD004', DATEADD(day, -6, GETDATE()), 150000.00, 15000.00, 15000.00, 180000.00, 'Served', 'Card', 'Paid', N'Họp mặt gia đình', @AdminUserID),

-- Phiên 5 - Đặng Văn Giang (LT-03)
(@Session5, 'ORD005', DATEADD(day, -4, GETDATE()), 75000.00, 7500.00, 0.00, 75000.00, 'Served', 'Cash', 'Paid', N'Ăn trưa nhanh', @AdminUserID),

-- Phiên 6 - Bùi Thị Hoa (LT-03) - 2 đơn hàng
(@Session6, 'ORD006', DATEADD(day, -2, GETDATE()), 150000.00, 15000.00, 0.00, 165000.00, 'Served', 'Transfer', 'Paid', N'Đơn hàng 1', @AdminUserID),
(@Session6, 'ORD007', DATEADD(day, -2, DATEADD(hour, 1, GETDATE())), 140000.00, 14000.00, 0.00, 155000.00, 'Served', 'Transfer', 'Paid', N'Đơn hàng 2', @AdminUserID),

-- Phiên 7 - Dương Thị Kim (LT-04)
(@Session7, 'ORD008', DATEADD(day, -3, GETDATE()), 150000.00, 15000.00, 0.00, 165000.00, 'Served', 'Card', 'Paid', N'Tiệc công ty', @AdminUserID),

-- Phiên 8 - Mai Thị Nga (LT-05)
(@Session8, 'ORD009', DATEADD(day, -2, GETDATE()), 180000.00, 18000.00, 3000.00, 195000.00, 'Served', 'Wallet', 'Paid', N'Tiệc sinh nhật', @AdminUserID),

-- Phiên 9 - Phan Văn Oanh (GD-01)
(@Session9, 'ORD010', DATEADD(day, -5, GETDATE()), 130000.00, 13000.00, 0.00, 145000.00, 'Served', 'Cash', 'Paid', N'Gia đình 4 người', @AdminUserID),

-- Phiên 10 - Trương Thị Rinh (GD-02)
(@Session10, 'ORD011', DATEADD(day, -4, GETDATE()), 250000.00, 25000.00, 5000.00, 280000.00, 'Served', 'Transfer', 'Paid', N'Tiệc gia đình lớn', @AdminUserID);

-- Lấy Order IDs vừa tạo
DECLARE @Order1 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD001');
DECLARE @Order2 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD002');
DECLARE @Order3 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD003');
DECLARE @Order4 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD004');
DECLARE @Order5 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD005');
DECLARE @Order6 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD006');
DECLARE @Order7 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD007');
DECLARE @Order8 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD008');
DECLARE @Order9 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD009');
DECLARE @Order10 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD010');
DECLARE @Order11 UNIQUEIDENTIFIER = (SELECT TOP 1 OrderID FROM Orders WHERE OrderNumber = 'ORD011');

-- Insert Order Details chi tiết (chỉ nếu có ProductVariant)
IF EXISTS (SELECT 1 FROM ProductVariant WHERE Size = 'Nhỏ' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen'))
BEGIN
    INSERT INTO OrderDetails (OrderID, ProductVariantID, Quantity, UnitPrice, TotalPrice) VALUES

-- ORD001 - Nguyễn Văn An (Cà phê đen nhỏ x2, Bánh mì thịt nướng vừa x1, Nước cam tươi lớn x2)
(@Order1, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Nhỏ' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen')), 2, 25000.00, 50000.00),
(@Order1, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Vừa' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh mì thịt nướng')), 1, 45000.00, 45000.00),
(@Order1, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Nước cam tươi')), 2, 30000.00, 60000.00),

-- ORD002 - Trần Thị Bình (Cà phê sữa nhỏ x1, Bánh ngọt vừa x2)
(@Order2, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Nhỏ' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê sữa')), 1, 30000.00, 30000.00),
(@Order2, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Vừa' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh ngọt')), 2, 25000.00, 50000.00),

-- ORD003 - Phạm Thị Dung (Cà phê đen lớn x3, Bánh mì thịt nướng lớn x2, Nước cam tươi lớn x2)
(@Order3, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen')), 3, 30000.00, 90000.00),
(@Order3, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh mì thịt nướng')), 2, 50000.00, 100000.00),
(@Order3, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Nước cam tươi')), 2, 30000.00, 60000.00),

-- ORD004 - Vũ Thị Phương (Cà phê sữa vừa x2, Bánh ngọt lớn x3)
(@Order4, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Vừa' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê sữa')), 2, 35000.00, 70000.00),
(@Order4, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh ngọt')), 3, 30000.00, 90000.00),

-- ORD005 - Đặng Văn Giang (Cà phê đen nhỏ x1, Bánh mì thịt nướng nhỏ x1, Nước cam tươi nhỏ x1)
(@Order5, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Nhỏ' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen')), 1, 25000.00, 25000.00),
(@Order5, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Nhỏ' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh mì thịt nướng')), 1, 35000.00, 35000.00),
(@Order5, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Nhỏ' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Nước cam tươi')), 1, 20000.00, 20000.00),

-- ORD006 - Bùi Thị Hoa Đơn 1 (Cà phê sữa lớn x2, Bánh ngọt lớn x2)
(@Order6, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê sữa')), 2, 40000.00, 80000.00),
(@Order6, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh ngọt')), 2, 30000.00, 60000.00),

-- ORD007 - Bùi Thị Hoa Đơn 2 (Cà phê đen lớn x2, Bánh mì thịt nướng lớn x1, Nước cam tươi lớn x1)
(@Order7, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen')), 2, 35000.00, 70000.00),
(@Order7, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh mì thịt nướng')), 1, 50000.00, 50000.00),
(@Order7, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Nước cam tươi')), 1, 30000.00, 30000.00),

-- ORD008 - Dương Thị Kim (Cà phê sữa lớn x3, Bánh ngọt lớn x2)
(@Order8, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê sữa')), 3, 40000.00, 120000.00),
(@Order8, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh ngọt')), 2, 30000.00, 60000.00),

-- ORD009 - Mai Thị Nga (Cà phê đen lớn x2, Bánh mì thịt nướng lớn x2, Nước cam tươi lớn x1)
(@Order9, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen')), 2, 35000.00, 70000.00),
(@Order9, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh mì thịt nướng')), 2, 50000.00, 100000.00),
(@Order9, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Nước cam tươi')), 1, 30000.00, 30000.00),

-- ORD010 - Phan Văn Oanh (Cà phê sữa vừa x2, Bánh ngọt vừa x2, Nước cam tươi vừa x1)
(@Order10, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Vừa' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê sữa')), 2, 35000.00, 70000.00),
(@Order10, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Vừa' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh ngọt')), 2, 25000.00, 50000.00),
(@Order10, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Vừa' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Nước cam tươi')), 1, 25000.00, 25000.00),

-- ORD011 - Trương Thị Rinh (Cà phê đen lớn x4, Bánh mì thịt nướng lớn x3, Nước cam tươi lớn x2)
(@Order11, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Cà phê đen')), 4, 35000.00, 140000.00),
(@Order11, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Bánh mì thịt nướng')), 3, 50000.00, 150000.00),
(@Order11, (SELECT TOP 1 ProductVariantID FROM ProductVariant WHERE Size = 'Lớn' AND ProductID = (SELECT TOP 1 ProductID FROM Products WHERE Name = N'Nước cam tươi')), 2, 30000.00, 60000.00);
END
ELSE
BEGIN
    PRINT '⚠️ Bỏ qua OrderDetails vì không có đủ ProductVariant.';
END

-- Insert Payment Transactions chi tiết
INSERT INTO PaymentTransactions (SessionID, OrderID, Amount, PaymentMethod, PaymentStatus, TransactionReference, Notes, ProcessedBy, ProcessedAt) VALUES

-- Thanh toán cho các phiên đã hoàn thành
(@Session1, @Order1, 150000.00, 'Cash', 'Completed', 'CASH001', N'Thanh toán tiền mặt', @AdminUserID, DATEADD(day, -5, DATEADD(hour, 2, GETDATE()))),
(@Session2, @Order2, 85000.00, 'Card', 'Completed', 'CARD001', N'Thanh toán bằng thẻ', @AdminUserID, DATEADD(day, -3, DATEADD(hour, 1, GETDATE()))),
(@Session3, @Order3, 220000.00, 'Transfer', 'Completed', 'TRF001', N'Chuyển khoản ngân hàng', @AdminUserID, DATEADD(day, -4, DATEADD(hour, 3, GETDATE()))),
(@Session4, @Order4, 180000.00, 'Card', 'Completed', 'CARD002', N'Thanh toán bằng thẻ', @AdminUserID, DATEADD(day, -6, DATEADD(hour, 2, GETDATE()))),
(@Session5, @Order5, 75000.00, 'Cash', 'Completed', 'CASH002', N'Thanh toán tiền mặt', @AdminUserID, DATEADD(day, -4, DATEADD(hour, 1, GETDATE()))),
(@Session6, @Order6, 165000.00, 'Transfer', 'Completed', 'TRF002', N'Chuyển khoản ngân hàng', @AdminUserID, DATEADD(day, -2, DATEADD(hour, 2, GETDATE()))),
(@Session6, @Order7, 155000.00, 'Transfer', 'Completed', 'TRF003', N'Chuyển khoản ngân hàng', @AdminUserID, DATEADD(day, -2, DATEADD(hour, 4, GETDATE()))),
(@Session7, @Order8, 165000.00, 'Card', 'Completed', 'CARD003', N'Thanh toán bằng thẻ', @AdminUserID, DATEADD(day, -3, DATEADD(hour, 2, GETDATE()))),
(@Session8, @Order9, 195000.00, 'Wallet', 'Completed', 'WALLET001', N'Thanh toán ví điện tử', @AdminUserID, DATEADD(day, -2, DATEADD(hour, 3, GETDATE()))),
(@Session9, @Order10, 145000.00, 'Cash', 'Completed', 'CASH003', N'Thanh toán tiền mặt', @AdminUserID, DATEADD(day, -5, DATEADD(hour, 2, GETDATE()))),
(@Session10, @Order11, 280000.00, 'Transfer', 'Completed', 'TRF004', N'Chuyển khoản ngân hàng', @AdminUserID, DATEADD(day, -4, DATEADD(hour, 3, GETDATE())));

-- Cập nhật TotalAmount cho các phiên dựa trên tổng các đơn hàng
UPDATE TableSessions 
SET TotalAmount = (
    SELECT ISNULL(SUM(TotalAmount), 0) 
    FROM Orders 
    WHERE Orders.SessionID = TableSessions.SessionID
)
WHERE Status = 'Completed';

-- Hiển thị thống kê
DECLARE @TotalSessions INT = (SELECT COUNT(*) FROM TableSessions);
DECLARE @TotalOrders INT = (SELECT COUNT(*) FROM Orders);
DECLARE @TotalPayments INT = (SELECT COUNT(*) FROM PaymentTransactions);
DECLARE @TotalRevenue DECIMAL(10,2) = (SELECT ISNULL(SUM(Amount), 0) FROM PaymentTransactions);

PRINT '✅ Đã tạo dữ liệu mẫu chi tiết cho lịch sử giao dịch của bàn:';
PRINT '📊 Tổng số phiên làm việc: ' + CAST(@TotalSessions AS NVARCHAR(10));
PRINT '📝 Tổng số đơn hàng: ' + CAST(@TotalOrders AS NVARCHAR(10));
PRINT '💳 Tổng số giao dịch thanh toán: ' + CAST(@TotalPayments AS NVARCHAR(10));
PRINT '💰 Tổng doanh thu: ' + CAST(@TotalRevenue AS NVARCHAR(20)) + ' VNĐ';
PRINT '';
PRINT '✅ Hoàn thành tạo dữ liệu mẫu cho table history!';

GO
