package com.liteflow.model.inventory;

import com.liteflow.model.auth.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("Order Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class OrderTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        Order order = new Order();
        
        assertEquals(BigDecimal.ZERO, order.getSubTotal());
        assertEquals(BigDecimal.ZERO, order.getVat());
        assertEquals(BigDecimal.ZERO, order.getDiscount());
        assertEquals(BigDecimal.ZERO, order.getTotalAmount());
        assertEquals("Pending", order.getStatus());
        assertEquals("Unpaid", order.getPaymentStatus());
        assertNotNull(order.getOrderDetails());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        Order order = new Order();
        UUID id = UUID.randomUUID();
        TableSession session = new TableSession();
        String orderNumber = "ORD001";
        LocalDateTime orderDate = LocalDateTime.now();
        BigDecimal subTotal = new BigDecimal("100.50");
        BigDecimal vat = new BigDecimal("10.05");
        BigDecimal discount = new BigDecimal("5.00");
        BigDecimal totalAmount = new BigDecimal("105.55");
        String status = "Ready";
        String paymentMethod = "Cash";
        String paymentStatus = "Paid";
        String notes = "Test notes";
        User createdBy = new User();
        LocalDateTime updatedAt = LocalDateTime.now();
        
        order.setOrderId(id);
        order.setSession(session);
        order.setOrderNumber(orderNumber);
        order.setOrderDate(orderDate);
        order.setSubTotal(subTotal);
        order.setVat(vat);
        order.setDiscount(discount);
        order.setTotalAmount(totalAmount);
        order.setStatus(status);
        order.setPaymentMethod(paymentMethod);
        order.setPaymentStatus(paymentStatus);
        order.setNotes(notes);
        order.setCreatedBy(createdBy);
        order.setUpdatedAt(updatedAt);
        
        assertEquals(id, order.getOrderId());
        assertEquals(session, order.getSession());
        assertEquals(orderNumber, order.getOrderNumber());
        assertEquals(orderDate, order.getOrderDate());
        assertEquals(subTotal, order.getSubTotal());
        assertEquals(vat, order.getVat());
        assertEquals(discount, order.getDiscount());
        assertEquals(totalAmount, order.getTotalAmount());
        assertEquals(status, order.getStatus());
        assertEquals(paymentMethod, order.getPaymentMethod());
        assertEquals(paymentStatus, order.getPaymentStatus());
        assertEquals(notes, order.getNotes());
        assertEquals(createdBy, order.getCreatedBy());
        assertEquals(updatedAt, order.getUpdatedAt());
    }
    
    @Test
    @DisplayName("Test addOrderDetail")
    public void testAddOrderDetail() {
        Order order = new Order();
        OrderDetail orderDetail = new OrderDetail();
        
        order.addOrderDetail(orderDetail);
        
        assertTrue(order.getOrderDetails().contains(orderDetail));
        assertEquals(order, orderDetail.getOrder());
    }
    
    @Test
    @DisplayName("Test addOrderDetail with null list")
    public void testAddOrderDetailWithNullList() {
        Order order = new Order();
        order.setOrderDetails(null);
        
        OrderDetail orderDetail = new OrderDetail();
        order.addOrderDetail(orderDetail);
        
        assertNotNull(order.getOrderDetails());
        assertTrue(order.getOrderDetails().contains(orderDetail));
    }
    
    @Test
    @DisplayName("Test removeOrderDetail")
    public void testRemoveOrderDetail() {
        Order order = new Order();
        OrderDetail orderDetail = new OrderDetail();
        
        order.addOrderDetail(orderDetail);
        assertTrue(order.getOrderDetails().contains(orderDetail));
        
        order.removeOrderDetail(orderDetail);
        
        assertFalse(order.getOrderDetails().contains(orderDetail));
        assertNull(orderDetail.getOrder());
    }
    
    @Test
    @DisplayName("Test removeOrderDetail with null list")
    public void testRemoveOrderDetailWithNullList() {
        Order order = new Order();
        order.setOrderDetails(null);
        
        OrderDetail orderDetail = new OrderDetail();
        // Should not throw exception
        order.removeOrderDetail(orderDetail);
    }
    
    @Test
    @DisplayName("Test isPending")
    public void testIsPending() {
        Order order = new Order();
        order.setStatus("Pending");
        
        assertTrue(order.isPending());
    }
    
    @Test
    @DisplayName("Test isPreparing")
    public void testIsPreparing() {
        Order order = new Order();
        order.setStatus("Preparing");
        
        assertTrue(order.isPreparing());
    }
    
    @Test
    @DisplayName("Test isReady")
    public void testIsReady() {
        Order order = new Order();
        order.setStatus("Ready");
        
        assertTrue(order.isReady());
    }
    
    @Test
    @DisplayName("Test isServed")
    public void testIsServed() {
        Order order = new Order();
        order.setStatus("Served");
        
        assertTrue(order.isServed());
    }
    
    @Test
    @DisplayName("Test isCancelled")
    public void testIsCancelled() {
        Order order = new Order();
        order.setStatus("Cancelled");
        
        assertTrue(order.isCancelled());
    }
    
    @Test
    @DisplayName("Test status methods return false for wrong status")
    public void testStatusMethodsFalse() {
        Order order = new Order();
        order.setStatus("Unknown");
        
        assertFalse(order.isPending());
        assertFalse(order.isPreparing());
        assertFalse(order.isReady());
        assertFalse(order.isServed());
        assertFalse(order.isCancelled());
    }
    
    @Test
    @DisplayName("Test isPaid")
    public void testIsPaid() {
        Order order = new Order();
        order.setPaymentStatus("Paid");
        
        assertTrue(order.isPaid());
    }
    
    @Test
    @DisplayName("Test isPaid - false")
    public void testIsPaidFalse() {
        Order order = new Order();
        order.setPaymentStatus("Unpaid");
        
        assertFalse(order.isPaid());
    }
    
    @Test
    @DisplayName("Test setOrderDetails")
    public void testSetOrderDetails() {
        Order order = new Order();
        List<OrderDetail> orderDetails = new ArrayList<>();
        OrderDetail od1 = new OrderDetail();
        OrderDetail od2 = new OrderDetail();
        orderDetails.add(od1);
        orderDetails.add(od2);
        
        order.setOrderDetails(orderDetails);
        
        assertEquals(2, order.getOrderDetails().size());
        assertEquals(orderDetails, order.getOrderDetails());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        Order order = new Order();
        UUID id = UUID.randomUUID();
        order.setOrderId(id);
        order.setOrderNumber("ORD001");
        order.setStatus("Pending");
        order.setTotalAmount(new BigDecimal("100.50"));
        
        String result = order.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("ORD001"));
        assertTrue(result.contains("Pending"));
        assertTrue(result.contains("100.50"));
        assertTrue(result.contains("Order"));
    }
}

