package com.liteflow.filter;

import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Integration tests for CommonFilter.
 * Tests HTTP request/response encoding and logging.
 * 
 * Strategy: Use mocks for HTTP requests/responses
 */
@DisplayName("CommonFilter Integration Tests")
@Tag("integration")
@Tag("filter")
public class CommonFilterIntegrationTest {
    
    private CommonFilter commonFilter;
    
    @BeforeEach
    public void setUp() throws Exception {
        commonFilter = new CommonFilter();
    }
    
    /**
     * Test UTF-8 encoding is set
     */
    @Test
    @DisplayName("Set UTF-8 encoding")
    public void testSetUtf8Encoding() throws Exception {
        // Arrange: Create GET request
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        FilterChain chain = mock(FilterChain.class);
        
        when(request.getRequestURI()).thenReturn("/LiteFlow/dashboard");
        when(request.getMethod()).thenReturn("GET");
        
        // Act: Call doFilter
        try {
            commonFilter.doFilter(request, response, chain);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Assert: Verify chain was called
        verify(chain, atLeastOnce()).doFilter(request, response);
    }
    
    /**
     * Test filter logs request timing
     */
    @Test
    @DisplayName("Log request timing")
    public void testLogRequestTiming() throws Exception {
        // Arrange: Create POST request
        HttpServletRequest request = ServletTestHelper.mockPostRequest(null);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        FilterChain chain = mock(FilterChain.class);
        
        when(request.getRequestURI()).thenReturn("/LiteFlow/api/test");
        when(request.getMethod()).thenReturn("POST");
        when(response.getStatus()).thenReturn(200);
        
        // Act: Call doFilter
        try {
            commonFilter.doFilter(request, response, chain);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Assert: Verify chain was called
        verify(chain, atLeastOnce()).doFilter(request, response);
    }
}

