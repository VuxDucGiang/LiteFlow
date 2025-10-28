# 🚀 DEPLOY & TEST - Hướng dẫn triển khai

## ✅ BUILD COMPLETE
```
target\LiteFlow.war created successfully!
Build time: 2025-10-27T13:31:35+07:00
```

---

## 📦 BƯỚC 1: DEPLOY WAR MỚI

### Option A: Tomcat Manager (Khuyến nghị)
1. Mở: `http://localhost:8080/manager/html`
2. Login (nếu cần)
3. Tìm `LiteFlow` trong danh sách
4. Click **"Undeploy"** để xóa bản cũ
5. Scroll xuống **"Deploy"**
6. Chọn file: `target\LiteFlow.war`
7. Click **"Deploy"**
8. Đợi ~30 giây để deployment hoàn tất

### Option B: Manual Deploy
```bash
# 1. Stop Tomcat
C:\path\to\tomcat\bin\shutdown.bat

# 2. Xóa deployment cũ
del C:\path\to\tomcat\webapps\LiteFlow.war
rmdir /s C:\path\to\tomcat\webapps\LiteFlow

# 3. Copy WAR mới
copy C:\Users\Administrator\Documents\LiteFlow\LiteFlow\target\LiteFlow.war C:\path\to\tomcat\webapps\

# 4. Start Tomcat
C:\path\to\tomcat\bin\startup.bat

# 5. Đợi 30-60 giây để Tomcat unpack WAR
```

---

## 🧪 BƯỚC 2: TEST BACKEND (CURL)

### Test POItemsServlet với POID thực tế:
```bash
curl "http://localhost:8080/LiteFlow/procurement/po-items?poid=D8324DC7-D431-4A44-BA40-03BE041146D7"
```

### ✅ Expected Response:
```json
[{"itemID":12,"itemName":"Pepsi 330ml","quantity":200,"unitPrice":10000.0}]
```

### ❌ Nếu lỗi:
- **404 Not Found**: WAR chưa deploy xong, đợi thêm
- **500 Internal Server Error**: Check Tomcat logs (`catalina.out`)
- **Empty response**: Tomcat chưa start, check service

---

## 🌐 BƯỚC 3: TEST FRONTEND

### 3.1 Mở trang Invoice
```
http://localhost:8080/LiteFlow/procurement/invoice
```

### 3.2 Mở Developer Tools (F12)
- Tab **Network**: Xem HTTP requests
- Tab **Console**: Xem JavaScript errors

### 3.3 Test Đối chiếu PO
1. Click nút **"Đối chiếu từ PO"**
2. Modal mở lên (main-nav ẩn)
3. Trong dropdown, chọn bất kỳ PO nào (có 4 options)
4. **QUAN SÁT:**

#### ✅ Thành công (< 1 giây):
- **UI Changes:**
  - "Đang tải sản phẩm từ PO..." → Hiện danh sách items
  - Nút "Đối chiếu PO" không còn disabled
  - Số tiền tự động tính

- **Network Tab (F12):**
  - Request: `/procurement/po-items?poid=xxx`
  - Status: `200 OK`
  - Response: JSON array with items
  - Time: < 500ms

- **Console Tab (F12):**
  - No errors

#### ❌ Stuck "Đang tải..." (> 10 giây):
- **UI:**
  - Spinner quay mãi
  - Nút "Đối chiếu PO" vẫn disabled

- **Network Tab:**
  - Request gửi đi nhưng không có response?
  - Hoặc: Không có request nào cả?

- **Console Tab:**
  - Error: `loadPODetails is not defined`?
  - Error: `Uncaught TypeError...`?
  - Warning: `Timeout - Server không phản hồi`?

---

## 📊 BƯỚC 4: CHECK TOMCAT LOGS

### File location:
```
C:\path\to\tomcat\logs\catalina.out
hoặc
C:\path\to\tomcat\logs\catalina.2025-10-27.log
```

### Tìm kiếm:
```
=== POItemsServlet.doGet START ===
POID parameter: xxx
Parsed UUID: xxx
Query executed, found X items
=== POItemsServlet.doGet END (took XXms) ===
```

### Phân tích:
- **Có logs**: Backend nhận request và xử lý
  - Nếu "found 0 items": POID không match
  - Nếu "found 1+ items": Backend OK, lỗi ở frontend
- **Không có logs**: Request không đến servlet
  - Kiểm tra `web.xml` mapping
  - Kiểm tra browser Network tab: request có gửi không?

---

## 🔍 BƯỚC 5: DEBUGGING CHECKLIST

Nếu vẫn lỗi, check từng điểm:

### Database Layer ✅
```sql
-- Run test_data_flow.sql to verify data exists
sqlcmd -S localhost -d LiteFlowDBO -U sa -P abc123 -i test_data_flow.sql
```

**Expected:** 4 APPROVED POs, 5 items

---

### Backend API ✅
```bash
curl "http://localhost:8080/LiteFlow/procurement/po-items?poid=D8324DC7-D431-4A44-BA40-03BE041146D7"
```

**Expected:** JSON with 1 item

---

### WAR Deployment ⏳
```bash
# Check WAR timestamp
dir target\LiteFlow.war

# Compare with deployed WAR
dir C:\path\to\tomcat\webapps\LiteFlow.war
```

**Expected:** Timestamps match (deployed trong 5 phút qua)

---

### Browser Cache ⏳
- Hard refresh: `Ctrl + Shift + R`
- Or: Incognito mode
- Or: Clear cache (Settings → Privacy → Clear browsing data)

---

### JavaScript Scope ⏳
**In browser Console (F12), test:**
```javascript
typeof window.loadPODetails
```

**Expected:** `"function"`
**If:** `"undefined"` → JavaScript chưa load hoặc có syntax error

---

## 🎯 EXPECTED RESULTS

### ✅ Nếu mọi thứ OK:
1. Mở invoice page → OK
2. Click "Đối chiếu từ PO" → Modal mở
3. Chọn PO → Items load trong < 1 giây
4. Submit form → Tạo invoice thành công
5. **TOTAL TIME: < 5 giây từ chọn PO đến submit**

### ❌ Nếu vẫn "Đang tải...":
**Report lại với:**
1. Screenshot Network tab (F12)
2. Screenshot Console tab (F12)
3. Copy/paste Tomcat logs (search for `POItemsServlet`)
4. Xác nhận đã deploy WAR mới (check timestamp)

---

## 🚨 COMMON ISSUES & FIXES

| Issue | Symptom | Fix |
|-------|---------|-----|
| **Old WAR deployed** | Code đúng nhưng behavior sai | Redeploy WAR, check timestamp |
| **Browser cache** | JavaScript không update | Hard refresh `Ctrl+Shift+R` |
| **Tomcat not started** | 404 error | Start Tomcat service |
| **EntityManagerFactory init** | First request slow (10s+), then OK | Wait 15s, retry |
| **UUID mismatch** | Backend returns `[]` | Check logs: "Parsed UUID" |
| **Network blocked** | Request timeout | Check firewall, test with `curl` |

---

## ✨ SUMMARY

**Current Status:**
- ✅ Database: 4 APPROVED POs, 5 items
- ✅ Backend API: Returns JSON correctly (tested with CURL)
- ✅ Frontend Code: Logic is correct
- ✅ WAR Built: `target\LiteFlow.war` ready
- ⏳ **NEXT: Deploy & Test on Browser**

**Action Items:**
1. Deploy `target\LiteFlow.war` to Tomcat
2. Test with CURL to verify backend
3. Test on browser with F12 open
4. Report results

**Estimated Time:** 3-5 minutes

---

**Good luck! 🚀**



