package com.liteflow.controller;

import com.google.gson.Gson;
import com.liteflow.service.OrderService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for CreateOrderServlet
 * Tests order creation, validation, and kitchen notification functionality
 */
@DisplayName("CreateOrderServlet Tests")
class CreateOrderServletTest {

    private CreateOrderServlet servlet;
    
    @Mock
    private HttpServletRequest mockRequest;
    
    @Mock
    private HttpServletResponse mockResponse;
    
    @Mock
    private OrderService mockOrderService;
    
    private StringWriter responseWriter;
    private PrintWriter printWriter;
    private Gson gson;

    @BeforeEach
    void setUp() throws Exception {
        // Initialize mocks
        MockitoAnnotations.openMocks(this);
        
        // Initialize servlet
        servlet = new CreateOrderServlet();
        
        // Inject mocked OrderService using reflection
        Field orderServiceField = CreateOrderServlet.class.getDeclaredField("orderService");
        orderServiceField.setAccessible(true);
        orderServiceField.set(servlet, mockOrderService);
        
        // Setup response writer
        responseWriter = new StringWriter();
        printWriter = new PrintWriter(responseWriter);
        when(mockResponse.getWriter()).thenReturn(printWriter);
        
        // Initialize Gson for JSON parsing
        gson = new Gson();
    }

    /**
     * HAPPY PATH TESTS
     */

    @Test
    @DisplayName("Should create order successfully when valid data is provided")
    void should_createOrderSuccessfully_when_validDataProvided() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        UUID orderId = UUID.randomUUID();
        
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":2,\"unitPrice\":50000,\"note\":\"No onions\"}"
                + "]"
                + "}";
        
        BufferedReader reader = new BufferedReader(new StringReader(requestBody));
        when(mockRequest.getReader()).thenReturn(reader);
        
        // Mock order service
        when(mockOrderService.createOrderAndNotifyKitchen(eq(tableId), anyList(), any())).thenReturn(orderId);
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setCharacterEncoding("UTF-8");
        verify(mockOrderService).createOrderAndNotifyKitchen(eq(tableId), anyList(), any());
        verify(mockResponse).setStatus(HttpServletResponse.SC_CREATED);
        
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":true"));
        assertTrue(response.contains(orderId.toString()));
    }

    @Test
    @DisplayName("Should generate unique order ID when order is created")
    void should_generateOrderId_when_orderIsCreated() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        UUID orderId = UUID.randomUUID();
        
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(orderId);
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        verify(mockOrderService).createOrderAndNotifyKitchen(any(UUID.class), anyList(), any());
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains(orderId.toString()));
    }

    @Test
    @DisplayName("Should save multiple order items when multiple items are provided")
    void should_saveMultipleOrderItems_when_multipleItemsProvided() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":2,\"unitPrice\":50000,\"note\":\"Extra spicy\"},"
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"No sugar\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(UUID.randomUUID());
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        verify(mockOrderService).createOrderAndNotifyKitchen(any(UUID.class), argThat(items -> 
            items != null && items.size() == 2
        ), any());
    }

    @Test
    @DisplayName("Should send proper status code when order is created successfully")
    void should_sendProperStatusCode_when_orderCreatedSuccessfully() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":2,\"unitPrice\":50000,\"note\":\"\"},"
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":3,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(UUID.randomUUID());
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        verify(mockResponse).setStatus(HttpServletResponse.SC_CREATED);
        verify(mockOrderService).createOrderAndNotifyKitchen(any(UUID.class), anyList(), any());
    }

    /**
     * EDGE CASES
     */

    @Test
    @DisplayName("Should handle order with special characters in note when note contains special chars")
    void should_handleSpecialCharactersInNote_when_noteContainsSpecialChars() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        String specialNote = "Extra spicy! @#$%";
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":40000,"
                + "   \"note\":\"" + specialNote + "\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(UUID.randomUUID());
        
        // Act & Assert
        assertDoesNotThrow(() -> servlet.doPost(mockRequest, mockResponse));
        verify(mockOrderService).createOrderAndNotifyKitchen(any(UUID.class), anyList(), any());
    }

    @Test
    @DisplayName("Should handle empty note when note is not provided")
    void should_handleEmptyNote_when_noteIsNotProvided() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":25000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(UUID.randomUUID());
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        verify(mockOrderService).createOrderAndNotifyKitchen(any(UUID.class), anyList(), any());
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":true"));
    }

    @Test
    @DisplayName("Should handle maximum quantity when quantity is at limit")
    void should_handleMaximumQuantity_when_quantityIsAtLimit() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        int maxQuantity = 99;
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":" + maxQuantity + ",\"unitPrice\":10000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(UUID.randomUUID());
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        verify(mockOrderService).createOrderAndNotifyKitchen(any(UUID.class), argThat(items -> {
            @SuppressWarnings("unchecked")
            Map<String, Object> item = (Map<String, Object>) items.get(0);
            Double quantity = (Double) item.get("quantity");
            return quantity != null && quantity.intValue() == maxQuantity;
        }), any());
    }

    /**
     * ERROR SCENARIOS
     */

    @Test
    @DisplayName("Should return error when table ID is null")
    void should_returnError_when_tableIdIsNull() throws Exception {
        // Arrange
        String requestBody = "{"
                + "\"tableId\":null,"
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":false"));
        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), anyList(), any());
    }

    @Test
    @DisplayName("Should return error when items array is empty")
    void should_returnError_when_itemsArrayIsEmpty() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":[]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":false"));
        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), anyList(), any());
    }

    @Test
    @DisplayName("Should return error when table ID is invalid UUID format")
    void should_returnError_when_tableIdIsInvalidUUID() throws Exception {
        // Arrange
        String requestBody = "{"
                + "\"tableId\":\"not-a-valid-uuid\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":false"));
        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), anyList(), any());
    }

    @Test
    @DisplayName("Should return error when table ID is empty string")
    void should_returnError_when_tableIdIsEmptyString() throws Exception {
        // Arrange
        String requestBody = "{"
                + "\"tableId\":\"\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":false"));
        assertTrue(response.contains("Table ID"));
        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), anyList(), any());
    }

    @Test
    @DisplayName("Should handle service exception when order creation fails")
    void should_handleServiceException_when_orderCreationFails() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any()))
            .thenThrow(new RuntimeException("Database error"));
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":false"));
        verify(mockResponse).setStatus(500);
    }

    @Test
    @DisplayName("Should handle malformed JSON when request body is invalid")
    void should_handleMalformedJSON_when_requestBodyIsInvalid() throws Exception {
        // Arrange
        String malformedJson = "{\"tableId\":\"some-id\", invalid json }";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(malformedJson)));
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":false"));
        verify(mockOrderService, never()).createOrderAndNotifyKitchen(any(), anyList(), any());
    }

    @Test
    @DisplayName("Should handle IllegalArgumentException from service layer")
    void should_handleIllegalArgumentException_when_serviceThrowsValidationError() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any()))
            .thenThrow(new IllegalArgumentException("Validation failed: Invalid item"));
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        printWriter.flush();
        String response = responseWriter.toString();
        assertTrue(response.contains("\"success\":false"));
        assertTrue(response.contains("Validation failed"));
        verify(mockResponse).setStatus(400);
    }

    @Test
    @DisplayName("Should return JSON response format when request is processed")
    void should_returnJSONResponseFormat_when_requestIsProcessed() throws Exception {
        // Arrange
        UUID tableId = UUID.randomUUID();
        UUID orderId = UUID.randomUUID();
        String requestBody = "{"
                + "\"tableId\":\"" + tableId + "\","
                + "\"items\":["
                + "  {\"variantId\":\"" + UUID.randomUUID() + "\",\"quantity\":1,\"unitPrice\":30000,\"note\":\"\"}"
                + "]"
                + "}";
        
        when(mockRequest.getReader()).thenReturn(new BufferedReader(new StringReader(requestBody)));
        when(mockOrderService.createOrderAndNotifyKitchen(any(UUID.class), anyList(), any())).thenReturn(orderId);
        
        // Act
        servlet.doPost(mockRequest, mockResponse);
        
        // Assert
        verify(mockResponse).setContentType("application/json");
        verify(mockResponse).setCharacterEncoding("UTF-8");
        
        printWriter.flush();
        String response = responseWriter.toString();
        
        // Verify JSON structure
        @SuppressWarnings("unchecked")
        Map<String, Object> responseMap = gson.fromJson(response, Map.class);
        assertNotNull(responseMap);
        assertEquals(true, responseMap.get("success"));
        assertNotNull(responseMap.get("message"));
        assertNotNull(responseMap.get("orderId"));
    }
}

