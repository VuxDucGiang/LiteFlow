# 🧪 TEST BACKEND - Manual Test

## Database Status: ✅ OK
- 4 APPROVED POs
- 5 Items total
- Users exist
- Foreign keys valid

## Test POID từ database:
```
D8324DC7-D431-4A44-BA40-03BE041146D7  (Pepsi - 1 item)
D2E95E5D-DFD6-42A7-9D16-2E4699B4A4B1  (?)
46369802-0FAF-4DD3-99E6-468E241733E0  (?)
E3CE9B4B-7221-4E8A-93FC-8C5FF598EBEA  (?)
```

## 🔍 MANUAL TEST với CURL:

### Test 1: POItemsServlet trực tiếp
```bash
curl "http://localhost:8080/LiteFlow/procurement/po-items?poid=D8324DC7-D431-4A44-BA40-03BE041146D7"
```

**Expected:**
```json
[{"itemID":12,"itemName":"Pepsi 330ml","quantity":200,"unitPrice":10000.0}]
```

**Nếu lỗi, check:**
1. Tomcat có đang chạy không?
2. LiteFlow.war đã deploy chưa?
3. Xem Tomcat logs: `catalina.out`

---

## 🎯 NEXT STEPS:

### 1. Deploy WAR mới
```bash
# Stop Tomcat
# Copy target\LiteFlow.war to webapps\
# Start Tomcat
# Wait for deployment (check logs)
```

### 2. Test với browser
```
http://localhost:8080/LiteFlow/procurement/invoice
```

### 3. Mở F12 Console, chọn PO, xem:
- Network tab: `/procurement/po-items` request
- Response: JSON array hoặc error?
- Console: JavaScript errors?

### 4. Xem Tomcat logs
```
catalina.out hoặc catalina.YYYY-MM-DD.log

Tìm:
=== POItemsServlet.doGet START ===
...
=== POItemsServlet.doGet END ===
```

---

## 🚨 POSSIBLE ISSUES:

### A. Timeout (10s) → No response from server
**Nguyên nhân:**
- EntityManagerFactory chưa khởi tạo
- Database connection failed
- Query bị hang

**Check:**
- Tomcat startup logs có error không?
- persistence.xml connection string đúng không?

### B. Response [] (empty) → Server OK nhưng query empty
**Nguyên nhân:**
- POID không match (UUID format khác)
- Query logic sai

**Debug:**
- Xem logs: "Query executed, found X items"
- Nếu X = 0 → POID mismatch

### C. Response HTML → Servlet error
**Nguyên nhân:**
- Exception trong servlet
- 404/500 error page

**Check:**
- Tomcat logs có stack trace
- web.xml mapping đúng không?

---

## 📊 EXPECTED BEHAVIOR:

### ✅ Thành công:
1. Request: `GET /procurement/po-items?poid=xxx`
2. Logs: "POItemsServlet.doGet START"
3. Logs: "Query executed, found 1 items"
4. Logs: "doGet END (took XXms)"
5. Response: `[{"itemID":12,...}]`
6. Frontend: Hiện items, enable submit
7. **DURATION: < 1 second**

### ❌ Timeout:
1. Request sent
2. No response for 10 seconds
3. Frontend: "Lỗi: Timeout"
4. Logs: Có thể STUCK hoặc không có logs gì
5. **DURATION: 10 seconds (timeout)**

---

## 🔧 DEBUG CHECKLIST:

- [ ] Database có data (✅ DONE - 4 POs, 5 items)
- [ ] Tomcat đang chạy
- [ ] LiteFlow.war deployed
- [ ] Test CURL: `/procurement/po-items?poid=...`
- [ ] Check Tomcat logs
- [ ] Check browser Console (F12)
- [ ] Check browser Network tab

---

**NEXT:** Test CURL command hoặc vào browser test!



