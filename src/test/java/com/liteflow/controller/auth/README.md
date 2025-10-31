# Module 1: Authentication & RBAC - Integration Tests

## 📋 OVERVIEW

This directory contains integration tests for the Authentication & RBAC module of LiteFlow.

**Created:** 31/10/2025  
**Framework:** JUnit 5 (Jupiter) + Mockito  
**Database:** H2 in-memory (MSSQLServer mode)  
**Coverage:** 15 PR2 test cases + ~55 additional tests

---

## 📁 STRUCTURE

```
controller/auth/
├── LoginServletIntegrationTest.java            (7 tests)
├── OAuth2CallbackServletIntegrationTest.java   (6 tests)
├── VerifyOtpServletIntegrationTest.java        (7 tests)
├── SignupServletIntegrationTest.java           (7 tests)
├── LogoutServletIntegrationTest.java           (6 tests)
├── SendOtpServletIntegrationTest.java          (7 tests)
├── ForgotPasswordServletIntegrationTest.java   (6 tests)
├── ResetPasswordServletIntegrationTest.java    (8 tests)
└── RefreshServletIntegrationTest.java          (7 tests)
```

**Total:** 9 test classes, ~61 test methods

---

## 🎯 TEST CASES COVERED (PR2)

### Happy Path
- ✅ TC-HP-001: Login successfully with email/password
- ✅ TC-HP-002: Login with Google OAuth2
- ✅ TC-HP-003: 2FA verification success
- ✅ TC-HP-006: Logout and invalidate session

### Edge Cases
- ✅ TC-EDGE-001: Login with password typo

### Error Scenarios
- ✅ TC-ERR-001: Login with non-existent user
- ✅ TC-ERR-002: 2FA verification with wrong code
- ✅ TC-ERR-003: OAuth with invalid token
- ✅ TC-ERR-004: Database connection lost
- ✅ TC-ERR-005: Signup with weak password

---

## 🚀 RUNNING TESTS

### Run all controller/auth tests
```bash
mvn test -Dtest="com.liteflow.controller.auth.*"
```

### Run specific test class
```bash
mvn test -Dtest=LoginServletIntegrationTest
```

### Run specific test method
```bash
mvn test -Dtest=LoginServletIntegrationTest#testLoginSuccess
```

### Run with coverage
```bash
mvn clean test jacoco:report
```

---

## 🛠️ TEST UTILITIES

### Test Data Builders
```java
// In your test method
User user = TestDataBuilder.buildUser("test@liteflow.com", "ADMIN");
Role role = TestDataBuilder.buildRole("ADMIN");
UserRole userRole = TestDataBuilder.buildUserRole(user, role);
```

### Test Scenarios
```java
// Create full auth scenario
TestScenarios.SimpleAuthScenario scenario = 
    TestScenarios.createSimpleAuthScenario(em, "test@liteflow.com", "USER");

// Access entities
User user = scenario.user;
Role role = scenario.role;
UserSession session = scenario.session;
```

### Mock HTTP Objects
```java
// Mock POST request
String json = ServletTestHelper.json("email", "test@test.com", "password", "Test@123");
HttpServletRequest req = ServletTestHelper.mockPostRequest(json);

// Mock response
HttpServletResponse resp = ServletTestHelper.mockResponse();

// Get response body
String responseBody = ServletTestHelper.getResponseBody(resp);
```

---

## 📝 WRITING NEW TESTS

### Template
```java
@DisplayName("Your Test Description")
@Test
public void testYourFeature() throws Exception {
    // Arrange: Setup test data
    TestScenarios.SimpleAuthScenario scenario = 
        TestScenarios.createSimpleAuthScenario(em, "user@test.com", "USER");
    
    String requestBody = ServletTestHelper.json(
        "email", "user@test.com",
        "password", "Test@123"
    );
    
    HttpServletRequest req = ServletTestHelper.mockPostRequest(requestBody);
    HttpServletResponse resp = ServletTestHelper.mockResponse();
    
    // Act: Execute servlet
    servlet.doPost(req, resp);
    
    // Assert: Verify behavior
    verify(resp).setStatus(HttpServletResponse.SC_OK);
    
    String responseBody = ServletTestHelper.getResponseBody(resp);
    assertTrue(responseBody.contains("success"));
    
    // Verify database changes
    em.refresh(scenario.user);
    assertNotNull(scenario.user.getPasswordHash());
}
```

---

## 🔍 COMMON PATTERNS

### 1. Testing Database Operations
```java
// Create entity
User user = TestDataBuilder.buildUser("test@test.com", "USER");
em.persist(user);
em.flush();

// Verify in database
Long count = em.createQuery("SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
    .setParameter("email", "test@test.com")
    .getSingleResult();
assertEquals(1, count);

// Update entity
em.refresh(user);
user.setIsActive(false);
em.merge(user);
em.flush();
```

### 2. Testing Servlet Behavior
```java
// Verify status code
verify(resp).setStatus(HttpServletResponse.SC_OK);

// Verify redirect
verify(resp).sendRedirect(contains("/login"));

// Verify response content
String body = ServletTestHelper.getResponseBody(resp);
assertTrue(body.contains("success"));
```

### 3. Testing Session Management
```java
// Mock session
HttpSession session = req.getSession();
when(session.getAttribute("userId")).thenReturn(user.getUserID().toString());

// Verify session invalidation
verify(session).invalidate();
```

---

## ⚠️ IMPORTANT NOTES

### Transaction Management
- Each test runs in its own transaction
- Transactions auto-rollback after each test
- Use `em.flush()` to force SQL execution
- Use `em.refresh(entity)` to reload from database

### Test Isolation
- Tests run independently
- No shared state between tests
- Each test creates its own data

### Mocking Strategy
- External services (Email, OAuth, Payment) are MOCKED
- Database operations are REAL (H2)
- Servlet objects are MOCKED

---

## 🐛 TROUBLESHOOTING

### Issue: EntityManager not closing
**Solution:** Ensure test extends `IntegrationTestBase`

### Issue: Transaction not rolling back
**Solution:** Don't manually commit in tests (unless testing commit behavior)

### Issue: Mock not working
**Solution:** Check Mockito imports: `import static org.mockito.Mockito.*;`

### Issue: Test data not found
**Solution:** Call `em.flush()` after `em.persist()`

---

## 📚 REFERENCES

- [IntegrationTestBase](../../helpers/base/IntegrationTestBase.java)
- [TestDataBuilder](../../helpers/builders/TestDataBuilder.java)
- [ServletTestHelper](../../helpers/mocks/ServletTestHelper.java)
- [TestScenarios](../../helpers/base/TestScenarios.java)

---

**Author:** AI Assistant  
**Date:** 31/10/2025  
**Status:** ✅ Complete

