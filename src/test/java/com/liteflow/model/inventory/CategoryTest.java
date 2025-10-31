package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("Category Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class CategoryTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        Category category = new Category();
        
        assertNotNull(category.getProductCategories());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        Category category = new Category();
        UUID id = UUID.randomUUID();
        String name = "Test Category";
        String description = "Test Description";
        
        category.setCategoryId(id);
        category.setName(name);
        category.setDescription(description);
        
        assertEquals(id, category.getCategoryId());
        assertEquals(name, category.getName());
        assertEquals(description, category.getDescription());
    }
    
    @Test
    @DisplayName("Test addProductCategory")
    public void testAddProductCategory() {
        Category category = new Category();
        ProductCategory productCategory = new ProductCategory();
        
        category.addProductCategory(productCategory);
        
        assertTrue(category.getProductCategories().contains(productCategory));
        assertEquals(category, productCategory.getCategory());
    }
    
    @Test
    @DisplayName("Test addProductCategory with null list")
    public void testAddProductCategoryWithNullList() {
        Category category = new Category();
        category.setProductCategories(null);
        
        ProductCategory productCategory = new ProductCategory();
        category.addProductCategory(productCategory);
        
        assertNotNull(category.getProductCategories());
        assertTrue(category.getProductCategories().contains(productCategory));
    }
    
    @Test
    @DisplayName("Test removeProductCategory")
    public void testRemoveProductCategory() {
        Category category = new Category();
        ProductCategory productCategory = new ProductCategory();
        
        category.addProductCategory(productCategory);
        assertTrue(category.getProductCategories().contains(productCategory));
        
        category.removeProductCategory(productCategory);
        
        assertFalse(category.getProductCategories().contains(productCategory));
        assertNull(productCategory.getCategory());
    }
    
    @Test
    @DisplayName("Test removeProductCategory with null list")
    public void testRemoveProductCategoryWithNullList() {
        Category category = new Category();
        category.setProductCategories(null);
        
        ProductCategory productCategory = new ProductCategory();
        // Should not throw exception
        category.removeProductCategory(productCategory);
    }
    
    @Test
    @DisplayName("Test setProductCategories")
    public void testSetProductCategories() {
        Category category = new Category();
        List<ProductCategory> productCategories = new ArrayList<>();
        ProductCategory pc1 = new ProductCategory();
        ProductCategory pc2 = new ProductCategory();
        productCategories.add(pc1);
        productCategories.add(pc2);
        
        category.setProductCategories(productCategories);
        
        assertEquals(2, category.getProductCategories().size());
        assertEquals(productCategories, category.getProductCategories());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        Category category = new Category();
        UUID id = UUID.randomUUID();
        String name = "Test Category";
        category.setCategoryId(id);
        category.setName(name);
        
        String result = category.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains(name));
        assertTrue(result.contains("Category"));
    }
}

