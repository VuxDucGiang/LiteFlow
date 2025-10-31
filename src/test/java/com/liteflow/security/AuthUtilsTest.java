package com.liteflow.security;

import com.liteflow.model.auth.Role;
import com.liteflow.model.auth.User;
import com.liteflow.model.auth.UserRole;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.*;
import java.util.stream.Collectors;

@DisplayName("AuthUtils Tests")
@Tag("unit")
@Tag("security")
public class AuthUtilsTest {
    
    @Test
    @DisplayName("Test hashPassword")
    public void testHashPassword() {
        String raw = "testPassword123";
        
        String hashed = AuthUtils.hashPassword(raw);
        
        assertNotNull(hashed);
        assertTrue(hashed.startsWith("$2a$"));
        assertNotEquals(raw, hashed);
    }
    
    @Test
    @DisplayName("Test hashPassword with null returns null")
    public void testHashPasswordNull() {
        String hashed = AuthUtils.hashPassword(null);
        
        assertNull(hashed);
    }
    
    @Test
    @DisplayName("Test verifyPassword with correct password")
    public void testVerifyPasswordCorrect() {
        String raw = "testPassword123";
        String hashed = AuthUtils.hashPassword(raw);
        
        boolean result = AuthUtils.verifyPassword(raw, hashed);
        
        assertTrue(result);
    }
    
    @Test
    @DisplayName("Test verifyPassword with incorrect password")
    public void testVerifyPasswordIncorrect() {
        String raw = "testPassword123";
        String hashed = AuthUtils.hashPassword(raw);
        String wrongPassword = "wrongPassword";
        
        boolean result = AuthUtils.verifyPassword(wrongPassword, hashed);
        
        assertFalse(result);
    }
    
    @Test
    @DisplayName("Test verifyPassword with null raw")
    public void testVerifyPasswordNullRaw() {
        String hashed = AuthUtils.hashPassword("test");
        
        boolean result = AuthUtils.verifyPassword(null, hashed);
        
        assertFalse(result);
    }
    
    @Test
    @DisplayName("Test verifyPassword with null hashed")
    public void testVerifyPasswordNullHashed() {
        boolean result = AuthUtils.verifyPassword("test", null);
        
        assertFalse(result);
    }
    
    @Test
    @DisplayName("Test normalizeBcryptHash with $2y prefix")
    public void testNormalizeBcryptHash2y() {
        String hash = "$2y$10$abcdefghijklmnopqrstuvwxyz123456";
        
        String normalized = AuthUtils.normalizeBcryptHash(hash);
        
        assertEquals("$2a$10$abcdefghijklmnopqrstuvwxyz123456", normalized);
    }
    
    @Test
    @DisplayName("Test normalizeBcryptHash with $2b prefix")
    public void testNormalizeBcryptHash2b() {
        String hash = "$2b$10$abcdefghijklmnopqrstuvwxyz123456";
        
        String normalized = AuthUtils.normalizeBcryptHash(hash);
        
        assertEquals("$2a$10$abcdefghijklmnopqrstuvwxyz123456", normalized);
    }
    
    @Test
    @DisplayName("Test normalizeBcryptHash with $2a prefix")
    public void testNormalizeBcryptHash2a() {
        String hash = "$2a$10$abcdefghijklmnopqrstuvwxyz123456";
        
        String normalized = AuthUtils.normalizeBcryptHash(hash);
        
        assertEquals(hash, normalized);
    }
    
    @Test
    @DisplayName("Test normalizeBcryptHash with null")
    public void testNormalizeBcryptHashNull() {
        String normalized = AuthUtils.normalizeBcryptHash(null);
        
        assertNull(normalized);
    }
    
    @Test
    @DisplayName("Test generateJwt with user")
    public void testGenerateJwt() {
        User user = new User();
        UUID userId = UUID.randomUUID();
        user.setUserID(userId);
        user.setEmail("test@example.com");
        user.setDisplayName("Test User");
        
        // Create UserRole objects for the user
        Role role1 = new Role();
        role1.setRoleID(UUID.randomUUID());
        role1.setName("ADMIN");
        
        Role role2 = new Role();
        role2.setRoleID(UUID.randomUUID());
        role2.setName("USER");
        
        UserRole userRole1 = new UserRole(userId, role1.getRoleID());
        userRole1.setRole(role1);
        userRole1.setIsActive(true);
        userRole1.setUser(user);
        
        UserRole userRole2 = new UserRole(userId, role2.getRoleID());
        userRole2.setRole(role2);
        userRole2.setIsActive(true);
        userRole2.setUser(user);
        
        Set<UserRole> userRoles = new HashSet<>();
        userRoles.add(userRole1);
        userRoles.add(userRole2);
        user.setUserRoles(userRoles);
        
        String jwt = AuthUtils.generateJwt(user);
        
        assertNotNull(jwt);
        assertFalse(jwt.isEmpty());
        
        // Verify token can be parsed
        JwtUtil.UserContext context = JwtUtil.parseToUserContext(jwt);
        assertEquals(user.getUserID().toString(), context.userId());
        assertTrue(context.roles().contains("ADMIN"));
        assertTrue(context.roles().contains("USER"));
        assertEquals("test@example.com", context.claims().get("email"));
        assertEquals("Test User", context.claims().get("displayName"));
    }
    
    @Test
    @DisplayName("Test generateJwt with null user")
    public void testGenerateJwtNullUser() {
        String jwt = AuthUtils.generateJwt(null);
        
        assertNull(jwt);
    }
    
    @Test
    @DisplayName("Test setJwtCookie")
    public void testSetJwtCookie() {
        HttpServletResponse resp = mock(HttpServletResponse.class);
        String jwt = "test.jwt.token";
        int maxAgeSec = 3600;
        boolean secure = false;
        
        AuthUtils.setJwtCookie(resp, jwt, maxAgeSec, secure);
        
        ArgumentCaptor<Cookie> cookieCaptor = ArgumentCaptor.forClass(Cookie.class);
        verify(resp, times(1)).addCookie(cookieCaptor.capture());
        
        Cookie cookie = cookieCaptor.getValue();
        assertEquals("LITEFLOW_TOKEN", cookie.getName());
        assertEquals(jwt, cookie.getValue());
        assertEquals("/", cookie.getPath());
        assertEquals(maxAgeSec, cookie.getMaxAge());
        assertTrue(cookie.isHttpOnly());
        assertEquals(secure, cookie.getSecure());
        
        // Verify header is also set
        ArgumentCaptor<String> headerNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> headerValueCaptor = ArgumentCaptor.forClass(String.class);
        verify(resp, atLeastOnce()).addHeader(headerNameCaptor.capture(), headerValueCaptor.capture());
        
        assertEquals("Set-Cookie", headerNameCaptor.getValue());
        assertTrue(headerValueCaptor.getValue().contains("LITEFLOW_TOKEN=" + jwt));
        assertTrue(headerValueCaptor.getValue().contains("SameSite=Lax"));
    }
    
    @Test
    @DisplayName("Test setJwtCookie with secure flag")
    public void testSetJwtCookieSecure() {
        HttpServletResponse resp = mock(HttpServletResponse.class);
        String jwt = "test.jwt.token";
        int maxAgeSec = 3600;
        boolean secure = true;
        
        AuthUtils.setJwtCookie(resp, jwt, maxAgeSec, secure);
        
        ArgumentCaptor<Cookie> cookieCaptor = ArgumentCaptor.forClass(Cookie.class);
        verify(resp, times(1)).addCookie(cookieCaptor.capture());
        
        Cookie cookie = cookieCaptor.getValue();
        assertTrue(cookie.getSecure());
    }
    
    @Test
    @DisplayName("Test extractDeviceInfo")
    public void testExtractDeviceInfo() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getHeader("User-Agent")).thenReturn("Mozilla/5.0");
        when(req.getRemoteAddr()).thenReturn("192.168.1.1");
        
        String deviceInfo = AuthUtils.extractDeviceInfo(req);
        
        assertNotNull(deviceInfo);
        assertTrue(deviceInfo.contains("UA="));
        assertTrue(deviceInfo.contains("IP="));
        assertTrue(deviceInfo.contains("Mozilla/5.0"));
        assertTrue(deviceInfo.contains("192.168.1.1"));
    }
    
    @Test
    @DisplayName("Test extractClientIp from X-Forwarded-For")
    public void testExtractClientIpFromXForwardedFor() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getHeader("X-Forwarded-For")).thenReturn("203.0.113.1, 198.51.100.2");
        when(req.getHeader("X-Real-IP")).thenReturn(null);
        
        String ip = AuthUtils.extractClientIp(req);
        
        assertEquals("203.0.113.1", ip);
    }
    
    @Test
    @DisplayName("Test extractClientIp from X-Real-IP")
    public void testExtractClientIpFromXRealIp() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getHeader("X-Forwarded-For")).thenReturn(null);
        when(req.getHeader("X-Real-IP")).thenReturn("198.51.100.2");
        
        String ip = AuthUtils.extractClientIp(req);
        
        assertEquals("198.51.100.2", ip);
    }
    
    @Test
    @DisplayName("Test extractClientIp from RemoteAddr")
    public void testExtractClientIpFromRemoteAddr() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getHeader("X-Forwarded-For")).thenReturn(null);
        when(req.getHeader("X-Real-IP")).thenReturn(null);
        when(req.getRemoteAddr()).thenReturn("192.168.1.100");
        
        String ip = AuthUtils.extractClientIp(req);
        
        assertEquals("192.168.1.100", ip);
    }
    
    @Test
    @DisplayName("Test extractClientIp with blank X-Forwarded-For")
    public void testExtractClientIpWithBlankXForwardedFor() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getHeader("X-Forwarded-For")).thenReturn("   ");
        when(req.getHeader("X-Real-IP")).thenReturn("198.51.100.2");
        
        String ip = AuthUtils.extractClientIp(req);
        
        assertEquals("198.51.100.2", ip);
    }
    
    @Test
    @DisplayName("Test extractClientIp with blank X-Real-IP")
    public void testExtractClientIpWithBlankXRealIp() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getHeader("X-Forwarded-For")).thenReturn(null);
        when(req.getHeader("X-Real-IP")).thenReturn("   ");
        when(req.getRemoteAddr()).thenReturn("192.168.1.100");
        
        String ip = AuthUtils.extractClientIp(req);
        
        assertEquals("192.168.1.100", ip);
    }
    
    @Test
    @DisplayName("Test normalizeEmail")
    public void testNormalizeEmail() {
        String email = "  Test@Example.COM  ";
        
        String normalized = AuthUtils.normalizeEmail(email);
        
        assertEquals("test@example.com", normalized);
    }
    
    @Test
    @DisplayName("Test normalizeEmail with null")
    public void testNormalizeEmailNull() {
        String normalized = AuthUtils.normalizeEmail(null);
        
        assertNull(normalized);
    }
    
    @Test
    @DisplayName("Test normalizeEmail with already normalized")
    public void testNormalizeEmailAlreadyNormalized() {
        String email = "test@example.com";
        
        String normalized = AuthUtils.normalizeEmail(email);
        
        assertEquals("test@example.com", normalized);
    }
}

