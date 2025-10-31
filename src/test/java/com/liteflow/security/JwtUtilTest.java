package com.liteflow.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.util.*;

@DisplayName("JwtUtil Tests")
@Tag("unit")
@Tag("security")
public class JwtUtilTest {
    
    @Test
    @DisplayName("Test generateToken with all parameters")
    public void testGenerateTokenWithAllParameters() {
        String subject = UUID.randomUUID().toString();
        List<String> roles = Arrays.asList("ADMIN", "USER");
        long ttlSeconds = 3600;
        Map<String, Object> claims = new HashMap<>();
        claims.put("email", "test@example.com");
        claims.put("name", "Test User");
        
        String token = JwtUtil.generateToken(subject, roles, ttlSeconds, claims);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test generateToken with null roles")
    public void testGenerateTokenWithNullRoles() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.generateToken(subject, null, 3600, null);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test generateToken with empty roles")
    public void testGenerateTokenWithEmptyRoles() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.generateToken(subject, Collections.emptyList(), 3600, null);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test generateToken with null claims")
    public void testGenerateTokenWithNullClaims() {
        String subject = UUID.randomUUID().toString();
        List<String> roles = Arrays.asList("USER");
        
        String token = JwtUtil.generateToken(subject, roles, 3600, null);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test generateToken with empty claims")
    public void testGenerateTokenWithEmptyClaims() {
        String subject = UUID.randomUUID().toString();
        List<String> roles = Arrays.asList("USER");
        
        String token = JwtUtil.generateToken(subject, roles, 3600, Collections.emptyMap());
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test generateToken with zero TTL uses default")
    public void testGenerateTokenWithZeroTTL() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.generateToken(subject, null, 0, null);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
        
        // Parse and verify expiration
        Jws<Claims> jws = JwtUtil.parse(token);
        assertNotNull(jws.getBody().getExpiration());
    }
    
    @Test
    @DisplayName("Test generateToken with negative TTL uses default")
    public void testGenerateTokenWithNegativeTTL() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.generateToken(subject, null, -100, null);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test parse valid token")
    public void testParseValidToken() {
        String subject = UUID.randomUUID().toString();
        List<String> roles = Arrays.asList("ADMIN");
        
        String token = JwtUtil.generateToken(subject, roles, 3600, null);
        
        Jws<Claims> jws = JwtUtil.parse(token);
        
        assertNotNull(jws);
        assertEquals(subject, jws.getBody().getSubject());
        assertNotNull(jws.getBody().getId());
        assertNotNull(jws.getBody().getIssuedAt());
        assertNotNull(jws.getBody().getExpiration());
    }
    
    @Test
    @DisplayName("Test parse invalid token throws exception")
    public void testParseInvalidToken() {
        assertThrows(JwtException.class, () -> {
            JwtUtil.parse("invalid.token.here");
        });
    }
    
    @Test
    @DisplayName("Test parseToUserContext with List roles")
    public void testParseToUserContextWithListRoles() {
        String subject = UUID.randomUUID().toString();
        List<String> roles = Arrays.asList("ADMIN", "USER");
        
        String token = JwtUtil.generateToken(subject, roles, 3600, null);
        
        JwtUtil.UserContext context = JwtUtil.parseToUserContext(token);
        
        assertNotNull(context);
        assertEquals(subject, context.userId());
        assertEquals(2, context.roles().size());
        assertTrue(context.roles().contains("ADMIN"));
        assertTrue(context.roles().contains("USER"));
        assertNotNull(context.claims());
    }
    
    @Test
    @DisplayName("Test parseToUserContext with String role")
    public void testParseToUserContextWithStringRole() throws Exception {
        String subject = UUID.randomUUID().toString();
        String token = JwtUtil.generateToken(subject, null, 3600, null);
        
        // Test parseToUserContext - it should work with null roles (empty list)
        JwtUtil.UserContext context = JwtUtil.parseToUserContext(token);
        
        assertNotNull(context);
        assertEquals(subject, context.userId());
        assertTrue(context.roles().isEmpty());
    }
    
    @Test
    @DisplayName("Test parseToUserContext with empty roles")
    public void testParseToUserContextWithEmptyRoles() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.generateToken(subject, Collections.emptyList(), 3600, null);
        
        JwtUtil.UserContext context = JwtUtil.parseToUserContext(token);
        
        assertNotNull(context);
        assertEquals(subject, context.userId());
        assertTrue(context.roles().isEmpty());
    }
    
    @Test
    @DisplayName("Test stripBearer with Bearer prefix")
    public void testStripBearerWithPrefix() {
        String header = "Bearer abc123token";
        
        String result = JwtUtil.stripBearer(header);
        
        assertEquals("abc123token", result);
    }
    
    @Test
    @DisplayName("Test stripBearer with Bearer prefix and spaces")
    public void testStripBearerWithPrefixAndSpaces() {
        String header = "Bearer   abc123token  ";
        
        String result = JwtUtil.stripBearer(header);
        
        assertEquals("abc123token", result);
    }
    
    @Test
    @DisplayName("Test stripBearer without Bearer prefix")
    public void testStripBearerWithoutPrefix() {
        String header = "abc123token";
        
        String result = JwtUtil.stripBearer(header);
        
        assertEquals("abc123token", result);
    }
    
    @Test
    @DisplayName("Test stripBearer with null")
    public void testStripBearerWithNull() {
        String result = JwtUtil.stripBearer(null);
        
        assertNull(result);
    }
    
    @Test
    @DisplayName("Test stripBearer trims whitespace")
    public void testStripBearerTrimsWhitespace() {
        String header = "   abc123token   ";
        
        String result = JwtUtil.stripBearer(header);
        
        assertEquals("abc123token", result);
    }
    
    @Test
    @DisplayName("Test UserContext constructor and getters")
    public void testUserContext() {
        String userId = UUID.randomUUID().toString();
        List<String> roles = Arrays.asList("USER");
        Claims claims = JwtUtil.parse(JwtUtil.generateToken(userId, roles, 3600, null)).getBody();
        
        JwtUtil.UserContext context = new JwtUtil.UserContext(userId, roles, claims);
        
        assertEquals(userId, context.userId());
        assertEquals(roles, context.roles());
        assertEquals(claims, context.claims());
    }
    
    @Test
    @DisplayName("Test issue method")
    public void testIssue() {
        String subject = UUID.randomUUID().toString();
        Map<String, Object> claims = Map.of("email", "test@example.com");
        List<String> roles = Arrays.asList("ADMIN");
        long ttlSeconds = 1800;
        
        String token = JwtUtil.issue(subject, claims, roles, ttlSeconds);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
        
        Jws<Claims> jws = JwtUtil.parse(token);
        assertEquals(subject, jws.getBody().getSubject());
        assertEquals("test@example.com", jws.getBody().get("email"));
    }
    
    @Test
    @DisplayName("Test issue with null claims")
    public void testIssueWithNullClaims() {
        String subject = UUID.randomUUID().toString();
        List<String> roles = Arrays.asList("USER");
        
        String token = JwtUtil.issue(subject, null, roles, 3600);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test issue with null roles")
    public void testIssueWithNullRoles() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.issue(subject, null, null, 3600);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
    
    @Test
    @DisplayName("Test issue with zero TTL uses default")
    public void testIssueWithZeroTTL() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.issue(subject, null, null, 0);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
        
        Jws<Claims> jws = JwtUtil.parse(token);
        assertNotNull(jws.getBody().getExpiration());
    }
    
    @Test
    @DisplayName("Test issue with negative TTL uses default")
    public void testIssueWithNegativeTTL() {
        String subject = UUID.randomUUID().toString();
        
        String token = JwtUtil.issue(subject, null, null, -100);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }
}

