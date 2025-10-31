package com.liteflow.service.auth;

import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.helpers.builders.TestDataBuilder;
import com.liteflow.model.auth.User;
import com.liteflow.model.auth.OtpToken;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Integration tests for OtpService.
 * Tests OTP generation, validation, and cleanup.
 * 
 * Test Cases Covered (from PR2):
 * - TC-HP-003: 2FA verification success
 * - TC-ERR-002: 2FA verification with wrong code
 */
@DisplayName("OtpService Integration Tests")
@Tag("integration")
@Tag("auth")
@Tag("otp")
@Tag("service")
public class OtpServiceIntegrationTest extends IntegrationTestBase {
    
    private OtpService otpService;
    
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        otpService = new OtpService();
    }
    
    /**
     * TC-HP-003: Xác thực 2FA (TOTP) thành công
     * 
     * Given: User has valid OTP generated
     * When: Validate with correct OTP code
     * Then: Should return true and mark OTP as used
     */
    @Test
    @DisplayName("TC-HP-003: 2FA verification succeeds with correct code")
    public void test2FAVerificationSuccess() {
        // Arrange: Create user and generate OTP
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Generate OTP
        String otpCode = otpService.issueOtp(user, "127.0.0.1");
        assertNotNull(otpCode, "OTP should be generated");
        assertEquals(6, otpCode.length(), "OTP should be 6 digits");
        
        // Act: Validate OTP
        boolean isValid = otpService.validateOtp(user, otpCode, "127.0.0.1");
        
        // Assert: Validation successful
        assertTrue(isValid, "Valid OTP should be accepted");
        
        // Verify OTP cannot be reused
        boolean reused = otpService.validateOtp(user, otpCode, "127.0.0.1");
        assertFalse(reused, "Used OTP should not be valid again");
    }
    
    /**
     * TC-ERR-002: Xác thực 2FA với TOTP code sai
     * 
     * Given: User has valid OTP
     * When: Validate with incorrect OTP code
     * Then: Should return false
     */
    @Test
    @DisplayName("TC-ERR-002: 2FA verification fails with incorrect code")
    public void test2FAVerificationWithInvalidCode() {
        // Arrange
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Generate OTP but don't use the generated code
        otpService.issueOtp(user, "127.0.0.1");
        
        // Act: Try with wrong code
        boolean isValid = otpService.validateOtp(user, "000000", "127.0.0.1");
        
        // Assert: Should fail (unless special admin case)
        if (!user.getEmail().equalsIgnoreCase("admin@liteflow.com")) {
            assertFalse(isValid, "Invalid OTP should be rejected");
        }
    }
    
    /**
     * Test OTP expiration (5 minutes).
     */
    @Test
    @DisplayName("OTP expires after 5 minutes")
    public void testOtpExpiration() {
        // Arrange: Create user and OTP
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Create expired OTP manually
        OtpToken expiredOtp = TestDataBuilder.buildExpiredOtpToken(user, "123456");
        em.persist(expiredOtp);
        em.flush();
        
        // Act: Try to validate expired OTP
        boolean isValid = otpService.validateOtp(user, "123456", "127.0.0.1");
        
        // Assert: Should be invalid
        assertFalse(isValid, "Expired OTP should not be valid");
    }
    
    /**
     * Test OTP for email (signup flow).
     */
    @Test
    @DisplayName("Can generate OTP for email before user exists")
    public void testOtpForEmail() {
        // Arrange: Email without user
        String email = "newuser@liteflow.com";
        
        // Act: Generate OTP for email
        String otpCode = otpService.issueOtpForEmail(email, "127.0.0.1");
        
        // Assert: OTP generated
        assertNotNull(otpCode, "OTP should be generated for email");
        assertEquals(6, otpCode.length(), "OTP should be 6 digits");
        assertTrue(otpCode.matches("\\d{6}"), "OTP should be numeric");
    }
    
    /**
     * Test OTP cleanup removes expired tokens.
     */
    @Test
    @DisplayName("Cleanup removes expired OTP tokens")
    public void testOtpCleanup() {
        // Arrange: Create user with expired OTP
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        
        OtpToken expiredOtp = TestDataBuilder.buildExpiredOtpToken(user, "123456");
        em.persist(expiredOtp);
        em.flush();
        
        // Act: Run cleanup
        int deleted = otpService.cleanupExpired();
        
        // Assert: Expired OTP should be deleted
        assertTrue(deleted >= 1, "At least one expired OTP should be cleaned up");
    }
    
    /**
     * Test special admin OTP (000000 always works for admin).
     */
    @Test
    @DisplayName("Admin can use special OTP 000000")
    public void testAdminSpecialOtp() {
        // Arrange: Create admin user
        User admin = TestDataBuilder.buildUser("admin@liteflow.com", "ADMIN");
        em.persist(admin);
        em.flush();
        
        // Act: Validate with special admin OTP
        boolean isValid = otpService.validateOtp(admin, "000000", "127.0.0.1");
        
        // Assert: Should always work for admin
        assertTrue(isValid, "Admin should be able to use special OTP 000000");
    }
    
    /**
     * Test OTP validation with null inputs.
     */
    @Test
    @DisplayName("OTP validation handles null inputs")
    public void testOtpValidationWithNullInputs() {
        // Arrange
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act & Assert: Various null scenarios
        assertFalse(otpService.validateOtp(null, "123456", "127.0.0.1"), 
            "Null user should return false");
        
        assertFalse(otpService.validateOtp(user, null, "127.0.0.1"), 
            "Null OTP should return false");
        
        assertFalse(otpService.validateOtp(user, "", "127.0.0.1"), 
            "Empty OTP should return false");
        
        assertFalse(otpService.validateOtp(user, "   ", "127.0.0.1"), 
            "Blank OTP should return false");
    }
    
    /**
     * Test multiple OTP generations invalidate previous ones.
     */
    @Test
    @DisplayName("New OTP invalidates previous active OTPs")
    public void testNewOtpInvalidatesPrevious() {
        // Arrange
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Generate first OTP
        String firstOtp = otpService.issueOtp(user, "127.0.0.1");
        
        // Generate second OTP (should invalidate first)
        String secondOtp = otpService.issueOtp(user, "127.0.0.1");
        
        // Act: Try to use first OTP
        boolean firstValid = otpService.validateOtp(user, firstOtp, "127.0.0.1");
        boolean secondValid = otpService.validateOtp(user, secondOtp, "127.0.0.1");
        
        // Assert: Only second OTP should work
        assertFalse(firstValid, "First OTP should be invalidated");
        assertTrue(secondValid, "Second OTP should be valid");
    }
    
    /**
     * Test OTP validation for non-existent user.
     */
    @Test
    @DisplayName("OTP validation fails for non-existent user")
    public void testOtpValidationForNonExistentUser() {
        // Arrange: User not in database
        User nonExistentUser = TestDataBuilder.buildUser("nonexistent@liteflow.com", "USER");
        // Don't persist
        
        // Act: Try to validate OTP
        boolean isValid = otpService.validateOtp(nonExistentUser, "123456", "127.0.0.1");
        
        // Assert: Should fail
        assertFalse(isValid, "OTP validation should fail for non-existent user");
    }
}

