package com.liteflow.controller;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.inventory.Table;
import com.liteflow.model.inventory.TableSession;
import com.google.gson.Gson;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet("/api/checkout")
public class CheckoutServlet extends HttpServlet {
    
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
            System.out.println("📥 Nhận request checkout: " + requestBody);
            
            // Parse JSON
            @SuppressWarnings("unchecked")
            Map<String, Object> requestData = gson.fromJson(requestBody, Map.class);
            
            if (requestData == null) {
                sendErrorResponse(response, out, gson, 400, "Request body không hợp lệ");
                return;
            }
            
            String tableIdStr = (String) requestData.get("tableId");
            String paymentMethod = (String) requestData.get("paymentMethod");
            
            if (tableIdStr == null || tableIdStr.isEmpty()) {
                sendErrorResponse(response, out, gson, 400, "Table ID không được rỗng");
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
            
            // Process checkout
            EntityManager em = BaseDAO.emf.createEntityManager();
            
            try {
                em.getTransaction().begin();
                
                // 1. Tìm active session của bàn
                String sessionQuery = "SELECT s FROM TableSession s WHERE s.table.tableId = :tableId AND s.status = 'Active'";
                Query query = em.createQuery(sessionQuery);
                query.setParameter("tableId", tableId);
                
                @SuppressWarnings("unchecked")
                List<TableSession> sessions = query.getResultList();
                
                if (sessions.isEmpty()) {
                    em.getTransaction().rollback();
                    sendErrorResponse(response, out, gson, 404, "Không tìm thấy session active cho bàn này");
                    return;
                }
                
                TableSession session = sessions.get(0);
                
                // 2. Cập nhật session
                session.setStatus("Completed");
                session.setCheckOutTime(LocalDateTime.now());
                session.setPaymentStatus("Paid");
                if (paymentMethod != null && !paymentMethod.isEmpty()) {
                    session.setPaymentMethod(paymentMethod);
                }
                em.merge(session);
                
                // 3. Cập nhật trạng thái bàn về Available
                Table table = em.find(Table.class, tableId);
                if (table != null) {
                    table.setStatus("Available");
                    em.merge(table);
                }
                
                // 4. Cập nhật tất cả orders thành Served
                String updateOrdersQuery = "UPDATE Order o SET o.status = 'Served', o.paymentStatus = 'Paid' WHERE o.session.sessionId = :sessionId";
                Query updateQuery = em.createQuery(updateOrdersQuery);
                updateQuery.setParameter("sessionId", session.getSessionId());
                updateQuery.executeUpdate();
                
                em.getTransaction().commit();
                
                // Trả về response thành công
                Map<String, Object> responseData = new HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Thanh toán thành công!");
                responseData.put("sessionId", session.getSessionId().toString());
                responseData.put("totalAmount", session.getTotalAmount().doubleValue());
                
                response.setStatus(HttpServletResponse.SC_OK);
                out.print(gson.toJson(responseData));
                
                System.out.println("✅ Checkout thành công cho bàn " + tableId);
                
            } catch (Exception e) {
                if (em.getTransaction().isActive()) {
                    em.getTransaction().rollback();
                }
                throw e;
            } finally {
                em.close();
            }
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi checkout: " + e.getMessage());
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
}

