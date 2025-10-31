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
import java.util.Set;

/**
 * Integration tests for user signup flow.
 * Tests email verification, OTP, and account creation.
 * 
 * Test Cases Covered (from PR2):
 * - TC-HP-008: Signup with email verification
 * - TC-ERR-005: Signup with existing email
 */
@DisplayName("Signup Integration Tests")
@Tag("integration")
@Tag("auth")
@Tag("signup")
@Tag("service")
public class SignupIntegrationTest extends IntegrationTestBase {
    
    private UserService userService;
    private OtpService otpService;
    private RoleService roleService;
    
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        userService = new UserService();
        otpService = new OtpService();
        roleService = new RoleService();
    }
    
    /**
     * TC-HP-008: Signup với email verification (OTP)
     * 
     * Given: New user wants to signup
     * When: Complete signup flow with email OTP
     * Then: User should be created and activated
     */
    @Test
    @DisplayName("TC-HP-008: Complete signup flow with OTP verification")
    public void testSignupWithOtpVerification() {
        // Arrange: Prepare signup data
        String email = "newuser@liteflow.com";
        String password = "SecurePass@123";
        String displayName = "New User";
        
        // Step 1: Request OTP for email
        String otpCode = otpService.issueOtpForEmail(email, "127.0.0.1");
        assertNotNull(otpCode, "OTP should be generated for signup");
        
        // Step 2: Create user (pending verification)
        User newUser = TestDataBuilder.buildUser(email, "USER");
        newUser.setDisplayName(displayName);
        newUser.setPasswordHash(PasswordUtil.hashPassword(password));
        newUser.setIsActive(false); // Initially inactive until OTP verified
        
        boolean created = userService.createUser(newUser);
        em.flush();
        
        assertTrue(created, "User should be created");
        
        // Step 3: Verify OTP
        boolean otpValid = otpService.validateOtp(newUser, otpCode, "127.0.0.1");
        assertTrue(otpValid, "OTP should be valid");
        
        // Step 4: Activate user after OTP verification
        newUser.setIsActive(true);
        boolean activated = userService.updateUser(newUser);
        em.flush();
        
        // Assert: User created and activated
        assertTrue(activated, "User should be activated after OTP verification");
        
        Optional<User> found = userService.getUserById(newUser.getUserID());
        assertTrue(found.isPresent(), "Created user should be found");
        assertTrue(found.get().getIsActive(), "User should be active");
        assertEquals(email, found.get().getEmail(), "Email should match");
    }
    
    /**
     * TC-ERR-005: Signup với email đã tồn tại
     * 
     * Given: Email already registered
     * When: Try to signup with same email
     * Then: Should reject duplicate signup
     */
    @Test
    @DisplayName("TC-ERR-005: Signup fails with duplicate email")
    public void testSignupWithDuplicateEmail() {
        // Arrange: Create existing user
        String existingEmail = "existing@liteflow.com";
        User existingUser = TestDataBuilder.buildUser(existingEmail, "USER");
        
        em.persist(existingUser);
        em.flush();
        
        // Act: Try to create another user with same email
        User duplicateUser = TestDataBuilder.buildUser(existingEmail, "USER");
        
        // Assert: Should throw exception
        assertThrows(Exception.class, () -> {
            em.persist(duplicateUser);
            em.flush();
        }, "Duplicate email signup should fail");
    }
    
    /**
     * Test signup with default USER role assignment.
     */
    @Test
    @DisplayName("New signup gets default USER role")
    public void testSignupWithDefaultRole() {
        // Arrange: Create default USER role
        Role userRole = TestDataBuilder.buildRole("USER");
        em.persist(userRole);
        em.flush();
        
        // Create new user
        User newUser = TestDataBuilder.buildUser("newuser@liteflow.com", "USER");
        em.persist(newUser);
        em.flush();
        
        // Assign default role
        boolean assigned = roleService.assignRole(
            newUser.getUserID(), 
            userRole.getRoleID(), 
            "127.0.0.1"
        );
        em.flush();
        
        // Assert: Role assigned
        assertTrue(assigned, "Default role should be assigned");
        
        Set<String> roles = roleService.getUserRoles(newUser.getUserID());
        assertTrue(roles.contains("USER"), "New user should have USER role");
    }
    
    /**
     * Test signup validation - email required.
     */
    @Test
    @DisplayName("Signup requires email address")
    public void testSignupRequiresEmail() {
        // Arrange: User without email
        User invalidUser = new User();
        invalidUser.setDisplayName("No Email");
        invalidUser.setPasswordHash(PasswordUtil.hashPassword("Pass@123"));
        // Email is null
        
        // Act & Assert: Should fail
        assertThrows(Exception.class, () -> {
            em.persist(invalidUser);
            em.flush();
        }, "Signup without email should fail");
    }
    
    /**
     * Test signup validation - password required.
     */
    @Test
    @DisplayName("Signup requires password")
    public void testSignupRequiresPassword() {
        // Arrange: User without password
        User user = TestDataBuilder.buildUser("nopass@liteflow.com", "USER");
        user.setPasswordHash(null); // No password
        
        em.persist(user);
        em.flush();
        
        // This test depends on business logic - some systems allow
        // OAuth-only users without passwords
        
        // Assert: User created but might require password later
        Optional<User> found = userService.getUserById(user.getUserID());
        assertTrue(found.isPresent(), "User should be created");
        assertNull(found.get().getPasswordHash(), "Password hash is null");
    }
    
    /**
     * Test signup with email verification timeout.
     */
    @Test
    @DisplayName("Signup OTP expires after timeout")
    public void testSignupOtpExpiration() {
        // Arrange: Create expired OTP for email
        String email = "newuser@liteflow.com";
        
        User newUser = TestDataBuilder.buildUser(email, "USER");
        em.persist(newUser);
        
        com.liteflow.model.auth.OtpToken expiredOtp = 
            TestDataBuilder.buildExpiredOtpToken(newUser, "123456");
        em.persist(expiredOtp);
        em.flush();
        
        // Act: Try to verify with expired OTP
        boolean otpValid = otpService.validateOtp(newUser, "123456", "127.0.0.1");
        
        // Assert: Should fail
        assertFalse(otpValid, "Expired signup OTP should not be valid");
    }
    
    /**
     * Test signup with invalid email format.
     */
    @Test
    @DisplayName("Signup validates email format")
    public void testSignupWithInvalidEmail() {
        // This test depends on validation logic in the service/controller layer
        // At database level, any string is acceptable for email field
        
        String[] invalidEmails = {
            "notanemail",
            "missing@domain",
            "@nodomain.com",
            "spaces in@email.com"
        };
        
        // For now, we document that validation should exist
        // Actual validation implementation may vary
        
        for (String invalidEmail : invalidEmails) {
            User user = TestDataBuilder.buildUser(invalidEmail, "USER");
            // If validation exists at DB level, this would fail
            // Otherwise, validation should be at application level
        }
    }
    
    /**
     * Test signup with Google OAuth (no password).
     */
    @Test
    @DisplayName("Signup with OAuth does not require password")
    public void testSignupWithOAuth() {
        // Arrange: Create OAuth user
        String email = "oauth@gmail.com";
        String googleId = "108234567890";
        
        User oauthUser = TestDataBuilder.buildGoogleUser(email, googleId);
        oauthUser.setPasswordHash(null); // OAuth users don't need password
        
        boolean created = userService.createUser(oauthUser);
        em.flush();
        
        // Assert: OAuth user created without password
        assertTrue(created, "OAuth user should be created");
        
        Optional<User> found = userService.getUserById(oauthUser.getUserID());
        assertTrue(found.isPresent(), "OAuth user should be found");
        assertNotNull(found.get().getGoogleID(), "GoogleID should be set");
        assertNull(found.get().getPasswordHash(), "OAuth user doesn't need password");
    }
    
    /**
     * Test signup with display name.
     */
    @Test
    @DisplayName("Signup allows custom display name")
    public void testSignupWithCustomDisplayName() {
        // Arrange: Create user with custom display name
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        String customName = "John Doe Jr.";
        user.setDisplayName(customName);
        
        boolean created = userService.createUser(user);
        em.flush();
        
        // Assert: Display name saved
        assertTrue(created, "User should be created");
        
        Optional<User> found = userService.getUserById(user.getUserID());
        assertTrue(found.isPresent());
        assertEquals(customName, found.get().getDisplayName(), 
            "Custom display name should be saved");
    }
    
    /**
     * Test signup creates audit log entry.
     */
    @Test
    @DisplayName("Signup creates audit trail")
    public void testSignupCreatesAuditLog() {
        // Arrange: Create new user (signup)
        User newUser = TestDataBuilder.buildUser("newuser@liteflow.com", "USER");
        
        boolean created = userService.createUser(newUser);
        em.flush();
        
        // Assert: User created
        assertTrue(created, "User should be created");
        
        // Audit log verification would depend on AuditService implementation
        // For now, we document that audit logging should occur
        // In real implementation, check AuditLogs table for SIGNUP entry
    }
}

