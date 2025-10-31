package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

@DisplayName("ProductPriceDTO Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ProductPriceDTOTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        ProductPriceDTO dto = new ProductPriceDTO();
        
        // Test that object can be created
        assertNotNull(dto);
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        ProductPriceDTO dto = new ProductPriceDTO();
        UUID productId = UUID.randomUUID();
        String productCode = "SP001";
        String productName = "Test Product";
        String size = "L";
        Double originalPrice = 120.0;
        Double sellingPrice = 100.0;
        String categoryName = "Food";
        Boolean isDeleted = false;
        
        dto.setProductId(productId);
        dto.setProductCode(productCode);
        dto.setProductName(productName);
        dto.setSize(size);
        dto.setOriginalPrice(originalPrice);
        dto.setSellingPrice(sellingPrice);
        dto.setCategoryName(categoryName);
        dto.setIsDeleted(isDeleted);
        
        assertEquals(productId, dto.getProductId());
        assertEquals(productCode, dto.getProductCode());
        assertEquals(productName, dto.getProductName());
        assertEquals(size, dto.getSize());
        assertEquals(originalPrice, dto.getOriginalPrice());
        assertEquals(sellingPrice, dto.getSellingPrice());
        assertEquals(categoryName, dto.getCategoryName());
        assertEquals(isDeleted, dto.getIsDeleted());
    }
    
    @Test
    @DisplayName("Test all getters return null initially")
    public void testGettersReturnNull() {
        ProductPriceDTO dto = new ProductPriceDTO();
        
        assertNull(dto.getProductId());
        assertNull(dto.getProductCode());
        assertNull(dto.getProductName());
        assertNull(dto.getSize());
        assertNull(dto.getOriginalPrice());
        assertNull(dto.getSellingPrice());
        assertNull(dto.getCategoryName());
        assertNull(dto.getIsDeleted());
    }
}

