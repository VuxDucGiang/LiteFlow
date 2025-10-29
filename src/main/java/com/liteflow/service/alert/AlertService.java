package com.liteflow.service.alert;

import com.liteflow.dao.alert.*;
import com.liteflow.model.alert.*;
import org.json.JSONObject;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Core Alert Service
 * Handles alert triggering, processing, and delivery
 */
public class AlertService {
    
    private final AlertConfigurationDAO alertConfigDAO;
    private final AlertHistoryDAO alertHistoryDAO;
    private final UserAlertPreferenceDAO userPrefDAO;
    private final NotificationService notificationService;
    private final GPTService gptService;
    
    public AlertService() {
        this.alertConfigDAO = new AlertConfigurationDAO();
        this.alertHistoryDAO = new AlertHistoryDAO();
        this.userPrefDAO = new UserAlertPreferenceDAO();
        this.notificationService = new NotificationService();
        this.gptService = new GPTService();
    }
    
    /**
     * Trigger an alert
     */
    public UUID triggerAlert(String alertType, String title, String message, 
                            JSONObject contextData, String priority) {
        
        System.out.println("🔔 Triggering alert: " + alertType + " - " + title);
        
        // Get alert configuration
        List<AlertConfiguration> configs = alertConfigDAO.getByType(alertType);
        if (configs.isEmpty()) {
            System.err.println("⚠️ No configuration found for alert type: " + alertType);
            return null;
        }
        
        AlertConfiguration config = configs.get(0);
        
        // Create alert history
        AlertHistory alert = new AlertHistory(alertType, title, message);
        alert.setAlertID(config.getAlertID());
        alert.setContextData(contextData != null ? contextData.toString() : null);
        alert.setPriority(priority != null ? priority : config.getPriority());
        alert.setDeliveryStatus("PENDING");
        
        // Generate GPT summary if enabled
        if (Boolean.TRUE.equals(config.getUseGPTSummary()) && gptService.isAvailable() && contextData != null) {
            try {
                String gptSummary = gptService.generateAlertSummary(alertType, contextData);
                alert.setGptSummary(gptSummary);
                
                // Use GPT summary as message if available
                if (gptSummary != null && !gptSummary.isEmpty() && !gptSummary.contains("không khả dụng")) {
                    alert.setMessage(message + "\n\n📊 AI Analysis:\n" + gptSummary);
                }
            } catch (Exception e) {
                System.err.println("⚠️ GPT summary generation failed: " + e.getMessage());
            }
        }
        
        // Save to database
        boolean saved = alertHistoryDAO.insert(alert);
        if (!saved) {
            System.err.println("❌ Failed to save alert to database");
            return null;
        }
        
        // Send notifications
        deliverAlert(alert, config);
        
        // Update last triggered
        alertConfigDAO.updateLastTriggered(config.getAlertID(), null);
        
        return alert.getHistoryID();
    }
    
    /**
     * Deliver alert to appropriate channels
     */
    private void deliverAlert(AlertHistory alert, AlertConfiguration config) {
        String title = alert.getTitle();
        String message = alert.getMessage();
        String priority = alert.getPriority();
        
        boolean anySuccess = false;
        
        // Send to Slack
        if (Boolean.TRUE.equals(config.getNotifySlack())) {
            boolean sent = notificationService.sendToDefaultSlack(title, message, priority);
            if (sent) {
                alert.setSentToSlack(true);
                anySuccess = true;
            }
        }
        
        // Send to Telegram
        if (Boolean.TRUE.equals(config.getNotifyTelegram())) {
            boolean sent = notificationService.sendToDefaultTelegram(title, message, priority);
            if (sent) {
                alert.setSentToTelegram(true);
                anySuccess = true;
            }
        }
        
        // Send to Email
        if (Boolean.TRUE.equals(config.getNotifyEmail())) {
            // TODO: Implement email delivery based on recipients
            System.out.println("📧 Email notification queued for: " + title);
            alert.setSentToEmail(true);
            anySuccess = true;
        }
        
        // In-app notification
        if (Boolean.TRUE.equals(config.getNotifyInApp())) {
            alert.setSentInApp(true);
            anySuccess = true;
        }
        
        // Update delivery status
        if (anySuccess) {
            alert.setDeliveryStatus("SENT");
            alert.setSentAt(LocalDateTime.now());
        } else {
            alert.setDeliveryStatus("FAILED");
            alert.setErrorMessage("No channels delivered successfully");
        }
        
        alertHistoryDAO.update(alert);
    }
    
    /**
     * Trigger Daily Summary alert
     */
    public UUID triggerDailySummary(JSONObject revenueData) {
        String title = "📊 Báo cáo doanh thu cuối ngày";
        
        // Build summary message
        StringBuilder message = new StringBuilder();
        message.append("**Tóm tắt doanh thu hôm nay:**\n\n");
        
        if (revenueData.has("totalRevenue")) {
            message.append("💰 Tổng doanh thu: ")
                   .append(String.format("%,.0f VND", revenueData.getDouble("totalRevenue")))
                   .append("\n");
        }
        if (revenueData.has("totalOrders")) {
            message.append("🛒 Số đơn hàng: ")
                   .append(revenueData.getInt("totalOrders"))
                   .append("\n");
        }
        if (revenueData.has("avgOrderValue")) {
            message.append("📈 Giá trị TB/đơn: ")
                   .append(String.format("%,.0f VND", revenueData.getDouble("avgOrderValue")))
                   .append("\n");
        }
        
        return triggerAlert("DAILY_SUMMARY", title, message.toString(), revenueData, "MEDIUM");
    }
    
    /**
     * Trigger PO Pending alert
     */
    public UUID triggerPOPending(String poId, String supplierName, double amount, int daysWaiting) {
        String title = "⏳ Đơn đặt hàng chờ duyệt";
        
        String message = String.format(
            "Đơn đặt hàng **%s** từ nhà cung cấp **%s** đang chờ phê duyệt.\n\n" +
            "💵 Giá trị: %,.0f VND\n" +
            "📅 Thời gian chờ: %d ngày\n\n" +
            "Vui lòng xem xét và phê duyệt.",
            poId, supplierName, amount, daysWaiting
        );
        
        JSONObject context = new JSONObject();
        context.put("poId", poId);
        context.put("supplierName", supplierName);
        context.put("amount", amount);
        context.put("daysWaiting", daysWaiting);
        
        return triggerAlert("PO_PENDING", title, message, context, "HIGH");
    }
    
    /**
     * Trigger Low Inventory alert
     */
    public UUID triggerLowInventory(String productName, int currentStock, int threshold) {
        String title = "📦 Cảnh báo tồn kho thấp";
        
        String message = String.format(
            "Sản phẩm **%s** sắp hết hàng!\n\n" +
            "📊 Tồn kho hiện tại: %d\n" +
            "⚠️ Ngưỡng cảnh báo: %d\n\n" +
            "Cần đặt hàng bổ sung.",
            productName, currentStock, threshold
        );
        
        JSONObject context = new JSONObject();
        context.put("productName", productName);
        context.put("currentStock", currentStock);
        context.put("threshold", threshold);
        
        return triggerAlert("LOW_INVENTORY", title, message, context, "MEDIUM");
    }
    
    /**
     * Trigger Out of Stock alert
     */
    public UUID triggerOutOfStock(String productName) {
        String title = "🚨 Sản phẩm hết hàng";
        
        String message = String.format(
            "Sản phẩm **%s** đã HẾT HÀNG!\n\n" +
            "⚠️ Cần đặt hàng gấp để tránh ảnh hưởng kinh doanh.",
            productName
        );
        
        JSONObject context = new JSONObject();
        context.put("productName", productName);
        
        return triggerAlert("OUT_OF_STOCK", title, message, context, "CRITICAL");
    }
    
    /**
     * Trigger Revenue Anomaly alert
     */
    public UUID triggerRevenueAnomaly(double currentRevenue, double averageRevenue, double deviationPercent) {
        String title = "📈 Phát hiện bất thường doanh thu";
        
        String direction = currentRevenue > averageRevenue ? "cao hơn" : "thấp hơn";
        String emoji = currentRevenue > averageRevenue ? "📈" : "📉";
        
        String message = String.format(
            "%s Doanh thu hiện tại **%s %.1f%%** so với trung bình!\n\n" +
            "💵 Doanh thu hiện tại: %,.0f VND\n" +
            "📊 Trung bình: %,.0f VND\n" +
            "📈 Chênh lệch: %.1f%%",
            emoji, direction, Math.abs(deviationPercent),
            currentRevenue, averageRevenue, Math.abs(deviationPercent)
        );
        
        JSONObject context = new JSONObject();
        context.put("currentRevenue", currentRevenue);
        context.put("averageRevenue", averageRevenue);
        context.put("deviationPercent", deviationPercent);
        
        return triggerAlert("REVENUE_ANOMALY", title, message, context, "HIGH");
    }
    
    /**
     * Trigger PO Overdue alert
     */
    public UUID triggerPOOverdue(String poId, String supplierName, LocalDateTime expectedDelivery, int daysOverdue) {
        String title = "⏰ Đơn đặt hàng quá hạn giao";
        
        String message = String.format(
            "Đơn đặt hàng **%s** từ nhà cung cấp **%s** đã quá hạn giao %d ngày!\n\n" +
            "📅 Ngày giao dự kiến: %s\n" +
            "⏰ Quá hạn: %d ngày\n\n" +
            "Cần liên hệ nhà cung cấp.",
            poId, supplierName, daysOverdue,
            expectedDelivery.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")),
            daysOverdue
        );
        
        JSONObject context = new JSONObject();
        context.put("poId", poId);
        context.put("supplierName", supplierName);
        context.put("expectedDelivery", expectedDelivery.toString());
        context.put("daysOverdue", daysOverdue);
        
        return triggerAlert("PO_OVERDUE", title, message, context, "HIGH");
    }
    
    /**
     * Trigger High Value PO alert
     */
    public UUID triggerHighValuePO(String poId, String supplierName, double amount, double threshold) {
        String title = "💰 Đơn đặt hàng giá trị cao";
        
        String message = String.format(
            "Đơn đặt hàng **%s** từ nhà cung cấp **%s** có giá trị cao, cần phê duyệt.\n\n" +
            "💵 Giá trị: %,.0f VND\n" +
            "⚠️ Ngưỡng: %,.0f VND\n\n" +
            "Vui lòng xem xét kỹ trước khi phê duyệt.",
            poId, supplierName, amount, threshold
        );
        
        JSONObject context = new JSONObject();
        context.put("poId", poId);
        context.put("supplierName", supplierName);
        context.put("amount", amount);
        context.put("threshold", threshold);
        
        return triggerAlert("PO_HIGH_VALUE", title, message, context, "HIGH");
    }
    
    /**
     * Get unread alerts count
     */
    public long getUnreadCount() {
        return alertHistoryDAO.getUnreadCount();
    }
    
    /**
     * Get unread alerts
     */
    public List<AlertHistory> getUnreadAlerts(int limit) {
        return alertHistoryDAO.getUnreadAlerts(limit);
    }
    
    /**
     * Get active alerts
     */
    public List<AlertHistory> getActiveAlerts(int limit) {
        return alertHistoryDAO.getActiveAlerts(limit);
    }
    
    /**
     * Get recent alerts
     */
    public List<AlertHistory> getRecentAlerts(int hours, int limit) {
        return alertHistoryDAO.getRecentAlerts(hours, limit);
    }
    
    /**
     * Mark alert as read
     */
    public boolean markAsRead(UUID historyID, UUID userId) {
        return alertHistoryDAO.markAsRead(historyID, userId);
    }
    
    /**
     * Mark all as read
     */
    public int markAllAsRead(UUID userId) {
        return alertHistoryDAO.markAllAsRead(userId);
    }
    
    /**
     * Dismiss alert
     */
    public boolean dismissAlert(UUID historyID, UUID userId) {
        return alertHistoryDAO.dismiss(historyID, userId);
    }
    
    /**
     * Get alert by ID
     */
    public AlertHistory getAlertById(UUID historyID) {
        return alertHistoryDAO.getById(historyID);
    }
    
    /**
     * Get alert statistics
     */
    public JSONObject getStatistics() {
        JSONObject stats = new JSONObject();
        
        try {
            stats.put("totalAlerts", alertHistoryDAO.getTotalCount());
            stats.put("unreadCount", alertHistoryDAO.getUnreadCount());
            stats.put("sentCount", alertHistoryDAO.getCountByStatus("SENT"));
            stats.put("failedCount", alertHistoryDAO.getCountByStatus("FAILED"));
            
            // Recent alerts by priority
            JSONObject byPriority = new JSONObject();
            byPriority.put("critical", alertHistoryDAO.getByPriority("CRITICAL", 10).size());
            byPriority.put("high", alertHistoryDAO.getByPriority("HIGH", 10).size());
            byPriority.put("medium", alertHistoryDAO.getByPriority("MEDIUM", 10).size());
            byPriority.put("low", alertHistoryDAO.getByPriority("LOW", 10).size());
            stats.put("byPriority", byPriority);
            
        } catch (Exception e) {
            System.err.println("❌ Failed to get alert statistics: " + e.getMessage());
        }
        
        return stats;
    }
    
    /**
     * Cleanup old alerts
     */
    public int cleanupOldAlerts(int daysOld) {
        return alertHistoryDAO.deleteOldAlerts(daysOld);
    }
    
    /**
     * Get all alert configurations
     */
    public List<AlertConfiguration> getAllConfigurations() {
        return alertConfigDAO.getAll();
    }
    
    /**
     * Get enabled configurations
     */
    public List<AlertConfiguration> getEnabledConfigurations() {
        return alertConfigDAO.getAllEnabled();
    }
    
    /**
     * Update alert configuration
     */
    public boolean updateConfiguration(AlertConfiguration config) {
        return alertConfigDAO.update(config);
    }
    
    /**
     * Enable/disable alert configuration
     */
    public boolean setConfigurationEnabled(UUID alertID, boolean enabled) {
        return alertConfigDAO.setEnabled(alertID, enabled);
    }
}

