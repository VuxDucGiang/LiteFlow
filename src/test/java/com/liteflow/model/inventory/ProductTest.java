package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("Product Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ProductTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        Product product = new Product();
        
        assertEquals(false, product.getIsDeleted());
        assertNotNull(product.getProductVariants());
        assertNotNull(product.getProductCategories());
        assertNotNull(product.getUserInteractions());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        Product product = new Product();
        UUID id = UUID.randomUUID();
        String name = "Test Product";
        String description = "Test Description";
        String imageUrl = "http://example.com/image.jpg";
        LocalDateTime importDate = LocalDateTime.now();
        Boolean isDeleted = false;
        String productType = "Food";
        String status = "Active";
        String unit = "Piece";
        
        product.setProductId(id);
        product.setName(name);
        product.setDescription(description);
        product.setImageUrl(imageUrl);
        product.setImportDate(importDate);
        product.setIsDeleted(isDeleted);
        product.setProductType(productType);
        product.setStatus(status);
        product.setUnit(unit);
        
        assertEquals(id, product.getProductId());
        assertEquals(name, product.getName());
        assertEquals(description, product.getDescription());
        assertEquals(imageUrl, product.getImageUrl());
        assertEquals(importDate, product.getImportDate());
        assertEquals(isDeleted, product.getIsDeleted());
        assertEquals(productType, product.getProductType());
        assertEquals(status, product.getStatus());
        assertEquals(unit, product.getUnit());
    }
    
    @Test
    @DisplayName("Test addProductVariant")
    public void testAddProductVariant() {
        Product product = new Product();
        ProductVariant variant = new ProductVariant();
        
        product.addProductVariant(variant);
        
        assertTrue(product.getProductVariants().contains(variant));
        assertEquals(product, variant.getProduct());
    }
    
    @Test
    @DisplayName("Test addProductVariant with null list")
    public void testAddProductVariantWithNullList() {
        Product product = new Product();
        product.setProductVariants(null);
        
        ProductVariant variant = new ProductVariant();
        product.addProductVariant(variant);
        
        assertNotNull(product.getProductVariants());
        assertTrue(product.getProductVariants().contains(variant));
    }
    
    @Test
    @DisplayName("Test removeProductVariant")
    public void testRemoveProductVariant() {
        Product product = new Product();
        ProductVariant variant = new ProductVariant();
        
        product.addProductVariant(variant);
        assertTrue(product.getProductVariants().contains(variant));
        
        product.removeProductVariant(variant);
        
        assertFalse(product.getProductVariants().contains(variant));
        assertNull(variant.getProduct());
    }
    
    @Test
    @DisplayName("Test addProductCategory")
    public void testAddProductCategory() {
        Product product = new Product();
        ProductCategory productCategory = new ProductCategory();
        
        product.addProductCategory(productCategory);
        
        assertTrue(product.getProductCategories().contains(productCategory));
        assertEquals(product, productCategory.getProduct());
    }
    
    @Test
    @DisplayName("Test removeProductCategory")
    public void testRemoveProductCategory() {
        Product product = new Product();
        ProductCategory productCategory = new ProductCategory();
        
        product.addProductCategory(productCategory);
        assertTrue(product.getProductCategories().contains(productCategory));
        
        product.removeProductCategory(productCategory);
        
        assertFalse(product.getProductCategories().contains(productCategory));
        assertNull(productCategory.getProduct());
    }
    
    @Test
    @DisplayName("Test addUserInteraction")
    public void testAddUserInteraction() {
        Product product = new Product();
        UserInteraction interaction = new UserInteraction();
        
        product.addUserInteraction(interaction);
        
        assertTrue(product.getUserInteractions().contains(interaction));
        assertEquals(product, interaction.getProduct());
    }
    
    @Test
    @DisplayName("Test removeUserInteraction")
    public void testRemoveUserInteraction() {
        Product product = new Product();
        UserInteraction interaction = new UserInteraction();
        
        product.addUserInteraction(interaction);
        assertTrue(product.getUserInteractions().contains(interaction));
        
        product.removeUserInteraction(interaction);
        
        assertFalse(product.getUserInteractions().contains(interaction));
        assertNull(interaction.getProduct());
    }
    
    @Test
    @DisplayName("Test isActive - not deleted")
    public void testIsActiveNotDeleted() {
        Product product = new Product();
        product.setIsDeleted(false);
        
        assertTrue(product.isActive());
    }
    
    @Test
    @DisplayName("Test isActive - deleted")
    public void testIsActiveDeleted() {
        Product product = new Product();
        product.setIsDeleted(true);
        
        assertFalse(product.isActive());
    }
    
    @Test
    @DisplayName("Test isActive - null isDeleted")
    public void testIsActiveNull() {
        Product product = new Product();
        product.setIsDeleted(null);
        
        assertTrue(product.isActive());
    }
    
    @Test
    @DisplayName("Test setProductVariants")
    public void testSetProductVariants() {
        Product product = new Product();
        List<ProductVariant> variants = new ArrayList<>();
        ProductVariant v1 = new ProductVariant();
        ProductVariant v2 = new ProductVariant();
        variants.add(v1);
        variants.add(v2);
        
        product.setProductVariants(variants);
        
        assertEquals(2, product.getProductVariants().size());
        assertEquals(variants, product.getProductVariants());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        Product product = new Product();
        UUID id = UUID.randomUUID();
        product.setProductId(id);
        product.setName("Test Product");
        product.setProductType("Food");
        product.setIsDeleted(false);
        
        String result = product.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("Test Product"));
        assertTrue(result.contains("Food"));
        assertTrue(result.contains("false"));
        assertTrue(result.contains("Product"));
    }
}

