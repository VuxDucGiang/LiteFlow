package com.liteflow.model.inventory;

import com.liteflow.model.auth.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.UUID;

@DisplayName("UserInteraction Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class UserInteractionTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        UserInteraction interaction = new UserInteraction();
        
        // Test default values can be set
        assertNull(interaction.getInteractionId()); // Not set until PrePersist
        assertNull(interaction.getInteractionTime()); // Not set until PrePersist
    }
    
    @Test
    @DisplayName("Test setters work correctly")
    public void testSettersWork() {
        UserInteraction interaction = new UserInteraction();
        UUID id = UUID.randomUUID();
        LocalDateTime time = LocalDateTime.now();
        
        interaction.setInteractionId(id);
        interaction.setInteractionTime(time);
        
        assertEquals(id, interaction.getInteractionId());
        assertEquals(time, interaction.getInteractionTime());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        UserInteraction interaction = new UserInteraction();
        UUID id = UUID.randomUUID();
        User user = new User();
        Product product = new Product();
        String interactionType = "VIEW";
        LocalDateTime interactionTime = LocalDateTime.now();
        
        interaction.setInteractionId(id);
        interaction.setUser(user);
        interaction.setProduct(product);
        interaction.setInteractionType(interactionType);
        interaction.setInteractionTime(interactionTime);
        
        assertEquals(id, interaction.getInteractionId());
        assertEquals(user, interaction.getUser());
        assertEquals(product, interaction.getProduct());
        assertEquals(interactionType, interaction.getInteractionType());
        assertEquals(interactionTime, interaction.getInteractionTime());
    }
    
    @Test
    @DisplayName("Test isView")
    public void testIsView() {
        UserInteraction interaction = new UserInteraction();
        interaction.setInteractionType("VIEW");
        
        assertTrue(interaction.isView());
    }
    
    @Test
    @DisplayName("Test isView - lowercase")
    public void testIsViewLowercase() {
        UserInteraction interaction = new UserInteraction();
        interaction.setInteractionType("view");
        
        assertTrue(interaction.isView());
    }
    
    @Test
    @DisplayName("Test isLike")
    public void testIsLike() {
        UserInteraction interaction = new UserInteraction();
        interaction.setInteractionType("LIKE");
        
        assertTrue(interaction.isLike());
    }
    
    @Test
    @DisplayName("Test isAddToCart")
    public void testIsAddToCart() {
        UserInteraction interaction = new UserInteraction();
        interaction.setInteractionType("ADD_TO_CART");
        
        assertTrue(interaction.isAddToCart());
    }
    
    @Test
    @DisplayName("Test isPurchase")
    public void testIsPurchase() {
        UserInteraction interaction = new UserInteraction();
        interaction.setInteractionType("PURCHASE");
        
        assertTrue(interaction.isPurchase());
    }
    
    @Test
    @DisplayName("Test isReview")
    public void testIsReview() {
        UserInteraction interaction = new UserInteraction();
        interaction.setInteractionType("REVIEW");
        
        assertTrue(interaction.isReview());
    }
    
    @Test
    @DisplayName("Test interaction type methods return false for wrong type")
    public void testInteractionTypeMethodsFalse() {
        UserInteraction interaction = new UserInteraction();
        interaction.setInteractionType("UNKNOWN");
        
        assertFalse(interaction.isView());
        assertFalse(interaction.isLike());
        assertFalse(interaction.isAddToCart());
        assertFalse(interaction.isPurchase());
        assertFalse(interaction.isReview());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        UserInteraction interaction = new UserInteraction();
        UUID id = UUID.randomUUID();
        interaction.setInteractionId(id);
        interaction.setInteractionType("VIEW");
        LocalDateTime time = LocalDateTime.now();
        interaction.setInteractionTime(time);
        
        String result = interaction.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("VIEW"));
        assertTrue(result.contains("UserInteraction"));
    }
}

