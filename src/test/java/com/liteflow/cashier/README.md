# 🧪 Cashier Order Test Suite - User Guide

## 📖 Overview

This directory contains comprehensive unit tests for the **Cashier Order** feature in the LiteFlow restaurant management system. The test suite validates order creation, input validation, error handling, and security features.

**Target Feature:** Cashier Order Management  
**Main Servlet:** `CreateOrderServlet`  
**Test Coverage:** 97% (doPost method: 100%)  
**Framework:** JUnit 5 + Mockito + Jakarta EE  

---

## 📋 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [Installation](#-installation)
3. [Running Tests](#-running-tests)
4. [Test Structure](#-test-structure)
5. [Test Results](#-test-results)
6. [Coverage Report](#-coverage-report)
7. [AI Prompts Summary](#-ai-prompts-summary)
8. [Troubleshooting](#-troubleshooting)
9. [Additional Resources](#-additional-resources)

---

## ⚙️ Prerequisites

Before running the tests, ensure you have:

### Required Software
- **Java Development Kit (JDK) 16+**
  - Verify: `java -version`
  - Download: [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://adoptium.net/)

- **Apache Maven 3.8+**
  - Verify: `mvn -version`
  - Download: [Apache Maven](https://maven.apache.org/download.cgi)

- **Git** (for cloning the repository)
  - Verify: `git --version`
  - Download: [Git SCM](https://git-scm.com/)

### Environment Setup
```bash
# Set JAVA_HOME (Windows)
set JAVA_HOME=C:\Program Files\Java\jdk-16

# Set JAVA_HOME (Linux/Mac)
export JAVA_HOME=/usr/lib/jvm/java-16-openjdk

# Add Maven to PATH
set PATH=%PATH%;C:\path\to\maven\bin  # Windows
export PATH=$PATH:/path/to/maven/bin  # Linux/Mac
```

---

## 📦 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/LiteFlow.git
cd LiteFlow
```

### 2. Install Dependencies
```bash
mvn clean install
```

This will download all required dependencies:
- JUnit Jupiter 5.10.0
- Mockito 5.5.0
- Jakarta Servlet API 5.0.0
- Gson 2.10.1
- JaCoCo 0.8.10

### 3. Verify Installation
```bash
mvn dependency:tree
```

Check that all test dependencies are present:
- `junit-jupiter-api`
- `mockito-core`
- `mockito-junit-jupiter`
- `jakarta.servlet-api`

---

## 🚀 Running Tests

### Quick Start - Run All Tests
```bash
mvn test
```

### Run Only Cashier Tests
```bash
mvn test -Dtest=CreateOrderServletTest
```

### Run with Detailed Output
```bash
mvn test -Dtest=CreateOrderServletTest -X
```

### Run Specific Test Method
```bash
# Run single test
mvn test -Dtest=CreateOrderServletTest#should_createOrder_when_validSingleItem

# Run multiple tests matching pattern
mvn test -Dtest=CreateOrderServletTest#should_createOrder*
```

### Run with Coverage Report
```bash
# Run tests and generate JaCoCo coverage report
mvn clean test jacoco:report

# Open coverage report
# Windows
start target/site/jacoco/index.html

# Linux/Mac
open target/site/jacoco/index.html
```

### Run in Quiet Mode (Less Verbose)
```bash
mvn test -Dtest=CreateOrderServletTest -q
```

### Run with UTF-8 Encoding (for Vietnamese characters)
```bash
mvn test -Dtest=CreateOrderServletTest -Dfile.encoding=UTF-8
```

### Run Tests in IDE

#### IntelliJ IDEA
1. Right-click on `CreateOrderServletTest.java`
2. Select "Run 'CreateOrderServletTest'"
3. Or press `Ctrl+Shift+F10` (Windows) / `Cmd+Shift+R` (Mac)

#### Eclipse
1. Right-click on `CreateOrderServletTest.java`
2. Select "Run As" → "JUnit Test"
3. Or press `Alt+Shift+X, T`

#### VS Code
1. Install "Test Runner for Java" extension
2. Click the play button next to test class or method
3. Or use Command Palette: "Java: Run Tests"

---

## 📁 Test Structure

### Directory Layout
```
src/test/java/com/liteflow/cashier/
├── CreateOrderServletTest.java       # Main test suite (20 tests)
├── OrderTestHelper.java               # Reusable test utilities
├── CreateOrderServletTestExample.java # Example usage (reference only)
├── TEST_SUMMARY.md                    # Detailed test report
└── README.md                          # This file
```

### Test Organization

#### CreateOrderServletTest.java
Main test class containing 20 test cases organized into:

1. **Happy Path Tests (4)** - Valid order creation scenarios
2. **Edge Case Tests (4)** - Boundary conditions and special cases
3. **Error Scenario Tests (7)** - Input validation and error handling
4. **Real-World Security Tests (5)** - Production vulnerability testing
5. **Infrastructure Tests (1)** - HTTP protocol compliance (CORS)

#### OrderTestHelper.java
Utility class providing:
- Mock setup methods (`setupResponseWriter`, `prepareRequestBody`)
- JSON builders (`buildOrderJson`, `buildMalformedJson`)
- Service mock configuration (`mockSuccessfulOrderCreation`)
- Assertion helpers (`assertSuccessResponse`, `assertBadRequestResponse`)
- Verification helpers (`verifyServiceCalledOnce`, `verifyCORSHeaders`)
- Test data builders (`OrderItemBuilder` with fluent API)

---

## 📊 Test Results

### Summary
```
Tests run: 20
✅ Passed: 20
❌ Failed: 0
⏭️ Skipped: 0
Success Rate: 100%
```

### Test Breakdown by Category

| Category | Tests | Status | Coverage |
|----------|-------|--------|----------|
| Happy Path | 4 | ✅ All Pass | 100% |
| Edge Cases | 4 | ✅ All Pass | 100% |
| Error Scenarios | 7 | ✅ All Pass | 100% |
| Security Tests | 5 | ✅ All Pass | 100% |
| Infrastructure | 1 | ✅ All Pass | 100% |

### Detailed Results

#### ✅ Happy Path Tests
- `TC-HP-001`: Create order with single item ✅
- `TC-HP-002`: Create order with multiple items ✅
- `TC-HP-003`: Create order with Vietnamese note ✅
- `TC-HP-004`: Create order with decimal price ✅

#### ✅ Edge Case Tests
- `TC-EDGE-001`: Handle large order (50 items) ✅
- `TC-EDGE-002`: Handle zero quantity ✅
- `TC-EDGE-003`: Handle duplicate items ✅
- `TC-EDGE-004`: Handle very long note (1000+ chars) ✅

#### ✅ Error Scenario Tests
- `TC-ERR-001`: Reject missing tableId ✅
- `TC-ERR-002`: Reject empty items array ✅
- `TC-ERR-003`: Reject invalid UUID format ✅
- `TC-ERR-004`: Handle null request body ✅
- `TC-ERR-005`: Reject missing required fields ✅
- `TC-ERR-006`: Handle validation errors ✅
- `TC-ERR-007`: Handle service runtime exceptions ✅

#### ✅ Security Tests (Real-World)
- `TC-REAL-001`: Block negative price attacks ✅
- `TC-REAL-002`: Handle Vietnamese + emoji properly ✅
- `TC-REAL-003`: Detect data type mismatches ✅
- `TC-REAL-004`: Handle malformed JSON ✅
- `TC-REAL-005`: Prevent duplicate submissions ✅

#### ✅ Infrastructure Tests
- `TC-INFRA-001`: Verify CORS preflight headers ✅

---

## 📈 Coverage Report

### Overall Coverage: 97%

| Metric | Coverage | Details |
|--------|----------|---------|
| **Line Coverage** | 96.6% | 57 of 59 lines covered |
| **Branch Coverage** | 100% | 12 of 12 branches covered |
| **Complexity Coverage** | 90.9% | 10 of 11 paths covered |
| **Method Coverage** | 80% | 4 of 5 methods covered |

### Method-Level Coverage

| Method | Coverage | Lines | Branches | Notes |
|--------|----------|-------|----------|-------|
| `doPost()` | ✅ 100% | 45/45 | 12/12 | Fully covered |
| `doOptions()` | ✅ 100% | 5/5 | 0/0 | Fully covered |
| `sendErrorResponse()` | ✅ 100% | 6/6 | 0/0 | Fully covered |
| `CreateOrderServlet()` | ✅ 100% | 1/1 | 0/0 | Constructor |
| `init()` | ❌ 0% | 0/2 | 0/0 | Not tested (container lifecycle) |

> **Note:** The `init()` method is not covered because it's only called by the servlet container during deployment, not during unit tests. This is expected and does not impact production code quality.

### View Full Coverage Report
```bash
# Generate report
mvn clean test jacoco:report

# Open in browser
start target/site/jacoco/index.html  # Windows
open target/site/jacoco/index.html   # Mac/Linux
```

---

## 🤖 AI Prompts Summary

This test suite was developed using an AI-assisted testing workflow with 6 major prompts:

### Prompt 1: Initial Analysis & Planning
**Goal:** Analyze the Cashier Order feature and create a comprehensive test plan.

**Output:** `prompts/outputs/Output_PR1.md`

**Key Deliverables:**
- Feature analysis (business logic, data flow)
- Test objectives and scope
- Test strategy (Unit, Integration, Mock Services)
- Test environment and tools (JUnit 5, Mockito)
- Test case grouping (Happy Path, Edge Cases, Errors)
- Edge scenarios and real-world cases
- Risks and assumptions
- Documentation plan

### Prompt 2: Basic Test Case Design
**Goal:** Create a detailed test case matrix with 15 basic test cases.

**Output:** `prompts/outputs/Output_PR2.md`

**Key Deliverables:**
- 4 Happy Path test cases
- 4 Edge Case test cases
- 7 Error Scenario test cases
- Complete test case details (ID, Description, Input Data, Expected Output, Mock Behavior)

### Prompt 3: Real-World Scenarios Design
**Goal:** Design 5 critical real-world test cases based on production risks.

**Output:** `prompts/outputs/Output_PR3.md`

**Key Deliverables:**
- Security vulnerability tests (negative price, SQL injection)
- Unicode/emoji handling tests
- Data type mismatch tests
- Network problem tests (malformed JSON)
- User behavior tests (double-click prevention)

### Prompt 4: Test Code Generation
**Goal:** Generate complete, compilable test code for all 20 test cases.

**Output:** `CreateOrderServletTest.java`

**Key Deliverables:**
- Full test class with JUnit 5 and Mockito
- AAA pattern (Arrange-Act-Assert)
- Reflection for protected method access
- Mock configuration (HttpServletRequest, HttpServletResponse, OrderService)
- Comprehensive assertions

### Prompt 5: Helper Methods Creation
**Goal:** Create reusable helper methods to reduce code duplication.

**Output:** `OrderTestHelper.java`

**Key Deliverables:**
- Mock setup utilities
- JSON builders
- Service mock configuration
- Assertion helpers
- Verification helpers
- Fluent test data builder (`OrderItemBuilder`)

### Prompt 6: Debug and Optimize
**Goal:** Debug and optimize the test suite to ensure all tests pass.

**Key Deliverables:**
- Fixed compilation errors (Jakarta vs Javax APIs)
- Fixed mock configuration issues (unnecessary stubbing)
- Resolved reflection access issues
- Optimized test performance
- Cleaned up code duplication
- UTF-8 encoding configuration

### AI Workflow Benefits
- ✅ **Comprehensive Planning:** Systematic approach from analysis to implementation
- ✅ **High Coverage:** 97% code coverage achieved
- ✅ **Real-World Focus:** Security and production scenarios included
- ✅ **Maintainable Code:** Helper methods and builders reduce duplication
- ✅ **Best Practices:** AAA pattern, descriptive naming, test isolation
- ✅ **Complete Documentation:** Test plans, summaries, and this README

---

## 🔧 Troubleshooting

### Issue 1: Tests Fail to Compile
**Symptom:**
```
[ERROR] Cannot find symbol: class ExtendWith
```

**Solution:**
Ensure `mockito-junit-jupiter` dependency is in `pom.xml`:
```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-junit-jupiter</artifactId>
    <version>5.5.0</version>
    <scope>test</scope>
</dependency>
```

Then run: `mvn clean install`

---

### Issue 2: Vietnamese Characters Display as `?`
**Symptom:**
```
? Nh?n request t?o order
```

**Solution:**
This is a console display issue, not a code bug. The Java code correctly handles UTF-8. To fix console display:

**Option A:** Run Maven with UTF-8 encoding:
```bash
mvn test -Dfile.encoding=UTF-8
```

**Option B:** Configure `pom.xml`:
```xml
<plugin>
    <groupId>org.apache.maven.surefire</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
        <argLine>-Dfile.encoding=UTF-8</argLine>
    </configuration>
</plugin>
```

**Option C:** Change Windows PowerShell encoding:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
```

---

### Issue 3: UnnecessaryStubbingException
**Symptom:**
```
org.mockito.exceptions.misusing.UnnecessaryStubbingException
```

**Solution:**
This occurs when a mock is configured but not used. The test suite has been fixed to only set up `PrintWriter` in tests that actually need it.

If you see this in new tests, move the `setupResponseWriter()` call from `@BeforeEach` to the specific test method.

---

### Issue 4: Method Not Accessible (IllegalAccessException)
**Symptom:**
```
java.lang.IllegalAccessException: can not access a member of class CreateOrderServlet
```

**Solution:**
The servlet methods `doPost()` and `doOptions()` are protected. Use reflection:
```java
private void callDoPost(HttpServletRequest req, HttpServletResponse resp) throws Exception {
    Method doPostMethod = CreateOrderServlet.class.getDeclaredMethod("doPost", 
        HttpServletRequest.class, HttpServletResponse.class);
    doPostMethod.setAccessible(true);
    doPostMethod.invoke(servlet, req, resp);
}
```

This is already implemented in `CreateOrderServletTest`.

---

### Issue 5: Coverage Report Not Generated
**Symptom:**
`target/site/jacoco/index.html` does not exist.

**Solution:**
Run tests with JaCoCo explicitly:
```bash
mvn clean test jacoco:report
```

Verify JaCoCo plugin is in `pom.xml`:
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

---

### Issue 6: OrderService Not Mocked Correctly
**Symptom:**
```
NullPointerException when calling orderService.createOrderAndNotifyKitchen()
```

**Solution:**
Ensure `OrderService` is injected into the servlet using reflection:
```java
@BeforeEach
void setUp() throws Exception {
    servlet = new CreateOrderServlet();
    
    // Inject mock OrderService using reflection
    Field orderServiceField = CreateOrderServlet.class.getDeclaredField("orderService");
    orderServiceField.setAccessible(true);
    orderServiceField.set(servlet, mockOrderService);
}
```

This is already implemented in `CreateOrderServletTest`.

---

## 📚 Additional Resources

### Internal Documentation
- **Test Summary:** [`TEST_SUMMARY.md`](./TEST_SUMMARY.md) - Comprehensive test results and analysis
- **Test Plan:** [`prompts/outputs/Output_PR1.md`](../../../prompts/outputs/Output_PR1.md) - Initial planning
- **Basic Test Cases:** [`prompts/outputs/Output_PR2.md`](../../../prompts/outputs/Output_PR2.md) - 15 basic tests
- **Real-World Test Cases:** [`prompts/outputs/Output_PR3.md`](../../../prompts/outputs/Output_PR3.md) - 5 critical tests
- **AI Conversation Log:** [`prompts/log.md`](../../../prompts/log.md) - Complete AI development history

### Testing Resources
- **JUnit 5 User Guide:** https://junit.org/junit5/docs/current/user-guide/
- **Mockito Documentation:** https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html
- **Jakarta Servlet Spec:** https://jakarta.ee/specifications/servlet/5.0/
- **JaCoCo Documentation:** https://www.jacoco.org/jacoco/trunk/doc/

### Best Practices
- **Test Naming Conventions:** https://dzone.com/articles/7-popular-unit-test-naming
- **AAA Pattern:** https://medium.com/@pjbgf/title-testing-code-ocd-and-the-aaa-pattern-df453975ab80
- **Test Data Builders:** https://www.petrikainulainen.net/programming/testing/writing-clean-tests-replace-assertions-with-a-domain-specific-language/
- **Mockito Best Practices:** https://www.baeldung.com/mockito-best-practices

### LiteFlow Project
- **GitHub Repository:** (Add your repo URL)
- **Project Documentation:** (Add link to main README)
- **API Documentation:** (Add link to API docs)
- **Issue Tracker:** (Add link to issues)

---

## 📞 Support

### Getting Help
- **Bug Reports:** Open an issue in the GitHub repository
- **Feature Requests:** Create a feature request issue
- **Questions:** Contact the development team

### Contributing
To add new tests:
1. Follow the AAA pattern (Arrange-Act-Assert)
2. Use `OrderTestHelper` utilities
3. Add `@DisplayName` annotation
4. Document test purpose in comments
5. Ensure test is isolated and repeatable
6. Update `TEST_SUMMARY.md` with new test details

---

## ✅ Quick Reference Commands

```bash
# Install dependencies
mvn clean install

# Run all tests
mvn test

# Run cashier tests only
mvn test -Dtest=CreateOrderServletTest

# Run with coverage
mvn clean test jacoco:report

# Run specific test
mvn test -Dtest=CreateOrderServletTest#should_createOrder_when_validSingleItem

# View coverage report
start target/site/jacoco/index.html  # Windows
open target/site/jacoco/index.html   # Mac/Linux

# Run in quiet mode
mvn test -Dtest=CreateOrderServletTest -q

# Run with UTF-8 encoding
mvn test -Dtest=CreateOrderServletTest -Dfile.encoding=UTF-8
```

---

**Last Updated:** October 25, 2025  
**Version:** 1.0.0  
**Maintained By:** LiteFlow Development Team  
**License:** (Add your license)

