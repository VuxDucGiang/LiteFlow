package com.liteflow.service.procurement;

import com.liteflow.dao.alert.UserAlertPreferenceDAO;
import com.liteflow.dao.procurement.POAlertNotificationDAO;
import com.liteflow.dao.procurement.PurchaseOrderDAO;
import com.liteflow.dao.procurement.SupplierDAO;
import com.liteflow.model.alert.UserAlertPreference;
import com.liteflow.model.procurement.POAlertNotification;
import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.service.alert.NotificationService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

/**
 * Service for sending Telegram notifications when new Purchase Orders are created
 */
public class POAlertService {
    
    private static final EntityManagerFactory emf = Persistence.createEntityManagerFactory("LiteFlowPU");
    
    // Telegram Bot Token (can be configured via environment variable or default channel)
    private static final String TELEGRAM_BOT_TOKEN = System.getenv("TELEGRAM_BOT_TOKEN") != null 
        ? System.getenv("TELEGRAM_BOT_TOKEN") 
        : "Your:telegrambotToken"; // Default from user config
    
    private final POAlertNotificationDAO notificationDAO;
    private final PurchaseOrderDAO poDAO;
    private final SupplierDAO supplierDAO;
    private final UserAlertPreferenceDAO userAlertPreferenceDAO;
    private final NotificationService notificationService;
    
    public POAlertService() {
        this.notificationDAO = new POAlertNotificationDAO();
        this.poDAO = new PurchaseOrderDAO();
        this.supplierDAO = new SupplierDAO();
        this.userAlertPreferenceDAO = new UserAlertPreferenceDAO();
        this.notificationService = new NotificationService();
    }
    
    /**
     * Send Telegram notification for new PO creation
     * This method should be called asynchronously after PO creation
     * @param poid PO ID of the newly created purchase order
     * @param targetUserId User ID to send notification to (null = send to all users with Telegram enabled)
     */
    public void sendPOCreationNotification(UUID poid, UUID targetUserId) {
        System.out.println("🔔 Initiating PO notification for POID: " + poid);
        System.out.println("🔔 Target user ID: " + (targetUserId != null ? targetUserId : "null (all users)"));
        
        // Run asynchronously to not block PO creation response
        CompletableFuture.runAsync(() -> {
            EntityManager em = null;
            try {
                em = emf.createEntityManager();
                
                System.out.println("🔔 [Async] Checking PO notification for POID: " + poid);
                
                // Get PO details
                PurchaseOrder po = poDAO.findById(poid);
                if (po == null) {
                    System.err.println("⚠️ PO not found: " + poid);
                    return;
                }
                
                // Get supplier name
                String supplierName = "Nhà cung cấp";
                if (po.getSupplierID() != null) {
                    try {
                        com.liteflow.model.procurement.Supplier supplier = supplierDAO.findById(po.getSupplierID());
                        if (supplier != null && supplier.getName() != null) {
                            supplierName = supplier.getName();
                        }
                    } catch (Exception e) {
                        System.err.println("⚠️ Error getting supplier: " + e.getMessage());
                    }
                }
                
                // Get list of users to notify
                System.out.println("🔍 Getting users to notify...");
                List<UUID> userIdsToNotify = getUsersToNotify(targetUserId);
                System.out.println("🔍 Found " + userIdsToNotify.size() + " users to notify");
                
                if (userIdsToNotify.isEmpty()) {
                    System.err.println("⚠️ No users configured for Telegram notifications - Check UserAlertPreferences table");
                    return;
                }
                
                for (UUID userId : userIdsToNotify) {
                    EntityManager notificationEm = null;
                    try {
                        // Check if notification has already been sent for this user + PO
                        if (notificationDAO.hasNotificationBeenSent(userId, poid)) {
                            System.out.println("⏭️ Notification already sent for User " + userId + " | PO " + poid);
                            continue;
                        }
                        
                        // Get user's Telegram Chat ID
                        System.out.println("🔍 Checking User " + userId + " Telegram settings...");
                        UserAlertPreference preference = userAlertPreferenceDAO.getByUserId(userId);
                        if (preference == null) {
                            System.err.println("⚠️ User " + userId + " does not have UserAlertPreference configured");
                            continue;
                        }
                        
                        if (preference.getTelegramUserID() == null || preference.getTelegramUserID().isEmpty()) {
                            System.err.println("⚠️ User " + userId + " does not have Telegram Chat ID configured");
                            continue;
                        }
                        
                        if (preference.getEnableTelegram() == null || !preference.getEnableTelegram()) {
                            System.err.println("⚠️ User " + userId + " has Telegram notifications disabled");
                            continue;
                        }
                        
                        String chatId = preference.getTelegramUserID();
                        System.out.println("✅ User " + userId + " has Telegram enabled with Chat ID: " + chatId);
                        
                        // Build message
                        String title = "📋 ĐƠN ĐẶT HÀNG MỚI";
                        
                        // Format amount
                        DecimalFormat df = new DecimalFormat("#,##0", DecimalFormatSymbols.getInstance(Locale.US));
                        String formattedAmount = df.format(po.getTotalAmount() != null ? po.getTotalAmount() : 0);
                        
                        String message = String.format(
                            "Đơn đặt hàng mới đã được tạo:\n\n" +
                            "<b>Mã đơn:</b> %s\n" +
                            "<b>Nhà cung cấp:</b> %s\n" +
                            "<b>Tổng tiền:</b> %s VNĐ\n" +
                            "<b>Ngày giao dự kiến:</b> %s\n" +
                            "<b>Trạng thái:</b> %s",
                            poid.toString().substring(0, 8).toUpperCase(),
                            escapeHtmlForTelegram(supplierName),
                            formattedAmount,
                            po.getExpectedDelivery() != null 
                                ? po.getExpectedDelivery().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                                : "Chưa xác định",
                            po.getStatus() != null ? po.getStatus() : "PENDING"
                        );
                        
                        if (po.getNotes() != null && !po.getNotes().trim().isEmpty()) {
                            message += "\n<b>Ghi chú:</b> " + escapeHtmlForTelegram(po.getNotes());
                        }
                        
                        String priority = "HIGH";
                        
                        // Send Telegram message
                        System.out.println("📤 Sending Telegram message to Chat ID: " + chatId + " for PO: " + poid);
                        boolean sent = notificationService.sendTelegramToUser(chatId, title, message, priority, TELEGRAM_BOT_TOKEN);
                        System.out.println("📤 Telegram send result: " + (sent ? "SUCCESS" : "FAILED"));
                        
                        if (sent) {
                            // Mark notification as sent (use separate EntityManager for transaction)
                            notificationEm = emf.createEntityManager();
                            notificationEm.getTransaction().begin();
                            
                            POAlertNotification notification = new POAlertNotification();
                            notification.setPoid(poid);
                            notification.setUserId(userId);
                            notification.setMessageSent(message);
                            
                            notificationEm.persist(notification);
                            notificationEm.getTransaction().commit();
                            
                            System.out.println("✅ PO notification sent to User " + userId + " | PO: " + poid);
                        } else {
                            System.err.println("❌ Failed to send PO notification to User " + userId);
                        }
                        
                    } catch (Exception e) {
                        if (notificationEm != null && notificationEm.getTransaction().isActive()) {
                            notificationEm.getTransaction().rollback();
                        }
                        System.err.println("❌ Error sending PO notification to user " + userId + ": " + e.getMessage());
                        e.printStackTrace();
                    } finally {
                        if (notificationEm != null && notificationEm.isOpen()) {
                            notificationEm.close();
                        }
                    }
                }
                
                System.out.println("✅ PO notification check completed for POID: " + poid);
                
            } catch (Exception e) {
                System.err.println("❌ [Async] Error in PO notification check: " + e.getMessage());
                e.printStackTrace();
            } finally {
                if (em != null && em.isOpen()) {
                    em.close();
                }
            }
        }).exceptionally(ex -> {
            // Handle any exceptions that weren't caught in the async task
            System.err.println("❌ [CompletableFuture] Unhandled exception in PO notification: " + ex.getMessage());
            ex.printStackTrace();
            return null;
        });
        
        System.out.println("🔔 PO notification task submitted for POID: " + poid);
    }
    
    /**
     * Send Telegram notification for PO status update (approve/reject)
     * @param poid PO ID
     * @param newStatus New status (APPROVED, REJECTED)
     * @param approverId User ID who approved/rejected
     */
    public void sendPOStatusUpdateNotification(UUID poid, String newStatus, UUID approverId) {
        // Run asynchronously to not block approval/rejection response
        CompletableFuture.runAsync(() -> {
            EntityManager em = null;
            try {
                em = emf.createEntityManager();
                
                System.out.println("🔔 Sending PO status update notification for POID: " + poid + " | Status: " + newStatus);
                
                // Get PO details
                PurchaseOrder po = poDAO.findById(poid);
                if (po == null) {
                    System.err.println("⚠️ PO not found: " + poid);
                    return;
                }
                
                // Get supplier name
                String supplierName = "Nhà cung cấp";
                if (po.getSupplierID() != null) {
                    try {
                        com.liteflow.model.procurement.Supplier supplier = supplierDAO.findById(po.getSupplierID());
                        if (supplier != null && supplier.getName() != null) {
                            supplierName = supplier.getName();
                        }
                    } catch (Exception e) {
                        System.err.println("⚠️ Error getting supplier: " + e.getMessage());
                    }
                }
                
                // Get list of users to notify (same users who received creation notification)
                List<UUID> userIdsToNotify = getUsersToNotify(null); // Notify all users with Telegram enabled
                
                if (userIdsToNotify.isEmpty()) {
                    System.out.println("⚠️ No users configured for Telegram notifications");
                    return;
                }
                
                for (UUID userId : userIdsToNotify) {
                    try {
                        // Get user's Telegram Chat ID
                        UserAlertPreference preference = userAlertPreferenceDAO.getByUserId(userId);
                        if (preference == null || preference.getTelegramUserID() == null || 
                            preference.getTelegramUserID().isEmpty()) {
                            continue;
                        }
                        
                        if (preference.getEnableTelegram() == null || !preference.getEnableTelegram()) {
                            continue;
                        }
                        
                        String chatId = preference.getTelegramUserID();
                        
                        // Build update message
                        String title;
                        String message;
                        String priority;
                        
                        if ("APPROVED".equals(newStatus)) {
                            title = "✅ ĐƠN ĐẶT HÀNG ĐÃ ĐƯỢC DUYỆT";
                            priority = "MEDIUM";
                        } else if ("REJECTED".equals(newStatus)) {
                            title = "❌ ĐƠN ĐẶT HÀNG ĐÃ BỊ TỪ CHỐI";
                            priority = "HIGH";
                        } else {
                            title = "📋 CẬP NHẬT ĐƠN ĐẶT HÀNG";
                            priority = "MEDIUM";
                        }
                        
                        // Format amount
                        DecimalFormat df = new DecimalFormat("#,##0", DecimalFormatSymbols.getInstance(Locale.US));
                        String formattedAmount = df.format(po.getTotalAmount() != null ? po.getTotalAmount() : 0);
                        
                        // Build message
                        message = String.format(
                            "Đơn đặt hàng đã được cập nhật trạng thái:\n\n" +
                            "<b>Mã đơn:</b> %s\n" +
                            "<b>Nhà cung cấp:</b> %s\n" +
                            "<b>Tổng tiền:</b> %s VNĐ\n" +
                            "<b>Trạng thái cũ:</b> %s\n" +
                            "<b>Trạng thái mới:</b> <b>%s</b>\n",
                            poid.toString().substring(0, 8).toUpperCase(),
                            escapeHtmlForTelegram(supplierName),
                            formattedAmount,
                            "PENDING", // Trạng thái cũ
                            newStatus
                        );
                        
                        if (po.getApprovedAt() != null) {
                            message += "<b>Thời gian:</b> " + 
                                po.getApprovedAt().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) + "\n";
                        }
                        
                        if (po.getNotes() != null && !po.getNotes().trim().isEmpty()) {
                            message += "<b>Ghi chú:</b> " + escapeHtmlForTelegram(po.getNotes());
                        }
                        
                        // Send Telegram message (new message, not edit)
                        boolean sent = notificationService.sendTelegramToUser(chatId, title, message, priority, TELEGRAM_BOT_TOKEN);
                        
                        if (sent) {
                            System.out.println("✅ PO status update notification sent to User " + userId + " | PO: " + poid + " | Status: " + newStatus);
                        } else {
                            System.err.println("❌ Failed to send PO status update notification to User " + userId);
                        }
                        
                    } catch (Exception e) {
                        System.err.println("❌ Error sending PO status update to user " + userId + ": " + e.getMessage());
                        e.printStackTrace();
                    }
                }
                
                System.out.println("✅ PO status update notification completed for POID: " + poid);
                
            } catch (Exception e) {
                System.err.println("❌ Error in PO status update notification: " + e.getMessage());
                e.printStackTrace();
            } finally {
                if (em != null && em.isOpen()) {
                    em.close();
                }
            }
        });
    }
    
    /**
     * Get list of user IDs to notify
     * If targetUserId is provided, only notify that user
     * Otherwise, notify all users with Telegram enabled
     */
    private List<UUID> getUsersToNotify(UUID targetUserId) {
        if (targetUserId != null) {
            System.out.println("🔍 Target user specified: " + targetUserId);
            // Still check if this user has Telegram enabled and Chat ID
            UserAlertPreference preference = userAlertPreferenceDAO.getByUserId(targetUserId);
            if (preference != null && 
                Boolean.TRUE.equals(preference.getEnableTelegram()) && 
                Boolean.TRUE.equals(preference.getEnableNotifications()) &&
                preference.getTelegramUserID() != null && 
                !preference.getTelegramUserID().isEmpty()) {
                System.out.println("✅ Target user has Telegram enabled with Chat ID");
                return List.of(targetUserId);
            } else {
                System.err.println("⚠️ Target user does not have Telegram enabled or Chat ID - will try all users");
                // Fall through to get all users
            }
        }
        
        // Get all users with Telegram enabled
        System.out.println("🔍 Getting all users with Telegram enabled...");
        List<UserAlertPreference> preferences = userAlertPreferenceDAO.getUsersWithTelegramEnabled();
        System.out.println("🔍 Found " + preferences.size() + " users with Telegram enabled");
        
        if (preferences.isEmpty()) {
            System.err.println("⚠️ No users found with Telegram enabled in database!");
        }
        
        List<UUID> userIds = preferences.stream()
            .filter(p -> {
                boolean hasChatId = p.getTelegramUserID() != null && !p.getTelegramUserID().isEmpty();
                if (!hasChatId) {
                    System.out.println("⚠️ User " + p.getUserID() + " has Telegram enabled but no Chat ID");
                } else {
                    System.out.println("✅ User " + p.getUserID() + " has Telegram enabled with Chat ID: " + p.getTelegramUserID());
                }
                return hasChatId;
            })
            .map(UserAlertPreference::getUserID)
            .toList();
        
        System.out.println("🔍 Filtered to " + userIds.size() + " users with Telegram Chat ID");
        return userIds;
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

