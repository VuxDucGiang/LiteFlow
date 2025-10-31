# Leave Request Feature Implementation

## Overview
This document describes the implementation of the Leave Request feature for the Employee Dashboard.

## Files Created

### 1. Database Schema
**File:** `database/leave_request_schema.sql`
- Created `LeaveRequests` table with the following structure:
  - LeaveRequestID (UNIQUEIDENTIFIER, Primary Key)
  - EmployeeID (Foreign Key to Employees)
  - LeaveType (Nghỉ phép, Nghỉ bệnh, Nghỉ không lương, Nghỉ khác)
  - StartDate, EndDate (DATE)
  - TotalDays (DECIMAL)
  - Reason (NVARCHAR)
  - Status (Chờ duyệt, Đã duyệt, Từ chối, Đã hủy)
  - ReviewedBy (Foreign Key to Users)
  - ReviewedAt, ReviewNotes
  - CreatedAt, UpdatedAt timestamps
- Added indexes for better query performance
- Created trigger to auto-update UpdatedAt timestamp

### 2. Model Class
**File:** `src/main/java/com/liteflow/model/timesheet/LeaveRequest.java`
- JPA Entity class mapped to LeaveRequests table
- Includes helper methods: isPending(), isApproved(), isRejected(), isCancelled(), isPaidLeave()
- PrePersist and PreUpdate lifecycle callbacks

### 3. DAO Layer
**File:** `src/main/java/com/liteflow/dao/timesheet/LeaveRequestDAO.java`
- Extends GenericDAO for CRUD operations
- Custom query methods:
  - `findByEmployeeId()` - Get all leave requests for an employee
  - `findByEmployeeAndDateRange()` - Get requests in date range
  - `findByEmployeeAndStatus()` - Get requests by status
  - `findPendingRequests()` - Get all pending requests (for managers)
  - `hasOverlappingLeave()` - Check for overlapping leave requests
  - `countApprovedLeaveDays()` - Count approved leave days in a period

### 4. Service Layer
**File:** `src/main/java/com/liteflow/service/LeaveRequestService.java`
- Business logic for leave request management
- Key methods:
  - `createLeaveRequest()` - Validates and creates new leave request
  - `updateLeaveRequest()` - Updates existing leave request
  - `cancelLeaveRequest()` - Employee cancels their own request
  - `approveLeaveRequest()` - Manager approves request
  - `rejectLeaveRequest()` - Manager rejects request
  - `isOwner()` - Check ownership of request
- Auto-calculates total days between start and end dates
- Validates date ranges and checks for overlapping leave requests

### 5. Controller/API Layer
**File:** `src/main/java/com/liteflow/controller/LeaveRequestServlet.java`
- RESTful API endpoints:
  - `GET /api/leave-request/` - Get all leave requests for logged-in employee
  - `GET /api/leave-request/?status={status}` - Filter by status
  - `GET /api/leave-request/{id}` - Get specific leave request
  - `POST /api/leave-request/` - Create new leave request
  - `PUT /api/leave-request/{id}` - Update leave request
  - `PUT /api/leave-request/{id}/cancel` - Cancel leave request
  - `DELETE /api/leave-request/{id}` - Delete leave request
- Includes authentication and authorization checks
- Returns JSON responses

### 6. Frontend UI
**Files Modified:**
- `src/main/webapp/dashboard-employee.jsp`
- `src/main/webapp/css/dashboard-employee.css`

**Changes:**
- Added "Xin nghỉ phép" button click handler
- Created leave request modal with:
  - Leave type selection (Nghỉ phép, Nghỉ bệnh, Nghỉ không lương, Nghỉ khác)
  - Start date and end date pickers
  - Reason textarea
  - Informational note about approval process
- JavaScript functions:
  - `openLeaveRequestModal()` - Opens the modal and resets form
  - `closeLeaveRequestModal()` - Closes the modal
  - `saveLeaveRequest()` - Submits the leave request via API
- Added CSS styling for form-note info boxes

## Features

### For Employees:
1. **Submit Leave Request** - Fill out form with leave type, dates, and reason
2. **View Leave Requests** - See all submitted requests and their status
3. **Cancel Pending Requests** - Cancel requests that haven't been reviewed yet
4. **Edit Pending Requests** - Modify requests that are still pending approval

### Validation:
- End date must be after or equal to start date
- Cannot submit overlapping leave requests
- Only pending requests can be edited or cancelled
- Automatic calculation of total leave days

### For Managers (API endpoints available):
- Approve or reject leave requests
- View all pending leave requests
- Add review notes when approving/rejecting

## API Request/Response Examples

### Create Leave Request
```javascript
POST /api/leave-request/
Body:
  leaveType=Nghỉ phép
  startDate=2025-11-01
  endDate=2025-11-03
  reason=Du lịch gia đình

Response:
{
  "leaveRequestId": "...",
  "leaveType": "Nghỉ phép",
  "startDate": "2025-11-01",
  "endDate": "2025-11-03",
  "totalDays": 3,
  "reason": "Du lịch gia đình",
  "status": "Chờ duyệt",
  "createdAt": "2025-10-30T10:30:00"
}
```

### Get Leave Requests
```javascript
GET /api/leave-request/

Response: [array of leave requests]
```

### Cancel Leave Request
```javascript
PUT /api/leave-request/{id}/cancel

Response:
{
  "success": true,
  "message": "Đã hủy đơn xin nghỉ"
}
```

## Setup Instructions

1. **Run Database Migration:**
   ```sql
   -- Execute the SQL script
   USE LiteFlowDBO;
   GO
   -- Run: database/leave_request_schema.sql
   ```

2. **Build and Deploy:**
   - Rebuild the Java project to compile new classes
   - Deploy to your application server

3. **Test the Feature:**
   - Login as an employee
   - Navigate to dashboard-employee page
   - Click "Xin nghỉ phép" button
   - Fill out and submit the form
   - Check the database for the new record

## Database Relationship
```
Users (UserID)
  └─> Employees (EmployeeID)
        └─> LeaveRequests (EmployeeID)
              └─> ReviewedBy (UserID) - References Users
```

## Status Flow
```
Chờ duyệt (Pending)
  ├─> Đã duyệt (Approved) - by Manager
  ├─> Từ chối (Rejected) - by Manager
  └─> Đã hủy (Cancelled) - by Employee
```

## Future Enhancements (Optional)
1. Add a "Leave Requests" list widget to the dashboard to show recent requests
2. Implement real-time notifications when a request is approved/rejected
3. Add leave balance tracking (total annual leave days vs. used days)
4. Create a manager view page for reviewing leave requests
5. Add email notifications for new requests and status changes
6. Implement recurring leave patterns (e.g., every Friday)
7. Add attachments support (e.g., medical certificates for sick leave)
8. Generate leave reports and statistics

## Notes
- The leave request system integrates with the existing Employee and User management system
- All dates are stored in the database using SQL Server DATE type
- The API uses session-based authentication (UserLogin session attribute)
- The system checks for overlapping leave requests to prevent conflicts
- Leave types can be easily extended by modifying the database constraint and UI dropdown
