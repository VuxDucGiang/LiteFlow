package com.liteflow.controller.cashier;

import com.liteflow.controller.GetSessionOrdersServlet;
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
 * Integration tests for GetSessionOrdersServlet.
 *
 * Test Coverage:
 * - GET /api/order/table/{tableId} - Get all orders for a specific table
 *
 * Strategy: Use Mockito to mock HTTP request/response and OrderService
 */
public class GetSessionOrdersServletIntegrationTest extends IntegrationTestBase {

    /**
     * Testable wrapper for GetSessionOrdersServlet to expose protected methods
     */
    private static class TestableGetSessionOrdersServlet extends GetSessionOrdersServlet {
        @Override
        public void doGet(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            super.doGet(request, response);
        }
    }

    private TestableGetSessionOrdersServlet servlet;
    private OrderService mockOrderService;
    private HttpServletRequest mockRequest;
    private HttpServletResponse mockResponse;
    private StringWriter responseWriter;
    private PrintWriter responsePrintWriter;

    @BeforeEach
    public void setUpServlet() throws Exception {
        // Create servlet instance
        servlet = new TestableGetSessionOrdersServlet();
        servlet.init();

        // Create mock OrderService
        mockOrderService = mock(OrderService.class);

        // Inject mock OrderService into servlet using reflection
        Field orderServiceField = GetSessionOrdersServlet.class.getDeclaredField("orderService");
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
    // TEST CASES: doGet() - GET /api/order/table/{tableId}
    // ===========================================

    /**
     * TC-HP-011: Get orders for table successfully with orders
     */
    @Test
    public void testGetSessionOrders_Success_WithOrders() throws Exception {
        // Given: Valid table ID with orders
        String tableId = "123e4567-e89b-12d3-a456-426614174000";
        List<Map<String, Object>> mockOrders = createMockTableOrders(3);

        when(mockOrderService.getOrdersByTable(UUID.fromString(tableId)))
                .thenReturn(mockOrders);
        when(mockRequest.getPathInfo()).thenReturn("/" + tableId);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setCharacterEncoding("UTF-8");
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"tableId\":\"" + tableId + "\""));
        assertTrue(responseBody.contains("\"orders\""));

        verify(mockOrderService, times(1)).getOrdersByTable(UUID.fromString(tableId));
    }

    /**
     * TC-HP-012: Get orders for table with no orders (empty array)
     */
    @Test
    public void testGetSessionOrders_Success_EmptyOrders() throws Exception {
        // Given: Valid table ID with no orders
        String tableId = "223e4567-e89b-12d3-a456-426614174000";

        when(mockOrderService.getOrdersByTable(UUID.fromString(tableId)))
                .thenReturn(new ArrayList<>());
        when(mockRequest.getPathInfo()).thenReturn("/" + tableId);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"orders\":[]"));

        verify(mockOrderService, times(1)).getOrdersByTable(UUID.fromString(tableId));
    }

    /**
     * TC-ERR-016: Get orders with missing tableId (no path info)
     */
    @Test
    public void testGetSessionOrders_Error_MissingTableId() throws Exception {
        // Given: No path info
        when(mockRequest.getPathInfo()).thenReturn(null);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Table ID không được rỗng"));

        verify(mockOrderService, never()).getOrdersByTable(any());
    }

    /**
     * TC-ERR-017: Get orders with empty path info (just slash)
     */
    @Test
    public void testGetSessionOrders_Error_EmptyPathInfo() throws Exception {
        // Given: Empty path info
        when(mockRequest.getPathInfo()).thenReturn("/");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Table ID không được rỗng"));

        verify(mockOrderService, never()).getOrdersByTable(any());
    }

    /**
     * TC-ERR-018: Get orders with invalid tableId format
     */
    @Test
    public void testGetSessionOrders_Error_InvalidTableIdFormat() throws Exception {
        // Given: Invalid UUID format
        String invalidTableId = "invalid-uuid-format";
        when(mockRequest.getPathInfo()).thenReturn("/" + invalidTableId);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Table ID không hợp lệ"));

        verify(mockOrderService, never()).getOrdersByTable(any());
    }

    /**
     * TC-ERR-019: Get orders with service throwing IllegalArgumentException
     */
    @Test
    public void testGetSessionOrders_Error_ServiceIllegalArgumentException() throws Exception {
        // Given: Service throws IllegalArgumentException
        String tableId = "323e4567-e89b-12d3-a456-426614174000";

        when(mockOrderService.getOrdersByTable(UUID.fromString(tableId)))
                .thenThrow(new IllegalArgumentException("Table ID không được null"));
        when(mockRequest.getPathInfo()).thenReturn("/" + tableId);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Table ID không được null"));
    }

    /**
     * TC-ERR-020: Get orders with service throwing general exception
     */
    @Test
    public void testGetSessionOrders_Error_ServiceException() throws Exception {
        // Given: Service throws runtime exception
        String tableId = "423e4567-e89b-12d3-a456-426614174000";

        when(mockOrderService.getOrdersByTable(UUID.fromString(tableId)))
                .thenThrow(new RuntimeException("Database connection failed"));
        when(mockRequest.getPathInfo()).thenReturn("/" + tableId);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Lỗi server"));
    }

    // ===========================================
    // HELPER METHODS
    // ===========================================

    /**
     * Create mock table orders data for testing
     */
    private List<Map<String, Object>> createMockTableOrders(int count) {
        List<Map<String, Object>> orders = new ArrayList<>();

        for (int i = 1; i <= count; i++) {
            Map<String, Object> order = new HashMap<>();
            order.put("orderId", UUID.randomUUID().toString());
            order.put("orderDetailId", UUID.randomUUID().toString());
            order.put("variantId", "variant-" + i);
            order.put("productId", UUID.randomUUID().toString());
            order.put("name", "Product " + i);
            order.put("size", "M");
            order.put("price", 45000.0 + (i * 5000));
            order.put("quantity", i);
            order.put("status", "Pending");
            order.put("note", "Test note " + i);

            orders.add(order);
        }

        return orders;
    }
}
