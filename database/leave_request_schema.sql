USE LiteFlowDBO;
GO

-- =======================================================
-- LEAVE REQUESTS TABLE
-- =======================================================
CREATE TABLE LeaveRequests (
    LeaveRequestID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    EmployeeID UNIQUEIDENTIFIER NOT NULL,
    LeaveType NVARCHAR(20) NOT NULL CHECK (LeaveType IN (N'Nghỉ phép', N'Nghỉ bệnh', N'Nghỉ không lương', N'Nghỉ khác')),
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    TotalDays DECIMAL(5,2) NOT NULL,
    Reason NVARCHAR(1000) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT N'Chờ duyệt' CHECK (Status IN (N'Chờ duyệt', N'Đã duyệt', N'Từ chối', N'Đã hủy')),
    ReviewedBy UNIQUEIDENTIFIER NULL,
    ReviewedAt DATETIME2 NULL,
    ReviewNotes NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_LeaveRequests_Employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON DELETE CASCADE,
    CONSTRAINT FK_LeaveRequests_ReviewedBy FOREIGN KEY (ReviewedBy) REFERENCES Users(UserID) ON DELETE NO ACTION,
    CONSTRAINT CK_LeaveRequests_DateRange CHECK (EndDate >= StartDate),
    CONSTRAINT CK_LeaveRequests_TotalDays CHECK (TotalDays > 0)
);
GO

-- Indexes for better query performance
CREATE INDEX IX_LeaveRequests_Employee ON LeaveRequests(EmployeeID);
CREATE INDEX IX_LeaveRequests_Status ON LeaveRequests(Status);
CREATE INDEX IX_LeaveRequests_StartDate ON LeaveRequests(StartDate);
CREATE INDEX IX_LeaveRequests_EndDate ON LeaveRequests(EndDate);
CREATE INDEX IX_LeaveRequests_CreatedAt ON LeaveRequests(CreatedAt);
GO

-- Trigger to update UpdatedAt timestamp
CREATE OR ALTER TRIGGER TRG_LeaveRequests_UpdatedAt
ON LeaveRequests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE LeaveRequests
    SET UpdatedAt = SYSDATETIME()
    FROM LeaveRequests lr
    INNER JOIN inserted i ON lr.LeaveRequestID = i.LeaveRequestID;
END;
GO
