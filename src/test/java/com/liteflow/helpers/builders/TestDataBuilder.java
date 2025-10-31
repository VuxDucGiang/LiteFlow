package com.liteflow.helpers.builders;

import com.liteflow.model.auth.User;
import com.liteflow.model.auth.Role;
import com.liteflow.model.auth.UserRole;
import com.liteflow.model.auth.UserSession;
import com.liteflow.model.auth.OtpToken;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.UUID;

/**
 * TestDataBuilder provides builder methods for creating test data objects.
 * All builders return fully initialized entities ready to be persisted.
 * 
 * Usage:
 * <pre>
 * User user = TestDataBuilder.buildUser("test@liteflow.com", "ADMIN");
 * em.persist(user);
 * </pre>
 */
public class TestDataBuilder {
    
    // ==========================================
    // AUTH MODULE
    // ==========================================
    
    /**
     * Build a User with specified email and role name.
     * Password hash is set to a bcrypt hash of "Test@123".
     * 
     * @param email User email
     * @param roleName Role name (for display purposes)
     * @return Fully initialized User entity
     */
    public static User buildUser(String email, String roleName) {
        User user = new User();
        user.setUserID(UUID.randomUUID());
        user.setEmail(email);
        user.setPasswordHash("$2a$10$N.gXqZ8Z5fZQJ5fXqZ8Z5.xvZxZ5fZQJ5fXqZ8Z5fZQJ5fXqZ8Z5"); // Test@123
        user.setDisplayName("Test " + roleName);
        user.setIsActive(true);
        return user;
    }
    
    /**
     * Build a User with custom password hash.
     */
    public static User buildUserWithPassword(String email, String passwordHash) {
        User user = buildUser(email, "USER");
        user.setPasswordHash(passwordHash);
        return user;
    }
    
    /**
     * Build a User with Google OAuth ID.
     */
    public static User buildGoogleUser(String email, String googleId) {
        User user = buildUser(email, "USER");
        user.setGoogleID(googleId);
        return user;
    }
    
    /**
     * Build a User with 2FA enabled.
     */
    public static User buildUserWith2FA(String email, String twoFactorSecret) {
        User user = buildUser(email, "USER");
        user.setTwoFactorSecret(twoFactorSecret);
        return user;
    }
    
    /**
     * Build an inactive User.
     */
    public static User buildInactiveUser(String email) {
        User user = buildUser(email, "USER");
        user.setIsActive(false);
        return user;
    }
    
    /**
     * Build a Role with specified name.
     * 
     * @param name Role name (e.g., "ADMIN", "CASHIER", "MANAGER")
     * @return Fully initialized Role entity
     */
    public static Role buildRole(String name) {
        Role role = new Role();
        role.setRoleID(UUID.randomUUID());
        role.setName(name);
        role.setDescription("Test role " + name);
        return role;
    }
    
    /**
     * Build a UserRole linking a User and Role.
     * 
     * @param user User entity
     * @param role Role entity
     * @return Fully initialized UserRole entity
     */
    public static UserRole buildUserRole(User user, Role role) {
        UserRole userRole = new UserRole();
        userRole.setUserId(user.getUserID());
        userRole.setRoleId(role.getRoleID());
        userRole.setUser(user);
        userRole.setRole(role);
        userRole.setIsActive(true);
        userRole.setAssignedAt(LocalDateTime.now());
        return userRole;
    }
    
    /**
     * Build a UserSession for a User.
     * 
     * @param user User entity
     * @return Fully initialized UserSession entity
     */
    public static UserSession buildSession(User user) {
        UserSession session = new UserSession();
        session.setSessionId(UUID.randomUUID());
        session.setUserId(user.getUserID());
        session.setUser(user);
        session.setJwt("test_jwt_token_" + UUID.randomUUID());
        session.setDeviceInfo("Test Device");
        session.setIpAddress("127.0.0.1");
        session.setCreatedAt(LocalDateTime.now());
        session.setExpiresAt(LocalDateTime.now().plusHours(8));
        session.setRevoked(false);
        return session;
    }
    
    /**
     * Build an expired UserSession.
     */
    public static UserSession buildExpiredSession(User user) {
        UserSession session = buildSession(user);
        session.setCreatedAt(LocalDateTime.now().minusHours(9));
        session.setExpiresAt(LocalDateTime.now().minusHours(1));
        return session;
    }
    
    /**
     * Build a UserSession with 2FA verified.
     */
    public static UserSession buildSessionWith2FA(User user) {
        UserSession session = buildSession(user);
        session.setLast2faVerifiedAt(LocalDateTime.now());
        return session;
    }
    
    /**
     * Build an OtpToken for a User.
     * 
     * @param user User entity
     * @param code OTP code (6 digits)
     * @return Fully initialized OtpToken entity
     */
    public static OtpToken buildOtpToken(User user, String code) {
        OtpToken otp = new OtpToken();
        otp.setUser(user);
        otp.setCode(code);
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        otp.setUsed(false);
        otp.setIpAddress("127.0.0.1");
        return otp;
    }
    
    /**
     * Build an OtpToken for email (signup before user exists).
     */
    public static OtpToken buildOtpTokenForEmail(String email, String code) {
        OtpToken otp = new OtpToken();
        otp.setTargetEmail(email);
        otp.setCode(code);
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        otp.setUsed(false);
        otp.setIpAddress("127.0.0.1");
        return otp;
    }
    
    /**
     * Build an expired OtpToken.
     */
    public static OtpToken buildExpiredOtpToken(User user, String code) {
        OtpToken otp = buildOtpToken(user, code);
        otp.setExpiresAt(LocalDateTime.now().minusMinutes(1));
        return otp;
    }
    
    /**
     * Build a used OtpToken.
     */
    public static OtpToken buildUsedOtpToken(User user, String code) {
        OtpToken otp = buildOtpToken(user, code);
        otp.setUsed(true);
        return otp;
    }
    
    // ==========================================
    // HELPER METHODS
    // ==========================================
    
    /**
     * Create a complete User with Role setup.
     * This is a convenience method that creates User, Role, and UserRole.
     * 
     * @param email User email
     * @param roleName Role name
     * @return Array of [User, Role, UserRole]
     */
    public static Object[] buildUserWithRole(String email, String roleName) {
        User user = buildUser(email, roleName);
        Role role = buildRole(roleName);
        UserRole userRole = buildUserRole(user, role);
        
        // Link UserRole to User
        user.getUserRoles().add(userRole);
        
        return new Object[]{user, role, userRole};
    }
    
    /**
     * Generate a random UUID string.
     */
    public static String randomUUID() {
        return UUID.randomUUID().toString();
    }
    
    /**
     * Generate a random 6-digit OTP code.
     */
    public static String randomOtpCode() {
        return String.format("%06d", (int)(Math.random() * 1000000));
    }
}

