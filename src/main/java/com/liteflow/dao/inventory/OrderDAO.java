package com.liteflow.dao.inventory;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.inventory.*;
import com.liteflow.model.auth.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

public class OrderDAO {
    
    /**
     * Tạo order mới với danh sách items
     * @param tableId ID của bàn
     * @param items Danh sách món (productVariantId, quantity, unitPrice)
     * @param userId ID của user tạo order
     * @return UUID của order được tạo
     */
    public UUID createOrder(UUID tableId, List<Map<String, Object>> items, UUID userId) {
        EntityManager em = BaseDAO.emf.createEntityManager();
        
        try {
            em.getTransaction().begin();
            
            // 1. Kiểm tra xem bàn có session đang active không
            TableSession session = findOrCreateActiveSession(em, tableId, userId);
            
            // 2. Tạo order number
            String orderNumber = generateOrderNumber(em);
            
            // 3. Tạo Order entity
            Order order = new Order();
            order.setOrderId(UUID.randomUUID());
            order.setSession(session);
            order.setOrderNumber(orderNumber);
            order.setOrderDate(LocalDateTime.now());
            order.setStatus("Pending"); // Trạng thái chờ làm
            order.setPaymentStatus("Unpaid");
            
            // Tính toán tổng tiền
            BigDecimal subtotal = BigDecimal.ZERO;
            
            // 4. Tạo OrderDetails
            List<OrderDetail> orderDetails = new ArrayList<>();
            for (Map<String, Object> item : items) {
                String variantIdStr = (String) item.get("variantId");
                if (variantIdStr == null || variantIdStr.isEmpty()) {
                    continue;
                }
                
                UUID variantId = UUID.fromString(variantIdStr);
                Integer quantity = ((Number) item.get("quantity")).intValue();
                BigDecimal unitPrice = new BigDecimal(item.get("unitPrice").toString());
                
                // Lấy ProductVariant
                ProductVariant variant = em.find(ProductVariant.class, variantId);
                if (variant == null) {
                    throw new RuntimeException("Không tìm thấy sản phẩm variant: " + variantId);
                }
                
                OrderDetail detail = new OrderDetail();
                detail.setOrderDetailId(UUID.randomUUID());
                detail.setOrder(order);
                detail.setProductVariant(variant);
                detail.setQuantity(quantity);
                detail.setUnitPrice(unitPrice);
                detail.calculateTotalPrice();
                detail.setStatus("Pending"); // Món đang chờ làm
                
                orderDetails.add(detail);
                subtotal = subtotal.add(detail.getTotalPrice());
            }
            
            // 5. Tính VAT và tổng tiền
            BigDecimal vat = subtotal.multiply(new BigDecimal("0.10")); // 10% VAT
            BigDecimal total = subtotal.add(vat);
            
            order.setSubTotal(subtotal);
            order.setVat(vat);
            order.setTotalAmount(total);
            order.setOrderDetails(orderDetails);
            
            // Set created by
            if (userId != null) {
                User user = em.find(User.class, userId);
                order.setCreatedBy(user);
            }
            
            // 6. Persist order (cascade sẽ persist orderDetails)
            em.persist(order);
            
            // 7. Update session total
            updateSessionTotal(em, session);
            
            em.getTransaction().commit();
            
            System.out.println("✅ Đã tạo order: " + orderNumber + " với " + orderDetails.size() + " món");
            return order.getOrderId();
            
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Lỗi khi tạo order: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Không thể tạo order: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    /**
     * Tìm hoặc tạo session active cho bàn
     */
    private TableSession findOrCreateActiveSession(EntityManager em, UUID tableId, UUID userId) {
        // Tìm session đang active
        Query query = em.createQuery(
            "SELECT s FROM TableSession s WHERE s.table.tableId = :tableId AND s.status = 'Active'"
        );
        query.setParameter("tableId", tableId);
        
        @SuppressWarnings("unchecked")
        List<TableSession> sessions = query.getResultList();
        
        if (!sessions.isEmpty()) {
            return sessions.get(0);
        }
        
        // Tạo session mới
        Table table = em.find(Table.class, tableId);
        if (table == null) {
            throw new RuntimeException("Không tìm thấy bàn: " + tableId);
        }
        
        TableSession session = new TableSession();
        session.setSessionId(UUID.randomUUID());
        session.setTable(table);
        session.setCheckInTime(LocalDateTime.now());
        session.setStatus("Active");
        session.setPaymentStatus("Unpaid");
        
        if (userId != null) {
            User user = em.find(User.class, userId);
            session.setCreatedBy(user);
        }
        
        em.persist(session);
        
        // Update table status
        table.setStatus("Occupied");
        em.merge(table);
        
        return session;
    }
    
    /**
     * Tạo order number tự động
     */
    private String generateOrderNumber(EntityManager em) {
        // Lấy order count trong ngày (SQL Server compatible)
        LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59).withNano(999999999);
        
        Query query = em.createQuery(
            "SELECT COUNT(o) FROM Order o WHERE o.orderDate >= :startOfDay AND o.orderDate <= :endOfDay"
        );
        query.setParameter("startOfDay", startOfDay);
        query.setParameter("endOfDay", endOfDay);
        
        Long count = (Long) query.getSingleResult();
        
        String date = LocalDateTime.now().toString().substring(0, 10).replace("-", "");
        return "ORD" + date + String.format("%03d", count + 1);
    }
    
    /**
     * Cập nhật tổng tiền của session
     */
    private void updateSessionTotal(EntityManager em, TableSession session) {
        Query query = em.createQuery(
            "SELECT SUM(o.totalAmount) FROM Order o WHERE o.session.sessionId = :sessionId"
        );
        query.setParameter("sessionId", session.getSessionId());
        BigDecimal total = (BigDecimal) query.getSingleResult();
        
        if (total == null) {
            total = BigDecimal.ZERO;
        }
        
        session.setTotalAmount(total);
        em.merge(session);
    }
    
    /**
     * Lấy orders của bàn/session hiện tại (cho cashier)
     */
    public List<Map<String, Object>> getOrdersByTable(UUID tableId) {
        EntityManager em = BaseDAO.emf.createEntityManager();
        List<Map<String, Object>> result = new ArrayList<>();
        
        try {
            // Tìm session active của bàn
            String sessionQuery = "SELECT s FROM TableSession s WHERE s.table.tableId = :tableId AND s.status = 'Active'";
            Query query = em.createQuery(sessionQuery);
            query.setParameter("tableId", tableId);
            
            @SuppressWarnings("unchecked")
            List<TableSession> sessions = query.getResultList();
            
            if (sessions.isEmpty()) {
                return result; // Không có session active
            }
            
            TableSession session = sessions.get(0);
            
            // Lấy tất cả orders của session (trừ Cancelled)
            // GIỮ LẠI cả Served để cashier vẫn hiển thị
            String jpql = "SELECT o FROM Order o " +
                         "LEFT JOIN FETCH o.orderDetails od " +
                         "LEFT JOIN FETCH od.productVariant pv " +
                         "LEFT JOIN FETCH pv.product p " +
                         "WHERE o.session.sessionId = :sessionId " +
                         "AND o.status != 'Cancelled' " +
                         "ORDER BY o.orderDate ASC";
            
            Query orderQuery = em.createQuery(jpql);
            orderQuery.setParameter("sessionId", session.getSessionId());
            
            @SuppressWarnings("unchecked")
            List<Order> orders = orderQuery.getResultList();
            
            for (Order order : orders) {
                for (OrderDetail detail : order.getOrderDetails()) {
                    Map<String, Object> itemMap = new HashMap<>();
                    itemMap.put("orderId", order.getOrderId().toString());
                    itemMap.put("orderDetailId", detail.getOrderDetailId().toString());
                    itemMap.put("variantId", detail.getProductVariant().getProductVariantId().toString());
                    itemMap.put("productId", detail.getProductVariant().getProduct().getProductId().toString());
                    itemMap.put("name", detail.getProductVariant().getProduct().getName());
                    itemMap.put("size", detail.getProductVariant().getSize());
                    itemMap.put("price", detail.getUnitPrice().doubleValue());
                    itemMap.put("quantity", detail.getQuantity());
                    itemMap.put("status", detail.getStatus());
                    result.add(itemMap);
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy orders của bàn: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        return result;
    }
    
    /**
     * Lấy danh sách orders đang pending (cho màn hình bếp)
     */
    public List<Map<String, Object>> getPendingOrders() {
        EntityManager em = BaseDAO.emf.createEntityManager();
        List<Map<String, Object>> result = new ArrayList<>();
        
        try {
            String jpql = "SELECT o FROM Order o " +
                         "LEFT JOIN FETCH o.orderDetails od " +
                         "LEFT JOIN FETCH od.productVariant pv " +
                         "LEFT JOIN FETCH pv.product p " +
                         "WHERE o.status IN ('Pending', 'Preparing', 'Ready') " +
                         "ORDER BY o.orderDate ASC";
            
            Query query = em.createQuery(jpql);
            @SuppressWarnings("unchecked")
            List<Order> orders = query.getResultList();
            
            for (Order order : orders) {
                Map<String, Object> orderMap = new HashMap<>();
                orderMap.put("orderId", order.getOrderId().toString());
                orderMap.put("orderNumber", order.getOrderNumber());
                orderMap.put("orderDate", order.getOrderDate().toString());
                orderMap.put("status", order.getStatus());
                orderMap.put("tableName", order.getSession().getTable().getTableNumber());
                
                List<Map<String, Object>> items = new ArrayList<>();
                for (OrderDetail detail : order.getOrderDetails()) {
                    Map<String, Object> itemMap = new HashMap<>();
                    String productName = detail.getProductVariant().getProduct().getName();
                    String size = detail.getProductVariant().getSize();
                    
                    // Thêm size vào tên nếu có
                    if (size != null && !size.isEmpty()) {
                        productName = productName + " (" + size + ")";
                    }
                    
                    itemMap.put("productName", productName);
                    itemMap.put("quantity", detail.getQuantity());
                    itemMap.put("status", detail.getStatus());
                    items.add(itemMap);
                }
                orderMap.put("items", items);
                
                result.add(orderMap);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy pending orders: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        return result;
    }
    
    /**
     * Cập nhật trạng thái order
     */
    public boolean updateOrderStatus(UUID orderId, String status) {
        EntityManager em = BaseDAO.emf.createEntityManager();
        
        try {
            em.getTransaction().begin();
            
            Order order = em.find(Order.class, orderId);
            if (order == null) {
                return false;
            }
            
            order.setStatus(status);
            
            // Cập nhật trạng thái của tất cả order details
            for (OrderDetail detail : order.getOrderDetails()) {
                detail.setStatus(status);
            }
            
            em.merge(order);
            em.getTransaction().commit();
            
            System.out.println("✅ Đã cập nhật trạng thái order " + order.getOrderNumber() + " thành " + status);
            return true;
            
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ Lỗi khi cập nhật trạng thái order: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
}

