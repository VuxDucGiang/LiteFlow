package com.liteflow.controller;

import com.liteflow.model.inventory.ProductDisplayDTO;
import com.liteflow.service.inventory.ProductService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductServlet", urlPatterns = {"/products"})
public class ProductServlet extends HttpServlet {

    private ProductService productService;

    @Override
    public void init() throws ServletException {
        productService = new ProductService();
    }

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("=== DEBUG: ProductServlet service method called ===");
        System.out.println("HTTP Method: " + request.getMethod());
        super.service(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy danh sách sản phẩm với giá và tồn kho
            List<ProductDisplayDTO> productList = productService.getAllProductsWithPriceAndStock();
            
            // Lấy danh sách danh mục từ sản phẩm hiện có
            List<String> categories = productService.getDistinctCategoriesFromProducts();
            
            // Debug logging
            System.out.println("=== DEBUG: ProductServlet ===");
            System.out.println("Số lượng sản phẩm lấy được: " + (productList != null ? productList.size() : "null"));
            System.out.println("Số lượng danh mục từ sản phẩm: " + (categories != null ? categories.size() : "null"));
            if (productList != null && !productList.isEmpty()) {
                System.out.println("Sản phẩm đầu tiên: " + productList.get(0).getProductName());
            }
            if (categories != null && !categories.isEmpty()) {
                System.out.println("Danh mục đầu tiên: " + categories.get(0));
                System.out.println("Tất cả danh mục:");
                for (int i = 0; i < categories.size(); i++) {
                    String cat = categories.get(i);
                    System.out.println("  [" + i + "] = '" + cat + "' (length: " + cat.length() + ")");
                }
            }

            // Gửi sang JSP
            request.setAttribute("products", productList);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/inventory/productlist.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong ProductServlet: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().println("Lỗi: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("=== DEBUG: ProductServlet POST method called ===");
        System.out.println("Request method: " + request.getMethod());
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Request URL: " + request.getRequestURL());
        
        // Set encoding for form data
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String action = request.getParameter("action");
            System.out.println("=== DEBUG: ProductServlet POST ===");
            System.out.println("Action: " + action);

            if ("test".equals(action)) {
                System.out.println("=== TEST POST REQUEST RECEIVED ===");
                response.getWriter().println("POST request received successfully!");
                return;
            }
            
            if ("create".equals(action)) {
                // Tạo sản phẩm mới
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String imageUrl = request.getParameter("imageUrl");
                String priceStr = request.getParameter("price");
                String stockStr = request.getParameter("stock");
                String[] sizes = request.getParameterValues("size");
                String customSize = request.getParameter("customSize");

                System.out.println("=== DEBUG: Form Data Received ===");
                System.out.println("Tên sản phẩm: " + name);
                System.out.println("Mô tả: " + description);
                System.out.println("URL hình ảnh: " + imageUrl);
                System.out.println("Giá bán: " + priceStr);
                System.out.println("Số lượng: " + stockStr);
                System.out.println("Sizes: " + java.util.Arrays.toString(sizes));
                System.out.println("Custom size: " + customSize);
                
                // Debug all parameters
                java.util.Enumeration<String> paramNames = request.getParameterNames();
                System.out.println("=== All Parameters ===");
                while (paramNames.hasMoreElements()) {
                    String paramName = paramNames.nextElement();
                    String[] paramValues = request.getParameterValues(paramName);
                    System.out.println(paramName + ": " + java.util.Arrays.toString(paramValues));
                }

                // Validation
                if (name == null || name.trim().isEmpty()) {
                    request.setAttribute("error", "Tên sản phẩm không được để trống");
                    doGet(request, response);
                    return;
                }

                if (description == null || description.trim().isEmpty()) {
                    request.setAttribute("error", "Mô tả sản phẩm không được để trống");
                    doGet(request, response);
                    return;
                }

                if (priceStr == null || priceStr.trim().isEmpty()) {
                    request.setAttribute("error", "Giá bán không được để trống");
                    doGet(request, response);
                    return;
                }

                if (stockStr == null || stockStr.trim().isEmpty()) {
                    request.setAttribute("error", "Số lượng tồn kho không được để trống");
                    doGet(request, response);
                    return;
                }

                // Validate price
                double price;
                try {
                    price = Double.parseDouble(priceStr.trim());
                    if (price <= 0) {
                        request.setAttribute("error", "Giá bán phải lớn hơn 0");
                        doGet(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Giá bán không hợp lệ");
                    doGet(request, response);
                    return;
                }

                // Validate stock
                int stock;
                try {
                    stock = Integer.parseInt(stockStr.trim());
                    if (stock < 0) {
                        request.setAttribute("error", "Số lượng tồn kho không được âm");
                        doGet(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Số lượng tồn kho không hợp lệ");
                    doGet(request, response);
                    return;
                }

                // Validate size
                if ((sizes == null || sizes.length == 0) && (customSize == null || customSize.trim().isEmpty())) {
                    request.setAttribute("error", "Vui lòng chọn ít nhất một size");
                    doGet(request, response);
                    return;
                }

                // Tạo đối tượng Product mới
                com.liteflow.model.inventory.Product newProduct = new com.liteflow.model.inventory.Product();
                newProduct.setName(name.trim());
                newProduct.setDescription(description.trim());
                newProduct.setImageUrl(imageUrl != null && !imageUrl.trim().isEmpty() ? imageUrl.trim() : null);
                newProduct.setImportDate(java.time.LocalDateTime.now());
                newProduct.setIsDeleted(false);

                // Lưu sản phẩm
                boolean success = productService.addProduct(newProduct);
                
                if (success) {
                    try {
                        // Tạo ProductVariant và ProductStock cho mỗi size
                        if (sizes != null && sizes.length > 0) {
                            // Tạo variant cho các size S, M, L được chọn
                            for (String size : sizes) {
                                createProductVariantAndStock(newProduct, size, price, stock);
                            }
                        }
                        
                        if (customSize != null && !customSize.trim().isEmpty()) {
                            // Tạo variant cho custom size
                            createProductVariantAndStock(newProduct, customSize.trim(), price, stock);
                        }
                        
                        request.setAttribute("success", "Thêm sản phẩm thành công!");
                        System.out.println("✅ Thêm sản phẩm thành công: " + name);
                    } catch (Exception e) {
                        System.err.println("❌ Lỗi khi tạo ProductVariant/ProductStock: " + e.getMessage());
                        e.printStackTrace();
                        request.setAttribute("error", "Sản phẩm đã được tạo nhưng có lỗi khi tạo variants");
                    }
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi thêm sản phẩm");
                    System.out.println("❌ Lỗi khi thêm sản phẩm: " + name);
                }
            }

            if ("update".equals(action)) {
                String productIdStr = request.getParameter("productId");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String imageUrl = request.getParameter("imageUrl");
                String priceStr = request.getParameter("price");
                String stockStr = request.getParameter("stock");
                String size = request.getParameter("size");
                System.out.println("=== DEBUG: UPDATE params ===");
                System.out.println("productId=" + productIdStr + ", name=" + name + ", price=" + priceStr + ", stock=" + stockStr + ", size=" + size);

                try {
                    java.util.UUID productId = java.util.UUID.fromString(productIdStr);

                    // Update Product fields
                    com.liteflow.dao.inventory.ProductDAO productDAO = new com.liteflow.dao.inventory.ProductDAO();
                    com.liteflow.model.inventory.Product product = productDAO.findById(productId);
                    if (product == null) {
                        request.setAttribute("error", "Không tìm thấy sản phẩm để cập nhật");
                        doGet(request, response);
                        return;
                    }
                    System.out.println("Found product: " + product.getProductId() + ", current name=" + product.getName());
                    if (name != null && !name.trim().isEmpty()) product.setName(name.trim());
                    if (description != null) product.setDescription(description.trim());
                    if (imageUrl != null && !imageUrl.trim().isEmpty()) product.setImageUrl(imageUrl.trim());
                    boolean productUpdated = productDAO.update(product);
                    System.out.println("Product updated: " + productUpdated);

                    // Update price and stock for the selected size
                    com.liteflow.dao.inventory.ProductVariantDAO variantDAO = new com.liteflow.dao.inventory.ProductVariantDAO();
                    com.liteflow.model.inventory.ProductVariant variant = variantDAO.findByProductAndSize(productId, size);
                    if (variant != null) {
                        System.out.println("Found variant: " + variant.getProductVariantId() + ", size=" + variant.getSize() + ", current price=" + variant.getPrice());
                        if (priceStr != null && !priceStr.isBlank()) {
                            try {
                                double price = Double.parseDouble(priceStr.trim());
                                variant.setPrice(java.math.BigDecimal.valueOf(price));
                                System.out.println("Updating variant selling price to: " + price);
                            } catch (NumberFormatException ignored) {}
                        }

                        if (stockStr != null && !stockStr.isBlank()) {
                            try {
                                int stock = Integer.parseInt(stockStr.trim());
                                com.liteflow.dao.inventory.ProductStockDAO stockDAO = new com.liteflow.dao.inventory.ProductStockDAO();
                                // Tìm stock theo variant và inventory mặc định
                                var em = com.liteflow.dao.BaseDAO.emf.createEntityManager();
                                try {
                                    var stocks = em.createQuery("SELECT ps FROM ProductStock ps WHERE ps.productVariant.productVariantId = :pvid", com.liteflow.model.inventory.ProductStock.class)
                                            .setParameter("pvid", variant.getProductVariantId())
                                            .getResultList();
                                    if (!stocks.isEmpty()) {
                                        var ps = stocks.get(0);
                                        System.out.println("Found stock row for variant: current amount=" + ps.getAmount());
                                        ps.setAmount(stock);
                                        boolean stockUpdated = stockDAO.update(ps);
                                        System.out.println("Stock updated: " + stockUpdated + ", new amount=" + stock);
                                    }
                                } finally {
                                    em.close();
                                }
                            } catch (NumberFormatException ignored) {}
                        }
                        boolean variantUpdated = variantDAO.update(variant);
                        System.out.println("Variant updated: " + variantUpdated);
                    } else {
                        System.out.println("Variant not found for productId=" + productId + ", size=" + size);
                    }

                    request.setAttribute("success", "Cập nhật sản phẩm thành công");
                } catch (Exception ex) {
                    request.setAttribute("error", "Lỗi khi cập nhật sản phẩm: " + ex.getMessage());
                }
            }

            // Redirect về trang danh sách
            doGet(request, response);
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong ProductServlet POST: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
    
    private void createProductVariantAndStock(com.liteflow.model.inventory.Product product, String size, double price, int stock) {
        try {
            System.out.println("=== DEBUG: Creating ProductVariant and Stock ===");
            System.out.println("Product ID: " + product.getProductId());
            System.out.println("Size: " + size);
            System.out.println("Price: " + price);
            System.out.println("Stock: " + stock);
            
            // Tạo ProductVariant
            com.liteflow.model.inventory.ProductVariant variant = new com.liteflow.model.inventory.ProductVariant();
            variant.setProduct(product);
            variant.setSize(size);
            variant.setPrice(java.math.BigDecimal.valueOf(price));
            variant.setOriginalPrice(java.math.BigDecimal.valueOf(price));
            variant.setIsDeleted(false);
            
            System.out.println("ProductVariant created: " + variant.getSize() + " - " + variant.getPrice());
            
            // Lưu ProductVariant
            com.liteflow.dao.inventory.ProductVariantDAO variantDAO = new com.liteflow.dao.inventory.ProductVariantDAO();
            boolean variantSuccess = variantDAO.insert(variant);
            
            System.out.println("ProductVariant insert result: " + variantSuccess);
            
            if (variantSuccess) {
                // Tạo Inventory mặc định (nếu chưa có)
                com.liteflow.model.inventory.Inventory defaultInventory = getOrCreateDefaultInventory();
                
                if (defaultInventory != null) {
                    System.out.println("Default inventory found/created: " + defaultInventory.getInventoryId());
                    
                    // Tạo ProductStock
                    com.liteflow.model.inventory.ProductStock productStock = new com.liteflow.model.inventory.ProductStock();
                    productStock.setProductVariant(variant);
                    productStock.setInventory(defaultInventory);
                    productStock.setAmount(stock);
                    
                    System.out.println("ProductStock created with amount: " + productStock.getAmount());
                    
                    // Lưu ProductStock
                    com.liteflow.dao.inventory.ProductStockDAO stockDAO = new com.liteflow.dao.inventory.ProductStockDAO();
                    boolean stockSuccess = stockDAO.insert(productStock);
                    
                    System.out.println("ProductStock insert result: " + stockSuccess);
                    
                    if (stockSuccess) {
                        System.out.println("✅ Tạo ProductVariant và ProductStock thành công cho size: " + size);
                    } else {
                        System.err.println("❌ Lỗi khi tạo ProductStock cho size: " + size);
                    }
                } else {
                    System.err.println("❌ Không thể tạo/lấy inventory mặc định");
                }
            } else {
                System.err.println("❌ Lỗi khi tạo ProductVariant cho size: " + size);
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong createProductVariantAndStock: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private com.liteflow.model.inventory.Inventory getOrCreateDefaultInventory() {
        try {
            System.out.println("=== DEBUG: Getting/Creating Default Inventory ===");
            com.liteflow.dao.inventory.InventoryDAO inventoryDAO = new com.liteflow.dao.inventory.InventoryDAO();
            
            // Tìm inventory mặc định
            com.liteflow.model.inventory.Inventory defaultInventory = inventoryDAO.findByField("storeLocation", "Kho chính");
            
            System.out.println("Found existing inventory: " + (defaultInventory != null));
            
            if (defaultInventory == null) {
                // Tạo inventory mặc định nếu chưa có
                System.out.println("Creating new default inventory...");
                defaultInventory = new com.liteflow.model.inventory.Inventory();
                defaultInventory.setStoreLocation("Kho chính");
                boolean insertResult = inventoryDAO.insert(defaultInventory);
                System.out.println("Inventory insert result: " + insertResult);
                if (insertResult) {
                    System.out.println("✅ Tạo inventory mặc định thành công");
                } else {
                    System.err.println("❌ Lỗi khi tạo inventory mặc định");
                }
            } else {
                System.out.println("✅ Sử dụng inventory mặc định có sẵn");
            }
            
            return defaultInventory;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi tạo/lấy inventory mặc định: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}
