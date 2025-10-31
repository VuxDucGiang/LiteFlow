package com.liteflow.controller.dashboard;

import com.liteflow.controller.DashboardServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Integration tests for DashboardServlet.
 * Tests HTTP request handling for dashboard page.
 * 
 * Strategy: Use mocks for HTTP requests/responses
 */
@DisplayName("DashboardServlet Integration Tests")
@Tag("integration")
@Tag("dashboard")
@Tag("controller")
public class DashboardServletIntegrationTest {
    
    private DashboardServlet dashboardServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        dashboardServlet = new DashboardServlet();
    }
    
    @Test
    @DisplayName("Get dashboard page")
    public void testGetDashboardPage() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/dashboard.jsp")).thenReturn(dispatcher);
        
        dashboardServlet.service(request, response);
        
        verify(request, atLeastOnce()).getMethod();
        verify(dispatcher).forward(request, response);
    }
}

