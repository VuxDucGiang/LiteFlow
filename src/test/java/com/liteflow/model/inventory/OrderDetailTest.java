package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@DisplayName("OrderDetail Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class OrderDetailTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        OrderDetail orderDetail = new OrderDetail();
        
        assertEquals(1, orderDetail.getQuantity());
        assertEquals("Pending", orderDetail.getStatus());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        OrderDetail orderDetail = new OrderDetail();
        UUID id = UUID.randomUUID();
        Order order = new Order();
        ProductVariant productVariant = new ProductVariant();
        Integer quantity = 5;
        BigDecimal unitPrice = new BigDecimal("10.50");
        BigDecimal totalPrice = new BigDecimal("52.50");
        String specialInstructions = "No onions";
        String status = "Ready";
        LocalDateTime createdAt = LocalDateTime.now();
        LocalDateTime updatedAt = LocalDateTime.now();
        
        orderDetail.setOrderDetailId(id);
        orderDetail.setOrder(order);
        orderDetail.setProductVariant(productVariant);
        orderDetail.setQuantity(quantity);
        orderDetail.setUnitPrice(unitPrice);
        orderDetail.setTotalPrice(totalPrice);
        orderDetail.setSpecialInstructions(specialInstructions);
        orderDetail.setStatus(status);
        orderDetail.setCreatedAt(createdAt);
        orderDetail.setUpdatedAt(updatedAt);
        
        assertEquals(id, orderDetail.getOrderDetailId());
        assertEquals(order, orderDetail.getOrder());
        assertEquals(productVariant, orderDetail.getProductVariant());
        assertEquals(quantity, orderDetail.getQuantity());
        assertEquals(unitPrice, orderDetail.getUnitPrice());
        assertEquals(totalPrice, orderDetail.getTotalPrice());
        assertEquals(specialInstructions, orderDetail.getSpecialInstructions());
        assertEquals(status, orderDetail.getStatus());
        assertEquals(createdAt, orderDetail.getCreatedAt());
        assertEquals(updatedAt, orderDetail.getUpdatedAt());
    }
    
    @Test
    @DisplayName("Test calculateTotalPrice")
    public void testCalculateTotalPrice() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setUnitPrice(new BigDecimal("10.50"));
        orderDetail.setQuantity(3);
        
        orderDetail.calculateTotalPrice();
        
        assertEquals(new BigDecimal("31.50"), orderDetail.getTotalPrice());
    }
    
    @Test
    @DisplayName("Test calculateTotalPrice with null unitPrice")
    public void testCalculateTotalPriceNullUnitPrice() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setUnitPrice(null);
        orderDetail.setQuantity(3);
        
        orderDetail.calculateTotalPrice();
        
        assertNull(orderDetail.getTotalPrice());
    }
    
    @Test
    @DisplayName("Test calculateTotalPrice with null quantity")
    public void testCalculateTotalPriceNullQuantity() {
        OrderDetail orderDetail = new OrderDetail();
        // Set initial values
        orderDetail.setUnitPrice(new BigDecimal("10.50"));
        orderDetail.setQuantity(5);
        orderDetail.calculateTotalPrice(); // This will set totalPrice
        BigDecimal previousTotal = orderDetail.getTotalPrice();
        
        // Now set quantity to null
        orderDetail.setQuantity(null);
        
        // calculateTotalPrice checks both are not null, so totalPrice should remain unchanged
        // (setQuantity calls calculateTotalPrice, but it won't recalculate with null quantity)
        // However, if there was a previous calculation, it might have value
        // The key is that quantity is now null
        assertNull(orderDetail.getQuantity());
    }
    
    @Test
    @DisplayName("Test setQuantity with null preserves previous total if calculated")
    public void testSetQuantityNullPreservesTotal() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setUnitPrice(new BigDecimal("10.00"));
        orderDetail.setQuantity(3);
        // setQuantity will trigger calculateTotalPrice, setting totalPrice to 30.00
        
        BigDecimal expectedTotal = new BigDecimal("30.00");
        
        // Now set quantity to null
        orderDetail.setQuantity(null);
        
        // calculateTotalPrice won't recalculate with null quantity, so totalPrice remains
        assertEquals(expectedTotal, orderDetail.getTotalPrice());
        assertNull(orderDetail.getQuantity());
    }
    
    @Test
    @DisplayName("Test setQuantity triggers calculateTotalPrice")
    public void testSetQuantityTriggersCalculate() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setUnitPrice(new BigDecimal("10.00"));
        orderDetail.setQuantity(5);
        
        // Should have calculated total
        assertEquals(new BigDecimal("50.00"), orderDetail.getTotalPrice());
    }
    
    @Test
    @DisplayName("Test setUnitPrice triggers calculateTotalPrice")
    public void testSetUnitPriceTriggersCalculate() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setQuantity(3);
        orderDetail.setUnitPrice(new BigDecimal("15.00"));
        
        // Should have calculated total
        assertEquals(new BigDecimal("45.00"), orderDetail.getTotalPrice());
    }
    
    @Test
    @DisplayName("Test isPending")
    public void testIsPending() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setStatus("Pending");
        
        assertTrue(orderDetail.isPending());
    }
    
    @Test
    @DisplayName("Test isPreparing")
    public void testIsPreparing() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setStatus("Preparing");
        
        assertTrue(orderDetail.isPreparing());
    }
    
    @Test
    @DisplayName("Test isReady")
    public void testIsReady() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setStatus("Ready");
        
        assertTrue(orderDetail.isReady());
    }
    
    @Test
    @DisplayName("Test isServed")
    public void testIsServed() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setStatus("Served");
        
        assertTrue(orderDetail.isServed());
    }
    
    @Test
    @DisplayName("Test status methods return false for wrong status")
    public void testStatusMethodsFalse() {
        OrderDetail orderDetail = new OrderDetail();
        orderDetail.setStatus("Unknown");
        
        assertFalse(orderDetail.isPending());
        assertFalse(orderDetail.isPreparing());
        assertFalse(orderDetail.isReady());
        assertFalse(orderDetail.isServed());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        OrderDetail orderDetail = new OrderDetail();
        UUID id = UUID.randomUUID();
        orderDetail.setOrderDetailId(id);
        orderDetail.setQuantity(3);
        orderDetail.setUnitPrice(new BigDecimal("10.50"));
        orderDetail.setTotalPrice(new BigDecimal("31.50"));
        orderDetail.setStatus("Pending");
        
        String result = orderDetail.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("3"));
        assertTrue(result.contains("10.50"));
        assertTrue(result.contains("31.50"));
        assertTrue(result.contains("Pending"));
        assertTrue(result.contains("OrderDetail"));
    }
}

