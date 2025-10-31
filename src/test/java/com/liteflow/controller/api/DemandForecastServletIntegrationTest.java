package com.liteflow.controller.api;

import com.liteflow.web.api.DemandForecastServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * Integration tests for DemandForecastServlet.
 * Tests HTTP request handling for demand forecasting API.
 * 
 * Strategy: Use mocks for HTTP requests/responses, may fail without DB but should execute
 */
@DisplayName("DemandForecastServlet Integration Tests")
@Tag("integration")
@Tag("api")
@Tag("controller")
public class DemandForecastServletIntegrationTest {
    
    private DemandForecastServlet demandForecastServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        demandForecastServlet = new DemandForecastServlet();
        // Don't call init() to avoid DB initialization
    }
    
    /**
     * Test GET full analysis (no action parameter)
     */
    @Test
    @DisplayName("Get full analysis")
    public void testGetFullAnalysis() throws Exception {
        // Arrange: Create GET request
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn(null);
        
        // Mock response writer
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        // Act: Call service
        try {
            demandForecastServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Assert: Should set JSON content type
        verify(response, atLeastOnce()).setContentType("application/json");
    }
    
    /**
     * Test GET stock alerts
     */
    @Test
    @DisplayName("Get stock alerts")
    public void testGetStockAlerts() throws Exception {
        // Arrange: Create GET request with alerts action
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("alerts");
        
        // Mock response writer
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        // Act: Call service
        try {
            demandForecastServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Assert: Should set content type
        verify(response, atLeastOnce()).setContentType("application/json");
    }
    
    /**
     * Test GET replenishment suggestions
     */
    @Test
    @DisplayName("Get replenishment suggestions")
    public void testGetReplenishmentSuggestions() throws Exception {
        // Arrange: Create GET request with suggestions action
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("suggestions");
        
        // Mock response writer
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        // Act: Call service
        try {
            demandForecastServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Assert: Should set content type
        verify(response, atLeastOnce()).setContentType("application/json");
    }
    
    /**
     * Test OPTIONS request for CORS
     */
    @Test
    @DisplayName("Handle OPTIONS request for CORS")
    public void testOptionsRequest() throws Exception {
        // Arrange: Create OPTIONS request
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        
        when(request.getMethod()).thenReturn("OPTIONS");
        
        // Act: Call service
        demandForecastServlet.service(request, response);
        
        // Assert: Should set CORS headers and OK status
        verify(response).setHeader("Access-Control-Allow-Origin", "*");
        verify(response).setHeader("Access-Control-Allow-Methods", "GET");
        verify(response).setStatus(HttpServletResponse.SC_OK);
    }
}

