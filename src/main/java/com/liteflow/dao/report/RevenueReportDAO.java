package com.liteflow.dao.report;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.persistence.TypedQuery;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

/**
 * DAO for Revenue Report queries
 * Queries Orders, OrderDetails, Products for revenue analytics
 */
public class RevenueReportDAO {
    
    private static final EntityManagerFactory emf = Persistence.createEntityManagerFactory("LiteFlowPU");
    
    /**
     * Get total revenue for date range
     */
    public BigDecimal getTotalRevenue(LocalDate startDate, LocalDate endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            String jpql = "SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid'";
            
            TypedQuery<BigDecimal> query = em.createQuery(jpql, BigDecimal.class);
            query.setParameter("startDate", startDateTime);
            query.setParameter("endDate", endDateTime);
            
            BigDecimal result = query.getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
            
        } catch (Exception e) {
            System.err.println("❌ Error getting total revenue: " + e.getMessage());
            e.printStackTrace();
            return BigDecimal.ZERO;
        } finally {
            em.close();
        }
    }
    
    /**
     * Get total order count for date range
     */
    public long getTotalOrders(LocalDate startDate, LocalDate endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            String jpql = "SELECT COUNT(o) FROM Order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid'";
            
            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            query.setParameter("startDate", startDateTime);
            query.setParameter("endDate", endDateTime);
            
            return query.getSingleResult();
            
        } catch (Exception e) {
            System.err.println("❌ Error getting total orders: " + e.getMessage());
            e.printStackTrace();
            return 0;
        } finally {
            em.close();
        }
    }
    
    /**
     * Get daily revenue trend
     * Returns: List of [date, revenue, orderCount]
     */
    public List<Object[]> getDailyRevenueTrend(LocalDate startDate, LocalDate endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            String jpql = "SELECT CAST(o.orderDate AS LocalDate), " +
                         "SUM(o.totalAmount), COUNT(o) " +
                         "FROM Order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid' " +
                         "GROUP BY CAST(o.orderDate AS LocalDate) " +
                         "ORDER BY CAST(o.orderDate AS LocalDate)";
            
            TypedQuery<Object[]> query = em.createQuery(jpql, Object[].class);
            query.setParameter("startDate", startDateTime);
            query.setParameter("endDate", endDateTime);
            
            return query.getResultList();
            
        } catch (Exception e) {
            System.err.println("❌ Error getting daily trend: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get hourly revenue distribution
     * Returns: List of [hour, revenue]
     */
    public List<Object[]> getHourlyRevenue(LocalDate date) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = date.atStartOfDay();
            LocalDateTime endDateTime = date.atTime(LocalTime.MAX);
            
            // Use native query for HOUR function
            String sql = "SELECT DATEPART(HOUR, o.OrderDate) as Hour, " +
                        "SUM(o.TotalAmount) as Revenue " +
                        "FROM Orders o " +
                        "WHERE o.OrderDate BETWEEN :startDate AND :endDate " +
                        "AND o.PaymentStatus = 'Paid' " +
                        "GROUP BY DATEPART(HOUR, o.OrderDate) " +
                        "ORDER BY DATEPART(HOUR, o.OrderDate)";
            
            @SuppressWarnings("unchecked")
            List<Object[]> results = em.createNativeQuery(sql)
                .setParameter("startDate", startDateTime)
                .setParameter("endDate", endDateTime)
                .getResultList();
            
            return results;
            
        } catch (Exception e) {
            System.err.println("❌ Error getting hourly revenue: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get top selling products
     * Returns: List of [productId, productName, quantity, revenue]
     */
    public List<Object[]> getTopProducts(LocalDate startDate, LocalDate endDate, int limit) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            System.out.println("📊 getTopProducts DAO - Start date: " + startDateTime);
            System.out.println("📊 getTopProducts DAO - End date: " + endDateTime);
            
            // FIX: Use p.productId (camelCase) and p.name (entity field names)
            String jpql = "SELECT p.productId, p.name, " +
                         "SUM(od.quantity), SUM(od.totalPrice) " +
                         "FROM OrderDetail od " +
                         "JOIN od.productVariant pv " +
                         "JOIN pv.product p " +
                         "JOIN od.order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid' " +
                         "GROUP BY p.productId, p.name " +
                         "ORDER BY SUM(od.totalPrice) DESC";
            
            System.out.println("📊 JPQL Query: " + jpql);
            
            TypedQuery<Object[]> query = em.createQuery(jpql, Object[].class);
            query.setParameter("startDate", startDateTime);
            query.setParameter("endDate", endDateTime);
            query.setMaxResults(limit);
            
            List<Object[]> results = query.getResultList();
            System.out.println("📊 DAO Query returned " + results.size() + " results");
            
            if (results.isEmpty()) {
                System.out.println("⚠️ WARNING: Query returned 0 results!");
                System.out.println("   Check if:");
                System.out.println("   1. Orders exist in date range: " + startDate + " to " + endDate);
                System.out.println("   2. PaymentStatus = 'Paid'");
                System.out.println("   3. OrderDetails linked properly");
            } else {
                System.out.println("✅ Sample result: " + java.util.Arrays.toString(results.get(0)));
            }
            
            return results;
            
        } catch (Exception e) {
            System.err.println("❌ Error getting top products: " + e.getMessage());
            System.err.println("   Exception class: " + e.getClass().getName());
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get revenue by product category
     * Returns: List of [categoryName, revenue]
     */
    public List<Object[]> getRevenueByCategory(LocalDate startDate, LocalDate endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            // FIX: Use pc.category.name instead of pc.categoryName
            // ProductCategory entity has 'category' relationship, not direct 'categoryName' field
            String jpql = "SELECT pc.category.name, SUM(od.totalPrice) " +
                         "FROM OrderDetail od " +
                         "JOIN od.productVariant pv " +
                         "JOIN pv.product p " +
                         "JOIN p.productCategories pc " +
                         "JOIN od.order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid' " +
                         "GROUP BY pc.category.name " +
                         "ORDER BY SUM(od.totalPrice) DESC";
            
            TypedQuery<Object[]> query = em.createQuery(jpql, Object[].class);
            query.setParameter("startDate", startDateTime);
            query.setParameter("endDate", endDateTime);
            
            return query.getResultList();
            
        } catch (Exception e) {
            System.err.println("❌ Error getting revenue by category: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }
    
    /**
     * Get new customers count (first order in period)
     */
    public long getNewCustomers(LocalDate startDate, LocalDate endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            // Count distinct sessions (tables) whose first order is in this period
            String jpql = "SELECT COUNT(DISTINCT o.session) FROM Order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid'";
            
            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            query.setParameter("startDate", startDateTime);
            query.setParameter("endDate", endDateTime);
            
            return query.getSingleResult();
            
        } catch (Exception e) {
            System.err.println("❌ Error getting new customers: " + e.getMessage());
            e.printStackTrace();
            return 0;
        } finally {
            em.close();
        }
    }
    
    /**
     * Get returning customers count (for restaurant context, returns 0 as concept doesn't apply)
     */
    public long getReturningCustomers(LocalDate startDate, LocalDate endDate) {
        // Restaurant context: No user tracking, so returning customers concept doesn't apply
        // Return 0 to avoid errors
        return 0;
    }
    
    /**
     * Get peak hour (hour with highest revenue)
     */
    public Integer getPeakHour(LocalDate startDate, LocalDate endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            String sql = "SELECT TOP 1 DATEPART(HOUR, o.OrderDate) as Hour " +
                        "FROM Orders o " +
                        "WHERE o.OrderDate BETWEEN :startDate AND :endDate " +
                        "AND o.PaymentStatus = 'Paid' " +
                        "GROUP BY DATEPART(HOUR, o.OrderDate) " +
                        "ORDER BY SUM(o.TotalAmount) DESC";
            
            @SuppressWarnings("unchecked")
            List<Integer> results = em.createNativeQuery(sql)
                .setParameter("startDate", startDateTime)
                .setParameter("endDate", endDateTime)
                .getResultList();
            
            return results.isEmpty() ? null : results.get(0);
            
        } catch (Exception e) {
            System.err.println("❌ Error getting peak hour: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }
    
    /**
     * Get revenue for previous period (for comparison)
     */
    public BigDecimal getPreviousPeriodRevenue(LocalDate startDate, LocalDate endDate) {
        long days = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate);
        LocalDate prevStartDate = startDate.minusDays(days + 1);
        LocalDate prevEndDate = startDate.minusDays(1);
        
        return getTotalRevenue(prevStartDate, prevEndDate);
    }
    
    /**
     * DEBUG: Get all orders for today (regardless of payment status)
     * Used to debug why revenue might be showing as 0
     */
    public Map<String, Object> getDebugOrdersToday(LocalDate date) {
        EntityManager em = emf.createEntityManager();
        try {
            LocalDateTime startDateTime = date.atStartOfDay();
            LocalDateTime endDateTime = date.atTime(LocalTime.MAX);
            
            // Total orders count
            String countJpql = "SELECT COUNT(o) FROM Order o " +
                              "WHERE o.orderDate BETWEEN :startDate AND :endDate";
            Long totalOrders = em.createQuery(countJpql, Long.class)
                .setParameter("startDate", startDateTime)
                .setParameter("endDate", endDateTime)
                .getSingleResult();
            
            // Total revenue (all statuses)
            String revenueJpql = "SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o " +
                                "WHERE o.orderDate BETWEEN :startDate AND :endDate";
            BigDecimal totalRevenue = em.createQuery(revenueJpql, BigDecimal.class)
                .setParameter("startDate", startDateTime)
                .setParameter("endDate", endDateTime)
                .getSingleResult();
            
            // Count by payment status
            String statusJpql = "SELECT o.paymentStatus, COUNT(o), SUM(o.totalAmount) FROM Order o " +
                               "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                               "GROUP BY o.paymentStatus";
            @SuppressWarnings("unchecked")
            List<Object[]> statusResults = em.createQuery(statusJpql)
                .setParameter("startDate", startDateTime)
                .setParameter("endDate", endDateTime)
                .getResultList();
            
            Map<String, Object> debug = new HashMap<>();
            debug.put("totalOrders", totalOrders);
            debug.put("totalRevenue", totalRevenue);
            debug.put("startDateTime", startDateTime);
            debug.put("endDateTime", endDateTime);
            
            System.out.println("   🔍 DEBUG - All orders today: " + totalOrders);
            System.out.println("   🔍 DEBUG - All revenue today: " + totalRevenue);
            System.out.println("   🔍 DEBUG - Breakdown by payment status:");
            for (Object[] row : statusResults) {
                String status = (String) row[0];
                Long count = (Long) row[1];
                BigDecimal revenue = (BigDecimal) row[2];
                System.out.println("      - " + status + ": " + count + " orders, " + revenue + " VND");
            }
            
            return debug;
            
        } catch (Exception e) {
            System.err.println("❌ Error in debug query: " + e.getMessage());
            e.printStackTrace();
            return new HashMap<>();
        } finally {
            em.close();
        }
    }
}

