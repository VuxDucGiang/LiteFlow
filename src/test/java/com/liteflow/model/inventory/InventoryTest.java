package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("Inventory Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class InventoryTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        Inventory inventory = new Inventory();
        
        // Default values
        assertEquals("Main Warehouse", inventory.getStoreLocation());
        assertNotNull(inventory.getProductStocks());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        Inventory inventory = new Inventory();
        UUID id = UUID.randomUUID();
        String location = "Warehouse A";
        
        inventory.setInventoryId(id);
        inventory.setStoreLocation(location);
        
        assertEquals(id, inventory.getInventoryId());
        assertEquals(location, inventory.getStoreLocation());
    }
    
    @Test
    @DisplayName("Test addProductStock")
    public void testAddProductStock() {
        Inventory inventory = new Inventory();
        ProductStock stock = new ProductStock();
        UUID stockId = UUID.randomUUID();
        stock.setProductStockId(stockId);
        
        inventory.addProductStock(stock);
        
        assertTrue(inventory.getProductStocks().contains(stock));
        assertEquals(inventory, stock.getInventory());
    }
    
    @Test
    @DisplayName("Test addProductStock with null productStocks list")
    public void testAddProductStockWithNullList() {
        Inventory inventory = new Inventory();
        inventory.setProductStocks(null);
        
        ProductStock stock = new ProductStock();
        inventory.addProductStock(stock);
        
        assertNotNull(inventory.getProductStocks());
        assertTrue(inventory.getProductStocks().contains(stock));
    }
    
    @Test
    @DisplayName("Test removeProductStock")
    public void testRemoveProductStock() {
        Inventory inventory = new Inventory();
        ProductStock stock = new ProductStock();
        UUID stockId = UUID.randomUUID();
        stock.setProductStockId(stockId);
        
        inventory.addProductStock(stock);
        assertTrue(inventory.getProductStocks().contains(stock));
        
        inventory.removeProductStock(stock);
        
        assertFalse(inventory.getProductStocks().contains(stock));
        assertNull(stock.getInventory());
    }
    
    @Test
    @DisplayName("Test removeProductStock with null list")
    public void testRemoveProductStockWithNullList() {
        Inventory inventory = new Inventory();
        inventory.setProductStocks(null);
        
        ProductStock stock = new ProductStock();
        // Should not throw exception
        inventory.removeProductStock(stock);
    }
    
    @Test
    @DisplayName("Test setProductStocks")
    public void testSetProductStocks() {
        Inventory inventory = new Inventory();
        List<ProductStock> stocks = new ArrayList<>();
        ProductStock stock1 = new ProductStock();
        ProductStock stock2 = new ProductStock();
        stocks.add(stock1);
        stocks.add(stock2);
        
        inventory.setProductStocks(stocks);
        
        assertEquals(2, inventory.getProductStocks().size());
        assertEquals(stocks, inventory.getProductStocks());
    }
    
    @Test
    @DisplayName("Test default storeLocation value")
    public void testDefaultStoreLocation() {
        Inventory inventory = new Inventory();
        
        assertEquals("Main Warehouse", inventory.getStoreLocation());
    }
    
    @Test
    @DisplayName("Test setting null storeLocation")
    public void testNullStoreLocation() {
        Inventory inventory = new Inventory();
        inventory.setStoreLocation(null);
        
        assertNull(inventory.getStoreLocation());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        Inventory inventory = new Inventory();
        UUID id = UUID.randomUUID();
        String location = "Test Warehouse";
        inventory.setInventoryId(id);
        inventory.setStoreLocation(location);
        
        String result = inventory.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains(location));
        assertTrue(result.contains("Inventory"));
    }
}

