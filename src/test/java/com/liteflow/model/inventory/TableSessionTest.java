package com.liteflow.model.inventory;

import com.liteflow.model.auth.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("TableSession Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class TableSessionTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        TableSession session = new TableSession();
        
        assertEquals("Active", session.getStatus());
        assertEquals(BigDecimal.ZERO, session.getTotalAmount());
        assertEquals("Unpaid", session.getPaymentStatus());
        assertNotNull(session.getOrders());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        TableSession session = new TableSession();
        UUID id = UUID.randomUUID();
        Table table = new Table();
        String customerName = "John Doe";
        String customerPhone = "0123456789";
        LocalDateTime checkInTime = LocalDateTime.now();
        LocalDateTime checkOutTime = LocalDateTime.now().plusHours(2);
        String status = "Completed";
        BigDecimal totalAmount = new BigDecimal("150.00");
        String paymentMethod = "Cash";
        String paymentStatus = "Paid";
        String invoiceName = "Invoice 001";
        String notes = "Test notes";
        User createdBy = new User();
        LocalDateTime updatedAt = LocalDateTime.now();
        
        session.setSessionId(id);
        session.setTable(table);
        session.setCustomerName(customerName);
        session.setCustomerPhone(customerPhone);
        session.setCheckInTime(checkInTime);
        session.setCheckOutTime(checkOutTime);
        session.setStatus(status);
        session.setTotalAmount(totalAmount);
        session.setPaymentMethod(paymentMethod);
        session.setPaymentStatus(paymentStatus);
        session.setInvoiceName(invoiceName);
        session.setNotes(notes);
        session.setCreatedBy(createdBy);
        session.setUpdatedAt(updatedAt);
        
        assertEquals(id, session.getSessionId());
        assertEquals(table, session.getTable());
        assertEquals(customerName, session.getCustomerName());
        assertEquals(customerPhone, session.getCustomerPhone());
        assertEquals(checkInTime, session.getCheckInTime());
        assertEquals(checkOutTime, session.getCheckOutTime());
        assertEquals(status, session.getStatus());
        assertEquals(totalAmount, session.getTotalAmount());
        assertEquals(paymentMethod, session.getPaymentMethod());
        assertEquals(paymentStatus, session.getPaymentStatus());
        assertEquals(invoiceName, session.getInvoiceName());
        assertEquals(notes, session.getNotes());
        assertEquals(createdBy, session.getCreatedBy());
        assertEquals(updatedAt, session.getUpdatedAt());
    }
    
    @Test
    @DisplayName("Test addOrder")
    public void testAddOrder() {
        TableSession session = new TableSession();
        Order order = new Order();
        
        session.addOrder(order);
        
        assertTrue(session.getOrders().contains(order));
        assertEquals(session, order.getSession());
    }
    
    @Test
    @DisplayName("Test addOrder with null list")
    public void testAddOrderWithNullList() {
        TableSession session = new TableSession();
        session.setOrders(null);
        
        Order order = new Order();
        session.addOrder(order);
        
        assertNotNull(session.getOrders());
        assertTrue(session.getOrders().contains(order));
    }
    
    @Test
    @DisplayName("Test removeOrder")
    public void testRemoveOrder() {
        TableSession session = new TableSession();
        Order order = new Order();
        
        session.addOrder(order);
        assertTrue(session.getOrders().contains(order));
        
        session.removeOrder(order);
        
        assertFalse(session.getOrders().contains(order));
        assertNull(order.getSession());
    }
    
    @Test
    @DisplayName("Test isActive")
    public void testIsActive() {
        TableSession session = new TableSession();
        session.setStatus("Active");
        
        assertTrue(session.isActive());
    }
    
    @Test
    @DisplayName("Test isActive - false")
    public void testIsActiveFalse() {
        TableSession session = new TableSession();
        session.setStatus("Completed");
        
        assertFalse(session.isActive());
    }
    
    @Test
    @DisplayName("Test isCompleted")
    public void testIsCompleted() {
        TableSession session = new TableSession();
        session.setStatus("Completed");
        
        assertTrue(session.isCompleted());
    }
    
    @Test
    @DisplayName("Test isCancelled")
    public void testIsCancelled() {
        TableSession session = new TableSession();
        session.setStatus("Cancelled");
        
        assertTrue(session.isCancelled());
    }
    
    @Test
    @DisplayName("Test status methods return false for wrong status")
    public void testStatusMethodsFalse() {
        TableSession session = new TableSession();
        session.setStatus("Unknown");
        
        assertFalse(session.isActive());
        assertFalse(session.isCompleted());
        assertFalse(session.isCancelled());
    }
    
    @Test
    @DisplayName("Test setOrders")
    public void testSetOrders() {
        TableSession session = new TableSession();
        List<Order> orders = new ArrayList<>();
        Order o1 = new Order();
        Order o2 = new Order();
        orders.add(o1);
        orders.add(o2);
        
        session.setOrders(orders);
        
        assertEquals(2, session.getOrders().size());
        assertEquals(orders, session.getOrders());
    }
}

