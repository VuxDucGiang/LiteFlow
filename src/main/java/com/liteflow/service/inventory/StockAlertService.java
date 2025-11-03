package com.liteflow.service.inventory;

import com.liteflow.dao.alert.UserAlertPreferenceDAO;
import com.liteflow.dao.inventory.ProductStockDAO;
import com.liteflow.dao.inventory.StockAlertNotificationDAO;
import com.liteflow.model.alert.UserAlertPreference;
import com.liteflow.model.inventory.ProductVariant;
import com.liteflow.model.inventory.StockAlertNotification;
import com.liteflow.service.alert.NotificationService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

/**
 * Service for checking stock levels after payment and sending Telegram notifications
 */
public class StockAlertService {
    
    private static final EntityManagerFactory emf = Persistence.createEntityManagerFactory("LiteFlowPU");
    
    // Alert thresholds
    private static final int WARNING_THRESHOLD = 20;  // <20: Cảnh báo
    private static final int CRITICAL_THRESHOLD = 10; // <10: Nguy hiểm
    
    // Telegram Bot Token (can be configured via environment variable or default channel)
    private static final String TELEGRAM_BOT_TOKEN = System.getenv("TELEGRAM_BOT_TOKEN") != null 
        ? System.getenv("TELEGRAM_BOT_TOKEN") 
        : "8462540667:AAGCDTkl1kdibhVffVZSmIbSv-kyMoJkPGI"; // Default from user config
    
    private final StockAlertNotificationDAO notificationDAO;
    private final ProductStockDAO productStockDAO;
    private final UserAlertPreferenceDAO userAlertPreferenceDAO;
    private final NotificationService notificationService;
    
    public StockAlertService() {
        this.notificationDAO = new StockAlertNotificationDAO();
        this.productStockDAO = new ProductStockDAO();
        this.userAlertPreferenceDAO = new UserAlertPreferenceDAO();
        this.notificationService = new NotificationService();
    }
    
    /**
     * Check stock levels for products after payment and send alerts if needed
     * This method should be called asynchronously after payment completion
     * @param orderItems List of items from payment (each item contains variantId and quantity)
     * @param userId User ID to send notification to (null = send to all users with Telegram enabled)
     */
    public void checkAndSendAlertsAfterPayment(List<Map<String, Object>> orderItems, UUID userId) {
        if (orderItems == null || orderItems.isEmpty()) {
            System.out.println("⚠️ No order items to check stock alerts");
            return;
        }
        
        // Run asynchronously to not block payment response
        CompletableFuture.runAsync(() -> {
            EntityManager em = null;
            try {
                em = emf.createEntityManager();
                
                System.out.println("🔍 Checking stock levels for " + orderItems.size() + " items after payment...");
                
                for (Map<String, Object> item : orderItems) {
                    try {
                        String variantIdStr = (String) item.get("variantId");
                        if (variantIdStr == null || variantIdStr.isEmpty()) {
                            continue;
                        }
                        
                        UUID productVariantId = UUID.fromString(variantIdStr);
                        
                        // Get current stock level
                        int currentStock = productStockDAO.getStockLevel(productVariantId);
                        
                        System.out.println("📦 ProductVariant: " + productVariantId + " | Current Stock: " + currentStock);
                        
                        // Check if notification should be sent for this variant
                        checkAndSendAlertForVariant(em, productVariantId, currentStock, userId);
                        
                    } catch (Exception e) {
                        System.err.println("❌ Error checking stock alert for item: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
                
                System.out.println("✅ Stock alert check completed");
                
            } catch (Exception e) {
                System.err.println("❌ Error in stock alert check: " + e.getMessage());
                e.printStackTrace();
            } finally {
                if (em != null && em.isOpen()) {
                    em.close();
                }
            }
        });
    }
    
    /**
     * Check and send alert for a specific product variant
     */
    private void checkAndSendAlertForVariant(EntityManager em, UUID variantId, int currentStock, UUID targetUserId) {
        try {
            // Get ProductVariant details
            ProductVariant variant = em.find(ProductVariant.class, variantId);
            if (variant == null) {
                System.err.println("⚠️ ProductVariant not found: " + variantId);
                return;
            }
            
            String productName = variant.getProduct().getName();
            String size = variant.getSize();
            
            // Determine which thresholds need alerts
            if (currentStock <= CRITICAL_THRESHOLD && currentStock > 0) {
                // Critical alert (<10)
                sendAlertIfNeeded(em, variantId, productName, size, currentStock, CRITICAL_THRESHOLD, targetUserId);
            }
            
            if (currentStock <= WARNING_THRESHOLD && currentStock > CRITICAL_THRESHOLD) {
                // Warning alert (10 < stock <= 20)
                sendAlertIfNeeded(em, variantId, productName, size, currentStock, WARNING_THRESHOLD, targetUserId);
            }
            
            // Reset notification state if stock increased above threshold
            if (currentStock > WARNING_THRESHOLD) {
                notificationDAO.resetNotificationState(variantId, WARNING_THRESHOLD);
            }
            if (currentStock > CRITICAL_THRESHOLD) {
                notificationDAO.resetNotificationState(variantId, CRITICAL_THRESHOLD);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error checking alert for variant " + variantId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Send alert if notification hasn't been sent for this threshold yet
     */
    private void sendAlertIfNeeded(EntityManager em, UUID variantId, String productName, String size, 
                                   int currentStock, int threshold, UUID targetUserId) {
        
        // Get list of users to notify
        List<UUID> userIdsToNotify = getUsersToNotify(targetUserId);
        
        if (userIdsToNotify.isEmpty()) {
            System.out.println("⚠️ No users configured for Telegram notifications");
            return;
        }
        
        for (UUID userId : userIdsToNotify) {
            EntityManager notificationEm = null;
            try {
                // Check if notification has already been sent for this user + variant + threshold
                if (notificationDAO.hasNotificationBeenSent(userId, variantId, threshold)) {
                    System.out.println("⏭️ Notification already sent for User " + userId + 
                                     " | Variant " + variantId + " | Threshold " + threshold);
                    continue;
                }
                
                // Get user's Telegram Chat ID
                UserAlertPreference preference = userAlertPreferenceDAO.getByUserId(userId);
                if (preference == null || preference.getTelegramUserID() == null || 
                    preference.getTelegramUserID().isEmpty()) {
                    System.out.println("⚠️ User " + userId + " does not have Telegram Chat ID configured");
                    continue;
                }
                
                if (preference.getEnableTelegram() == null || !preference.getEnableTelegram()) {
                    System.out.println("⚠️ User " + userId + " has Telegram notifications disabled");
                    continue;
                }
                
                String chatId = preference.getTelegramUserID();
                
                // Build message (không thêm emoji vào title vì sendTelegramToUser đã thêm rồi)
                String title;
                String message;
                String priority;
                
                if (threshold == CRITICAL_THRESHOLD) {
                    title = "NGUY HIỂM TỒN KHO";
                    message = String.format(
                        "Sản phẩm <b>%s</b> (Size: <b>%s</b>) chỉ còn <b>%d</b> đơn vị trong kho.\n\n" +
                        "Cần nhập hàng ngay để tránh thiếu hụt!",
                        escapeHtmlForTelegram(productName), escapeHtmlForTelegram(size), currentStock
                    );
                    priority = "CRITICAL";
                } else {
                    title = "CẢNH BÁO TỒN KHO";
                    message = String.format(
                        "Sản phẩm <b>%s</b> (Size: <b>%s</b>) còn <b>%d</b> đơn vị trong kho.\n\n" +
                        "Nên nhập hàng sớm để đảm bảo cung ứng.",
                        escapeHtmlForTelegram(productName), escapeHtmlForTelegram(size), currentStock
                    );
                    priority = "HIGH";
                }
                
                // Send Telegram message
                boolean sent = notificationService.sendTelegramToUser(chatId, title, message, priority, TELEGRAM_BOT_TOKEN);
                
                if (sent) {
                    // Mark notification as sent (use separate EntityManager for transaction)
                    notificationEm = emf.createEntityManager();
                    notificationEm.getTransaction().begin();
                    
                    StockAlertNotification notification = new StockAlertNotification();
                    notification.setProductVariant(notificationEm.getReference(ProductVariant.class, variantId));
                    notification.setUserId(userId);
                    notification.setAlertThreshold(threshold);
                    notification.setStockLevel(currentStock);
                    notification.setMessageSent(message);
                    
                    notificationEm.persist(notification);
                    notificationEm.getTransaction().commit();
                    
                    System.out.println("✅ Stock alert sent to User " + userId + 
                                     " | Product: " + productName + " | Stock: " + currentStock + 
                                     " | Threshold: " + threshold);
                } else {
                    System.err.println("❌ Failed to send stock alert to User " + userId);
                }
                
            } catch (Exception e) {
                if (notificationEm != null && notificationEm.getTransaction().isActive()) {
                    notificationEm.getTransaction().rollback();
                }
                System.err.println("❌ Error sending alert to user " + userId + ": " + e.getMessage());
                e.printStackTrace();
            } finally {
                if (notificationEm != null && notificationEm.isOpen()) {
                    notificationEm.close();
                }
            }
        }
    }
    
    /**
     * Get list of user IDs to notify
     * If targetUserId is provided, only notify that user
     * Otherwise, notify all users with Telegram enabled
     */
    private List<UUID> getUsersToNotify(UUID targetUserId) {
        if (targetUserId != null) {
            return List.of(targetUserId);
        }
        
        // Get all users with Telegram enabled
        List<UserAlertPreference> preferences = userAlertPreferenceDAO.getUsersWithTelegramEnabled();
            return preferences.stream()
            .filter(p -> p.getTelegramUserID() != null && !p.getTelegramUserID().isEmpty())
            .map(UserAlertPreference::getUserID)
            .toList();
    }
    
    /**
     * Escape HTML cho Telegram (chỉ escape các ký tự đặc biệt, giữ lại tags HTML hợp lệ)
     */
    private String escapeHtmlForTelegram(String text) {
        if (text == null) return "";
        // Telegram hỗ trợ HTML nhưng cần escape các ký tự đặc biệt
        return text
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    }
}

