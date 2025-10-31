package com.liteflow.model.inventory;

import com.liteflow.model.auth.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@DisplayName("PaymentTransaction Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class PaymentTransactionTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        PaymentTransaction transaction = new PaymentTransaction();
        
        assertEquals("Completed", transaction.getPaymentStatus());
    }
    
    @Test
    @DisplayName("Test default payment status")
    public void testDefaultPaymentStatus() {
        PaymentTransaction transaction = new PaymentTransaction();
        
        assertEquals("Completed", transaction.getPaymentStatus());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        PaymentTransaction transaction = new PaymentTransaction();
        UUID id = UUID.randomUUID();
        TableSession session = new TableSession();
        Order order = new Order();
        BigDecimal amount = new BigDecimal("100.50");
        String paymentMethod = "Cash";
        String paymentStatus = "Pending";
        String transactionReference = "REF123";
        String notes = "Test notes";
        User user = new User();
        LocalDateTime processedAt = LocalDateTime.now();
        
        transaction.setTransactionId(id);
        transaction.setSession(session);
        transaction.setOrder(order);
        transaction.setAmount(amount);
        transaction.setPaymentMethod(paymentMethod);
        transaction.setPaymentStatus(paymentStatus);
        transaction.setTransactionReference(transactionReference);
        transaction.setNotes(notes);
        transaction.setProcessedBy(user);
        transaction.setProcessedAt(processedAt);
        
        assertEquals(id, transaction.getTransactionId());
        assertEquals(session, transaction.getSession());
        assertEquals(order, transaction.getOrder());
        assertEquals(amount, transaction.getAmount());
        assertEquals(paymentMethod, transaction.getPaymentMethod());
        assertEquals(paymentStatus, transaction.getPaymentStatus());
        assertEquals(transactionReference, transaction.getTransactionReference());
        assertEquals(notes, transaction.getNotes());
        assertEquals(user, transaction.getProcessedBy());
        assertEquals(processedAt, transaction.getProcessedAt());
    }
    
    @Test
    @DisplayName("Test isCompleted")
    public void testIsCompleted() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentStatus("Completed");
        
        assertTrue(transaction.isCompleted());
    }
    
    @Test
    @DisplayName("Test isPending")
    public void testIsPending() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentStatus("Pending");
        
        assertTrue(transaction.isPending());
    }
    
    @Test
    @DisplayName("Test isFailed")
    public void testIsFailed() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentStatus("Failed");
        
        assertTrue(transaction.isFailed());
    }
    
    @Test
    @DisplayName("Test isRefunded")
    public void testIsRefunded() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentStatus("Refunded");
        
        assertTrue(transaction.isRefunded());
    }
    
    @Test
    @DisplayName("Test isCashPayment")
    public void testIsCashPayment() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentMethod("Cash");
        
        assertTrue(transaction.isCashPayment());
    }
    
    @Test
    @DisplayName("Test isCardPayment")
    public void testIsCardPayment() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentMethod("Card");
        
        assertTrue(transaction.isCardPayment());
    }
    
    @Test
    @DisplayName("Test isTransferPayment")
    public void testIsTransferPayment() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentMethod("Transfer");
        
        assertTrue(transaction.isTransferPayment());
    }
    
    @Test
    @DisplayName("Test isWalletPayment")
    public void testIsWalletPayment() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentMethod("Wallet");
        
        assertTrue(transaction.isWalletPayment());
    }
    
    @Test
    @DisplayName("Test payment status methods return false for wrong status")
    public void testPaymentStatusMethodsFalse() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentStatus("Unknown");
        
        assertFalse(transaction.isCompleted());
        assertFalse(transaction.isPending());
        assertFalse(transaction.isFailed());
        assertFalse(transaction.isRefunded());
    }
    
    @Test
    @DisplayName("Test payment method methods return false for wrong method")
    public void testPaymentMethodMethodsFalse() {
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentMethod("Unknown");
        
        assertFalse(transaction.isCashPayment());
        assertFalse(transaction.isCardPayment());
        assertFalse(transaction.isTransferPayment());
        assertFalse(transaction.isWalletPayment());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        PaymentTransaction transaction = new PaymentTransaction();
        UUID id = UUID.randomUUID();
        transaction.setTransactionId(id);
        transaction.setAmount(new BigDecimal("100.50"));
        transaction.setPaymentMethod("Cash");
        transaction.setPaymentStatus("Completed");
        LocalDateTime date = LocalDateTime.now();
        transaction.setProcessedAt(date);
        
        String result = transaction.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("100.50"));
        assertTrue(result.contains("Cash"));
        assertTrue(result.contains("Completed"));
        assertTrue(result.contains("PaymentTransaction"));
    }
}

