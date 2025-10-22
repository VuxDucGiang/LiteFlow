-- ============================================================
-- PROCUREMENT MODULE - DATABASE SCHEMA & QUERIES
-- Updated with current implementation
-- ============================================================

USE LiteFlowDBO;
GO

-- ============================================================
-- 1️⃣ TABLE CREATION (Procurement Schema)
-- ============================================================

-- Suppliers Table
CREATE TABLE Suppliers (
    SupplierID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(150) NOT NULL UNIQUE,
    Contact NVARCHAR(100),
    Email NVARCHAR(150),
    Phone NVARCHAR(50),
    Address NVARCHAR(250),
    Rating DECIMAL(3,2) DEFAULT 0,
    OnTimeRate DECIMAL(5,2) DEFAULT 0,
    DefectRate DECIMAL(5,2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CreatedBy UNIQUEIDENTIFIER REFERENCES Users(UserID)
);

-- Supplier SLA Tracking
CREATE TABLE SupplierSLA (
    SLAID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SupplierID UNIQUEIDENTIFIER REFERENCES Suppliers(SupplierID),
    TotalOrders INT DEFAULT 0,
    OnTimeDeliveries INT DEFAULT 0,
    AvgDelayDays DECIMAL(5,2) DEFAULT 0,
    LastEvaluated DATETIME2 DEFAULT SYSUTCDATETIME()
);

-- Purchase Orders
CREATE TABLE PurchaseOrders (
    POID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SupplierID UNIQUEIDENTIFIER REFERENCES Suppliers(SupplierID),
    CreatedBy UNIQUEIDENTIFIER REFERENCES Users(UserID),
    ApprovedBy UNIQUEIDENTIFIER NULL REFERENCES Users(UserID),
    CreateDate DATETIME2 DEFAULT SYSUTCDATETIME(),
    ExpectedDelivery DATETIME2,
    TotalAmount DECIMAL(18,2) DEFAULT 0,
    Status NVARCHAR(20) DEFAULT 'PENDING',
    ApprovalLevel INT DEFAULT 1,
    ApprovedAt DATETIME2,
    Notes NVARCHAR(300)
);

-- Purchase Order Items
CREATE TABLE PurchaseOrderItems (
    ItemID INT IDENTITY PRIMARY KEY,
    POID UNIQUEIDENTIFIER REFERENCES PurchaseOrders(POID) ON DELETE CASCADE,
    ItemName NVARCHAR(150),
    Quantity INT,
    UnitPrice DECIMAL(18,2),
    Total AS (Quantity * UnitPrice) PERSISTED
);

-- Goods Receipts
CREATE TABLE GoodsReceipts (
    ReceiptID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    POID UNIQUEIDENTIFIER REFERENCES PurchaseOrders(POID),
    ReceivedBy UNIQUEIDENTIFIER REFERENCES Users(UserID),
    ReceiveDate DATETIME2 DEFAULT SYSUTCDATETIME(),
    Notes NVARCHAR(200),
    Status NVARCHAR(20) CHECK (Status IN ('PARTIAL','FULL'))
);

-- Invoices
CREATE TABLE Invoices (
    InvoiceID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    POID UNIQUEIDENTIFIER REFERENCES PurchaseOrders(POID),
    SupplierID UNIQUEIDENTIFIER REFERENCES Suppliers(SupplierID),
    InvoiceDate DATETIME2 DEFAULT SYSUTCDATETIME(),
    TotalAmount DECIMAL(18,2),
    Matched BIT DEFAULT 0,
    MatchNote NVARCHAR(200)
);
GO

-- ============================================================
-- 2️⃣ INDEXES FOR PERFORMANCE
-- ============================================================

-- Suppliers indexes
CREATE INDEX IX_Suppliers_Name ON Suppliers(Name);
CREATE INDEX IX_Suppliers_Email ON Suppliers(Email);
CREATE INDEX IX_Suppliers_IsActive ON Suppliers(IsActive);

-- Purchase Orders indexes
CREATE INDEX IX_PurchaseOrders_SupplierID ON PurchaseOrders(SupplierID);
CREATE INDEX IX_PurchaseOrders_Status ON PurchaseOrders(Status);
CREATE INDEX IX_PurchaseOrders_CreateDate ON PurchaseOrders(CreateDate);
CREATE INDEX IX_PurchaseOrders_ExpectedDelivery ON PurchaseOrders(ExpectedDelivery);
CREATE INDEX IX_PurchaseOrders_CreatedBy ON PurchaseOrders(CreatedBy);

-- Purchase Order Items indexes
CREATE INDEX IX_PurchaseOrderItems_POID ON PurchaseOrderItems(POID);

-- Goods Receipts indexes
CREATE INDEX IX_GoodsReceipts_POID ON GoodsReceipts(POID);
CREATE INDEX IX_GoodsReceipts_ReceiveDate ON GoodsReceipts(ReceiveDate);

-- Invoices indexes
CREATE INDEX IX_Invoices_POID ON Invoices(POID);
CREATE INDEX IX_Invoices_SupplierID ON Invoices(SupplierID);
GO

-- ============================================================
-- 3️⃣ STORED PROCEDURES - SUPPLIER MANAGEMENT
-- ============================================================

-- Get All Suppliers
CREATE PROCEDURE sp_GetAllSuppliers
AS
BEGIN
    SELECT 
        s.SupplierID,
        s.Name,
        s.Contact,
        s.Email,
        s.Phone,
        s.Address,
        s.Rating,
        s.OnTimeRate,
        s.DefectRate,
        s.IsActive,
        s.CreatedAt,
        s.CreatedBy,
        sla.TotalOrders,
        sla.OnTimeDeliveries,
        sla.AvgDelayDays,
        sla.LastEvaluated
    FROM Suppliers s
    LEFT JOIN SupplierSLA sla ON s.SupplierID = sla.SupplierID
    WHERE s.IsActive = 1
    ORDER BY s.Name;
END
GO

-- Create New Supplier
CREATE PROCEDURE sp_CreateSupplier
    @Name NVARCHAR(150),
    @Contact NVARCHAR(100) = NULL,
    @Email NVARCHAR(150) = NULL,
    @Phone NVARCHAR(50) = NULL,
    @Address NVARCHAR(250) = NULL,
    @Rating DECIMAL(3,2) = 0,
    @OnTimeRate DECIMAL(5,2) = 0,
    @DefectRate DECIMAL(5,2) = 0,
    @CreatedBy UNIQUEIDENTIFIER,
    @SupplierID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET @SupplierID = NEWID();
    
    INSERT INTO Suppliers (SupplierID, Name, Contact, Email, Phone, Address, Rating, OnTimeRate, DefectRate, CreatedBy)
    VALUES (@SupplierID, @Name, @Contact, @Email, @Phone, @Address, @Rating, @OnTimeRate, @DefectRate, @CreatedBy);
    
    -- Initialize SLA tracking
    INSERT INTO SupplierSLA (SupplierID, TotalOrders, OnTimeDeliveries, AvgDelayDays)
    VALUES (@SupplierID, 0, 0, 0);
END
GO

-- Update Supplier
CREATE PROCEDURE sp_UpdateSupplier
    @SupplierID UNIQUEIDENTIFIER,
    @Name NVARCHAR(150) = NULL,
    @Contact NVARCHAR(100) = NULL,
    @Email NVARCHAR(150) = NULL,
    @Phone NVARCHAR(50) = NULL,
    @Address NVARCHAR(250) = NULL,
    @Rating DECIMAL(3,2) = NULL,
    @OnTimeRate DECIMAL(5,2) = NULL,
    @DefectRate DECIMAL(5,2) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    UPDATE Suppliers 
    SET 
        Name = ISNULL(@Name, Name),
        Contact = ISNULL(@Contact, Contact),
        Email = ISNULL(@Email, Email),
        Phone = ISNULL(@Phone, Phone),
        Address = ISNULL(@Address, Address),
        Rating = ISNULL(@Rating, Rating),
        OnTimeRate = ISNULL(@OnTimeRate, OnTimeRate),
        DefectRate = ISNULL(@DefectRate, DefectRate),
        IsActive = ISNULL(@IsActive, IsActive)
    WHERE SupplierID = @SupplierID;
END
GO

-- ============================================================
-- 4️⃣ STORED PROCEDURES - PURCHASE ORDER MANAGEMENT
-- ============================================================

-- Get All Purchase Orders with Supplier Info
CREATE PROCEDURE sp_GetAllPurchaseOrders
AS
BEGIN
    SELECT 
        po.POID,
        po.SupplierID,
        s.Name as SupplierName,
        po.CreatedBy,
        u.FullName as CreatedByName,
        po.CreateDate,
        po.ExpectedDelivery,
        po.TotalAmount,
        po.Status,
        po.ApprovalLevel,
        po.ApprovedAt,
        po.Notes,
        COUNT(poi.ItemID) as ItemCount
    FROM PurchaseOrders po
    LEFT JOIN Suppliers s ON po.SupplierID = s.SupplierID
    LEFT JOIN Users u ON po.CreatedBy = u.UserID
    LEFT JOIN PurchaseOrderItems poi ON po.POID = poi.POID
    GROUP BY po.POID, po.SupplierID, s.Name, po.CreatedBy, u.FullName, 
             po.CreateDate, po.ExpectedDelivery, po.TotalAmount, po.Status, 
             po.ApprovalLevel, po.ApprovedAt, po.Notes
    ORDER BY po.CreateDate DESC;
END
GO

-- Get Purchase Order Details with Items
CREATE PROCEDURE sp_GetPurchaseOrderDetails
    @POID UNIQUEIDENTIFIER
AS
BEGIN
    -- Get PO basic info
    SELECT 
        po.POID,
        po.SupplierID,
        s.Name as SupplierName,
        s.Contact as SupplierContact,
        s.Email as SupplierEmail,
        s.Phone as SupplierPhone,
        s.Address as SupplierAddress,
        po.CreatedBy,
        u.FullName as CreatedByName,
        po.CreateDate,
        po.ExpectedDelivery,
        po.TotalAmount,
        po.Status,
        po.ApprovalLevel,
        po.ApprovedAt,
        po.Notes
    FROM PurchaseOrders po
    LEFT JOIN Suppliers s ON po.SupplierID = s.SupplierID
    LEFT JOIN Users u ON po.CreatedBy = u.UserID
    WHERE po.POID = @POID;
    
    -- Get PO items
    SELECT 
        poi.ItemID,
        poi.ItemName,
        poi.Quantity,
        poi.UnitPrice,
        poi.Total
    FROM PurchaseOrderItems poi
    WHERE poi.POID = @POID
    ORDER BY poi.ItemID;
END
GO

-- Create New Purchase Order
CREATE PROCEDURE sp_CreatePurchaseOrder
    @SupplierID UNIQUEIDENTIFIER,
    @CreatedBy UNIQUEIDENTIFIER,
    @ExpectedDelivery DATETIME2,
    @Notes NVARCHAR(300) = NULL,
    @POID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET @POID = NEWID();
    
    INSERT INTO PurchaseOrders (POID, SupplierID, CreatedBy, ExpectedDelivery, Notes)
    VALUES (@POID, @SupplierID, @CreatedBy, @ExpectedDelivery, @Notes);
END
GO

-- Add Item to Purchase Order
CREATE PROCEDURE sp_AddPurchaseOrderItem
    @POID UNIQUEIDENTIFIER,
    @ItemName NVARCHAR(150),
    @Quantity INT,
    @UnitPrice DECIMAL(18,2)
AS
BEGIN
    INSERT INTO PurchaseOrderItems (POID, ItemName, Quantity, UnitPrice)
    VALUES (@POID, @ItemName, @Quantity, @UnitPrice);
    
    -- Update PO total
    UPDATE PurchaseOrders 
    SET TotalAmount = (
        SELECT ISNULL(SUM(Quantity * UnitPrice), 0)
        FROM PurchaseOrderItems 
        WHERE POID = @POID
    )
    WHERE POID = @POID;
END
GO

-- Approve Purchase Order
CREATE PROCEDURE sp_ApprovePurchaseOrder
    @POID UNIQUEIDENTIFIER,
    @ApprovedBy UNIQUEIDENTIFIER
AS
BEGIN
    UPDATE PurchaseOrders 
    SET 
        Status = 'APPROVED',
        ApprovedBy = @ApprovedBy,
        ApprovedAt = SYSUTCDATETIME()
    WHERE POID = @POID;
END
GO

-- Reject Purchase Order
CREATE PROCEDURE sp_RejectPurchaseOrder
    @POID UNIQUEIDENTIFIER,
    @Notes NVARCHAR(300) = NULL
AS
BEGIN
    UPDATE PurchaseOrders 
    SET 
        Status = 'REJECTED',
        Notes = ISNULL(@Notes, Notes)
    WHERE POID = @POID;
END
GO

-- ============================================================
-- 5️⃣ VIEWS FOR REPORTING
-- ============================================================

-- Supplier Performance View
CREATE VIEW vw_SupplierPerformance AS
SELECT 
    s.SupplierID,
    s.Name,
    s.Rating,
    s.OnTimeRate,
    s.DefectRate,
    sla.TotalOrders,
    sla.OnTimeDeliveries,
    sla.AvgDelayDays,
    sla.LastEvaluated,
    CASE 
        WHEN sla.TotalOrders > 0 THEN (CAST(sla.OnTimeDeliveries AS FLOAT) / sla.TotalOrders) * 100
        ELSE 0 
    END as ActualOnTimeRate
FROM Suppliers s
LEFT JOIN SupplierSLA sla ON s.SupplierID = sla.SupplierID
WHERE s.IsActive = 1;
GO

-- Purchase Order Summary View
CREATE VIEW vw_PurchaseOrderSummary AS
SELECT 
    po.POID,
    s.Name as SupplierName,
    po.CreateDate,
    po.ExpectedDelivery,
    po.TotalAmount,
    po.Status,
    COUNT(poi.ItemID) as ItemCount,
    CASE 
        WHEN po.ExpectedDelivery < SYSUTCDATETIME() AND po.Status IN ('APPROVED', 'PENDING') THEN 1
        ELSE 0 
    END as IsOverdue
FROM PurchaseOrders po
LEFT JOIN Suppliers s ON po.SupplierID = s.SupplierID
LEFT JOIN PurchaseOrderItems poi ON po.POID = poi.POID
GROUP BY po.POID, s.Name, po.CreateDate, po.ExpectedDelivery, po.TotalAmount, po.Status;
GO

-- Monthly Procurement Report View
CREATE VIEW vw_MonthlyProcurementReport AS
SELECT 
    YEAR(po.CreateDate) as Year,
    MONTH(po.CreateDate) as Month,
    COUNT(*) as TotalOrders,
    SUM(CASE WHEN po.Status = 'APPROVED' THEN 1 ELSE 0 END) as ApprovedOrders,
    SUM(CASE WHEN po.Status = 'PENDING' THEN 1 ELSE 0 END) as PendingOrders,
    SUM(CASE WHEN po.Status = 'REJECTED' THEN 1 ELSE 0 END) as RejectedOrders,
    SUM(po.TotalAmount) as TotalValue,
    AVG(po.TotalAmount) as AvgOrderValue
FROM PurchaseOrders po
GROUP BY YEAR(po.CreateDate), MONTH(po.CreateDate);
GO

-- ============================================================
-- 6️⃣ TRIGGERS FOR DATA INTEGRITY
-- ============================================================

-- Update Supplier SLA when PO status changes
CREATE TRIGGER tr_UpdateSupplierSLA
ON PurchaseOrders
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Status)
    BEGIN
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

-- ============================================================
-- 7️⃣ UTILITY FUNCTIONS
-- ============================================================

-- Function to calculate supplier rating
CREATE FUNCTION fn_CalculateSupplierRating(@SupplierID UNIQUEIDENTIFIER)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @Rating DECIMAL(3,2);
    
    SELECT @Rating = (
        (s.OnTimeRate * 0.4) + 
        ((100 - s.DefectRate) * 0.4) + 
        (s.Rating * 0.2)
    ) / 100 * 5
    FROM Suppliers s
    WHERE s.SupplierID = @SupplierID;
    
    RETURN ISNULL(@Rating, 0);
END
GO

-- Function to get overdue orders count
CREATE FUNCTION fn_GetOverdueOrdersCount(@SupplierID UNIQUEIDENTIFIER = NULL)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    
    SELECT @Count = COUNT(*)
    FROM PurchaseOrders po
    WHERE po.ExpectedDelivery < SYSUTCDATETIME()
    AND po.Status IN ('APPROVED', 'PENDING')
    AND (@SupplierID IS NULL OR po.SupplierID = @SupplierID);
    
    RETURN ISNULL(@Count, 0);
END
GO

-- ============================================================
-- 8️⃣ SAMPLE QUERIES FOR TESTING
-- ============================================================

-- Query 1: Get all active suppliers with their performance
/*
SELECT * FROM vw_SupplierPerformance ORDER BY Rating DESC;
*/

-- Query 2: Get purchase orders by status
/*
SELECT Status, COUNT(*) as Count, SUM(TotalAmount) as TotalValue
FROM vw_PurchaseOrderSummary
GROUP BY Status;
*/

-- Query 3: Get overdue orders
/*
SELECT * FROM vw_PurchaseOrderSummary 
WHERE IsOverdue = 1
ORDER BY ExpectedDelivery;
*/

-- Query 4: Monthly procurement report
/*
SELECT * FROM vw_MonthlyProcurementReport
ORDER BY Year DESC, Month DESC;
*/

-- Query 5: Top suppliers by order value
/*
SELECT 
    s.Name,
    COUNT(po.POID) as OrderCount,
    SUM(po.TotalAmount) as TotalValue,
    AVG(po.TotalAmount) as AvgOrderValue
FROM Suppliers s
LEFT JOIN PurchaseOrders po ON s.SupplierID = po.SupplierID
WHERE s.IsActive = 1
GROUP BY s.SupplierID, s.Name
ORDER BY TotalValue DESC;
*/

PRINT '========================================';
PRINT 'PROCUREMENT MODULE SCHEMA CREATED SUCCESSFULLY!';
PRINT '========================================';
PRINT 'Tables: Suppliers, SupplierSLA, PurchaseOrders, PurchaseOrderItems, GoodsReceipts, Invoices';
PRINT 'Stored Procedures: sp_GetAllSuppliers, sp_CreateSupplier, sp_UpdateSupplier, sp_GetAllPurchaseOrders, etc.';
PRINT 'Views: vw_SupplierPerformance, vw_PurchaseOrderSummary, vw_MonthlyProcurementReport';
PRINT 'Functions: fn_CalculateSupplierRating, fn_GetOverdueOrdersCount';
PRINT 'Triggers: tr_UpdateSupplierSLA';
PRINT '========================================';
GO