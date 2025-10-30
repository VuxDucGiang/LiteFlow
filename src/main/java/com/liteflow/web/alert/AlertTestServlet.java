package com.liteflow.web.alert;

import com.liteflow.service.alert.AlertSchedulerService;
import com.liteflow.service.alert.AlertService;
import com.liteflow.service.alert.GPTService;
import com.liteflow.service.alert.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Servlet for testing Alert System
 * Provides endpoints to manually trigger alerts for testing
 */
@WebServlet("/alert/test")
public class AlertTestServlet extends HttpServlet {
    
    private final AlertService alertService;
    private final AlertSchedulerService schedulerService;
    private final NotificationService notificationService;
    private final GPTService gptService;
    
    public AlertTestServlet() {
        this.alertService = new AlertService();
        this.schedulerService = new AlertSchedulerService();
        this.notificationService = new NotificationService();
        this.gptService = new GPTService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Show test page
        request.getRequestDispatcher("/alert/test.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing action parameter");
            return;
        }
        
        String result = "";
        boolean success = false;
        
        try {
            switch (action) {
                case "test-daily-summary":
                    result = testDailySummary();
                    success = true;
                    break;
                    
                case "test-po-pending":
                    result = testPOPending();
                    success = true;
                    break;
                    
                case "test-po-overdue":
                    result = testPOOverdue();
                    success = true;
                    break;
                    
                case "test-low-inventory":
                    result = testLowInventory();
                    success = true;
                    break;
                    
                case "test-out-of-stock":
                    result = testOutOfStock();
                    success = true;
                    break;
                    
                case "test-revenue-anomaly":
                    result = testRevenueAnomaly();
                    success = true;
                    break;
                    
                case "test-high-value-po":
                    result = testHighValuePO();
                    success = true;
                    break;
                    
                case "test-slack":
                    result = testSlackNotification();
                    success = true;
                    break;
                    
                case "test-telegram":
                    result = testTelegramNotification();
                    success = true;
                    break;
                    
                case "start-scheduler":
                    schedulerService.start();
                    result = "Scheduler started successfully";
                    success = true;
                    break;
                    
                case "stop-scheduler":
                    schedulerService.stop();
                    result = "Scheduler stopped successfully";
                    success = true;
                    break;
                    
                case "init-scheduled-runs":
                    schedulerService.initializeScheduledRuns();
                    result = "Scheduled runs initialized";
                    success = true;
                    break;
                    
                case "manual-check-inventory":
                    // Method removed from AlertSchedulerService
                    result = "Manual inventory check not available in current version";
                    success = false;
                    break;
                    
                case "manual-check-po-pending":
                    // Method removed from AlertSchedulerService
                    result = "Manual PO check not available in current version";
                    success = false;
                    break;
                    
                case "manual-check-all":
                    // Method removed from AlertSchedulerService  
                    result = "Manual all checks not available in current version";
                    success = false;
                    break;
                    
                default:
                    result = "Unknown action: " + action;
            }
            
        } catch (Exception e) {
            result = "Error: " + e.getMessage();
            e.printStackTrace();
        }
        
        // Redirect back with result
        response.sendRedirect(request.getContextPath() + "/alert/test?result=" + 
                            java.net.URLEncoder.encode(result, "UTF-8") + 
                            "&success=" + success);
    }
    
    private String testDailySummary() {
        // 🚫 DISABLED: Revenue notification không còn cần thiết (disabled by user request)
        System.out.println("🚫 TEST DISABLED: Daily Summary alert has been disabled");
        return "❌ Daily Summary Alert is DISABLED. Revenue notifications are no longer needed.";
    }
    
    private String testPOPending() {
        UUID alertId = alertService.triggerPOPending(
            "PO-2025-001",
            "Công ty TNHH ABC",
            5500000,
            3
        );
        return "PO Pending Alert triggered. ID: " + alertId;
    }
    
    private String testPOOverdue() {
        UUID alertId = alertService.triggerPOOverdue(
            "PO-2025-002",
            "Công ty XYZ",
            LocalDateTime.now().minusDays(5),
            5
        );
        return "PO Overdue Alert triggered. ID: " + alertId;
    }
    
    private String testLowInventory() {
        UUID alertId = alertService.triggerLowInventory(
            "Cà phê hạt Arabica",
            8,
            15
        );
        return "Low Inventory Alert triggered. ID: " + alertId;
    }
    
    private String testOutOfStock() {
        UUID alertId = alertService.triggerOutOfStock("Sữa tươi Vinamilk");
        return "Out of Stock Alert triggered. ID: " + alertId;
    }
    
    private String testRevenueAnomaly() {
        UUID alertId = alertService.triggerRevenueAnomaly(
            22500000,
            15000000,
            50.0
        );
        return "Revenue Anomaly Alert triggered. ID: " + alertId;
    }
    
    private String testHighValuePO() {
        UUID alertId = alertService.triggerHighValuePO(
            "PO-2025-003",
            "Công ty DEF",
            8500000,
            5000000
        );
        return "High Value PO Alert triggered. ID: " + alertId;
    }
    
    private String testSlackNotification() {
        boolean sent = notificationService.sendToDefaultSlack(
            "🧪 Test Notification",
            "This is a test notification from LiteFlow Alert System.\n\n" +
            "If you see this, Slack integration is working correctly! ✅",
            "LOW"
        );
        return sent ? "Slack notification sent successfully" : "Failed to send Slack notification";
    }
    
    private String testTelegramNotification() {
        boolean sent = notificationService.sendToDefaultTelegram(
            "🧪 Test Notification",
            "This is a test notification from LiteFlow Alert System.\n\n" +
            "If you see this, Telegram integration is working correctly! ✅",
            "LOW"
        );
        return sent ? "Telegram notification sent successfully" : "Failed to send Telegram notification";
    }
}

