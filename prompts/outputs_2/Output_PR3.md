## PR3 — CẤU TRÚC THƯ MỤC & MAPPING TEST CASES

### TỔNG QUAN
**Mục tiêu:** Thiết kế cấu trúc thư mục test Integration Testing tuân thủ Maven Standard  
**Phạm vi:** Mapping 85 test cases từ PR2 vào cấu trúc module rõ ràng  
**Chiến lược dữ liệu:** Sử dụng Test Builders & Mocks thay vì SQL seed files

---

## 📂 PHẦN 1: SOURCE CODE & MODULE ANALYSIS

### 1.1. Module Nghiệp Vụ Chính (6 modules)

| Module | Main Components | Test Priority |
|--------|----------------|---------------|
| **Authentication & RBAC** | `web/auth/*`, `filter/*`, `AuthService` | Critical |
| **Cashier/POS Order** | `CashierServlet`, `OrderService`, `PaymentService` | Critical |
| **Inventory** | `ProductServlet`, `InventoryService`, `ExcelService` | High |
| **Employee** | `EmployeeServlet`, `AttendanceServlet`, `TimesheetService` | Medium |
| **Reservation** | `ReceptionServlet`, `ReservationService`, `TableService` | Medium |
| **Procurement** | `web/procurement/*`, `ProcurementService` | Low |

---

## 📂 PHẦN 2: CẤU TRÚC THƯ MỤC TEST

### 2.1. Tổng Quan Structure

```
src/test/java/com/liteflow/
├── controller/          # Servlet Integration Tests
│   ├── auth/           (9 files - TC-HP-001 to TC-ERR-005)
│   ├── cashier/        (7 files - TC-HP-007 to TC-ERR-011)
│   ├── inventory/      (4 files - TC-HP-017 to TC-ERR-016)
│   ├── employee/       (8 files - TC-HP-024 to TC-ERR-020)
│   ├── reservation/    (5 files - TC-HP-030 to TC-ERR-023)
│   └── procurement/    (5 files - TC-HP-034 to TC-ERR-025)
│
├── service/            # Service Layer Integration Tests
│   ├── auth/          (5 files)
│   ├── order/         (4 files)
│   ├── inventory/     (4 files)
│   ├── employee/      (6 files)
│   └── procurement/   (3 files)
│
├── integration/        # E2E & Special Tests
│   ├── e2e/           (3 files - critical flows)
│   ├── transaction/   (2 files - rollback scenarios)
│   └── concurrency/   (2 files - race conditions)
│
├── filter/            (3 files - auth/session)
│
└── helpers/           # Test Utilities
    ├── builders/      (Test data builders)
    ├── mocks/         (External service mocks)
    └── base/          (Base test classes)

src/test/resources/
├── test-persistence.xml
├── application-test.properties
└── mock-responses/    (JSON mock data)
```

### 2.2. Chi Tiết Files Theo Module

**Module 1: Authentication & RBAC (15 TCs → 9 files)**
- `controller/auth/`: LoginServlet, OAuth2, Logout, OTP, Signup (9 files)
- `filter/`: AuthenticationFilter, AuthorizationFilter, Session (3 files)

**Module 2: Cashier/POS Order (22 TCs → 11 files)**
- `controller/cashier/`: CreateOrder, Payment, Receipt, SplitPayment (7 files)
- `controller/kitchen/`: KitchenServlet, OrderStatusUpdate (2 files)
- `service/order/`: OrderService, PaymentService, PromotionService (4 files)

**Module 3: Inventory (17 TCs → 8 files)**
- `controller/inventory/`: ProductServlet, StockUpdate, ExcelImportExport (4 files)
- `service/inventory/`: ProductService, InventoryService, AlertService (4 files)

**Module 4: Employee (14 TCs → 14 files)**
- `controller/employee/`: Employee, Attendance, Timesheet, Schedule, Compensation (8 files)
- `service/employee/`: EmployeeService, AttendanceService, PayrollService (6 files)

**Module 5: Reservation (10 TCs → 8 files)**
- `controller/reservation/`: ReceptionServlet, ReservationCreate/CheckIn/Cancel (5 files)
- `service/reservation/`: ReservationService, TableAvailability (3 files)

**Module 6: Procurement (7 TCs → 8 files)**
- `controller/procurement/`: PurchaseOrder, GoodsReceipt, Invoice (5 files)
- `service/procurement/`: ProcurementService, InvoiceMatching (3 files)

---

## 🗂️ PHẦN 3: TEST CASE MAPPING & NAMING

### 3.1. Quy Tắc Đặt Tên

| Loại Test | Pattern | Ví dụ |
|-----------|---------|-------|
| **Integration Test** | `<Class>IntegrationTest.java` | `OrderServiceIntegrationTest.java` |
| **E2E Test** | `<Feature>E2ETest.java` | `OrderFlowE2ETest.java` |
| **Special Tests** | `<Feature>ConcurrencyTest.java` | `StockConcurrencyTest.java` |

### 3.2. Tổng Hợp Mapping (85 TCs → 58 Files)

| Module | Happy Path | Edge Cases | Errors | Total TCs | Test Files |
|--------|-----------|------------|--------|-----------|------------|
| **Auth & RBAC** | 6 | 4 | 5 | 15 | 12 files |
| **Cashier/POS** | 10 | 6 | 6 | 22 | 11 files |
| **Inventory** | 7 | 5 | 5 | 17 | 8 files |
| **Employee** | 6 | 4 | 4 | 14 | 14 files |
| **Reservation** | 4 | 3 | 3 | 10 | 8 files |
| **Procurement** | 3 | 2 | 2 | 7 | 8 files |
| **E2E/Special** | - | - | - | - | 7 files |
| **TOTAL** | **36** | **24** | **25** | **85** | **~68 files**

---

## 🗂️ PHẦN 4: CHIẾN LƯỢC TẠO DỮ LIỆU TEST

### 4.1. Test Resources (Minimal)

```
src/test/resources/
├── META-INF/test-persistence.xml       # H2 in-memory config
├── application-test.properties         # Test configs
└── mock-responses/                     # JSON mock data
    ├── payment-success.json
    ├── oauth-response.json
    └── email-notification.json
```

### 4.2. Test Persistence Config

```xml
<persistence-unit name="LiteFlowTestPU">
    <properties>
        <property name="jakarta.persistence.jdbc.driver" value="org.h2.Driver"/>
        <property name="jakarta.persistence.jdbc.url" 
                  value="jdbc:h2:mem:testdb;MODE=MSSQLServer"/>
        <property name="hibernate.hbm2ddl.auto" value="create-drop"/>
        <property name="hibernate.show_sql" value="false"/>
    </properties>
</persistence-unit>
```

### 4.3. Test Properties

```properties
# Mock External Services
mock.payment.gateway=true
mock.email.service=true
mock.oauth.service=true

# Coverage
jacoco.output=target/jacoco-integration
```

---

## 📐 PHẦN 5: TEST DATA BUILDERS & HELPERS

### 5.1. IntegrationTestBase.java - Base Class

```java
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public abstract class IntegrationTestBase {
    protected static EntityManagerFactory emf;
    protected EntityManager em;
    
    @BeforeAll
    public static void setUpClass() {
        emf = Persistence.createEntityManagerFactory("LiteFlowTestPU");
    }
    
    @BeforeEach
    public void setUp() {
        em = emf.createEntityManager();
        em.getTransaction().begin();
    }
    
    @AfterEach
    public void tearDown() {
        if (em.getTransaction().isActive()) {
            em.getTransaction().rollback();
        }
        em.close();
    }
}
```

### 5.2. TestDataBuilder.java - Builders cho mọi Entity

```java
public class TestDataBuilder {
    
    // === AUTH MODULE ===
    public static User buildUser(String email, String role) {
        return User.builder()
            .userId(UUID.randomUUID())
            .email(email)
            .passwordHash("$2a$10$test.hash")
            .displayName("Test " + role)
            .isActive(true)
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    public static Role buildRole(String name) {
        return Role.builder()
            .roleId(UUID.randomUUID())
            .name(name)
            .description("Test role " + name)
            .build();
    }
    
    public static UserSession buildSession(User user) {
        return UserSession.builder()
            .sessionId(UUID.randomUUID())
            .user(user)
            .token("test_jwt_token_" + UUID.randomUUID())
            .status("ACTIVE")
            .createdAt(LocalDateTime.now())
            .expiresAt(LocalDateTime.now().plusHours(8))
            .build();
    }
    
    // === ORDER MODULE ===
    public static Order buildOrder(String tableId, String status) {
        return Order.builder()
            .orderId(UUID.randomUUID())
            .tableId(tableId)
            .orderType("DINE_IN")
            .status(status)
            .totalAmount(0.0)
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    public static OrderItem buildOrderItem(Order order, Product product, int qty) {
        return OrderItem.builder()
            .order(order)
            .product(product)
            .quantity(qty)
            .unitPrice(product.getUnitPrice())
            .subtotal(product.getUnitPrice() * qty)
            .build();
    }
    
    public static Payment buildPayment(Order order, String method) {
        return Payment.builder()
            .paymentId(UUID.randomUUID())
            .order(order)
            .paymentMethod(method)
            .amount(order.getTotalAmount())
            .status("COMPLETED")
            .paidAt(LocalDateTime.now())
            .build();
    }
    
    // === INVENTORY MODULE ===
    public static Product buildProduct(String name, double price, int stock) {
        return Product.builder()
            .productId(UUID.randomUUID())
            .name(name)
            .sku("SKU-" + UUID.randomUUID().toString().substring(0, 8))
            .unitPrice(price)
            .costPrice(price * 0.6)
            .stockQuantity(stock)
            .minStockLevel(20)
            .isActive(true)
            .build();
    }
    
    // === EMPLOYEE MODULE ===
    public static Employee buildEmployee(User user, String department) {
        return Employee.builder()
            .user(user)
            .employeeCode("EMP-" + UUID.randomUUID().toString().substring(0, 6))
            .department(department)
            .salary(8000000.0)
            .hireDate(LocalDate.now())
            .status("ACTIVE")
            .build();
    }
    
    public static Attendance buildAttendance(Employee emp, LocalDateTime checkIn) {
        return Attendance.builder()
            .attendanceId(UUID.randomUUID())
            .employee(emp)
            .checkInTime(checkIn)
            .checkOutTime(checkIn.plusHours(8))
            .workHours(8.0)
            .build();
    }
    
    // === RESERVATION MODULE ===
    public static Reservation buildReservation(Table table, LocalDateTime time) {
        return Reservation.builder()
            .reservationId(UUID.randomUUID())
            .table(table)
            .reservationTime(time)
            .numberOfGuests(4)
            .customerPhone("+84901234567")
            .status("CONFIRMED")
            .build();
    }
    
    public static Table buildTable(int number, int capacity) {
        return Table.builder()
            .tableId(UUID.randomUUID())
            .tableNumber(number)
            .capacity(capacity)
            .status("AVAILABLE")
            .build();
    }
    
    // === PROCUREMENT MODULE ===
    public static PurchaseOrder buildPurchaseOrder(Supplier supplier) {
        return PurchaseOrder.builder()
            .poId(UUID.randomUUID())
            .poNumber("PO-2025-" + (int)(Math.random()*1000))
            .supplier(supplier)
            .status("PENDING")
            .totalAmount(0.0)
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    public static Supplier buildSupplier(String name) {
        return Supplier.builder()
            .supplierId(UUID.randomUUID())
            .name(name)
            .contactPerson("Contact " + name)
            .phone("+84912345678")
            .isActive(true)
            .build();
    }
}
```

### 5.3. MockServiceHelper.java - External Service Mocks

```java
public class MockServiceHelper {
    
    public static PaymentGatewayService mockPaymentSuccess() {
        PaymentGatewayService mock = mock(PaymentGatewayService.class);
        when(mock.processPayment(any())).thenReturn(
            PaymentResponse.success("txn_" + UUID.randomUUID(), "Approved")
        );
        return mock;
    }
    
    public static PaymentGatewayService mockPaymentTimeout() {
        PaymentGatewayService mock = mock(PaymentGatewayService.class);
        when(mock.processPayment(any())).thenThrow(
            new TimeoutException("Gateway timeout")
        );
        return mock;
    }
    
    public static EmailService mockEmailService() {
        EmailService mock = mock(EmailService.class);
        doNothing().when(mock).sendEmail(anyString(), anyString(), anyString());
        return mock;
    }
    
    public static OAuth2Service mockOAuthSuccess() {
        OAuth2Service mock = mock(OAuth2Service.class);
        when(mock.verifyToken(anyString())).thenReturn(
            OAuth2User.builder()
                .googleId("1234567890")
                .email("test@gmail.com")
                .displayName("Test User")
                .build()
        );
        return mock;
    }
}
```

### 5.4. ServletTestHelper.java - HTTP Mocking

```java
public class ServletTestHelper {
    
    public static HttpServletRequest mockRequest(String method, String json) {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getMethod()).thenReturn(method);
        when(req.getReader()).thenReturn(
            new BufferedReader(new StringReader(json))
        );
        return req;
    }
    
    public static HttpServletResponse mockResponse() {
        HttpServletResponse resp = mock(HttpServletResponse.class);
        StringWriter writer = new StringWriter();
        try {
            when(resp.getWriter()).thenReturn(new PrintWriter(writer));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return resp;
    }
    
    public static String getResponseBody(HttpServletResponse resp) {
        return resp.getWriter().toString();
    }
}
```

### 5.5. TestScenarios.java - Complex Scenarios

```java
public class TestScenarios {
    
    // Tạo full scenario cho test
    public static OrderTestScenario createOrderScenario(EntityManager em) {
        // 1. Create users & roles
        Role cashierRole = TestDataBuilder.buildRole("CASHIER");
        User cashier = TestDataBuilder.buildUser("cashier@test.com", "CASHIER");
        em.persist(cashierRole);
        em.persist(cashier);
        
        // 2. Create products
        Product p1 = TestDataBuilder.buildProduct("Coffee", 45000, 100);
        Product p2 = TestDataBuilder.buildProduct("Tea", 35000, 80);
        em.persist(p1);
        em.persist(p2);
        
        // 3. Create table
        Table table = TestDataBuilder.buildTable(1, 4);
        em.persist(table);
        
        em.flush();
        
        return new OrderTestScenario(cashier, table, Arrays.asList(p1, p2));
    }
    
    public static EmployeeTestScenario createEmployeeScenario(EntityManager em) {
        Role managerRole = TestDataBuilder.buildRole("MANAGER");
        User manager = TestDataBuilder.buildUser("manager@test.com", "MANAGER");
        em.persist(managerRole);
        em.persist(manager);
        
        Employee emp = TestDataBuilder.buildEmployee(manager, "Kitchen");
        em.persist(emp);
        em.flush();
        
        return new EmployeeTestScenario(manager, emp);
    }
}
```

---

## 📊 PHẦN 6: LỢI ÍCH & COVERAGE

### 6.1. Lợi Ích Thiết Kế

| Khía cạnh | Lợi ích |
|-----------|---------|
| **Builder Pattern** | Tạo test data linh hoạt, không cần SQL |
| **Mock Services** | Kiểm soát external dependencies, test error cases |
| **Test Scenarios** | Tái sử dụng setup phức tạp across tests |
| **Phân module** | Chạy tests theo module, dễ maintain |
| **H2 + create-drop** | Test isolation, mỗi test độc lập |

### 6.2. Coverage Ước Tính

| Layer | Test Files | Coverage Target |
|-------|-----------|-----------------|
| Controller | ~38 files | 75-80% |
| Service | ~22 files | 80-85% |
| Integration/E2E | ~7 files | 100% critical paths |
| **TOTAL** | **~68 files** | **≥70% overall** |

---

## 📋 PHẦN 7: CHECKLIST TRIỂN KHAI

### Setup (Phase 1)
- [ ] Tạo test directory structure
- [ ] Setup `test-persistence.xml` (H2 in-memory)
- [ ] Implement `IntegrationTestBase.java`

### Helpers (Phase 2)
- [ ] Implement `TestDataBuilder.java` (all entities)
- [ ] Implement `MockServiceHelper.java`
- [ ] Implement `ServletTestHelper.java`
- [ ] Implement `TestScenarios.java`

### Implementation (Phase 3 - theo priority)
1. **Auth & RBAC** (15 TCs) - Critical
2. **Cashier/POS** (22 TCs) - Critical
3. **Inventory** (17 TCs) - High
4. **Employee** (14 TCs) - Medium
5. **Reservation** (10 TCs) - Medium
6. **Procurement** (7 TCs) - Low

### E2E & CI/CD (Phase 4)
- [ ] E2E flow tests (3 critical flows)
- [ ] Transaction & concurrency tests
- [ ] Configure JaCoCo coverage
- [ ] CI pipeline integration

---

## 🎯 TÓM TẮT

### Điểm Nổi Bật
✅ **No SQL seed files** - Dùng builders/mocks để generate data  
✅ **85 test cases → 68 test files** - Mapping rõ ràng  
✅ **Builder cho mọi entity** - User, Product, Order, Employee, etc.  
✅ **Mock external services** - Payment, Email, OAuth  
✅ **Test scenarios** - Complex setups reusable  

### Metrics
- **Total Files:** ~68 integration test files
- **Coverage Target:** ≥70% (Servlet + Service layers)
- **Execution Time:** ~8-12 minutes

### Bước Tiếp Theo
**PR4:** Implement test code theo cấu trúc này  
**PR5:** Run tests & collect coverage reports  
**PR6:** Final report & recommendations