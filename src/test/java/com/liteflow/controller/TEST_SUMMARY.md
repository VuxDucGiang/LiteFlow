# CreateOrderServletTest - Test Summary

## Tổng quan
File test cho `CreateOrderServlet` với **15 test cases** bao gồm Happy Path, Edge Cases, và Error Scenarios.

## Cấu trúc Test

### Setup (@BeforeEach)
- Khởi tạo mocks (MockitoAnnotations)
- Tạo servlet instance
- Inject mocked OrderService bằng reflection
- Setup response writer để capture output

### Dependencies
- **JUnit 5**: Framework test chính
- **Mockito**: Mocking framework
- **Jakarta Servlet API**: Servlet API (không phải javax)
- **Gson**: JSON parsing

---

## Test Cases (15 total)

### ✅ HAPPY PATH TESTS (4 tests)

#### 1. `should_createOrderSuccessfully_when_validDataProvided()`
**Mục đích:** Test tạo order thành công với dữ liệu hợp lệ

**Kiểm tra:**
- Response content type là `application/json`
- Response charset là `UTF-8`
- OrderService được gọi với đúng tham số
- Status code là `201 (SC_CREATED)`
- Response chứa `"success":true` và `orderId`

---

#### 2. `should_generateOrderId_when_orderIsCreated()`
**Mục đích:** Verify rằng order ID được generate khi tạo order

**Kiểm tra:**
- OrderService được gọi để tạo order
- Response chứa UUID của order được tạo

---

#### 3. `should_saveMultipleOrderItems_when_multipleItemsProvided()`
**Mục đích:** Test lưu nhiều items trong một order

**Kiểm tra:**
- OrderService nhận đúng 2 items trong request
- Cả 2 items đều được process

---

#### 4. `should_sendProperStatusCode_when_orderCreatedSuccessfully()`
**Mục đích:** Verify status code khi tạo order thành công

**Kiểm tra:**
- Status code trả về là `201 (SC_CREATED)`
- OrderService được gọi thành công

---

### 🔄 EDGE CASES (4 tests)

#### 5. `should_handleSpecialCharactersInNote_when_noteContainsSpecialChars()`
**Mục đích:** Test xử lý ký tự đặc biệt trong note

**Kiểm tra:**
- Servlet không throw exception với special chars (`@#$%`)
- OrderService được gọi bình thường

---

#### 6. `should_handleEmptyNote_when_noteIsNotProvided()`
**Mục đích:** Test xử lý khi note rỗng

**Kiểm tra:**
- OrderService chấp nhận note rỗng
- Response thành công

---

#### 7. `should_handleMaximumQuantity_when_quantityIsAtLimit()`
**Mục đích:** Test xử lý quantity ở mức maximum (99)

**Kiểm tra:**
- OrderService nhận đúng quantity = 99
- Không có lỗi khi quantity lớn

---

### ❌ ERROR SCENARIOS (7 tests)

#### 8. `should_returnError_when_tableIdIsNull()`
**Mục đích:** Test xử lý khi tableId = null

**Kiểm tra:**
- Response chứa `"success":false`
- OrderService KHÔNG được gọi
- Lỗi validation được bắt

---

#### 9. `should_returnError_when_itemsArrayIsEmpty()`
**Mục đích:** Test xử lý khi danh sách items rỗng

**Kiểm tra:**
- Response chứa `"success":false`
- OrderService KHÔNG được gọi
- Validate items không rỗng

---

#### 10. `should_returnError_when_tableIdIsInvalidUUID()`
**Mục đích:** Test xử lý khi tableId không phải UUID hợp lệ

**Kiểm tra:**
- Response chứa `"success":false`
- OrderService KHÔNG được gọi
- Validate UUID format

---

#### 11. `should_returnError_when_tableIdIsEmptyString()`
**Mục đích:** Test xử lý khi tableId là chuỗi rỗng

**Kiểm tra:**
- Response chứa `"success":false`
- Response chứa thông báo lỗi về "Table ID"
- OrderService KHÔNG được gọi

---

#### 12. `should_handleServiceException_when_orderCreationFails()`
**Mục đích:** Test xử lý khi OrderService throw RuntimeException

**Kiểm tra:**
- Response chứa `"success":false`
- Status code là `500 (Internal Server Error)`
- Exception được handle gracefully

---

#### 13. `should_handleMalformedJSON_when_requestBodyIsInvalid()`
**Mục đích:** Test xử lý khi JSON không hợp lệ

**Kiểm tra:**
- Response chứa `"success":false`
- OrderService KHÔNG được gọi
- Không throw unchecked exception

---

#### 14. `should_handleIllegalArgumentException_when_serviceThrowsValidationError()`
**Mục đích:** Test xử lý IllegalArgumentException từ service layer

**Kiểm tra:**
- Response chứa `"success":false`
- Response chứa message từ exception ("Validation failed")
- Status code là `400 (Bad Request)`

---

#### 15. `should_returnJSONResponseFormat_when_requestIsProcessed()`
**Mục đích:** Verify format của JSON response

**Kiểm tra:**
- Content type là `application/json`
- Charset là `UTF-8`
- Response có đúng structure: `success`, `message`, `orderId`
- JSON parse được bằng Gson

---

## Cách chạy tests

### Chạy tất cả tests
```bash
mvn test
```

### Chạy riêng test class này
```bash
mvn test -Dtest=CreateOrderServletTest
```

### Chạy một test method cụ thể
```bash
mvn test -Dtest=CreateOrderServletTest#should_createOrderSuccessfully_when_validDataProvided
```

### Chạy với coverage report
```bash
mvn clean test jacoco:report
```

---

## Test Naming Convention

Tất cả tests đều follow format:
```
should_[expected_behavior]_when_[condition]()
```

**Ví dụ:**
- `should_createOrderSuccessfully_when_validDataProvided()`
- `should_returnError_when_tableIdIsNull()`

---

## Test Structure (AAA Pattern)

Mỗi test đều follow cấu trúc:

```java
@Test
@DisplayName("Mô tả test case")
void should_expectedBehavior_when_condition() throws Exception {
    // ARRANGE - Setup test data
    UUID tableId = UUID.randomUUID();
    String requestBody = "{ ... }";
    when(mockOrderService.method()).thenReturn(result);
    
    // ACT - Execute method under test
    servlet.doPost(mockRequest, mockResponse);
    
    // ASSERT - Verify expected outcomes
    verify(mockOrderService).method();
    assertTrue(response.contains("expected"));
}
```

---

## Coverage Summary

| Category | Test Count | Percentage |
|----------|-----------|------------|
| Happy Path | 4 | 27% |
| Edge Cases | 4 | 27% |
| Error Scenarios | 7 | 46% |
| **TOTAL** | **15** | **100%** |

---

## Key Testing Techniques Used

1. **Mocking** - Mock HttpServletRequest, HttpServletResponse, OrderService
2. **Reflection** - Inject mocked dependencies vào servlet
3. **Verification** - Verify method calls với Mockito
4. **Assertions** - assertTrue, assertEquals, assertNotNull, assertDoesNotThrow
5. **Exception Testing** - Test exception handling với when().thenThrow()
6. **JSON Validation** - Parse và validate JSON response structure

---

## Dependencies Required

Thêm vào `pom.xml`:

```xml
<dependencies>
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter-api</artifactId>
        <version>5.8.2</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <version>4.0.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Jakarta Servlet API -->
    <dependency>
        <groupId>jakarta.servlet</groupId>
        <artifactId>jakarta.servlet-api</artifactId>
        <version>5.0.0</version>
        <scope>provided</scope>
    </dependency>
    
    <!-- Gson -->
    <dependency>
        <groupId>com.google.code.gson</groupId>
        <artifactId>gson</artifactId>
        <version>2.8.9</version>
    </dependency>
</dependencies>
```

---

## Tác giả
Generated theo CASHIER_TESTING_README.md specification

**Ngày tạo:** October 24, 2025

