package com.liteflow.service.auth;

import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.helpers.builders.TestDataBuilder;
import com.liteflow.model.auth.User;
import com.liteflow.model.auth.Role;
import com.liteflow.model.auth.UserRole;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;

import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Integration tests for RoleService.
 * Tests role assignment and RBAC functionality.
 * 
 * Test Cases Covered (from PR2):
 * - TC-HP-005: RBAC authorization check
 * - TC-ERR-003: Unauthorized access attempt
 */
@DisplayName("RoleService Integration Tests")
@Tag("integration")
@Tag("auth")
@Tag("rbac")
@Tag("service")
public class RoleServiceIntegrationTest extends IntegrationTestBase {
    
    private RoleService roleService;
    
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        roleService = new RoleService();
    }
    
    /**
     * TC-HP-005: Cashier có quyền truy cập POS
     * 
     * Given: User has CASHIER role
     * When: Check permissions for /cart/* endpoint
     * Then: Should be authorized
     */
    @Test
    @DisplayName("TC-HP-005: Cashier authorized for POS access")
    public void testCashierAuthorizedForPOS() {
        // Arrange: Create cashier user with role
        User cashier = TestDataBuilder.buildUser("cashier@liteflow.com", "CASHIER");
        Role cashierRole = TestDataBuilder.buildRole("CASHIER");
        
        em.persist(cashier);
        em.persist(cashierRole);
        em.flush();
        
        // Assign role to user
        UserRole userRole = TestDataBuilder.buildUserRole(cashier, cashierRole);
        em.persist(userRole);
        em.flush();
        
        // Act: Get user roles
        Set<String> roles = roleService.getUserRoles(cashier.getUserID());
        
        // Assert: Should have CASHIER role
        assertNotNull(roles, "Roles should not be null");
        assertTrue(roles.contains("CASHIER"), "User should have CASHIER role");
    }
    
    /**
     * TC-ERR-003: User không có quyền truy cập tài nguyên
     * 
     * Given: User has EMPLOYEE role only
     * When: Try to access admin-only resource
     * Then: Should be unauthorized
     */
    @Test
    @DisplayName("TC-ERR-003: Employee unauthorized for admin access")
    public void testEmployeeUnauthorizedForAdmin() {
        // Arrange: Create employee user (not admin)
        User employee = TestDataBuilder.buildUser("employee@liteflow.com", "EMPLOYEE");
        Role employeeRole = TestDataBuilder.buildRole("EMPLOYEE");
        
        em.persist(employee);
        em.persist(employeeRole);
        em.flush();
        
        UserRole userRole = TestDataBuilder.buildUserRole(employee, employeeRole);
        em.persist(userRole);
        em.flush();
        
        // Act: Get user roles
        Set<String> roles = roleService.getUserRoles(employee.getUserID());
        
        // Assert: Should NOT have ADMIN role
        assertNotNull(roles, "Roles should not be null");
        assertFalse(roles.contains("ADMIN"), "Employee should not have ADMIN role");
        assertTrue(roles.contains("EMPLOYEE"), "User should have EMPLOYEE role");
    }
    
    /**
     * Test assigning role to user.
     */
    @Test
    @DisplayName("Can assign role to user")
    public void testAssignRoleToUser() {
        // Arrange: Create user and role
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        Role role = TestDataBuilder.buildRole("MANAGER");
        
        em.persist(user);
        em.persist(role);
        em.flush();
        
        // Act: Assign role
        boolean assigned = roleService.assignRole(user.getUserID(), role.getRoleID(), "127.0.0.1");
        em.flush();
        
        // Assert: Role assigned
        assertTrue(assigned, "Role should be assigned");
        
        Set<String> roles = roleService.getUserRoles(user.getUserID());
        assertTrue(roles.contains("MANAGER"), "User should have MANAGER role");
    }
    
    /**
     * Test removing role from user.
     */
    @Test
    @DisplayName("Can remove role from user")
    public void testRemoveRoleFromUser() {
        // Arrange: Create user with role
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        Role role = TestDataBuilder.buildRole("CASHIER");
        
        em.persist(user);
        em.persist(role);
        em.flush();
        
        UserRole userRole = TestDataBuilder.buildUserRole(user, role);
        em.persist(userRole);
        em.flush();
        
        // Act: Remove role
        boolean removed = roleService.removeRole(user.getUserID(), role.getRoleID(), "127.0.0.1");
        em.flush();
        
        // Assert: Role removed
        assertTrue(removed, "Role should be removed");
        
        Set<String> roles = roleService.getUserRoles(user.getUserID());
        assertFalse(roles.contains("CASHIER"), "User should not have CASHIER role");
    }
    
    /**
     * Test user with multiple roles.
     */
    @Test
    @DisplayName("User can have multiple roles")
    public void testUserWithMultipleRoles() {
        // Arrange: Create user and multiple roles
        User user = TestDataBuilder.buildUser("manager@liteflow.com", "MANAGER");
        Role managerRole = TestDataBuilder.buildRole("MANAGER");
        Role cashierRole = TestDataBuilder.buildRole("CASHIER");
        
        em.persist(user);
        em.persist(managerRole);
        em.persist(cashierRole);
        em.flush();
        
        // Assign both roles
        UserRole ur1 = TestDataBuilder.buildUserRole(user, managerRole);
        UserRole ur2 = TestDataBuilder.buildUserRole(user, cashierRole);
        
        em.persist(ur1);
        em.persist(ur2);
        em.flush();
        
        // Act: Get user roles
        Set<String> roles = roleService.getUserRoles(user.getUserID());
        
        // Assert: Should have both roles
        assertNotNull(roles, "Roles should not be null");
        assertTrue(roles.size() >= 2, "User should have at least 2 roles");
        assertTrue(roles.contains("MANAGER"), "User should have MANAGER role");
        assertTrue(roles.contains("CASHIER"), "User should have CASHIER role");
    }
    
    /**
     * Test getting all roles.
     */
    @Test
    @DisplayName("Can retrieve all system roles")
    public void testGetAllRoles() {
        // Arrange: Create multiple roles
        Role admin = TestDataBuilder.buildRole("ADMIN");
        Role manager = TestDataBuilder.buildRole("MANAGER");
        Role cashier = TestDataBuilder.buildRole("CASHIER");
        
        em.persist(admin);
        em.persist(manager);
        em.persist(cashier);
        em.flush();
        
        // Act: Get all roles
        List<Role> allRoles = roleService.getAllRoles();
        
        // Assert: All roles returned
        assertNotNull(allRoles, "Roles list should not be null");
        assertTrue(allRoles.size() >= 3, "Should have at least 3 roles");
    }
    
    /**
     * Test role with permissions.
     */
    @Test
    @DisplayName("Role can have permissions defined")
    public void testRoleWithPermissions() {
        // Arrange: Create role with permissions
        Role adminRole = TestDataBuilder.buildRole("ADMIN");
        String permissions = "[\"read\",\"write\",\"delete\",\"manage_users\"]";
        adminRole.setPermissions(permissions);
        
        em.persist(adminRole);
        em.flush();
        
        // Act: Retrieve role
        Role found = em.find(Role.class, adminRole.getRoleID());
        
        // Assert: Permissions preserved
        assertNotNull(found, "Role should be found");
        assertEquals(permissions, found.getPermissions(), "Permissions should match");
    }
    
    /**
     * Test checking if user has specific role.
     */
    @Test
    @DisplayName("Can check if user has specific role")
    public void testHasRole() {
        // Arrange: Create user with specific role
        User user = TestDataBuilder.buildUser("admin@liteflow.com", "ADMIN");
        Role adminRole = TestDataBuilder.buildRole("ADMIN");
        
        em.persist(user);
        em.persist(adminRole);
        em.flush();
        
        UserRole userRole = TestDataBuilder.buildUserRole(user, adminRole);
        em.persist(userRole);
        em.flush();
        
        // Act: Check role
        boolean hasAdmin = roleService.hasRole(user.getUserID(), "ADMIN");
        boolean hasManager = roleService.hasRole(user.getUserID(), "MANAGER");
        
        // Assert: Correct role checks
        assertTrue(hasAdmin, "User should have ADMIN role");
        assertFalse(hasManager, "User should not have MANAGER role");
    }
    
    /**
     * Test role assignment to non-existent user fails.
     */
    @Test
    @DisplayName("Cannot assign role to non-existent user")
    public void testAssignRoleToNonExistentUser() {
        // Arrange: Create role but no user
        Role role = TestDataBuilder.buildRole("CASHIER");
        em.persist(role);
        em.flush();
        
        // Act: Try to assign role to random user ID
        UUID randomUserId = UUID.randomUUID();
        boolean assigned = roleService.assignRole(randomUserId, role.getRoleID(), "127.0.0.1");
        
        // Assert: Should fail
        assertFalse(assigned, "Cannot assign role to non-existent user");
    }
    
    /**
     * Test user with no roles returns empty set.
     */
    @Test
    @DisplayName("User with no roles returns empty set")
    public void testUserWithNoRoles() {
        // Arrange: Create user without roles
        User user = TestDataBuilder.buildUser("noroles@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Get roles
        Set<String> roles = roleService.getUserRoles(user.getUserID());
        
        // Assert: Empty set
        assertNotNull(roles, "Roles should not be null");
        assertTrue(roles.isEmpty(), "User should have no roles");
    }
}

