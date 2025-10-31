package com.liteflow.controller.dashboard;

import com.liteflow.controller.SetupEmployeeServlet;
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
 * Integration tests for SetupEmployeeServlet.
 * Tests HTTP request handling for setup employee page.
 * 
 * Strategy: Use mocks for HTTP requests/responses
 */
@DisplayName("SetupEmployeeServlet Integration Tests")
@Tag("integration")
@Tag("dashboard")
@Tag("controller")
public class SetupEmployeeServletIntegrationTest {
    
    private SetupEmployeeServlet setupEmployeeServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        setupEmployeeServlet = new SetupEmployeeServlet();
    }
    
    @Test
    @DisplayName("Get setup employee page")
    public void testGetSetupEmployeePage() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/employee/setupEmployee.jsp")).thenReturn(dispatcher);
        
        setupEmployeeServlet.service(request, response);
        
        verify(request, atLeastOnce()).getMethod();
        verify(request).setAttribute("page", "setup-employee");
        verify(dispatcher).forward(request, response);
    }
    
    @Test
    @DisplayName("POST redirects to GET")
    public void testPostRedirectsToGet() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        setupEmployeeServlet.service(request, response);
        
        verify(request, atLeastOnce()).getMethod();
        verify(response).sendRedirect("/LiteFlow/employee/setup");
    }
}

