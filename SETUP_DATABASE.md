# 🛠️ SETUP DATABASE - PROCUREMENT MODULE

## ❌ VẤN ĐỀ HIỆN TẠI
```
Invalid object name 'PurchaseOrders'
```
→ **Tables chưa được tạo trong database!**

---

## ✅ GIẢI PHÁP - CHẠY 2 SCRIPTS THEO THỨ TỰ:

### **Bước 1: Tạo Schema (Tables, Indexes, Procedures)**
```bash
sqlcmd -S localhost -d LiteFlowDBO -U sa -P abc123 -i database\Pro_ipdate.sql
```

**File này tạo:**
- ✅ Tables: Suppliers, PurchaseOrders, PurchaseOrderItems, GoodsReceipts, GoodsReceiptItems, Invoices, InvoiceItems, SupplierSLA
- ✅ Indexes
- ✅ Stored Procedures
- ✅ Views
- ✅ Functions
- ✅ Triggers

**Expected output:**
```
========================================
PROCUREMENT MODULE SCHEMA CREATED SUCCESSFULLY!
========================================
```

---

### **Bước 2: Insert Sample Data**
```bash
sqlcmd -S localhost -d LiteFlowDBO -U sa -P abc123 -i database\PROCUREMENT_SAMPLE_DATA.sql
```

**File này tạo:**
- ✅ 5 Suppliers (Highlands, Vinamilk, Kinh Đô, Trái cây Đà Lạt, Ajinomoto)
- ✅ 5 Purchase Orders (APPROVED, PENDING, COMPLETED, REJECTED)
- ✅ 12 Purchase Order Items
- ✅ 3 Goods Receipts
- ✅ Sample GoodsReceiptItems và InvoiceItems
- ✅ Supplier SLA data

**Expected output:**
```
========================================
SAMPLE DATA INSERTED SUCCESSFULLY!
========================================
```

---

### **Bước 3: Verify Database**
```bash
sqlcmd -S localhost -d LiteFlowDBO -U sa -P abc123 -i check_database.sql
```

**Expected output:**
```
========================================
STEP 1: Kiểm tra Tables tồn tại
========================================
TableName              RowCount
---------------------- -----------
GoodsReceiptItems      X
GoodsReceipts          3
InvoiceItems           X
Invoices               X
PurchaseOrderItems     12
PurchaseOrders         5
Suppliers              5
SupplierSLA            5

========================================
STEP 2: Kiểm tra POs APPROVED
========================================
Total_APPROVED_POs  Oldest_PO           Newest_PO
------------------- ------------------- -------------------
3                   2025-XX-XX          2025-XX-XX

========================================
STEP 3: Chi tiết POs APPROVED (top 5)
========================================
POID                                 POID_String              SupplierName        TotalAmount  Status    CreateDate           ItemsCount
------------------------------------ ------------------------ ------------------- ------------ --------- -------------------- -----------
...                                  ...                      Highlands Coffee    1450000.00   APPROVED  2025-XX-XX           3
...                                  ...                      Vinamilk            1800000.00   APPROVED  2025-XX-XX           1
...                                  ...                      Kinh Đô             1200000.00   APPROVED  2025-XX-XX           2

========================================
STEP 4: Kiểm tra Items cho PO đầu tiên
========================================
Testing with POID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

ItemID  POID                                 ItemName                 Quantity  UnitPrice  Subtotal
------- ------------------------------------ ------------------------ --------- ---------- -----------
1       xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx Cà phê Arabica Premium   50        25000.00   1250000.00
2       xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx Cà phê Robusta           30        20000.00   600000.00
...

Total items for this PO: 3

========================================
STEP 5: Kiểm tra Indexes
========================================
(Hiển thị indexes trên PurchaseOrderItems)

========================================
STEP 6: Performance Test Query
========================================
(Hiển thị items)

Query execution time: 45 ms
OK: Query performance is acceptable

========================================
STEP 7: Check for NULL/Invalid POIDs
========================================
TableName            Total_Records  NULL_POIDs
-------------------- -------------- -----------
PurchaseOrders       5              0
PurchaseOrderItems   12             0

========================================
STEP 8: Orphaned Items Check
========================================
OK: No orphaned items found

========================================
DIAGNOSTIC COMPLETE
========================================
```

---

## 🎯 TÓM TẮT LỆNH

```bash
# 1. Tạo schema
sqlcmd -S localhost -d LiteFlowDBO -U sa -P abc123 -i database\Pro_ipdate.sql

# 2. Insert data
sqlcmd -S localhost -d LiteFlowDBO -U sa -P abc123 -i database\PROCUREMENT_SAMPLE_DATA.sql

# 3. Verify
sqlcmd -S localhost -d LiteFlowDBO -U sa -P abc123 -i check_database.sql

# 4. Deploy application
# Copy target\LiteFlow.war to Tomcat webapps\

# 5. Test
# Open: http://localhost:8080/LiteFlow/procurement/invoice
```

---

## ⚠️ LƯU Ý

### Nếu tables đã tồn tại:
`Pro_ipdate.sql` có `DROP TABLE IF EXISTS` nên an toàn chạy lại.

### Nếu muốn reset data:
```sql
-- Xóa data (giữ schema)
DELETE FROM InvoiceItems;
DELETE FROM Invoices;
DELETE FROM GoodsReceiptItems;
DELETE FROM GoodsReceipts;
DELETE FROM PurchaseOrderItems;
DELETE FROM PurchaseOrders;
DELETE FROM SupplierSLA;
DELETE FROM Suppliers;

-- Sau đó chạy lại PROCUREMENT_SAMPLE_DATA.sql
```

### Nếu muốn xóa toàn bộ:
```sql
-- Chạy lại Pro_ipdate.sql
-- Nó sẽ DROP và tạo lại tất cả
```

---

## 🔍 TROUBLESHOOTING

### Lỗi: "Database does not exist"
```bash
# Tạo database trước
sqlcmd -S localhost -U sa -P abc123 -Q "CREATE DATABASE LiteFlowDBO"
```

### Lỗi: "Login failed"
```bash
# Check credentials
# Username: sa
# Password: abc123 (hoặc password bạn đã set)
```

### Lỗi: "Cannot connect to server"
```bash
# Check SQL Server đang chạy
services.msc → SQL Server (MSSQLSERVER) → Start
```

---

**Status:** ✅ READY TO SETUP  
**Next:** Chạy 3 lệnh trên theo thứ tự 1 → 2 → 3



