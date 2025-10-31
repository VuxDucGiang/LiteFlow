package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

@DisplayName("ReservationItem Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ReservationItemTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        ReservationItem item = new ReservationItem();
        
        assertEquals(1, item.getQuantity());
    }
    
    @Test
    @DisplayName("Test constructor with parameters")
    public void testConstructorWithParameters() {
        Reservation reservation = new Reservation();
        Product product = new Product();
        Integer quantity = 5;
        
        ReservationItem item = new ReservationItem(reservation, product, quantity);
        
        assertEquals(reservation, item.getReservation());
        assertEquals(product, item.getProduct());
        assertEquals(quantity, item.getQuantity());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        ReservationItem item = new ReservationItem();
        UUID id = UUID.randomUUID();
        Reservation reservation = new Reservation();
        Product product = new Product();
        Integer quantity = 3;
        String note = "Extra spicy";
        
        item.setReservationItemId(id);
        item.setReservation(reservation);
        item.setProduct(product);
        item.setQuantity(quantity);
        item.setNote(note);
        
        assertEquals(id, item.getReservationItemId());
        assertEquals(reservation, item.getReservation());
        assertEquals(product, item.getProduct());
        assertEquals(quantity, item.getQuantity());
        assertEquals(note, item.getNote());
    }
    
    @Test
    @DisplayName("Test toString with null product")
    public void testToStringWithNullProduct() {
        ReservationItem item = new ReservationItem();
        UUID id = UUID.randomUUID();
        item.setReservationItemId(id);
        item.setProduct(null);
        item.setQuantity(3);
        item.setNote("Test note");
        
        String result = item.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("null"));
        assertTrue(result.contains("3"));
        assertTrue(result.contains("Test note"));
        assertTrue(result.contains("ReservationItem"));
    }
    
    @Test
    @DisplayName("Test toString with product")
    public void testToStringWithProduct() {
        ReservationItem item = new ReservationItem();
        UUID id = UUID.randomUUID();
        Product product = new Product();
        product.setName("Test Product");
        item.setReservationItemId(id);
        item.setProduct(product);
        item.setQuantity(2);
        item.setNote("No note");
        
        String result = item.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("Test Product"));
        assertTrue(result.contains("2"));
        assertTrue(result.contains("No note"));
        assertTrue(result.contains("ReservationItem"));
    }
}

