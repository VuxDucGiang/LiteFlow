package com.liteflow.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PasswordUtilTest {

    @Test
    public void testHashAndCheck() {
        String pw = "Secret123";
        String hash = PasswordUtil.hash(pw, 12);
        assertNotNull(hash);
        assertTrue(PasswordUtil.check(pw, hash));
        assertFalse(PasswordUtil.check("wrong", hash));
    }

    @Test
    public void testPrefixNormalization() {
        String pw = "Another1";
        String hash = PasswordUtil.hash(pw, 12);
        assertTrue(hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$"));
        // Simulate a $2y$ prefix by replacing
        String alt = "$2y$" + hash.substring(4);
        assertTrue(PasswordUtil.check(pw, alt), "Password check should succeed even if hash starts with $2y$");
    }
}
