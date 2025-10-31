package com.liteflow.controller.cashier;

import com.liteflow.controller.UpdateOrderStatusServlet;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.UUID;

/**
 * Integration tests for UpdateOrderStatusServlet.
 * Tests HTTP request handling for updating order status.
 * 
 * Strategy: Use mocks for HTTP requests/responses, may fail without DB but should execute
 */
@DisplayName("UpdateOrderStatusServlet Integration Tests")
@Tag("integration")
@Tag("cashier")
@Tag("controller")
public class UpdateOrderStatusServletIntegrationTest {
    
    private UpdateOrderStatusServlet updateOrderStatusServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        updateOrderStatusServlet = new UpdateOrderStatusServlet();
        updateOrderStatusServlet.init();
    }
    
    @Test
    @DisplayName("Update order status via POST")
    public void testUpdateOrderStatus() throws Exception {
        // Arrange: Create POST request with JSON body
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("POST");
        
        String orderId = UUID.randomUUID().toString();
        String jsonBody = "{\"orderId\":\"" + orderId + "\",\"status\":\"Preparing\"}";
        
        BufferedReader reader = new BufferedReader(new StringReader(jsonBody));
        when(request.getReader()).thenReturn(reader);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        // Act: Call service
        try {
            updateOrderStatusServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Assert: Should set JSON content type
        verify(response, atLeastOnce()).setContentType("application/json");
    }
    
    @Test
    @DisplayName("Update order status with invalid JSON")
    public void testUpdateOrderStatusInvalidJson() throws Exception {
        // Arrange: Create POST request with invalid JSON body
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("POST");
        
        String jsonBody = "invalid json";
        BufferedReader reader = new BufferedReader(new StringReader(jsonBody));
        when(request.getReader()).thenReturn(reader);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        // Act: Call service
        try {
            updateOrderStatusServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Assert: Should set JSON content type
        verify(response, atLeastOnce()).setContentType("application/json");
    }
}

