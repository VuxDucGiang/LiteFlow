package com.liteflow.controller;

import com.liteflow.service.inventory.ProductService;
import com.liteflow.model.inventory.ProductPriceDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
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
}
