# Hướng dẫn sử dụng tính năng Thiết lập lương

## Tổng quan

Tính năng thiết lập lương cho phép bạn cấu hình chi tiết lương cho từng nhân viên hoặc nhiều nhân viên cùng lúc, bao gồm:
- **Lương chính**: 3 loại (Lương cứng, Theo giờ, Theo ca)
- **Làm thêm giờ**: Mức lương cho giờ overtime
- **Thưởng**: Tiền thưởng cố định hàng tháng
- **Hoa hồng**: Tỷ lệ % hoa hồng trên doanh số
- **Phụ cấp**: Các khoản phụ cấp (xăng xe, ăn uống, điện thoại...)
- **Giảm trừ**: Các khoản giảm trừ (bảo hiểm, phạt...)

## Bước 1: Chạy Database Migration

Trước khi sử dụng tính năng, bạn cần chạy migration để thêm các cột mới vào bảng `EmployeeCompensation`.

### Cách chạy Migration:

1. Mở **SQL Server Management Studio (SSMS)**
2. Kết nối đến database `LiteFlowDBO`
3. Mở file migration: `database/migration_add_salary_fields.sql`
4. Chạy script này (Execute hoặc F5)
5. Kiểm tra output console để đảm bảo migration thành công

### Kết quả mong đợi:

Sau khi chạy, bảng `EmployeeCompensation` sẽ có thêm 5 cột mới:
- `OvertimeRate` (DECIMAL)
- `BonusAmount` (DECIMAL)
- `CommissionRate` (DECIMAL)
- `AllowanceAmount` (DECIMAL)
- `DeductionAmount` (DECIMAL)

## Bước 2: Build và Deploy ứng dụng

1. Build lại project Maven:
   ```bash
   mvn clean install
   ```

2. Deploy file WAR vào Tomcat server

3. Restart Tomcat server

## Bước 3: Sử dụng tính năng

### Có 2 cách thiết lập lương:

#### **Cách 1: Thiết lập từng nhân viên** (trong trang Danh sách nhân viên)

1. Đăng nhập vào hệ thống LiteFlow
2. Vào menu **Nhân viên** → **Danh sách nhân viên**
3. Click vào một nhân viên trong bảng để xem chi tiết
4. Chuyển sang tab **"Thiết lập lương"**

#### **Cách 2: Thiết lập nhiều nhân viên** (trong trang Thiết lập nhanh)

1. Đăng nhập vào hệ thống LiteFlow
2. Vào menu **Nhân viên** → **Thiết lập nhân viên**
3. Click vào nút **"Thiết lập"** ở mục "Thiết lập lương"
4. Bảng thiết lập lương sẽ hiển thị tất cả nhân viên
5. Click vào dấu **"+"** hoặc **"✎"** để chỉnh sửa từng field

### Cấu hình lương cho nhân viên:

#### 1. Chọn loại lương chính:

**Lương cứng (Fixed):**
- Chọn loại: "Lương cứng"
- Nhập số tiền lương tháng (VD: 3000000 = 3 triệu đồng/tháng)

**Theo giờ (Hybrid):**
- Chọn loại: "Theo giờ"
- Nhập mức lương/giờ (VD: 25000 = 25k/giờ)

**Theo ca (PerShift):**
- Chọn loại: "Theo ca"
- Nhập mức lương/ca (VD: 100000 = 100k/ca)

#### 2. Nhập các thông tin bổ sung (tùy chọn):

- **Làm thêm giờ**: Mức lương cho mỗi giờ làm thêm (VD: 30000)
- **Thưởng**: Tiền thưởng cố định hàng tháng (VD: 1000000)
- **Hoa hồng (%)**: Tỷ lệ % hoa hồng (VD: 5.5 nghĩa là 5.5%)
- **Phụ cấp**: Tổng phụ cấp (VD: 500000)
- **Giảm trừ**: Tổng giảm trừ (VD: 200000)

#### 3. Lưu cấu hình:

- Click nút **"Lưu cấu hình lương"**
- Hệ thống sẽ tự động vô hiệu hóa các cấu hình lương cũ
- Tạo cấu hình lương mới và đánh dấu là active

## Tính năng bảng thiết lập lương (Modal)

Bảng thiết lập lương cho phép xem và chỉnh sửa lương của tất cả nhân viên cùng lúc:

### Giao diện:

- **STT**: Số thứ tự
- **Nhân viên**: Tên và mã nhân viên
- **Lương chính**: Hiển thị loại lương và số tiền
  - Ví dụ: "3,000,000 / tháng - Lương cứng"
  - Ví dụ: "25,000 / giờ - Theo giờ"
  - Ví dụ: "100,000 / ca - Theo ca làm việc"
- **Làm thêm**: Mức lương overtime
- **Thưởng**: Tiền thưởng
- **Hoa hồng**: % hoa hồng
- **Phụ cấp**: Tổng phụ cấp
- **Giảm trừ**: Tổng giảm trừ

### Cách sử dụng:

1. **Thêm giá trị mới**: Click vào nút **"+"**
   - Modal nhỏ sẽ hiện ra
   - Nhập giá trị
   - Click "Lưu"

2. **Chỉnh sửa giá trị**: Hover vào giá trị → Click icon **"✎"**
   - Modal chỉnh sửa hiện ra
   - Thay đổi giá trị
   - Click "Lưu"

3. **Xem tổng số đã thiết lập**: Hiển thị ở đầu trang
   - Ví dụ: "Đã thiết lập lương cho 5/10 nhân viên"

### Lưu ý:

- Để thiết lập **Lương chính** (loại lương), bạn cần vào trang Danh sách nhân viên → Click vào nhân viên → Tab "Thiết lập lương"
- Bảng chỉ cho phép chỉnh sửa các field phụ (Làm thêm, Thưởng, Hoa hồng, Phụ cấp, Giảm trừ)
- Tất cả thay đổi được lưu tự động và cập nhật ngay lập tức

## Cấu trúc Backend

### Files đã được tạo/sửa đổi:

1. **Database Migration:**
   - `database/migration_add_salary_fields.sql`

2. **Model:**
   - `src/main/java/com/liteflow/model/payroll/EmployeeCompensation.java` (đã update)

3. **DAO Layer:**
   - `src/main/java/com/liteflow/dao/payroll/EmployeeCompensationDAO.java` (mới)

4. **Service Layer:**
   - `src/main/java/com/liteflow/service/CompensationService.java` (mới)

5. **Controller:**
   - `src/main/java/com/liteflow/controller/CompensationServlet.java` (mới)

6. **View:**
   - `src/main/webapp/employee/employeeList.jsp` (đã update tab "Thiết lập lương")
   - `src/main/webapp/employee/setupEmployee.jsp` (đã thêm modal bảng thiết lập lương)

### API Endpoints:

**GET `/compensation`**
- `?action=get&employeeCode=EMP001` - Lấy compensation active của nhân viên
- `?action=getAllWithEmployees` - Lấy tất cả nhân viên + compensations (dùng cho modal bảng)
- (không có param) - Lấy tất cả active compensations

**POST `/compensation`**
- `action=save` - Tạo compensation mới
- `action=update` - Cập nhật compensation
- `action=delete` - Xóa compensation

## Ví dụ sử dụng:

### Ví dụ 1: Nhân viên lương cứng
- **Loại lương**: Lương cứng
- **Lương tháng**: 5,000,000 VND
- **Thưởng**: 1,000,000 VND
- **Phụ cấp**: 500,000 VND
- **Giảm trừ**: 200,000 VND (bảo hiểm)

### Ví dụ 2: Nhân viên theo ca
- **Loại lương**: Theo ca
- **Lương/ca**: 150,000 VND
- **Làm thêm**: 40,000 VND/giờ
- **Hoa hồng**: 2.5%

### Ví dụ 3: Nhân viên theo giờ
- **Loại lương**: Theo giờ
- **Lương/giờ**: 30,000 VND
- **Làm thêm**: 45,000 VND/giờ
- **Phụ cấp**: 300,000 VND

## Lưu ý:

1. **Validation**: Frontend sẽ kiểm tra loại lương phải được chọn trước khi lưu
2. **History**: Mỗi lần lưu cấu hình mới, hệ thống sẽ vô hiệu hóa cấu hình cũ (isActive = false) để giữ lại lịch sử
3. **Currency**: Tất cả số tiền đều tính theo VND
4. **Active Status**: Chỉ có 1 cấu hình lương active cho mỗi nhân viên tại một thời điểm

## Troubleshooting:

### Lỗi: "Không thể lưu cấu hình lương"
- Kiểm tra đã chọn loại lương chưa
- Kiểm tra database connection
- Xem console log để biết chi tiết lỗi

### Lỗi: "No active compensation found"
- Nhân viên chưa có cấu hình lương nào
- Tạo cấu hình mới bằng cách điền form và click "Lưu"

### Migration thất bại:
- Kiểm tra đã kết nối đúng database chưa
- Kiểm tra user có quyền ALTER TABLE không
- Xem output console để biết lỗi cụ thể

## Liên hệ hỗ trợ:

Nếu gặp vấn đề, vui lòng liên hệ team phát triển với thông tin chi tiết về lỗi.
