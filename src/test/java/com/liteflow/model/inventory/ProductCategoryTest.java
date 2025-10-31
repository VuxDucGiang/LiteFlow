package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

@DisplayName("ProductCategory Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ProductCategoryTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        ProductCategory productCategory = new ProductCategory();
        
        // Test that object can be created
        assertNull(productCategory.getProductCategoryId()); // Not set until PrePersist
        assertNull(productCategory.getProduct());
        assertNull(productCategory.getCategory());
    }
    
    @Test
    @DisplayName("Test setProductCategoryId")
    public void testSetProductCategoryId() {
        ProductCategory productCategory = new ProductCategory();
        UUID id = UUID.randomUUID();
        
        productCategory.setProductCategoryId(id);
        
        assertEquals(id, productCategory.getProductCategoryId());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        ProductCategory productCategory = new ProductCategory();
        UUID id = UUID.randomUUID();
        Product product = new Product();
        Category category = new Category();
        
        productCategory.setProductCategoryId(id);
        productCategory.setProduct(product);
        productCategory.setCategory(category);
        
        assertEquals(id, productCategory.getProductCategoryId());
        assertEquals(product, productCategory.getProduct());
        assertEquals(category, productCategory.getCategory());
    }
    
    @Test
    @DisplayName("Test toString with null product and category")
    public void testToStringWithNulls() {
        ProductCategory productCategory = new ProductCategory();
        UUID id = UUID.randomUUID();
        productCategory.setProductCategoryId(id);
        productCategory.setProduct(null);
        productCategory.setCategory(null);
        
        String result = productCategory.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("null"));
        assertTrue(result.contains("ProductCategory"));
    }
    
    @Test
    @DisplayName("Test toString with product and category")
    public void testToStringWithValues() {
        ProductCategory productCategory = new ProductCategory();
        UUID id = UUID.randomUUID();
        Product product = new Product();
        product.setName("Test Product");
        Category category = new Category();
        category.setName("Test Category");
        
        productCategory.setProductCategoryId(id);
        productCategory.setProduct(product);
        productCategory.setCategory(category);
        
        String result = productCategory.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("Test Product"));
        assertTrue(result.contains("Test Category"));
        assertTrue(result.contains("ProductCategory"));
    }
}

