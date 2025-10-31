package com.liteflow.helpers.mocks;

import com.liteflow.service.auth.OtpService;
import org.mockito.Mockito;

import java.util.UUID;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * MockServiceHelper provides mock implementations of external services.
 * Used to isolate tests from external dependencies like email, payment gateways, OAuth, etc.
 * 
 * Usage:
 * <pre>
 * OtpService otpService = MockServiceHelper.mockOtpServiceSuccess();
 * when(otpService.generateOtp(any())).thenReturn("123456");
 * </pre>
 */
public class MockServiceHelper {
    
    // ==========================================
    // OTP SERVICE MOCKS
    // ==========================================
    
    /**
     * Mock OtpService - Note: Actual methods depend on OtpService implementation.
     * This is a placeholder for when OtpService interface is defined.
     */
    public static Object mockOtpServiceSuccess() {
        // TODO: Implement after OtpService interface is finalized
        // OtpService mock = Mockito.mock(OtpService.class);
        // when(mock.someMethod(any())).thenReturn("123456");
        return null;
    }
    
    /**
     * Mock OtpService failure - placeholder.
     */
    public static Object mockOtpServiceFail() {
        // TODO: Implement after OtpService interface is finalized
        return null;
    }
    
    // ==========================================
    // OAUTH SERVICE MOCKS
    // ==========================================
    
    /**
     * Mock OAuth2 verification success.
     * Returns a mock OAuth2User with predefined data.
     */
    public static GoogleOAuth2User mockOAuthSuccess() {
        return new GoogleOAuth2User(
            "1234567890",
            "test@gmail.com",
            "Test User",
            "https://example.com/avatar.jpg"
        );
    }
    
    /**
     * Mock OAuth2 verification failure.
     */
    public static GoogleOAuth2User mockOAuthFailure() {
        return null;
    }
    
    // ==========================================
    // EMAIL SERVICE MOCKS
    // ==========================================
    
    /**
     * Mock EmailService that does nothing (successful send).
     */
    public static void mockEmailServiceSuccess() {
        // In real implementation, this would mock MailUtil or EmailService
        // For now, we just return void since email sending is not critical for tests
    }
    
    // ==========================================
    // PAYMENT GATEWAY MOCKS
    // ==========================================
    
    /**
     * Mock PaymentGateway that always succeeds.
     */
    public static PaymentResponse mockPaymentSuccess() {
        return new PaymentResponse(
            true,
            "txn_" + UUID.randomUUID(),
            "Approved",
            "Payment successful"
        );
    }
    
    /**
     * Mock PaymentGateway that fails.
     */
    public static PaymentResponse mockPaymentFailure() {
        return new PaymentResponse(
            false,
            null,
            "Declined",
            "Insufficient funds"
        );
    }
    
    /**
     * Mock PaymentGateway that times out.
     */
    public static void mockPaymentTimeout() throws Exception {
        throw new Exception("Gateway timeout");
    }
    
    // ==========================================
    // HELPER CLASSES
    // ==========================================
    
    /**
     * Simple mock OAuth2User for Google authentication.
     */
    public static class GoogleOAuth2User {
        public final String googleId;
        public final String email;
        public final String displayName;
        public final String pictureUrl;
        
        public GoogleOAuth2User(String googleId, String email, String displayName, String pictureUrl) {
            this.googleId = googleId;
            this.email = email;
            this.displayName = displayName;
            this.pictureUrl = pictureUrl;
        }
    }
    
    /**
     * Simple mock PaymentResponse.
     */
    public static class PaymentResponse {
        public final boolean success;
        public final String transactionId;
        public final String status;
        public final String message;
        
        public PaymentResponse(boolean success, String transactionId, String status, String message) {
            this.success = success;
            this.transactionId = transactionId;
            this.status = status;
            this.message = message;
        }
    }
}

