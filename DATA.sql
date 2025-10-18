-- ============================================================
-- 1️⃣0 PAYROLL & COMPENSATION - SAMPLE DATA
-- ============================================================

-- Create sample Pay Policies
INSERT INTO PayPolicies (Name, Description, OvertimeMultiplier, NightShiftMultiplier, WeekendMultiplier, HolidayMultiplier, MinBreakMinutes, Currency, IsActive, CreatedBy)
SELECT N'Chính sách chuẩn VN', N'Mặc định cho nhân viên toàn thời gian', 1.5, 1.2, 1.5, 2.0, 15, 'VND', 1, u.UserID
FROM Users u WHERE u.Email = 'hr@liteflow.vn';

INSERT INTO PayPolicies (Name, Description, OvertimeMultiplier, NightShiftMultiplier, WeekendMultiplier, HolidayMultiplier, MinBreakMinutes, Currency, IsActive, CreatedBy)
SELECT N'Chính sách tăng cuối tuần', N'Tăng lương giờ cho cuối tuần', 1.5, 1.2, 1.75, 2.0, 15, 'VND', 1, u.UserID
FROM Users u WHERE u.Email = 'hr@liteflow.vn';
GO

-- Per-employee compensation configurations
INSERT INTO EmployeeCompensation (EmployeeID, CompensationType, PolicyID, BaseMonthlySalary, HourlyRate, PerShiftRate, Currency, EffectiveFrom, EffectiveTo, IsActive, Notes, CreatedBy)
SELECT e.EmployeeID, 'Fixed', p.PolicyID, 12000000, NULL, NULL, 'VND', CAST(SYSDATETIME() AS DATE), NULL, 1, N'Thu nhập cố định', uHR.UserID
FROM Employees e
JOIN Users uEmp ON uEmp.UserID = e.UserID AND uEmp.Email = 'cashier1@liteflow.vn'
JOIN PayPolicies p ON p.Name = N'Chính sách chuẩn VN'
CROSS JOIN Users uHR
WHERE uHR.Email = 'hr@liteflow.vn';

INSERT INTO EmployeeCompensation (EmployeeID, CompensationType, PolicyID, BaseMonthlySalary, HourlyRate, PerShiftRate, Currency, EffectiveFrom, EffectiveTo, IsActive, Notes, CreatedBy)
SELECT e.EmployeeID, 'PerShift', p.PolicyID, NULL, NULL, 100000, 'VND', CAST(SYSDATETIME() AS DATE), NULL, 1, N'Pha chế tính theo ca', uHR.UserID
FROM Employees e
JOIN Users uEmp ON uEmp.UserID = e.UserID AND uEmp.Email = 'employee1@liteflow.vn'
JOIN PayPolicies p ON p.Name = N'Chính sách chuẩn VN'
CROSS JOIN Users uHR
WHERE uHR.Email = 'hr@liteflow.vn';

INSERT INTO EmployeeCompensation (EmployeeID, CompensationType, PolicyID, BaseMonthlySalary, HourlyRate, PerShiftRate, Currency, EffectiveFrom, EffectiveTo, IsActive, Notes, CreatedBy)
SELECT e.EmployeeID, 'Hybrid', p.PolicyID, 8000000, 20000, NULL, 'VND', CAST(SYSDATETIME() AS DATE), NULL, 1, N'Kho: lương cơ bản + theo giờ', uHR.UserID
FROM Employees e
JOIN Users uEmp ON uEmp.UserID = e.UserID AND uEmp.Email = 'inventory@liteflow.vn'
JOIN PayPolicies p ON p.Name = N'Chính sách chuẩn VN'
CROSS JOIN Users uHR
WHERE uHR.Email = 'hr@liteflow.vn';
GO

-- Shift pay rules (by template/position, with weekend uplift)
INSERT INTO ShiftPayRules (TemplateID, Position, DayType, RateType, Rate, Currency, EffectiveFrom, EffectiveTo, IsActive, Notes)
SELECT t.TemplateID, N'Nhân viên pha chế / Barista', 'Weekday', 'Hourly', 25000, 'VND', CAST(SYSDATETIME() AS DATE), NULL, 1, N'Giờ ngày thường'
FROM ShiftTemplates t WHERE t.Name = N'Ca Sáng';

INSERT INTO ShiftPayRules (TemplateID, Position, DayType, RateType, Rate, Currency, EffectiveFrom, EffectiveTo, IsActive, Notes)
SELECT t.TemplateID, N'Nhân viên pha chế / Barista', 'Weekend', 'Hourly', 30000, 'VND', CAST(SYSDATETIME() AS DATE), NULL, 1, N'Giờ cuối tuần'
FROM ShiftTemplates t WHERE t.Name = N'Ca Sáng';

INSERT INTO ShiftPayRules (TemplateID, Position, DayType, RateType, Rate, Currency, EffectiveFrom, EffectiveTo, IsActive, Notes)
SELECT t.TemplateID, N'Thu ngân / Cashier', 'Any', 'Hourly', 28000, 'VND', CAST(SYSDATETIME() AS DATE), NULL, 1, N'Áp dụng mọi ngày'
FROM ShiftTemplates t WHERE t.Name = N'Ca Tối';
GO

-- Timesheets (actual worked times)
-- Employee1 morning shift today (07:00 - 12:00, 15 min break)
INSERT INTO EmployeeShiftTimesheets (EmployeeID, ShiftID, WorkDate, CheckInAt, CheckOutAt, BreakMinutes, Status, Source, HoursWorked, ApprovedBy, ApprovedAt, Notes)
SELECT e.EmployeeID,
       s.ShiftID,
       CAST(SYSDATETIME() AS DATE),
       DATEADD(MINUTE, -5, s.StartAt),
       DATEADD(MINUTE, 10, s.EndAt),
       15,
       'Approved',
       'Manual',
       4.75,
       uHR.UserID,
       SYSDATETIME(),
       N'Check-in sớm 5 phút; check-out muộn 10 phút'
FROM Employees e
JOIN Users uEmp ON uEmp.UserID = e.UserID AND uEmp.Email = 'employee1@liteflow.vn'
JOIN EmployeeShifts s ON s.EmployeeID = e.EmployeeID AND CONVERT(date, s.StartAt) = CAST(SYSDATETIME() AS DATE) AND s.Title = N'Ca Sáng'
CROSS JOIN Users uHR
WHERE uHR.Email = 'hr@liteflow.vn';
GO

-- Holidays and exchange rates
INSERT INTO HolidayCalendar (HolidayDate, Name, Region, DayType, IsPaidHoliday)
VALUES ('2025-09-02', N'Quốc khánh Việt Nam', 'VN', 'Public', 1);

INSERT INTO ExchangeRates (Currency, RateToVND, RateDate, Source)
VALUES ('USD', 24800.000000, CAST(SYSDATETIME() AS DATE), N'Static Sample'),
       ('VND', 1.000000, CAST(SYSDATETIME() AS DATE), N'Parity');
GO

-- Pay period for current month and a payroll run
DECLARE @StartOfMonth DATE = DATEADD(DAY, 1, EOMONTH(SYSDATETIME(), -1));
DECLARE @EndOfMonth DATE = EOMONTH(SYSDATETIME(), 0);

DECLARE @PeriodID UNIQUEIDENTIFIER = NEWID();
INSERT INTO PayPeriods (PayPeriodID, Name, PeriodType, StartDate, EndDate, Status)
VALUES (@PeriodID, FORMAT(@StartOfMonth, 'yyyy-MM') + N' - Kỳ lương', 'Monthly', @StartOfMonth, @EndOfMonth, 'Open');

DECLARE @RunID UNIQUEIDENTIFIER = NEWID();
INSERT INTO PayrollRuns (PayrollRunID, PayPeriodID, RunNumber, Status, CalculatedAt, Notes)
VALUES (@RunID, @PeriodID, 1, 'Calculated', SYSDATETIME(), N'Chạy lương mẫu cho kỳ hiện tại');

-- Payroll entries for two employees (same batch to keep @RunID)
INSERT INTO PayrollEntries (PayrollRunID, EmployeeID, CompensationType, BaseSalary, HourlyRate, PerShiftRate, HoursWorked, ShiftsWorked, OvertimeHours, HolidayHours, Allowances, Bonuses, Deductions, GrossPay, NetPay)
SELECT @RunID, e.EmployeeID, 'Fixed', 12000000, NULL, NULL, NULL, NULL, 0, 0, 0, 500000, 0, 12500000, 12500000
FROM Employees e JOIN Users u ON u.UserID = e.UserID AND u.Email = 'cashier1@liteflow.vn';

INSERT INTO PayrollEntries (PayrollRunID, EmployeeID, CompensationType, BaseSalary, HourlyRate, PerShiftRate, HoursWorked, ShiftsWorked, OvertimeHours, HolidayHours, Allowances, Bonuses, Deductions, GrossPay, NetPay)
SELECT @RunID, e.EmployeeID, 'PerShift', NULL, NULL, 100000, 4.75, 1, 0, 0, 0, 0, 0, 100000, 100000
FROM Employees e JOIN Users u ON u.UserID = e.UserID AND u.Email = 'employee1@liteflow.vn';

-- One payroll adjustment (allowance) for barista (same batch)
INSERT INTO PayrollAdjustments (PayrollRunID, EmployeeID, AdjustmentType, Amount, Reason, CreatedBy, CreatedAt)
SELECT @RunID, e.EmployeeID, 'Allowance', 50000, N'Phụ cấp chuyên cần', uHR.UserID, SYSDATETIME()
FROM Employees e
JOIN Users u ON u.UserID = e.UserID AND u.Email = 'employee1@liteflow.vn'
CROSS JOIN Users uHR
WHERE uHR.Email = 'hr@liteflow.vn';
GO
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
-- 7️⃣ ROOMS & TABLES
-- ============================================================
INSERT INTO Rooms (Name, Description) VALUES
(N'Tầng 1', N'Khu vực tầng 1'),
(N'Tầng 2', N'Khu vực tầng 2'),
(N'VIP', N'Phòng VIP riêng tư');
GO

INSERT INTO Tables (RoomID, TableNumber, TableName, Capacity, Status) VALUES
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 1'), 'T1-01', 'Bàn 1', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 1'), 'T1-02', 'Bàn 2', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 1'), 'T1-03', 'Bàn 3', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 1'), 'T1-04', 'Bàn 4', 2, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 1'), 'T1-05', 'Bàn 5', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-01', 'Bàn 6', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-02', 'Bàn 7', 8, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-03', 'Bàn 8', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Tầng 2'), 'T2-04', 'Bàn 9', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'VIP'), 'VIP-01', 'Bàn VIP 1', 6, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'VIP'), 'VIP-02', 'Bàn VIP 2', 8, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'VIP'), 'VIP-03', 'Bàn VIP 3', 4, 'Available');
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
-- 1️⃣ THÊM PHÒNG VÀ BÀN MẪU
-- ============================================================

-- Thêm phòng mới
INSERT INTO Rooms (Name, Description) VALUES
(N'Phòng Ngoài Trời', N'Khu vực ngoài trời, thoáng mát'),
(N'Phòng Họp', N'Phòng họp riêng tư cho khách VIP'),
(N'Khu Vực Lễ Tân', N'Khu vực gần lễ tân, tiện lợi');
GO

-- Thêm bàn mẫu với các trạng thái khác nhau
INSERT INTO Tables (RoomID, TableNumber, TableName, Capacity, Status) VALUES
-- Phòng Ngoài Trời
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-01', N'Bàn Ngoài Trời 1', 4, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-02', N'Bàn Ngoài Trời 2', 6, 'Occupied'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-03', N'Bàn Ngoài Trời 3', 8, 'Reserved'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Ngoài Trời'), 'NT-04', N'Bàn Ngoài Trời 4', 2, 'Maintenance'),

-- Phòng Họp
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Họp'), 'PH-01', N'Bàn Họp 1', 10, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Họp'), 'PH-02', N'Bàn Họp 2', 12, 'Occupied'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Phòng Họp'), 'PH-03', N'Bàn Họp 3', 8, 'Available'),

-- Khu Vực Lễ Tân
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-01', N'Bàn Lễ Tân 1', 2, 'Available'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-02', N'Bàn Lễ Tân 2', 4, 'Occupied'),
((SELECT TOP 1 RoomID FROM Rooms WHERE Name = N'Khu Vực Lễ Tân'), 'LT-03', N'Bàn Lễ Tân 3', 2, 'Available');

-- Thêm bàn không có phòng (test case)
INSERT INTO Tables (RoomID, TableNumber, TableName, Capacity, Status) VALUES
(NULL, 'NO-ROOM-01', 'Bàn Không Phòng 1', 4, 'Available'),
(NULL, 'NO-ROOM-02', 'Bàn Không Phòng 2', 6, 'Occupied');

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
    
    SET @counter = @counter + 1;
END

GO

-- ============================================================
-- 8️⃣ SEED ATTENDANCE STATUS FOR CURRENT WEEK
-- ============================================================
USE LiteFlowDBO;
GO

DECLARE @Mon DATE;
DECLARE @today2 DATE = CAST(SYSDATETIME() AS DATE);
SET @Mon = DATEADD(DAY, -((DATEPART(WEEKDAY, @today2) + 5) % 7), @today2); -- Monday

-- Barista employee (employee1@liteflow.vn): Mon-Fri work, Wed paid leave, Thu unpaid leave
DECLARE @EmpBarista UNIQUEIDENTIFIER = (
  SELECT e.EmployeeID FROM Employees e JOIN Users u ON u.UserID = e.UserID AND u.Email = 'employee1@liteflow.vn'
);

IF @EmpBarista IS NOT NULL
BEGIN
  -- Mon: Work 07:05 - 12:10
  MERGE EmployeeAttendance AS t
  USING (SELECT @EmpBarista AS EmployeeID, @Mon AS WorkDate) s
  ON (t.EmployeeID = s.EmployeeID AND t.WorkDate = s.WorkDate)
  WHEN MATCHED THEN UPDATE SET Status = 'Work', CheckInTime = '07:05', CheckOutTime = '12:10', UpdatedAt = SYSDATETIME()
  WHEN NOT MATCHED THEN INSERT (EmployeeID, WorkDate, Status, CheckInTime, CheckOutTime)
    VALUES (@EmpBarista, @Mon, 'Work', '07:05', '12:10');

  -- Tue: Work 07:00 - 12:00
  MERGE EmployeeAttendance AS t
  USING (SELECT @EmpBarista AS EmployeeID, DATEADD(DAY, 1, @Mon) AS WorkDate) s
  ON (t.EmployeeID = s.EmployeeID AND t.WorkDate = s.WorkDate)
  WHEN MATCHED THEN UPDATE SET Status = 'Work', CheckInTime = '07:00', CheckOutTime = '12:00', UpdatedAt = SYSDATETIME()
  WHEN NOT MATCHED THEN INSERT (EmployeeID, WorkDate, Status, CheckInTime, CheckOutTime)
    VALUES (@EmpBarista, DATEADD(DAY, 1, @Mon), 'Work', '07:00', '12:00');

  -- Wed: Leave Paid
  MERGE EmployeeAttendance AS t
  USING (SELECT @EmpBarista AS EmployeeID, DATEADD(DAY, 2, @Mon) AS WorkDate) s
  ON (t.EmployeeID = s.EmployeeID AND t.WorkDate = s.WorkDate)
  WHEN MATCHED THEN UPDATE SET Status = 'LeavePaid', CheckInTime = NULL, CheckOutTime = NULL, UpdatedAt = SYSDATETIME()
  WHEN NOT MATCHED THEN INSERT (EmployeeID, WorkDate, Status)
    VALUES (@EmpBarista, DATEADD(DAY, 2, @Mon), 'LeavePaid');

  -- Thu: Leave Unpaid
  MERGE EmployeeAttendance AS t
  USING (SELECT @EmpBarista AS EmployeeID, DATEADD(DAY, 3, @Mon) AS WorkDate) s
  ON (t.EmployeeID = s.EmployeeID AND t.WorkDate = s.WorkDate)
  WHEN MATCHED THEN UPDATE SET Status = 'LeaveUnpaid', CheckInTime = NULL, CheckOutTime = NULL, UpdatedAt = SYSDATETIME()
  WHEN NOT MATCHED THEN INSERT (EmployeeID, WorkDate, Status)
    VALUES (@EmpBarista, DATEADD(DAY, 3, @Mon), 'LeaveUnpaid');

  -- Fri: Work 07:10 - 12:05
  MERGE EmployeeAttendance AS t
  USING (SELECT @EmpBarista AS EmployeeID, DATEADD(DAY, 4, @Mon) AS WorkDate) s
  ON (t.EmployeeID = s.EmployeeID AND t.WorkDate = s.WorkDate)
  WHEN MATCHED THEN UPDATE SET Status = 'Work', CheckInTime = '07:10', CheckOutTime = '12:05', UpdatedAt = SYSDATETIME()
  WHEN NOT MATCHED THEN INSERT (EmployeeID, WorkDate, Status, CheckInTime, CheckOutTime)
    VALUES (@EmpBarista, DATEADD(DAY, 4, @Mon), 'Work', '07:10', '12:05');
END
GO

-- Cashier employee (cashier1@liteflow.vn): Work Tue/Thu evening
DECLARE @EmpCashier UNIQUEIDENTIFIER = (
  SELECT e.EmployeeID FROM Employees e JOIN Users u ON u.UserID = e.UserID AND u.Email = 'cashier1@liteflow.vn'
);

IF @EmpCashier IS NOT NULL
BEGIN
  -- Tue: Work 17:00 - 22:00
  MERGE EmployeeAttendance AS t
  USING (SELECT @EmpCashier AS EmployeeID, DATEADD(DAY, 1, @Mon) AS WorkDate) s
  ON (t.EmployeeID = s.EmployeeID AND t.WorkDate = s.WorkDate)
  WHEN MATCHED THEN UPDATE SET Status = 'Work', CheckInTime = '17:00', CheckOutTime = '22:00', UpdatedAt = SYSDATETIME()
  WHEN NOT MATCHED THEN INSERT (EmployeeID, WorkDate, Status, CheckInTime, CheckOutTime)
    VALUES (@EmpCashier, DATEADD(DAY, 1, @Mon), 'Work', '17:00', '22:00');

  -- Thu: Work 17:05 - 22:10
  MERGE EmployeeAttendance AS t
  USING (SELECT @EmpCashier AS EmployeeID, DATEADD(DAY, 3, @Mon) AS WorkDate) s
  ON (t.EmployeeID = s.EmployeeID AND t.WorkDate = s.WorkDate)
  WHEN MATCHED THEN UPDATE SET Status = 'Work', CheckInTime = '17:05', CheckOutTime = '22:10', UpdatedAt = SYSDATETIME()
  WHEN NOT MATCHED THEN INSERT (EmployeeID, WorkDate, Status, CheckInTime, CheckOutTime)
    VALUES (@EmpCashier, DATEADD(DAY, 3, @Mon), 'Work', '17:05', '22:10');
END
GO

-- ============================================================
-- 9️⃣ SEED BONUS/PENALTY EVENTS FOR CURRENT WEEK
-- ============================================================
USE LiteFlowDBO;
GO

DECLARE @HRUser UNIQUEIDENTIFIER = (SELECT TOP 1 UserID FROM Users WHERE Email = 'hr@liteflow.vn');

IF @EmpBarista IS NOT NULL
BEGIN
  INSERT INTO EmployeeCompEvents (EmployeeID, WorkDate, EventType, Amount, Reason, CreatedBy)
  VALUES (@EmpBarista, DATEADD(DAY, 1, @Mon), 'Bonus', 50000, N'Thưởng hiệu suất ca sáng', @HRUser);

  INSERT INTO EmployeeCompEvents (EmployeeID, WorkDate, EventType, Amount, Reason, CreatedBy)
  VALUES (@EmpBarista, DATEADD(DAY, 4, @Mon), 'Penalty', 20000, N'Đi trễ 10 phút', @HRUser);
END

IF @EmpCashier IS NOT NULL
BEGIN
  INSERT INTO EmployeeCompEvents (EmployeeID, WorkDate, EventType, Amount, Reason, CreatedBy)
  VALUES (@EmpCashier, DATEADD(DAY, 3, @Mon), 'Bonus', 30000, N'Hỗ trợ đóng ca tối', @HRUser);
END
GO