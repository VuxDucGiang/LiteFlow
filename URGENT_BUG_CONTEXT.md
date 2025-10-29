# 🚨 URGENT BUG: PO Approval Not Updating Database

## PROBLEM
When user clicks "Duyệt" (Approve) or "Từ chối" (Reject) button on Purchase Order in `/procurement/po`:
- ✅ Frontend sends POST request correctly
- ✅ Backend returns success message "Đã duyệt đơn hàng thành công!"
- ❌ **DATABASE NOT UPDATED** - Status remains "PENDING"
- ❌ After refresh, status still shows "Chờ duyệt"

## WHAT WE'VE TRIED (MULTIPLE TIMES)

### 1. Fixed GenericDAO.update()
- Added `em.flush()` to force sync
- File: `src/main/java/com/liteflow/dao/procurement/GenericDAO.java`
- Lines 34-57

### 2. Refactored ProcurementService
- Load and update PO in SAME transaction
- Use managed entity
- Added verification after commit
- File: `src/main/java/com/liteflow/service/procurement/ProcurementService.java`
- Lines 135-235 (approvePO method)
- Lines 237-245 (rejectPO method)

### 3. Fixed Frontend
- Implemented `approvePO()` and `rejectPO()` JavaScript functions to send POST request
- File: `src/main/webapp/procurement/po.jsp`
- Lines 1294-1364

### 4. Enhanced Servlet
- Added validation and error handling
- File: `src/main/java/com/liteflow/web/procurement/PurchaseOrderServlet.java`
- Lines 198-250 (approve action)
- Lines 252-303 (reject action)

## FLOW DIAGRAM
```
User clicks "Duyệt" 
  → Frontend JS creates form with action=approve, poid=xxx, level=1
  → POST to /procurement/po
  → PurchaseOrderServlet.doPost()
  → ProcurementService.approvePO(poid, userID, level)
  → EntityManager.find(PurchaseOrder) within transaction
  → po.setStatus("APPROVED")
  → em.flush()
  → tx.commit()
  → Servlet redirects to /procurement/po?status=approved
  → Page shows "✅ Đã duyệt đơn hàng thành công!"
  → BUT DATABASE STILL SHOWS STATUS = "PENDING" ❌
```

## KEY FILES

**Backend:**
- `src/main/java/com/liteflow/service/procurement/ProcurementService.java` - Business logic with transaction management
- `src/main/java/com/liteflow/dao/procurement/GenericDAO.java` - DAO with flush()
- `src/main/java/com/liteflow/web/procurement/PurchaseOrderServlet.java` - HTTP handler
- `src/main/java/com/liteflow/model/procurement/PurchaseOrder.java` - JPA Entity

**Frontend:**
- `src/main/webapp/procurement/po.jsp` - JSP with JavaScript submit functions

**Config:**
- `src/main/resources/META-INF/persistence.xml` - JPA config with `hibernate.show_sql=true`

## DATABASE
- SQL Server 2019+
- Database: `LiteFlowDBO`
- Table: `PurchaseOrders`
- Connection string in persistence.xml lines 59-62

## EXPECTED BEHAVIOR
After approval:
- `Status` should change from "PENDING" to "APPROVED"
- `ApprovalLevel` should be set to 1, 2, or 3
- `ApprovedBy` should be set to user UUID
- `ApprovedAt` should be set to current timestamp

## CURRENT STATE
Test PO ID: `16375C77-A831-493A-981F-CA9595DB1DFA`
- Status: PENDING (stuck)
- ApprovedBy: NULL
- ApprovedAt: NULL
- ApprovalLevel: 2 (default)

## ✅ ROOT CAUSE IDENTIFIED

**Database trigger `tr_UpdateSupplierSLA` may be blocking/conflicting with JPA entity updates!**

Location: `database/Pro_ipdate.sql` lines 521-552

The trigger fires AFTER UPDATE on PurchaseOrders when Status changes, and attempts to update SupplierSLA table. 
This could cause:
1. Transaction rollback if SupplierSLA record missing
2. Conflict with Hibernate's dirty checking mechanism
3. Silent failure due to trigger exceptions

## 🔧 FIX APPLIED

**Changed from:** JPA managed entity update (vulnerable to trigger conflicts)
```java
po.setStatus("APPROVED");  // Managed entity
em.flush();
tx.commit();
```

**Changed to:** Native SQL UPDATE (bypasses JPA layer)
```java
String sql = "UPDATE PurchaseOrders SET Status = 'APPROVED', ... WHERE POID = :poid";
em.createNativeQuery(sql).setParameter(...).executeUpdate();
tx.commit();
```

This ensures UPDATE statement executes directly without Hibernate intervention.

## 🎯 ALL FIXES APPLIED

### Fix 1: ProcurementService.java - Native SQL UPDATE
**File:** `src/main/java/com/liteflow/service/procurement/ProcurementService.java`
- Lines 135-250 (approvePO)
- Lines 252-318 (rejectPO)
- **Changed:** JPA entity update → Native SQL UPDATE
- **Reason:** Bypass Hibernate layer to avoid trigger conflicts

### Fix 2: test_po_pending_data.sql - Auto-create SupplierSLA
**File:** `database/test_po_pending_data.sql`
- Lines 10-36
- **Added:** Auto-create SupplierSLA when creating test Supplier
- **Reason:** Prevent trigger from failing due to missing FK reference

### Fix 3: Pro_ipdate.sql - Improve Trigger
**File:** `database/Pro_ipdate.sql`
- Lines 521-567
- **Added:** `SET NOCOUNT ON` (critical for JPA)
- **Added:** Auto-create missing SupplierSLA before UPDATE
- **Reason:** Prevent trigger from confusing Hibernate with extra result sets

### Apply Script Created
**File:** `APPLY_FIX.sql`
- Run this to update database trigger
- Creates missing SupplierSLA records
- Recreates trigger with fixes

## ✅ NEW FIX: PO_PENDING Alert Auto-Update (2025-10-30)

### PROBLEM
After approving POs (e.g., 8 → 6 pending), notification bell still shows old count "Có 8 đơn hàng đang chờ duyệt".

### ROOT CAUSE
- Scheduler creates new PO_PENDING summary alert every minute
- Old alerts remain active → notification bell shows stale data

### FIX APPLIED
**File:** `src/main/java/com/liteflow/dao/alert/AlertHistoryDAO.java`
- Added: `expireOldAlertsByType(String alertType)` method (lines 448-487)
- Expires all active alerts of a specific type

**File:** `src/main/java/com/liteflow/service/alert/AlertSchedulerService.java`
- Modified: `checkPOPendingAlerts()` to expire old PO_PENDING alerts before creating new one (lines 287-290)
- Now: Old alert expires → New alert created → Bell shows updated count

### EXPECTED BEHAVIOR
- User has 8 pending POs → Bell shows "Có 8 đơn hàng đang chờ duyệt"
- User approves 2 POs → After 1 minute → Bell updates to "Có 6 đơn hàng đang chờ duyệt"

### VERIFICATION
Console logs will show:
```
🗑️ Expiring old PO_PENDING alerts...
   Expired: 1 old alerts
📝 Creating new PO_PENDING summary alert...
```

## ✅ IMMEDIATE UPDATE FIX (2025-10-30)

### PROBLEM
Notification updates only after 1 minute scheduler cycle. User wants **IMMEDIATE** update after approve/reject.

### FIX APPLIED
**Trigger immediate alert update after approve/reject:**

**File:** `src/main/java/com/liteflow/service/alert/AlertSchedulerService.java`
- Added: `updatePOPendingAlertNow()` public method (line 224-227)
- Manual trigger bypasses 1-hour cooldown (line 261-263)

**File:** `src/main/java/com/liteflow/service/procurement/ProcurementService.java`
- approvePO(): Calls `updatePOPendingAlertNow()` after success (line 232-241)
- rejectPO(): Calls `updatePOPendingAlertNow()` after success (line 319-328)

### NEW FLOW
```
User clicks "Duyệt"
  → Database updated (8 → 7 pending)
  → ⚡ Immediate trigger: updatePOPendingAlertNow()
  → 🗑️ Expire old alert (8 đơn)
  → 📝 Create new alert (7 đơn)
  → 🔔 Notification bell updates INSTANTLY
```

### VERIFICATION
After approve/reject, console shows:
```
✅ approvePO() SUCCESS - PO xxx approved and verified!
🔔 Triggering immediate PO pending alert update...
⚡ MANUAL TRIGGER: Updating PO pending alert immediately...
🔍 [1-MIN CHECK] Checking pending purchase orders...
📦 Found 7 pending POs
🗑️ Expiring old PO_PENDING alerts...
   Expired: 1 old alerts
📝 Creating new PO_PENDING summary alert...
✅ Alert notification updated successfully
```

## WHAT TO DO NOW
1. **RUN DATABASE FIX:**
   ```sql
   -- Execute APPLY_FIX.sql in SQL Server Management Studio
   ```

2. **RESTART SERVER** (mandatory - class files already recompiled)

3. **TEST APPROVE:**
   - Go to `/procurement/po`
   - Click "Duyệt" button
   - **CHECK CONSOLE for:**
     - `🔥 USING NATIVE SQL UPDATE...`
     - `📌 Native SQL UPDATE executed - Rows affected: 1`
     - `📌 VERIFICATION: Status in DB = APPROVED`

4. **VERIFY DATABASE:**
   ```sql
   SELECT POID, Status, ApprovalLevel, ApprovedBy, ApprovedAt
   FROM LiteFlowDBO.dbo.PurchaseOrders
   WHERE POID = '16375C77-A831-493A-981F-CA9595DB1DFA';
   ```

## REBUILD INSTRUCTIONS
```bash
# Delete compiled class
Remove-Item target\classes\com\liteflow\service\procurement\ProcurementService.class -ErrorAction SilentlyContinue

# Compile
mvn compile -DskipTests

# Restart server (mandatory)
# Then hard refresh browser (Ctrl+Shift+R)
```

## TEST QUERY
```sql
SELECT POID, Status, ApprovalLevel, ApprovedBy, ApprovedAt
FROM LiteFlowDBO.dbo.PurchaseOrders
WHERE POID = '16375C77-A831-493A-981F-CA9595DB1DFA';
```

---
**IMPORTANT:** User has already restarted server multiple times. Bug persists across rebuilds.

