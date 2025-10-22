package com.liteflow.service;

import com.liteflow.dao.inventory.OrderDAO;
import java.util.*;

public class OrderService {
    
    private final OrderDAO orderDAO;
    
    public OrderService() {
        this.orderDAO = new OrderDAO();
    }
    
    /**
     * Tạo order mới và gửi thông báo đến bếp
     * @param tableId ID của bàn
     * @param items Danh sách món
     * @param userId ID của user tạo order
     * @return UUID của order
     */
    public UUID createOrderAndNotifyKitchen(UUID tableId, List<Map<String, Object>> items, UUID userId) {
        // Validate input
        if (tableId == null) {
            throw new IllegalArgumentException("Table ID không được null");
        }
        
        if (items == null || items.isEmpty()) {
            throw new IllegalArgumentException("Danh sách món không được rỗng");
        }
        
        // Tạo order
        UUID orderId = orderDAO.createOrder(tableId, items, userId);
        
        // TODO: Trong tương lai có thể thêm logic gửi thông báo real-time đến màn hình bếp
        // Ví dụ: WebSocket, Server-Sent Events, hoặc Polling
        System.out.println("📢 Thông báo đến bếp: Order mới đã được tạo - ID: " + orderId);
        
        return orderId;
    }
    
    /**
     * Lấy orders của bàn (cho cashier)
     */
    public List<Map<String, Object>> getOrdersByTable(UUID tableId) {
        if (tableId == null) {
            throw new IllegalArgumentException("Table ID không được null");
        }
        return orderDAO.getOrdersByTable(tableId);
    }
    
    /**
     * Lấy danh sách orders đang chờ làm
     */
    public List<Map<String, Object>> getPendingOrders() {
        return orderDAO.getPendingOrders();
    }
    
    /**
     * Cập nhật trạng thái order
     */
    public boolean updateOrderStatus(UUID orderId, String status) {
        // Validate status
        List<String> validStatuses = Arrays.asList("Pending", "Preparing", "Ready", "Served", "Cancelled");
        if (!validStatuses.contains(status)) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ: " + status);
        }
        
        return orderDAO.updateOrderStatus(orderId, status);
    }
    
    /**
     * Đánh dấu order là đang chuẩn bị
     */
    public boolean markOrderAsPreparing(UUID orderId) {
        return updateOrderStatus(orderId, "Preparing");
    }
    
    /**
     * Đánh dấu order là đã sẵn sàng
     */
    public boolean markOrderAsReady(UUID orderId) {
        return updateOrderStatus(orderId, "Ready");
    }
    
    /**
     * Đánh dấu order là đã phục vụ
     */
    public boolean markOrderAsServed(UUID orderId) {
        return updateOrderStatus(orderId, "Served");
    }
    
    /**
     * Hủy order
     */
    public boolean cancelOrder(UUID orderId) {
        return updateOrderStatus(orderId, "Cancelled");
    }
}

