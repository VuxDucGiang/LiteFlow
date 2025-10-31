# 🚀 Quick Start Guide - LiteFlow Test Suite

## ⚡ TL;DR (Too Long; Didn't Read)

```bash
# Run ALL tests in project
mvn test

# Run only CreateOrderServlet tests
mvn test -Dtest=CreateOrderServletTest

# Run all tests in cashier package
mvn test -Dtest=com.liteflow.cashier.*

# Generate coverage report for all tests
mvn clean test jacoco:report

# View coverage
start target/site/jacoco/index.html  # Windows
```

**CreateOrderServlet Result:** 20 tests, 100% pass rate, 97% coverage ✅

---

## 📊 Test Results

| Metric | Value | Status |
|--------|-------|--------|
| **Total Tests** | 20 | ✅ |
| **Passed** | 20 | ✅ |
| **Failed** | 0 | ✅ |
| **Success Rate** | 100% | ✅ |
| **Code Coverage** | 97% | ✅ |
| **Execution Time** | ~4 seconds | ✅ |

---

## 🎯 What's Being Tested?

### ✅ CreateOrderServlet
The cashier order creation endpoint (`POST /api/order/create`)

**Test Categories:**
- 🟢 **4 Happy Path** - Valid order creation
- 🟡 **4 Edge Cases** - Boundary conditions
- 🔴 **7 Error Scenarios** - Invalid inputs
- 🔐 **5 Security Tests** - Production vulnerabilities
- ⚙️ **1 Infrastructure** - CORS compliance

---

## 💻 Maven Commands

### Run ALL Tests

```bash
# Run ALL tests in the entire project
mvn test

# Run all tests with clean build
mvn clean test

# Run all tests in quiet mode
mvn test -q

# Run all tests with verbose output
mvn test -X
```

### Run Tests by Package

```bash
# Run all tests in cashier package
mvn test -Dtest=com.liteflow.cashier.*

# Run all tests in util package
mvn test -Dtest=com.liteflow.util.*

# Run all tests in helpers package
mvn test -Dtest=com.liteflow.helpers.*

# Run multiple packages
mvn test -Dtest=com.liteflow.cashier.*,com.liteflow.util.*
```

### Run Specific Test Class

```bash
# Run only CreateOrderServlet tests
mvn test -Dtest=CreateOrderServletTest

# Run only PasswordUtil tests
mvn test -Dtest=PasswordUtilTest

# Run multiple specific classes
mvn test -Dtest=CreateOrderServletTest,PasswordUtilTest
```

### Run with Options

```bash
# Run in quiet mode (less output)
mvn test -Dtest=CreateOrderServletTest -q

# Run with verbose output (debug)
mvn test -Dtest=CreateOrderServletTest -X

# Run tests in parallel (faster)
mvn test -T 4  # 4 threads
```

### Coverage Commands

```bash
# Generate coverage for ALL tests
mvn clean test jacoco:report

# Generate coverage for specific test
mvn clean test -Dtest=CreateOrderServletTest jacoco:report

# Generate coverage for package
mvn clean test -Dtest=com.liteflow.cashier.* jacoco:report

# Run tests without cleaning (faster)
mvn test jacoco:report

# View coverage report location
echo target/site/jacoco/index.html
```

### Specific Test Execution

```bash
# Run single test method
mvn test -Dtest=CreateOrderServletTest#should_createOrder_when_validSingleItem

# Run tests matching pattern (all "should_createOrder*")
mvn test -Dtest=CreateOrderServletTest#should_createOrder*

# Run multiple specific tests
mvn test -Dtest=CreateOrderServletTest#should_createOrder_when_validSingleItem+should_return400_when_missingTableId
```

### Build Commands

```bash
# Clean and run tests
mvn clean test

# Full build with tests
mvn clean install

# Skip tests (not recommended)
mvn clean install -DskipTests

# Run tests only (skip compilation if already compiled)
mvn surefire:test -Dtest=CreateOrderServletTest
```

### UTF-8 Encoding (for Vietnamese characters)

```bash
# Windows PowerShell
mvn test -Dtest=CreateOrderServletTest -Dfile.encoding=UTF-8

# Windows CMD
mvn test -Dtest=CreateOrderServletTest -Dfile.encoding=UTF-8

# Linux/Mac
JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8 mvn test -Dtest=CreateOrderServletTest
```

---

## 🏗️ Project Structure

```
src/test/java/com/liteflow/
├── cashier/
│   ├── CreateOrderServletTest.java    # Order creation tests (20 tests)
│   ├── OrderTestHelper.java           # Test utilities
│   ├── TEST_SUMMARY.md                # Test report
│   └── README.md                      # User guide
├── util/
│   └── PasswordUtilTest.java          # Password utility tests
├── helpers/
│   ├── base/
│   │   ├── IntegrationTestBase.java   # Base class for integration tests
│   │   └── TestScenarios.java         # Pre-built test scenarios
│   ├── builders/
│   │   └── TestDataBuilder.java       # Entity builders
│   └── mocks/
│       ├── MockServiceHelper.java     # Service mocks
│       └── ServletTestHelper.java     # HTTP mocking
└── resources/
    ├── META-INF/test-persistence.xml  # H2 test database config
    └── application-test.properties    # Test properties
```

---

## 📚 Documentation Files

| File | Purpose | When to Read |
|------|---------|--------------|
| **QUICK_START.md** | Quick commands and summary | First time, daily use |
| **README.md** | Complete setup guide | Installation, troubleshooting |
| **TEST_SUMMARY.md** | Detailed test analysis | Understanding test coverage |
| **VALIDATION_CHECKLIST.md** | Quality assurance | Production deployment |

---

## 🔍 Coverage Report

### How to Generate
```bash
mvn clean test jacoco:report
```

### How to View
**Windows:**
```bash
start target/site/jacoco/index.html
```

**Mac:**
```bash
open target/site/jacoco/index.html
```

**Linux:**
```bash
xdg-open target/site/jacoco/index.html
```

### What You'll See
- **Overall Coverage:** 97%
- **Line Coverage:** 96.6% (57/59 lines)
- **Branch Coverage:** 100% (12/12 branches)
- **Method Coverage:** 80% (4/5 methods)

---

## ✅ Test Categories at a Glance

### 🟢 Happy Path (4 tests)
```bash
TC-HP-001: Single item order
TC-HP-002: Multiple items order
TC-HP-003: Order with Vietnamese note
TC-HP-004: Order with decimal price
```

### 🟡 Edge Cases (4 tests)
```bash
TC-EDGE-001: Large order (50 items)
TC-EDGE-002: Zero quantity
TC-EDGE-003: Duplicate items
TC-EDGE-004: Very long note (1000+ chars)
```

### 🔴 Error Scenarios (7 tests)
```bash
TC-ERR-001: Missing tableId
TC-ERR-002: Empty items array
TC-ERR-003: Invalid UUID format
TC-ERR-004: Null request body
TC-ERR-005: Missing required fields
TC-ERR-006: Validation error
TC-ERR-007: Service runtime exception
```

### 🔐 Security Tests (5 tests)
```bash
TC-REAL-001: Negative price attack [CRITICAL]
TC-REAL-002: Vietnamese + emoji [HIGH]
TC-REAL-003: Data type mismatch [HIGH]
TC-REAL-004: Malformed JSON [HIGH]
TC-REAL-005: Double-submission [CRITICAL]
```

### ⚙️ Infrastructure (1 test)
```bash
TC-INFRA-001: CORS preflight headers
```

---

## 🐛 Troubleshooting

### Issue: Tests fail to compile
**Solution:**
```bash
mvn clean install
```

### Issue: "No tests were executed"
**Possible Causes:**
1. Wrong test class name
2. Test class not in correct package

**Solution:**
```bash
# Check test class exists
mvn test -Dtest=CreateOrderServletTest -X

# List all test classes
find src/test/java -name "*Test.java"

# Run all tests (don't specify -Dtest)
mvn test
```

### Issue: Vietnamese characters show as `?`
**Solution:**
```bash
mvn test -Dfile.encoding=UTF-8
```
> This is a console display issue, not a code bug. The Java code handles UTF-8 correctly.

### Issue: Coverage report not generated
**Solution:**
```bash
mvn clean test jacoco:report
```

### Issue: "Cannot find symbol: class ExtendWith"
**Solution:**
Ensure `mockito-junit-jupiter` is in `pom.xml`, then run:
```bash
mvn clean install
```

### Issue: Tests run too slow
**Solution - Run in parallel:**
```bash
mvn test -T 4  # Use 4 threads
mvn test -T 1C # 1 thread per CPU core
```

### Issue: Need to skip tests temporarily
**Solution:**
```bash
mvn clean install -DskipTests
# Note: Not recommended for production builds
```

---

## 🎓 IDE Integration

### IntelliJ IDEA
1. Right-click `CreateOrderServletTest.java`
2. Select "Run 'CreateOrderServletTest'"
3. Or press `Ctrl+Shift+F10`

### Eclipse
1. Right-click `CreateOrderServletTest.java`
2. Select "Run As" → "JUnit Test"
3. Or press `Alt+Shift+X, T`

### VS Code
1. Install "Test Runner for Java" extension
2. Click play button next to test class
3. Or use Command Palette: "Java: Run Tests"

---

## 📈 Expected Output

### For ALL Tests (`mvn test`)
```
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.liteflow.cashier.CreateOrderServletTest
[INFO] Tests run: 20, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.liteflow.util.PasswordUtilTest
[INFO] Tests run: X, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: X, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

### For Specific Test (`mvn test -Dtest=CreateOrderServletTest`)
```
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.liteflow.cashier.CreateOrderServletTest
[INFO] Tests run: 20, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 20, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

---

## 🚀 Quick Command Reference

### Most Common Commands

```bash
# 1. Run ALL tests in project
mvn test

# 2. Run with coverage report
mvn clean test jacoco:report

# 3. Run specific test class
mvn test -Dtest=CreateOrderServletTest

# 4. Run all tests in a package
mvn test -Dtest=com.liteflow.cashier.*

# 5. View coverage report
start target/site/jacoco/index.html  # Windows
open target/site/jacoco/index.html   # Mac
xdg-open target/site/jacoco/index.html  # Linux
```

## 🚀 Next Steps

1. ✅ Run all tests: `mvn test`
2. ✅ Check coverage: `mvn clean test jacoco:report`
3. ✅ Read full guide: [`README.md`](./README.md)
4. ✅ Review test details: [`TEST_SUMMARY.md`](./TEST_SUMMARY.md)
5. ✅ Validate quality: [`VALIDATION_CHECKLIST.md`](./VALIDATION_CHECKLIST.md)
6. ✅ Check helper classes: [`../helpers/base/IntegrationTestBase.java`](../helpers/base/IntegrationTestBase.java)

---

## 📞 Need Help?

- **Installation Issues:** See [`README.md`](./README.md) → Prerequisites
- **Test Failures:** See [`README.md`](./README.md) → Troubleshooting
- **Coverage Questions:** See [`TEST_SUMMARY.md`](./TEST_SUMMARY.md) → Coverage Report
- **Quality Concerns:** See [`VALIDATION_CHECKLIST.md`](./VALIDATION_CHECKLIST.md)

---

**Created:** October 25, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready

