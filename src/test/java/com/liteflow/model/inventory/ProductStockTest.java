package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

@DisplayName("ProductStock Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ProductStockTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        ProductStock stock = new ProductStock();
        
        assertEquals(0, stock.getAmount());
        assertNotNull(stock.getAmount()); // Default value
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        ProductStock stock = new ProductStock();
        UUID id = UUID.randomUUID();
        ProductVariant variant = new ProductVariant();
        Inventory inventory = new Inventory();
        Integer amount = 100;
        
        stock.setProductStockId(id);
        stock.setProductVariant(variant);
        stock.setInventory(inventory);
        stock.setAmount(amount);
        
        assertEquals(id, stock.getProductStockId());
        assertEquals(variant, stock.getProductVariant());
        assertEquals(inventory, stock.getInventory());
        assertEquals(amount, stock.getAmount());
    }
    
    @Test
    @DisplayName("Test isInStock - positive amount")
    public void testIsInStockPositive() {
        ProductStock stock = new ProductStock();
        stock.setAmount(10);
        
        assertTrue(stock.isInStock());
    }
    
    @Test
    @DisplayName("Test isInStock - zero amount")
    public void testIsInStockZero() {
        ProductStock stock = new ProductStock();
        stock.setAmount(0);
        
        assertFalse(stock.isInStock());
    }
    
    @Test
    @DisplayName("Test isInStock - null amount")
    public void testIsInStockNull() {
        ProductStock stock = new ProductStock();
        stock.setAmount(null);
        
        assertFalse(stock.isInStock());
    }
    
    @Test
    @DisplayName("Test isOutOfStock - zero amount")
    public void testIsOutOfStockZero() {
        ProductStock stock = new ProductStock();
        stock.setAmount(0);
        
        assertTrue(stock.isOutOfStock());
    }
    
    @Test
    @DisplayName("Test isOutOfStock - negative amount")
    public void testIsOutOfStockNegative() {
        ProductStock stock = new ProductStock();
        stock.setAmount(-5);
        
        assertTrue(stock.isOutOfStock());
    }
    
    @Test
    @DisplayName("Test isOutOfStock - null amount")
    public void testIsOutOfStockNull() {
        ProductStock stock = new ProductStock();
        stock.setAmount(null);
        
        assertTrue(stock.isOutOfStock());
    }
    
    @Test
    @DisplayName("Test isOutOfStock - positive amount")
    public void testIsOutOfStockPositive() {
        ProductStock stock = new ProductStock();
        stock.setAmount(10);
        
        assertFalse(stock.isOutOfStock());
    }
    
    @Test
    @DisplayName("Test increaseStock")
    public void testIncreaseStock() {
        ProductStock stock = new ProductStock();
        stock.setAmount(10);
        
        stock.increaseStock(5);
        
        assertEquals(15, stock.getAmount());
    }
    
    @Test
    @DisplayName("Test increaseStock with null amount")
    public void testIncreaseStockNullAmount() {
        ProductStock stock = new ProductStock();
        stock.setAmount(null);
        
        stock.increaseStock(10);
        
        assertEquals(10, stock.getAmount());
    }
    
    @Test
    @DisplayName("Test decreaseStock")
    public void testDecreaseStock() {
        ProductStock stock = new ProductStock();
        stock.setAmount(10);
        
        stock.decreaseStock(3);
        
        assertEquals(7, stock.getAmount());
    }
    
    @Test
    @DisplayName("Test decreaseStock with null amount")
    public void testDecreaseStockNullAmount() {
        ProductStock stock = new ProductStock();
        stock.setAmount(null);
        
        stock.decreaseStock(5);
        
        assertEquals(0, stock.getAmount());
    }
    
    @Test
    @DisplayName("Test decreaseStock below zero")
    public void testDecreaseStockBelowZero() {
        ProductStock stock = new ProductStock();
        stock.setAmount(5);
        
        stock.decreaseStock(10);
        
        assertEquals(0, stock.getAmount());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        ProductStock stock = new ProductStock();
        UUID id = UUID.randomUUID();
        stock.setProductStockId(id);
        stock.setAmount(100);
        
        String result = stock.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("100"));
        assertTrue(result.contains("ProductStock"));
    }
}

