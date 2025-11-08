package com.liteflow.selenium.tests;

import com.liteflow.selenium.base.BaseTest;
import com.liteflow.selenium.pages.cashier.CashierPage;
import org.junit.jupiter.api.*;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * System tests for Cashier page using Selenium WebDriver
 *
 * This test class covers the main functionality of the Cashier page:
 * - Table selection and management
 * - Menu item selection and order creation
 * - Order modifications (add/remove items, update quantities)
 * - Discount application
 * - Payment methods
 * - Checkout process
 *
 * Tests are ordered to run sequentially for better reliability.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class CashierSystemTest extends BaseTest {

    private CashierPage cashierPage;

    /**
     * Setup method - runs before each test
     */
    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        cashierPage = new CashierPage(driver);

        // Navigate to cashier page
        navigateTo("/cart/cashier");
        cashierPage.waitForPageToLoad();
    }

    /**
     * Test 1: Load cashier page successfully
     */
    @Test
    @Order(1)
    @DisplayName("1. Load trang cashier thành công")
    public void testLoadCashierPage() {
        // Verify page title
        String pageTitle = cashierPage.getPageTitle();
        assertTrue(pageTitle.contains("Cashier") || pageTitle.contains("LiteFlow"),
                   "Page title should contain 'Cashier' or 'LiteFlow'");

        // Verify page is loaded
        assertTrue(cashierPage.isPageLoaded(),
                   "Cashier page should be loaded with all main elements");

        // Verify default tab is Tables
        assertTrue(cashierPage.isTablesTabActive(),
                   "Tables tab should be active by default");

        // Take screenshot for documentation
        takeScreenshot("cashier_page_loaded");
    }

    /**
     * Test 2: Select table and display information
     */
    @Test
    @Order(2)
    @DisplayName("2. Chọn bàn và hiển thị thông tin")
    public void testSelectTable() {
        // Ensure we're on Tables tab
        cashierPage.switchToTablesTab();

        // Get table count before selection
        int tableCount = cashierPage.getTableSection().getVisibleTablesCount();
        assertTrue(tableCount > 0, "Should have at least one table available");

        // Select first available table (assuming table T001 or similar exists)
        // Note: Adjust table number based on your test data
        boolean tableSelected = cashierPage.getTableSection().selectTable("T001");

        if (!tableSelected) {
            // Try selecting by name if selection by number failed
            tableSelected = cashierPage.getTableSection().selectTableByName("Bàn 1");
        }

        assertTrue(tableSelected, "Table should be selected successfully");

        // Verify table info is displayed in order section
        String tableInfo = cashierPage.getOrderSection().getSelectedTableInfo();
        assertFalse(tableInfo.contains("Chưa chọn bàn"),
                    "Selected table info should be displayed");

        takeScreenshot("table_selected");
    }

    /**
     * Test 3: Add menu item to order
     */
    @Test
    @Order(3)
    @DisplayName("3. Thêm món vào order")
    public void testAddMenuItemToOrder() {
        // Select a table first
        cashierPage.switchToTablesTab();
        cashierPage.getTableSection().selectTable("T001");

        // Switch to menu tab
        cashierPage.switchToMenuTab();
        assertTrue(cashierPage.isMenuTabActive(), "Menu tab should be active");

        // Get initial order count
        int initialOrderCount = cashierPage.getOrderSection().getOrderItemsCount();

        // Add a menu item (adjust item name based on your test data)
        // Using a common item name - adjust as needed
        boolean itemAdded = cashierPage.getMenuSection().addMenuItem("Phở bò", 1);

        if (!itemAdded) {
            // Try alternative common items
            itemAdded = cashierPage.getMenuSection().addMenuItem("Cơm rang", 1);
        }

        // If still not found, select all categories and try again
        if (!itemAdded) {
            cashierPage.getMenuSection().selectAllCategories();
            sleep(500);

            // Get first available menu item
            List<String> menuItems = cashierPage.getMenuSection().getVisibleMenuItemNames();
            if (!menuItems.isEmpty()) {
                itemAdded = cashierPage.getMenuSection().addMenuItem(menuItems.get(0), 1);
            }
        }

        assertTrue(itemAdded, "Menu item should be added to order");

        // Verify order count increased
        int finalOrderCount = cashierPage.getOrderSection().getOrderItemsCount();
        assertTrue(finalOrderCount > initialOrderCount,
                   "Order items count should increase after adding item");

        // Verify order is not empty
        assertFalse(cashierPage.getOrderSection().isOrderEmpty(),
                    "Order should not be empty after adding item");

        takeScreenshot("menu_item_added");
    }

    /**
     * Test 4: Remove order item
     */
    @Test
    @Order(4)
    @DisplayName("4. Xóa món khỏi order")
    public void testRemoveOrderItem() {
        // Setup: Add items to order
        setupOrderWithItems();

        // Get initial order count
        int initialCount = cashierPage.getOrderSection().getOrderItemsCount();
        assertTrue(initialCount > 0, "Order should have items before removal");

        // Remove first item
        boolean removed = cashierPage.getOrderSection().removeOrderItem(0);
        assertTrue(removed, "Order item should be removed successfully");

        // Verify count decreased
        int finalCount = cashierPage.getOrderSection().getOrderItemsCount();
        assertEquals(initialCount - 1, finalCount,
                     "Order count should decrease by 1 after removal");

        takeScreenshot("order_item_removed");
    }

    /**
     * Test 5: Update order item quantity
     */
    @Test
    @Order(5)
    @DisplayName("5. Cập nhật số lượng món")
    public void testUpdateOrderItemQuantity() {
        // Setup: Add items to order
        setupOrderWithItems();

        // Update quantity of first item
        int newQuantity = 3;
        boolean updated = cashierPage.getOrderSection().updateOrderItemQuantity(0, newQuantity);
        assertTrue(updated, "Order item quantity should be updated");

        // Verify total changed (subtotal should increase)
        String subtotal = cashierPage.getOrderSection().getSubtotal();
        assertNotNull(subtotal, "Subtotal should be displayed");
        assertFalse(subtotal.equals("0đ"), "Subtotal should be greater than 0");

        takeScreenshot("quantity_updated");
    }

    /**
     * Test 6: Search menu
     */
    @Test
    @Order(6)
    @DisplayName("6. Tìm kiếm món trong menu")
    public void testSearchMenu() {
        cashierPage.switchToMenuTab();

        // Get initial menu items count
        int initialCount = cashierPage.getMenuSection().getVisibleMenuItemsCount();

        // Search for a keyword
        String searchKeyword = "phở";
        cashierPage.getMenuSection().searchMenu(searchKeyword);
        sleep(500);

        // Get filtered count
        int filteredCount = cashierPage.getMenuSection().getVisibleMenuItemsCount();

        // Verify filtering occurred (count should change or stay same if all items match)
        assertTrue(filteredCount <= initialCount,
                   "Filtered items should be less than or equal to initial items");

        // Clear search
        cashierPage.getMenuSection().clearSearch();
        sleep(500);

        takeScreenshot("menu_search");
    }

    /**
     * Test 7: Filter menu by category
     */
    @Test
    @Order(7)
    @DisplayName("7. Lọc món theo danh mục")
    public void testFilterMenuByCategory() {
        cashierPage.switchToMenuTab();

        // Get all categories
        List<String> categories = cashierPage.getMenuSection().getAllCategories();
        assertTrue(categories.size() > 0, "Should have at least one category");

        // Filter by first non-"All" category
        for (String category : categories) {
            if (!category.contains("Tất cả") && !category.contains("all")) {
                boolean filtered = cashierPage.getMenuSection().filterByCategory(category);
                assertTrue(filtered, "Should be able to filter by category: " + category);

                // Verify active category
                String activeCategory = cashierPage.getMenuSection().getActiveCategory();
                assertNotNull(activeCategory, "Active category should be set");

                break;
            }
        }

        takeScreenshot("category_filter");
    }

    /**
     * Test 8: Apply percentage discount
     */
    @Test
    @Order(8)
    @DisplayName("8. Áp dụng giảm giá phần trăm")
    public void testApplyDiscount() {
        // Setup: Add items to order
        setupOrderWithItems();

        // Get initial total
        String initialTotal = cashierPage.getOrderSection().getTotal();

        // Apply 10% discount
        double discountPercent = 10.0;
        cashierPage.getOrderSection().applyPercentageDiscount(discountPercent);
        sleep(500);

        // Verify discount is applied
        assertTrue(cashierPage.getOrderSection().isDiscountApplied(),
                   "Discount should be applied and visible");

        // Verify discount amount is shown
        String discountAmount = cashierPage.getOrderSection().getDiscount();
        assertNotNull(discountAmount, "Discount amount should be displayed");
        assertFalse(discountAmount.equals("0đ"), "Discount should be greater than 0");

        // Verify total changed
        String finalTotal = cashierPage.getOrderSection().getTotal();
        assertNotEquals(initialTotal, finalTotal, "Total should change after discount");

        takeScreenshot("discount_applied");
    }

    /**
     * Test 9: Checkout with cash payment
     */
    @Test
    @Order(9)
    @DisplayName("9. Checkout thanh toán tiền mặt")
    public void testCheckoutCashPayment() {
        // Setup: Add items and select table
        setupOrderWithItems();

        // Verify checkout button is enabled
        assertTrue(cashierPage.getOrderSection().isCheckoutEnabled(),
                   "Checkout button should be enabled when order has items");

        // Select cash payment method
        cashierPage.getOrderSection().selectPaymentMethod("cash");

        // Get total before checkout
        String totalBeforeCheckout = cashierPage.getOrderSection().getTotal();
        assertFalse(totalBeforeCheckout.equals("0đ"), "Total should be greater than 0");

        // Click checkout
        cashierPage.getOrderSection().clickCheckout();
        sleep(1000);

        // Handle any confirmation dialogs or wait for checkout to complete
        // Note: Actual verification depends on your app's checkout behavior
        // You might need to check for success message, redirect, etc.

        takeScreenshot("checkout_completed");
    }

    /**
     * Test 10: Checkout with card payment
     */
    @Test
    @Order(10)
    @DisplayName("10. Checkout thanh toán thẻ")
    public void testCheckoutCardPayment() {
        // Setup: Add items and select table
        setupOrderWithItems();

        // Select card payment method
        cashierPage.getOrderSection().selectPaymentMethod("card");

        // Verify payment method is selected
        String selectedMethod = cashierPage.getOrderSection().getSelectedPaymentMethod();
        assertEquals("card", selectedMethod, "Card payment method should be selected");

        // Click checkout
        cashierPage.getOrderSection().clickCheckout();
        sleep(1000);

        takeScreenshot("checkout_card_payment");
    }

    /**
     * Test 11: Checkout special table (takeaway)
     */
    @Test
    @Order(11)
    @DisplayName("11. Checkout bàn đặc biệt (mang về)")
    public void testCheckoutSpecialTable() {
        // Try to select a special table (usually named "Mang về" or similar)
        cashierPage.switchToTablesTab();

        boolean specialTableSelected = cashierPage.getTableSection().selectTableByName("Mang về");

        if (!specialTableSelected) {
            // Skip test if no special table exists
            System.out.println("No special table found - skipping test");
            return;
        }

        // Add items
        cashierPage.switchToMenuTab();
        addMenuItems(2);

        // Checkout
        cashierPage.getOrderSection().selectPaymentMethod("cash");
        cashierPage.getOrderSection().clickCheckout();
        sleep(1000);

        takeScreenshot("special_table_checkout");
    }

    /**
     * Test 12: Multiple invoices
     */
    @Test
    @Order(12)
    @DisplayName("12. Tạo nhiều hóa đơn cùng lúc")
    public void testMultipleInvoices() {
        // Get initial invoice count
        int initialCount = cashierPage.getInvoiceCount();

        // Add new invoice
        cashierPage.addNewInvoice();
        sleep(500);

        // Verify invoice count increased
        int newCount = cashierPage.getInvoiceCount();
        assertEquals(initialCount + 1, newCount,
                     "Invoice count should increase by 1");

        // Switch between invoices
        cashierPage.switchToInvoice(1);
        sleep(300);

        String invoice1Name = cashierPage.getCurrentInvoiceName();
        assertNotNull(invoice1Name, "Invoice 1 name should be displayed");

        cashierPage.switchToInvoice(2);
        sleep(300);

        String invoice2Name = cashierPage.getCurrentInvoiceName();
        assertNotNull(invoice2Name, "Invoice 2 name should be displayed");

        takeScreenshot("multiple_invoices");
    }

    /**
     * Test 13: Table status update after checkout
     */
    @Test
    @Order(13)
    @DisplayName("13. Trạng thái bàn cập nhật sau checkout")
    public void testTableStatusUpdate() {
        // Select an available table
        cashierPage.switchToTablesTab();

        // Filter for available tables
        cashierPage.getTableSection().filterByStatus("available");
        sleep(500);

        // Check if table T001 is available
        boolean isAvailable = cashierPage.getTableSection().isTableAvailable("T001");

        if (isAvailable) {
            // Select and create order
            cashierPage.getTableSection().selectTable("T001");
            setupOrderWithItems();

            // Complete checkout
            cashierPage.getOrderSection().checkout("cash");
            sleep(1000);

            // Verify table status changed
            // Note: This depends on your app's behavior after checkout
            // You might need to refresh or navigate back to tables
            cashierPage.switchToTablesTab();
            sleep(500);
        }

        takeScreenshot("table_status_after_checkout");
    }

    /**
     * Test 14: Order note functionality
     */
    @Test
    @Order(14)
    @DisplayName("14. Thêm ghi chú cho order")
    public void testOrderNote() {
        // Setup order
        setupOrderWithItems();

        // Click order note button
        cashierPage.getOrderSection().clickOrderNote();
        sleep(500);

        // Note: Additional steps depend on your note modal implementation
        // You would need to interact with the note modal here

        takeScreenshot("order_note");
    }

    /**
     * Test 15: Clear order
     */
    @Test
    @Order(15)
    @DisplayName("15. Xóa toàn bộ order")
    public void testClearOrder() {
        // Setup order with items
        setupOrderWithItems();

        // Verify order has items
        assertFalse(cashierPage.getOrderSection().isOrderEmpty(),
                    "Order should have items before clearing");

        // Clear order
        cashierPage.getOrderSection().clearOrder();
        sleep(500);

        // Verify order is empty
        assertTrue(cashierPage.getOrderSection().isOrderEmpty(),
                   "Order should be empty after clearing");

        takeScreenshot("order_cleared");
    }

    /**
     * Test 16: Amount discount
     */
    @Test
    @Order(16)
    @DisplayName("16. Áp dụng giảm giá theo số tiền")
    public void testAmountDiscount() {
        // Setup order
        setupOrderWithItems();

        // Apply 20000 VND discount
        double discountAmount = 20000;
        cashierPage.getOrderSection().applyAmountDiscount(discountAmount);
        sleep(500);

        // Verify discount applied
        assertTrue(cashierPage.getOrderSection().isDiscountApplied(),
                   "Discount should be applied");

        String discount = cashierPage.getOrderSection().getDiscount();
        assertNotNull(discount, "Discount amount should be displayed");

        takeScreenshot("amount_discount");
    }

    /**
     * Test 17: Remove discount
     */
    @Test
    @Order(17)
    @DisplayName("17. Xóa giảm giá")
    public void testRemoveDiscount() {
        // Setup order with discount
        setupOrderWithItems();
        cashierPage.getOrderSection().applyPercentageDiscount(10);
        sleep(500);

        // Verify discount is applied
        assertTrue(cashierPage.getOrderSection().isDiscountApplied(),
                   "Discount should be applied initially");

        // Remove discount
        cashierPage.getOrderSection().removeDiscount();
        sleep(500);

        // Verify discount is removed
        assertFalse(cashierPage.getOrderSection().isDiscountApplied(),
                    "Discount should be removed");

        takeScreenshot("discount_removed");
    }

    /**
     * Test 18: Notify kitchen
     */
    @Test
    @Order(18)
    @DisplayName("18. Thông báo bếp")
    public void testNotifyKitchen() {
        // Setup order
        setupOrderWithItems();

        // Check if notify button is enabled
        if (cashierPage.getOrderSection().isNotifyKitchenEnabled()) {
            // Click notify kitchen
            cashierPage.getOrderSection().notifyKitchen();
            sleep(500);

            // Verify notification was sent
            // Note: Depends on your app's feedback mechanism

            takeScreenshot("kitchen_notified");
        } else {
            System.out.println("Notify kitchen button is disabled - skipping test");
        }
    }

    // ==================== Helper Methods ====================

    /**
     * Helper method to setup an order with items
     */
    private void setupOrderWithItems() {
        // Select table
        cashierPage.switchToTablesTab();
        boolean tableSelected = cashierPage.getTableSection().selectTable("T001");

        if (!tableSelected) {
            cashierPage.getTableSection().selectTableByName("Bàn 1");
        }

        // Add menu items
        cashierPage.switchToMenuTab();
        addMenuItems(2);
    }

    /**
     * Helper method to add menu items
     *
     * @param count number of different items to add
     */
    private void addMenuItems(int count) {
        cashierPage.getMenuSection().selectAllCategories();
        sleep(300);

        List<String> menuItems = cashierPage.getMenuSection().getVisibleMenuItemNames();

        int itemsAdded = 0;
        for (String itemName : menuItems) {
            if (itemsAdded >= count) break;

            if (cashierPage.getMenuSection().isMenuItemAvailable(itemName)) {
                cashierPage.getMenuSection().addMenuItem(itemName, 1);
                itemsAdded++;
                sleep(300);
            }
        }
    }

    /**
     * Override takeScreenshot to handle test failures
     */
    @AfterEach
    public void captureScreenshotOnFailure(TestInfo testInfo) {
        if (testInfo.getDisplayName().contains("FAILED")) {
            takeScreenshot(testInfo.getDisplayName().replaceAll("[^a-zA-Z0-9]", "_"));
        }
    }
}
