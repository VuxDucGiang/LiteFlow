package com.liteflow.helpers.base;

import com.liteflow.model.auth.*;
import com.liteflow.helpers.builders.TestDataBuilder;
import jakarta.persistence.EntityManager;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * TestScenarios provides pre-built complex scenarios for testing.
 * These scenarios set up multiple related entities in the database.
 * 
 * Usage:
 * <pre>
 * AuthTestScenario scenario = TestScenarios.createAuthScenario(em);
 * User admin = scenario.adminUser;
 * Role adminRole = scenario.adminRole;
 * </pre>
 */
public class TestScenarios {
    
    // ==========================================
    // AUTH MODULE SCENARIOS
    // ==========================================
    
    /**
     * Create a complete authentication test scenario with multiple users and roles.
     * 
     * Sets up:
     * - 4 Roles: ADMIN, MANAGER, CASHIER, EMPLOYEE
     * - 4 Users: admin, manager, cashier, employee
     * - UserRoles linking each user to their role
     * - Sessions for each user
     * 
     * @param em EntityManager (must have an active transaction)
     * @return AuthTestScenario with all created entities
     */
    public static AuthTestScenario createAuthScenario(EntityManager em) {
        // 1. Create Roles
        Role adminRole = TestDataBuilder.buildRole("ADMIN");
        Role managerRole = TestDataBuilder.buildRole("MANAGER");
        Role cashierRole = TestDataBuilder.buildRole("CASHIER");
        Role employeeRole = TestDataBuilder.buildRole("EMPLOYEE");
        
        em.persist(adminRole);
        em.persist(managerRole);
        em.persist(cashierRole);
        em.persist(employeeRole);
        
        // 2. Create Users
        User adminUser = TestDataBuilder.buildUser("admin@liteflow.com", "ADMIN");
        User managerUser = TestDataBuilder.buildUser("manager@liteflow.com", "MANAGER");
        User cashierUser = TestDataBuilder.buildUser("cashier@liteflow.com", "CASHIER");
        User employeeUser = TestDataBuilder.buildUser("employee@liteflow.com", "EMPLOYEE");
        
        em.persist(adminUser);
        em.persist(managerUser);
        em.persist(cashierUser);
        em.persist(employeeUser);
        
        // 3. Create UserRoles
        UserRole adminUserRole = TestDataBuilder.buildUserRole(adminUser, adminRole);
        UserRole managerUserRole = TestDataBuilder.buildUserRole(managerUser, managerRole);
        UserRole cashierUserRole = TestDataBuilder.buildUserRole(cashierUser, cashierRole);
        UserRole employeeUserRole = TestDataBuilder.buildUserRole(employeeUser, employeeRole);
        
        em.persist(adminUserRole);
        em.persist(managerUserRole);
        em.persist(cashierUserRole);
        em.persist(employeeUserRole);
        
        // 4. Create Sessions
        UserSession adminSession = TestDataBuilder.buildSession(adminUser);
        UserSession managerSession = TestDataBuilder.buildSession(managerUser);
        UserSession cashierSession = TestDataBuilder.buildSession(cashierUser);
        
        em.persist(adminSession);
        em.persist(managerSession);
        em.persist(cashierSession);
        
        em.flush();
        
        return new AuthTestScenario(
            adminUser, managerUser, cashierUser, employeeUser,
            adminRole, managerRole, cashierRole, employeeRole,
            adminSession, managerSession, cashierSession
        );
    }
    
    /**
     * Create a simple auth scenario with one user.
     * 
     * @param em EntityManager
     * @param email User email
     * @param roleName Role name
     * @return SimpleAuthScenario
     */
    public static SimpleAuthScenario createSimpleAuthScenario(EntityManager em, String email, String roleName) {
        Role role = TestDataBuilder.buildRole(roleName);
        User user = TestDataBuilder.buildUser(email, roleName);
        UserRole userRole = TestDataBuilder.buildUserRole(user, role);
        UserSession session = TestDataBuilder.buildSession(user);
        
        em.persist(role);
        em.persist(user);
        em.persist(userRole);
        em.persist(session);
        em.flush();
        
        return new SimpleAuthScenario(user, role, userRole, session);
    }
    
    /**
     * Create an auth scenario with 2FA enabled user.
     * 
     * @param em EntityManager
     * @return TwoFactorAuthScenario
     */
    public static TwoFactorAuthScenario create2FAScenario(EntityManager em) {
        Role role = TestDataBuilder.buildRole("ADMIN");
        User user = TestDataBuilder.buildUserWith2FA("admin2fa@liteflow.com", "JBSWY3DPEHPK3PXP");
        UserRole userRole = TestDataBuilder.buildUserRole(user, role);
        OtpToken otpToken = TestDataBuilder.buildOtpToken(user, "123456");
        
        em.persist(role);
        em.persist(user);
        em.persist(userRole);
        em.persist(otpToken);
        em.flush();
        
        return new TwoFactorAuthScenario(user, role, otpToken);
    }
    
    /**
     * Create an OAuth scenario with Google user.
     * 
     * @param em EntityManager
     * @return OAuthScenario
     */
    public static OAuthScenario createOAuthScenario(EntityManager em) {
        Role role = TestDataBuilder.buildRole("USER");
        User googleUser = TestDataBuilder.buildGoogleUser("googleuser@gmail.com", "1234567890");
        UserRole userRole = TestDataBuilder.buildUserRole(googleUser, role);
        UserSession session = TestDataBuilder.buildSession(googleUser);
        
        em.persist(role);
        em.persist(googleUser);
        em.persist(userRole);
        em.persist(session);
        em.flush();
        
        return new OAuthScenario(googleUser, role, session);
    }
    
    // ==========================================
    // SCENARIO DATA CLASSES
    // ==========================================
    
    /**
     * Complete auth scenario with multiple users and roles.
     */
    public static class AuthTestScenario {
        public final User adminUser;
        public final User managerUser;
        public final User cashierUser;
        public final User employeeUser;
        
        public final Role adminRole;
        public final Role managerRole;
        public final Role cashierRole;
        public final Role employeeRole;
        
        public final UserSession adminSession;
        public final UserSession managerSession;
        public final UserSession cashierSession;
        
        public AuthTestScenario(
            User adminUser, User managerUser, User cashierUser, User employeeUser,
            Role adminRole, Role managerRole, Role cashierRole, Role employeeRole,
            UserSession adminSession, UserSession managerSession, UserSession cashierSession
        ) {
            this.adminUser = adminUser;
            this.managerUser = managerUser;
            this.cashierUser = cashierUser;
            this.employeeUser = employeeUser;
            this.adminRole = adminRole;
            this.managerRole = managerRole;
            this.cashierRole = cashierRole;
            this.employeeRole = employeeRole;
            this.adminSession = adminSession;
            this.managerSession = managerSession;
            this.cashierSession = cashierSession;
        }
    }
    
    /**
     * Simple auth scenario with one user.
     */
    public static class SimpleAuthScenario {
        public final User user;
        public final Role role;
        public final UserRole userRole;
        public final UserSession session;
        
        public SimpleAuthScenario(User user, Role role, UserRole userRole, UserSession session) {
            this.user = user;
            this.role = role;
            this.userRole = userRole;
            this.session = session;
        }
    }
    
    /**
     * 2FA scenario with OTP token.
     */
    public static class TwoFactorAuthScenario {
        public final User user;
        public final Role role;
        public final OtpToken otpToken;
        
        public TwoFactorAuthScenario(User user, Role role, OtpToken otpToken) {
            this.user = user;
            this.role = role;
            this.otpToken = otpToken;
        }
    }
    
    /**
     * OAuth scenario with Google user.
     */
    public static class OAuthScenario {
        public final User googleUser;
        public final Role role;
        public final UserSession session;
        
        public OAuthScenario(User googleUser, Role role, UserSession session) {
            this.googleUser = googleUser;
            this.role = role;
            this.session = session;
        }
    }
}

