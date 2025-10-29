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
            
            String jpql = "SELECT p.productID, p.productName, " +
                         "SUM(od.quantity), SUM(od.totalPrice) " +
                         "FROM OrderDetail od " +
                         "JOIN od.productVariant pv " +
                         "JOIN pv.product p " +
                         "JOIN od.order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid' " +
                         "GROUP BY p.productID, p.productName " +
                         "ORDER BY SUM(od.totalPrice) DESC";
            
            TypedQuery<Object[]> query = em.createQuery(jpql, Object[].class);
            query.setParameter("startDate", startDateTime);
            query.setParameter("endDate", endDateTime);
            query.setMaxResults(limit);
            
            return query.getResultList();
            
        } catch (Exception e) {
            System.err.println("❌ Error getting top products: " + e.getMessage());
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
            
            String jpql = "SELECT pc.categoryName, SUM(od.totalPrice) " +
                         "FROM OrderDetail od " +
                         "JOIN od.productVariant pv " +
                         "JOIN pv.product p " +
                         "JOIN p.productCategories pc " +
                         "JOIN od.order o " +
                         "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                         "AND o.paymentStatus = 'Paid' " +
                         "GROUP BY pc.categoryName " +
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
}

