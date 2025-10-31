# LiteFlow Integration Tests

## 📋 OVERVIEW

This directory contains integration tests for the LiteFlow restaurant management system.

**Framework:** JUnit 5 (Jupiter) + Mockito  
**Database:** H2 in-memory (MSSQLServer mode)  
**Strategy:** Test-driven development with full integration coverage

---

## 📁 DIRECTORY STRUCTURE

```
src/test/java/com/liteflow/
├── controller/auth/          # Module 1: Authentication & RBAC (9 files, ~61 tests)
├── filter/                   # Filter tests (3 files, ~24 tests)
├── helpers/                  # Test utilities
│   ├── base/                # Base classes & scenarios
│   │   ├── IntegrationTestBase.java
│   │   └── TestScenarios.java
│   ├── builders/            # Test data builders
│   │   └── TestDataBuilder.java
│   └── mocks/              # Mock helpers
│       ├── MockServiceHelper.java
│       └── ServletTestHelper.java
└── service/auth/            # Service layer tests (coming soon)

src/test/resources/
├── META-INF/
│   └── test-persistence.xml     # JPA configuration
├── application-test.properties   # Test properties
└── mock-responses/              # Mock JSON data
```

---

## 🎯 MODULES & STATUS

| Module | Status | Test Files | Test Cases | Coverage |
|--------|--------|------------|------------|----------|
| **Module 1: Auth & RBAC** | ✅ Complete | 12 | ~70 | TBD |
| **Module 2: Cashier/POS** | 🚧 Pending | 0 | 22 | - |
| **Module 3: Inventory** | 🚧 Pending | 0 | 17 | - |
| **Module 4: Employee** | 🚧 Pending | 0 | 14 | - |
| **Module 5: Reservation** | 🚧 Pending | 0 | 10 | - |
| **Module 6: Procurement** | 🚧 Pending | 0 | 7 | - |

**Total:** 85 test cases from PR2 + additional coverage

---

## 🚀 QUICK START

### Prerequisites
```xml
<!-- Add to pom.xml -->
<dependencies>
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <version>5.5.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- H2 Database -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <version>2.2.224</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Run Tests
```bash
# Run all tests
mvn test

# Run specific module
mvn test -Dtest="com.liteflow.controller.auth.*"

# Run with coverage
mvn clean test jacoco:report
```

---

## 🛠️ TEST UTILITIES

### 1. IntegrationTestBase
Base class for all integration tests. Provides:
- EntityManager lifecycle management
- Automatic transaction rollback
- H2 database setup/teardown

```java
public class MyTest extends IntegrationTestBase {
    @Test
    public void testSomething() {
        // 'em' (EntityManager) is available
        User user = TestDataBuilder.buildUser("test@test.com", "USER");
        em.persist(user);
        em.flush();
        
        // Assert...
    }
}
```

### 2. TestDataBuilder
Fluent builders for all entities:
```java
// User
User user = TestDataBuilder.buildUser("email@test.com", "ADMIN");
User googleUser = TestDataBuilder.buildGoogleUser("email@gmail.com", "googleId123");
User user2FA = TestDataBuilder.buildUserWith2FA("email@test.com", "secret");

// Role & UserRole
Role role = TestDataBuilder.buildRole("ADMIN");
UserRole userRole = TestDataBuilder.buildUserRole(user, role);

// Session
UserSession session = TestDataBuilder.buildSession(user);
UserSession expiredSession = TestDataBuilder.buildExpiredSession(user);

// OTP
OtpToken otp = TestDataBuilder.buildOtpToken(user, "123456");
```

### 3. TestScenarios
Pre-built complex scenarios:
```java
// Simple: 1 user + 1 role + 1 session
SimpleAuthScenario scenario = TestScenarios.createSimpleAuthScenario(em, "user@test.com", "USER");

// Full: 4 users + 4 roles + sessions
AuthTestScenario fullScenario = TestScenarios.createAuthScenario(em);
User admin = fullScenario.adminUser;
User cashier = fullScenario.cashierUser;

// 2FA
TwoFactorAuthScenario twoFA = TestScenarios.create2FAScenario(em);

// OAuth
OAuthScenario oauth = TestScenarios.createOAuthScenario(em);
```

### 4. ServletTestHelper
Mock HTTP objects:
```java
// Request
String json = ServletTestHelper.json("key1", "value1", "key2", "value2");
HttpServletRequest req = ServletTestHelper.mockPostRequest(json);
HttpServletRequest getReq = ServletTestHelper.mockGetRequest();

// Response
HttpServletResponse resp = ServletTestHelper.mockResponse();
String responseBody = ServletTestHelper.getResponseBody(resp);

// Session
HttpSession session = req.getSession();
```

### 5. MockServiceHelper
Mock external services:
```java
// OTP
OtpService otpService = MockServiceHelper.mockOtpServiceSuccess();

// OAuth
GoogleOAuth2User oauthUser = MockServiceHelper.mockOAuthSuccess();

// Payment
PaymentResponse payment = MockServiceHelper.mockPaymentSuccess();
```

---

## 📝 WRITING TESTS

### Test Template
```java
package com.liteflow.controller.auth;

import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.helpers.base.TestScenarios;
import com.liteflow.helpers.builders.TestDataBuilder;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@DisplayName("MyServlet Integration Tests")
@Tag("integration")
public class MyServletIntegrationTest extends IntegrationTestBase {
    
    private MyServlet servlet;
    
    @Override
    public void setUp() {
        super.setUp();
        servlet = new MyServlet();
    }
    
    @Test
    @DisplayName("TC-XXX: Test description")
    public void testFeature() throws Exception {
        // Arrange
        TestScenarios.SimpleAuthScenario scenario = 
            TestScenarios.createSimpleAuthScenario(em, "test@test.com", "USER");
        
        String requestBody = ServletTestHelper.json("param", "value");
        HttpServletRequest req = ServletTestHelper.mockPostRequest(requestBody);
        HttpServletResponse resp = ServletTestHelper.mockResponse();
        
        // Act
        servlet.doPost(req, resp);
        
        // Assert
        verify(resp).setStatus(HttpServletResponse.SC_OK);
        
        String responseBody = ServletTestHelper.getResponseBody(resp);
        assertTrue(responseBody.contains("success"));
        
        // Verify database
        em.refresh(scenario.user);
        assertNotNull(scenario.user);
    }
}
```

---

## 🔍 BEST PRACTICES

### 1. Test Isolation
- Each test is independent
- No shared state
- Auto rollback after each test

### 2. Arrange-Act-Assert
```java
// Arrange: Setup data
User user = TestDataBuilder.buildUser(...);

// Act: Execute operation
servlet.doPost(req, resp);

// Assert: Verify results
verify(resp).setStatus(200);
```

### 3. Test Naming
```java
// Good
public void testLoginSuccessWithValidCredentials() { }
public void testLoginFailsWithInvalidPassword() { }

// Bad
public void test1() { }
public void testLogin() { }
```

### 4. Use DisplayName
```java
@Test
@DisplayName("TC-HP-001: Login successfully with email and password")
public void testLoginSuccess() { }
```

### 5. Database Operations
```java
// Persist
em.persist(entity);
em.flush(); // Force SQL execution

// Refresh
em.refresh(entity); // Reload from DB

// Query
Long count = em.createQuery("SELECT COUNT(u) FROM User u", Long.class)
    .getSingleResult();
```

---

## ⚠️ COMMON ISSUES

### Issue: EntityManager closed
**Cause:** Test doesn't extend IntegrationTestBase  
**Solution:** Extend IntegrationTestBase

### Issue: Transaction not rolling back
**Cause:** Manual commit in test  
**Solution:** Don't call em.getTransaction().commit()

### Issue: Test data not found
**Cause:** Forgot to call em.flush()  
**Solution:** Call em.flush() after em.persist()

### Issue: Mock not working
**Cause:** Wrong import  
**Solution:** `import static org.mockito.Mockito.*;`

---

## 📊 COVERAGE

### Current Status
- **Module 1 (Auth):** ~70 tests created
- **Total Coverage:** TBD (run `mvn test jacoco:report`)

### Target
- Overall: ≥70%
- Controller Layer: 75-80%
- Service Layer: 80-85%
- Critical Paths: 100%

---

## 📚 REFERENCES

### Documentation
- [PR2: Test Case Matrix](../../../prompts/outputs_2/Output_PR2.md)
- [PR3: Directory Structure](../../../prompts/outputs_2/Output_PR3.md)
- [PR4 Summary](../../../prompts/outputs_2/Output_PR4_Module1_Summary.md)

### External
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [H2 Database](http://www.h2database.com/html/main.html)

---

## 📞 SUPPORT

**Issues?** Check:
1. This README
2. Module-specific README (e.g., controller/auth/README.md)
3. Helper class JavaDocs
4. PR2/PR3 documentation

---

**Status:** 🚧 In Progress  
**Last Updated:** 31/10/2025  
**Next:** Module 2 (Cashier/POS)

