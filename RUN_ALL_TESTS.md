# 🚀 CHẠY TẤT CẢ TESTS - QUICK REFERENCE

## ⚡ LỆNH NHANH NHẤT

```bash
# Chạy TẤT CẢ tests trong project (74 test files)
mvn test
```

---

## 📊 CÁC LỆNH CHÍNH

### 1️⃣ Chạy Tất Cả Tests
```bash
# Cơ bản
mvn test

# Với clean build
mvn clean test

# Quiet mode (ít output)
mvn test -q

# Verbose mode (debug)
mvn test -X
```

### 2️⃣ Chạy Tests Theo Module/Package
```bash
# 🔐 Module 1: Authentication & Authorization
mvn test -Dtest=com.liteflow.controller.auth.*
mvn test -Dtest=com.liteflow.service.auth.*

# 💰 Module 2: Cashier/POS
mvn test -Dtest=com.liteflow.controller.cashier.*
mvn test -Dtest=com.liteflow.cashier.*

# 📦 Module 3: Inventory & Products
mvn test -Dtest=com.liteflow.controller.inventory.*
mvn test -Dtest=com.liteflow.service.inventory.*

# 👥 Module 4: Employee Management
mvn test -Dtest=com.liteflow.controller.employee.*
mvn test -Dtest=com.liteflow.service.employee.*

# 🍽️ Module 5: Reservation & Tables
mvn test -Dtest=com.liteflow.controller.reservation.*

# 🛒 Module 6: Procurement
mvn test -Dtest=com.liteflow.controller.procurement.*
mvn test -Dtest=com.liteflow.service.procurement.*

# 📊 Module 7: Reports & Analytics
mvn test -Dtest=com.liteflow.controller.report.*
mvn test -Dtest=com.liteflow.service.analytics.*

# 💵 Module 8: Sales
mvn test -Dtest=com.liteflow.controller.sales.*
mvn test -Dtest=com.liteflow.dao.sales.*

# 📅 Module 9: Schedule & Timesheet
mvn test -Dtest=com.liteflow.controller.schedule.*
mvn test -Dtest=com.liteflow.service.schedule.*
mvn test -Dtest=com.liteflow.controller.timesheet.*
mvn test -Dtest=com.liteflow.service.timesheet.*

# 🔔 Module 10: Alerts & Notifications
mvn test -Dtest=com.liteflow.controller.alert.*
mvn test -Dtest=com.liteflow.service.alert.*

# 🤖 Module 11: AI & Chatbot
mvn test -Dtest=com.liteflow.controller.api.*
mvn test -Dtest=com.liteflow.service.ai.*

# 🛡️ Filters & Security
mvn test -Dtest=com.liteflow.filter.*

# 🔧 Utilities
mvn test -Dtest=com.liteflow.util.*

# Nhiều modules cùng lúc
mvn test -Dtest=com.liteflow.controller.auth.*,com.liteflow.controller.cashier.*
```

### 3️⃣ Chạy Test Class Cụ Thể
```bash
# Một class
mvn test -Dtest=LoginServletIntegrationTest

# Nhiều classes
mvn test -Dtest=LoginServletIntegrationTest,PasswordUtilTest
```

### 4️⃣ Chạy Test Method Cụ Thể
```bash
# Một method
mvn test -Dtest=LoginServletIntegrationTest#testLoginSuccess

# Tất cả methods bắt đầu với "testLogin"
mvn test -Dtest=LoginServletIntegrationTest#testLogin*

# Nhiều methods
mvn test -Dtest=LoginServletIntegrationTest#testLoginSuccess+testLoginFail
```

---

## 📈 COVERAGE REPORT

### Tạo Coverage Report
```bash
# Coverage cho TẤT CẢ tests
mvn clean test jacoco:report

# Coverage cho module cụ thể
mvn clean test -Dtest=com.liteflow.controller.auth.* jacoco:report
mvn clean test -Dtest=com.liteflow.controller.cashier.* jacoco:report

# Coverage cho specific test class
mvn clean test -Dtest=LoginServletIntegrationTest jacoco:report
```

### Xem Coverage Report
```bash
# Windows PowerShell
start target/site/jacoco/index.html

# Mac
open target/site/jacoco/index.html

# Linux
xdg-open target/site/jacoco/index.html
```

### Coverage Tests Chuyên Dụng
```bash
# Chạy coverage test cho Spring Context
mvn test -Dtest=CoverageSpringContextTest

# Chạy coverage test dùng reflection
mvn test -Dtest=ReflectionCoverageTest
```

---

## ⚡ TỐI ƯU HÓA TỐC ĐỘ

### Chạy Song Song (Parallel)
```bash
# Dùng 4 threads
mvn test -T 4

# Dùng 1 thread cho mỗi CPU core
mvn test -T 1C

# Kết hợp với quiet mode
mvn test -T 4 -q
```

### Skip Các Bước Không Cần
```bash
# Skip compilation nếu đã compile
mvn surefire:test

# Skip tests (không khuyến khích)
mvn clean install -DskipTests
```

---

## 🔍 KIỂM TRA TESTS

### Liệt Kê Tất Cả Test Files
```bash
# Windows PowerShell
Get-ChildItem -Path "src/test/java" -Recurse -Filter "*Test.java" | Select-Object Name

# Linux/Mac
find src/test/java -name "*Test.java"
```

### Đếm Số Lượng Tests
```bash
# Windows PowerShell
Get-ChildItem -Path "src/test/java" -Recurse -Filter "*Test.java" | Measure-Object | Select-Object -ExpandProperty Count

# Linux/Mac
find src/test/java -name "*Test.java" | wc -l
```

---

## 🎯 CÁC TEST HIỆN CÓ

### Tổng Quan
- **Tổng số test files:** 74
- **Framework:** JUnit 5 + Mockito
- **Database:** H2 in-memory (MSSQLServer mode)

### 📦 Tests Theo Module

#### 🔐 Module 1: Authentication & Authorization (13 tests)
**Controller Tests:**
- `LoginServletIntegrationTest`
- `LoginGoogleServletIntegrationTest`
- `SignupServletIntegrationTest`
- `LogoutServletIntegrationTest`
- `RefreshServletIntegrationTest`
- `ForgotPasswordServletIntegrationTest`
- `OtpServletIntegrationTest`
- `OAuth2CallbackServletIntegrationTest`

**Service Tests:**
- `AuthServiceIntegrationTest`
- `UserServiceIntegrationTest`
- `RoleServiceIntegrationTest`
- `OtpServiceIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.auth.*,com.liteflow.service.auth.*`

---

#### 💰 Module 2: Cashier/POS (6 tests)
**Controller Tests:**
- `CashierServletIntegrationTest`
- `CashierAPIServletIntegrationTest`
- `GetSessionOrdersServletIntegrationTest`
- `UpdateOrderStatusServletIntegrationTest`
- `KitchenServletIntegrationTest`

**Legacy Tests:**
- `CreateOrderServletTest` (20 test cases, 97% coverage)

**Service Tests:**
- `OrderServiceIntegrationTest`

**Helper:**
- `OrderTestHelper`

**Command:** `mvn test -Dtest=com.liteflow.controller.cashier.*,com.liteflow.cashier.*,com.liteflow.service.order.*`

---

#### 📦 Module 3: Inventory & Products (7 tests)
**Controller Tests:**
- `ProductServletIntegrationTest`
- `SetPriceServletIntegrationTest`

**Service Tests:**
- `ProductServiceIntegrationTest`
- `ProductServiceH2IntegrationTest`
- `RoomTableServiceH2IntegrationTest`
- `ReservationServiceH2IntegrationTest`
- `ExcelServiceIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.inventory.*,com.liteflow.service.inventory.*`

---

#### 👥 Module 4: Employee Management (5 tests)
**Controller Tests:**
- `EmployeeServletIntegrationTest`
- `AttendanceServletIntegrationTest`
- `DashboardEmployeeServletIntegrationTest`
- `TimesheetServletIntegrationTest`

**Service Tests:**
- `EmployeeServiceIntegrationTest`
- `TimesheetServiceIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.employee.*,com.liteflow.service.employee.*`

---

#### 🍽️ Module 5: Reservation & Tables (2 tests)
**Controller Tests:**
- `ReceptionServletIntegrationTest`
- `RoomTableServletIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.reservation.*`

---

#### 🛒 Module 6: Procurement (5 tests)
**Controller Tests:**
- `PurchaseOrderServletIntegrationTest`
- `InvoiceServletIntegrationTest`
- `GoodsReceiptServletIntegrationTest`

**Web Tests:**
- `PurchaseOrderServletIntegrationTest` (web layer)

**Service Tests:**
- `ProcurementServiceH2IntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.procurement.*,com.liteflow.service.procurement.*,com.liteflow.web.procurement.*`

---

#### 📊 Module 7: Reports & Analytics (3 tests)
**Controller Tests:**
- `DailyReportServletIntegrationTest`
- `RevenueReportServletIntegrationTest`

**Service Tests:**
- `DemandForecastServiceIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.report.*,com.liteflow.service.analytics.*`

---

#### 💵 Module 8: Sales (4 tests)
**Controller Tests:**
- `SalesInvoiceServletIntegrationTest`
- `SalesInvoicePageServletIntegrationTest`

**Web Tests:**
- `SalesInvoiceServletIntegrationTest` (web layer)

**DAO Tests:**
- `SalesInvoiceDAOIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.sales.*,com.liteflow.dao.sales.*,com.liteflow.web.sales.*`

---

#### 📅 Module 9: Schedule & Timesheet (6 tests)
**Controller Tests:**
- `ScheduleServletIntegrationTest`
- `PersonalScheduleServletIntegrationTest`
- `LeaveRequestServletIntegrationTest`
- `ForgotClockRequestServletIntegrationTest`

**Service Tests:**
- `ScheduleServiceIntegrationTest`
- `PersonalScheduleServiceIntegrationTest`
- `LeaveRequestServiceIntegrationTest`
- `ForgotClockRequestServiceIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.schedule.*,com.liteflow.controller.timesheet.*,com.liteflow.service.schedule.*,com.liteflow.service.timesheet.*`

---

#### 🔔 Module 10: Alerts & Notifications (5 tests)
**Controller Tests:**
- `AlertServletIntegrationTest`
- `SendNotificationServletIntegrationTest`
- `NotificationAPIServletIntegrationTest`

**Service Tests:**
- `AlertServiceIntegrationTest`

**Job Tests:**
- `ProcurementAlertJobIntegrationTest`

**Listener Tests:**
- `AlertSchedulerListenerIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.alert.*,com.liteflow.service.alert.*,com.liteflow.job.*,com.liteflow.listener.*`

---

#### 🤖 Module 11: AI & Chatbot (3 tests)
**Controller Tests:**
- `ChatBotServletIntegrationTest`
- `DemandForecastServletIntegrationTest`

**Service Tests:**
- `GPTServiceIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.api.*,com.liteflow.service.ai.*`

---

#### 💼 Module 12: Dashboard & Admin (3 tests)
**Controller Tests:**
- `DashboardServletIntegrationTest`
- `SetupEmployeeServletIntegrationTest`
- `RecalculateAttendanceFlagsServletIntegrationTest`

**Service Tests:**
- `CompensationServiceIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.controller.dashboard.*,com.liteflow.controller.compensation.*,com.liteflow.service.compensation.*`

---

#### 🛡️ Security & Filters (3 tests)
- `AuthenticationFilterIntegrationTest`
- `CommonFilterIntegrationTest`
- `NoticeServletIntegrationTest`

**Command:** `mvn test -Dtest=com.liteflow.filter.*,com.liteflow.web.notice.*`

---

#### 🔧 Utilities & Coverage (3 tests)
- `PasswordUtilTest`
- `CoverageSpringContextTest`
- `ReflectionCoverageTest`

**Command:** `mvn test -Dtest=com.liteflow.util.*,CoverageSpringContextTest,ReflectionCoverageTest`

---

### 🛠️ Helper Classes & Utilities
**Base Classes:**
- `IntegrationTestBase` - Base class cho integration tests
- `TestScenarios` - Pre-built test scenarios

**Builders:**
- `TestDataBuilder` - Builders cho entities

**Mocks:**
- `MockServiceHelper` - Service mocks
- `ServletTestHelper` - HTTP mocking
- `OrderTestHelper` - Order-specific helpers

---

## 🐛 TROUBLESHOOTING

### Vấn Đề: "No tests were executed"
**Giải pháp:**
```bash
# Kiểm tra test class tồn tại
mvn test -Dtest=CreateOrderServletTest -X

# Chạy TẤT CẢ tests (không dùng -Dtest)
mvn test
```

### Vấn Đề: Tests chạy chậm
**Giải pháp:**
```bash
# Chạy song song
mvn test -T 4
```

### Vấn Đề: Ký tự tiếng Việt hiện `?`
**Giải pháp:**
```bash
mvn test -Dfile.encoding=UTF-8
```

### Vấn Đề: Build failed
**Giải pháp:**
```bash
# Clean và rebuild
mvn clean install

# Nếu vẫn lỗi, xem logs chi tiết
mvn clean install -X
```

---

## 📊 KẾT QUẢ MONG ĐỢI

### Khi Chạy Tất Cả Tests
```
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.liteflow.controller.auth.LoginServletIntegrationTest
[INFO] Running com.liteflow.controller.auth.SignupServletIntegrationTest
[INFO] Running com.liteflow.controller.cashier.CashierServletIntegrationTest
[INFO] Running com.liteflow.cashier.CreateOrderServletTest
[INFO] Tests run: 20, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.liteflow.service.auth.AuthServiceIntegrationTest
[INFO] Running com.liteflow.util.PasswordUtilTest
[INFO] ... (66 more test files) ...
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: XXX, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

### Khi Chạy Tests Theo Module
```bash
# Example: Chạy module Authentication
mvn test -Dtest=com.liteflow.controller.auth.*

[INFO] Running com.liteflow.controller.auth.LoginServletIntegrationTest
[INFO] Running com.liteflow.controller.auth.SignupServletIntegrationTest
[INFO] Running com.liteflow.controller.auth.LogoutServletIntegrationTest
... (5 more tests) ...
[INFO] Tests run: XX, Failures: 0, Errors: 0, Skipped: 0
```

---

## 🎓 TÀI LIỆU THAM KHẢO

### Tài Liệu Nội Bộ
1. **[README.md](src/test/java/README.md)** - Test infrastructure guide
2. **[Auth Module Testing Guide](src/test/java/com/liteflow/controller/auth/README.md)** - Auth testing specifics
3. **[Servlet Testing Notes](src/test/java/com/liteflow/controller/auth/SERVLET_TESTING_NOTE.md)** - Servlet test patterns

### External References
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [JaCoCo Coverage](https://www.jacoco.org/jacoco/trunk/doc/)
- [Maven Surefire Plugin](https://maven.apache.org/surefire/maven-surefire-plugin/)

---

## 🚀 BẮT ĐẦU NGAY

```bash
# 1. Chạy tất cả tests (74 test files)
mvn test

# 2. Chạy tests của một module cụ thể
mvn test -Dtest=com.liteflow.controller.auth.*

# 3. Tạo coverage report
mvn clean test jacoco:report

# 4. Xem coverage (Windows)
start target/site/jacoco/index.html
```

---

## 📋 QUICK CHECKLIST

Trước khi chạy tests, đảm bảo:
- [ ] Java 11+ đã được cài đặt
- [ ] Maven 3.6+ đã được cài đặt  
- [ ] Dependencies đã được download (`mvn clean install`)
- [ ] Database H2 được configure trong test-persistence.xml

---

## 💡 TIPS & TRICKS

### Chạy Tests Nhanh Hơn
```bash
# Sử dụng parallel execution
mvn test -T 4

# Skip tests không cần thiết (cẩn thận!)
mvn test -Dtest=YourTest -DfailIfNoTests=false
```

### Debug Tests
```bash
# Verbose output
mvn test -X -Dtest=LoginServletIntegrationTest

# Chỉ chạy 1 test method
mvn test -Dtest=LoginServletIntegrationTest#testLoginSuccess
```

### Working với Coverage
```bash
# Coverage cho một module
mvn clean test -Dtest=com.liteflow.controller.auth.* jacoco:report

# Check coverage threshold
mvn clean verify
```

---

**Tạo ngày:** 31/10/2025  
**Cập nhật:** 31/10/2025  
**Status:** ✅ Complete - 74 Test Files Ready  
**Lệnh đơn giản nhất:** `mvn test`  
**Framework:** JUnit 5 + Mockito + H2

