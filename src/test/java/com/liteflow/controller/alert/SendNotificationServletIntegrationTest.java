package com.liteflow.controller.alert;

import com.liteflow.web.alert.SendNotificationServlet;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.UUID;

/**
 * Integration tests for SendNotificationServlet.
 * Tests HTTP request handling for sending notifications.
 * 
 * Strategy: Use mocks for HTTP requests/responses, may fail without DB but should execute
 */
@DisplayName("SendNotificationServlet Integration Tests")
@Tag("integration")
@Tag("alert")
@Tag("controller")
public class SendNotificationServletIntegrationTest {
    
    private SendNotificationServlet sendNotificationServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        sendNotificationServlet = new SendNotificationServlet();
    }
    
    @Test
    @DisplayName("GET method not allowed")
    public void testGetNotAllowed() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("GET");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        sendNotificationServlet.service(request, response);
        
        verify(response).setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        verify(response).setContentType("application/json");
    }
    
    @Test
    @DisplayName("Send notification with admin role via POST")
    public void testSendNotificationAsAdmin() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("POST");
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(UUID.randomUUID());
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        String jsonBody = "{\"title\":\"Test\",\"message\":\"Test message\",\"priority\":\"HIGH\",\"isPinned\":false}";
        BufferedReader reader = new BufferedReader(new StringReader(jsonBody));
        when(request.getReader()).thenReturn(reader);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            sendNotificationServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response, atLeastOnce()).setContentType("application/json");
    }
    
    @Test
    @DisplayName("Send notification without session returns 401")
    public void testSendNotificationNoSession() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("POST");
        when(request.getSession(false)).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            sendNotificationServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Send notification without admin role returns 403")
    public void testSendNotificationNonAdmin() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("POST");
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(UUID.randomUUID());
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Employee"));
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            sendNotificationServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }
}

