-- ============================================================
-- EMPLOYEE NOTICE BOARD SYSTEM
-- Hệ thống bảng thông báo cho nhân viên
-- ============================================================

USE LiteFlowDBO;
GO

-- ============================================================
-- NOTICES TABLE
-- Bảng lưu trữ thông báo gửi từ Admin đến Employee
-- ============================================================

IF OBJECT_ID('Notices', 'U') IS NOT NULL DROP TABLE Notices;
GO

CREATE TABLE Notices (
    NoticeID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),

    -- Notice Content
    Title NVARCHAR(200) NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,

    -- Notice Type/Priority
    NoticeType NVARCHAR(20) DEFAULT 'general' CHECK (NoticeType IN ('important', 'general', 'info', 'urgent')),

    -- Status
    IsActive BIT DEFAULT 1,
    IsPinned BIT DEFAULT 0, -- Ghim thông báo lên đầu

    -- Display Period
    PublishedAt DATETIME2 DEFAULT SYSDATETIME(),
    ExpiresAt DATETIME2 NULL, -- Null = không hết hạn

    -- Target Audience (NULL = all employees)
    TargetRoles NVARCHAR(MAX) NULL, -- JSON array: ["Employee", "Manager"]
    TargetUserIDs NVARCHAR(MAX) NULL, -- JSON array of specific user IDs

    -- Creator Info
    CreatedBy UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE NO ACTION,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 DEFAULT SYSDATETIME(),

    -- Metadata
    ViewCount INT DEFAULT 0, -- Số lượt xem

    CONSTRAINT FK_Notices_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserID) ON DELETE NO ACTION
);
GO

CREATE INDEX IX_Notices_Type ON Notices(NoticeType);
CREATE INDEX IX_Notices_Active ON Notices(IsActive);
CREATE INDEX IX_Notices_Published ON Notices(PublishedAt);
CREATE INDEX IX_Notices_Pinned ON Notices(IsPinned) WHERE IsPinned = 1;
CREATE INDEX IX_Notices_Expiry ON Notices(ExpiresAt) WHERE ExpiresAt IS NOT NULL;
GO

-- ============================================================
-- NOTICE READS TABLE
-- Theo dõi nhân viên nào đã đọc thông báo nào
-- ============================================================

IF OBJECT_ID('NoticeReads', 'U') IS NOT NULL DROP TABLE NoticeReads;
GO

CREATE TABLE NoticeReads (
    ReadID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    NoticeID UNIQUEIDENTIFIER NOT NULL,
    UserID UNIQUEIDENTIFIER NOT NULL,
    ReadAt DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_NoticeReads_Notice FOREIGN KEY (NoticeID) REFERENCES Notices(NoticeID) ON DELETE CASCADE,
    CONSTRAINT FK_NoticeReads_User FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    CONSTRAINT UQ_NoticeReads_NoticeUser UNIQUE (NoticeID, UserID)
);
GO

CREATE INDEX IX_NoticeReads_NoticeID ON NoticeReads(NoticeID);
CREATE INDEX IX_NoticeReads_UserID ON NoticeReads(UserID);
GO

-- ============================================================
-- VIEWS
-- ============================================================

-- Active Notices View
IF OBJECT_ID('vw_ActiveNotices', 'V') IS NOT NULL DROP VIEW vw_ActiveNotices;
GO

CREATE VIEW vw_ActiveNotices AS
SELECT
    n.NoticeID,
    n.Title,
    n.Content,
    n.NoticeType,
    n.IsPinned,
    n.PublishedAt,
    n.ExpiresAt,
    n.ViewCount,
    u.DisplayName as CreatedByName,
    n.CreatedBy,
    n.CreatedAt,
    DATEDIFF(DAY, n.PublishedAt, SYSDATETIME()) as DaysAgo
FROM Notices n
INNER JOIN Users u ON n.CreatedBy = u.UserID
WHERE n.IsActive = 1
  AND (n.ExpiresAt IS NULL OR n.ExpiresAt > SYSDATETIME());
GO

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- Get Active Notices for Employee Dashboard
IF OBJECT_ID('sp_GetActiveNotices', 'P') IS NOT NULL DROP PROCEDURE sp_GetActiveNotices;
GO

CREATE PROCEDURE sp_GetActiveNotices
    @UserID UNIQUEIDENTIFIER = NULL,
    @Limit INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Limit)
        n.NoticeID,
        n.Title,
        n.Content,
        n.NoticeType,
        n.IsPinned,
        n.PublishedAt,
        n.ViewCount,
        u.DisplayName as CreatedByName,
        CASE WHEN nr.ReadID IS NOT NULL THEN 1 ELSE 0 END as IsRead
    FROM Notices n
    INNER JOIN Users u ON n.CreatedBy = u.UserID
    LEFT JOIN NoticeReads nr ON n.NoticeID = nr.NoticeID AND nr.UserID = @UserID
    WHERE n.IsActive = 1
      AND (n.ExpiresAt IS NULL OR n.ExpiresAt > SYSDATETIME())
    ORDER BY n.IsPinned DESC, n.PublishedAt DESC;
END;
GO

-- Mark Notice as Read
IF OBJECT_ID('sp_MarkNoticeRead', 'P') IS NOT NULL DROP PROCEDURE sp_MarkNoticeRead;
GO

CREATE PROCEDURE sp_MarkNoticeRead
    @NoticeID UNIQUEIDENTIFIER,
    @UserID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert or ignore if already read
    IF NOT EXISTS (SELECT 1 FROM NoticeReads WHERE NoticeID = @NoticeID AND UserID = @UserID)
    BEGIN
        INSERT INTO NoticeReads (NoticeID, UserID, ReadAt)
        VALUES (@NoticeID, @UserID, SYSDATETIME());

        -- Update view count
        UPDATE Notices
        SET ViewCount = ViewCount + 1
        WHERE NoticeID = @NoticeID;
    END
END;
GO

-- Create New Notice
IF OBJECT_ID('sp_CreateNotice', 'P') IS NOT NULL DROP PROCEDURE sp_CreateNotice;
GO

CREATE PROCEDURE sp_CreateNotice
    @Title NVARCHAR(200),
    @Content NVARCHAR(MAX),
    @NoticeType NVARCHAR(20),
    @IsPinned BIT = 0,
    @ExpiresAt DATETIME2 = NULL,
    @CreatedBy UNIQUEIDENTIFIER,
    @NoticeID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @NoticeID = NEWID();

    INSERT INTO Notices (
        NoticeID,
        Title,
        Content,
        NoticeType,
        IsPinned,
        ExpiresAt,
        CreatedBy,
        PublishedAt
    )
    VALUES (
        @NoticeID,
        @Title,
        @Content,
        @NoticeType,
        @IsPinned,
        @ExpiresAt,
        @CreatedBy,
        SYSDATETIME()
    );
END;
GO

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Auto-expire old notices
IF OBJECT_ID('tr_Notices_AutoExpire', 'TR') IS NOT NULL DROP TRIGGER tr_Notices_AutoExpire;
GO

CREATE TRIGGER tr_Notices_AutoExpire
ON Notices
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Deactivate expired notices
    UPDATE Notices
    SET IsActive = 0
    WHERE ExpiresAt IS NOT NULL
      AND ExpiresAt < SYSDATETIME()
      AND IsActive = 1;
END;
GO

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

PRINT '========================================';
PRINT '✅ NOTICE BOARD SYSTEM CREATED!';
PRINT '========================================';
PRINT 'Tables Created:';
PRINT '  1. Notices';
PRINT '  2. NoticeReads';
PRINT '';
PRINT 'Views Created:';
PRINT '  1. vw_ActiveNotices';
PRINT '';
PRINT 'Stored Procedures:';
PRINT '  1. sp_GetActiveNotices';
PRINT '  2. sp_MarkNoticeRead';
PRINT '  3. sp_CreateNotice';
PRINT '========================================';
GO
