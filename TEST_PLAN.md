# 🎯 TEST PLAN - "Đang tải" Issue

## ✅ VERIFIED (So far):
1. **Database**: ✅ 4 APPROVED POs, 5 items total
2. **Backend API**: ✅ `/procurement/po-items?poid=xxx` returns JSON correctly
3. **Frontend Code**: ✅ `loadPODetails()` logic is correct
4. **Servlet Logic**: ✅ `completedPOs` is loaded and filtered

## 🔍 REMAINING CHECKS:

### 1. WAR Deployment Status
**Check if the latest code is deployed:**
```bash
# Check WAR timestamp
dir target\LiteFlow.war

# Check Tomcat deployment timestamp
dir C:\path\to\tomcat\webapps\LiteFlow.war
```

**If timestamps don't match → REDEPLOY!**

---

### 2. Browser Cache Issue
**User might be viewing OLD JavaScript:**
- Hard refresh: `Ctrl + Shift + R` or `Ctrl + F5`
- Clear browser cache
- Try Incognito mode

---

### 3. Console Check (F12)
**When dropdown changes, check:**

#### Network Tab:
- Request URL: `/LiteFlow/procurement/po-items?poid=D8324DC7-...`
- Status: `200 OK`
- Response: `[{"itemID":12,...}]`
- Time: Should be < 1 second

#### Console Tab:
- Any JavaScript errors?
- Look for: `loadPODetails is not defined`
- Look for: `Uncaught TypeError...`

---

### 4. Tomcat Logs
**Check `catalina.out` or `catalina.YYYY-MM-DD.log`:**

Search for:
```
=== POItemsServlet.doGet START ===
POID parameter: D8324DC7-...
Parsed UUID: d8324dc7-...
Query executed, found 1 items
=== POItemsServlet.doGet END (took XXms) ===
```

**If no logs → Request never reached servlet**
**If logs exist but frontend stuck → Frontend issue**

---

## 🧪 STEP-BY-STEP TEST:

### Step 1: Deploy Fresh WAR
```bash
cd C:\Users\Administrator\Documents\LiteFlow\LiteFlow
mvn clean package -DskipTests

# Stop Tomcat
# Copy target\LiteFlow.war → Tomcat webapps\
# Start Tomcat
# Wait 30 seconds for deployment
```

### Step 2: Test Backend Directly
```bash
curl "http://localhost:8080/LiteFlow/procurement/po-items?poid=D8324DC7-D431-4A44-BA40-03BE041146D7"
```

**Expected:** JSON array with 1 item

### Step 3: Test Frontend
1. Open: `http://localhost:8080/LiteFlow/procurement/invoice`
2. Press `F12` → Network tab
3. Click "Đối chiếu từ PO" button
4. Select first PO from dropdown
5. **WATCH:**
   - Network tab: Request sent?
   - Console: Errors?
   - UI: "Đang tải..." changes to items?

### Step 4: Analyze Results

#### ✅ Success (should see):
- Network: `/po-items` request → 200 OK → JSON
- Console: No errors
- UI: Items appear, "Đối chiếu PO" button enabled
- Duration: < 1 second

#### ❌ Stuck on "Đang tải...":
- Network: Request sent but hangs?
- Console: Errors?
- Backend: Check Tomcat logs

---

## 🚨 MOST LIKELY ISSUES:

### Issue #1: Old WAR deployed (90% chance)
**Symptom:** Code looks correct but behavior is wrong
**Fix:** 
```bash
# 1. Check build timestamp
dir target\LiteFlow.war
# 2. Stop Tomcat
# 3. Delete webapps\LiteFlow folder AND LiteFlow.war
# 4. Copy new WAR
# 5. Start Tomcat
```

### Issue #2: Browser cache (5% chance)
**Symptom:** JavaScript not updated
**Fix:** Hard refresh (`Ctrl + Shift + R`)

### Issue #3: EntityManagerFactory init slow (3% chance)
**Symptom:** First request takes 10+ seconds, then OK
**Fix:** Wait and retry

### Issue #4: UUID format mismatch (1% chance)
**Symptom:** Backend returns `[]` (empty)
**Fix:** Check logs: "Parsed UUID: ..." vs Database POID

### Issue #5: Network/proxy issue (1% chance)
**Symptom:** Request never reaches server
**Fix:** Check firewall, test with `curl`

---

## 📊 EXPECTED TIMELINE:

| Action | Duration |
|--------|----------|
| Build WAR | 1 minute |
| Deploy | 30 seconds |
| Backend Test (CURL) | < 1 second |
| Frontend Test | < 1 second per PO |
| **TOTAL** | **~3 minutes** |

---

## 🎯 NEXT ACTIONS:

1. **Rebuild WAR**: `mvn clean package -DskipTests`
2. **Redeploy**: Stop Tomcat → Copy WAR → Start
3. **Test CURL**: Verify backend works
4. **Test Browser**: Open invoice page → F12 → Test dropdown
5. **Report Results**: Share Network tab + Console + Tomcat logs if stuck

---

**Current Status:**
- ✅ Database: VERIFIED (4 POs, 5 items)
- ✅ Backend API: VERIFIED (CURL returns JSON)
- ⏳ Frontend: NEEDS TESTING (suspect old WAR deployed)

**Next:** Deploy fresh WAR and test!



