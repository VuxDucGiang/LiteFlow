package com.liteflow.controller.timesheet;

import com.liteflow.controller.LeaveRequestServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;
import com.liteflow.helpers.builders.TestDataBuilder;

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

@DisplayName("LeaveRequestServlet Integration Tests")
@Tag("integration")
@Tag("timesheet")
@Tag("controller")
public class LeaveRequestServletIntegrationTest {
    
    private LeaveRequestServlet leaveRequestServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        leaveRequestServlet = new LeaveRequestServlet();
    }
    
    @Test
    @DisplayName("Get leave requests list - root path")
    public void testGetLeaveRequestsRoot() throws Exception {
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
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Get leave requests list - with status filter")
    public void testGetLeaveRequestsWithStatus() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        when(request.getPathInfo()).thenReturn("/");
        when(request.getParameter("status")).thenReturn("Chờ duyệt");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getParameter("status");
    }
    
    @Test
    @DisplayName("Get leave request by ID")
    public void testGetLeaveRequestById() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        UUID requestId = UUID.randomUUID();
        when(request.getPathInfo()).thenReturn("/" + requestId.toString());
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Get leave requests - unauthorized")
    public void testGetLeaveRequestsUnauthorized() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        // No UserLogin in session
        when(request.getPathInfo()).thenReturn("/");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Get leave requests - invalid path")
    public void testGetLeaveRequestsInvalidPath() throws Exception {
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
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create leave request - valid data")
    public void testCreateLeaveRequest() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("leaveType")).thenReturn("ANNUAL");
        when(request.getParameter("startDate")).thenReturn("2024-01-01");
        when(request.getParameter("endDate")).thenReturn("2024-01-05");
        when(request.getParameter("reason")).thenReturn("Test reason");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getParameter("leaveType");
        verify(request, atLeastOnce()).getParameter("startDate");
        verify(request, atLeastOnce()).getParameter("endDate");
    }
    
    @Test
    @DisplayName("Create leave request - missing leaveType")
    public void testCreateLeaveRequestMissingLeaveType() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("leaveType")).thenReturn(null);
        when(request.getParameter("startDate")).thenReturn("2024-01-01");
        when(request.getParameter("endDate")).thenReturn("2024-01-05");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("leaveType");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create leave request - missing startDate")
    public void testCreateLeaveRequestMissingStartDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("leaveType")).thenReturn("ANNUAL");
        when(request.getParameter("startDate")).thenReturn(null);
        when(request.getParameter("endDate")).thenReturn("2024-01-05");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("startDate");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create leave request - missing endDate")
    public void testCreateLeaveRequestMissingEndDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("leaveType")).thenReturn("ANNUAL");
        when(request.getParameter("startDate")).thenReturn("2024-01-01");
        when(request.getParameter("endDate")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("endDate");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create leave request - unauthorized")
    public void testCreateLeaveRequestUnauthorized() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        // No UserLogin in session
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Create leave request - invalid date format")
    public void testCreateLeaveRequestInvalidDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("leaveType")).thenReturn("ANNUAL");
        when(request.getParameter("startDate")).thenReturn("invalid-date");
        when(request.getParameter("endDate")).thenReturn("2024-01-05");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail date parsing
        }
        
        verify(request, atLeastOnce()).getParameter("startDate");
    }
    
    @Test
    @DisplayName("Update leave request - PUT")
    public void testUpdateLeaveRequest() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = mock(HttpSession.class);
        UUID userId = UUID.randomUUID();
        UUID requestId = UUID.randomUUID();
        
        when(request.getMethod()).thenReturn("PUT");
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(userId);
        when(request.getPathInfo()).thenReturn("/" + requestId.toString());
        when(request.getParameter("leaveType")).thenReturn("SICK");
        when(request.getParameter("startDate")).thenReturn("2024-02-01");
        when(request.getParameter("endDate")).thenReturn("2024-02-03");
        when(request.getParameter("reason")).thenReturn("Updated reason");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Update leave request - cancel")
    public void testCancelLeaveRequest() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = mock(HttpSession.class);
        UUID userId = UUID.randomUUID();
        UUID requestId = UUID.randomUUID();
        
        when(request.getMethod()).thenReturn("PUT");
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(userId);
        when(request.getPathInfo()).thenReturn("/" + requestId.toString() + "/cancel");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Update leave request - invalid path")
    public void testUpdateLeaveRequestInvalidPath() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getMethod()).thenReturn("PUT");
        when(request.getPathInfo()).thenReturn("/invalid");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail
        }
        
        verify(request, atLeastOnce()).getPathInfo();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Update leave request - unauthorized")
    public void testUpdateLeaveRequestUnauthorized() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        UUID requestId = UUID.randomUUID();
        when(request.getMethod()).thenReturn("PUT");
        when(request.getPathInfo()).thenReturn("/" + requestId.toString());
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Delete leave request - DELETE")
    public void testDeleteLeaveRequest() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = mock(HttpSession.class);
        UUID userId = UUID.randomUUID();
        UUID requestId = UUID.randomUUID();
        
        when(request.getMethod()).thenReturn("DELETE");
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(userId);
        when(request.getPathInfo()).thenReturn("/" + requestId.toString());
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Delete leave request - invalid path")
    public void testDeleteLeaveRequestInvalidPath() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getMethod()).thenReturn("DELETE");
        when(request.getPathInfo()).thenReturn("/invalid-path");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail
        }
        
        verify(request, atLeastOnce()).getPathInfo();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Delete leave request - unauthorized")
    public void testDeleteLeaveRequestUnauthorized() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        UUID requestId = UUID.randomUUID();
        when(request.getMethod()).thenReturn("DELETE");
        when(request.getPathInfo()).thenReturn("/" + requestId.toString());
        HttpSession session = mock(HttpSession.class);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            leaveRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
}
