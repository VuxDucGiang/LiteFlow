# 📅 Seed Data - Lịch Cá Nhân (Personal Schedules)

## 📝 Mô tả

Đã tạo seed data mẫu cho **3 lịch cá nhân** của nhân viên **Đỗ Thị F** (EMP006 - Barista).

## 🎯 Dữ liệu đã seed

### 1️⃣ **Học kỹ năng pha chế nâng cao**
- **Thời gian**: 3 ngày sau, 09:00 - 12:00
- **Ưu tiên**: `High` (Cao)
- **Trạng thái**: `Pending` (Chưa làm)
- **Nhắc nhở**: 12 giờ trước khi bắt đầu
- **Mô tả**: Tham gia khóa học pha chế cà phê chuyên nghiệp (Latte Art, Pour Over, Cold Brew, Espresso)
- **Ghi chú**: Cần chuẩn bị sổ tay, dụng cụ. Địa chỉ: 123 Nguyễn Huệ, Q.1

### 2️⃣ **Kiểm tra và bổ sung kho nguyên liệu**
- **Thời gian**: Hôm nay, 14:00 - 16:00
- **Ưu tiên**: `Medium` (Trung bình)
- **Trạng thái**: `InProgress` (Đang làm)
- **Mô tả**: Rà soát toàn bộ nguyên liệu pha chế, lập danh sách đặt hàng
- **Ghi chú**: Đã kiểm tra: cà phê ✓, sữa ✓. Cần kiểm tra: syrup, trà, topping

### 3️⃣ **Họp team pha chế tháng này**
- **Thời gian**: 5 ngày trước (đã qua), 17:00 - 18:30
- **Ưu tiên**: `Low` (Thấp)
- **Trạng thái**: `Completed` (Đã hoàn thành)
- **Mô tả**: Tổng kết tháng trước, đề xuất cải tiến, thảo luận menu mới
- **Ghi chú**: ✓ Đã hoàn thành. Thống nhất thêm 3 món mới, 8/10 nhân viên tham gia

---

## 🚀 Cách sử dụng

### **Bước 1: Chạy script seed data**

Trong **SQL Server Management Studio (SSMS)**:

```sql
-- Chạy file này để tạo dữ liệu mẫu
USE LiteFlowDBO;
GO

-- File: database/liteflow_data.sql (đã có sẵn phần PersonalSchedules ở cuối)
```

Hoặc nếu chỉ muốn tạo lịch cá nhân (database đã có sẵn):

```sql
USE LiteFlowDBO;
GO

-- Lấy EmployeeID của Đỗ Thị F
DECLARE @EmpDTF UNIQUEIDENTIFIER;
SELECT @EmpDTF = EmployeeID FROM Employees WHERE EmployeeCode = 'EMP006';

-- Copy 3 INSERT statements từ liteflow_data.sql (line 1473-1544)
```

### **Bước 2: Kiểm tra dữ liệu**

Chạy script kiểm tra:

```bash
# File: database/check_personal_schedules.sql
```

Kết quả mong đợi:

```
=== KIỂM TRA LỊCH CÁ NHÂN ===

✓ Tìm thấy nhân viên:
  Mã NV: EMP006
  Họ tên: Đỗ Thị F

=== KẾT QUẢ KIỂM TRA ===
Số lịch cá nhân: 3

=== CHI TIẾT LỊCH CÁ NHÂN ===
----------------------------------------------------------------------
STT  Tiêu đề                              Ngày        Giờ    Ưu tiên  Trạng thái
---  -----------------------------------  ----------  -----  -------  -----------
1    Học kỹ năng pha chế nâng cao         [+3 ngày]   09:00  High     Pending
2    Kiểm tra và bổ sung kho nguyên liệu  [hôm nay]   14:00  Medium   InProgress
3    Họp team pha chế tháng này           [-5 ngày]   17:00  Low      Completed

=== THỐNG KÊ THEO TRẠNG THÁI ===
Trạng thái    Số lượng  Ưu tiên
------------  --------  -------
Pending       1         High
InProgress    1         Medium
Completed     1         Low

✅ Dữ liệu mẫu đã được seed thành công!
```

### **Bước 3: Xem trên ứng dụng**

1. Đăng nhập với tài khoản **Đỗ Thị F**:
   - Email: `giangducx2312@gmail.com`
   - Password: `1` (hoặc password mặc định trong data seed)

2. Truy cập trang **Dashboard Employee** hoặc **Lịch cá nhân**

3. Bạn sẽ thấy 3 lịch đã tạo:
   - ⏰ **Học kỹ năng pha chế** (Sắp tới, Priority cao)
   - 🔄 **Kiểm tra kho** (Đang làm)
   - ✅ **Họp team** (Đã hoàn thành)

---

## 📊 Schema Reference

```sql
CREATE TABLE PersonalSchedules (
    ScheduleID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    EmployeeID UNIQUEIDENTIFIER NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    StartDate DATE NOT NULL,
    StartTime TIME NULL,
    EndTime TIME NULL,
    Priority NVARCHAR(20) NOT NULL DEFAULT 'Medium' 
        CHECK (Priority IN ('Low', 'Medium', 'High')),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending' 
        CHECK (Status IN ('Pending', 'InProgress', 'Completed', 'Cancelled')),
    ReminderDate DATETIME2 NULL,
    ReminderSent BIT NOT NULL DEFAULT 0,
    Notes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
```

### **Các giá trị hợp lệ:**

**Priority (Ưu tiên):**
- `Low` - Thấp
- `Medium` - Trung bình (mặc định)
- `High` - Cao

**Status (Trạng thái):**
- `Pending` - Chờ làm (mặc định)
- `InProgress` - Đang làm
- `Completed` - Đã hoàn thành
- `Cancelled` - Đã hủy

---

## 🎨 Ứng dụng thực tế

Bạn có thể mở rộng seed data cho các nhân viên khác:

```sql
-- Ví dụ: Thêm lịch cho Nguyễn Văn A (EMP001)
DECLARE @EmpOwner UNIQUEIDENTIFIER;
SELECT @EmpOwner = EmployeeID FROM Employees WHERE EmployeeCode = 'EMP001';

INSERT INTO PersonalSchedules (
    EmployeeID, Title, Description, StartDate, StartTime, EndTime, 
    Priority, Status, Notes
)
VALUES (
    @EmpOwner,
    N'Họp quản lý cấp cao',
    N'Họp ban lãnh đạo để xem xét kế hoạch kinh doanh quý 4',
    DATEADD(DAY, 7, CAST(SYSDATETIME() AS DATE)),
    '09:00', '11:00',
    'High', 'Pending',
    N'Chuẩn bị: báo cáo doanh thu, kế hoạch marketing'
);
```

---

## 🧪 Test Cases

### **Test 1: Query lịch sắp tới**
```sql
SELECT Title, StartDate, Priority, Status
FROM PersonalSchedules ps
JOIN Employees e ON ps.EmployeeID = e.EmployeeID
WHERE e.EmployeeCode = 'EMP006'
  AND ps.Status IN ('Pending', 'InProgress')
  AND ps.StartDate >= CAST(SYSDATETIME() AS DATE)
ORDER BY ps.StartDate, ps.StartTime;
```

**Kết quả:** 2 lịch (Kiểm tra kho, Học pha chế)

### **Test 2: Query lịch cần nhắc nhở**
```sql
SELECT Title, ReminderDate
FROM PersonalSchedules ps
JOIN Employees e ON ps.EmployeeID = e.EmployeeID
WHERE e.EmployeeCode = 'EMP006'
  AND ps.ReminderDate IS NOT NULL
  AND ps.ReminderSent = 0
  AND ps.ReminderDate <= SYSDATETIME();
```

**Kết quả:** 0-1 lịch (tùy thời điểm chạy)

### **Test 3: Thống kê theo ưu tiên**
```sql
SELECT 
    Priority, 
    COUNT(*) AS Total,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS Completed
FROM PersonalSchedules ps
JOIN Employees e ON ps.EmployeeID = e.EmployeeID
WHERE e.EmployeeCode = 'EMP006'
GROUP BY Priority;
```

**Kết quả:**
```
Priority  Total  Completed
--------  -----  ---------
High      1      0
Medium    1      0
Low       1      1
```

---

## 🔧 Troubleshooting

### **Lỗi: Không tìm thấy nhân viên EMP006**

```sql
-- Kiểm tra xem nhân viên có tồn tại không
SELECT * FROM Employees WHERE EmployeeCode = 'EMP006';

-- Nếu không có, chạy lại script seed:
-- database/liteflow_data.sql (line 532-555)
```

### **Lỗi: Foreign key constraint**

```sql
-- Kiểm tra bảng Employees đã có dữ liệu chưa
SELECT COUNT(*) FROM Employees;

-- Nếu = 0, chạy đầy đủ script:
-- 1. database/liteflow_schema.sql
-- 2. database/liteflow_data.sql
```

### **Lỗi: Duplicate data**

```sql
-- Xóa dữ liệu cũ trước khi chạy lại
DELETE FROM PersonalSchedules 
WHERE EmployeeID IN (
    SELECT EmployeeID FROM Employees WHERE EmployeeCode = 'EMP006'
);
```

---

## 📚 Tài liệu liên quan

- `database/liteflow_schema.sql` - Schema definition
- `database/liteflow_data.sql` - Full seed data
- `database/check_personal_schedules.sql` - Verification script

---

## ✅ Checklist

Sau khi seed data xong:

- [ ] Chạy `check_personal_schedules.sql` - Thấy 3 lịch
- [ ] Đăng nhập với tài khoản Đỗ Thị F
- [ ] Xem lịch cá nhân trên UI
- [ ] Test filter theo Status, Priority
- [ ] Test tính năng reminder (nếu có)
- [ ] Test update/delete lịch

---

**🎉 Hoàn tất!** Database đã có dữ liệu lịch cá nhân mẫu cho nhân viên Đỗ Thị F.

