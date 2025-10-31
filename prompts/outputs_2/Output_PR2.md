## PR2 — MA TRẬN TEST CASE TÍCH HỢP HỆ THỐNG LITEFLOW

### TỔNG QUAN
**Mục tiêu:** Đảm bảo coverage tích hợp ≥70% trên toàn hệ thống LiteFlow (Servlet ↔ Service ↔ DAO ↔ DB)  
**Phạm vi:** Tất cả module nghiệp vụ chính với các điểm tích hợp quan trọng  
**Tổng số test case:** 85 test cases (36 Happy Path + 24 Edge Cases + 25 Error Scenarios)

---

## 📊 TEST CASE MATRIX - INTEGRATION TESTS

---

### ✅ HAPPY PATH SCENARIOS (36 test cases)

#### **Module 1: Authentication & RBAC (6 test cases)**

**TC-HP-001: Đăng nhập thành công với email/password**
- **Description:** Kiểm tra tích hợp AuthenticationFilter → AuthService → UserDAO → DB → SessionDAO
- **Input Data:**
  ```json
  {
    "email": "admin@liteflow.com",
    "password": "Admin@123",
    "rememberMe": false
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Session cookie được tạo
  - JWT token trong response
  - Redirect đến dashboard phù hợp role
  - DB: ghi nhật ký UserSessions với status=ACTIVE
- **Mock Behavior:** None (real DB)

**TC-HP-002: Đăng nhập với Google OAuth2**
- **Description:** Kiểm tra tích hợp OAuth2 flow → AuthService → UserDAO (tạo/cập nhật user)
- **Input Data:**
  ```json
  {
    "googleToken": "valid_google_jwt_token",
    "googleId": "108234567890",
    "email": "user@gmail.com",
    "displayName": "John Doe"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - User được tạo mới hoặc cập nhật GoogleID
  - Session được tạo
  - JWT token trả về
  - DB: Users table có record mới/cập nhật
- **Mock Behavior:** Mock Google OAuth verification API

**TC-HP-003: Xác thực 2FA (TOTP) thành công**
- **Description:** Kiểm tra tích hợp 2FA flow → AuthService → UserDAO (verify TOTP secret)
- **Input Data:**
  ```json
  {
    "userId": "user-uuid-001",
    "totpCode": "123456",
    "sessionToken": "temp_session_token"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Session được nâng cấp thành FULLY_AUTHENTICATED
  - Last2FAVerifiedAt được cập nhật
  - Redirect đến dashboard
- **Mock Behavior:** Mock TOTP generator với time-based code cố định

**TC-HP-004: Phân quyền RBAC - Admin tạo user mới**
- **Description:** Kiểm tra tích hợp AuthorizationFilter → EmployeeService → UserDAO + RoleDAO + UserRoleDAO
- **Input Data:**
  ```json
  {
    "email": "newemployee@liteflow.com",
    "displayName": "New Employee",
    "phone": "+84901234567",
    "roles": ["EMPLOYEE"],
    "createdBy": "admin-uuid-001"
  }
  ```
- **Expected Output:**
  - HTTP 201 Created
  - User mới trong DB với PasswordHash (random generated)
  - UserRoles được gán
  - Email thông báo gửi đến nhân viên mới
- **Mock Behavior:** Mock EmailService

**TC-HP-005: Phân quyền RBAC - Cashier truy cập POS (authorized)**
- **Description:** Kiểm tra AuthorizationFilter cho phép Cashier vào /cart/*
- **Input Data:**
  - Session: user có role CASHIER
  - Request: GET /cart/cashier.jsp
- **Expected Output:**
  - HTTP 200 OK
  - Trang POS hiển thị
  - Filter log ghi "Access granted"
- **Mock Behavior:** None

**TC-HP-006: Logout và invalidate session**
- **Description:** Kiểm tra tích hợp LogoutServlet → SessionService → UserSessionDAO
- **Input Data:**
  - Session cookie: valid_session_id
  - Request: POST /auth/logout
- **Expected Output:**
  - HTTP 302 Redirect to /auth/login.jsp
  - Session cookie bị xóa
  - DB: UserSessions.Status = LOGGED_OUT, LoggedOutAt = timestamp
- **Mock Behavior:** None

---

#### **Module 2: Cashier/POS Order Management (10 test cases)**

**TC-HP-007: Tạo đơn hàng mới thành công**
- **Description:** Kiểm tra tích hợp CreateOrderServlet → OrderService → OrderDAO + OrderItemDAO + InventoryService
- **Input Data:**
  ```json
  {
    "tableId": "table-uuid-001",
    "roomId": "room-uuid-001",
    "items": [
      {"productId": "prod-001", "quantity": 2, "unitPrice": 50000, "note": "No sugar"},
      {"productId": "prod-002", "quantity": 1, "unitPrice": 75000}
    ],
    "cashierId": "cashier-uuid-001",
    "orderType": "DINE_IN"
  }
  ```
- **Expected Output:**
  - HTTP 201 Created
  - Response: `{"orderId": "order-uuid-xxx", "totalAmount": 175000, "status": "PENDING"}`
  - DB: Orders table có record mới với Status=PENDING
  - DB: OrderItems có 2 records
  - DB: Inventory stock giảm tương ứng (nếu có tracking)
  - DB: Table.Status = OCCUPIED
- **Mock Behavior:** None (real DB transaction)

**TC-HP-008: Áp dụng khuyến mãi cho đơn hàng**
- **Description:** Kiểm tra tích hợp PromotionService → OrderService → PricingService
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-001",
    "promotionCode": "SUMMER2025",
    "orderTotal": 175000
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"discountAmount": 35000, "finalAmount": 140000, "promotionApplied": true}`
  - DB: Orders.DiscountAmount = 35000, FinalAmount = 140000
  - DB: PromotionUsages có record mới
- **Mock Behavior:** None

**TC-HP-009: Thanh toán đơn hàng (Cash)**
- **Description:** Kiểm tra tích hợp PaymentServlet → PaymentService → OrderService → ReceiptService
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-001",
    "paymentMethod": "CASH",
    "amountPaid": 200000,
    "cashierId": "cashier-uuid-001"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"paymentId": "payment-uuid-xxx", "change": 60000, "receiptId": "receipt-001"}`
  - DB: Payments table có record, Status=COMPLETED
  - DB: Orders.Status = PAID, PaidAt = timestamp
  - DB: Receipts table có record với details
- **Mock Behavior:** None

**TC-HP-010: Thanh toán đơn hàng (Credit Card)**
- **Description:** Kiểm tra tích hợp PaymentService → External Payment Gateway → OrderService
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-002",
    "paymentMethod": "CREDIT_CARD",
    "cardToken": "tok_visa_1234",
    "amount": 340000
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"paymentId": "payment-uuid-xxx", "transactionId": "txn_ext_123", "status": "COMPLETED"}`
  - DB: Payments với ExternalTransactionId
  - DB: Orders.Status = PAID
- **Mock Behavior:** Mock PaymentGatewayService trả về success response

**TC-HP-011: In hóa đơn sau thanh toán**
- **Description:** Kiểm tra tích hợp ReceiptServlet → ReceiptService → OrderDAO + PaymentDAO
- **Input Data:**
  - Request: GET /receipt/print?orderId=order-uuid-001
- **Expected Output:**
  - HTTP 200 OK
  - Content-Type: application/pdf hoặc text/html
  - Response body chứa thông tin đầy đủ: items, prices, payment, timestamp
  - DB: Receipts.PrintedCount += 1
- **Mock Behavior:** None

**TC-HP-012: Cập nhật trạng thái đơn hàng (PENDING → PREPARING)**
- **Description:** Kiểm tra tích hợp KitchenServlet → OrderService → NotificationService
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-001",
    "newStatus": "PREPARING",
    "kitchenStaffId": "staff-uuid-001"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - DB: Orders.Status = PREPARING, UpdatedBy = staff-uuid-001
  - Notification gửi đến cashier (via WebSocket hoặc polling)
- **Mock Behavior:** Mock NotificationService

**TC-HP-013: Cập nhật trạng thái đơn hàng (PREPARING → READY → SERVED)**
- **Description:** Kiểm tra workflow hoàn chỉnh của đơn hàng trong bếp
- **Input Data:**
  - Step 1: `{"orderId": "xxx", "status": "READY"}`
  - Step 2: `{"orderId": "xxx", "status": "SERVED"}`
- **Expected Output:**
  - HTTP 200 OK cho cả 2 requests
  - DB: Orders.Status thay đổi theo workflow
  - DB: OrderStatusHistory có log cho mỗi lần chuyển đổi
  - Table.Status = AVAILABLE khi SERVED
- **Mock Behavior:** None

**TC-HP-014: Hủy đơn hàng (với lý do)**
- **Description:** Kiểm tra tích hợp CancelOrderServlet → OrderService → InventoryService (rollback stock)
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-003",
    "cancelReason": "Customer requested",
    "cancelledBy": "manager-uuid-001"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - DB: Orders.Status = CANCELLED, CancelledAt, CancelReason
  - DB: Inventory stock được hoàn trả
  - DB: Table.Status = AVAILABLE
- **Mock Behavior:** None

**TC-HP-015: Lấy lịch sử đơn hàng theo ngày**
- **Description:** Kiểm tra tích hợp OrderHistoryServlet → OrderService → OrderDAO (JOIN complex)
- **Input Data:**
  - Request: GET /api/orders?date=2025-10-31&cashierId=cashier-uuid-001
- **Expected Output:**
  - HTTP 200 OK
  - Response: JSON array với các orders, bao gồm items, payment, customer info
  - Sorted by CreatedAt DESC
- **Mock Behavior:** None

**TC-HP-016: Chia bill (Split Payment)**
- **Description:** Kiểm tra tích hợp SplitPaymentService → PaymentService → OrderService
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-004",
    "splitType": "EQUAL",
    "numberOfPeople": 3,
    "totalAmount": 300000
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"splitAmounts": [100000, 100000, 100000], "splitPaymentIds": ["pay-1", "pay-2", "pay-3"]}`
  - DB: Payments có 3 records, mỗi cái 100000
  - DB: Orders.Status = PAID khi tất cả splits đã thanh toán
- **Mock Behavior:** None

---

#### **Module 3: Inventory Management (7 test cases)**

**TC-HP-017: Thêm sản phẩm mới vào kho**
- **Description:** Kiểm tra tích hợp ProductServlet → ProductService → ProductDAO + CategoryDAO
- **Input Data:**
  ```json
  {
    "name": "Cappuccino",
    "category": "Beverages",
    "unitPrice": 45000,
    "costPrice": 20000,
    "stockQuantity": 100,
    "unit": "cup",
    "minStockLevel": 20,
    "isActive": true
  }
  ```
- **Expected Output:**
  - HTTP 201 Created
  - Response: `{"productId": "prod-uuid-xxx", "message": "Product created"}`
  - DB: Products table có record mới
  - DB: InventoryLogs có record (INITIAL_STOCK)
- **Mock Behavior:** None

**TC-HP-018: Cập nhật tồn kho (nhập hàng)**
- **Description:** Kiểm tra tích hợp InventoryServlet → InventoryService → InventoryDAO + InventoryLogDAO
- **Input Data:**
  ```json
  {
    "productId": "prod-uuid-001",
    "quantityChange": +50,
    "transactionType": "STOCK_IN",
    "reason": "Supplier delivery",
    "performedBy": "manager-uuid-001",
    "referenceId": "PO-2025-001"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - DB: Products.StockQuantity += 50
  - DB: InventoryLogs có record với type=STOCK_IN
- **Mock Behavior:** None

**TC-HP-019: Cập nhật tồn kho (xuất hàng cho đơn)**
- **Description:** Kiểm tra tích hợp tự động khi tạo đơn → InventoryService giảm stock
- **Input Data:** Triggered từ TC-HP-007 (tạo đơn)
- **Expected Output:**
  - DB: Products.StockQuantity giảm theo items trong đơn
  - DB: InventoryLogs có records với type=STOCK_OUT, ReferenceId=orderId
- **Mock Behavior:** None

**TC-HP-020: Cảnh báo tồn kho thấp**
- **Description:** Kiểm tra tích hợp InventoryService → AlertService → NotificationService
- **Input Data:**
  - Background job hoặc trigger: kiểm tra Products.StockQuantity < MinStockLevel
- **Expected Output:**
  - DB: Alerts table có record mới với type=LOW_STOCK
  - Notification gửi đến Manager/Admin
- **Mock Behavior:** Mock NotificationService (email/SMS)

**TC-HP-021: Lấy danh sách sản phẩm với filter và phân trang**
- **Description:** Kiểm tra tích hợp ProductServlet → ProductService → ProductDAO (complex query)
- **Input Data:**
  - Request: GET /api/products?category=Beverages&status=active&page=1&size=20&sort=name
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"items": [...], "total": 45, "page": 1, "totalPages": 3}`
  - Sorted alphabetically
- **Mock Behavior:** None

**TC-HP-022: Import sản phẩm từ Excel**
- **Description:** Kiểm tra tích hợp ExcelImportServlet → ExcelService → ProductService (bulk insert)
- **Input Data:**
  - File: products.xlsx với 50 rows
  - Columns: Name, Category, UnitPrice, CostPrice, StockQuantity
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"imported": 48, "failed": 2, "errors": [...]}`
  - DB: Products có 48 records mới
- **Mock Behavior:** None

**TC-HP-023: Export báo cáo tồn kho ra Excel**
- **Description:** Kiểm tra tích hợp ReportServlet → InventoryService → ExcelExportService
- **Input Data:**
  - Request: GET /api/inventory/export?format=xlsx&date=2025-10-31
- **Expected Output:**
  - HTTP 200 OK
  - Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  - File tải về chứa đầy đủ sản phẩm, stock, giá trị tồn
- **Mock Behavior:** None

---

#### **Module 4: Employee Management (6 test cases)**

**TC-HP-024: Tạo hồ sơ nhân viên mới**
- **Description:** Kiểm tra tích hợp EmployeeServlet → EmployeeService → UserDAO + EmployeeDAO + RoleDAO
- **Input Data:**
  ```json
  {
    "email": "staff@liteflow.com",
    "displayName": "Jane Smith",
    "phone": "+84912345678",
    "role": "KITCHEN_STAFF",
    "hireDate": "2025-10-01",
    "salary": 8000000,
    "department": "Kitchen"
  }
  ```
- **Expected Output:**
  - HTTP 201 Created
  - DB: Users có user mới với role KITCHEN_STAFF
  - DB: Employees có record với salary, hireDate, department
  - Email chào mừng gửi đến nhân viên
- **Mock Behavior:** Mock EmailService

**TC-HP-025: Cập nhật thông tin nhân viên**
- **Description:** Kiểm tra tích hợp EmployeeServlet → EmployeeService → EmployeeDAO
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-001",
    "salary": 9000000,
    "department": "Management",
    "updatedBy": "admin-uuid-001"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - DB: Employees.Salary = 9000000, Department = Management
  - DB: EmployeeHistory có log thay đổi
- **Mock Behavior:** None

**TC-HP-026: Chấm công nhân viên (Check-in/Check-out)**
- **Description:** Kiểm tra tích hợp AttendanceServlet → AttendanceService → AttendanceDAO
- **Input Data:**
  - Check-in: `{"employeeId": "emp-uuid-001", "action": "CHECK_IN", "timestamp": "2025-10-31T08:00:00Z"}`
  - Check-out: `{"employeeId": "emp-uuid-001", "action": "CHECK_OUT", "timestamp": "2025-10-31T17:00:00Z"}`
- **Expected Output:**
  - HTTP 200 OK cho cả 2
  - DB: Attendance có record với CheckInTime và CheckOutTime
  - DB: WorkHours = 9.0 (calculated)
- **Mock Behavior:** None

**TC-HP-027: Tạo lịch làm việc cho nhân viên**
- **Description:** Kiểm tra tích hợp ScheduleServlet → ScheduleService → ScheduleDAO
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-001",
    "shifts": [
      {"date": "2025-11-01", "shiftType": "MORNING", "startTime": "08:00", "endTime": "16:00"},
      {"date": "2025-11-02", "shiftType": "EVENING", "startTime": "16:00", "endTime": "00:00"}
    ],
    "createdBy": "manager-uuid-001"
  }
  ```
- **Expected Output:**
  - HTTP 201 Created
  - DB: Schedules có 2 records
  - Notification gửi đến nhân viên về lịch làm việc
- **Mock Behavior:** Mock NotificationService

**TC-HP-028: Tính lương cho nhân viên (Paysheet)**
- **Description:** Kiểm tra tích hợp PayrollServlet → PayrollService → AttendanceService + EmployeeService
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-001",
    "month": "2025-10",
    "baseSalary": 8000000,
    "overtimeHours": 10,
    "deductions": 500000
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"totalSalary": 8700000, "breakdown": {...}}`
  - DB: Payrolls có record với details
- **Mock Behavior:** None

**TC-HP-029: Lấy báo cáo hiệu suất nhân viên**
- **Description:** Kiểm tra tích hợp ReportServlet → EmployeeService (complex aggregation)
- **Input Data:**
  - Request: GET /api/reports/employee-performance?employeeId=emp-uuid-001&month=2025-10
- **Expected Output:**
  - HTTP 200 OK
  - Response: JSON với total orders, total revenue, attendance rate, customer feedback
- **Mock Behavior:** None

---

#### **Module 5: Table & Reservation (4 test cases)**

**TC-HP-030: Tạo đặt bàn mới**
- **Description:** Kiểm tra tích hợp ReservationServlet → ReservationService → TableService
- **Input Data:**
  ```json
  {
    "customerId": "customer-uuid-001",
    "tableId": "table-uuid-005",
    "reservationDate": "2025-11-05",
    "reservationTime": "19:00",
    "numberOfGuests": 4,
    "specialRequest": "Window seat",
    "phone": "+84987654321"
  }
  ```
- **Expected Output:**
  - HTTP 201 Created
  - DB: Reservations table có record, Status=CONFIRMED
  - DB: Tables.Status = RESERVED (cho time slot đó)
  - SMS/Email confirmation gửi đến khách
- **Mock Behavior:** Mock NotificationService

**TC-HP-031: Check-in khách đặt bàn**
- **Description:** Kiểm tra tích hợp ReservationServlet → ReservationService → TableService
- **Input Data:**
  ```json
  {
    "reservationId": "reservation-uuid-001",
    "action": "CHECK_IN",
    "actualArrivalTime": "2025-11-05T19:05:00Z"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - DB: Reservations.Status = CHECKED_IN
  - DB: Tables.Status = OCCUPIED
- **Mock Behavior:** None

**TC-HP-032: Hủy đặt bàn**
- **Description:** Kiểm tra tích hợp ReservationServlet → ReservationService
- **Input Data:**
  ```json
  {
    "reservationId": "reservation-uuid-002",
    "cancelReason": "Customer cancelled",
    "cancelledBy": "customer-uuid-002"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - DB: Reservations.Status = CANCELLED
  - DB: Tables.Status = AVAILABLE
- **Mock Behavior:** None

**TC-HP-033: Lấy danh sách bàn trống theo thời gian**
- **Description:** Kiểm tra tích hợp TableServlet → TableService (complex availability query)
- **Input Data:**
  - Request: GET /api/tables/available?date=2025-11-05&time=19:00&guests=4
- **Expected Output:**
  - HTTP 200 OK
  - Response: Array of available tables với capacity >= 4
  - Exclude tables có reservation trong time slot ±2h
- **Mock Behavior:** None

---

#### **Module 6: Procurement (3 test cases)**

**TC-HP-034: Tạo Purchase Order (PO) mới**
- **Description:** Kiểm tra tích hợp ProcurementServlet → ProcurementService → SupplierService → PODAO
- **Input Data:**
  ```json
  {
    "supplierId": "supplier-uuid-001",
    "items": [
      {"productId": "prod-uuid-010", "quantity": 100, "unitPrice": 15000},
      {"productId": "prod-uuid-011", "quantity": 50, "unitPrice": 25000}
    ],
    "expectedDeliveryDate": "2025-11-10",
    "createdBy": "manager-uuid-001"
  }
  ```
- **Expected Output:**
  - HTTP 201 Created
  - Response: `{"poId": "PO-2025-002", "totalAmount": 2750000}`
  - DB: PurchaseOrders có record, Status=PENDING
  - DB: PurchaseOrderItems có 2 records
- **Mock Behavior:** None

**TC-HP-035: Nhận hàng và cập nhật tồn kho**
- **Description:** Kiểm tra tích hợp GoodsReceiptServlet → InventoryService → PurchaseOrderService
- **Input Data:**
  ```json
  {
    "poId": "PO-2025-002",
    "receivedItems": [
      {"productId": "prod-uuid-010", "receivedQuantity": 100, "condition": "GOOD"},
      {"productId": "prod-uuid-011", "receivedQuantity": 50, "condition": "GOOD"}
    ],
    "receivedBy": "warehouse-staff-001",
    "receivedDate": "2025-11-10"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - DB: PurchaseOrders.Status = RECEIVED
  - DB: GoodsReceipts có record
  - DB: Products.StockQuantity tăng tương ứng
  - DB: InventoryLogs có records (STOCK_IN)
- **Mock Behavior:** None

**TC-HP-036: Lấy báo cáo procurement theo tháng**
- **Description:** Kiểm tra tích hợp ReportServlet → ProcurementService (aggregation + JOIN)
- **Input Data:**
  - Request: GET /api/reports/procurement?month=2025-10&supplierId=supplier-uuid-001
- **Expected Output:**
  - HTTP 200 OK
  - Response: JSON với total POs, total amount, received vs pending, top products
- **Mock Behavior:** None

---

### ⚠️ EDGE CASES (24 test cases)

#### **Module 1: Authentication & RBAC (4 test cases)**

**TC-EDGE-001: Đăng nhập với password gần đúng (typo)**
- **Description:** Kiểm tra xử lý sai password với typo nhỏ
- **Input Data:**
  ```json
  {
    "email": "admin@liteflow.com",
    "password": "Admin@12" // thiếu ký tự cuối
  }
  ```
- **Expected Output:**
  - HTTP 401 Unauthorized
  - Response: `{"error": "Invalid credentials"}`
  - DB: không tạo session
  - DB: LoginAttempts += 1 (nếu có tracking)
- **Mock Behavior:** None

**TC-EDGE-002: Session expire và auto logout**
- **Description:** Kiểm tra AuthenticationFilter xử lý session hết hạn
- **Input Data:**
  - Session: expired (CreatedAt + 8h < now)
  - Request: GET /api/orders
- **Expected Output:**
  - HTTP 401 Unauthorized
  - Redirect to /auth/login.jsp
  - Session cookie bị xóa
- **Mock Behavior:** None

**TC-EDGE-003: Đăng nhập đồng thời từ nhiều thiết bị**
- **Description:** Kiểm tra hệ thống xử lý multiple sessions cho cùng user
- **Input Data:**
  - User đăng nhập từ browser A → session-001
  - User đăng nhập từ browser B → session-002
- **Expected Output:**
  - Cả 2 sessions đều ACTIVE (hoặc session-001 bị invalidate nếu config single-session)
  - DB: UserSessions có 2 records hoặc 1 (tùy policy)
- **Mock Behavior:** None

**TC-EDGE-004: RBAC - Manager truy cập endpoint của Admin (403)**
- **Description:** Kiểm tra AuthorizationFilter block access không đủ quyền
- **Input Data:**
  - Session: user có role MANAGER
  - Request: DELETE /api/users/{userId}
- **Expected Output:**
  - HTTP 403 Forbidden
  - Response: `{"error": "Insufficient permissions"}`
- **Mock Behavior:** None

---

#### **Module 2: Cashier/POS Order (6 test cases)**

**TC-EDGE-005: Tạo đơn với số lượng item = 0**
- **Description:** Kiểm tra validation tại Service layer
- **Input Data:**
  ```json
  {
    "tableId": "table-uuid-001",
    "items": [
      {"productId": "prod-001", "quantity": 0, "unitPrice": 50000}
    ]
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Item quantity must be greater than 0"}`
- **Mock Behavior:** None

**TC-EDGE-006: Tạo đơn với sản phẩm inactive**
- **Description:** Kiểm tra validation product status trước khi tạo order
- **Input Data:**
  ```json
  {
    "items": [
      {"productId": "prod-inactive-001", "quantity": 1}
    ]
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Product prod-inactive-001 is not available"}`
- **Mock Behavior:** None

**TC-EDGE-007: Áp dụng khuyến mãi đã hết hạn**
- **Description:** Kiểm tra PromotionService validate expiry date
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-001",
    "promotionCode": "EXPIRED2024"
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Promotion code has expired"}`
- **Mock Behavior:** None

**TC-EDGE-008: Thanh toán với số tiền nhỏ hơn total**
- **Description:** Kiểm tra validation payment amount
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-001",
    "paymentMethod": "CASH",
    "amountPaid": 100000,
    "orderTotal": 175000
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Insufficient payment amount"}`
- **Mock Behavior:** None

**TC-EDGE-009: Tạo đơn với table đã bị occupied**
- **Description:** Kiểm tra concurrent access handling cho Table
- **Input Data:**
  - Table.Status = OCCUPIED
  - Request: Create order cho table đó
- **Expected Output:**
  - HTTP 409 Conflict
  - Response: `{"error": "Table is already occupied"}`
- **Mock Behavior:** None

**TC-EDGE-010: Hủy đơn đã thanh toán**
- **Description:** Kiểm tra business rule không cho phép hủy đơn đã PAID
- **Input Data:**
  ```json
  {
    "orderId": "order-paid-001",
    "cancelReason": "Customer changed mind"
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Cannot cancel paid order. Please process refund instead."}`
- **Mock Behavior:** None

---

#### **Module 3: Inventory (5 test cases)**

**TC-EDGE-011: Cập nhật stock âm (overselling)**
- **Description:** Kiểm tra InventoryService prevent negative stock
- **Input Data:**
  ```json
  {
    "productId": "prod-uuid-001",
    "quantityChange": -150,
    "currentStock": 100
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Insufficient stock. Available: 100"}`
  - DB: Stock không thay đổi
- **Mock Behavior:** None

**TC-EDGE-012: Import Excel với dữ liệu duplicate (SKU/Name)**
- **Description:** Kiểm tra ExcelService xử lý duplicate entries
- **Input Data:**
  - File có 2 rows với cùng SKU "SKU-001"
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"imported": 1, "failed": 1, "errors": ["Row 3: Duplicate SKU"]}`
  - DB: chỉ có 1 product được tạo
- **Mock Behavior:** None

**TC-EDGE-013: Cập nhật giá sản phẩm thành 0 hoặc âm**
- **Description:** Kiểm tra validation business rule
- **Input Data:**
  ```json
  {
    "productId": "prod-uuid-001",
    "unitPrice": -5000
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Unit price must be positive"}`
- **Mock Behavior:** None

**TC-EDGE-014: Filter sản phẩm với category không tồn tại**
- **Description:** Kiểm tra ProductDAO xử lý invalid filter
- **Input Data:**
  - Request: GET /api/products?category=NonExistentCategory
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"items": [], "total": 0}`
- **Mock Behavior:** None

**TC-EDGE-015: Tồn kho bằng chính xác min stock level (boundary)**
- **Description:** Kiểm tra alert trigger ở boundary
- **Input Data:**
  - Product.StockQuantity = 20
  - Product.MinStockLevel = 20
- **Expected Output:**
  - Alert được trigger (vì stock <= min)
  - DB: Alerts có record LOW_STOCK
- **Mock Behavior:** None

---

#### **Module 4: Employee (4 test cases)**

**TC-EDGE-016: Tạo nhân viên với email đã tồn tại**
- **Description:** Kiểm tra unique constraint validation
- **Input Data:**
  ```json
  {
    "email": "existing@liteflow.com",
    "displayName": "Duplicate User"
  }
  ```
- **Expected Output:**
  - HTTP 409 Conflict
  - Response: `{"error": "Email already exists"}`
- **Mock Behavior:** None

**TC-EDGE-017: Check-out mà chưa check-in**
- **Description:** Kiểm tra AttendanceService validate workflow
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-001",
    "action": "CHECK_OUT",
    "noCheckInRecord": true
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "No check-in record found"}`
- **Mock Behavior:** None

**TC-EDGE-018: Tính lương với overtime vượt giới hạn**
- **Description:** Kiểm tra PayrollService validation overtime hours
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-001",
    "month": "2025-10",
    "overtimeHours": 120 // > max allowed (80h)
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Overtime hours exceed maximum allowed (80h)"}`
- **Mock Behavior:** None

**TC-EDGE-019: Tạo lịch làm việc trùng ca**
- **Description:** Kiểm tra ScheduleService detect conflicts
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-001",
    "shifts": [
      {"date": "2025-11-01", "startTime": "08:00", "endTime": "16:00"},
      {"date": "2025-11-01", "startTime": "14:00", "endTime": "22:00"}
    ]
  }
  ```
- **Expected Output:**
  - HTTP 409 Conflict
  - Response: `{"error": "Shift conflict detected for 2025-11-01"}`
- **Mock Behavior:** None

---

#### **Module 5: Table & Reservation (3 test cases)**

**TC-EDGE-020: Đặt bàn cho quá khứ**
- **Description:** Kiểm tra ReservationService validate date
- **Input Data:**
  ```json
  {
    "reservationDate": "2025-10-01",
    "reservationTime": "19:00",
    "currentDate": "2025-10-31"
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Cannot make reservation in the past"}`
- **Mock Behavior:** None

**TC-EDGE-021: Đặt bàn với số lượng khách > capacity**
- **Description:** Kiểm tra TableService validation
- **Input Data:**
  ```json
  {
    "tableId": "table-uuid-small",
    "numberOfGuests": 10,
    "tableCapacity": 4
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Number of guests exceeds table capacity"}`
- **Mock Behavior:** None

**TC-EDGE-022: Check-in reservation đã quá giờ (late arrival)**
- **Description:** Kiểm tra ReservationService xử lý late check-in
- **Input Data:**
  ```json
  {
    "reservationId": "reservation-uuid-001",
    "reservationTime": "19:00",
    "actualArrivalTime": "20:30" // late 1.5h
  }
  ```
- **Expected Output:**
  - HTTP 200 OK (hoặc 409 nếu table đã cho khách khác)
  - Response có warning: `{"status": "CHECKED_IN", "warning": "Late arrival"}`
- **Mock Behavior:** None

---

#### **Module 6: Procurement (2 test cases)**

**TC-EDGE-023: Tạo PO với supplier inactive**
- **Description:** Kiểm tra ProcurementService validate supplier status
- **Input Data:**
  ```json
  {
    "supplierId": "supplier-inactive-001",
    "items": [...]
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Supplier is inactive"}`
- **Mock Behavior:** None

**TC-EDGE-024: Nhận hàng với số lượng != PO quantity**
- **Description:** Kiểm tra GoodsReceiptService xử lý partial receipt
- **Input Data:**
  ```json
  {
    "poId": "PO-2025-002",
    "receivedItems": [
      {"productId": "prod-uuid-010", "receivedQuantity": 80, "orderedQuantity": 100}
    ]
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"status": "PARTIALLY_RECEIVED", "discrepancies": [...]}`
  - DB: PurchaseOrders.Status = PARTIALLY_RECEIVED
  - DB: Stock chỉ tăng 80
- **Mock Behavior:** None

---

### ❌ ERROR SCENARIOS (25 test cases)

#### **Module 1: Authentication & RBAC (5 test cases)**

**TC-ERR-001: Đăng nhập với user không tồn tại**
- **Description:** Kiểm tra AuthService xử lý user not found
- **Input Data:**
  ```json
  {
    "email": "nonexistent@liteflow.com",
    "password": "AnyPassword"
  }
  ```
- **Expected Output:**
  - HTTP 401 Unauthorized
  - Response: `{"error": "Invalid credentials"}`
  - Không leak thông tin "user not found"
- **Mock Behavior:** None

**TC-ERR-002: Xác thực 2FA với TOTP code sai**
- **Description:** Kiểm tra AuthService reject invalid TOTP
- **Input Data:**
  ```json
  {
    "userId": "user-uuid-001",
    "totpCode": "000000"
  }
  ```
- **Expected Output:**
  - HTTP 401 Unauthorized
  - Response: `{"error": "Invalid 2FA code"}`
  - DB: Failed2FAAttempts += 1
- **Mock Behavior:** None

**TC-ERR-003: Google OAuth với invalid token**
- **Description:** Kiểm tra AuthService xử lý lỗi OAuth verification
- **Input Data:**
  ```json
  {
    "googleToken": "invalid_or_expired_token"
  }
  ```
- **Expected Output:**
  - HTTP 401 Unauthorized
  - Response: `{"error": "OAuth verification failed"}`
- **Mock Behavior:** Mock Google API trả về error

**TC-ERR-004: Database connection lost khi đăng nhập**
- **Description:** Kiểm tra exception handling khi DB down
- **Input Data:**
  - Valid credentials
  - DB connection đột ngột bị mất
- **Expected Output:**
  - HTTP 503 Service Unavailable
  - Response: `{"error": "Service temporarily unavailable"}`
  - Log ghi chi tiết SQLException
- **Mock Behavior:** Mock DAO throw SQLException

**TC-ERR-005: Tạo user với password không đủ mạnh**
- **Description:** Kiểm tra validation password policy
- **Input Data:**
  ```json
  {
    "email": "weak@liteflow.com",
    "password": "123"
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Password must be at least 8 characters, contain uppercase, lowercase, number, and special char"}`
- **Mock Behavior:** None

---

#### **Module 2: Cashier/POS Order (6 test cases)**

**TC-ERR-006: Tạo đơn khi DB transaction rollback**
- **Description:** Kiểm tra transaction handling khi partial failure
- **Input Data:**
  - Valid order data
  - Trigger exception sau khi insert Orders nhưng trước khi insert OrderItems
- **Expected Output:**
  - HTTP 500 Internal Server Error
  - DB: Orders table KHÔNG có record mới (rollback thành công)
  - DB: OrderItems table KHÔNG có records
- **Mock Behavior:** Mock OrderItemDAO throw exception

**TC-ERR-007: Thanh toán khi Payment Gateway timeout**
- **Description:** Kiểm tra tích hợp với external service bị timeout
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-001",
    "paymentMethod": "CREDIT_CARD",
    "cardToken": "tok_visa_1234"
  }
  ```
- **Expected Output:**
  - HTTP 504 Gateway Timeout
  - Response: `{"error": "Payment gateway timeout. Please try again."}`
  - DB: Orders.Status = PENDING (không đổi)
  - DB: Payments.Status = FAILED
- **Mock Behavior:** Mock PaymentGatewayService throw TimeoutException

**TC-ERR-008: Thanh toán thành công nhưng ghi receipt lỗi**
- **Description:** Kiểm tra idempotency và rollback partial failure
- **Input Data:**
  - Valid payment data
  - Trigger exception khi ReceiptService.create()
- **Expected Output:**
  - HTTP 500 Internal Server Error
  - DB: Payments.Status = COMPLETED (đã commit)
  - DB: Orders.Status = PAID
  - DB: Receipts KHÔNG có record
  - Log warning: "Receipt generation failed, payment successful"
  - Background job retry receipt generation
- **Mock Behavior:** Mock ReceiptDAO throw exception

**TC-ERR-009: Cập nhật order status với invalid workflow**
- **Description:** Kiểm tra OrderService validate state transition
- **Input Data:**
  ```json
  {
    "orderId": "order-uuid-001",
    "currentStatus": "PENDING",
    "newStatus": "SERVED" // skip PREPARING, READY
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Invalid status transition: PENDING -> SERVED"}`
- **Mock Behavior:** None

**TC-ERR-010: Tạo đơn khi inventory update fail (race condition)**
- **Description:** Kiểm tra concurrency handling
- **Input Data:**
  - 2 requests đồng thời đặt món có stock = 1
  - Request 1: quantity = 1
  - Request 2: quantity = 1
- **Expected Output:**
  - Request 1: HTTP 201 Created
  - Request 2: HTTP 409 Conflict, `{"error": "Insufficient stock"}`
  - DB: chỉ 1 order được tạo
  - DB: Stock = 0
- **Mock Behavior:** None (test concurrent requests)

**TC-ERR-011: In hóa đơn cho order không tồn tại**
- **Description:** Kiểm tra ReceiptService xử lý invalid orderId
- **Input Data:**
  - Request: GET /receipt/print?orderId=non-existent-uuid
- **Expected Output:**
  - HTTP 404 Not Found
  - Response: `{"error": "Order not found"}`
- **Mock Behavior:** None

---

#### **Module 3: Inventory (5 test cases)**

**TC-ERR-012: Thêm sản phẩm với SKU duplicate (DB constraint)**
- **Description:** Kiểm tra exception handling cho unique constraint violation
- **Input Data:**
  ```json
  {
    "sku": "SKU-EXISTING",
    "name": "New Product"
  }
  ```
- **Expected Output:**
  - HTTP 409 Conflict
  - Response: `{"error": "SKU already exists"}`
  - Log ghi SQLIntegrityConstraintViolationException
- **Mock Behavior:** None

**TC-ERR-013: Cập nhật stock khi product không tồn tại**
- **Description:** Kiểm tra InventoryService validation
- **Input Data:**
  ```json
  {
    "productId": "non-existent-uuid",
    "quantityChange": +50
  }
  ```
- **Expected Output:**
  - HTTP 404 Not Found
  - Response: `{"error": "Product not found"}`
- **Mock Behavior:** None

**TC-ERR-014: Import Excel file bị corrupt hoặc sai format**
- **Description:** Kiểm tra ExcelService exception handling
- **Input Data:**
  - File: corrupted.xlsx (không parse được)
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Invalid file format"}`
- **Mock Behavior:** None

**TC-ERR-015: Export Excel khi không có dữ liệu**
- **Description:** Kiểm tra ExcelExportService xử lý empty result
- **Input Data:**
  - Request: GET /api/inventory/export?date=2020-01-01 (no data)
- **Expected Output:**
  - HTTP 200 OK
  - File tải về có header nhưng không có data rows
- **Mock Behavior:** None

**TC-ERR-016: Alert service không gửi được email (SMTP fail)**
- **Description:** Kiểm tra AlertService handle notification failure
- **Input Data:**
  - Low stock trigger
  - SMTP server down
- **Expected Output:**
  - DB: Alerts.Status = PENDING (not SENT)
  - Log error: "Failed to send notification"
  - Background job retry sau 5 phút
- **Mock Behavior:** Mock EmailService throw MessagingException

---

#### **Module 4: Employee (4 test cases)**

**TC-ERR-017: Cập nhật nhân viên không tồn tại**
- **Description:** Kiểm tra EmployeeService validation
- **Input Data:**
  ```json
  {
    "employeeId": "non-existent-uuid",
    "salary": 10000000
  }
  ```
- **Expected Output:**
  - HTTP 404 Not Found
  - Response: `{"error": "Employee not found"}`
- **Mock Behavior:** None

**TC-ERR-018: Chấm công với timestamp trong tương lai**
- **Description:** Kiểm tra AttendanceService validate timestamp
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-001",
    "action": "CHECK_IN",
    "timestamp": "2025-12-31T08:00:00Z" // future
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Timestamp cannot be in the future"}`
- **Mock Behavior:** None

**TC-ERR-019: Tính lương khi không có attendance records**
- **Description:** Kiểm tra PayrollService xử lý missing data
- **Input Data:**
  ```json
  {
    "employeeId": "emp-uuid-new",
    "month": "2025-10"
  }
  ```
- **Expected Output:**
  - HTTP 200 OK
  - Response: `{"totalSalary": 0, "workDays": 0, "warning": "No attendance records found"}`
- **Mock Behavior:** None

**TC-ERR-020: Tạo lịch làm việc khi employee inactive**
- **Description:** Kiểm tra ScheduleService validation
- **Input Data:**
  ```json
  {
    "employeeId": "emp-inactive-001",
    "shifts": [...]
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Cannot schedule shifts for inactive employee"}`
- **Mock Behavior:** None

---

#### **Module 5: Table & Reservation (3 test cases)**

**TC-ERR-021: Tạo reservation với tableId không tồn tại**
- **Description:** Kiểm tra ReservationService validation
- **Input Data:**
  ```json
  {
    "tableId": "non-existent-table-uuid",
    "reservationDate": "2025-11-05"
  }
  ```
- **Expected Output:**
  - HTTP 404 Not Found
  - Response: `{"error": "Table not found"}`
- **Mock Behavior:** None

**TC-ERR-022: Check-in reservation đã bị hủy**
- **Description:** Kiểm tra ReservationService validate status
- **Input Data:**
  ```json
  {
    "reservationId": "reservation-cancelled-001",
    "action": "CHECK_IN"
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Cannot check-in cancelled reservation"}`
- **Mock Behavior:** None

**TC-ERR-023: Lấy available tables khi DB query timeout**
- **Description:** Kiểm tra TableService exception handling
- **Input Data:**
  - Request: GET /api/tables/available?date=2025-11-05
  - DB query quá lâu (> 5s)
- **Expected Output:**
  - HTTP 504 Gateway Timeout
  - Response: `{"error": "Query timeout"}`
  - Log ghi QueryTimeoutException
- **Mock Behavior:** Mock TableDAO throw SQLException

---

#### **Module 6: Procurement (2 test cases)**

**TC-ERR-024: Tạo PO với items rỗng**
- **Description:** Kiểm tra ProcurementService validation
- **Input Data:**
  ```json
  {
    "supplierId": "supplier-uuid-001",
    "items": []
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Purchase order must contain at least one item"}`
- **Mock Behavior:** None

**TC-ERR-025: Nhận hàng khi PO đã hoàn tất (duplicate goods receipt)**
- **Description:** Kiểm tra GoodsReceiptService prevent duplicate
- **Input Data:**
  ```json
  {
    "poId": "PO-completed-001",
    "currentStatus": "COMPLETED",
    "receivedItems": [...]
  }
  ```
- **Expected Output:**
  - HTTP 400 Bad Request
  - Response: `{"error": "Purchase order already completed"}`
- **Mock Behavior:** None

---

## 📈 PHÂN TÍCH BẢO PHỦ (COVERAGE ESTIMATION)

### Coverage theo Module

| Module | Happy Path | Edge Cases | Error Scenarios | Tổng TC | Ước tính Coverage |
|--------|-----------|------------|-----------------|---------|-------------------|
| **Authentication & RBAC** | 6 | 4 | 5 | **15** | **~80%** |
| **Cashier/POS Order** | 10 | 6 | 6 | **22** | **~85%** |
| **Inventory Management** | 7 | 5 | 5 | **17** | **~75%** |
| **Employee Management** | 6 | 4 | 4 | **14** | **~70%** |
| **Table & Reservation** | 4 | 3 | 3 | **10** | **~65%** |
| **Procurement** | 3 | 2 | 2 | **7** | **~60%** |
| **TỔNG CỘNG** | **36** | **24** | **25** | **85** | **≥70%** |

### Các điểm tích hợp được bao phủ

✅ **Frontend ↔ Servlet ↔ Service ↔ DAO ↔ DB** (end-to-end flow)  
✅ **Transaction Management** (rollback, partial failure)  
✅ **Concurrency Control** (race conditions, optimistic locking)  
✅ **Authentication & Authorization** (session, JWT, RBAC)  
✅ **External Service Integration** (Payment Gateway, Email, SMS)  
✅ **Business Logic Validation** (workflow, constraints, business rules)  
✅ **Error Handling & Exception Management**  
✅ **Data Integrity** (FK constraints, unique constraints, cascades)  

### Metrics đo lường

- **Line Coverage**: ≥70% trên các gói `com.liteflow.controller`, `com.liteflow.service`
- **Branch Coverage**: ≥60% trên các điều kiện nghiệp vụ quan trọng
- **Integration Points**: 100% các luồng tích hợp E2E ưu tiên được test
- **Critical Paths**: 100% các ca dùng chính được test (Order flow, Auth flow, Payment flow)

---

## 🎯 KẾT LUẬN

Ma trận test case này bao phủ **85 test cases** trên **6 module nghiệp vụ chính** của hệ thống LiteFlow, với ước tính đạt **≥70% coverage tích hợp** trên tầng Servlet + Service + DAO.

**Ưu tiên thực thi:**
1. **Phase 1** (Critical): Authentication, Order Management (TC-HP-001 đến TC-HP-016)
2. **Phase 2** (Core Business): Inventory, Employee, Payment (TC-HP-017 đến TC-HP-029)
3. **Phase 3** (Supporting): Reservation, Procurement, Reporting (TC-HP-030 đến TC-HP-036)
4. **Phase 4** (Robustness): Tất cả Edge Cases + Error Scenarios

**Tài liệu kế tiếp:** PR3 - Môi trường test & seed data, PR4 - Implementation test code, PR5 - Báo cáo coverage.

