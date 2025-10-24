# AI Prompt Log

## Prompt 001: Create Unit Tests for CreateOrderServlet

### Context (Background):
I am working on the **LiteFlow** project - a restaurant management system with cashier functionality. The project uses **Jakarta EE** with servlets for handling HTTP requests. Currently, I need to test the `CreateOrderServlet` class located at `src/main/java/com/liteflow/controller/CreateOrderServlet.java`.

The servlet has the following characteristics:
- **Framework**: Jakarta Servlet API (not javax)
- **Dependencies**: Uses `OrderService` for business logic
- **HTTP Method**: POST endpoint at `/api/order/create`
- **Input**: JSON request body with `tableId` (UUID) and `items` array
- **Output**: JSON response with `success`, `message`, and `orderId` fields
- **Key Functionality**: 
  - Validates table ID (UUID format, not null, not empty)
  - Validates items array (not null, not empty)
  - Creates order through OrderService
  - Returns appropriate HTTP status codes (201 for success, 400 for validation errors, 500 for server errors)

### Task (Requirements):
Based on the functions described in the **CASHIER_TESTING_README.md** documentation, write a comprehensive test file for `CreateOrderServlet` using **JUnit 5** and **Mockito** framework.

Create the test file at: `src/test/java/com/liteflow/controller/CreateOrderServletTest.java`

The test suite should cover:
- **Happy Path scenarios** - normal successful operations
- **Edge Cases** - boundary conditions and special inputs
- **Error Scenarios** - validation failures and exception handling

### Requirements (Detailed Specifications):

**Test Structure:**
- Use **JUnit 5** (not JUnit 4) with annotations: `@Test`, `@BeforeEach`, `@DisplayName`
- Use **Mockito** for mocking: `HttpServletRequest`, `HttpServletResponse`, `OrderService`
- Apply **AAA Pattern** (Arrange - Act - Assert) in each test method
- Use **Reflection** to inject mocked `OrderService` into the servlet

**Naming Convention:**
- Follow the format: `should_[expected_behavior]_when_[condition]()`
- Examples:
  - `should_createOrderSuccessfully_when_validDataProvided()`
  - `should_returnError_when_tableIdIsNull()`

**Test Setup:**
- Use `@BeforeEach` to initialize mocks and setup common test fixtures
- Initialize `MockitoAnnotations.openMocks(this)`
- Setup response writer to capture servlet output
- Inject mocked dependencies using reflection

**Test Coverage:**
- Minimum **15 test cases** (maximum 15)
- At least **4 Happy Path tests**
- At least **3 Edge Case tests**
- At least **7 Error Scenario tests**

**Assertion Requirements:**
- Each test must include appropriate assertions:
  - `assertTrue()`, `assertFalse()` for boolean conditions
  - `assertEquals()` for value comparisons
  - `assertNotNull()` for null checks
  - `assertDoesNotThrow()` for exception handling validation
- Use Mockito's `verify()` to ensure correct method calls
- Use `argThat()` for complex argument matching

**Specific Test Scenarios to Cover:**

*Happy Path:*
1. Create order successfully with valid data
2. Generate unique order ID when order is created
3. Save multiple order items when multiple items provided
4. Send proper HTTP status code (201) when successful

*Edge Cases:*
1. Handle special characters in note field
2. Handle empty note when not provided
3. Handle maximum quantity values
4. Process orders with multiple items

*Error Scenarios:*
1. Return error when table ID is null
2. Return error when items array is empty
3. Return error when table ID is invalid UUID format
4. Return error when table ID is empty string
5. Handle service exceptions gracefully
6. Handle malformed JSON in request body
7. Handle IllegalArgumentException from service layer
8. Validate proper JSON response format

### Expected Output Format:

**File Structure:**
```java
package com.liteflow.controller;

// Imports
import com.google.gson.Gson;
import com.liteflow.service.OrderService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
// ... other imports

@DisplayName("CreateOrderServlet Tests")
class CreateOrderServletTest {
    // Mock declarations
    private CreateOrderServlet servlet;
    @Mock private HttpServletRequest mockRequest;
    @Mock private HttpServletResponse mockResponse;
    @Mock private OrderService mockOrderService;
    
    @BeforeEach
    void setUp() throws Exception {
        // Setup code
    }
    
    @Test
    @DisplayName("Test description")
    void should_behavior_when_condition() throws Exception {
        // ARRANGE
        // ... setup test data
        
        // ACT
        // ... execute method under test
        
        // ASSERT
        // ... verify expectations
    }
}
```

**Each test should include:**
1. `@Test` annotation
2. `@DisplayName` with clear description
3. Method name following naming convention
4. AAA structure with comments
5. Appropriate assertions and verifications

**Documentation:**
- Create a summary document at: `src/test/java/com/liteflow/controller/TEST_SUMMARY.md`
- Include:
  - List of all test cases with descriptions
  - How to run tests (Maven commands)
  - Test coverage breakdown by category
  - Key testing techniques used

### Example (Sample Output):

**Example Test Case 1 - Happy Path:**
```java
@Test
@DisplayName("Should create order successfully when valid data is provided")
void should_createOrderSuccessfully_when_validDataProvided() throws Exception {
    // ARRANGE
    UUID tableId = UUID.randomUUID();
    UUID orderId = UUID.randomUUID();
    
    String requestBody = "{"
            + "\"tableId\":\"" + tableId + "\","
            + "\"items\":["
            + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":2,\"unitPrice\":50000,\"note\":\"No onions\"}"
            + "]"
            + "}";
    
    BufferedReader reader = new BufferedReader(new StringReader(requestBody));
    when(mockRequest.getReader()).thenReturn(reader);
    when(mockOrderService.createOrderAndNotifyKitchen(eq(tableId), anyList(), any())).thenReturn(orderId);
    
    // ACT
    servlet.doPost(mockRequest, mockResponse);
    
    // ASSERT
    verify(mockResponse).setContentType("application/json");
    verify(mockResponse).setCharacterEncoding("UTF-8");
    verify(mockOrderService).createOrderAndNotifyKitchen(eq(tableId), anyList(), any());
    verify(mockResponse).setStatus(HttpServletResponse.SC_CREATED);
    
    printWriter.flush();
    String response = responseWriter.toString();
    assertTrue(response.contains("\"success\":true"));
    assertTrue(response.contains(orderId.toString()));
}
```

**Purpose:** Validates that the servlet correctly processes a valid order request, calls the service layer with appropriate parameters, and returns a successful JSON response with the created order ID.

---

**Example Test Case 2 - Error Scenario:**
```java
@Test
@DisplayName("Should return error when table ID is null")
void should_returnError_when_tableIdIsNull() throws Exception {
    // ARRANGE
    String requestBody = "{"
            + "\"tableId\":null,"
            + "\"items\":["
            + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
            + "]"
            + "}";
    
    when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
    
    // ACT
    servlet.doPost(mockRequest, mockResponse);
    
    // ASSERT
    printWriter.flush();
    String response = responseWriter.toString();
    assertTrue(response.contains("\"success\":false"));
    verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), anyList(), any());
}
```

**Purpose:** Ensures that the servlet properly validates the table ID field and returns an error response when it is null, without calling the service layer.

---

**Example Test Case 3 - Edge Case:**
```java
@Test
@DisplayName("Should handle special characters in note when note contains special chars")
void should_handleSpecialCharactersInNote_when_noteContainsSpecialChars() throws Exception {
    // ARRANGE
    UUID tableId = UUID.randomUUID();
    String specialNote = "Extra spicy! @#$%";
    String requestBody = "{"
            + "\"tableId\":\"" + tableId + "\","
            + "\"items\":["
            + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":40000,"
            + "   \"note\":\"" + specialNote + "\"}"
            + "]"
            + "}";
    
    when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
    when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(UUID.randomUUID());
    
    // ACT & ASSERT
    assertDoesNotThrow(() -> servlet.doPost(mockRequest, mockResponse));
    verify(mockOrderService).createOrderAndNotifyKitchen(any(UUID.class), anyList(), any());
}
```

**Purpose:** Tests the servlet's ability to handle special characters in user input (note field) without throwing exceptions or failing to process the request.

---

### Additional Notes:

**Dependencies Required:**
- JUnit Jupiter API 5.10.0+
- Mockito Core 4.0.0+
- Jakarta Servlet API (provided scope)
- Gson for JSON parsing

**Testing Best Practices Applied:**
1. **Isolation**: Each test is independent and can run in any order
2. **Mocking**: External dependencies are mocked to focus on servlet logic
3. **Clarity**: Clear test names and DisplayName annotations
4. **Coverage**: Comprehensive coverage of success, failure, and edge cases
5. **Maintainability**: Well-structured code following AAA pattern
6. **Verification**: Both state and behavior verification using assertions and mocks

**Commands to Run Tests:**
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=CreateOrderServletTest

# Run with coverage report
mvn clean test jacoco:report

# Run a single test method
mvn test -Dtest=CreateOrderServletTest#should_createOrderSuccessfully_when_validDataProvided
```

---

### Result Summary:

**Deliverables Created:**
1. ✅ `CreateOrderServletTest.java` - 15 comprehensive test cases
2. ✅ `TEST_SUMMARY.md` - Detailed documentation of all tests

**Test Execution Results:**
- ✅ Tests run: 15
- ✅ Failures: 0
- ✅ Errors: 0
- ✅ Skipped: 0
- ⏱️ Time elapsed: ~5.8 seconds

**Test Distribution:**
- Happy Path Tests: 4 (27%)
- Edge Case Tests: 4 (27%)
- Error Scenario Tests: 7 (46%)
- **Total: 15 tests (100% pass rate)**

---

*Date Created:* October 24, 2025  
*Project:* LiteFlow Restaurant Management System  
*Module:* Cashier Order Management  
*Status:* ✅ Completed Successfully

