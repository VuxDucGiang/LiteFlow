package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("Reservation Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class ReservationTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        Reservation reservation = new Reservation();
        
        assertEquals("PENDING", reservation.getStatus());
        assertNotNull(reservation.getReservationItems());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        Reservation reservation = new Reservation();
        UUID id = UUID.randomUUID();
        String reservationCode = "RES001";
        String customerName = "John Doe";
        String customerPhone = "0123456789";
        String customerEmail = "john@example.com";
        LocalDateTime arrivalTime = LocalDateTime.now().plusDays(1);
        Integer numberOfGuests = 4;
        Table table = new Table();
        Room room = new Room();
        String status = "CONFIRMED";
        String notes = "Window seat preferred";
        LocalDateTime createdAt = LocalDateTime.now();
        LocalDateTime updatedAt = LocalDateTime.now();
        
        reservation.setReservationId(id);
        reservation.setReservationCode(reservationCode);
        reservation.setCustomerName(customerName);
        reservation.setCustomerPhone(customerPhone);
        reservation.setCustomerEmail(customerEmail);
        reservation.setArrivalTime(arrivalTime);
        reservation.setNumberOfGuests(numberOfGuests);
        reservation.setTable(table);
        reservation.setRoom(room);
        reservation.setStatus(status);
        reservation.setNotes(notes);
        reservation.setCreatedAt(createdAt);
        reservation.setUpdatedAt(updatedAt);
        
        assertEquals(id, reservation.getReservationId());
        assertEquals(reservationCode, reservation.getReservationCode());
        assertEquals(customerName, reservation.getCustomerName());
        assertEquals(customerPhone, reservation.getCustomerPhone());
        assertEquals(customerEmail, reservation.getCustomerEmail());
        assertEquals(arrivalTime, reservation.getArrivalTime());
        assertEquals(numberOfGuests, reservation.getNumberOfGuests());
        assertEquals(table, reservation.getTable());
        assertEquals(room, reservation.getRoom());
        assertEquals(status, reservation.getStatus());
        assertEquals(notes, reservation.getNotes());
        assertEquals(createdAt, reservation.getCreatedAt());
        assertEquals(updatedAt, reservation.getUpdatedAt());
    }
    
    @Test
    @DisplayName("Test addReservationItem")
    public void testAddReservationItem() {
        Reservation reservation = new Reservation();
        ReservationItem item = new ReservationItem();
        
        reservation.addReservationItem(item);
        
        assertTrue(reservation.getReservationItems().contains(item));
        assertEquals(reservation, item.getReservation());
    }
    
    @Test
    @DisplayName("Test addReservationItem with null list")
    public void testAddReservationItemWithNullList() {
        Reservation reservation = new Reservation();
        reservation.setReservationItems(null);
        
        ReservationItem item = new ReservationItem();
        reservation.addReservationItem(item);
        
        assertNotNull(reservation.getReservationItems());
        assertTrue(reservation.getReservationItems().contains(item));
    }
    
    @Test
    @DisplayName("Test removeReservationItem")
    public void testRemoveReservationItem() {
        Reservation reservation = new Reservation();
        ReservationItem item = new ReservationItem();
        
        reservation.addReservationItem(item);
        assertTrue(reservation.getReservationItems().contains(item));
        
        reservation.removeReservationItem(item);
        
        assertFalse(reservation.getReservationItems().contains(item));
        assertNull(item.getReservation());
    }
    
    @Test
    @DisplayName("Test isPending")
    public void testIsPending() {
        Reservation reservation = new Reservation();
        reservation.setStatus("PENDING");
        
        assertTrue(reservation.isPending());
    }
    
    @Test
    @DisplayName("Test isConfirmed")
    public void testIsConfirmed() {
        Reservation reservation = new Reservation();
        reservation.setStatus("CONFIRMED");
        
        assertTrue(reservation.isConfirmed());
    }
    
    @Test
    @DisplayName("Test isSeated")
    public void testIsSeated() {
        Reservation reservation = new Reservation();
        reservation.setStatus("SEATED");
        
        assertTrue(reservation.isSeated());
    }
    
    @Test
    @DisplayName("Test isCancelled")
    public void testIsCancelled() {
        Reservation reservation = new Reservation();
        reservation.setStatus("CANCELLED");
        
        assertTrue(reservation.isCancelled());
    }
    
    @Test
    @DisplayName("Test isNoShow")
    public void testIsNoShow() {
        Reservation reservation = new Reservation();
        reservation.setStatus("NO_SHOW");
        
        assertTrue(reservation.isNoShow());
    }
    
    @Test
    @DisplayName("Test status methods return false for wrong status")
    public void testStatusMethodsFalse() {
        Reservation reservation = new Reservation();
        reservation.setStatus("UNKNOWN");
        
        assertFalse(reservation.isPending());
        assertFalse(reservation.isConfirmed());
        assertFalse(reservation.isSeated());
        assertFalse(reservation.isCancelled());
        assertFalse(reservation.isNoShow());
    }
    
    @Test
    @DisplayName("Test hasTable - with table")
    public void testHasTable() {
        Reservation reservation = new Reservation();
        reservation.setTable(new Table());
        
        assertTrue(reservation.hasTable());
    }
    
    @Test
    @DisplayName("Test hasTable - without table")
    public void testHasTableFalse() {
        Reservation reservation = new Reservation();
        reservation.setTable(null);
        
        assertFalse(reservation.hasTable());
    }
    
    @Test
    @DisplayName("Test isOverdue - overdue")
    public void testIsOverdue() {
        Reservation reservation = new Reservation();
        reservation.setArrivalTime(LocalDateTime.now().minusMinutes(30));
        reservation.setStatus("PENDING");
        
        assertTrue(reservation.isOverdue(15));
    }
    
    @Test
    @DisplayName("Test isOverdue - not overdue")
    public void testIsOverdueNot() {
        Reservation reservation = new Reservation();
        reservation.setArrivalTime(LocalDateTime.now().plusMinutes(30));
        reservation.setStatus("PENDING");
        
        assertFalse(reservation.isOverdue(15));
    }
    
    @Test
    @DisplayName("Test isOverdue - null arrivalTime")
    public void testIsOverdueNullArrivalTime() {
        Reservation reservation = new Reservation();
        reservation.setArrivalTime(null);
        
        assertFalse(reservation.isOverdue(15));
    }
    
    @Test
    @DisplayName("Test isOverdue - already seated")
    public void testIsOverdueSeated() {
        Reservation reservation = new Reservation();
        reservation.setArrivalTime(LocalDateTime.now().minusMinutes(30));
        reservation.setStatus("SEATED");
        
        assertFalse(reservation.isOverdue(15));
    }
    
    @Test
    @DisplayName("Test setReservationItems")
    public void testSetReservationItems() {
        Reservation reservation = new Reservation();
        List<ReservationItem> items = new ArrayList<>();
        ReservationItem item1 = new ReservationItem();
        ReservationItem item2 = new ReservationItem();
        items.add(item1);
        items.add(item2);
        
        reservation.setReservationItems(items);
        
        assertEquals(2, reservation.getReservationItems().size());
        assertEquals(items, reservation.getReservationItems());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        Reservation reservation = new Reservation();
        UUID id = UUID.randomUUID();
        reservation.setReservationId(id);
        reservation.setReservationCode("RES001");
        reservation.setCustomerName("John Doe");
        reservation.setCustomerPhone("0123456789");
        LocalDateTime arrivalTime = LocalDateTime.now();
        reservation.setArrivalTime(arrivalTime);
        reservation.setNumberOfGuests(4);
        reservation.setStatus("PENDING");
        
        String result = reservation.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("RES001"));
        assertTrue(result.contains("John Doe"));
        assertTrue(result.contains("0123456789"));
        assertTrue(result.contains("4"));
        assertTrue(result.contains("PENDING"));
        assertTrue(result.contains("Reservation"));
    }
}

