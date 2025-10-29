package com.liteflow.cashier;

import com.google.gson.Gson;
import com.liteflow.service.OrderService;
import com.liteflow.util.OrderDataUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mockito.Mockito;

import java.io.*;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Test helper utilities for CreateOrderServlet testing
 * Provides reusable methods for mock setup, data generation, and assertions
 */
@SuppressWarnings("unchecked")
public class OrderTestHelper {

    private static final Gson gson = new Gson();

    // =========================
    // Constants
    // =========================

    public static final String VALID_TABLE_ID = "0a4e5d60-9a55-4a55-a7d5-2f1f7f5b1a11";
    public static final UUID VALID_TABLE_UUID = UUID.fromString(VALID_TABLE_ID);
    public static final UUID DEFAULT_ORDER_ID = UUID.fromString("11111111-1111-1111-1111-111111111111");

    // =========================
    // Mock Request/Response Helpers
    // =========================

    /**
     * Prepare mock request with JSON body
     */
    public static void prepareRequestBody(HttpServletRequest mockRequest, String jsonBody) throws IOException {
        BufferedReader reader = new BufferedReader(new StringReader(jsonBody));
        when(mockRequest.getReader()).thenReturn(reader);
        // ✅ Mock pathInfo for CashierAPIServlet routing
        when(mockRequest.getPathInfo()).thenReturn("/order/create");
    }

    /**
     * Prepare request with order data (table + items)
     */
    public static void prepareOrderRequest(HttpServletRequest mockRequest, String tableId, 
                                          List<OrderItemBuilder> items) throws IOException {
        String json = buildOrderJson(tableId, items);
        prepareRequestBody(mockRequest, json);
        // Mock pathInfo for CashierAPIServlet routing
        when(mockRequest.getPathInfo()).thenReturn("/order/create");
    }

    /**
     * Prepare request with order data using UUID
     */
    public static void prepareOrderRequest(HttpServletRequest mockRequest, UUID tableId, 
                                          List<OrderItemBuilder> items) throws IOException {
        prepareOrderRequest(mockRequest, tableId.toString(), items);
    }

    /**
     * Create StringWriter for capturing response
     */
    public static StringWriter setupResponseWriter(HttpServletResponse mockResponse) throws IOException {
        StringWriter responseWriter = new StringWriter();
        when(mockResponse.getWriter()).thenReturn(new PrintWriter(responseWriter, true));
        return responseWriter;
    }

    /**
     * Reset response writer for multiple calls in same test
     */
    public static StringWriter resetResponseWriter(HttpServletResponse mockResponse) throws IOException {
        StringWriter responseWriter = new StringWriter();
        Mockito.reset(mockResponse);
        when(mockResponse.getWriter()).thenReturn(new PrintWriter(responseWriter, true));
        return responseWriter;
    }

    // =========================
    // JSON Builders
    // =========================

    /**
     * Build complete order JSON
     */
    public static String buildOrderJson(String tableId, List<OrderItemBuilder> items) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"tableId\":\"").append(tableId).append("\",");
        sb.append("\"items\":[");
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(items.get(i).toJson());
        }
        sb.append("]}");
        return sb.toString();
    }

    /**
     * Build order JSON with invalid/missing fields
     */
    public static String buildInvalidOrderJson(String tableIdField, String itemsField) {
        StringBuilder sb = new StringBuilder("{");
        if (tableIdField != null) {
            sb.append("\"tableId\":").append(tableIdField);
        }
        if (itemsField != null) {
            if (tableIdField != null) sb.append(",");
            sb.append("\"items\":").append(itemsField);
        }
        sb.append("}");
        return sb.toString();
    }

    /**
     * Build malformed JSON for error testing
     */
    public static String buildMalformedJson(String tableId) {
        return "{ \"tableId\": \"" + tableId + "\", \"items\": ["; // Missing closing brackets
    }

    // =========================
    // Mock Service Behavior Helpers
    // =========================

    /**
     * Setup successful order creation
     */
    public static void mockSuccessfulOrderCreation(OrderService mockService, UUID orderId) {
        // ✅ createOrderAndNotifyKitchen bây giờ trả về Map<String, Object>
        Map<String, Object> orderInfo = new HashMap<>();
        orderInfo.put("orderId", orderId);
        orderInfo.put("orderNumber", "ORD-" + orderId.toString().substring(0, 8));
        
        // ✅ Dùng nullable() thay vì anyString() để match với null
        when(mockService.createOrderAndNotifyKitchen(any(UUID.class), any(List.class), any(), nullable(String.class), nullable(String.class)))
                .thenReturn(orderInfo);
    }

    /**
     * Setup service to throw validation error
     */
    public static void mockServiceValidationError(OrderService mockService, String errorMessage) {
        // ✅ Dùng nullable() thay vì anyString() để match với null
        when(mockService.createOrderAndNotifyKitchen(any(UUID.class), any(List.class), any(), nullable(String.class), nullable(String.class)))
                .thenThrow(new IllegalArgumentException(errorMessage));
    }

    /**
     * Setup service to throw runtime error
     */
    public static void mockServiceRuntimeError(OrderService mockService, String errorMessage) {
        // ✅ Dùng nullable() thay vì anyString() để match với null
        when(mockService.createOrderAndNotifyKitchen(any(UUID.class), any(List.class), any(), nullable(String.class), nullable(String.class)))
                .thenThrow(new RuntimeException(errorMessage));
    }

    /**
     * Setup service to handle multiple calls (for double-click test)
     */
    public static void mockServiceForDuplicateDetection(OrderService mockService, 
                                                       UUID firstOrderId, String duplicateMessage) {
        // ✅ createOrderAndNotifyKitchen bây giờ trả về Map<String, Object>
        Map<String, Object> orderInfo = new HashMap<>();
        orderInfo.put("orderId", firstOrderId);
        orderInfo.put("orderNumber", "ORD-" + firstOrderId.toString().substring(0, 8));
        
        // ✅ Dùng nullable() thay vì anyString() để match với null
        when(mockService.createOrderAndNotifyKitchen(any(UUID.class), any(List.class), any(), nullable(String.class), nullable(String.class)))
                .thenReturn(orderInfo)
                .thenThrow(new IllegalArgumentException(duplicateMessage));
    }

    // =========================
    // Response Assertion Helpers
    // =========================

    /**
     * Assert successful response (201 Created)
     */
    public static void assertSuccessResponse(HttpServletResponse mockResponse, 
                                            StringWriter responseWriter, UUID expectedOrderId) {
        verify(mockResponse).setStatus(HttpServletResponse.SC_CREATED);
        Map<?, ?> map = parseResponse(responseWriter);
        assertThat(map.get("success")).isEqualTo(true);
        assertThat((String) map.get("message")).contains("Đã gửi thông báo đến bếp thành công");
        if (expectedOrderId != null) {
            // ✅ Response trả về orderIdUUID (UUID) và orderId (orderNumber)
            assertThat((String) map.get("orderIdUUID")).isEqualTo(expectedOrderId.toString());
            // ✅ Verify orderNumber có format đúng (ORD-xxxxxxxx)
            assertThat((String) map.get("orderId")).matches("ORD-[0-9a-f]{8}");
        }
    }

    /**
     * Assert error response (400 Bad Request)
     */
    public static void assertBadRequestResponse(HttpServletResponse mockResponse, 
                                               StringWriter responseWriter, String expectedMessageFragment) {
        verify(mockResponse).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        Map<?, ?> map = parseResponse(responseWriter);
        assertThat(map.get("success")).isEqualTo(false);
        assertThat((String) map.get("message")).contains(expectedMessageFragment);
    }

    /**
     * Assert server error response (500 Internal Server Error)
     */
    public static void assertServerErrorResponse(HttpServletResponse mockResponse, 
                                                StringWriter responseWriter, String expectedMessageFragment) {
        verify(mockResponse).setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        Map<?, ?> map = parseResponse(responseWriter);
        assertThat(map.get("success")).isEqualTo(false);
        assertThat((String) map.get("message")).contains(expectedMessageFragment);
    }

    /**
     * Parse JSON response
     */
    public static Map<?, ?> parseResponse(StringWriter responseWriter) {
        String json = responseWriter.toString();
        return gson.fromJson(json, Map.class);
    }

    // =========================
    // UUID Helpers
    // =========================

    /**
     * Generate random UUID for testing
     */
    public static UUID generateTestUUID() {
        return OrderDataUtil.generateTestUUID();
    }

    /**
     * Generate deterministic UUID for testing (based on seed)
     */
    public static UUID generateTestUUID(int seed) {
        return OrderDataUtil.generateTestUUID(seed);
    }

    /**
     * Validate UUID format
     */
    public static boolean isValidUUID(String uuid) {
        return OrderDataUtil.isValidUUID(uuid);
    }

    // =========================
    // Test Data Builders
    // =========================

    /**
     * Builder for order items with fluent API
     */
    public static class OrderItemBuilder {
        private String variantId;
        private Object quantity; // Can be int or String for testing
        private Object unitPrice; // Can be double or String for testing
        private String note;

        public static OrderItemBuilder create() {
            return new OrderItemBuilder();
        }

        public OrderItemBuilder variantId(String variantId) {
            this.variantId = variantId;
            return this;
        }

        public OrderItemBuilder quantity(int quantity) {
            this.quantity = quantity;
            return this;
        }

        public OrderItemBuilder quantityAsString(String quantity) {
            this.quantity = quantity;
            return this;
        }

        public OrderItemBuilder unitPrice(double unitPrice) {
            this.unitPrice = unitPrice;
            return this;
        }

        public OrderItemBuilder unitPriceAsString(String unitPrice) {
            this.unitPrice = unitPrice;
            return this;
        }

        public OrderItemBuilder note(String note) {
            this.note = note;
            return this;
        }

        public String toJson() {
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"variantId\":\"").append(variantId).append("\"");
            
            if (quantity != null) {
                sb.append(",\"quantity\":");
                if (quantity instanceof String) {
                    sb.append("\"").append(quantity).append("\"");
                } else {
                    sb.append(quantity);
                }
            }
            
            if (unitPrice != null) {
                sb.append(",\"unitPrice\":");
                if (unitPrice instanceof String) {
                    sb.append("\"").append(unitPrice).append("\"");
                } else {
                    sb.append(unitPrice);
                }
            }
            
            if (note != null) {
                // Escape quotes in note
                String escapedNote = note.replace("\"", "\\\"");
                sb.append(",\"note\":\"").append(escapedNote).append("\"");
            }
            
            sb.append("}");
            return sb.toString();
        }
    }

    // =========================
    // Quick Builder Methods
    // =========================

    /**
     * Create basic item without note
     */
    public static OrderItemBuilder basicItem(String variantId, int quantity, double price) {
        return OrderItemBuilder.create()
                .variantId(variantId)
                .quantity(quantity)
                .unitPrice(price);
    }

    /**
     * Create item with note
     */
    public static OrderItemBuilder itemWithNote(String variantId, int quantity, double price, String note) {
        return OrderItemBuilder.create()
                .variantId(variantId)
                .quantity(quantity)
                .unitPrice(price)
                .note(note);
    }

    /**
     * Create item with negative price for security testing
     */
    public static OrderItemBuilder itemWithNegativePrice(String variantId, int quantity, double price) {
        return OrderItemBuilder.create()
                .variantId(variantId)
                .quantity(quantity)
                .unitPrice(price);
    }

    /**
     * Generate multiple test items for bulk testing
     */
    public static List<OrderItemBuilder> generateMultipleItems(int count) {
        List<OrderItemBuilder> items = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            items.add(basicItem("v-" + (8000 + i), 1, 10000));
        }
        return items;
    }

    /**
     * Generate item with long unicode note for emoji/encoding testing
     */
    public static OrderItemBuilder itemWithLongUnicodeNote(String variantId) {
        String longNoteBase = "Không hành, ít đường 😊 – làm nhanh giúp bàn VIP Tầng 2. ";
        StringBuilder note = new StringBuilder();
        for (int i = 0; i < 20; i++) note.append(longNoteBase);
        return itemWithNote(variantId, 1, 60000, note.toString());
    }

    /**
     * Generate item with SQL injection pattern in note
     */
    public static OrderItemBuilder itemWithSQLInjectionNote(String variantId) {
        return itemWithNote(variantId, 1, 50000, "\") DROP TABLE orders; -- 😊");
    }

    /**
     * Generate item with quantity as string (type mismatch test)
     */
    public static OrderItemBuilder itemWithStringQuantity(String variantId, String quantity, double price) {
        return OrderItemBuilder.create()
                .variantId(variantId)
                .quantityAsString(quantity)
                .unitPrice(price);
    }

    /**
     * Generate item with price as string (type mismatch test)
     */
    public static OrderItemBuilder itemWithStringPrice(String variantId, int quantity, String price) {
        return OrderItemBuilder.create()
                .variantId(variantId)
                .quantity(quantity)
                .unitPriceAsString(price);
    }

    // =========================
    // Verification Helpers
    // =========================

    /**
     * Verify service was never called (for validation error tests)
     */
    public static void verifyServiceNeverCalled(OrderService mockService) {
        // ✅ Dùng nullable() thay vì anyString() để match với null
        verify(mockService, never()).createOrderAndNotifyKitchen(any(), any(), any(), nullable(String.class), nullable(String.class));
    }

    /**
     * Verify service was called exactly once
     */
    public static void verifyServiceCalledOnce(OrderService mockService) {
        // ✅ Dùng nullable() thay vì anyString() để match với null
        verify(mockService, times(1)).createOrderAndNotifyKitchen(any(UUID.class), any(List.class), any(), nullable(String.class), nullable(String.class));
    }

    /**
     * Verify CORS headers are set correctly
     */
    public static void verifyCORSHeaders(HttpServletResponse mockResponse) {
        verify(mockResponse).setHeader("Access-Control-Allow-Origin", "*");
        // ✅ CashierAPIServlet sử dụng "GET, POST, OPTIONS" không phải "POST, OPTIONS"
        verify(mockResponse).setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        verify(mockResponse).setHeader("Access-Control-Allow-Headers", "Content-Type");
        verify(mockResponse).setStatus(HttpServletResponse.SC_OK);
    }
}

