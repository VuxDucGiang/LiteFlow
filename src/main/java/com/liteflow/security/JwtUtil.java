package com.liteflow.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;

import java.security.Key;
import java.time.Instant;
import java.util.*;

/**
 * JwtUtil: - Subject = userId (UUID string) - Claim "roles" luôn là
 * List<String>
 * - Có jti, iat, exp
 */
public final class JwtUtil {

    private static final String DEFAULT_SECRET
            = "5DfF9vP1hZbH9Y87Uqx8UJZz2mJbn7c0U8U9jV9p3wJZoE4u4eItD0FQkg4T6x2k";
    private static final long DEFAULT_TTL_SECONDS = 15 * 60;

    private static final Key KEY;

    static {
        String s = System.getenv("LITEFLOW_JWT_SECRET");
        if (s == null || s.length() < 32) {
            s = System.getProperty("LITEFLOW_JWT_SECRET", DEFAULT_SECRET);
        }
        KEY = Keys.hmacShaKeyFor(s.getBytes());
    }

    private JwtUtil() {
    }

    public static String generateToken(String subject,
            List<String> roles,
            long ttlSeconds,
            Map<String, Object> claims) {
        Instant now = Instant.now();
        JwtBuilder b = Jwts.builder()
                .setSubject(subject)
                .setId(UUID.randomUUID().toString())
                .setIssuedAt(Date.from(now))
                .signWith(KEY, SignatureAlgorithm.HS256);

        if (claims != null && !claims.isEmpty()) {
            b.addClaims(claims);
        }
        b.claim("roles", roles != null ? roles : List.of());

        long ttl = ttlSeconds > 0 ? ttlSeconds : DEFAULT_TTL_SECONDS;
        b.setExpiration(Date.from(now.plusSeconds(ttl)));

        return b.compact();
    }

    public static Jws<Claims> parse(String jwt) throws JwtException {
        return Jwts.parserBuilder()
                .setSigningKey(KEY)
                .build()
                .parseClaimsJws(jwt);
    }

    public static UserContext parseToUserContext(String jwt) throws JwtException {
        Jws<Claims> jws = parse(jwt);
        Claims c = jws.getBody();

        String userId = c.getSubject();
        List<String> roles = new ArrayList<>();
        Object raw = c.get("roles");
        if (raw instanceof List<?> lst) {
            for (Object o : lst) {
                if (o instanceof String s) {
                    roles.add(s);
                }
            }
        } else if (raw instanceof String s) {
            roles = List.of(s);
        }
        return new UserContext(userId, roles, c);
    }

    public static String stripBearer(String header) {
        if (header == null) {
            return null;
        }
        if (header.startsWith("Bearer ")) {
            return header.substring(7).trim();
        }
        return header.trim();
    }

    public record UserContext(String userId, List<String> roles, Claims claims) {

    }

    public static String issue(String subject,
            Map<String, Object> claims,
            List<String> roles,
            long ttlSeconds) {
        Instant now = Instant.now();
        if (ttlSeconds <= 0) {
            ttlSeconds = 900; // ✅ mặc định 15 phút
        }

        JwtBuilder builder = Jwts.builder()
                .setSubject(subject)
                .setId(UUID.randomUUID().toString()) // ✅ jti để revoke
                .setIssuedAt(Date.from(now))
                .signWith(KEY, SignatureAlgorithm.HS256);

        if (claims != null) {
            builder.addClaims(claims);
        }
        builder.claim("roles", roles != null ? roles : List.of());

        builder.setExpiration(Date.from(now.plusSeconds(ttlSeconds)));

        return builder.compact();
    }

}
