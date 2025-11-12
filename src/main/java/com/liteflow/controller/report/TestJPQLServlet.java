package com.liteflow.controller.report;

import jakarta.persistence.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/report/test-jpql")
public class TestJPQLServlet extends HttpServlet {
    
    private static final EntityManagerFactory emf = Persistence.createEntityManagerFactory("LiteFlowPU");
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        
        StringBuilder output = new StringBuilder();
        
        try {
            LocalDate endDate = LocalDate.now();
            LocalDate startDate = endDate.minusDays(30);
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            output.append("=== TEST JPQL QUERY DIRECTLY ===\n\n");
            output.append("Start: ").append(startDateTime).append("\n");
            output.append("End: ").append(endDateTime).append("\n\n");
            
            EntityManager em = emf.createEntityManager();
            
            try {
                // Test 1: Count OrderDetails
                String countJpql = "SELECT COUNT(od) FROM OrderDetail od " +
                                  "JOIN od.order o " +
                                  "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                                  "AND o.paymentStatus = 'Paid'";
                
                TypedQuery<Long> countQuery = em.createQuery(countJpql, Long.class);
                countQuery.setParameter("startDate", startDateTime);
                countQuery.setParameter("endDate", endDateTime);
                Long count = countQuery.getSingleResult();
                
                output.append("TEST 1 - OrderDetails count: ").append(count).append("\n\n");
                
                // Test 2: Simple product list
                String simpleJpql = "SELECT p.productID, p.name FROM OrderDetail od " +
                                   "JOIN od.productVariant pv " +
                                   "JOIN pv.product p " +
                                   "JOIN od.order o " +
                                   "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                                   "AND o.paymentStatus = 'Paid' " +
                                   "GROUP BY p.productID, p.name";
                
                TypedQuery<Object[]> simpleQuery = em.createQuery(simpleJpql, Object[].class);
                simpleQuery.setParameter("startDate", startDateTime);
                simpleQuery.setParameter("endDate", endDateTime);
                List<Object[]> simpleResults = simpleQuery.getResultList();
                
                output.append("TEST 2 - Simple product list: ").append(simpleResults.size()).append(" products\n");
                for (Object[] row : simpleResults) {
                    output.append("  - ").append(row[0]).append(": ").append(row[1]).append("\n");
                }
                output.append("\n");
                
                // Test 3: Full aggregation query
                String fullJpql = "SELECT p.productID, p.name, " +
                                 "SUM(od.quantity), SUM(od.totalPrice) " +
                                 "FROM OrderDetail od " +
                                 "JOIN od.productVariant pv " +
                                 "JOIN pv.product p " +
                                 "JOIN od.order o " +
                                 "WHERE o.orderDate BETWEEN :startDate AND :endDate " +
                                 "AND o.paymentStatus = 'Paid' " +
                                 "GROUP BY p.productID, p.name " +
                                 "ORDER BY SUM(od.totalPrice) DESC";
                
                TypedQuery<Object[]> fullQuery = em.createQuery(fullJpql, Object[].class);
                fullQuery.setParameter("startDate", startDateTime);
                fullQuery.setParameter("endDate", endDateTime);
                fullQuery.setMaxResults(10);
                List<Object[]> fullResults = fullQuery.getResultList();
                
                output.append("TEST 3 - Full aggregation: ").append(fullResults.size()).append(" products\n\n");
                for (Object[] row : fullResults) {
                    output.append(String.format("  %s | %s | Qty: %s | Revenue: %s\n", 
                        row[0], row[1], row[2], row[3]));
                }
                
                if (fullResults.isEmpty()) {
                    output.append("\n⚠️ WARNING: Query returned 0 results!\n");
                    output.append("This means JPQL query has a problem!\n");
                } else {
                    output.append("\n✅ SUCCESS: Query works!\n");
                }
                
            } finally {
                em.close();
            }
            
        } catch (Exception e) {
            output.append("\n❌ ERROR: ").append(e.getClass().getName()).append("\n");
            output.append("Message: ").append(e.getMessage()).append("\n\n");
            output.append("Stack trace:\n");
            for (StackTraceElement el : e.getStackTrace()) {
                output.append("  ").append(el.toString()).append("\n");
            }
        }
        
        response.getWriter().write(output.toString());
    }
}

