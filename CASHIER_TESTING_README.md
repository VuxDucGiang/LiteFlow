# Cashier System - Unit Testing Guide

## Table of Contents
- [Overview](#overview)
- [Testing Architecture](#testing-architecture)
- [Test Environment Setup](#test-environment-setup)
- [Test Scope](#test-scope)
- [Test Categories](#test-categories)
- [Testing Framework & Tools](#testing-framework--tools)
- [Test Naming Conventions](#test-naming-conventions)
- [Test Case Structure](#test-case-structure)
- [Backend API Endpoints Testing](#backend-api-endpoints-testing)
- [Frontend JavaScript Functions Testing](#frontend-javascript-functions-testing)
- [Integration Testing Strategy](#integration-testing-strategy)
- [Data Fixtures & Test Data](#data-fixtures--test-data)
- [Expected Coverage Metrics](#expected-coverage-metrics)
- [Running Tests](#running-tests)
- [Troubleshooting](#troubleshooting)

---

## Overview

### Context
This document outlines the comprehensive unit testing strategy for the **Cashier System** (`cashier.jsp`) in the LiteFlow restaurant management application. The cashier interface is a critical point-of-sale (POS) component that handles:
- Table selection and management
- Menu browsing and item selection
- Order creation and modification
- Kitchen notifications
- Payment processing and checkout

The system follows a **JSP + Servlet + JavaScript** architecture with RESTful API endpoints for backend communication.

### Purpose
To ensure robust, reliable, and bug-free cashier operations through systematic testing of:
1. **Backend Servlets** - Business logic and data processing
2. **API Endpoints** - RESTful service layer
3. **Frontend JavaScript** - Client-side logic and UI interactions
4. **Integration Flows** - End-to-end user workflows

---

## Testing Architecture

```
┌─────────────────────────────────────────────┐
│         CASHIER SYSTEM TESTING              │
├─────────────────────────────────────────────┤
│                                             │
│  ┌───────────────────────────────────┐     │
│  │   UNIT TESTS (JUnit 5)            │     │
│  ├───────────────────────────────────┤     │
│  │ - Servlet Logic Tests             │     │
│  │ - DAO Layer Tests                 │     │
│  │ - Service Layer Tests             │     │
│  │ - Validation Tests                │     │
│  └───────────────────────────────────┘     │
│                                             │
│  ┌───────────────────────────────────┐     │
│  │   API TESTS (REST Assured)        │     │
│  ├───────────────────────────────────┤     │
│  │ - GET /api/cashier                │     │
│  │ - POST /api/order/create          │     │
│  │ - GET /api/order/table/{id}       │     │
│  │ - POST /api/checkout              │     │
│  └───────────────────────────────────┘     │
│                                             │
│  ┌───────────────────────────────────┐     │
│  │   FRONTEND TESTS (Jest/Jasmine)   │     │
│  ├───────────────────────────────────┤     │
│  │ - renderTables()                  │     │
│  │ - renderMenu()                    │     │
│  │ - addToCart()                     │     │
│  │ - updateQuantity()                │     │
│  │ - notifyKitchen()                 │     │
│  │ - checkout()                      │     │
│  └───────────────────────────────────┘     │
│                                             │
│  ┌───────────────────────────────────┐     │
│  │   INTEGRATION TESTS (Selenium)    │     │
│  ├───────────────────────────────────┤     │
│  │ - Complete order workflows        │     │
│  │ - Multi-table scenarios           │     │
│  │ - Payment processing flows        │     │
│  └───────────────────────────────────┘     │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Test Environment Setup

### Prerequisites
- **Java**: JDK 11 or higher
- **Maven**: 3.6+
- **JUnit**: 5.8.2+
- **Mockito**: 4.0+
- **REST Assured**: 5.0+ (for API testing)
- **Database**: MySQL 8.0+ or H2 (in-memory for testing)
- **Application Server**: Tomcat 9.0+ or Embedded Jetty

### Maven Dependencies
Required dependencies in `pom.xml`:
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
    
    <!-- REST Assured -->
    <dependency>
        <groupId>io.rest-assured</groupId>
        <artifactId>rest-assured</artifactId>
        <version>5.0.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- H2 Database for Testing -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <version>2.1.214</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Servlet API -->
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>4.0.1</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

---

## Test Scope

### In-Scope Components

#### Backend Components
1. **CashierServlet** (`com.liteflow.controller.CashierServlet`)
   - Initial data loading (tables, rooms, menu items, categories)
   - JSON serialization
   - Session management

2. **CreateOrderServlet** (`com.liteflow.controller.CreateOrderServlet`)
   - Order creation logic
   - Order item validation
   - Table status updates
   - Kitchen notification

3. **CheckoutServlet** (`com.liteflow.controller.CheckoutServlet`)
   - Payment processing
   - Order completion
   - Table status reset
   - Transaction management

4. **GetSessionOrdersServlet** (`com.liteflow.controller.GetSessionOrdersServlet`)
   - Retrieve orders by table ID
   - Order item aggregation
   - Status filtering

#### Frontend Components (JavaScript)
1. **Table Management Functions**
   - `renderTables()`
   - `populateRoomFilter()`
   - `loadTableOrders()`

2. **Menu Management Functions**
   - `renderMenu()`
   - `populateMenuCategories()`

3. **Order Management Functions**
   - `addToCart(variantId)`
   - `removeFromCart(variantId)`
   - `updateQuantity(variantId, newQuantity)`
   - `updateNote(variantId, note)`
   - `renderOrderItems()`
   - `updateBill()`

4. **Workflow Functions**
   - `notifyKitchen()`
   - `setupTabSystem()`
   - `setupEventListeners()`

#### Database Operations (DAO Layer)
- TableDAO
- MenuItemDAO
- OrderDAO
- ProductVariantDAO
- CategoryDAO

### Out-of-Scope
- UI/UX visual regression testing
- Performance/load testing (separate test suite)
- Security penetration testing
- Browser compatibility testing

---

## Test Categories

### 1. Happy Path Tests
Standard, expected user workflows with valid inputs:
- Select available table → Add menu items → Notify kitchen → Checkout
- Browse menu by category → Search items → Add to cart
- Load existing orders for occupied table → Add more items → Update order

### 2. Edge Cases
Boundary conditions and unusual but valid scenarios:
- Empty cart checkout attempt
- Maximum quantity limits
- Zero-priced items
- Special characters in notes
- Simultaneous table selection
- Filter combinations (all filters applied together)

### 3. Error Scenarios
Invalid inputs and error handling:
- Null pointer exceptions
- Invalid table IDs
- Non-existent menu items
- Database connection failures
- Network timeouts
- Malformed JSON responses
- Concurrent modification conflicts

### 4. State Transition Tests
Testing state changes in the system:
- Table status: Available → Occupied → Available
- Order status: New → Notified → Partial → Completed
- Cart state: Empty → Filled → Cleared

### 5. Integration Tests
End-to-end workflows:
- Complete order lifecycle
- Multi-table order management
- Payment method variations
- Order modification after kitchen notification

---

## Testing Framework & Tools

### Primary Framework: JUnit 5

**Key Features Used:**
- `@Test` - Individual test methods
- `@BeforeEach` - Setup before each test
- `@AfterEach` - Cleanup after each test
- `@BeforeAll` - One-time setup
- `@AfterAll` - One-time cleanup
- `@ParameterizedTest` - Data-driven tests
- `@DisplayName` - Descriptive test names
- `@Nested` - Grouped test classes
- `@Tag` - Test categorization

### Supporting Libraries

**Mockito** - Mocking framework
- Mock servlet request/response objects
- Mock database connections
- Mock external dependencies
- Spy on real objects

**AssertJ** - Fluent assertions
- More readable assertions
- Better error messages
- Rich API for collections and objects

**REST Assured** - API testing
- HTTP request/response testing
- JSON schema validation
- Response time assertions

**H2 Database** - In-memory database
- Fast test execution
- Isolated test data
- No external dependencies

---

## Test Naming Conventions

### Format
```
should_[ExpectedBehavior]_when_[Condition]()
```

### Examples

**Good Examples:**
```java
should_returnAllTables_when_noFilterApplied()
should_addItemToCart_when_tableIsSelected()
should_throwException_when_tableIdIsNull()
should_calculateTotalWithVAT_when_orderHasItems()
should_updateTableStatusToOccupied_when_orderIsCreated()
should_filterTablesByRoom_when_roomFilterIsApplied()
should_mergeOrderItems_when_sameVariantAddedTwice()
should_returnEmptyList_when_tableHasNoOrders()
should_resetTableStatus_when_checkoutIsSuccessful()
should_trackNotifiedQuantity_when_kitchenNotificationSent()
```

**Bad Examples (Avoid):**
```java
testAddToCart()              // Not descriptive
test1()                      // Meaningless name
addToCartTest()              // Wrong format
should_work()                // Too vague
testValidation()             // Unclear expectation
```

### Test Class Naming
```
[ClassName]Test
```

Examples:
- `CashierServletTest`
- `CreateOrderServletTest`
- `OrderDAOTest`
- `MenuRenderingTest`

---

## Test Case Structure

### AAA Pattern (Arrange-Act-Assert)

All tests follow this structure:

```java
@Test
@DisplayName("Should add item to cart when table is selected")
void should_addItemToCart_when_tableIsSelected() {
    // ARRANGE - Set up test data and preconditions
    String tableId = "table1";
    String variantId = "variant123";
    Table mockTable = createMockTable(tableId);
    MenuItem mockItem = createMockMenuItem(variantId);
    
    // ACT - Execute the method under test
    boolean result = cashierService.addToCart(tableId, variantId);
    
    // ASSERT - Verify the expected outcome
    assertTrue(result);
    assertEquals(1, orderService.getCartItems().size());
    assertEquals(variantId, orderService.getCartItems().get(0).getVariantId());
}
```

### Test Method Template

```java
@Test
@DisplayName("[Human-readable description of test case]")
void should_[expectedBehavior]_when_[condition]() {
    // Arrange
    // - Create test objects
    // - Set up mocks
    // - Define expected values
    
    // Act
    // - Call the method being tested
    
    // Assert
    // - Verify return values
    // - Verify state changes
    // - Verify mock interactions
}
```

---

## Backend API Endpoints Testing

### 1. GET /api/cashier

**Purpose:** Load initial cashier page data (tables, rooms, menu items, categories)

**Test Cases:**
- `should_returnTablesAndMenuData_when_requestIsValid()`
- `should_returnEmptyArrays_when_databaseIsEmpty()`
- `should_returnCorrectJSONStructure_when_dataExists()`
- `should_handleDatabaseException_when_connectionFails()`
- `should_setCorrectContentType_when_responseIsReturned()`
- `should_includeAllRooms_when_multiplRoomsExist()`
- `should_includeAllCategories_when_multipleCategoriesExist()`
- `should_filterActiveMenuItems_when_inactiveItemsExist()`

**Sample Test Structure:**
```java
@Nested
@DisplayName("GET /api/cashier Tests")
class CashierDataLoadingTests {
    
    private CashierServlet cashierServlet;
    private HttpServletRequest mockRequest;
    private HttpServletResponse mockResponse;
    private StringWriter responseWriter;
    
    @BeforeEach
    void setUp() {
        // Initialize mocks and test fixtures
    }
    
    @Test
    @DisplayName("Should return tables and menu data when request is valid")
    void should_returnTablesAndMenuData_when_requestIsValid() {
        // Arrange
        // Act
        // Assert
    }
    
    // Additional tests...
}
```

---

### 2. POST /api/order/create

**Purpose:** Create new order and notify kitchen

**Test Cases:**
- `should_createOrder_when_validDataProvided()`
- `should_generateOrderId_when_orderIsCreated()`
- `should_updateTableStatus_when_orderIsCreated()`
- `should_saveOrderItems_when_multipleItemsProvided()`
- `should_calculateSubtotal_when_itemsHavePrices()`
- `should_handleNotes_when_itemHasCustomNote()`
- `should_returnError_when_tableIdIsInvalid()`
- `should_returnError_when_itemsArrayIsEmpty()`
- `should_returnError_when_variantIdDoesNotExist()`
- `should_preventDuplicateOrders_when_concurrentRequestsOccur()`
- `should_trackNotifiedQuantity_when_partialOrderExists()`
- `should_addToExistingOrder_when_tableAlreadyHasOrder()`

**Request Payload Structure:**
```json
{
    "tableId": "table1",
    "items": [
        {
            "variantId": "variant123",
            "quantity": 2,
            "unitPrice": 50000,
            "note": "No onions"
        }
    ]
}
```

**Response Structure:**
```json
{
    "success": true,
    "message": "Order created successfully",
    "orderId": "ORD-20231024-001"
}
```

---

### 3. GET /api/order/table/{tableId}

**Purpose:** Retrieve existing orders for a specific table

**Test Cases:**
- `should_returnOrders_when_tableHasOrders()`
- `should_returnEmptyArray_when_tableHasNoOrders()`
- `should_aggregateOrderItems_when_sameVariantOrderedMultipleTimes()`
- `should_includeItemDetails_when_ordersExist()`
- `should_includeNotesAndStatus_when_available()`
- `should_returnError_when_tableIdIsInvalid()`
- `should_calculateTotalQuantity_when_multipleOrdersExist()`
- `should_excludeCompletedOrders_when_onlyActiveOrdersRequested()`

**Response Structure:**
```json
{
    "success": true,
    "orders": [
        {
            "productId": 1,
            "variantId": "variant123",
            "name": "Phở Bò",
            "size": "Large",
            "price": 50000,
            "quantity": 2,
            "status": "Preparing",
            "note": "No onions"
        }
    ]
}
```

---

### 4. POST /api/checkout

**Purpose:** Process payment and complete order

**Test Cases:**
- `should_completeCheckout_when_validDataProvided()`
- `should_updateOrderStatus_when_checkoutIsSuccessful()`
- `should_resetTableStatus_when_checkoutIsSuccessful()`
- `should_recordPaymentMethod_when_provided()`
- `should_calculateFinalTotal_when_checkoutInitiated()`
- `should_generateReceipt_when_checkoutCompleted()`
- `should_returnError_when_tableHasNoOrders()`
- `should_returnError_when_paymentMethodIsInvalid()`
- `should_handleTransactionRollback_when_errorOccurs()`
- `should_preventDoubleCheckout_when_alreadyCompleted()`

**Request Payload:**
```json
{
    "tableId": "table1",
    "paymentMethod": "cash"
}
```

**Response Structure:**
```json
{
    "success": true,
    "message": "Checkout successful",
    "receiptId": "RCP-20231024-001",
    "totalAmount": 110000
}
```

---

## Frontend JavaScript Functions Testing

### Table Management Functions

#### renderTables()
**Test Cases:**
- `should_displayAllTables_when_noFilterApplied()`
- `should_filterByStatus_when_statusFilterSelected()`
- `should_filterByRoom_when_roomFilterSelected()`
- `should_applyCombinedFilters_when_multipleFiltersActive()`
- `should_highlightSelectedTable_when_tableIsClicked()`
- `should_showEmptyMessage_when_noTablesMatchFilter()`
- `should_displayCorrectStatusBadge_when_tableStatusChanges()`
- `should_handleMissingRoomData_when_roomIsUndefined()`

#### populateRoomFilter()
**Test Cases:**
- `should_populateDropdown_when_roomsExist()`
- `should_includeAllRoomsOption_when_initialized()`
- `should_showFallbackOption_when_noRoomsInDatabase()`
- `should_sortRoomsByName_when_multipleRoomsExist()`

#### loadTableOrders()
**Test Cases:**
- `should_loadOrders_when_tableIsOccupied()`
- `should_mergeItems_when_sameVariantExistsMultipleTimes()`
- `should_setNotifiedQuantity_when_ordersLoadedFromDatabase()`
- `should_handleEmptyOrders_when_tableHasNoOrders()`
- `should_updateUI_when_ordersLoaded()`
- `should_handleAPIError_when_requestFails()`

---

### Menu Management Functions

#### renderMenu()
**Test Cases:**
- `should_displayAllItems_when_noCategorySelected()`
- `should_filterByCategory_when_categoryButtonClicked()`
- `should_filterBySearchTerm_when_userTypesInSearch()`
- `should_showEmptyMessage_when_noItemsMatch()`
- `should_displayItemWithSize_when_sizeIsAvailable()`
- `should_formatPrice_when_itemIsRendered()`
- `should_handleMissingImage_when_imageUrlNotProvided()`

#### populateMenuCategories()
**Test Cases:**
- `should_createCategoryButtons_when_categoriesExist()`
- `should_includeAllCategoriesOption_when_initialized()`
- `should_highlightActiveCategory_when_selected()`
- `should_attachEventListeners_when_buttonsCreated()`

---

### Order Management Functions

#### addToCart(variantId)
**Test Cases:**
- `should_addNewItem_when_itemNotInCart()`
- `should_incrementQuantity_when_itemAlreadyInCart()`
- `should_showAlert_when_noTableSelected()`
- `should_showAlert_when_variantIdIsInvalid()`
- `should_updateUI_when_itemAdded()`
- `should_calculateTotal_when_itemAdded()`
- `should_trackNotifiedQuantity_when_itemAlreadyNotified()`
- `should_displayItemWithSize_when_sizeIsAvailable()`

#### updateQuantity(variantId, newQuantity)
**Test Cases:**
- `should_updateQuantity_when_validQuantityProvided()`
- `should_removeItem_when_quantityIsZero()`
- `should_removeItem_when_quantityIsNegative()`
- `should_updateBill_when_quantityChanges()`
- `should_updateNotificationStatus_when_quantityIncreased()`

#### updateNote(variantId, note)
**Test Cases:**
- `should_saveNote_when_noteIsProvided()`
- `should_clearNote_when_emptyStringProvided()`
- `should_handleSpecialCharacters_when_noteContainsThem()`
- `should_logUpdate_when_noteIsChanged()`

#### renderOrderItems()
**Test Cases:**
- `should_showEmptyMessage_when_cartIsEmpty()`
- `should_displayAllItems_when_itemsExist()`
- `should_showNotifiedBadge_when_itemFullyNotified()`
- `should_showPartialBadge_when_itemPartiallyNotified()`
- `should_showNewBadge_when_itemNotNotified()`
- `should_displayQuantityControls_when_itemRendered()`
- `should_displayNoteInput_when_itemRendered()`
- `should_formatPrice_when_displaying()`

#### updateBill()
**Test Cases:**
- `should_calculateSubtotal_when_itemsExist()`
- `should_calculateVAT_when_subtotalCalculated()`
- `should_calculateTotal_when_VATAdded()`
- `should_formatCurrency_when_displaying()`
- `should_enableCheckoutButton_when_itemsExistAndTableSelected()`
- `should_disableCheckoutButton_when_cartIsEmpty()`
- `should_enableNotifyButton_when_itemsExistAndTableSelected()`

---

### Workflow Functions

#### notifyKitchen()
**Test Cases:**
- `should_sendToKitchen_when_newItemsExist()`
- `should_sendOnlyNewItems_when_someItemsAlreadyNotified()`
- `should_showAlert_when_allItemsAlreadyNotified()`
- `should_showAlert_when_cartIsEmpty()`
- `should_showAlert_when_noTableSelected()`
- `should_updateNotifiedQuantity_when_notificationSuccessful()`
- `should_displaySuccessMessage_when_notificationSent()`
- `should_handleAPIError_when_requestFails()`
- `should_includeNotes_when_itemsHaveNotes()`
- `should_renderOrderItems_when_notificationCompleted()`

#### setupTabSystem()
**Test Cases:**
- `should_switchToTablesTab_when_tablesButtonClicked()`
- `should_switchToMenuTab_when_menuButtonClicked()`
- `should_highlightActiveTab_when_tabSwitched()`
- `should_showCorrectPanel_when_tabSwitched()`

#### setupEventListeners()
**Test Cases:**
- `should_attachTableClickListener_when_initialized()`
- `should_attachFilterListeners_when_initialized()`
- `should_attachSearchListener_when_initialized()`
- `should_attachClearOrderListener_when_initialized()`
- `should_attachNotifyKitchenListener_when_initialized()`
- `should_attachCheckoutListener_when_initialized()`
- `should_attachPaymentMethodListeners_when_initialized()`

---

## Integration Testing Strategy

### End-to-End Test Scenarios

#### Scenario 1: Complete Order Flow (Happy Path)
**Steps:**
1. Load cashier page
2. Select available table
3. Browse menu
4. Add items to cart
5. Notify kitchen
6. Process checkout
7. Verify table status reset

**Expected Outcome:**
- Order created in database
- Table status updated (Available → Occupied → Available)
- Kitchen notified
- Payment recorded
- Receipt generated

---

#### Scenario 2: Modify Existing Order
**Steps:**
1. Select occupied table
2. Load existing orders
3. Add new items
4. Notify kitchen (only new items)
5. Verify partial notification

**Expected Outcome:**
- Existing items remain unchanged
- New items added to order
- Kitchen receives only new items
- Notification badges updated correctly

---

#### Scenario 3: Multi-Table Management
**Steps:**
1. Select Table A
2. Add items
3. Notify kitchen
4. Switch to Table B
5. Add different items
6. Verify orders are independent

**Expected Outcome:**
- Each table maintains separate order
- Switching tables doesn't mix orders
- Cart cleared when switching to empty table

---

#### Scenario 4: Error Recovery
**Steps:**
1. Simulate network failure
2. Attempt kitchen notification
3. Verify error handling
4. Retry after network restored
5. Verify successful retry

**Expected Outcome:**
- User-friendly error message displayed
- Order state preserved
- Successful retry after recovery

---

## Data Fixtures & Test Data

### Test Database Schema
Use H2 in-memory database with schema matching production:

```sql
-- Tables
CREATE TABLE room_table (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    room VARCHAR(100),
    capacity INT,
    status VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Product variants
CREATE TABLE product_variant (
    id VARCHAR(50) PRIMARY KEY,
    product_id INT,
    size VARCHAR(50),
    price DECIMAL(10,2),
    is_active BOOLEAN
);

-- Orders
CREATE TABLE orders (
    id VARCHAR(50) PRIMARY KEY,
    table_id VARCHAR(50),
    total_amount DECIMAL(10,2),
    status VARCHAR(20),
    created_at TIMESTAMP
);

-- Order items
CREATE TABLE order_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    variant_id VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    note TEXT,
    status VARCHAR(20)
);
```

### Sample Test Data

```java
public class TestDataFactory {
    
    public static Table createTestTable(String id, String status) {
        Table table = new Table();
        table.setId(id);
        table.setName("Table " + id);
        table.setRoom("Floor 1");
        table.setCapacity(4);
        table.setStatus(status);
        return table;
    }
    
    public static MenuItem createTestMenuItem(String variantId, String name, double price) {
        MenuItem item = new MenuItem();
        item.setVariantId(variantId);
        item.setName(name);
        item.setPrice(price);
        item.setCategory("Main Course");
        return item;
    }
    
    public static Order createTestOrder(String tableId, List<OrderItem> items) {
        Order order = new Order();
        order.setTableId(tableId);
        order.setItems(items);
        order.setStatus("Pending");
        return order;
    }
}
```

### Test Data Sets

**Minimal Set (Quick Tests):**
- 3 tables (2 available, 1 occupied)
- 2 rooms
- 5 menu items (3 categories)
- 1 active order

**Standard Set (Comprehensive Tests):**
- 10 tables (varying statuses)
- 3 rooms
- 20 menu items (5 categories)
- 5 active orders

**Stress Set (Performance Tests):**
- 100 tables
- 10 rooms
- 200 menu items
- 50 concurrent orders

---

## Expected Coverage Metrics

### Coverage Targets

| Component | Line Coverage | Branch Coverage | Method Coverage |
|-----------|--------------|-----------------|-----------------|
| Servlets | ≥ 85% | ≥ 80% | ≥ 90% |
| DAO Layer | ≥ 90% | ≥ 85% | ≥ 95% |
| Service Layer | ≥ 90% | ≥ 85% | ≥ 95% |
| Validators | ≥ 95% | ≥ 90% | 100% |
| **Overall** | **≥ 85%** | **≥ 80%** | **≥ 90%** |

### Critical Paths (Must be 100% Covered)
- Payment processing
- Order creation
- Table status updates
- Data validation
- Error handling

---

## Running Tests

### Run All Tests
```bash
mvn clean test
```

### Run Specific Test Class
```bash
mvn test -Dtest=CashierServletTest
```

### Run Tests with Coverage Report
```bash
mvn clean test jacoco:report
```
Coverage report will be generated at: `target/site/jacoco/index.html`

### Run Tests by Tag
```bash
# Run only unit tests
mvn test -Dgroups="unit"

# Run only integration tests
mvn test -Dgroups="integration"

# Run only API tests
mvn test -Dgroups="api"
```

### Run Tests in IDE
**IntelliJ IDEA:**
- Right-click on test class → Run
- Use shortcut: `Ctrl+Shift+F10` (Windows/Linux) or `Cmd+Shift+R` (Mac)

**Eclipse:**
- Right-click on test class → Run As → JUnit Test

---

## Troubleshooting

### Common Issues

#### 1. Database Connection Errors
**Problem:** `java.sql.SQLException: Connection refused`

**Solutions:**
- Verify H2 database is properly configured
- Check `persistence.xml` settings
- Ensure test database is created before tests run

```java
@BeforeAll
static void setupDatabase() {
    // Initialize H2 database
    DatabaseSetup.createSchema();
    DatabaseSetup.insertTestData();
}
```

---

#### 2. Mock Object Errors
**Problem:** `NullPointerException` when calling mocked methods

**Solutions:**
- Ensure mocks are initialized: `MockitoAnnotations.openMocks(this)`
- Define stub behavior: `when(mockObject.method()).thenReturn(value)`
- Verify mock creation: `assertNotNull(mockObject)`

```java
@BeforeEach
void setUp() {
    MockitoAnnotations.openMocks(this);
    when(mockRequest.getParameter("tableId")).thenReturn("table1");
}
```

---

#### 3. JSON Parsing Errors
**Problem:** `com.google.gson.JsonSyntaxException`

**Solutions:**
- Validate JSON structure in test data
- Use proper escaping for special characters
- Verify GSON version compatibility

```java
// Use typed response parsing
Gson gson = new Gson();
Response response = gson.fromJson(jsonString, Response.class);
```

---

#### 4. Concurrent Modification Exceptions
**Problem:** `ConcurrentModificationException` in collection tests

**Solutions:**
- Use thread-safe collections for concurrent tests
- Synchronize access to shared resources
- Use `CopyOnWriteArrayList` for test data

```java
List<Order> orders = new CopyOnWriteArrayList<>();
```

---

#### 5. Servlet Context Issues
**Problem:** `ServletContext` not available in tests

**Solutions:**
- Use `MockHttpServletRequest` and `MockHttpServletResponse`
- Initialize servlet context manually
- Use Spring Mock MVC for integration tests

```java
MockHttpServletRequest request = new MockHttpServletRequest();
MockHttpServletResponse response = new MockHttpServletResponse();
request.setServletContext(new MockServletContext());
```

---

## Test Documentation Standards

### Each Test Should Include:
1. **@DisplayName** - Clear description of what is being tested
2. **Comments** - Explain complex setup or assertions
3. **Meaningful variable names** - Self-documenting code
4. **Expected vs actual** - Clear assertion messages

### Example:
```java
@Test
@DisplayName("Should calculate total with 10% VAT when order has multiple items")
void should_calculateTotalWithVAT_when_orderHasMultipleItems() {
    // Arrange: Create order with known item prices
    Order order = new Order();
    order.addItem(createItem("item1", 100.00, 2)); // 200.00
    order.addItem(createItem("item2", 50.00, 3));  // 150.00
    // Subtotal: 350.00
    
    // Act: Calculate total
    double total = orderService.calculateTotal(order);
    
    // Assert: Verify VAT calculation (350 + 35 = 385)
    assertEquals(385.00, total, 0.01, 
        "Total should include 10% VAT on subtotal");
}
```

---

## Continuous Integration

### GitHub Actions Workflow
```yaml
name: Cashier Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up JDK 11
        uses: actions/setup-java@v2
        with:
          java-version: '11'
      - name: Run tests
        run: mvn clean test
      - name: Generate coverage report
        run: mvn jacoco:report
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v2
```

---

## Best Practices Summary

1. **Test Independence** - Each test should run independently
2. **Fast Execution** - Use in-memory database, minimize I/O
3. **Deterministic** - Tests should produce same results every time
4. **Readable** - Tests serve as documentation
5. **Maintainable** - Easy to update when code changes
6. **Comprehensive** - Cover happy paths, edge cases, and errors
7. **Isolated** - Mock external dependencies
8. **Automated** - Run in CI/CD pipeline

---

## Next Steps

1. **Phase 1:** Implement backend servlet tests (Week 1-2)
2. **Phase 2:** Implement DAO layer tests (Week 2-3)
3. **Phase 3:** Implement frontend JavaScript tests (Week 3-4)
4. **Phase 4:** Implement integration tests (Week 4-5)
5. **Phase 5:** Achieve target coverage metrics (Week 5-6)
6. **Phase 6:** CI/CD integration and automation (Week 6)

---

## References

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [REST Assured Documentation](https://rest-assured.io/)
- [AssertJ Documentation](https://assertj.github.io/doc/)
- [Maven Surefire Plugin](https://maven.apache.org/surefire/maven-surefire-plugin/)
- [JaCoCo Java Code Coverage](https://www.jacoco.org/jacoco/trunk/doc/)

---

## Contact & Support

For questions or issues with testing:
- Project Lead: [Your Name]
- QA Team: [QA Team Email]
- Documentation: [Wiki Link]

---

**Document Version:** 1.0  
**Last Updated:** October 24, 2025  
**Author:** LiteFlow Development Team

