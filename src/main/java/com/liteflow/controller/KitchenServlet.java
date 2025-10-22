package com.liteflow.controller;

import com.liteflow.service.OrderService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

@WebServlet("/kitchen")
public class KitchenServlet extends HttpServlet {
    
    private OrderService orderService;
    
    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy danh sách orders đang pending và preparing
            List<Map<String, Object>> pendingOrders = orderService.getPendingOrders();
            
            // Convert to JSON for JavaScript
            Gson gson = new Gson();
            request.setAttribute("ordersJson", gson.toJson(pendingOrders));
            
            // Forward to JSP
            request.getRequestDispatcher("/kitchen/kitchen.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong KitchenServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi server");
        }
    }
}

