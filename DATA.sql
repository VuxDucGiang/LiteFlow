-- ================================
-- SAMPLE DATA FOR LITEFLOW CAFE ☕
-- Version: 2025-10
-- ================================

USE LiteFlowDBO;
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
(N'Cà phê đen', N'Cà phê phin truyền thống Việt Nam, đậm vị', 'images/cf_den.jpg'),
(N'Cà phê sữa đá', N'Cà phê phin pha sữa đặc, vị ngọt béo', 'images/cf_suada.jpg'),
(N'Latte', N'Cà phê espresso với sữa nóng và lớp foam', 'images/latte.jpg'),
(N'Trà đào cam sả', N'Trà đào kết hợp cam và sả, vị thanh mát', 'images/tra_dao.jpg'),
(N'Trà sữa trân châu', N'Trà sữa ngọt dịu kèm trân châu đen', 'images/trasua.jpg'),
(N'Sinh tố xoài', N'Sinh tố xoài tươi, ngọt mát', 'images/sinh_to_xoai.jpg'),
(N'Nước ép cam', N'Nước cam vắt tươi nguyên chất', 'images/nuoc_cam.jpg'),
(N'Bánh tiramisu', N'Bánh tiramisu Ý, mềm xốp, vị cà phê', 'images/tiramisu.jpg'),
(N'Croissant bơ', N'Bánh croissant Pháp, giòn thơm vị bơ', 'images/croissant.jpg'),
(N'Khoai tây chiên', N'Khoai tây chiên giòn vàng', 'images/khoai_tay.jpg');
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
-- 7️⃣ ROOMS & TABLES
-- ============================================================
INSERT INTO Rooms (Name, Description) VALUES
(N'Tầng 1', N'Khu vực tầng 1'),
(N'Tầng 2', N'Khu vực tầng 2'),
(N'VIP', N'Phòng VIP riêng tư');
GO

INSERT INTO Tables (RoomID, TableNumber) VALUES
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 1'), 'Bàn 1'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 1'), 'Bàn 2'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'Bàn 3'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'VIP'), 'VIP 1');
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
