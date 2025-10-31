package com.liteflow.helpers.mocks;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mockito.Mockito;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;

import static org.mockito.Mockito.*;

/**
 * ServletTestHelper provides utilities for mocking HTTP Servlet objects.
 * Simplifies creation of mock HttpServletRequest and HttpServletResponse.
 * 
 * Usage:
 * <pre>
 * HttpServletRequest req = ServletTestHelper.mockPostRequest("{\"email\":\"test@test.com\"}");
 * HttpServletResponse resp = ServletTestHelper.mockResponse();
 * 
 * servlet.doPost(req, resp);
 * 
 * String responseBody = ServletTestHelper.getResponseBody(resp);
 * </pre>
 */
public class ServletTestHelper {
    
    // ==========================================
    // REQUEST MOCKING
    // ==========================================
    
    /**
     * Mock a POST request with JSON body.
     * 
     * @param jsonBody JSON request body
     * @return Mock HttpServletRequest
     */
    public static HttpServletRequest mockPostRequest(String jsonBody) {
        return mockRequest("POST", jsonBody);
    }
    
    /**
     * Mock a GET request.
     * 
     * @return Mock HttpServletRequest
     */
    public static HttpServletRequest mockGetRequest() {
        return mockRequest("GET", null);
    }
    
    /**
     * Mock a generic HTTP request.
     * 
     * @param method HTTP method (GET, POST, PUT, DELETE, etc.)
     * @param body Request body (can be null for GET)
     * @return Mock HttpServletRequest
     */
    public static HttpServletRequest mockRequest(String method, String body) {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getMethod()).thenReturn(method);
        when(req.getContentType()).thenReturn("application/json");
        
        if (body != null) {
            try {
                BufferedReader reader = new BufferedReader(new StringReader(body));
                when(req.getReader()).thenReturn(reader);
            } catch (Exception e) {
                throw new RuntimeException("Failed to mock request body", e);
            }
        }
        
        // Mock session
        HttpSession session = mockSession();
        when(req.getSession()).thenReturn(session);
        when(req.getSession(anyBoolean())).thenReturn(session);
        
        // Mock context path
        when(req.getContextPath()).thenReturn("/LiteFlow");
        
        // Mock IP address
        when(req.getRemoteAddr()).thenReturn("127.0.0.1");
        
        return req;
    }
    
    /**
     * Mock HttpServletRequest with authentication (user session).
     * 
     * @param userId User ID to set in session
     * @param email User email
     * @param role User role
     * @return Mock HttpServletRequest with session attributes
     */
    public static HttpServletRequest mockAuthenticatedRequest(String userId, String email, String role) {
        HttpServletRequest req = mockGetRequest();
        HttpSession session = req.getSession();
        
        // Set session attributes (adjust based on your actual session structure)
        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("userEmail")).thenReturn(email);
        when(session.getAttribute("userRole")).thenReturn(role);
        
        return req;
    }
    
    // ==========================================
    // RESPONSE MOCKING
    // ==========================================
    
    // Map to store StringWriters for responses (workaround for mock limitation)
    private static final java.util.Map<HttpServletResponse, StringWriter> responseWriters = 
        new java.util.HashMap<>();
    
    /**
     * Mock HttpServletResponse with StringWriter for capturing output.
     * 
     * @return Mock HttpServletResponse
     */
    public static HttpServletResponse mockResponse() {
        HttpServletResponse resp = mock(HttpServletResponse.class);
        
        try {
            StringWriter stringWriter = new StringWriter();
            PrintWriter writer = new PrintWriter(stringWriter);
            when(resp.getWriter()).thenReturn(writer);
            
            // Store the StringWriter in our map
            responseWriters.put(resp, stringWriter);
        } catch (Exception e) {
            throw new RuntimeException("Failed to mock response writer", e);
        }
        
        return resp;
    }
    
    /**
     * Get the response body as String.
     * Must be called AFTER servlet execution.
     * 
     * @param resp Mock HttpServletResponse
     * @return Response body as String
     */
    public static String getResponseBody(HttpServletResponse resp) {
        try {
            PrintWriter writer = resp.getWriter();
            writer.flush();
            
            // Retrieve the StringWriter from our map
            StringWriter stringWriter = responseWriters.get(resp);
            if (stringWriter != null) {
                return stringWriter.toString();
            }
            return "";
        } catch (Exception e) {
            throw new RuntimeException("Failed to get response body", e);
        }
    }
    
    // ==========================================
    // SESSION MOCKING
    // ==========================================
    
    /**
     * Mock HttpSession.
     * 
     * @return Mock HttpSession
     */
    public static HttpSession mockSession() {
        HttpSession session = mock(HttpSession.class);
        when(session.getId()).thenReturn("test_session_" + System.currentTimeMillis());
        
        // Mock session attribute storage using a simple map-like behavior
        // This allows setAttribute/getAttribute to work properly
        java.util.Map<String, Object> sessionAttributes = new java.util.HashMap<>();
        
        doAnswer(invocation -> {
            String key = invocation.getArgument(0);
            Object value = invocation.getArgument(1);
            sessionAttributes.put(key, value);
            return null;
        }).when(session).setAttribute(anyString(), any());
        
        when(session.getAttribute(anyString())).thenAnswer(invocation -> {
            String key = invocation.getArgument(0);
            return sessionAttributes.get(key);
        });
        
        return session;
    }
    
    // ==========================================
    // HELPER METHODS
    // ==========================================
    
    /**
     * Create a simple JSON string for testing.
     * 
     * @param keyValues Alternating key-value pairs (e.g., "key1", "value1", "key2", "value2")
     * @return JSON string
     */
    public static String json(String... keyValues) {
        if (keyValues.length % 2 != 0) {
            throw new IllegalArgumentException("keyValues must be in pairs");
        }
        
        StringBuilder sb = new StringBuilder("{");
        for (int i = 0; i < keyValues.length; i += 2) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(keyValues[i]).append("\":\"").append(keyValues[i + 1]).append("\"");
        }
        sb.append("}");
        return sb.toString();
    }
}

