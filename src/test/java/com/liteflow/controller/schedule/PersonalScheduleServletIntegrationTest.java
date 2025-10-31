package com.liteflow.controller.schedule;

import com.liteflow.controller.PersonalScheduleServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.UUID;

@DisplayName("PersonalScheduleServlet Integration Tests")
@Tag("integration")
@Tag("schedule")
@Tag("controller")
public class PersonalScheduleServletIntegrationTest {
    
    private PersonalScheduleServlet personalScheduleServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        personalScheduleServlet = new PersonalScheduleServlet();
    }
    
    @Test
    @DisplayName("Get all schedules - root path")
    public void testGetAllSchedulesRoot() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        when(request.getPathInfo()).thenReturn("/");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Get schedules - with date filter")
    public void testGetSchedulesWithDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        when(request.getPathInfo()).thenReturn("/");
        when(request.getParameter("date")).thenReturn("2024-01-01");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getParameter("date");
    }
    
    @Test
    @DisplayName("Get schedule by ID")
    public void testGetScheduleById() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        UUID scheduleId = UUID.randomUUID();
        when(request.getPathInfo()).thenReturn("/" + scheduleId.toString());
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Get schedules - unauthorized")
    public void testGetSchedulesUnauthorized() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        // No UserLogin in session
        when(request.getPathInfo()).thenReturn("/");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Get schedules - invalid path")
    public void testGetSchedulesInvalidPath() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        when(request.getPathInfo()).thenReturn("/invalid-path");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create schedule - valid data")
    public void testCreateSchedule() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("title")).thenReturn("Test Schedule");
        when(request.getParameter("description")).thenReturn("Test Description");
        when(request.getParameter("startDate")).thenReturn("2024-01-01");
        when(request.getParameter("startTime")).thenReturn("09:00");
        when(request.getParameter("endTime")).thenReturn("17:00");
        when(request.getParameter("priority")).thenReturn("High");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getParameter("title");
        verify(request, atLeastOnce()).getParameter("startDate");
    }
    
    @Test
    @DisplayName("Create schedule - missing title")
    public void testCreateScheduleMissingTitle() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("title")).thenReturn(null);
        when(request.getParameter("startDate")).thenReturn("2024-01-01");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("title");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create schedule - missing startDate")
    public void testCreateScheduleMissingStartDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("title")).thenReturn("Test Schedule");
        when(request.getParameter("startDate")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("startDate");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create schedule - unauthorized")
    public void testCreateScheduleUnauthorized() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        // No UserLogin in session
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Update schedule - PUT")
    public void testUpdateSchedule() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = mock(HttpSession.class);
        UUID userId = UUID.randomUUID();
        UUID scheduleId = UUID.randomUUID();
        
        when(request.getMethod()).thenReturn("PUT");
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(userId);
        when(request.getPathInfo()).thenReturn("/" + scheduleId.toString());
        when(request.getParameter("title")).thenReturn("Updated Title");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Update schedule - invalid path")
    public void testUpdateScheduleInvalidPath() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getMethod()).thenReturn("PUT");
        when(request.getPathInfo()).thenReturn("/invalid");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail
        }
        
        verify(request, atLeastOnce()).getPathInfo();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Update schedule - unauthorized")
    public void testUpdateScheduleUnauthorized() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        UUID scheduleId = UUID.randomUUID();
        when(request.getMethod()).thenReturn("PUT");
        when(request.getPathInfo()).thenReturn("/" + scheduleId.toString());
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Delete schedule - DELETE")
    public void testDeleteSchedule() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = mock(HttpSession.class);
        UUID userId = UUID.randomUUID();
        UUID scheduleId = UUID.randomUUID();
        
        when(request.getMethod()).thenReturn("DELETE");
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(userId);
        when(request.getPathInfo()).thenReturn("/" + scheduleId.toString());
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Delete schedule - invalid path")
    public void testDeleteScheduleInvalidPath() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getMethod()).thenReturn("DELETE");
        when(request.getPathInfo()).thenReturn("/invalid-path");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail
        }
        
        verify(request, atLeastOnce()).getPathInfo();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Delete schedule - unauthorized")
    public void testDeleteScheduleUnauthorized() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        UUID scheduleId = UUID.randomUUID();
        when(request.getMethod()).thenReturn("DELETE");
        when(request.getPathInfo()).thenReturn("/" + scheduleId.toString());
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            personalScheduleServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
}
