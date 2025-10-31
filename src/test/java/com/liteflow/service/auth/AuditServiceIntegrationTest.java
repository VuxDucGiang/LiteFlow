package com.liteflow.service.auth;

import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.helpers.builders.TestDataBuilder;
import com.liteflow.model.auth.User;
import com.liteflow.model.auth.AuditLog;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;

import java.util.List;

/**
 * Integration tests for AuditService.
 * Tests security audit logging for authentication events.
 * 
 * Audit logging is critical for security compliance and forensics.
 */
@DisplayName("AuditService Integration Tests")
@Tag("integration")
@Tag("auth")
@Tag("audit")
@Tag("security")
@Tag("service")
public class AuditServiceIntegrationTest extends IntegrationTestBase {
    
    private AuditService auditService;
    
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        auditService = new AuditService();
    }
    
    /**
     * Test logging successful login.
     */
    @Test
    @DisplayName("Audit logs successful login")
    public void testAuditLoginSuccess() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log successful login
        auditService.logLoginSuccess(user, "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertFalse(logs.isEmpty(), "Audit log should be created");
        assertTrue(
            logs.stream().anyMatch(log -> 
                "LOGIN_SUCCESS".equals(log.getAction())
            ),
            "Should have LOGIN_SUCCESS audit entry"
        );
    }
    
    /**
     * Test logging failed login attempt.
     */
    @Test
    @DisplayName("Audit logs failed login attempt")
    public void testAuditLoginFailure() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log failed login
        auditService.logLoginFailed(user, "Wrong password", "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                "LOGIN_FAIL".equals(log.getAction())
            ),
            "Should have LOGIN_FAIL audit entry"
        );
    }
    
    /**
     * Test logging logout.
     */
    @Test
    @DisplayName("Audit logs user logout")
    public void testAuditLogout() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log logout
        auditService.logLogout(user, "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                "LOGOUT".equals(log.getAction())
            ),
            "Should have LOGOUT audit entry"
        );
    }
    
    /**
     * Test logging OTP issuance.
     */
    @Test
    @DisplayName("Audit logs OTP issuance")
    public void testAuditOtpIssued() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log OTP issued
        auditService.logOtpIssued(user, "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                "OTP_ISSUED".equals(log.getAction())
            ),
            "Should have OTP_ISSUED audit entry"
        );
    }
    
    /**
     * Test logging OTP usage.
     */
    @Test
    @DisplayName("Audit logs OTP verification")
    public void testAuditOtpUsed() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log OTP used
        auditService.logOtpUsed(user, "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                "OTP_USED".equals(log.getAction())
            ),
            "Should have OTP_USED audit entry"
        );
    }
    
    /**
     * Test logging password change.
     */
    @Test
    @DisplayName("Audit logs password change")
    public void testAuditPasswordChange() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log password change
        auditService.logPasswordChanged(user, "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                "PASSWORD_CHANGED".equals(log.getAction())
            ),
            "Should have PASSWORD_CHANGED audit entry"
        );
    }
    
    /**
     * Test logging unauthorized access attempt.
     */
    @Test
    @DisplayName("Audit logs unauthorized access attempts")
    public void testAuditAccessDenied() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log access denied
        auditService.logAccessDenied(user, "/admin/dashboard", "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                "ACCESS_DENIED".equals(log.getAction())
            ),
            "Should have ACCESS_DENIED audit entry"
        );
    }
    
    /**
     * Test logging account lock.
     */
    @Test
    @DisplayName("Audit logs account lock")
    public void testAuditAccountLock() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Log account lock
        auditService.logAccountLocked(user, "Too many failed attempts", "127.0.0.1");
        em.flush();
        
        // Assert: Audit log created
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                "LOCK_ACCOUNT".equals(log.getAction())
            ),
            "Should have LOCK_ACCOUNT audit entry"
        );
    }
    
    /**
     * Test audit log contains IP address.
     */
    @Test
    @DisplayName("Audit logs capture IP address")
    public void testAuditLogsContainIpAddress() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        String ipAddress = "192.168.1.100";
        
        // Act: Log with specific IP
        auditService.logLoginSuccess(user, ipAddress);
        em.flush();
        
        // Assert: IP address captured
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertTrue(
            logs.stream().anyMatch(log -> 
                ipAddress.equals(log.getIpAddress())
            ),
            "Audit log should contain IP address"
        );
    }
    
    /**
     * Test audit log contains timestamp.
     */
    @Test
    @DisplayName("Audit logs have accurate timestamps")
    public void testAuditLogsHaveTimestamps() {
        // Arrange: Create user
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Act: Create audit log
        auditService.logLoginSuccess(user, "127.0.0.1");
        em.flush();
        
        // Assert: Timestamp present
        List<AuditLog> logs = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        assertFalse(logs.isEmpty(), "Audit logs should exist");
        logs.forEach(log -> {
            assertNotNull(log.getCreatedAt(), "Audit log should have timestamp");
        });
    }
    
    /**
     * Test retrieving audit history for user.
     */
    @Test
    @DisplayName("Can retrieve complete audit history for user")
    public void testRetrieveUserAuditHistory() {
        // Arrange: Create user and multiple audit events
        User user = TestDataBuilder.buildUser("user@liteflow.com", "USER");
        em.persist(user);
        em.flush();
        
        // Log multiple events
        auditService.logLoginSuccess(user, "127.0.0.1");
        auditService.logOtpIssued(user, "127.0.0.1");
        auditService.logOtpUsed(user, "127.0.0.1");
        auditService.logLogout(user, "127.0.0.1");
        em.flush();
        
        // Act: Retrieve audit history
        List<AuditLog> auditHistory = em.createQuery(
            "SELECT a FROM AuditLog a WHERE a.userId = :userId ORDER BY a.createdAt DESC", 
            AuditLog.class
        )
        .setParameter("userId", user.getUserID())
        .getResultList();
        
        // Assert: All events logged
        assertNotNull(auditHistory, "Audit history should not be null");
        assertTrue(auditHistory.size() >= 4, "Should have at least 4 audit entries");
    }
}

