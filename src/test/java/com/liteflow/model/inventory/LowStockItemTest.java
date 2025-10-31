package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

@DisplayName("LowStockItem Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class LowStockItemTest {
    
    @Test
    @DisplayName("Test constructor with 5 parameters")
    public void testConstructor5Params() {
        UUID productID = UUID.randomUUID();
        UUID variantID = UUID.randomUUID();
        String productName = "Test Product";
        String size = "M";
        int currentStock = 10;
        
        LowStockItem item = new LowStockItem(productID, variantID, productName, size, currentStock);
        
        assertEquals(productID, item.getProductID());
        assertEquals(variantID, item.getProductVariantID());
        assertEquals(productName, item.getProductName());
        assertEquals(size, item.getSize());
        assertEquals(currentStock, item.getCurrentStock());
    }
    
    @Test
    @DisplayName("Test constructor with 6 parameters")
    public void testConstructor6Params() {
        UUID productID = UUID.randomUUID();
        UUID variantID = UUID.randomUUID();
        String productName = "Test Product";
        String size = "L";
        int currentStock = 5;
        int threshold = 20;
        
        LowStockItem item = new LowStockItem(productID, variantID, productName, size, currentStock, threshold);
        
        assertEquals(productID, item.getProductID());
        assertEquals(variantID, item.getProductVariantID());
        assertEquals(productName, item.getProductName());
        assertEquals(size, item.getSize());
        assertEquals(currentStock, item.getCurrentStock());
        assertEquals(threshold, item.getThreshold());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        LowStockItem item = new LowStockItem(UUID.randomUUID(), UUID.randomUUID(), "Product", "M", 10);
        
        UUID productID = UUID.randomUUID();
        UUID variantID = UUID.randomUUID();
        String productName = "Updated Product";
        String size = "XL";
        int currentStock = 15;
        int threshold = 30;
        
        item.setProductID(productID);
        item.setProductVariantID(variantID);
        item.setProductName(productName);
        item.setSize(size);
        item.setCurrentStock(currentStock);
        item.setThreshold(threshold);
        
        assertEquals(productID, item.getProductID());
        assertEquals(variantID, item.getProductVariantID());
        assertEquals(productName, item.getProductName());
        assertEquals(size, item.getSize());
        assertEquals(currentStock, item.getCurrentStock());
        assertEquals(threshold, item.getThreshold());
    }
    
    @Test
    @DisplayName("Test getFullName")
    public void testGetFullName() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Product Name", "L", 10
        );
        
        assertEquals("Product Name (L)", item.getFullName());
    }
    
    @Test
    @DisplayName("Test isCritical - stock < 50% threshold")
    public void testIsCritical() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Product", "M", 5, 20
        );
        
        assertTrue(item.isCritical()); // 5 < 10 (50% of 20)
    }
    
    @Test
    @DisplayName("Test isCritical - stock >= 50% threshold")
    public void testIsCriticalFalse() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Product", "M", 15, 20
        );
        
        assertFalse(item.isCritical()); // 15 >= 10 (50% of 20)
    }
    
    @Test
    @DisplayName("Test isCritical - threshold is zero")
    public void testIsCriticalZeroThreshold() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Product", "M", 5, 0
        );
        
        assertFalse(item.isCritical());
    }
    
    @Test
    @DisplayName("Test getStockPercentage")
    public void testGetStockPercentage() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Product", "M", 50, 100
        );
        
        assertEquals(50.0, item.getStockPercentage(), 0.01);
    }
    
    @Test
    @DisplayName("Test getStockPercentage - zero threshold")
    public void testGetStockPercentageZeroThreshold() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Product", "M", 50, 0
        );
        
        assertEquals(100.0, item.getStockPercentage(), 0.01);
    }
    
    @Test
    @DisplayName("Test getStockPercentage - negative threshold")
    public void testGetStockPercentageNegativeThreshold() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Product", "M", 50, -10
        );
        
        assertEquals(100.0, item.getStockPercentage(), 0.01);
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        LowStockItem item = new LowStockItem(
            UUID.randomUUID(), UUID.randomUUID(), "Test Product", "M", 10, 20
        );
        
        String result = item.toString();
        
        assertTrue(result.contains("Test Product"));
        assertTrue(result.contains("M"));
        assertTrue(result.contains("10"));
        assertTrue(result.contains("20"));
        assertTrue(result.contains("LowStockItem"));
    }
}

