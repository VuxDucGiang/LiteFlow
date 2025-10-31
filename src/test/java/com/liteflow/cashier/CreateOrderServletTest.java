package com.liteflow.cashier;

import com.liteflow.controller.CashierAPIServlet;
import com.liteflow.service.OrderService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.StringWriter;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.*;

import static com.liteflow.cashier.OrderTestHelper.*;

/**
 * Comprehensive test suite for CreateOrderServlet
 * Tests 20 scenarios: 4 Happy Path, 4 Edge Cases, 12 Error Scenarios (including 5 real-world)
 */
@ExtendWith(MockitoExtension.class)
class CreateOrderServletTest {

    @Mock
    private HttpServletRequest mockRequest;

    @Mock
    private HttpServletResponse mockResponse;

    @Mock
    private OrderService mockOrderService;

    private CashierAPIServlet servlet;
    private StringWriter responseWriter;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new CashierAPIServlet();
        // ✅ Gọi init() để khởi tạo gson
        servlet.init();
        // ✅ Sau đó inject mock service để override service thật
        injectOrderService(servlet, mockOrderService);
    }

    private void injectOrderService(CashierAPIServlet target, OrderService service) throws Exception {
        Field f = CashierAPIServlet.class.getDeclaredField("orderService");
        f.setAccessible(true);
        f.set(target, service);
    }

    private void callDoPost(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Method m = CashierAPIServlet.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        m.setAccessible(true);
        m.invoke(servlet, request, response);
    }

    private void callDoOptions(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Method m = CashierAPIServlet.class.getDeclaredMethod("doOptions", HttpServletRequest.class, HttpServletResponse.class);
        m.setAccessible(true);
        m.invoke(servlet, request, response);
    }

    // =========================
    // Happy Path (4 cases)
    // =========================

    @Test
    @DisplayName("TC-HP-001: should_createOrder_when_validSingleItem()")
    void should_createOrder_when_validSingleItem() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(itemWithNote("v-101", 2, 45000, "Ít đá"));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, DEFAULT_ORDER_ID);

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, DEFAULT_ORDER_ID);
        verifyServiceCalledOnce(mockOrderService);
    }

    @Test
    @DisplayName("TC-HP-002: should_createOrder_when_multipleItems()")
    void should_createOrder_when_multipleItems() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(
                basicItem("v-201", 1, 30000),
                basicItem("v-202", 3, 55000),
                itemWithNote("v-203", 2, 40000, "ít cay")
        );
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, generateTestUUID());

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, null);
        verifyServiceCalledOnce(mockOrderService);
    }

    @Test
    @DisplayName("TC-HP-003: should_createOrder_when_deltaOnlyItemsProvided()")
    void should_createOrder_when_deltaOnlyItemsProvided() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(basicItem("v-302", 1, 55000));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, generateTestUUID());

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, null);
    }

    @Test
    @DisplayName("TC-HP-004: should_setCORSHeaders_when_options()")
    void should_setCORSHeaders_when_options() throws Exception {
        // Act
        callDoOptions(mockRequest, mockResponse);

        // Assert
        verifyCORSHeaders(mockResponse);
    }

    // =========================
    // Edge Cases (4 cases)
    // =========================

    @Test
    @DisplayName("TC-EDGE-001: should_acceptLongUnicodeNote_when_valid()")
    void should_acceptLongUnicodeNote_when_valid() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(itemWithLongUnicodeNote("v-501"));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, generateTestUUID());

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, null);
    }

    @Test
    @DisplayName("TC-EDGE-002: should_createLargeOrder_when_manyItems()")
    void should_createLargeOrder_when_manyItems() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = generateMultipleItems(50);
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, generateTestUUID());

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, null);
    }

    @Test
    @DisplayName("TC-EDGE-003: should_acceptMissingOptionalNote_when_valid()")
    void should_acceptMissingOptionalNote_when_valid() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(basicItem("v-701", 2, 35000));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, generateTestUUID());

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, null);
    }

    @Test
    @DisplayName("TC-EDGE-004: should_acceptDecimalPrice_when_valid()")
    void should_acceptDecimalPrice_when_valid() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(
                OrderItemBuilder.create().variantId("v-704").quantity(1).unitPrice(45000.75)
        );
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, generateTestUUID());

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, null);
    }

    // =========================
    // Error Scenarios (12 cases)
    // =========================

    @Test
    @DisplayName("TC-ERR-001: should_return400_when_tableIdMissing()")
    void should_return400_when_tableIdMissing() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        String invalidJson = buildInvalidOrderJson(null, "[{\"variantId\":\"v-801\",\"quantity\":1,\"unitPrice\":20000}]");
        prepareRequestBody(mockRequest, invalidJson);

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Table ID không được rỗng");
        verifyServiceNeverCalled(mockOrderService);
    }

    @Test
    @DisplayName("TC-ERR-002: should_return400_when_tableIdEmpty()")
    void should_return400_when_tableIdEmpty() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        String invalidJson = "{\"tableId\":\"\",\"items\":[{\"variantId\":\"v-802\",\"quantity\":1,\"unitPrice\":20000}]}";
        prepareRequestBody(mockRequest, invalidJson);

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Table ID không được rỗng");
        verifyServiceNeverCalled(mockOrderService);
    }

    @Test
    @DisplayName("TC-ERR-003: should_return400_when_tableIdInvalidUUID()")
    void should_return400_when_tableIdInvalidUUID() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(basicItem("v-803", 1, 20000));
        String invalidJson = buildOrderJson("table1", items);
        prepareRequestBody(mockRequest, invalidJson);

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Table ID không hợp lệ: table1");
        verifyServiceNeverCalled(mockOrderService);
    }

    @Test
    @DisplayName("TC-ERR-004: should_return400_when_itemsMissing()")
    void should_return400_when_itemsMissing() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        String invalidJson = buildInvalidOrderJson("\"" + VALID_TABLE_ID + "\"", null);
        prepareRequestBody(mockRequest, invalidJson);

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Danh sách món không được rỗng");
        verifyServiceNeverCalled(mockOrderService);
    }

    @Test
    @DisplayName("TC-ERR-005: should_return400_when_itemsEmptyArray()")
    void should_return400_when_itemsEmptyArray() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        String invalidJson = buildInvalidOrderJson("\"" + VALID_TABLE_ID + "\"", "[]");
        prepareRequestBody(mockRequest, invalidJson);

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Danh sách món không được rỗng");
        verifyServiceNeverCalled(mockOrderService);
    }

    @Test
    @DisplayName("TC-ERR-006: should_return400_when_malformedJson()")
    void should_return400_when_malformedJson() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        String malformedJson = buildMalformedJson(VALID_TABLE_ID);
        prepareRequestBody(mockRequest, malformedJson);

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        // ✅ Malformed JSON được handle như bad request (400), không phải server error (500)
        assertBadRequestResponse(mockResponse, responseWriter, "Request body không hợp lệ");
        verifyServiceNeverCalled(mockOrderService);
    }

    @Test
    @DisplayName("TC-ERR-007: should_return400_when_requestBodyIsJsonNullLiteral()")
    void should_return400_when_requestBodyIsJsonNullLiteral() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        prepareRequestBody(mockRequest, "null");

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Request body không hợp lệ");
        verifyServiceNeverCalled(mockOrderService);
    }

    @Test
    @DisplayName("TC-ERR-008: should_return500_when_serviceThrowsRuntimeException()")
    void should_return500_when_serviceThrowsRuntimeException() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(basicItem("v-900", 1, 10000));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockServiceRuntimeError(mockOrderService, "DB down");

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertServerErrorResponse(mockResponse, responseWriter, "Lỗi server");
    }

    // =========================
    // Real-World Scenarios (5 cases)
    // =========================

    @Test
    @DisplayName("TC-REAL-001: should_rejectOrder_when_priceIsNegative()")
    void should_rejectOrder_when_priceIsNegative() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(itemWithNegativePrice("v-1001", 2, -50000));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockServiceValidationError(mockOrderService, "Giá món không hợp lệ");

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Giá món không hợp lệ");
    }

    @Test
    @DisplayName("TC-REAL-002: should_rejectOrder_when_noteContainsSQLInjectionLikePatterns()")
    void should_rejectOrder_when_noteContainsSQLInjectionLikePatterns() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(itemWithSQLInjectionNote("v-1002"));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockServiceValidationError(mockOrderService, "Ghi chú không hợp lệ");

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Ghi chú không hợp lệ");
    }

    @Test
    @DisplayName("TC-REAL-003: should_acceptUnicodeEmojiNotes_when_valid()")
    void should_acceptUnicodeEmojiNotes_when_valid() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        String note = "Không hành, ít đường 😊😊😊 – làm nhanh giúp bàn VIP Tầng 2";
        List<OrderItemBuilder> items = Arrays.asList(itemWithNote("v-1003", 1, 60000, note));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockSuccessfulOrderCreation(mockOrderService, generateTestUUID());

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertSuccessResponse(mockResponse, responseWriter, null);
    }

    @Test
    @DisplayName("TC-REAL-004: should_return400_when_quantityIsString()")
    void should_return400_when_quantityIsString() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(itemWithStringQuantity("v-2001", "2", 45000));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockServiceValidationError(mockOrderService, "Kiểu dữ liệu không hợp lệ");

        // Act
        callDoPost(mockRequest, mockResponse);

        // Assert
        assertBadRequestResponse(mockResponse, responseWriter, "Kiểu dữ liệu không hợp lệ");
    }

    @Test
    @DisplayName("TC-REAL-005: should_handleDoubleClickSubmittingTwice()")
    void should_handleDoubleClickSubmittingTwice() throws Exception {
        // Arrange
        responseWriter = setupResponseWriter(mockResponse);
        List<OrderItemBuilder> items = Arrays.asList(basicItem("v-dup", 1, 30000));
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);
        mockServiceForDuplicateDetection(mockOrderService, DEFAULT_ORDER_ID, "Duplicate request");

        // Act - First call succeeds
        callDoPost(mockRequest, mockResponse);
        assertSuccessResponse(mockResponse, responseWriter, DEFAULT_ORDER_ID);

        // Reset for second call
        responseWriter = resetResponseWriter(mockResponse);
        prepareOrderRequest(mockRequest, VALID_TABLE_UUID, items);

        // Act - Second call fails
        callDoPost(mockRequest, mockResponse);

        // Assert   `
        assertBadRequestResponse(mockResponse, responseWriter, "Duplicate request");
    }
}
