package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.UUID;

@DisplayName("InventoryLog Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class InventoryLogTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        InventoryLog log = new InventoryLog();
        
        assertEquals("Main Warehouse", log.getStoreLocation());
    }
    
    @Test
    @DisplayName("Test default storeLocation value")
    public void testDefaultStoreLocation() {
        InventoryLog log = new InventoryLog();
        
        assertEquals("Main Warehouse", log.getStoreLocation());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        InventoryLog log = new InventoryLog();
        UUID id = UUID.randomUUID();
        ProductVariant variant = new ProductVariant();
        String actionType = "IN";
        Integer quantityChanged = 10;
        LocalDateTime actionDate = LocalDateTime.now();
        String storeLocation = "Warehouse B";
        
        log.setLogId(id);
        log.setProductVariant(variant);
        log.setActionType(actionType);
        log.setQuantityChanged(quantityChanged);
        log.setActionDate(actionDate);
        log.setStoreLocation(storeLocation);
        
        assertEquals(id, log.getLogId());
        assertEquals(variant, log.getProductVariant());
        assertEquals(actionType, log.getActionType());
        assertEquals(quantityChanged, log.getQuantityChanged());
        assertEquals(actionDate, log.getActionDate());
        assertEquals(storeLocation, log.getStoreLocation());
    }
    
    @Test
    @DisplayName("Test isInbound - IN")
    public void testIsInbound() {
        InventoryLog log = new InventoryLog();
        log.setActionType("IN");
        
        assertTrue(log.isInbound());
    }
    
    @Test
    @DisplayName("Test isInbound - lowercase")
    public void testIsInboundLowercase() {
        InventoryLog log = new InventoryLog();
        log.setActionType("in");
        
        assertTrue(log.isInbound());
    }
    
    @Test
    @DisplayName("Test isInbound - false")
    public void testIsInboundFalse() {
        InventoryLog log = new InventoryLog();
        log.setActionType("OUT");
        
        assertFalse(log.isInbound());
    }
    
    @Test
    @DisplayName("Test isOutbound - OUT")
    public void testIsOutbound() {
        InventoryLog log = new InventoryLog();
        log.setActionType("OUT");
        
        assertTrue(log.isOutbound());
    }
    
    @Test
    @DisplayName("Test isOutbound - lowercase")
    public void testIsOutboundLowercase() {
        InventoryLog log = new InventoryLog();
        log.setActionType("out");
        
        assertTrue(log.isOutbound());
    }
    
    @Test
    @DisplayName("Test isAdjustment - ADJUST")
    public void testIsAdjustment() {
        InventoryLog log = new InventoryLog();
        log.setActionType("ADJUST");
        
        assertTrue(log.isAdjustment());
    }
    
    @Test
    @DisplayName("Test isAdjustment - lowercase")
    public void testIsAdjustmentLowercase() {
        InventoryLog log = new InventoryLog();
        log.setActionType("adjust");
        
        assertTrue(log.isAdjustment());
    }
    
    @Test
    @DisplayName("Test isIncrease - positive quantity")
    public void testIsIncrease() {
        InventoryLog log = new InventoryLog();
        log.setQuantityChanged(10);
        
        assertTrue(log.isIncrease());
    }
    
    @Test
    @DisplayName("Test isIncrease - negative quantity")
    public void testIsIncreaseNegative() {
        InventoryLog log = new InventoryLog();
        log.setQuantityChanged(-10);
        
        assertFalse(log.isIncrease());
    }
    
    @Test
    @DisplayName("Test isIncrease - null quantity")
    public void testIsIncreaseNull() {
        InventoryLog log = new InventoryLog();
        log.setQuantityChanged(null);
        
        assertFalse(log.isIncrease());
    }
    
    @Test
    @DisplayName("Test isDecrease - negative quantity")
    public void testIsDecrease() {
        InventoryLog log = new InventoryLog();
        log.setQuantityChanged(-10);
        
        assertTrue(log.isDecrease());
    }
    
    @Test
    @DisplayName("Test isDecrease - positive quantity")
    public void testIsDecreasePositive() {
        InventoryLog log = new InventoryLog();
        log.setQuantityChanged(10);
        
        assertFalse(log.isDecrease());
    }
    
    @Test
    @DisplayName("Test isDecrease - null quantity")
    public void testIsDecreaseNull() {
        InventoryLog log = new InventoryLog();
        log.setQuantityChanged(null);
        
        assertFalse(log.isDecrease());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        InventoryLog log = new InventoryLog();
        UUID id = UUID.randomUUID();
        log.setLogId(id);
        log.setActionType("IN");
        log.setQuantityChanged(10);
        LocalDateTime date = LocalDateTime.now();
        log.setActionDate(date);
        
        String result = log.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("IN"));
        assertTrue(result.contains("10"));
        assertTrue(result.contains("InventoryLog"));
    }
}

