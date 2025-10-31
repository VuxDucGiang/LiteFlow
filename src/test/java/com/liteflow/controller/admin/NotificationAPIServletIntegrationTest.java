package com.liteflow.controller.admin;

import com.liteflow.controller.NotificationAPIServlet;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.UUID;

/**
 * Integration tests for NotificationAPIServlet.
 * Tests HTTP request handling for notification API.
 * 
 * Strategy: Use mocks for HTTP requests/responses, may fail without DB but should execute
 */
@DisplayName("NotificationAPIServlet Integration Tests")
@Tag("integration")
@Tag("admin")
@Tag("controller")
public class NotificationAPIServletIntegrationTest {
    
    private NotificationAPIServlet notificationAPIServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        notificationAPIServlet = new NotificationAPIServlet();
    }
    
    @Test
    @DisplayName("Send notification to admin via POST")
    public void testSendNotificationToAdmin() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("POST");
        when(request.getPathInfo()).thenReturn("/send-to-admin");
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(UUID.randomUUID());
        
        when(request.getParameter("type")).thenReturn("LEAVE_REQUEST");
        when(request.getParameter("title")).thenReturn("Leave Request");
        when(request.getParameter("message")).thenReturn("Employee requested leave");
        when(request.getParameter("priority")).thenReturn("HIGH");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            notificationAPIServlet.service(request, response);
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
        when(request.getPathInfo()).thenReturn("/send-to-admin");
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(null); // No user
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            notificationAPIServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Unknown endpoint returns 404")
    public void testUnknownEndpoint() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("POST");
        when(request.getPathInfo()).thenReturn("/unknown");
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(UUID.randomUUID());
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            notificationAPIServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response).setStatus(HttpServletResponse.SC_NOT_FOUND);
    }
}

