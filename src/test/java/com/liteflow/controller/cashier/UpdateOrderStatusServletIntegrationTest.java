package com.liteflow.controller.cashier;

import com.liteflow.controller.UpdateOrderStatusServlet;
import com.liteflow.helpers.base.IntegrationTestBase;
import com.liteflow.service.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.*;
import java.lang.reflect.Field;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Integration tests for UpdateOrderStatusServlet.
 *
 * Test Coverage:
 * - POST /api/order/status - Update order status
 *
 * Strategy: Use Mockito to mock HTTP request/response and OrderService
 */
public class UpdateOrderStatusServletIntegrationTest extends IntegrationTestBase {

    /**
     * Testable wrapper for UpdateOrderStatusServlet to expose protected methods
     */
    private static class TestableUpdateOrderStatusServlet extends UpdateOrderStatusServlet {
        @Override
        public void doPost(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            super.doPost(request, response);
        }
    }

    private TestableUpdateOrderStatusServlet servlet;
    private OrderService mockOrderService;
    private HttpServletRequest mockRequest;
    private HttpServletResponse mockResponse;
    private StringWriter responseWriter;
    private PrintWriter responsePrintWriter;

    @BeforeEach
    public void setUpServlet() throws Exception {
        // Create servlet instance
        servlet = new TestableUpdateOrderStatusServlet();
        servlet.init();

        // Create mock OrderService
        mockOrderService = mock(OrderService.class);

        // Inject mock OrderService into servlet using reflection
        Field orderServiceField = UpdateOrderStatusServlet.class.getDeclaredField("orderService");
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
    // TEST CASES: doPost() - POST /api/order/status
    // ===========================================

    /**
     * TC-HP-013: Update order status successfully to Preparing
     */
    @Test
    public void testUpdateOrderStatus_Success_ToPreparing() throws Exception {
        // Given: Valid request to update status to Preparing
        String orderId = "123e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\",\"status\":\"Preparing\"}", orderId);

        when(mockOrderService.updateOrderStatus(UUID.fromString(orderId), "Preparing"))
                .thenReturn(true);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setCharacterEncoding("UTF-8");
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"orderId\":\"" + orderId + "\""));
        assertTrue(responseBody.contains("\"newStatus\":\"Preparing\""));

        verify(mockOrderService, times(1)).updateOrderStatus(UUID.fromString(orderId), "Preparing");
    }

    /**
     * TC-HP-014: Update order status successfully to Ready
     */
    @Test
    public void testUpdateOrderStatus_Success_ToReady() throws Exception {
        // Given: Valid request to update status to Ready
        String orderId = "223e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\",\"status\":\"Ready\"}", orderId);

        when(mockOrderService.updateOrderStatus(UUID.fromString(orderId), "Ready"))
                .thenReturn(true);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"newStatus\":\"Ready\""));

        verify(mockOrderService, times(1)).updateOrderStatus(UUID.fromString(orderId), "Ready");
    }

    /**
     * TC-HP-015: Update order status successfully to Served
     */
    @Test
    public void testUpdateOrderStatus_Success_ToServed() throws Exception {
        // Given: Valid request to update status to Served
        String orderId = "323e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\",\"status\":\"Served\"}", orderId);

        when(mockOrderService.updateOrderStatus(UUID.fromString(orderId), "Served"))
                .thenReturn(true);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"newStatus\":\"Served\""));

        verify(mockOrderService, times(1)).updateOrderStatus(UUID.fromString(orderId), "Served");
    }

    /**
     * TC-HP-016: Update order status successfully to Cancelled
     */
    @Test
    public void testUpdateOrderStatus_Success_ToCancelled() throws Exception {
        // Given: Valid request to update status to Cancelled
        String orderId = "423e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\",\"status\":\"Cancelled\"}", orderId);

        when(mockOrderService.updateOrderStatus(UUID.fromString(orderId), "Cancelled"))
                .thenReturn(true);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"newStatus\":\"Cancelled\""));

        verify(mockOrderService, times(1)).updateOrderStatus(UUID.fromString(orderId), "Cancelled");
    }

    /**
     * TC-ERR-021: Update order status with missing orderId
     */
    @Test
    public void testUpdateOrderStatus_Error_MissingOrderId() throws Exception {
        // Given: Request without orderId
        String requestJson = "{\"status\":\"Preparing\"}";

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Order ID không được rỗng"));

        verify(mockOrderService, never()).updateOrderStatus(any(), any());
    }

    /**
     * TC-ERR-022: Update order status with missing status
     */
    @Test
    public void testUpdateOrderStatus_Error_MissingStatus() throws Exception {
        // Given: Request without status
        String orderId = "523e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\"}", orderId);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Status không được rỗng"));

        verify(mockOrderService, never()).updateOrderStatus(any(), any());
    }

    /**
     * TC-ERR-023: Update order status with invalid orderId format
     */
    @Test
    public void testUpdateOrderStatus_Error_InvalidOrderIdFormat() throws Exception {
        // Given: Invalid UUID format
        String requestJson = "{\"orderId\":\"invalid-uuid\",\"status\":\"Preparing\"}";

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Order ID không hợp lệ"));

        verify(mockOrderService, never()).updateOrderStatus(any(), any());
    }

    /**
     * TC-ERR-024: Update order status when order not found
     */
    @Test
    public void testUpdateOrderStatus_Error_OrderNotFound() throws Exception {
        // Given: Service returns false (order not found)
        String orderId = "623e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\",\"status\":\"Preparing\"}", orderId);

        when(mockOrderService.updateOrderStatus(UUID.fromString(orderId), "Preparing"))
                .thenReturn(false);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_NOT_FOUND);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Không tìm thấy order"));

        verify(mockOrderService, times(1)).updateOrderStatus(UUID.fromString(orderId), "Preparing");
    }

    /**
     * TC-ERR-025: Update order status with invalid status value (caught by service)
     */
    @Test
    public void testUpdateOrderStatus_Error_InvalidStatus() throws Exception {
        // Given: Service throws IllegalArgumentException for invalid status
        String orderId = "723e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\",\"status\":\"InvalidStatus\"}", orderId);

        when(mockOrderService.updateOrderStatus(UUID.fromString(orderId), "InvalidStatus"))
                .thenThrow(new IllegalArgumentException("Trạng thái không hợp lệ: InvalidStatus"));

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Trạng thái không hợp lệ"));

        verify(mockOrderService, times(1)).updateOrderStatus(UUID.fromString(orderId), "InvalidStatus");
    }

    /**
     * TC-ERR-026: Update order status with malformed JSON
     */
    @Test
    public void testUpdateOrderStatus_Error_MalformedJson() throws Exception {
        // Given: Invalid JSON
        String requestJson = "{invalid json content";

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Lỗi server"));

        verify(mockOrderService, never()).updateOrderStatus(any(), any());
    }

    /**
     * TC-ERR-027: Update order status with service throwing general exception
     */
    @Test
    public void testUpdateOrderStatus_Error_ServiceException() throws Exception {
        // Given: Service throws runtime exception
        String orderId = "823e4567-e89b-12d3-a456-426614174000";
        String requestJson = String.format("{\"orderId\":\"%s\",\"status\":\"Preparing\"}", orderId);

        when(mockOrderService.updateOrderStatus(UUID.fromString(orderId), "Preparing"))
                .thenThrow(new RuntimeException("Database error"));

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Lỗi server"));
    }
}
