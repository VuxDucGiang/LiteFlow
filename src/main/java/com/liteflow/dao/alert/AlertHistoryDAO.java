package com.liteflow.dao.alert;

import com.liteflow.model.alert.AlertHistory;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.persistence.TypedQuery;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * DAO for Alert History operations
 */
public class AlertHistoryDAO {
    
    private static final EntityManagerFactory emf = Persistence.createEntityManagerFactory("LiteFlowPU");
    
    /**
     * Get all alert history
     */
    public List<AlertHistory> getAll() {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah ORDER BY ah.triggeredAt DESC",
                AlertHistory.class
            );
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get alert history by ID
     */
    public AlertHistory getById(UUID historyID) {
        EntityManager em = emf.createEntityManager();
        try {
            return em.find(AlertHistory.class, historyID);
        } finally {
            em.close();
        }
    }
    
    /**
     * Get unread alerts (for notification bell)
     */
    public List<AlertHistory> getUnreadAlerts(int limit) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.isRead = false AND ah.isDismissed = false " +
                "AND ah.deliveryStatus IN ('SENT', 'PARTIAL') " +
                "AND (ah.expiresAt IS NULL OR ah.expiresAt > :now) " +
                "ORDER BY ah.priority DESC, ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setParameter("now", LocalDateTime.now());
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get unread count
     */
    public long getUnreadCount() {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(ah) FROM AlertHistory ah " +
                "WHERE ah.isRead = false AND ah.isDismissed = false " +
                "AND ah.deliveryStatus IN ('SENT', 'PARTIAL') " +
                "AND (ah.expiresAt IS NULL OR ah.expiresAt > :now)",
                Long.class
            );
            query.setParameter("now", LocalDateTime.now());
            return query.getSingleResult();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get active alerts (not read, not dismissed, not expired)
     */
    public List<AlertHistory> getActiveAlerts(int limit) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.isDismissed = false " +
                "AND (ah.expiresAt IS NULL OR ah.expiresAt > :now) " +
                "AND ah.deliveryStatus IN ('SENT', 'PARTIAL') " +
                "ORDER BY ah.priority DESC, ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setParameter("now", LocalDateTime.now());
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get alerts by type
     */
    public List<AlertHistory> getByType(String alertType, int limit) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.alertType = :alertType " +
                "ORDER BY ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setParameter("alertType", alertType);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get alerts by priority
     */
    public List<AlertHistory> getByPriority(String priority, int limit) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.priority = :priority AND ah.isDismissed = false " +
                "ORDER BY ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setParameter("priority", priority);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get alerts by date range
     */
    public List<AlertHistory> getByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.triggeredAt BETWEEN :startDate AND :endDate " +
                "ORDER BY ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setParameter("startDate", startDate);
            query.setParameter("endDate", endDate);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get alerts with GPT summary
     */
    public List<AlertHistory> getAlertsWithGPT(int limit) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.gptSummary IS NOT NULL " +
                "ORDER BY ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get recent alerts (last 24 hours)
     */
    public List<AlertHistory> getRecentAlerts(int hours, int limit) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.triggeredAt >= :since " +
                "ORDER BY ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setParameter("since", LocalDateTime.now().minusHours(hours));
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Find alerts by type since a specific time (for cooldown checks)
     * @param alertType Alert type
     * @param since Cutoff time
     * @return List of alerts
     */
    public List<AlertHistory> findByAlertTypeSince(String alertType, LocalDateTime since) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<AlertHistory> query = em.createQuery(
                "SELECT ah FROM AlertHistory ah " +
                "WHERE ah.alertType = :alertType " +
                "  AND ah.triggeredAt >= :since " +
                "ORDER BY ah.triggeredAt DESC",
                AlertHistory.class
            );
            query.setParameter("alertType", alertType);
            query.setParameter("since", since);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    /**
     * Insert new alert history
     */
    public boolean insert(AlertHistory alertHistory) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(alertHistory);
            em.getTransaction().commit();
            System.out.println("✅ AlertHistory inserted: " + alertHistory.getHistoryID() + " - " + alertHistory.getTitle());
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to insert AlertHistory: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
    
    /**
     * Update alert history
     */
    public boolean update(AlertHistory alertHistory) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(alertHistory);
            em.getTransaction().commit();
            System.out.println("✅ AlertHistory updated: " + alertHistory.getHistoryID());
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to update AlertHistory: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
    
    /**
     * Mark alert as read
     */
    public boolean markAsRead(UUID historyID, UUID userId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            AlertHistory alert = em.find(AlertHistory.class, historyID);
            if (alert != null) {
                alert.markAsRead(userId);
                em.merge(alert);
            }
            em.getTransaction().commit();
            System.out.println("✅ Alert marked as read: " + historyID);
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to mark as read: " + e.getMessage());
            return false;
        } finally {
            em.close();
        }
    }
    
    /**
     * Mark all as read
     */
    public int markAllAsRead(UUID userId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            int count = em.createQuery(
                "UPDATE AlertHistory ah SET ah.isRead = true, ah.readAt = :now, ah.readBy = :userId " +
                "WHERE ah.isRead = false"
            )
            .setParameter("now", LocalDateTime.now())
            .setParameter("userId", userId)
            .executeUpdate();
            em.getTransaction().commit();
            System.out.println("✅ Marked " + count + " alerts as read");
            return count;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to mark all as read: " + e.getMessage());
            return 0;
        } finally {
            em.close();
        }
    }
    
    /**
     * Dismiss alert
     */
    public boolean dismiss(UUID historyID, UUID userId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            AlertHistory alert = em.find(AlertHistory.class, historyID);
            if (alert != null) {
                alert.dismiss(userId);
                em.merge(alert);
            }
            em.getTransaction().commit();
            System.out.println("✅ Alert dismissed: " + historyID);
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to dismiss: " + e.getMessage());
            return false;
        } finally {
            em.close();
        }
    }
    
    /**
     * Record action taken
     */
    public boolean recordAction(UUID historyID, String action, UUID userId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            AlertHistory alert = em.find(AlertHistory.class, historyID);
            if (alert != null) {
                alert.recordAction(action, userId);
                em.merge(alert);
            }
            em.getTransaction().commit();
            System.out.println("✅ Action recorded for alert: " + historyID + " - " + action);
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to record action: " + e.getMessage());
            return false;
        } finally {
            em.close();
        }
    }
    
    /**
     * Delete old alerts (cleanup)
     */
    public int deleteOldAlerts(int daysOld) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            int count = em.createQuery(
                "DELETE FROM AlertHistory ah " +
                "WHERE ah.triggeredAt < :cutoffDate " +
                "AND ah.priority IN ('LOW', 'MEDIUM')"
            )
            .setParameter("cutoffDate", LocalDateTime.now().minusDays(daysOld))
            .executeUpdate();
            em.getTransaction().commit();
            System.out.println("✅ Deleted " + count + " old alerts");
            return count;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to delete old alerts: " + e.getMessage());
            return 0;
        } finally {
            em.close();
        }
    }
    
    /**
     * Get statistics
     */
    public long getTotalCount() {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(ah) FROM AlertHistory ah",
                Long.class
            );
            return query.getSingleResult();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get count by delivery status
     */
    public long getCountByStatus(String deliveryStatus) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(ah) FROM AlertHistory ah WHERE ah.deliveryStatus = :status",
                Long.class
            );
            query.setParameter("status", deliveryStatus);
            return query.getSingleResult();
        } finally {
            em.close();
        }
    }
    
    /**
     * Expire old alerts of a specific type
     * Used to ensure only the latest summary alert is shown
     * @param alertType Alert type to expire
     * @return Number of alerts expired
     */
    public int expireOldAlertsByType(String alertType) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            
            // Set expiresAt to now for all active alerts of this type
            int count = em.createQuery(
                "UPDATE AlertHistory ah " +
                "SET ah.expiresAt = :now " +
                "WHERE ah.alertType = :alertType " +
                "AND (ah.expiresAt IS NULL OR ah.expiresAt > :now)"
            )
            .setParameter("now", LocalDateTime.now())
            .setParameter("alertType", alertType)
            .executeUpdate();
            
            em.getTransaction().commit();
            
            if (count > 0) {
                System.out.println("✅ Expired " + count + " old alerts of type: " + alertType);
            }
            
            return count;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Failed to expire old alerts: " + e.getMessage());
            e.printStackTrace();
            return 0;
        } finally {
            em.close();
        }
    }
}


