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

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Integration tests for UserService.
 * Tests user CRUD operations and role management.
 * 
 * Test Cases Covered (from PR2):
 * - TC-HP-004: Admin creates new user (RBAC)
 * - TC-EDGE-002: Email already exists
 */
@DisplayName("UserService Integration Tests")
@Tag("integration")
@Tag("auth")
@Tag("user")
@Tag("service")
public class UserServiceIntegrationTest extends IntegrationTestBase {
    
    private UserService userService;
    
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        userService = new UserService();
    }
    
    /**
     * TC-HP-004: Admin tạo user mới với role EMPLOYEE
     * 
     * Given: Admin user exists
     * When: Create new user with valid data
     * Then: User should be created with assigned role
     */
    @Test
    @DisplayName("TC-HP-004: Admin creates new user successfully")
    public void testAdminCreatesNewUser() {
        // Arrange: Create admin user
        User admin = TestDataBuilder.buildUser("admin@liteflow.com", "ADMIN");
        em.persist(admin);
        em.flush();
        
        // Create new employee user
        User newEmployee = TestDataBuilder.buildUser("employee@liteflow.com", "EMPLOYEE");
        newEmployee.setPasswordHash(PasswordUtil.hashPassword("TempPass@123"));
        
        // Act: Save new user
        boolean created = userService.createUser(newEmployee);
        em.flush();
        
        // Assert: User created
        assertTrue(created, "User should be created successfully");
        
        // Verify user exists in database
        Optional<User> found = userService.getUserById(newEmployee.getUserID());
        assertTrue(found.isPresent(), "Created user should be found");
        assertEquals("employee@liteflow.com", found.get().getEmail());
    }
    
    /**
     * Test getting all users.
     */
    @Test
    @DisplayName("Can retrieve all users")
    public void testGetAllUsers() {
        // Arrange: Create multiple users
        User user1 = TestDataBuilder.buildUser("user1@liteflow.com", "USER");
        User user2 = TestDataBuilder.buildUser("user2@liteflow.com", "USER");
        User user3 = TestDataBuilder.buildUser("user3@liteflow.com", "USER");
        
        em.persist(user1);
        em.persist(user2);
        em.persist(user3);
        em.flush();
        
        // Act: Get all users
        List<User> allUsers = userService.getAllUsers();
        
        // Assert: All users returned
        assertNotNull(allUsers, "User list should not be null");
        assertTrue(allUsers.size() >= 3, "Should have at least 3 users");
    }
    
    /**
     * Test updating user information.
     */
    @Test
    @DisplayName("Can update user information")
    public void testUpdateUser() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Update display name
        user.setDisplayName("Updated Name");
        boolean updated = userService.updateUser(user);
        em.flush();
        
        // Assert: User updated
        assertTrue(updated, "User should be updated");
        
        Optional<User> found = userService.getUserById(user.getUserID());
        assertTrue(found.isPresent());
        assertEquals("Updated Name", found.get().getDisplayName());
    }
    
    /**
     * Test locking user account.
     */
    @Test
    @DisplayName("Can lock user account")
    public void testLockUserAccount() {
        // Arrange: Create active user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        user.setIsActive(true);
        em.persist(user);
        em.flush();
        
        // Act: Lock account
        boolean locked = userService.lockAccount(user.getUserID(), "127.0.0.1");
        em.flush();
        
        // Assert: Account locked
        assertTrue(locked, "Account should be locked");
        
        Optional<User> found = userService.getUserById(user.getUserID());
        assertTrue(found.isPresent());
        assertFalse(found.get().getIsActive(), "User should be inactive");
    }
    
    /**
     * Test unlocking user account.
     */
    @Test
    @DisplayName("Can unlock user account")
    public void testUnlockUserAccount() {
        // Arrange: Create locked user
        User user = TestDataBuilder.buildInactiveUser("locked@liteflow.com");
        em.persist(user);
        em.flush();
        
        // Act: Unlock account
        boolean unlocked = userService.unlockAccount(user.getUserID(), "127.0.0.1");
        em.flush();
        
        // Assert: Account unlocked
        assertTrue(unlocked, "Account should be unlocked");
        
        Optional<User> found = userService.getUserById(user.getUserID());
        assertTrue(found.isPresent());
        assertTrue(found.get().getIsActive(), "User should be active");
    }
    
    /**
     * TC-EDGE-002: Tạo user với email đã tồn tại
     * 
     * Given: User with email exists
     * When: Try to create another user with same email
     * Then: Should handle duplicate email appropriately
     */
    @Test
    @DisplayName("TC-EDGE-002: Cannot create user with duplicate email")
    public void testCreateUserWithDuplicateEmail() {
        // Arrange: Create first user
        User user1 = TestDataBuilder.buildUser("duplicate@liteflow.com", "USER");
        em.persist(user1);
        em.flush();
        
        // Act: Try to create second user with same email
        User user2 = TestDataBuilder.buildUser("duplicate@liteflow.com", "USER");
        
        // Assert: Should throw exception or fail gracefully
        assertThrows(Exception.class, () -> {
            em.persist(user2);
            em.flush();
        }, "Duplicate email should cause exception");
    }
    
    /**
     * Test finding user by non-existent ID.
     */
    @Test
    @DisplayName("Finding non-existent user returns empty")
    public void testFindNonExistentUser() {
        // Act: Try to find non-existent user
        UUID randomId = UUID.randomUUID();
        Optional<User> found = userService.getUserById(randomId);
        
        // Assert: Should be empty
        assertFalse(found.isPresent(), "Non-existent user should return empty");
    }
    
    /**
     * Test change password functionality.
     */
    @Test
    @DisplayName("Can change user password")
    public void testChangePassword() {
        // Arrange: Create user with initial password
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        String oldPassword = "OldPass@123";
        user.setPasswordHash(PasswordUtil.hashPassword(oldPassword));
        em.persist(user);
        em.flush();
        
        // Act: Change password
        String newPassword = "NewPass@123";
        boolean changed = userService.changePassword(
            user.getUserID(), 
            oldPassword, 
            newPassword, 
            "127.0.0.1"
        );
        em.flush();
        
        // Assert: Password changed
        assertTrue(changed, "Password should be changed");
        
        // Verify new password works
        Optional<User> found = userService.getUserById(user.getUserID());
        assertTrue(found.isPresent());
        assertTrue(
            PasswordUtil.verifyPassword(newPassword, found.get().getPasswordHash()),
            "New password should verify"
        );
        
        // Verify old password no longer works
        assertFalse(
            PasswordUtil.verifyPassword(oldPassword, found.get().getPasswordHash()),
            "Old password should not verify"
        );
    }
    
    /**
     * Test user creation with all required fields.
     */
    @Test
    @DisplayName("User creation requires all mandatory fields")
    public void testUserCreationValidation() {
        // Arrange: Create user with missing email
        User invalidUser = new User();
        invalidUser.setDisplayName("Test User");
        // Email is null
        
        // Act & Assert: Should fail validation
        assertThrows(Exception.class, () -> {
            em.persist(invalidUser);
            em.flush();
        }, "User without email should fail validation");
    }
    
    /**
     * Test that user metadata JSON can be set and retrieved.
     */
    @Test
    @DisplayName("User metadata JSON works correctly")
    public void testUserMetadataJson() {
        // Arrange: Create user with metadata
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        String metadata = "{\"theme\":\"dark\",\"language\":\"vi\"}";
        user.setMeta(metadata);
        
        em.persist(user);
        em.flush();
        
        // Act: Retrieve user
        Optional<User> found = userService.getUserById(user.getUserID());
        
        // Assert: Metadata preserved
        assertTrue(found.isPresent());
        assertEquals(metadata, found.get().getMeta());
    }
}

