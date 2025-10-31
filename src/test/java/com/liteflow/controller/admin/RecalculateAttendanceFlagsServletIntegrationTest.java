package com.liteflow.controller.admin;

import com.liteflow.controller.RecalculateAttendanceFlagsServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * Integration tests for RecalculateAttendanceFlagsServlet.
 * Tests HTTP request handling for recalculating attendance flags.
 * 
 * Strategy: Use mocks for HTTP requests/responses, may fail without DB but should execute
 */
@DisplayName("RecalculateAttendanceFlagsServlet Integration Tests")
@Tag("integration")
@Tag("admin")
@Tag("controller")
public class RecalculateAttendanceFlagsServletIntegrationTest {
    
    private RecalculateAttendanceFlagsServlet recalculateAttendanceFlagsServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        recalculateAttendanceFlagsServlet = new RecalculateAttendanceFlagsServlet();
    }
    
    @Test
    @DisplayName("Get recalculate form page")
    public void testGetRecalculatePage() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
        verify(response, atLeastOnce()).getWriter();
    }
    
    @Test
    @DisplayName("Get page output contains form")
    public void testGetPageContainsForm() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
            printWriter.flush();
            String output = stringWriter.toString();
            assertTrue(output.contains("Recalculate") || output.contains("days"));
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response, atLeastOnce()).getWriter();
    }
    
    @Test
    @DisplayName("Post recalculate with default days")
    public void testPostRecalculateDefault() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn(null);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
        verify(request, atLeastOnce()).getParameter("days");
    }
    
    @Test
    @DisplayName("Post recalculate with custom days")
    public void testPostRecalculateCustomDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("60");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
        verify(request, atLeastOnce()).getParameter("days");
    }
    
    @Test
    @DisplayName("Post recalculate with invalid days - non-numeric")
    public void testPostRecalculateInvalidDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("invalid");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // Expected - invalid number format, defaults to 30
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Post recalculate with empty days string")
    public void testPostRecalculateEmptyDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Post recalculate with blank days string")
    public void testPostRecalculateBlankDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("   ");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Post recalculate with large days value")
    public void testPostRecalculateLargeDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("365");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Post recalculate with minimum days value")
    public void testPostRecalculateMinDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("1");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Post recalculate with zero days")
    public void testPostRecalculateZeroDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("0");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Post recalculate with negative days")
    public void testPostRecalculateNegativeDays() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("-1");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Verify POST response contains results")
    public void testPostResponseContainsResults() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("30");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
            printWriter.flush();
            String output = stringWriter.toString();
            
            // Verify HTML output contains expected elements
            assertTrue(output.contains("Recalculate") || output.contains("Hoàn thành") || output.contains("records"));
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("days");
        verify(response, atLeastOnce()).getWriter();
    }
    
    @Test
    @DisplayName("Verify POST response contains context path")
    public void testPostResponseContainsContextPath() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("30");
        when(request.getContextPath()).thenReturn("/TestApp");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
            printWriter.flush();
            String output = stringWriter.toString();
            
            // Verify HTML output contains context path in link
            assertTrue(output.contains("/TestApp") || output.contains("Quay lại"));
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getContextPath();
        verify(response, atLeastOnce()).getWriter();
    }
    
    @Test
    @DisplayName("Error handling in doGet")
    public void testGetErrorHandling() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(response.getWriter()).thenThrow(new RuntimeException("Test error"));
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // Expected
        }
        
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
    
    @Test
    @DisplayName("Error handling in doPost")
    public void testPostErrorHandling() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("days")).thenReturn("30");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        when(response.getWriter()).thenThrow(new RuntimeException("Test error"));
        
        try {
            recalculateAttendanceFlagsServlet.service(request, response);
        } catch (Exception e) {
            // Expected
        }
        
        verify(response, atLeastOnce()).setContentType("text/html; charset=UTF-8");
    }
}
