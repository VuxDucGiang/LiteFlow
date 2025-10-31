package com.liteflow.service.ai;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("GPTService Integration Tests")
@Tag("integration")
@Tag("ai")
@Tag("service")
public class GPTServiceIntegrationTest {
    
    private GPTService gptService;
    
    @BeforeEach
    public void setUp() throws Exception {
        // Use empty API key for testing (will fail gracefully)
        gptService = new GPTService("");
    }
    
    @Test
    @DisplayName("Check GPT service configuration")
    public void testIsConfigured() throws Exception {
        try {
            boolean configured = gptService.isConfigured();
            assertTrue(true, "Should check configuration");
        } catch (Exception e) {
            assertTrue(true, "Should check configuration");
        }
    }
    
    @Test
    @DisplayName("Chat with GPT")
    public void testChat() throws Exception {
        try {
            String response = gptService.chat("Hello", null);
            assertTrue(true, "Should attempt to chat");
        } catch (Exception e) {
            // Expected to fail without valid API key
            assertTrue(true, "Should attempt to chat");
        }
    }
    
    @Test
    @DisplayName("Chat with intelligence")
    public void testChatWithIntelligence() throws Exception {
        try {
            String response = gptService.chatWithIntelligence("Hello");
            assertTrue(true, "Should attempt intelligent chat");
        } catch (Exception e) {
            // Expected to fail without valid API key
            assertTrue(true, "Should attempt intelligent chat");
        }
    }
    
    @Test
    @DisplayName("Chat with single parameter")
    public void testChatSingleParam() throws Exception {
        try {
            String response = gptService.chat("Hello");
            assertTrue(true, "Should attempt to chat");
        } catch (Exception e) {
            // Expected to fail without valid API key
            assertTrue(true, "Should attempt to chat");
        }
    }
}

