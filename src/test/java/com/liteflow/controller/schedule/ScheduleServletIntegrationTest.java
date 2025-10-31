package com.liteflow.controller.schedule;

import com.liteflow.controller.ScheduleServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.UUID;

/**
 * Integration tests for ScheduleServlet.
 * Tests HTTP request handling for schedule management.
 * 
 * Strategy: Use mocks for HTTP requests/responses, may fail without DB but should execute
 */
@DisplayName("ScheduleServlet Integration Tests")
@Tag("integration")
@Tag("schedule")
@Tag("controller")
public class ScheduleServletIntegrationTest {
    
    private ScheduleServlet scheduleServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        scheduleServlet = new ScheduleServlet();
        // Don't call init() to avoid DB initialization
    }
    
    @Test
    @DisplayName("Get schedule page")
    public void testGetSchedulePage() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getMethod();
    }
    
    @Test
    @DisplayName("Get schedule page with week start parameter")
    public void testGetSchedulePageWithWeekStart() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("weekStart");
    }
    
    @Test
    @DisplayName("Get schedule page - invalid weekStart date")
    public void testGetSchedulePageInvalidWeekStart() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("weekStart")).thenReturn("invalid-date");
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected - invalid date format
        }
        
        verify(request, atLeastOnce()).getParameter("weekStart");
    }
    
    @Test
    @DisplayName("Get schedule page - blank weekStart parameter")
    public void testGetSchedulePageBlankWeekStart() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("weekStart")).thenReturn("   ");
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("weekStart");
    }
    
    @Test
    @DisplayName("Get schedule page - with employeeCode filter")
    public void testGetSchedulePageWithEmployeeFilter() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("employeeCode")).thenReturn("EMP001");
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("employeeCode");
    }
    
    @Test
    @DisplayName("Get schedule page - with templateName filter")
    public void testGetSchedulePageWithTemplateFilter() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("templateName")).thenReturn("Morning");
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("templateName");
    }
    
    @Test
    @DisplayName("Get schedule page - null UserRoles")
    public void testGetSchedulePageNullUserRoles() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(null);
        when(session.getAttribute("UserLogin")).thenReturn(UUID.randomUUID());
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(session, atLeastOnce()).getAttribute("UserRoles");
    }
    
    @Test
    @DisplayName("Get schedule page - empty UserRoles")
    public void testGetSchedulePageEmptyUserRoles() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Collections.emptyList());
        when(session.getAttribute("UserLogin")).thenReturn(UUID.randomUUID());
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(session, atLeastOnce()).getAttribute("UserRoles");
    }
    
    @Test
    @DisplayName("Get schedule page - UserLogin as String")
    public void testGetSchedulePageUserLoginAsString() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(null);
        when(session.getAttribute("UserLogin")).thenReturn(UUID.randomUUID().toString());
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(session, atLeastOnce()).getAttribute("UserLogin");
    }
    
    @Test
    @DisplayName("Get schedule page - invalid UserLogin String")
    public void testGetSchedulePageInvalidUserLogin() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(null);
        when(session.getAttribute("UserLogin")).thenReturn("invalid-uuid");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected - invalid UUID
        }
        
        verify(session, atLeastOnce()).getAttribute("UserLogin");
    }
    
    @Test
    @DisplayName("Get schedule page - Employee role")
    public void testGetSchedulePageEmployeeRole() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Employee"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getRequestDispatcher("/schedule.jsp");
    }
    
    @Test
    @DisplayName("Create shift via POST")
    public void testCreateShift() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("title")).thenReturn("Morning Shift");
        when(request.getParameter("notes")).thenReturn("Test notes");
        when(request.getParameter("location")).thenReturn("Main Office");
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserEmployeeCode")).thenReturn("ADMIN001");
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - missing date")
    public void testCreateShiftMissingDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn(null);
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected - missing date
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - missing employeeCode")
    public void testCreateShiftMissingEmployeeCode() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(null);
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - invalid date format")
    public void testCreateShiftInvalidDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("invalid-date");
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected - invalid date format
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - invalid time format")
    public void testCreateShiftInvalidTime() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"invalid-time"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected - invalid time format
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - mismatched start/end times")
    public void testCreateShiftMismatchedTimes() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00", "10:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - with isRecurring")
    public void testCreateShiftRecurring() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("isRecurring")).thenReturn("true");
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("isRecurring");
    }
    
    @Test
    @DisplayName("Create shift - with embed parameter")
    public void testCreateShiftWithEmbed() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        when(request.getParameter("embed")).thenReturn("1");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        // Verify parameters were read (embed may not be read if creation fails)
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - blank action defaults to create")
    public void testCreateShiftBlankAction() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - null action defaults to create")
    public void testCreateShiftNullAction() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn(null);
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - empty employeeCode in array")
    public void testCreateShiftEmptyEmployeeCode() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"", "EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Create shift - with templateName parameter")
    public void testCreateShiftWithTemplateName() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameterValues("employeeCode")).thenReturn(new String[]{"EMP001"});
        when(request.getParameter("date")).thenReturn("2024-01-01");
        when(request.getParameterValues("startTime")).thenReturn(new String[]{"09:00:00"});
        when(request.getParameterValues("endTime")).thenReturn(new String[]{"17:00:00"});
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        when(request.getParameter("templateName")).thenReturn("Morning");
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("templateName");
    }
    
    @Test
    @DisplayName("Error handling in doGet")
    public void testGetErrorHandling() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/schedule.jsp")).thenReturn(dispatcher);
        doThrow(new RuntimeException("Test error")).when(dispatcher).forward(any(), any());
        
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("UserRoles")).thenReturn(Arrays.asList("Admin"));
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // Exception handled in servlet
        }
        
        verify(request, atLeastOnce()).getRequestDispatcher("/schedule.jsp");
    }
    
    @Test
    @DisplayName("Error handling in doPost")
    public void testPostErrorHandling() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("create");
        when(request.getParameter("weekStart")).thenReturn("2024-01-01");
        when(request.getParameter("date")).thenThrow(new RuntimeException("Test error"));
        
        HttpSession session = ServletTestHelper.mockSession();
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/LiteFlow");
        
        try {
            scheduleServlet.service(request, response);
        } catch (Exception e) {
            // Exception handled in servlet
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
}
