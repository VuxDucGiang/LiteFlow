package com.liteflow.controller;

import com.liteflow.service.OrderService;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

@WebServlet("/api/order/create")
public class CreateOrderServlet extends HttpServlet {
    
    private OrderService orderService;
    
    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        try {
            // Đọc JSON từ request body
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            
            String requestBody = sb.toString();
            System.out.println("📥 Nhận request tạo order: " + requestBody);
            
            // Parse JSON
            @SuppressWarnings("unchecked")
            Map<String, Object> requestData = gson.fromJson(requestBody, Map.class);
            
            // Validate input
            if (requestData == null) {
                sendErrorResponse(response, out, gson, 400, "Request body không hợp lệ");
                return;
            }
            
            String tableIdStr = (String) requestData.get("tableId");
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> items = (List<Map<String, Object>>) requestData.get("items");
            
            if (tableIdStr == null || tableIdStr.isEmpty()) {
                sendErrorResponse(response, out, gson, 400, "Table ID không được rỗng");
                return;
            }
            
            if (items == null || items.isEmpty()) {
                sendErrorResponse(response, out, gson, 400, "Danh sách món không được rỗng");
                return;
            }
            
            // Convert tableId to UUID
            UUID tableId;
            try {
                tableId = UUID.fromString(tableIdStr);
            } catch (IllegalArgumentException e) {
                sendErrorResponse(response, out, gson, 400, "Table ID không hợp lệ: " + tableIdStr);
                return;
            }
            
            // TODO: Lấy userId từ session khi có authentication
            UUID userId = null;
            
            // Tạo order
            UUID orderId = orderService.createOrderAndNotifyKitchen(tableId, items, userId);
            
            // Trả về response thành công
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("message", "Đã gửi thông báo đến bếp thành công!");
            responseData.put("orderId", orderId.toString());
            
            response.setStatus(HttpServletResponse.SC_CREATED);
            out.print(gson.toJson(responseData));
            
            System.out.println("✅ Đã tạo order thành công: " + orderId);
            
        } catch (IllegalArgumentException e) {
            System.err.println("⚠️ Lỗi validation: " + e.getMessage());
            sendErrorResponse(response, out, gson, 400, e.getMessage());
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi tạo order: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, out, gson, 500, "Lỗi server: " + e.getMessage());
        } finally {
            out.flush();
        }
    }
    
    /**
     * Gửi error response
     */
    private void sendErrorResponse(HttpServletResponse response, PrintWriter out, 
                                   Gson gson, int statusCode, String message) {
        response.setStatus(statusCode);
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("message", message);
        out.print(gson.toJson(errorResponse));
    }
    
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hỗ trợ CORS nếu cần
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }
}

