# Hướng dẫn Build và Test Compensation API

## Vấn đề hiện tại

Khi nhấn vào "Thiết lập lương" trong trang setupEmployee.jsp, modal không hiển thị danh sách nhân viên.

## Nguyên nhân

Các servlet mới (SetupEmployeeServlet, CompensationServlet) chưa được compile và deploy.

## Giải pháp

### Bước 1: Build lại project

Mở Command Prompt hoặc Terminal và chạy:

```bash
cd e:\FPT_University\FALL2025\SWP391\LiteFlow-master
mvn clean package
```

Hoặc nếu dùng IDE:
- **IntelliJ IDEA**: Click vào Maven panel → Lifecycle → clean → package
- **Eclipse**: Right-click project → Run As → Maven build → Goals: clean package

### Bước 2: Deploy file WAR

Sau khi build thành công, file WAR sẽ được tạo tại:
```
target/LiteFlow-1.0-SNAPSHOT.war
```

**Cách deploy:**

#### Cách 1: Deploy thủ công
1. Dừng Tomcat server
2. Xóa folder cũ trong `webapps/` (ví dụ: `webapps/LiteFlow/`)
3. Copy file WAR vào `tomcat/webapps/`
4. Khởi động lại Tomcat

#### Cách 2: Deploy qua Tomcat Manager
1. Truy cập: `http://localhost:8080/manager/html`
2. Scroll xuống "WAR file to deploy"
3. Chọn file WAR và click "Deploy"

### Bước 3: Kiểm tra Tomcat logs

Khi server khởi động, kiểm tra logs để đảm bảo servlet được load:

**File log**: `tomcat/logs/catalina.out` hoặc `tomcat/logs/catalina.[date].log`

Tìm dòng:
```
INFO: Deploying web application
INFO: Deployment of web application ... has finished
```

### Bước 4: Test API trực tiếp

Sau khi deploy xong, test API bằng file test đã tạo:

1. Truy cập: `http://localhost:8080/LiteFlow/test-compensation-api.html`
2. Click nút "Run Test" để kiểm tra API
3. Kiểm tra console (F12) để xem logs chi tiết

**Kết quả mong đợi:**
- Status: 200 OK
- Response chứa `employees` array và `compensations` array

### Bước 5: Test trên setupEmployee.jsp

1. Truy cập: `http://localhost:8080/LiteFlow/employee/setup`
2. Click vào nút "Thiết lập" ở mục "Thiết lập lương"
3. Modal sẽ hiển thị bảng với danh sách tất cả nhân viên
4. Mở browser console (F12) để xem logs

**Console logs mong đợi:**
```
Received data: {employees: [...], compensations: [...]}
Employees: 10
Compensations: 5
```

## Troubleshooting

### Lỗi 1: 404 Not Found - /compensation

**Nguyên nhân**: Servlet chưa được deploy

**Giải pháp**:
1. Kiểm tra file `CompensationServlet.java` có annotation `@WebServlet(urlPatterns = {"/compensation"})`
2. Build lại project với `mvn clean package`
3. Deploy lại file WAR
4. Restart Tomcat

### Lỗi 2: Console log "Network response was not ok: 500"

**Nguyên nhân**: Lỗi server-side (database, service, etc.)

**Giải pháp**:
1. Kiểm tra Tomcat logs tại `tomcat/logs/catalina.out`
2. Tìm stack trace để xác định lỗi
3. Kiểm tra database connection
4. Đảm bảo migration đã được chạy (xem `SALARY_SETUP_GUIDE.md`)

### Lỗi 3: "Fetched 0 employees"

**Nguyên nhân**: Database không có dữ liệu hoặc EmployeeService có lỗi

**Giải pháp**:
1. Kiểm tra database có employees không
2. Test query: `SELECT * FROM Employee`
3. Kiểm tra connection string trong `persistence.xml`

### Lỗi 4: CORS error

**Nguyên nhân**: Nếu test từ domain khác

**Giải pháp**:
- Test từ cùng domain (localhost:8080)
- Hoặc thêm CORS headers trong servlet

## Kiểm tra logs

### Server-side logs (Tomcat):

Trong `catalina.out`, bạn sẽ thấy:
```
CompensationServlet doGet - action: getAllWithEmployees
=== handleGetAllWithEmployees called ===
Fetched 10 employees
Fetched 5 compensations
```

### Client-side logs (Browser Console):

Trong browser console (F12), bạn sẽ thấy:
```
Received data: {employees: [...], compensations: [...]}
Employees: 10
Compensations: 5
```

## Cấu trúc project sau khi build

```
LiteFlow-master/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/liteflow/controller/
│       │       ├── CompensationServlet.java  ← Mới
│       │       └── SetupEmployeeServlet.java ← Mới
│       └── webapp/
│           ├── employee/
│           │   ├── employeeList.jsp
│           │   └── setupEmployee.jsp  ← Đã update
│           ├── includes/
│           │   └── header.jsp  ← Đã update
│           └── test-compensation-api.html  ← Test file
├── target/
│   └── LiteFlow-1.0-SNAPSHOT.war  ← File deploy
└── pom.xml
```

## Liên hệ

Nếu vẫn gặp lỗi, hãy cung cấp:
1. Tomcat logs (catalina.out)
2. Browser console logs (F12)
3. Screenshot của lỗi
4. Kết quả test từ `test-compensation-api.html`
