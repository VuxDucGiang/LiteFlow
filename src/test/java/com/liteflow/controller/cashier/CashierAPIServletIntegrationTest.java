package com.liteflow.controller.cashier;

import com.liteflow.controller.CashierAPIServlet;
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
 * Integration tests for CashierAPIServlet.
 *
 * Test Coverage:
 * - POST /api/cashier/order/create - Create order and notify kitchen
 * - POST /api/cashier/checkout - Process payment and close session
 * - GET /api/cashier/invoice/next-number - Get next invoice number
 * - GET /api/cashier/notification/history - Get notification history
 *
 * Strategy: Use Mockito to mock HTTP request/response and OrderService
 */
public class CashierAPIServletIntegrationTest extends IntegrationTestBase {

    /**
     * Testable wrapper for CashierAPIServlet to expose protected methods
     */
    private static class TestableCashierAPIServlet extends CashierAPIServlet {
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

        @Override
        public void doOptions(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            super.doOptions(request, response);
        }
    }

    private TestableCashierAPIServlet servlet;
    private OrderService mockOrderService;
    private HttpServletRequest mockRequest;
    private HttpServletResponse mockResponse;
    private StringWriter responseWriter;
    private PrintWriter responsePrintWriter;

    @BeforeEach
    public void setUpServlet() throws Exception {
        // Create servlet instance
        servlet = new TestableCashierAPIServlet();
        servlet.init();

        // Create mock OrderService
        mockOrderService = mock(OrderService.class);

        // Inject mock OrderService into servlet using reflection
        Field orderServiceField = CashierAPIServlet.class.getDeclaredField("orderService");
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
    // TEST CASES: handleCreateOrder() - POST /api/cashier/order/create
    // ===========================================

    /**
     * TC-HP-007: Create order successfully with valid data
     */
    @Test
    public void testCreateOrder_Success_WithValidData() throws Exception {
        // Given: Valid create order request
        String requestJson = """
                {
                    "tableId": "123e4567-e89b-12d3-a456-426614174000",
                    "items": [
                        {"variantId": "variant-001", "quantity": 2, "unitPrice": 45000, "note": "No sugar"}
                    ],
                    "invoiceName": "HD001",
                    "orderNote": "Quick service please"
                }
                """;

        UUID mockOrderId = UUID.randomUUID();
        Map<String, Object> mockOrderInfo = new HashMap<>();
        mockOrderInfo.put("orderId", mockOrderId);
        mockOrderInfo.put("orderNumber", "ORD20251031001");

        when(mockOrderService.createOrderAndNotifyKitchen(any(), any(), any(), any(), any()))
                .thenReturn(mockOrderInfo);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setStatus(HttpServletResponse.SC_CREATED);

        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));
        assertTrue(responseBody.contains("\"orderId\":\"ORD20251031001\""));
        assertTrue(responseBody.contains(mockOrderId.toString()));

        verify(mockOrderService, times(1)).createOrderAndNotifyKitchen(any(), any(), any(), eq("HD001"), eq("Quick service please"));
    }

    /**
     * TC-HP-008: Create order with special table (takeaway)
     */
    @Test
    public void testCreateOrder_Success_WithSpecialTableTakeaway() throws Exception {
        // Given: Takeaway order
        String requestJson = """
                {
                    "tableId": "takeaway",
                    "items": [
                        {"variantId": "variant-001", "quantity": 1, "unitPrice": 50000}
                    ],
                    "invoiceName": "HD002"
                }
                """;

        UUID mockOrderId = UUID.randomUUID();
        Map<String, Object> mockOrderInfo = new HashMap<>();
        mockOrderInfo.put("orderId", mockOrderId);
        mockOrderInfo.put("orderNumber", "ORD20251031002");

        when(mockOrderService.createOrderAndNotifyKitchen(isNull(), any(), any(), any(), any()))
                .thenReturn(mockOrderInfo);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_CREATED);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));

        // Verify tableId is null for special table
        verify(mockOrderService, times(1)).createOrderAndNotifyKitchen(isNull(), any(), any(), eq("HD002"), isNull());
    }

    /**
     * TC-HP-009: Create order with special table (delivery)
     */
    @Test
    public void testCreateOrder_Success_WithSpecialTableDelivery() throws Exception {
        // Given: Delivery order
        String requestJson = """
                {
                    "tableId": "delivery",
                    "items": [
                        {"variantId": "variant-001", "quantity": 3, "unitPrice": 35000}
                    ],
                    "invoiceName": "HD003"
                }
                """;

        UUID mockOrderId = UUID.randomUUID();
        Map<String, Object> mockOrderInfo = new HashMap<>();
        mockOrderInfo.put("orderId", mockOrderId);
        mockOrderInfo.put("orderNumber", "ORD20251031003");

        when(mockOrderService.createOrderAndNotifyKitchen(isNull(), any(), any(), any(), any()))
                .thenReturn(mockOrderInfo);

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_CREATED);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":true"));

        verify(mockOrderService, times(1)).createOrderAndNotifyKitchen(isNull(), any(), any(), eq("HD003"), isNull());
    }

    /**
     * TC-ERR-007: Create order with missing tableId
     */
    @Test
    public void testCreateOrder_Error_MissingTableId() throws Exception {
        // Given: Request without tableId
        String requestJson = """
                {
                    "items": [
                        {"variantId": "variant-001", "quantity": 2, "unitPrice": 45000}
                    ],
                    "invoiceName": "HD004"
                }
                """;

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Table ID"));

        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), any(), any(), any(), any());
    }

    /**
     * TC-ERR-008: Create order with empty items array
     */
    @Test
    public void testCreateOrder_Error_EmptyItems() throws Exception {
        // Given: Request with empty items
        String requestJson = """
                {
                    "tableId": "123e4567-e89b-12d3-a456-426614174000",
                    "items": [],
                    "invoiceName": "HD005"
                }
                """;

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));

        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), any(), any(), any(), any());
    }

    /**
     * TC-ERR-009: Create order with invalid tableId format
     */
    @Test
    public void testCreateOrder_Error_InvalidTableIdFormat() throws Exception {
        // Given: Request with invalid UUID
        String requestJson = """
                {
                    "tableId": "invalid-uuid-format",
                    "items": [
                        {"variantId": "variant-001", "quantity": 2, "unitPrice": 45000}
                    ],
                    "invoiceName": "HD006"
                }
                """;

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Table ID không hợp lệ"));

        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), any(), any(), any(), any());
    }

    /**
     * TC-ERR-010: Create order with service exception
     */
    @Test
    public void testCreateOrder_Error_ServiceException() throws Exception {
        // Given: Service throws exception
        String requestJson = """
                {
                    "tableId": "123e4567-e89b-12d3-a456-426614174000",
                    "items": [
                        {"variantId": "variant-001", "quantity": 2, "unitPrice": 45000}
                    ],
                    "invoiceName": "HD007"
                }
                """;

        when(mockOrderService.createOrderAndNotifyKitchen(any(), any(), any(), any(), any()))
                .thenThrow(new RuntimeException("Database connection failed"));

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Lỗi server"));
    }

    /**
     * TC-ERR-011: Create order with malformed JSON
     */
    @Test
    public void testCreateOrder_Error_MalformedJson() throws Exception {
        // Given: Invalid JSON
        String requestJson = "{invalid json content";

        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then: Malformed JSON is caught and returns 400 BAD_REQUEST
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));

        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), any(), any(), any(), any());
    }

    // ===========================================
    // TEST CASES: CORS Support - OPTIONS
    // ===========================================

    /**
     * TC-HP-010: OPTIONS request returns proper CORS headers
     */
    @Test
    public void testOptions_Success_CORSHeaders() throws Exception {
        // Given: OPTIONS request
        when(mockRequest.getPathInfo()).thenReturn("/order/create");

        // When
        servlet.doOptions(mockRequest, mockResponse);

        // Then
        verify(mockResponse).setHeader("Access-Control-Allow-Origin", "*");
        verify(mockResponse).setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        verify(mockResponse).setHeader("Access-Control-Allow-Headers", "Content-Type");
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);
    }

    // ===========================================
    // TEST CASES: Error Handling
    // ===========================================

    /**
     * TC-ERR-012: POST to invalid endpoint returns 404
     */
    @Test
    public void testPost_Error_InvalidEndpoint() throws Exception {
        // Given: Invalid endpoint
        String requestJson = "{}";
        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn("/invalid/endpoint");

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_NOT_FOUND);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Endpoint không tồn tại"));
    }

    /**
     * TC-ERR-013: POST without path info returns 400
     */
    @Test
    public void testPost_Error_MissingPathInfo() throws Exception {
        // Given: No path info
        String requestJson = "{}";
        BufferedReader reader = new BufferedReader(new StringReader(requestJson));
        when(mockRequest.getReader()).thenReturn(reader);
        when(mockRequest.getPathInfo()).thenReturn(null);

        // When
        servlet.doPost(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Thiếu path info"));
    }

    /**
     * TC-ERR-014: GET to invalid endpoint returns 404
     */
    @Test
    public void testGet_Error_InvalidEndpoint() throws Exception {
        // Given: Invalid GET endpoint
        when(mockRequest.getPathInfo()).thenReturn("/invalid/endpoint");

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_NOT_FOUND);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Endpoint không tồn tại"));
    }

    /**
     * TC-ERR-015: GET without path info returns 400
     */
    @Test
    public void testGet_Error_MissingPathInfo() throws Exception {
        // Given: No path info
        when(mockRequest.getPathInfo()).thenReturn(null);

        // When
        servlet.doGet(mockRequest, mockResponse);
        responsePrintWriter.flush();

        // Then
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String responseBody = responseWriter.toString();
        assertTrue(responseBody.contains("\"success\":false"));
        assertTrue(responseBody.contains("Thiếu path info"));
    }

    // Note: Tests for checkout, getNextInvoiceNumber, and getNotificationHistory
    // are not included here because they require database mocking which goes beyond
    // pure mock strategy. These would need IntegrationTestBase with H2 database
    // or more complex mocking setup with EntityManager mocks.
}
