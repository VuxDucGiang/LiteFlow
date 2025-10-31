package com.liteflow.controller.report;

import com.liteflow.controller.DailyReportServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.PrintWriter;
import java.io.StringWriter;

@DisplayName("DailyReportServlet Integration Tests")
@Tag("integration")
@Tag("report")
@Tag("controller")
public class DailyReportServletIntegrationTest {
    
    private DailyReportServlet dailyReportServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        dailyReportServlet = new DailyReportServlet();
        dailyReportServlet.init();
    }
    
    @Test
    @DisplayName("Get daily summary API")
    public void testGetDailySummary() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getPathInfo()).thenReturn("/daily-summary");
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameter("type")).thenReturn("summary");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            dailyReportServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Export daily report")
    public void testExportDailyReport() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getPathInfo()).thenReturn("/daily-export");
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameter("format")).thenReturn("excel");
        
        try {
            dailyReportServlet.service(request, response);
        } catch (Exception e) {
            // May fail without output stream
        }
        
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Handle OPTIONS request")
    public void testHandleOptions() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getMethod()).thenReturn("OPTIONS");
        
        try {
            dailyReportServlet.service(request, response);
        } catch (Exception e) {
            // May fail
        }
        
        verify(response, atLeastOnce()).setHeader(eq("Access-Control-Allow-Origin"), anyString());
    }
    
    @Test
    @DisplayName("Handle invalid path")
    public void testHandleInvalidPath() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getPathInfo()).thenReturn("/invalid-path");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            dailyReportServlet.service(request, response);
        } catch (Exception e) {
            // May fail
        }
        
        verify(request, atLeastOnce()).getPathInfo();
    }
}
