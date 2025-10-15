package com.liteflow.controller;

import com.liteflow.service.inventory.ProductService;
import com.liteflow.model.inventory.ProductPriceDTO;
import com.liteflow.dao.inventory.ProductVariantDAO;
import com.liteflow.model.inventory.ProductVariant;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.UUID;
import java.util.List;

@WebServlet(name = "SetPriceServlet", urlPatterns = {"/setprice"})
public class SetPriceServlet extends HttpServlet {
    private ProductService productService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.productService = new ProductService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy danh sách sản phẩm với thông tin giá
            List<ProductPriceDTO> productPriceList = productService.getAllProductsWithPriceInfo();
            // Lấy danh sách danh mục để lọc nhanh
            List<String> categories = productService.getDistinctCategoriesFromProducts();
            
            // Debug logging
            System.out.println("=== DEBUG: SetPriceServlet ===");
            System.out.println("Số lượng sản phẩm lấy được: " + (productPriceList != null ? productPriceList.size() : "null"));
            System.out.println("Số lượng danh mục: " + (categories != null ? categories.size() : "null"));

            // Gửi sang JSP
            request.setAttribute("productPrices", productPriceList);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/inventory/setPrice.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong SetPriceServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải dữ liệu giá sản phẩm: " + e.getMessage());
            request.getRequestDispatcher("/inventory/setPrice.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Endpoint: POST /setprice
        // Params: productId (UUID), size (String), originalPrice (number), sellingPrice (number)
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String productIdStr = request.getParameter("productId");
            String size = request.getParameter("size");
            String originalPriceStr = request.getParameter("originalPrice");
            String sellingPriceStr = request.getParameter("sellingPrice");

            if (productIdStr == null || productIdStr.isBlank() || size == null || size.isBlank()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"success\":false,\"message\":\"Thiếu productId hoặc size\"}");
                return;
            }

            UUID productId = UUID.fromString(productIdStr);
            BigDecimal originalPrice = originalPriceStr != null && !originalPriceStr.isBlank()
                    ? new BigDecimal(originalPriceStr)
                    : null;
            BigDecimal sellingPrice = sellingPriceStr != null && !sellingPriceStr.isBlank()
                    ? new BigDecimal(sellingPriceStr)
                    : null;

            if (originalPrice == null || sellingPrice == null ||
                    originalPrice.compareTo(BigDecimal.ZERO) < 0 || sellingPrice.compareTo(BigDecimal.ZERO) < 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"success\":false,\"message\":\"Giá không hợp lệ\"}");
                return;
            }

            ProductVariantDAO variantDAO = new ProductVariantDAO();
            ProductVariant variant = variantDAO.findByProductAndSize(productId, size);

            if (variant == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.write("{\"success\":false,\"message\":\"Không tìm thấy biến thể sản phẩm\"}");
                return;
            }

            variant.setOriginalPrice(originalPrice);
            variant.setPrice(sellingPrice);

            boolean ok = variantDAO.update(variant);
            if (ok) {
                out.write("{\"success\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.write("{\"success\":false,\"message\":\"Cập nhật thất bại\"}");
            }
        } catch (IllegalArgumentException e) {
            // UUID parse error hoặc BigDecimal lỗi
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Tham số không hợp lệ\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi máy chủ\"}");
        }
    }
}
