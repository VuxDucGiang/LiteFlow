package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import com.liteflow.model.procurement.Supplier;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet(urlPatterns = {"/procurement/supplier"})
public class SupplierServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== SUPPLIER SERVLET DEBUG ===");
            
            // Set content type and encoding FIRST
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            
            // Disable chunked encoding to prevent ERR_INCOMPLETE_CHUNKED_ENCODING
            resp.setHeader("Transfer-Encoding", "identity");
            
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Suppliers loaded: " + suppliers.size());
            
            // Set in request scope for JSP
            req.setAttribute("suppliers", suppliers);
            
            System.out.println("Forwarding to supplier-list.jsp");
            req.getRequestDispatcher("/procurement/supplier-list.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in SupplierServlet doGet: " + e.getMessage());
            e.printStackTrace();
            
            // Send error response with proper encoding
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("<html><head><meta charset='UTF-8'></head><body><h1>Lỗi hệ thống</h1><p>" + e.getMessage() + "</p><a href='/LiteFlow/procurement/supplier-simple'>Thử phiên bản đơn giản</a></body></html>");
            resp.getWriter().flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        String action = req.getParameter("action");
        
        if ("update".equals(action)) {
            // Handle update supplier
            handleUpdateSupplier(req, resp);
        } else {
            // Handle create new supplier
            handleCreateSupplier(req, resp);
        }
    }
    
    private void handleCreateSupplier(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String userLogin = (String) req.getSession().getAttribute("UserLogin");
        UUID createdBy = userLogin != null ? UUID.fromString(userLogin) : null;
        service.createSupplier(name, createdBy, email);
        resp.sendRedirect(req.getContextPath() + "/procurement/supplier");
    }
    
    private void handleUpdateSupplier(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== UPDATE SUPPLIER REQUEST ===");
            
            // Get parameters
            String supplierId = req.getParameter("supplierId");
            String name = req.getParameter("name");
            String contact = req.getParameter("contact");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");
            String ratingStr = req.getParameter("rating");
            String onTimeRateStr = req.getParameter("onTimeRate");
            String isActiveStr = req.getParameter("isActive");
            
            System.out.println("Parameters: " + supplierId + ", " + name + ", " + email);
            
            // Business validation
            if (supplierId == null || supplierId.trim().isEmpty()) {
                throw new IllegalArgumentException("Supplier ID is required");
            }
            
            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Tên nhà cung cấp không được để trống");
            }
            
            if (email == null || email.trim().isEmpty()) {
                throw new IllegalArgumentException("Email không được để trống");
            }
            
            // Email format validation
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                throw new IllegalArgumentException("Email không đúng định dạng");
            }
            
            UUID supplierUUID = UUID.fromString(supplierId);
            
            // Get existing supplier
            Supplier existingSupplier = service.getSupplierById(supplierUUID);
            if (existingSupplier == null) {
                throw new IllegalArgumentException("Không tìm thấy nhà cung cấp với ID: " + supplierId);
            }
            
            System.out.println("Found supplier: " + existingSupplier.getName());
            
            // Update fields with business logic
            existingSupplier.setName(name.trim());
            existingSupplier.setContact(contact != null ? contact.trim() : null);
            existingSupplier.setEmail(email.trim().toLowerCase());
            existingSupplier.setPhone(phone != null ? phone.trim() : null);
            existingSupplier.setAddress(address != null ? address.trim() : null);
            
            // Rating validation (0-5)
            if (ratingStr != null && !ratingStr.trim().isEmpty()) {
                double rating = Double.parseDouble(ratingStr);
                if (rating < 0 || rating > 5) {
                    throw new IllegalArgumentException("Đánh giá phải từ 0 đến 5");
                }
                existingSupplier.setRating(rating);
            }
            
            // On-time rate validation (0-100)
            if (onTimeRateStr != null && !onTimeRateStr.trim().isEmpty()) {
                double onTimeRate = Double.parseDouble(onTimeRateStr);
                if (onTimeRate < 0 || onTimeRate > 100) {
                    throw new IllegalArgumentException("Tỷ lệ đúng hạn phải từ 0 đến 100%");
                }
                existingSupplier.setOnTimeRate(onTimeRate);
            }
            
            // Status update
            if (isActiveStr != null) {
                existingSupplier.setIsActive(Boolean.parseBoolean(isActiveStr));
            }
            
            // Save updated supplier
            boolean success = service.updateSupplier(existingSupplier);
            
            if (success) {
                System.out.println("Supplier updated successfully: " + existingSupplier.getName());
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"success\": true, \"message\": \"Nhà cung cấp '" + existingSupplier.getName() + "' đã được cập nhật thành công\"}");
            } else {
                throw new RuntimeException("Lỗi khi lưu dữ liệu vào database");
            }
            
        } catch (IllegalArgumentException e) {
            System.err.println("Validation error: " + e.getMessage());
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        } catch (Exception e) {
            System.err.println("Error updating supplier: " + e.getMessage());
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }
}
