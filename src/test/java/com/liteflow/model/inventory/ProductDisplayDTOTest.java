package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

@DisplayName("ProductDisplayDTO Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ProductDisplayDTOTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        ProductDisplayDTO dto = new ProductDisplayDTO();
        
        // Test that object can be created
        assertNotNull(dto);
    }
    
    @Test
    @DisplayName("Test constructor with parameters")
    public void testConstructorWithParameters() {
        UUID productId = UUID.randomUUID();
        String productCode = "SP001";
        String productName = "Test Product";
        Double price = 100.0;
        int stockAmount = 50;
        String size = "L";
        Boolean isDeleted = false;
        String imageUrl = "http://example.com/image.jpg";
        String categoryName = "Food";
        
        ProductDisplayDTO dto = new ProductDisplayDTO(
            productId, productCode, productName, price, stockAmount, size, isDeleted, imageUrl, categoryName
        );
        
        assertEquals(productId, dto.getProductId());
        assertEquals(productCode, dto.getProductCode());
        assertEquals(productName, dto.getProductName());
        assertEquals(price, dto.getPrice());
        assertEquals(stockAmount, dto.getStockAmount());
        assertEquals(size, dto.getSize());
        assertEquals(isDeleted, dto.getIsDeleted());
        assertEquals(imageUrl, dto.getImageUrl());
        assertEquals(categoryName, dto.getCategoryName());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        ProductDisplayDTO dto = new ProductDisplayDTO();
        UUID productId = UUID.randomUUID();
        String productCode = "SP002";
        String productName = "Product 2";
        Double price = 150.0;
        int stockAmount = 30;
        String size = "M";
        Boolean isDeleted = false;
        String imageUrl = "http://example.com/img2.jpg";
        String categoryName = "Drink";
        String productType = "Beverage";
        String description = "Test description";
        String status = "Active";
        String unit = "Bottle";
        
        dto.setProductId(productId);
        dto.setProductCode(productCode);
        dto.setProductName(productName);
        dto.setPrice(price);
        dto.setStockAmount(stockAmount);
        dto.setSize(size);
        dto.setIsDeleted(isDeleted);
        dto.setImageUrl(imageUrl);
        dto.setCategoryName(categoryName);
        dto.setProductType(productType);
        dto.setDescription(description);
        dto.setStatus(status);
        dto.setUnit(unit);
        
        assertEquals(productId, dto.getProductId());
        assertEquals(productCode, dto.getProductCode());
        assertEquals(productName, dto.getProductName());
        assertEquals(price, dto.getPrice());
        assertEquals(stockAmount, dto.getStockAmount());
        assertEquals(size, dto.getSize());
        assertEquals(isDeleted, dto.getIsDeleted());
        assertEquals(imageUrl, dto.getImageUrl());
        assertEquals(categoryName, dto.getCategoryName());
        assertEquals(productType, dto.getProductType());
        assertEquals(description, dto.getDescription());
        assertEquals(status, dto.getStatus());
        assertEquals(unit, dto.getUnit());
    }
}

