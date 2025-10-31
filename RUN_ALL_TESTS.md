# 🚀 CHẠY TẤT CẢ TESTS - QUICK REFERENCE

## ⚡ LỆNH NHANH NHẤT

```bash
# Chạy TẤT CẢ tests trong project
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

### 2️⃣ Chạy Tests Theo Package
```bash
# Tất cả tests trong package cashier
mvn test -Dtest=com.liteflow.cashier.*

# Tất cả tests trong package util
mvn test -Dtest=com.liteflow.util.*

# Tất cả tests trong package helpers
mvn test -Dtest=com.liteflow.helpers.*

# Nhiều packages cùng lúc
mvn test -Dtest=com.liteflow.cashier.*,com.liteflow.util.*
```

### 3️⃣ Chạy Test Class Cụ Thể
```bash
# Một class
mvn test -Dtest=CreateOrderServletTest

# Nhiều classes
mvn test -Dtest=CreateOrderServletTest,PasswordUtilTest
```

### 4️⃣ Chạy Test Method Cụ Thể
```bash
# Một method
mvn test -Dtest=CreateOrderServletTest#should_createOrder_when_validSingleItem

# Tất cả methods bắt đầu với "should_createOrder"
mvn test -Dtest=CreateOrderServletTest#should_createOrder*

# Nhiều methods
mvn test -Dtest=CreateOrderServletTest#test1+test2
```

---

## 📈 COVERAGE REPORT

### Tạo Coverage Report
```bash
# Coverage cho TẤT CẢ tests
mvn clean test jacoco:report

# Coverage cho specific test
mvn clean test -Dtest=CreateOrderServletTest jacoco:report

# Coverage cho package
mvn clean test -Dtest=com.liteflow.cashier.* jacoco:report
```

### Xem Coverage Report
```bash
# Windows
start target/site/jacoco/index.html

# Mac
open target/site/jacoco/index.html

# Linux
xdg-open target/site/jacoco/index.html
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

### Working Tests ✅
1. **CreateOrderServletTest** (20 tests)
   - Package: `com.liteflow.cashier`
   - Coverage: 97%
   - Command: `mvn test -Dtest=CreateOrderServletTest`

2. **PasswordUtilTest** 
   - Package: `com.liteflow.util`
   - Command: `mvn test -Dtest=PasswordUtilTest`

### Helper Classes ✅
3. **IntegrationTestBase** - Base class cho integration tests
4. **TestDataBuilder** - Builders cho entities
5. **MockServiceHelper** - Service mocks
6. **ServletTestHelper** - HTTP mocking
7. **TestScenarios** - Pre-built scenarios

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

---

## 🎓 TÀI LIỆU THAM KHẢO

1. **[QUICK_START.md](src/test/java/com/liteflow/cashier/QUICK_START.md)** - Hướng dẫn chi tiết
2. **[README.md](src/test/java/README.md)** - Test infrastructure guide
3. **[FINAL_STATUS.md](FINAL_STATUS.md)** - Trạng thái compilation fix

---

## 🚀 BẮT ĐẦU NGAY

```bash
# 1. Chạy tất cả tests
mvn test

# 2. Tạo coverage report
mvn clean test jacoco:report

# 3. Xem coverage
start target/site/jacoco/index.html
```

---

**Tạo ngày:** 31/10/2025  
**Status:** ✅ Ready to Use  
**Lệnh đơn giản nhất:** `mvn test`

