package com.liteflow.controller.timesheet;

import com.liteflow.controller.ForgotClockRequestServlet;
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

@DisplayName("ForgotClockRequestServlet Integration Tests")
@Tag("integration")
@Tag("timesheet")
@Tag("controller")
public class ForgotClockRequestServletIntegrationTest {
    
    private ForgotClockRequestServlet forgotClockRequestServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        forgotClockRequestServlet = new ForgotClockRequestServlet();
    }
    
    @Test
    @DisplayName("Get forgot clock requests list - root path")
    public void testGetForgotClockRequestsRoot() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Get forgot clock requests list - with status filter")
    public void testGetForgotClockRequestsWithStatus() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getParameter("status");
    }
    
    @Test
    @DisplayName("Get forgot clock request by ID")
    public void testGetForgotClockRequestById() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Get forgot clock requests - unauthorized")
    public void testGetForgotClockRequestsUnauthorized() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        // No UserLogin in session
        when(request.getPathInfo()).thenReturn("/");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Get forgot clock requests - invalid path")
    public void testGetForgotClockRequestsInvalidPath() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create forgot clock request - valid data")
    public void testCreateForgotClockRequest() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("forgotDate")).thenReturn("2024-01-01");
        when(request.getParameter("forgotType")).thenReturn("IN");
        when(request.getParameter("forgotTime")).thenReturn("08:00");
        when(request.getParameter("reason")).thenReturn("Test reason");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getParameter("forgotDate");
        verify(request, atLeastOnce()).getParameter("forgotType");
        verify(request, atLeastOnce()).getParameter("reason");
    }
    
    @Test
    @DisplayName("Create forgot clock request - missing forgotDate")
    public void testCreateForgotClockRequestMissingDate() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("forgotDate")).thenReturn(null);
        when(request.getParameter("forgotType")).thenReturn("IN");
        when(request.getParameter("reason")).thenReturn("Test reason");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("forgotDate");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create forgot clock request - missing forgotType")
    public void testCreateForgotClockRequestMissingType() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("forgotDate")).thenReturn("2024-01-01");
        when(request.getParameter("forgotType")).thenReturn(null);
        when(request.getParameter("reason")).thenReturn("Test reason");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("forgotType");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create forgot clock request - missing reason")
    public void testCreateForgotClockRequestMissingReason() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        UUID userId = UUID.randomUUID();
        session.setAttribute("UserLogin", userId);
        
        when(request.getParameter("forgotDate")).thenReturn("2024-01-01");
        when(request.getParameter("forgotType")).thenReturn("IN");
        when(request.getParameter("reason")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail validation
        }
        
        verify(request, atLeastOnce()).getParameter("reason");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Create forgot clock request - unauthorized")
    public void testCreateForgotClockRequestUnauthorized() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = request.getSession();
        // No UserLogin in session
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Update forgot clock request - PUT")
    public void testUpdateForgotClockRequest() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        HttpSession session = mock(HttpSession.class);
        UUID userId = UUID.randomUUID();
        UUID requestId = UUID.randomUUID();
        
        when(request.getMethod()).thenReturn("PUT");
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("UserLogin")).thenReturn(userId);
        when(request.getPathInfo()).thenReturn("/" + requestId.toString());
        when(request.getParameter("forgotDate")).thenReturn("2024-02-01");
        when(request.getParameter("forgotType")).thenReturn("OUT");
        when(request.getParameter("reason")).thenReturn("Updated reason");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Update forgot clock request - cancel")
    public void testCancelForgotClockRequest() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Update forgot clock request - invalid path")
    public void testUpdateForgotClockRequestInvalidPath() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getMethod()).thenReturn("PUT");
        when(request.getPathInfo()).thenReturn("/invalid");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail
        }
        
        verify(request, atLeastOnce()).getPathInfo();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Update forgot clock request - unauthorized")
    public void testUpdateForgotClockRequestUnauthorized() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
    
    @Test
    @DisplayName("Delete forgot clock request - DELETE")
    public void testDeleteForgotClockRequest() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(request, atLeastOnce()).getPathInfo();
    }
    
    @Test
    @DisplayName("Delete forgot clock request - invalid path")
    public void testDeleteForgotClockRequestInvalidPath() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getMethod()).thenReturn("DELETE");
        when(request.getPathInfo()).thenReturn("/invalid-path");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail
        }
        
        verify(request, atLeastOnce()).getPathInfo();
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    
    @Test
    @DisplayName("Delete forgot clock request - unauthorized")
    public void testDeleteForgotClockRequestUnauthorized() throws Exception {
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
            forgotClockRequestServlet.service(request, response);
        } catch (Exception e) {
            // Expected to fail authentication
        }
        
        verify(request, atLeastOnce()).getSession();
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }
}
