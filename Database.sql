USE master;
GO
IF DB_ID('LiteFlowDBO') IS NOT NULL
BEGIN
    ALTER DATABASE LiteFlowDBO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LiteFlowDBO;
END
GO
CREATE DATABASE LiteFlowDBO;
GO
USE LiteFlowDBO;
GO

-- =======================================================
-- 1. AUTHENTICATION & AUTHORIZATION
-- =======================================================

-- USERS
CREATE TABLE Users (
    UserID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Email NVARCHAR(320) NOT NULL UNIQUE,
    Phone NVARCHAR(32) NULL,
    GoogleID NVARCHAR(200) NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    TwoFactorSecret NVARCHAR(200) NULL,
    DisplayName NVARCHAR(200),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),
    Meta NVARCHAR(MAX),
    Last2FAVerifiedAt DATETIME2 NULL
);
GO
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE UNIQUE INDEX UX_Users_Phone_NotNull ON Users(Phone) WHERE Phone IS NOT NULL;
GO

-- ROLES
CREATE TABLE Roles (
    RoleID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) UNIQUE,
    Description NVARCHAR(500)
);
GO

-- USER ROLES
CREATE TABLE UserRoles (
    UserID UNIQUEIDENTIFIER NOT NULL,
    RoleID UNIQUEIDENTIFIER NOT NULL,
    AssignedAt DATETIME2 DEFAULT SYSDATETIME(),
    AssignedBy UNIQUEIDENTIFIER NULL,
    IsActive BIT DEFAULT 1,
    PRIMARY KEY(UserID, RoleID),
    CONSTRAINT FK_UserRoles_User FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_UserRoles_Role FOREIGN KEY (RoleID) REFERENCES Roles(RoleID) ON DELETE CASCADE
);
GO

-- USER SESSIONS
CREATE TABLE UserSessions (
    SessionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL,
    JWT NVARCHAR(MAX),
    DeviceInfo NVARCHAR(500),
    IPAddress NVARCHAR(50),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    ExpiresAt DATETIME2,
    Revoked BIT DEFAULT 0,
    Last2faVerifiedAt DATETIME2 NULL,
    Action NVARCHAR(200),
    ObjectType NVARCHAR(100),
    ObjectID UNIQUEIDENTIFIER NULL,
    Details NVARCHAR(MAX),
    IPAddressAction NVARCHAR(50),
    CreatedAtAction DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_UserSessions_User FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO
CREATE INDEX IX_UserSessions_UserID ON UserSessions(UserID);
GO

-- OTP TOKENS
CREATE TABLE OtpTokens (
    OtpID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL,
    Code NVARCHAR(6) NOT NULL,
    ExpiresAt DATETIME2 NOT NULL,
    Used BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    IPAddress NVARCHAR(50),
	TargetEmail VARCHAR(320) NULL,
    CONSTRAINT FK_OtpTokens_User FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO
CREATE INDEX IX_OtpTokens_UserID ON OtpTokens(UserID);
CREATE INDEX IX_OtpTokens_Expiry ON OtpTokens(ExpiresAt, Used);
GO

-- AUDIT LOGS
CREATE TABLE AuditLogs (
    AuditID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NULL,
    Action NVARCHAR(200) NOT NULL,
    ObjectType NVARCHAR(100) NOT NULL,
    ObjectID NVARCHAR(36) NULL,
    Details NVARCHAR(MAX) NULL,
    IPAddress NVARCHAR(50) NULL,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_AuditLogs_User FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE SET NULL
);
GO
CREATE INDEX IX_AuditLogs_UserID ON AuditLogs(UserID);
CREATE INDEX IX_AuditLogs_Action ON AuditLogs(Action);
CREATE INDEX IX_AuditLogs_ObjectType ON AuditLogs(ObjectType);
CREATE INDEX IX_AuditLogs_CreatedAt ON AuditLogs(CreatedAt);
GO

-- TRIGGER cleanup OTP
CREATE OR ALTER TRIGGER TRG_Cleanup_OtpTokens
ON OtpTokens
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM OtpTokens
    WHERE ExpiresAt < SYSDATETIME() OR Used = 1;
END;
GO

-- =======================================================
-- 2. PRODUCT & CATEGORY
-- =======================================================
CREATE TABLE Categories (
    CategoryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX)
);

CREATE TABLE Products (
    ProductID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    ImageURL NVARCHAR(MAX),
    ImportDate DATETIME2 DEFAULT SYSDATETIME(),
    IsDeleted BIT NOT NULL DEFAULT 0
);

CREATE TABLE ProductVariant (
    ProductVariantID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProductID UNIQUEIDENTIFIER NOT NULL,
    Size NVARCHAR(50) NOT NULL,
    OriginalPrice DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Price DECIMAL(10,2) NOT NULL,
    DiscountPrice DECIMAL(10,2) DEFAULT NULL,
    DiscountExpiry DATETIME2,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);

CREATE TABLE ProductsCategories (
    ProductCategoryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProductID UNIQUEIDENTIFIER NOT NULL,
    CategoryID UNIQUEIDENTIFIER NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE CASCADE
);

-- =======================================================
-- 3. INVENTORY
-- =======================================================
CREATE TABLE Inventory (
    InventoryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    StoreLocation NVARCHAR(100) DEFAULT 'Main Warehouse'
);

CREATE TABLE ProductStock (
    ProductStockID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProductVariantID UNIQUEIDENTIFIER NOT NULL,
    InventoryID UNIQUEIDENTIFIER NOT NULL,
    Amount INT NOT NULL DEFAULT 0,
    FOREIGN KEY (ProductVariantID) REFERENCES ProductVariant(ProductVariantID) ON DELETE CASCADE,
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID) ON DELETE CASCADE
);

CREATE TABLE InventoryLogs (
    LogID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProductVariantID UNIQUEIDENTIFIER NOT NULL,
    ActionType NVARCHAR(10) NOT NULL,
    QuantityChanged INT NOT NULL,
    ActionDate DATETIME2 DEFAULT SYSDATETIME(),
    StoreLocation NVARCHAR(100) DEFAULT 'Main Warehouse',
    FOREIGN KEY (ProductVariantID) REFERENCES ProductVariant(ProductVariantID)
);

-- =======================================================
-- 4. CAFE MANAGEMENT SYSTEM
-- =======================================================

-- TABLE SESSIONS - Quản lý phiên làm việc của từng bàn
CREATE TABLE TableSessions (
    SessionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TableID UNIQUEIDENTIFIER NOT NULL,
    CustomerName NVARCHAR(200) NULL,  -- Tên khách hàng (tùy chọn)
    CustomerPhone NVARCHAR(20) NULL,  -- SĐT khách hàng (tùy chọn)
    CheckInTime DATETIME2 DEFAULT SYSDATETIME(),  -- Thời gian vào
    CheckOutTime DATETIME2 NULL,      -- Thời gian ra
    Status NVARCHAR(50) DEFAULT 'Active' CHECK (Status IN ('Active', 'Completed', 'Cancelled')),
    TotalAmount DECIMAL(10,2) DEFAULT 0.00,  -- Tổng tiền của phiên
    PaymentMethod NVARCHAR(50) NULL,  -- Phương thức thanh toán
    PaymentStatus NVARCHAR(50) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Unpaid', 'Paid', 'Partial')),
    Notes NVARCHAR(MAX) NULL,         -- Ghi chú
    CreatedBy UNIQUEIDENTIFIER NULL,  -- Nhân viên tạo phiên
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_TableSessions_Table FOREIGN KEY (TableID) REFERENCES Tables(TableID) ON DELETE CASCADE,
    CONSTRAINT FK_TableSessions_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserID) ON DELETE SET NULL
);

-- ORDERS - Đơn hàng trong phiên (có thể có nhiều đơn trong 1 phiên)
CREATE TABLE Orders (
    OrderID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SessionID UNIQUEIDENTIFIER NOT NULL,  -- Liên kết với phiên bàn
    OrderNumber NVARCHAR(50) NOT NULL,    -- Số đơn hàng (vd: ORD001, ORD002)
    OrderDate DATETIME2 DEFAULT SYSDATETIME(),
    SubTotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    VAT DECIMAL(10,2) DEFAULT 0.00,       -- Thuế VAT
    Discount DECIMAL(10,2) DEFAULT 0.00,  -- Giảm giá
    TotalAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Status NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Preparing', 'Ready', 'Served', 'Cancelled')),
    PaymentMethod NVARCHAR(50) NULL,
    PaymentStatus NVARCHAR(50) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Unpaid', 'Paid')),
    Notes NVARCHAR(MAX) NULL,
    CreatedBy UNIQUEIDENTIFIER NULL,
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_Orders_Session FOREIGN KEY (SessionID) REFERENCES TableSessions(SessionID) ON DELETE CASCADE,
    CONSTRAINT FK_Orders_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserID) ON DELETE SET NULL
);

-- ORDER DETAILS - Chi tiết món trong đơn hàng
CREATE TABLE OrderDetails (
    OrderDetailID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    OrderID UNIQUEIDENTIFIER NOT NULL,
    ProductVariantID UNIQUEIDENTIFIER NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,     -- Giá đơn vị
    TotalPrice DECIMAL(10,2) NOT NULL,    -- Tổng tiền = UnitPrice * Quantity
    SpecialInstructions NVARCHAR(500) NULL, -- Yêu cầu đặc biệt (ít đường, không đá, etc.)
    Status NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Preparing', 'Ready', 'Served')),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_OrderDetails_Order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_ProductVariant FOREIGN KEY (ProductVariantID) REFERENCES ProductVariant(ProductVariantID)
);

-- =======================================================
-- 5. USER INTERACTIONS
-- =======================================================
CREATE TABLE UserInteractions (
    InteractionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL,
    ProductID UNIQUEIDENTIFIER NOT NULL,
    InteractionType NVARCHAR(50) NOT NULL,
    InteractionTime DATETIME2 DEFAULT SYSDATETIME(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- =======================================================
-- 6. ROOMS & TABLES
-- =======================================================
CREATE TABLE Rooms (
    RoomID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME()
);

CREATE TABLE Tables (
    TableID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RoomID UNIQUEIDENTIFIER NULL,
    TableNumber NVARCHAR(50) NOT NULL,
    TableName NVARCHAR(100) NOT NULL,  -- Tên hiển thị (vd: "Bàn 1", "Bàn VIP")
    Capacity INT NOT NULL DEFAULT 4,   -- Sức chứa
    Status NVARCHAR(50) DEFAULT 'Available' CHECK (Status IN ('Available', 'Occupied', 'Reserved', 'Maintenance')),
    IsActive BIT DEFAULT 1,            -- Bàn có hoạt động không
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_Tables_Room FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID) ON DELETE SET NULL
);

-- =======================================================
-- 7. PAYMENT TRANSACTIONS
-- =======================================================
CREATE TABLE PaymentTransactions (
    TransactionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SessionID UNIQUEIDENTIFIER NOT NULL,
    OrderID UNIQUEIDENTIFIER NULL,  -- NULL nếu thanh toán toàn bộ phiên
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL CHECK (PaymentMethod IN ('Cash', 'Card', 'Transfer', 'Wallet')),
    PaymentStatus NVARCHAR(50) DEFAULT 'Completed' CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    TransactionReference NVARCHAR(200) NULL,  -- Mã giao dịch từ hệ thống thanh toán
    Notes NVARCHAR(500) NULL,
    ProcessedBy UNIQUEIDENTIFIER NULL,  -- Nhân viên xử lý thanh toán
    ProcessedAt DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_PaymentTransactions_Session FOREIGN KEY (SessionID) REFERENCES TableSessions(SessionID) ON DELETE CASCADE,
    CONSTRAINT FK_PaymentTransactions_Order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE SET NULL,
    CONSTRAINT FK_PaymentTransactions_ProcessedBy FOREIGN KEY (ProcessedBy) REFERENCES Users(UserID) ON DELETE SET NULL
);

-- =======================================================
-- 8. INDEXES
-- =======================================================
CREATE INDEX IX_Users_IsActive ON Users(IsActive);

CREATE INDEX IX_Products_Name ON Products(Name);
CREATE INDEX IX_Products_IsDeleted ON Products(IsDeleted);

CREATE INDEX IX_ProductVariant_ProductID ON ProductVariant(ProductID);
CREATE INDEX IX_ProductVariant_Price ON ProductVariant(Price);

-- Cafe Management Indexes
CREATE INDEX IX_TableSessions_TableID ON TableSessions(TableID);
CREATE INDEX IX_TableSessions_Status ON TableSessions(Status);
CREATE INDEX IX_TableSessions_CheckInTime ON TableSessions(CheckInTime);
CREATE INDEX IX_TableSessions_CheckOutTime ON TableSessions(CheckOutTime);

CREATE INDEX IX_Orders_SessionID ON Orders(SessionID);
CREATE INDEX IX_Orders_OrderNumber ON Orders(OrderNumber);
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX IX_Orders_Status ON Orders(Status);
CREATE INDEX IX_Orders_PaymentStatus ON Orders(PaymentStatus);

CREATE INDEX IX_OrderDetails_OrderID ON OrderDetails(OrderID);
CREATE INDEX IX_OrderDetails_ProductVariantID ON OrderDetails(ProductVariantID);
CREATE INDEX IX_OrderDetails_Status ON OrderDetails(Status);

CREATE INDEX IX_PaymentTransactions_SessionID ON PaymentTransactions(SessionID);
CREATE INDEX IX_PaymentTransactions_OrderID ON PaymentTransactions(OrderID);
CREATE INDEX IX_PaymentTransactions_ProcessedAt ON PaymentTransactions(ProcessedAt);

CREATE INDEX IX_Rooms_Name ON Rooms(Name);
CREATE INDEX IX_Tables_RoomID ON Tables(RoomID);
CREATE INDEX IX_Tables_Status ON Tables(Status);
CREATE INDEX IX_Tables_IsActive ON Tables(IsActive);
GO
USE LiteFlowDBO;
GO

-- =======================================================
-- 9. EMPLOYEES (Liên kết với bảng Users)
-- =======================================================

CREATE TABLE Employees (
    EmployeeID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL UNIQUE,  -- Liên kết 1-1 với Users
    EmployeeCode NVARCHAR(50) NOT NULL UNIQUE,  -- Mã số nhân viên (vd: EMP001)
    FullName NVARCHAR(200) NOT NULL,
    Gender NVARCHAR(10) CHECK (Gender IN (N'Nam', N'Nữ', N'Khác')),
    BirthDate DATE NULL,
    NationalID NVARCHAR(20) NULL,  -- Số CCCD/CMND
    Phone NVARCHAR(20) NULL,
    Email NVARCHAR(320) NULL,      -- Phụ, có thể khác Email user
    Address NVARCHAR(500) NULL,
    AvatarURL NVARCHAR(MAX) NULL,
    HireDate DATETIME2 DEFAULT SYSDATETIME(),
    TerminationDate DATETIME2 NULL,
    EmploymentStatus NVARCHAR(50) DEFAULT N'Đang làm' 
        CHECK (EmploymentStatus IN (N'Đang làm', N'Đã nghỉ', N'Tạm nghỉ')),
    Position NVARCHAR(100) NULL,   -- Chức vụ (vd: Thu ngân, Quản lý, Pha chế)
    Salary DECIMAL(12,2) NULL,     -- Lương cơ bản
    BankAccount NVARCHAR(100) NULL,
    BankName NVARCHAR(200) NULL,
    Notes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Employees_User FOREIGN KEY (UserID) 
        REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

-- =======================================================
-- 10. INDEXES CHO EMPLOYEE
-- =======================================================
CREATE INDEX IX_Employees_Status ON Employees(EmploymentStatus);
CREATE INDEX IX_Employees_Position ON Employees(Position);
CREATE INDEX IX_Employees_FullName ON Employees(FullName);
CREATE INDEX IX_Employees_HireDate ON Employees(HireDate);
GO
