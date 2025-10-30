USE LiteFlowDBO;

-- ============================================================
-- VERIFY: Revenue Notification Đã Bị Disable
-- ============================================================

PRINT '═══════════════════════════════════════════════════════';
PRINT '  VERIFICATION: Revenue Notification Disabled';
PRINT '═══════════════════════════════════════════════════════';
PRINT '';

-- 1. Check no visible DAILY_SUMMARY alerts
PRINT '1️⃣ DAILY_SUMMARY Alerts (Should be 0)';
PRINT '────────────────────────────────────────────────────';
SELECT COUNT(*) AS VisibleAlerts
FROM AlertHistory
WHERE AlertType = 'DAILY_SUMMARY'
  AND (ExpiresAt IS NULL OR ExpiresAt > GETDATE());
PRINT '   Expected: 0';
PRINT '';

-- 2. Check all DAILY_SUMMARY alerts are expired
PRINT '2️⃣ All DAILY_SUMMARY Alerts Status';
PRINT '────────────────────────────────────────────────────';
SELECT 
    COUNT(*) AS TotalAlerts,
    SUM(CASE WHEN ExpiresAt <= GETDATE() THEN 1 ELSE 0 END) AS Expired,
    SUM(CASE WHEN ExpiresAt > GETDATE() OR ExpiresAt IS NULL THEN 1 ELSE 0 END) AS Active
FROM AlertHistory
WHERE AlertType = 'DAILY_SUMMARY';
PRINT '   Expected: Active = 0, all should be Expired';
PRINT '';

-- 3. Check configuration disabled
PRINT '3️⃣ Alert Configurations Status';
PRINT '────────────────────────────────────────────────────';
SELECT 
    AlertType,
    Name,
    IsEnabled,
    CASE 
        WHEN IsEnabled = 1 THEN '✅ ACTIVE'
        ELSE '🚫 DISABLED'
    END AS Status
FROM AlertConfigurations
ORDER BY AlertType;
PRINT '   Expected: DAILY_SUMMARY = DISABLED (0)';
PRINT '';

-- 4. Check other alerts still active
PRINT '4️⃣ Other Active Alerts (Should Still Work)';
PRINT '────────────────────────────────────────────────────';
SELECT 
    AlertType,
    COUNT(*) AS VisibleCount
FROM AlertHistory
WHERE (ExpiresAt IS NULL OR ExpiresAt > GETDATE())
  AND DeliveryStatus = 'SENT'
GROUP BY AlertType
ORDER BY COUNT(*) DESC;
PRINT '   PO_PENDING and other alerts should still work';
PRINT '';

PRINT '═══════════════════════════════════════════════════════';
PRINT '✅ VERIFICATION COMPLETE';
PRINT '═══════════════════════════════════════════════════════';
PRINT '';
PRINT 'What to Check in UI:';
PRINT '  1. Refresh notification bell';
PRINT '  2. Should NOT see any revenue notifications';
PRINT '  3. Should still see PO pending notifications (if any)';
PRINT '  4. /alert/test page: "Test Daily Summary" button';
PRINT '     → Should show: "DISABLED" message';
PRINT '';
PRINT '═══════════════════════════════════════════════════════';

