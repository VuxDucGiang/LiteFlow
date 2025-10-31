package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("ProductVariant Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ProductVariantTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        ProductVariant variant = new ProductVariant();
        
        assertEquals(BigDecimal.ZERO, variant.getOriginalPrice());
        assertEquals(false, variant.getIsDeleted());
        assertNotNull(variant.getProductStocks());
        assertNotNull(variant.getInventoryLogs());
        assertNotNull(variant.getOrderDetails());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        ProductVariant variant = new ProductVariant();
        UUID id = UUID.randomUUID();
        Product product = new Product();
        String size = "L";
        BigDecimal originalPrice = new BigDecimal("100.00");
        BigDecimal price = new BigDecimal("90.00");
        BigDecimal discountPrice = new BigDecimal("80.00");
        LocalDateTime discountExpiry = LocalDateTime.now().plusDays(7);
        Boolean isDeleted = false;
        
        variant.setProductVariantId(id);
        variant.setProduct(product);
        variant.setSize(size);
        variant.setOriginalPrice(originalPrice);
        variant.setPrice(price);
        variant.setDiscountPrice(discountPrice);
        variant.setDiscountExpiry(discountExpiry);
        variant.setIsDeleted(isDeleted);
        
        assertEquals(id, variant.getProductVariantId());
        assertEquals(product, variant.getProduct());
        assertEquals(size, variant.getSize());
        assertEquals(originalPrice, variant.getOriginalPrice());
        assertEquals(price, variant.getPrice());
        assertEquals(discountPrice, variant.getDiscountPrice());
        assertEquals(discountExpiry, variant.getDiscountExpiry());
        assertEquals(isDeleted, variant.getIsDeleted());
    }
    
    @Test
    @DisplayName("Test addProductStock")
    public void testAddProductStock() {
        ProductVariant variant = new ProductVariant();
        ProductStock stock = new ProductStock();
        
        variant.addProductStock(stock);
        
        assertTrue(variant.getProductStocks().contains(stock));
        assertEquals(variant, stock.getProductVariant());
    }
    
    @Test
    @DisplayName("Test removeProductStock")
    public void testRemoveProductStock() {
        ProductVariant variant = new ProductVariant();
        ProductStock stock = new ProductStock();
        
        variant.addProductStock(stock);
        assertTrue(variant.getProductStocks().contains(stock));
        
        variant.removeProductStock(stock);
        
        assertFalse(variant.getProductStocks().contains(stock));
        assertNull(stock.getProductVariant());
    }
    
    @Test
    @DisplayName("Test addInventoryLog")
    public void testAddInventoryLog() {
        ProductVariant variant = new ProductVariant();
        InventoryLog log = new InventoryLog();
        
        variant.addInventoryLog(log);
        
        assertTrue(variant.getInventoryLogs().contains(log));
        assertEquals(variant, log.getProductVariant());
    }
    
    @Test
    @DisplayName("Test removeInventoryLog")
    public void testRemoveInventoryLog() {
        ProductVariant variant = new ProductVariant();
        InventoryLog log = new InventoryLog();
        
        variant.addInventoryLog(log);
        assertTrue(variant.getInventoryLogs().contains(log));
        
        variant.removeInventoryLog(log);
        
        assertFalse(variant.getInventoryLogs().contains(log));
        assertNull(log.getProductVariant());
    }
    
    @Test
    @DisplayName("Test addOrderDetail")
    public void testAddOrderDetail() {
        ProductVariant variant = new ProductVariant();
        OrderDetail orderDetail = new OrderDetail();
        
        variant.addOrderDetail(orderDetail);
        
        assertTrue(variant.getOrderDetails().contains(orderDetail));
        assertEquals(variant, orderDetail.getProductVariant());
    }
    
    @Test
    @DisplayName("Test removeOrderDetail")
    public void testRemoveOrderDetail() {
        ProductVariant variant = new ProductVariant();
        OrderDetail orderDetail = new OrderDetail();
        
        variant.addOrderDetail(orderDetail);
        assertTrue(variant.getOrderDetails().contains(orderDetail));
        
        variant.removeOrderDetail(orderDetail);
        
        assertFalse(variant.getOrderDetails().contains(orderDetail));
        assertNull(orderDetail.getProductVariant());
    }
    
    @Test
    @DisplayName("Test isActive - not deleted")
    public void testIsActiveNotDeleted() {
        ProductVariant variant = new ProductVariant();
        variant.setIsDeleted(false);
        
        assertTrue(variant.isActive());
    }
    
    @Test
    @DisplayName("Test isActive - deleted")
    public void testIsActiveDeleted() {
        ProductVariant variant = new ProductVariant();
        variant.setIsDeleted(true);
        
        assertFalse(variant.isActive());
    }
    
    @Test
    @DisplayName("Test hasDiscount - has discount price")
    public void testHasDiscount() {
        ProductVariant variant = new ProductVariant();
        variant.setDiscountPrice(new BigDecimal("80.00"));
        
        assertTrue(variant.hasDiscount());
    }
    
    @Test
    @DisplayName("Test hasDiscount - null discount price")
    public void testHasDiscountNull() {
        ProductVariant variant = new ProductVariant();
        variant.setDiscountPrice(null);
        
        assertFalse(variant.hasDiscount());
    }
    
    @Test
    @DisplayName("Test hasDiscount - zero discount price")
    public void testHasDiscountZero() {
        ProductVariant variant = new ProductVariant();
        variant.setDiscountPrice(BigDecimal.ZERO);
        
        assertFalse(variant.hasDiscount());
    }
    
    @Test
    @DisplayName("Test isDiscountExpired - expired")
    public void testIsDiscountExpired() {
        ProductVariant variant = new ProductVariant();
        variant.setDiscountExpiry(LocalDateTime.now().minusDays(1));
        
        assertTrue(variant.isDiscountExpired());
    }
    
    @Test
    @DisplayName("Test isDiscountExpired - not expired")
    public void testIsDiscountExpiredNot() {
        ProductVariant variant = new ProductVariant();
        variant.setDiscountExpiry(LocalDateTime.now().plusDays(1));
        
        assertFalse(variant.isDiscountExpired());
    }
    
    @Test
    @DisplayName("Test isDiscountExpired - null expiry")
    public void testIsDiscountExpiredNull() {
        ProductVariant variant = new ProductVariant();
        variant.setDiscountExpiry(null);
        
        assertFalse(variant.isDiscountExpired());
    }
    
    @Test
    @DisplayName("Test getCurrentPrice - with valid discount")
    public void testGetCurrentPriceWithDiscount() {
        ProductVariant variant = new ProductVariant();
        variant.setPrice(new BigDecimal("100.00"));
        variant.setDiscountPrice(new BigDecimal("80.00"));
        variant.setDiscountExpiry(LocalDateTime.now().plusDays(1));
        
        assertEquals(new BigDecimal("80.00"), variant.getCurrentPrice());
    }
    
    @Test
    @DisplayName("Test getCurrentPrice - expired discount")
    public void testGetCurrentPriceExpiredDiscount() {
        ProductVariant variant = new ProductVariant();
        variant.setPrice(new BigDecimal("100.00"));
        variant.setDiscountPrice(new BigDecimal("80.00"));
        variant.setDiscountExpiry(LocalDateTime.now().minusDays(1));
        
        assertEquals(new BigDecimal("100.00"), variant.getCurrentPrice());
    }
    
    @Test
    @DisplayName("Test getCurrentPrice - no discount")
    public void testGetCurrentPriceNoDiscount() {
        ProductVariant variant = new ProductVariant();
        variant.setPrice(new BigDecimal("100.00"));
        variant.setDiscountPrice(null);
        
        assertEquals(new BigDecimal("100.00"), variant.getCurrentPrice());
    }
    
    @Test
    @DisplayName("Test getCurrentPrice - zero discount")
    public void testGetCurrentPriceZeroDiscount() {
        ProductVariant variant = new ProductVariant();
        variant.setPrice(new BigDecimal("100.00"));
        variant.setDiscountPrice(BigDecimal.ZERO);
        
        assertEquals(new BigDecimal("100.00"), variant.getCurrentPrice());
    }
    
    @Test
    @DisplayName("Test setProductStocks")
    public void testSetProductStocks() {
        ProductVariant variant = new ProductVariant();
        List<ProductStock> stocks = new ArrayList<>();
        ProductStock s1 = new ProductStock();
        ProductStock s2 = new ProductStock();
        stocks.add(s1);
        stocks.add(s2);
        
        variant.setProductStocks(stocks);
        
        assertEquals(2, variant.getProductStocks().size());
        assertEquals(stocks, variant.getProductStocks());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        ProductVariant variant = new ProductVariant();
        UUID id = UUID.randomUUID();
        variant.setProductVariantId(id);
        variant.setSize("L");
        variant.setPrice(new BigDecimal("100.00"));
        variant.setIsDeleted(false);
        
        String result = variant.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("L"));
        assertTrue(result.contains("100.00"));
        assertTrue(result.contains("false"));
        assertTrue(result.contains("ProductVariant"));
    }
}

