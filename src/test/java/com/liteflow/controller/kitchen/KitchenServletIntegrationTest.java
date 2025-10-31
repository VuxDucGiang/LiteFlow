package com.liteflow.controller.kitchen;

import com.liteflow.controller.KitchenServlet;
import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.service.OrderService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.io.*;
import java.lang.reflect.Field;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Integration tests for KitchenServlet.
 *
 * Test Coverage:
 * - handleKitchenPage() - Load kitchen page with initial orders
 * - handleGetOrders() - API endpoint to fetch orders (JSON)
 * - handleGetNotifications() - API endpoint to fetch notification history (JSON)
 * - handleSaveNotification() - API endpoint to save notifications (JSON)
 *
 * Strategy: Use Mockito to mock HTTP request/response and OrderService
 */
public class KitchenServletIntegrationTest extends IntegrationTestBase {

    /**
     * Testable wrapper for KitchenServlet to expose protected methods
     */
    private static class TestableKitchenServlet extends KitchenServlet {
        @Override
        public void doGet(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            super.doGet(request, response);
        }

        @Override
        public void doPost(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            super.doPost(request, response);
        }
    }

    private TestableKitchenServlet servlet;
    private OrderService mockOrderService;
    private HttpServletRequest mockRequest;
    private HttpServletResponse mockResponse;
    private StringWriter responseWriter;
    private PrintWriter responsePrintWriter;

    @BeforeEach
    public void setUpServlet() throws Exception {
        // Create servlet instance
        servlet = new TestableKitchenServlet();
        servlet.init();

        // Create mock OrderService
        mockOrderService = mock(OrderService.class);

        // Inject mock OrderService into servlet using reflection
        Field orderServiceField = KitchenServlet.class.getDeclaredField("orderService");
        orderServiceField.setAccessible(true);
        orderServiceField.set(servlet, mockOrderService);

        // Create mock HTTP request/response
        mockRequest = mock(HttpServletRequest.class);
        mockResponse = mock(HttpServletResponse.class);

        // Setup response writer
        responseWriter = new StringWriter();
        responsePrintWriter = new PrintWriter(responseWriter);
        when(mockResponse.getWriter()).thenReturn(responsePrintWriter);
    }

    // ===========================================
    // TEST CASES: handleKitchenPage() - GET /kitchen
    // ===========================================

    /**
     * TC-HP-001: Load kitchen page successfully with orders
     */
    @Test
    public void testHandleKitchenPage_Success_WithOrders() throws Exception {
        // Given: Mock pending orders
        List<Map<String, Object>> mockOrders = createMockOrders(3);
        when(mockOrderService.getPendingOrders()).thenReturn(mockOrders);

        // Mock request dispatcher
        RequestDispatcher mockDispatcher = mock(RequestDispatcher.class);
        when(mockRequest.getRequestDispatcher("/kitchen/kitchen.jsp")).thenReturn(mockDispatcher);
        when(mockRequest.getServletPath()).thenReturn("/kitchen");

        // When: Call servlet doGet
        servlet.doGet(mockRequest, mockResponse);

        // Then: Verify request attribute set with JSON orders
        ArgumentCaptor<String> attributeCaptor = ArgumentCaptor.forClass(String.class);
        verify(mockRequest).setAttribute(eq("ordersJson"), attributeCaptor.capture());

        String ordersJson = attributeCaptor.getValue();
        assertNotNull(ordersJson);
        assertTrue(ordersJson.contains("\"status\":\"Pending\""));

        // Verify dispatcher forward
        verify(mockDispatcher).forward(mockRequest, mockResponse);
        verify(mockOrderService, times(1)).getPendingOrders();
    }

    /**
     * TC-HP-002: Load kitchen page with empty orders
     */
    @Test
    public void testHandleKitchenPage_Success_EmptyOrders() throws Exception {
        // Given: Empty orders
        when(mockOrderService.getPendingOrders()).thenReturn(new ArrayList<>());

        RequestDispatcher mockDispatcher = mock(RequestDispatcher.class);
        when(mockRequest.getRequestDispatcher("/kitchen/kitchen.jsp")).thenReturn(mockDispatcher);
        when(mockRequest.getServletPath()).thenReturn("/kitchen");

        // When
        servlet.doGet(mockRequest, mockResponse);

        // Then
        ArgumentCaptor<String> attributeCaptor = ArgumentCaptor.forClass(String.class);
        verify(mockRequest).setAttribute(eq("ordersJson"), attributeCaptor.capture());

        String ordersJson = attributeCaptor.getValue();
        assertEquals("[]", ordersJson);
        verify(mockDispatcher).forward(mockRequest, mockResponse);
    }

    /**
     * TC-ERR-001: Handle service error when loading kitchen page
     */
    @Test
    public void testHandleKitchenPage_Error_ServiceException() throws Exception {
        // Given: OrderService throws exception
        when(mockOrderService.getPendingOrders()).thenThrow(new RuntimeException("Database error"));
        when(mockRequest.getServletPath()).thenReturn("/kitchen");

        // When
        servlet.doGet(mockRequest, mockResponse);

        // Then: Should send error response (500)
        verify(mockResponse).sendError(eq(HttpServletResponse.SC_INTERNAL_SERVER_ERROR), anyString());
    }

    // ===========================================
    // TEST CASES: handleGetOrders() - GET /api/kitchen/orders
    // ===========================================

    /**
     * TC-HP-003: Get orders API returns success with orders
     */
    @Test
    public void testHandleGetOrders_Success_WithOrders() throws Exception {
        // Given
        List<Map<String, Object>> mockOrders = createMockOrders(5);
        when(mockOrderService.getPendingOrders()).thenReturn(mockOrders);
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/orders");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setCharacterEncoding("UTF-8");
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"count\":5"));
        assertTrue(responseBody.contains("\"orders\""));
    }

    /**
     * TC-HP-004: Get orders API returns empty array when no orders
     */
    @Test
    public void testHandleGetOrders_Success_EmptyOrders() throws Exception {
        // Given
        when(mockOrderService.getPendingOrders()).thenReturn(new ArrayList<>());
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/orders");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"count\":0"));
        assertTrue(responseBody.contains("\"orders\":[]"));
    }

    /**
     * TC-ERR-002: Get orders API handles service exception
     */
    @Test
    public void testHandleGetOrders_Error_ServiceException() throws Exception {
        // Given
        when(mockOrderService.getPendingOrders()).thenThrow(new RuntimeException("DB connection failed"));
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/orders");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("\"message\""));
        assertTrue(responseBody.contains("\"orders\":[]"));
        assertTrue(responseBody.contains("\"count\":0"));
    }

    // ===========================================
    // TEST CASES: handleGetNotifications() - GET /api/kitchen/notifications
    // ===========================================

    /**
     * TC-HP-005: Get notifications API with default limit
     */
    @Test
    public void testHandleGetNotifications_Success_DefaultLimit() throws Exception {
        // Given: No limit parameter (use default 50)
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getParameter("limit")).thenReturn(null);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"notifications\""));
        assertTrue(responseBody.contains("\"count\""));
    }

    /**
     * TC-HP-006: Get notifications API with custom limit
     */
    @Test
    public void testHandleGetNotifications_Success_CustomLimit() throws Exception {
        // Given
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getParameter("limit")).thenReturn("20");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
    }

    /**
     * TC-EDGE-001: Get notifications with invalid limit (negative)
     */
    @Test
    public void testHandleGetNotifications_Edge_InvalidLimitNegative() throws Exception {
        // Given: Invalid limit (negative) - should use default 50
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getParameter("limit")).thenReturn("-10");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then: Should still succeed with default limit
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
    }

    /**
     * TC-EDGE-002: Get notifications with limit exceeding max (>100)
     */
    @Test
    public void testHandleGetNotifications_Edge_LimitExceedsMax() throws Exception {
        // Given: Limit > 100 - should cap to default 50
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getParameter("limit")).thenReturn("150");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then: Should still succeed with capped limit
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
    }

    /**
     * TC-EDGE-003: Get notifications with non-numeric limit
     */
    @Test
    public void testHandleGetNotifications_Edge_NonNumericLimit() throws Exception {
        // Given: Non-numeric limit - should use default 50
        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getParameter("limit")).thenReturn("invalid");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then: Should still succeed with default limit
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
    }

    // ===========================================
    // TEST CASES: handleSaveNotification() - POST /api/kitchen/notifications
    // ===========================================

    /**
     * TC-HP-007: Save notification successfully
     */
    @Test
    public void testHandleSaveNotification_Success() throws Exception {
        // Given: Valid notification JSON
        String notificationJson = "{\"type\":\"status-change\",\"orderId\":\"123\",\"title\":\"Test\"}";
        BufferedReader reader = new BufferedReader(new StringReader(notificationJson));

        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"message\""));
    }

    /**
     * TC-ERR-003: Save notification with empty body
     */
    @Test
    public void testHandleSaveNotification_Error_EmptyBody() throws Exception {
        // Given: Empty request body
        BufferedReader reader = new BufferedReader(new StringReader(""));

        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then: Should return error
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
    }

    /**
     * TC-ERR-004: Save notification with invalid JSON
     */
    @Test
    public void testHandleSaveNotification_Error_InvalidJson() throws Exception {
        // Given: Invalid JSON
        String invalidJson = "{invalid json content";
        BufferedReader reader = new BufferedReader(new StringReader(invalidJson));

        when(mockRequest.getServletPath()).thenReturn("/api/kitchen/notifications");
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then: Should return error
        verify(mockResponse).setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
    }

    // ===========================================
    // TEST CASES: Error Handling
    // ===========================================

    /**
     * TC-ERR-005: Invalid endpoint returns 404
     */
    @Test
    public void testInvalidEndpoint_Returns404() throws Exception {
        // Given: Invalid endpoint
        when(mockRequest.getServletPath()).thenReturn("/invalid/endpoint");

        // When
        servlet.doGet(mockRequest, mockResponse);

        // Then
        verify(mockResponse).sendError(eq(HttpServletResponse.SC_NOT_FOUND), anyString());
    }

    /**
     * TC-ERR-006: POST to unsupported endpoint returns 405
     */
    @Test
    public void testPostToUnsupportedEndpoint_Returns405() throws Exception {
        // Given: POST to /kitchen endpoint (not supported)
        when(mockRequest.getServletPath()).thenReturn("/kitchen");

        // When
        servlet.doPost(mockRequest, mockResponse);

        // Then
        verify(mockResponse).sendError(eq(HttpServletResponse.SC_METHOD_NOT_ALLOWED), anyString());
    }

    // ===========================================
    // HELPER METHODS
    // ===========================================

    /**
     * Create mock order data for testing
     */
    private List<Map<String, Object>> createMockOrders(int count) {
        List<Map<String, Object>> orders = new ArrayList<>();

        for (int i = 1; i <= count; i++) {
            Map<String, Object> order = new HashMap<>();
            order.put("orderId", UUID.randomUUID().toString());
            order.put("orderNumber", "ORD20251031" + String.format("%03d", i));
            order.put("orderDate", "2025-10-31T14:30:00");
            order.put("status", "Pending");
            order.put("tableName", "Table " + i);

            // Add order items
            List<Map<String, Object>> items = new ArrayList<>();
            Map<String, Object> item = new HashMap<>();
            item.put("productName", "Coffee");
            item.put("quantity", 2);
            item.put("status", "Pending");
            item.put("note", "No sugar");
            items.add(item);

            order.put("items", items);
            orders.add(order);
        }

        return orders;
    }
}
