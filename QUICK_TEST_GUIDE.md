# Hướng dẫn Test nhanh Tính năng Thiết lập Lương

## Kiểm tra Modal hiển thị

### Bước 1: Mở trang

Truy cập: `http://localhost:8080/LiteFlow/employee/setup`

### Bước 2: Mở Modal

Click vào nút **"Thiết lập"** ở mục "Thiết lập lương"

### Bước 3: Quan sát

Bạn sẽ thấy:
- Modal hiển thị với title "Thiết lập lương"
- Banner màu vàng ở trên cùng (Debug Mode)
- Bảng với các cột: STT, Nhân viên, Lương chính, Làm thêm, Thưởng, Hoa hồng, Phụ cấp, Giảm trừ
- Một trong các trạng thái sau:
  - "Đang tải dữ liệu..." (loading)
  - Danh sách nhân viên với các nút "+"
  - Thông báo lỗi (màu đỏ)

## Test với dữ liệu mẫu (nếu API không hoạt động)

Nếu bạn thấy lỗi hoặc không có dữ liệu:

1. Click nút **"Test với dữ liệu mẫu"** trong banner màu vàng
2. Bảng sẽ hiển thị 5 nhân viên mẫu:
   - EMP001: Nguyễn Văn A (đã có lương)
   - EMP002: Trần Thị B (đã có lương)
   - EMP003: Lê Văn C (chưa có lương)
   - EMP004: Phạm Thị D (chưa có lương)
   - EMP005: Hoàng Văn E (chưa có lương)

## Kiểm tra Console (F12)

Mở Developer Console (F12) để xem logs:

### Logs mong đợi khi thành công:
```
=== openSalaryModal called ===
=== loadSalaryData called ===
Fetching from: /LiteFlow/compensation?action=getAllWithEmployees
Response status: 200
Response ok: true
Raw response: {"employees":[...],"compensations":[...]}
Parsed data: {employees: Array(10), compensations: Array(5)}
✓ Employees loaded: 10
✓ Compensations loaded: 5
=== renderSalaryTable called ===
Rendering 10 employees
✓ Table rendered with 10 rows
```

### Logs khi có lỗi:
```
=== openSalaryModal called ===
=== loadSalaryData called ===
Fetching from: /LiteFlow/compensation?action=getAllWithEmployees
Response status: 404 (hoặc 500)
❌ Error loading salary data: HTTP 404: Not Found
```

## Các trường hợp lỗi phổ biến

### Lỗi 1: "HTTP 404: Not Found"

**Nguyên nhân**: CompensationServlet chưa được deploy

**Giải pháp**:
```bash
cd e:\FPT_University\FALL2025\SWP391\LiteFlow-master
mvn clean package
```
Sau đó deploy file WAR và restart Tomcat

### Lỗi 2: "Fetched 0 employees"

**Nguyên nhân**: Database không có dữ liệu employees

**Giải pháp**:
1. Kiểm tra database connection
2. Chạy query: `SELECT * FROM Employee`
3. Đảm bảo có ít nhất 1 employee trong database

### Lỗi 3: Modal không hiển thị

**Nguyên nhân**: JavaScript error hoặc CSS issue

**Giải pháp**:
1. Mở Console (F12) → tab Console để xem error
2. Kiểm tra tab Elements để xem `#salaryModal` có display: flex không
3. Kiểm tra tab Network để xem file JSP có load thành công không

### Lỗi 4: "Không thể parse JSON response"

**Nguyên nhân**: Server trả về HTML thay vì JSON (thường do error page)

**Giải pháp**:
1. Xem raw response trong console
2. Kiểm tra Tomcat logs (`catalina.out`)
3. Có thể có exception trong servlet

## Test UI với dữ liệu mẫu

1. Click "Test với dữ liệu mẫu"
2. Bảng sẽ hiển thị 5 nhân viên
3. Thử các thao tác:

### Test thêm/sửa field:
- **Nhân viên EMP003**: Tất cả field đều có nút "+" → Click "+" để thêm
- **Nhân viên EMP001**: Hover vào giá trị → Icon "✎" hiện ra → Click để edit

### Test Modal edit:
1. Click vào nút "+" hoặc "✎"
2. Modal nhỏ hiện ra
3. Nhập giá trị mới
4. Click "Lưu"
5. (Lưu ý: Trong test mode, API sẽ fail vì không có backend)

## Kiểm tra từng phần

### 1. Kiểm tra Modal mở/đóng
- Click "Thiết lập" → Modal mở
- Click nút "✕" → Modal đóng
- Click nút "Xong" → Modal đóng

### 2. Kiểm tra Bảng render
- Bảng có header đúng 8 cột
- Mỗi row có đủ 8 cell
- Cell "STT" có số thứ tự
- Cell "Nhân viên" có tên và mã nhân viên

### 3. Kiểm tra nút "+"
- Nếu chưa có giá trị → Hiển thị nút "+"
- Click nút "+" → Modal edit mở ra

### 4. Kiểm tra icon "✎"
- Nếu đã có giá trị → Hover vào → Icon "✎" hiện ra
- Click icon "✎" → Modal edit mở ra

## Debug Info

Banner Debug Mode hiển thị:
- **Đang tải dữ liệu từ server...** → API đang fetch
- **✓ Đã tải: X nhân viên, Y cấu hình lương** → Thành công (màu xanh)
- **⚠ Không có nhân viên trong database** → Database rỗng (màu cam)
- **✗ Lỗi: [error message]** → API lỗi (màu đỏ)
- **✓ Test Mode: 5 nhân viên mẫu, 2 cấu hình mẫu** → Test mode (màu xanh dương)

## Nếu vẫn không hoạt động

1. **Kiểm tra URL**: Đảm bảo đang truy cập đúng `/employee/setup`
2. **Kiểm tra Browser**: Thử trên Chrome hoặc Edge
3. **Clear Cache**: Xóa cache và reload (Ctrl+Shift+R hoặc Ctrl+F5)
4. **Kiểm tra Tomcat**: Đảm bảo server đang chạy
5. **Kiểm tra logs**: Xem Tomcat logs trong `catalogs/catalina.out`

## Tóm tắt Checklist

- [ ] Modal mở được khi click "Thiết lập"
- [ ] Banner Debug Mode hiển thị
- [ ] Bảng có 8 cột đúng tên
- [ ] Console có logs (F12 → Console tab)
- [ ] Nút "Test với dữ liệu mẫu" hoạt động
- [ ] Bảng hiển thị 5 nhân viên khi test
- [ ] Nút "+" hiển thị cho field chưa có giá trị
- [ ] Icon "✎" hiển thị khi hover vào giá trị đã có
- [ ] Modal edit mở được khi click "+" hoặc "✎"
- [ ] Modal edit có thể đóng bằng nút "✕" hoặc "Hủy"

## Liên hệ

Nếu vẫn gặp vấn đề, cung cấp:
1. Screenshot của modal
2. Console logs (F12)
3. Network tab (F12 → Network)
4. Tomcat logs (catalina.out)
