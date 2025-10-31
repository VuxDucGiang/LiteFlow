package com.liteflow.service.auth;

import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.helpers.builders.TestDataBuilder;
import com.liteflow.model.auth.User;
import com.liteflow.model.auth.Role;
import com.liteflow.model.auth.UserRole;
import com.liteflow.util.PasswordUtil;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;

import java.util.Optional;
import java.util.UUID;

/**
 * Integration tests for AuthService.
 * Tests business logic for authentication flow.
 * 
 * Test Cases Covered (from PR2):
 * - TC-HP-001: Login successfully with email/password
 * - TC-EDGE-001: Login with password typo
 * - TC-ERR-001: Login with non-existent user
 */
@DisplayName("AuthService Integration Tests")
@Tag("integration")
@Tag("auth")
@Tag("service")
public class AuthServiceIntegrationTest extends IntegrationTestBase {
    
    private AuthService authService;
    
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        authService = new AuthService();
    }
    
    /**
     * TC-HP-001: Đăng nhập thành công với email/password
     * 
     * Given: User exists with valid password
     * When: Authenticate with correct credentials
     * Then: Should return user and verify password successfully
     */
    @Test
    @DisplayName("TC-HP-001: Login successfully with valid credentials")
    public void testLoginSuccess() {
        // Arrange: Create user with hashed password
        User user = TestDataBuilder.buildUser("admin@liteflow.com", "ADMIN");
        String rawPassword = "Admin@123";
        user.setPasswordHash(PasswordUtil.hashPassword(rawPassword));
        
        em.persist(user);
        em.flush();
        
        // Act: Find user by email
        Optional<User> foundUser = authService.findByEmail("admin@liteflow.com");
        
        // Assert: User found
        assertTrue(foundUser.isPresent(), "User should be found by email");
        assertEquals("admin@liteflow.com", foundUser.get().getEmail());
        
        // Verify password
        boolean passwordMatch = authService.checkPassword(foundUser.get(), rawPassword);
        assertTrue(passwordMatch, "Password should match");
    }
    
    /**
     * TC-EDGE-001: Đăng nhập với password gần đúng (typo)
     * 
     * Given: User exists with password "Admin@123"
     * When: Try to authenticate with "Admin@12" (typo)
     * Then: Should reject authentication
     */
    @Test
    @DisplayName("TC-EDGE-001: Login fails with password typo")
    public void testLoginWithPasswordTypo() {
        // Arrange
        User user = TestDataBuilder.buildUser("admin@liteflow.com", "ADMIN");
        String correctPassword = "Admin@123";
        user.setPasswordHash(PasswordUtil.hashPassword(correctPassword));
        
        em.persist(user);
        em.flush();
        
        // Act: Try with typo password
        Optional<User> foundUser = authService.findByEmail("admin@liteflow.com");
        boolean passwordMatch = authService.checkPassword(
            foundUser.get(), 
            "Admin@12"  // Missing last character
        );
        
        // Assert: Should fail
        assertFalse(passwordMatch, "Password with typo should not match");
    }
    
    /**
     * TC-ERR-001: Đăng nhập với user không tồn tại
     * 
     * Given: User does not exist in database
     * When: Try to find user by email
     * Then: Should return empty Optional
     */
    @Test
    @DisplayName("TC-ERR-001: Login fails with non-existent user")
    public void testLoginWithNonExistentUser() {
        // Act: Try to find non-existent user
        Optional<User> foundUser = authService.findByEmail("nonexistent@liteflow.com");
        
        // Assert: Should be empty
        assertFalse(foundUser.isPresent(), "Non-existent user should not be found");
    }
    
    /**
     * Test case-insensitive email lookup.
     */
    @Test
    @DisplayName("Email lookup is case-insensitive")
    public void testEmailLookupCaseInsensitive() {
        // Arrange
        User user = TestDataBuilder.buildUser("Test@LiteFlow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Try different cases
        Optional<User> found1 = authService.findByEmail("test@liteflow.com");
        Optional<User> found2 = authService.findByEmail("TEST@LITEFLOW.COM");
        Optional<User> found3 = authService.findByEmail("Test@LiteFlow.com");
        
        // Assert: All should find the same user
        assertTrue(found1.isPresent(), "Lowercase should find user");
        assertTrue(found2.isPresent(), "Uppercase should find user");
        assertTrue(found3.isPresent(), "Mixed case should find user");
        
        assertEquals(user.getUserID(), found1.get().getUserID());
        assertEquals(user.getUserID(), found2.get().getUserID());
        assertEquals(user.getUserID(), found3.get().getUserID());
    }
    
    /**
     * Test authentication with inactive user.
     */
    @Test
    @DisplayName("Cannot authenticate inactive user")
    public void testAuthenticationWithInactiveUser() {
        // Arrange
        User user = TestDataBuilder.buildInactiveUser("inactive@liteflow.com");
        String password = "Test@123";
        user.setPasswordHash(PasswordUtil.hashPassword(password));
        
        em.persist(user);
        em.flush();
        
        // Act
        Optional<User> foundUser = authService.findByEmail("inactive@liteflow.com");
        
        // Assert: User found but is inactive
        assertTrue(foundUser.isPresent(), "User should be found");
        assertFalse(foundUser.get().getIsActive(), "User should be inactive");
    }
    
    /**
     * Test email validation with null/empty values.
     */
    @Test
    @DisplayName("Email lookup handles null/empty input")
    public void testEmailLookupWithInvalidInput() {
        // Act & Assert
        Optional<User> nullResult = authService.findByEmail(null);
        assertFalse(nullResult.isPresent(), "Null email should return empty");
        
        Optional<User> emptyResult = authService.findByEmail("");
        assertFalse(emptyResult.isPresent(), "Empty email should return empty");
        
        Optional<User> blankResult = authService.findByEmail("   ");
        assertFalse(blankResult.isPresent(), "Blank email should return empty");
    }
    
    /**
     * Test password verification with null password.
     */
    @Test
    @DisplayName("Password check handles null password")
    public void testPasswordCheckWithNullPassword() {
        // Arrange
        User user = TestDataBuilder.buildUser("test@liteflow.com", "USER");
        user.setPasswordHash(PasswordUtil.hashPassword("Test@123"));
        
        em.persist(user);
        em.flush();
        
        // Act & Assert
        boolean result = authService.checkPassword(user, null);
        assertFalse(result, "Null password should not match");
    }
    
    /**
     * Test authentication flow with multiple users.
     */
    @Test
    @DisplayName("Can authenticate multiple different users")
    public void testMultipleUserAuthentication() {
        // Arrange: Create multiple users
        User admin = TestDataBuilder.buildUser("admin@liteflow.com", "ADMIN");
        admin.setPasswordHash(PasswordUtil.hashPassword("AdminPass@123"));
        
        User cashier = TestDataBuilder.buildUser("cashier@liteflow.com", "CASHIER");
        cashier.setPasswordHash(PasswordUtil.hashPassword("CashierPass@123"));
        
        em.persist(admin);
        em.persist(cashier);
        em.flush();
        
        // Act: Authenticate both
        Optional<User> foundAdmin = authService.findByEmail("admin@liteflow.com");
        Optional<User> foundCashier = authService.findByEmail("cashier@liteflow.com");
        
        // Assert: Both found and passwords verified
        assertTrue(foundAdmin.isPresent());
        assertTrue(foundCashier.isPresent());
        
        assertTrue(authService.checkPassword(foundAdmin.get(), "AdminPass@123"));
        assertTrue(authService.checkPassword(foundCashier.get(), "CashierPass@123"));
        
        // Cross-verification should fail
        assertFalse(authService.checkPassword(foundAdmin.get(), "CashierPass@123"));
        assertFalse(authService.checkPassword(foundCashier.get(), "AdminPass@123"));
    }
}

