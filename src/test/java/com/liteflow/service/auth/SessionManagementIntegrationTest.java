package com.liteflow.service.auth;

import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.helpers.builders.TestDataBuilder;
import com.liteflow.model.auth.User;
import com.liteflow.model.auth.UserSession;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Integration tests for UserSession management.
 * Tests session creation, validation, and logout.
 * 
 * Test Cases Covered (from PR2):
 * - TC-HP-006: Logout and invalidate session
 * - TC-EDGE-003: Session expired
 */
@DisplayName("Session Management Integration Tests")
@Tag("integration")
@Tag("auth")
@Tag("session")
@Tag("service")
public class SessionManagementIntegrationTest extends IntegrationTestBase {
    
    private UserService userService;
    
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        userService = new UserService();
    }
    
    /**
     * TC-HP-006: Logout và invalidate session
     * 
     * Given: User has active session
     * When: Logout is called
     * Then: Session should be revoked
     */
    @Test
    @DisplayName("TC-HP-006: Logout invalidates user session")
    public void testLogoutInvalidatesSession() {
        // Arrange: Create user with active session
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession session = TestDataBuilder.buildSession(user);
        
        em.persist(user);
        em.persist(session);
        em.flush();
        
        // Act: Revoke session (logout)
        boolean revoked = userService.revokeSession(session.getSessionId());
        em.flush();
        
        // Assert: Session should be revoked
        assertTrue(revoked, "Session should be revoked");
        
        UserSession found = em.find(UserSession.class, session.getSessionId());
        assertNotNull(found, "Session should still exist");
        assertTrue(found.isRevoked(), "Session should be marked as revoked");
    }
    
    /**
     * Test creating a new session for user.
     */
    @Test
    @DisplayName("Can create new session for user")
    public void testCreateSession() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Create session
        UserSession session = TestDataBuilder.buildSession(user);
        em.persist(session);
        em.flush();
        
        // Assert: Session created
        assertNotNull(session.getSessionId(), "Session ID should be set");
        assertEquals(user.getUserID(), session.getUserId(), "Session should belong to user");
        assertFalse(session.isRevoked(), "New session should not be revoked");
    }
    
    /**
     * TC-EDGE-003: Session đã hết hạn
     * 
     * Given: User has expired session
     * When: Validate session
     * Then: Should be considered invalid
     */
    @Test
    @DisplayName("TC-EDGE-003: Expired session is invalid")
    public void testExpiredSessionIsInvalid() {
        // Arrange: Create user with expired session
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession expiredSession = TestDataBuilder.buildExpiredSession(user);
        
        em.persist(user);
        em.persist(expiredSession);
        em.flush();
        
        // Act: Check if session is expired
        boolean isExpired = expiredSession.getExpiresAt().isBefore(LocalDateTime.now());
        
        // Assert: Should be expired
        assertTrue(isExpired, "Session should be expired");
    }
    
    /**
     * Test getting active sessions for user.
     */
    @Test
    @DisplayName("Can retrieve active sessions for user")
    public void testGetActiveSessionsForUser() {
        // Arrange: Create user with multiple sessions
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession activeSession1 = TestDataBuilder.buildSession(user);
        UserSession activeSession2 = TestDataBuilder.buildSession(user);
        UserSession revokedSession = TestDataBuilder.buildSession(user);
        revokedSession.setRevoked(true);
        
        em.persist(user);
        em.persist(activeSession1);
        em.persist(activeSession2);
        em.persist(revokedSession);
        em.flush();
        
        // Act: Get active sessions
        List<UserSession> activeSessions = userService.getActiveSessions(user.getUserID());
        
        // Assert: Only active sessions returned
        assertNotNull(activeSessions, "Sessions list should not be null");
        assertTrue(activeSessions.size() >= 2, "Should have at least 2 active sessions");
        assertTrue(activeSessions.stream().noneMatch(UserSession::isRevoked), 
            "No revoked sessions should be in active list");
    }
    
    /**
     * Test revoking all sessions for user.
     */
    @Test
    @DisplayName("Can revoke all sessions for user")
    public void testRevokeAllUserSessions() {
        // Arrange: Create user with multiple sessions
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession session1 = TestDataBuilder.buildSession(user);
        UserSession session2 = TestDataBuilder.buildSession(user);
        UserSession session3 = TestDataBuilder.buildSession(user);
        
        em.persist(user);
        em.persist(session1);
        em.persist(session2);
        em.persist(session3);
        em.flush();
        
        // Act: Revoke all sessions
        int revoked = userService.revokeAllUserSessions(user.getUserID());
        em.flush();
        
        // Assert: All sessions revoked
        assertTrue(revoked >= 3, "At least 3 sessions should be revoked");
        
        List<UserSession> activeSessions = userService.getActiveSessions(user.getUserID());
        assertTrue(activeSessions.isEmpty(), "No active sessions should remain");
    }
    
    /**
     * Test session with 2FA verification.
     */
    @Test
    @DisplayName("Session can track 2FA verification")
    public void testSessionWith2FAVerification() {
        // Arrange: Create user and session with 2FA
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession session = TestDataBuilder.buildSessionWith2FA(user);
        
        em.persist(user);
        em.persist(session);
        em.flush();
        
        // Assert: 2FA timestamp recorded
        assertNotNull(session.getLast2faVerifiedAt(), 
            "2FA verification timestamp should be set");
        assertTrue(session.getLast2faVerifiedAt().isBefore(LocalDateTime.now().plusSeconds(1)), 
            "2FA timestamp should be recent");
    }
    
    /**
     * Test session cleanup removes expired sessions.
     */
    @Test
    @DisplayName("Can cleanup expired sessions")
    public void testCleanupExpiredSessions() {
        // Arrange: Create expired sessions
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession expiredSession1 = TestDataBuilder.buildExpiredSession(user);
        UserSession expiredSession2 = TestDataBuilder.buildExpiredSession(user);
        UserSession activeSession = TestDataBuilder.buildSession(user);
        
        em.persist(user);
        em.persist(expiredSession1);
        em.persist(expiredSession2);
        em.persist(activeSession);
        em.flush();
        
        // Act: Cleanup expired sessions
        int deleted = userService.cleanupExpiredSessions();
        
        // Assert: Expired sessions removed
        assertTrue(deleted >= 2, "At least 2 expired sessions should be cleaned up");
    }
    
    /**
     * Test session JWT token uniqueness.
     */
    @Test
    @DisplayName("Each session has unique JWT token")
    public void testSessionJwtUniqueness() {
        // Arrange: Create user with multiple sessions
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession session1 = TestDataBuilder.buildSession(user);
        UserSession session2 = TestDataBuilder.buildSession(user);
        UserSession session3 = TestDataBuilder.buildSession(user);
        
        em.persist(user);
        em.persist(session1);
        em.persist(session2);
        em.persist(session3);
        em.flush();
        
        // Assert: All JWT tokens are unique
        assertNotEquals(session1.getJwt(), session2.getJwt(), 
            "Session 1 and 2 should have different JWTs");
        assertNotEquals(session2.getJwt(), session3.getJwt(), 
            "Session 2 and 3 should have different JWTs");
        assertNotEquals(session1.getJwt(), session3.getJwt(), 
            "Session 1 and 3 should have different JWTs");
    }
    
    /**
     * Test cannot revoke non-existent session.
     */
    @Test
    @DisplayName("Cannot revoke non-existent session")
    public void testRevokeNonExistentSession() {
        // Act: Try to revoke random session ID
        UUID randomSessionId = UUID.randomUUID();
        boolean revoked = userService.revokeSession(randomSessionId);
        
        // Assert: Should fail
        assertFalse(revoked, "Cannot revoke non-existent session");
    }
    
    /**
     * Test session extends on activity.
     */
    @Test
    @DisplayName("Session can be extended on activity")
    public void testSessionExtension() {
        // Arrange: Create user with session
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        UserSession session = TestDataBuilder.buildSession(user);
        LocalDateTime originalExpiry = session.getExpiresAt();
        
        em.persist(user);
        em.persist(session);
        em.flush();
        
        // Act: Extend session
        session.setExpiresAt(LocalDateTime.now().plusHours(8));
        em.merge(session);
        em.flush();
        
        // Assert: Expiry time updated
        UserSession found = em.find(UserSession.class, session.getSessionId());
        assertNotNull(found);
        assertTrue(found.getExpiresAt().isAfter(originalExpiry), 
            "Session expiry should be extended");
    }
}

