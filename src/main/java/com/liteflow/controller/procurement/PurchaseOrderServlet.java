package com.liteflow.controller.procurement;

import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.model.procurement.PurchaseOrderItem;
import com.liteflow.service.procurement.ProcurementService;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

// @WebServlet(urlPatterns = {"/procurement/po"}) // Disabled - using web.xml mapping
public class PurchaseOrderServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        String action = req.getParameter("action");
        
        // Handle AJAX request for PO details
        if ("details".equals(action)) {
            handleGetDetails(req, resp);
            return;
        }
        
        // CRITICAL: Set response headers to prevent chunked encoding issues
        resp.setContentType("text/html; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Transfer-Encoding", "identity");
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setHeader("Expires", "0");
        
        try {
            System.out.println("=== PurchaseOrderServlet.doGet START ===");
            
            List<PurchaseOrder> purchaseOrders = service.getAllPOs();
            List<com.liteflow.model.procurement.Supplier> suppliers = service.getAllSuppliers();
            
            System.out.println("DEBUG: Loaded " + purchaseOrders.size() + " purchase orders");
            System.out.println("DEBUG: Loaded " + suppliers.size() + " suppliers");
            
            req.setAttribute("purchaseOrders", purchaseOrders);
            req.setAttribute("suppliers", suppliers);
            
            System.out.println("DEBUG: Forwarding to po.jsp");
            req.getRequestDispatcher("/procurement/po.jsp").forward(req, resp);
            System.out.println("=== PurchaseOrderServlet.doGet END ===");
            
        } catch (Exception e) {
            System.err.println("ERROR in PurchaseOrderServlet.doGet: " + e.getMessage());
            e.printStackTrace();
            
            // Send error response directly to avoid JSP issues
            resp.setContentType("text/html; charset=UTF-8");
            resp.getWriter().write(
                "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head><title>PO Error</title></head>\n" +
                "<body>\n" +
                "    <h1>Lỗi tải trang đơn đặt hàng</h1>\n" +
                "    <p><strong>Lỗi:</strong> " + e.getMessage() + "</p>\n" +
                "    <pre>" + e.toString() + "</pre>\n" +
                "    <p><a href=\"/LiteFlow/dashboard\">Quay về Dashboard</a></p>\n" +
                "</body>\n" +
                "</html>"
            );
        }
    }
    
    private void handleGetDetails(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            String poidStr = req.getParameter("poid");
            System.out.println("handleGetDetails - POID: " + poidStr);
            UUID poid = UUID.fromString(poidStr);
            
            PurchaseOrder po = service.getAllPOs().stream()
                .filter(p -> p.getPoid().equals(poid))
                .findFirst()
                .orElse(null);
            
            if (po == null) {
                System.err.println("PO not found: " + poid);
                resp.getWriter().write("{\"error\": \"PO not found\"}");
                return;
            }
            
            // Get supplier name
            com.liteflow.model.procurement.Supplier supplier = service.getSupplierById(po.getSupplierID());
            String supplierName = supplier != null ? supplier.getName() : "N/A";
            
            List<PurchaseOrderItem> items = service.getPOItems(poid);
            System.out.println("Found " + items.size() + " items for PO");
            
            // Build JSON manually
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"poid\":\"").append(po.getPoid()).append("\",");
            json.append("\"supplierID\":\"").append(po.getSupplierID()).append("\",");
            json.append("\"supplierName\":\"").append(supplierName.replace("\"", "\\\"")).append("\",");
            json.append("\"createDate\":\"").append(po.getCreateDate() != null ? po.getCreateDate() : "").append("\",");
            json.append("\"expectedDelivery\":\"").append(po.getExpectedDelivery() != null ? po.getExpectedDelivery() : "").append("\",");
            json.append("\"totalAmount\":").append(po.getTotalAmount() != null ? po.getTotalAmount() : 0).append(",");
            json.append("\"status\":\"").append(po.getStatus() != null ? po.getStatus() : "PENDING").append("\",");
            json.append("\"notes\":\"").append(po.getNotes() != null ? po.getNotes().replace("\"", "\\\"") : "").append("\",");
            
            // Get total received quantities (for both RECEIVING and APPROVED status)
            // This allows us to show received quantities even if status changes
            Map<String, Integer> receivedQuantities = service.getTotalReceivedQuantities(poid);
            
            json.append("\"receivedQuantities\":{");
            boolean firstReceived = true;
            for (Map.Entry<String, Integer> entry : receivedQuantities.entrySet()) {
                if (!firstReceived) json.append(",");
                json.append("\"").append(entry.getKey().replace("\"", "\\\"")).append("\":").append(entry.getValue());
                firstReceived = false;
            }
            json.append("},");
            
            json.append("\"items\":[");
            
            for (int i = 0; i < items.size(); i++) {
                PurchaseOrderItem item = items.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"itemName\":\"").append(item.getItemName().replace("\"", "\\\"")).append("\",");
                json.append("\"quantity\":").append(item.getQuantity()).append(",");
                json.append("\"unitPrice\":").append(item.getUnitPrice()).append(",");
                json.append("\"total\":").append(item.getQuantity() * item.getUnitPrice());
                json.append("}");
            }
            
            json.append("]}");
            
            System.out.println("Sending JSON response: " + json.toString().substring(0, Math.min(200, json.length())) + "...");
            resp.getWriter().write(json.toString());
            
        } catch (Exception e) {
            System.err.println("ERROR in handleGetDetails: " + e.getMessage());
            e.printStackTrace();
            resp.getWriter().write("{\"error\": \"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String action = req.getParameter("action");
        String userLogin = (String) req.getSession().getAttribute("UserLogin");
        UUID userID = userLogin != null ? UUID.fromString(userLogin) : null;

        if ("create".equals(action)) {
            try {
                // Get parameters from form (match with frontend field names)
                String supplierIDParam = req.getParameter("supplierID");
                String expectedDeliveryParam = req.getParameter("expectedDelivery");
                String notes = req.getParameter("notes");

                // Validate required fields
                if (supplierIDParam == null || supplierIDParam.trim().isEmpty()) {
                    throw new IllegalArgumentException("Nhà cung cấp không được để trống");
                }
                if (expectedDeliveryParam == null || expectedDeliveryParam.trim().isEmpty()) {
                    throw new IllegalArgumentException("Ngày giao dự kiến không được để trống");
                }

                UUID supplierID = UUID.fromString(supplierIDParam);
                LocalDateTime expected = LocalDateTime.parse(expectedDeliveryParam);

                // Get item arrays (match with frontend field names)
                String[] names = req.getParameterValues("itemName");
                String[] qtys = req.getParameterValues("quantity");
                String[] prices = req.getParameterValues("unitPrice");

                // Validate items
                if (names == null || names.length == 0) {
                    throw new IllegalArgumentException("Phải có ít nhất 1 sản phẩm");
                }

                List<PurchaseOrderItem> items = new ArrayList<>();
                for (int i = 0; i < names.length; i++) {
                    if (names[i] != null && !names[i].trim().isEmpty()) {
                        PurchaseOrderItem item = new PurchaseOrderItem();
                        item.setItemName(names[i].trim());
                        item.setQuantity(Integer.parseInt(qtys[i]));
                        item.setUnitPrice(Double.parseDouble(prices[i]));
                        items.add(item);
                    }
                }

                if (items.isEmpty()) {
                    throw new IllegalArgumentException("Phải có ít nhất 1 sản phẩm hợp lệ");
                }

                service.createPurchaseOrder(supplierID, userID, expected, notes, items);
                resp.sendRedirect(req.getContextPath() + "/procurement/po?status=created");
                
            } catch (IllegalArgumentException e) {
                System.err.println("ERROR: Validation failed - " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            } catch (Exception e) {
                System.err.println("ERROR: Failed to create PO - " + e.getMessage());
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode("Lỗi hệ thống: " + e.getMessage(), "UTF-8"));
            }
        }

        if ("approve".equals(action)) {
            try {
                String poidParam = req.getParameter("poid");
                String levelParam = req.getParameter("level");
                
                System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                System.out.println("PurchaseOrderServlet - APPROVE action");
                System.out.println("  POID param: " + poidParam);
                System.out.println("  Level param: " + levelParam);
                System.out.println("  User ID: " + userID);
                
                if (poidParam == null || poidParam.trim().isEmpty()) {
                    System.err.println("❌ APPROVE FAILED: Missing POID parameter");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Thiếu thông tin đơn hàng", "UTF-8"));
                    return;
                }
                
                if (userID == null) {
                    System.err.println("❌ APPROVE FAILED: User not logged in");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Bạn chưa đăng nhập", "UTF-8"));
                    return;
                }
                
                UUID poid = UUID.fromString(poidParam);
                int level = levelParam != null && !levelParam.isEmpty() ? Integer.parseInt(levelParam) : 1;
                
                System.out.println("  Calling approvePO()...");
                boolean success = service.approvePO(poid, userID, level);
                
                if (success) {
                    System.out.println("✅ APPROVE SUCCESS - Redirecting with status=approved");
                    
                    // Refresh PO pending notification immediately
                    try {
                        com.liteflow.service.alert.AlertService alertService = new com.liteflow.service.alert.AlertService();
                        alertService.refreshPOPendingNotification();
                    } catch (Exception e) {
                        System.err.println("⚠️ Failed to refresh notification (non-critical): " + e.getMessage());
                    }
                    
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?status=approved");
                } else {
                    System.err.println("❌ APPROVE FAILED - service.approvePO() returned false");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Không thể duyệt đơn hàng. Vui lòng kiểm tra console logs.", "UTF-8"));
                }
                System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                
            } catch (IllegalArgumentException e) {
                System.err.println("❌ APPROVE FAILED: Invalid parameters - " + e.getMessage());
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode("Thông tin không hợp lệ: " + e.getMessage(), "UTF-8"));
            } catch (Exception e) {
                System.err.println("❌ APPROVE FAILED: Unexpected error - " + e.getMessage());
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode("Lỗi hệ thống: " + e.getMessage(), "UTF-8"));
            }
        }

        if ("reject".equals(action)) {
            try {
                String poidParam = req.getParameter("poid");
                String reason = req.getParameter("reason");
                
                System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                System.out.println("PurchaseOrderServlet - REJECT action");
                System.out.println("  POID param: " + poidParam);
                System.out.println("  Reason: " + reason);
                System.out.println("  User ID: " + userID);
                
                if (poidParam == null || poidParam.trim().isEmpty()) {
                    System.err.println("❌ REJECT FAILED: Missing POID parameter");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Thiếu thông tin đơn hàng", "UTF-8"));
                    return;
                }
                
                if (userID == null) {
                    System.err.println("❌ REJECT FAILED: User not logged in");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Bạn chưa đăng nhập", "UTF-8"));
                    return;
                }
                
                UUID poid = UUID.fromString(poidParam);
                
                System.out.println("  Calling rejectPO()...");
                boolean success = service.rejectPO(poid, userID, reason);
                
                if (success) {
                    System.out.println("✅ REJECT SUCCESS - Redirecting with status=rejected");
                    
                    // Refresh PO pending notification immediately
                    try {
                        com.liteflow.service.alert.AlertService alertService = new com.liteflow.service.alert.AlertService();
                        alertService.refreshPOPendingNotification();
                    } catch (Exception e) {
                        System.err.println("⚠️ Failed to refresh notification (non-critical): " + e.getMessage());
                    }
                    
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?status=rejected");
                } else {
                    System.err.println("❌ REJECT FAILED - service.rejectPO() returned false");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Không thể từ chối đơn hàng. Vui lòng kiểm tra console logs.", "UTF-8"));
                }
                System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                
            } catch (IllegalArgumentException e) {
                System.err.println("❌ REJECT FAILED: Invalid parameters - " + e.getMessage());
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode("Thông tin không hợp lệ: " + e.getMessage(), "UTF-8"));
            } catch (Exception e) {
                System.err.println("❌ REJECT FAILED: Unexpected error - " + e.getMessage());
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode("Lỗi hệ thống: " + e.getMessage(), "UTF-8"));
            }
        }

        if ("receive".equals(action)) {
            try {
                String poidParam = req.getParameter("poid");
                String itemsJson = req.getParameter("items");
                String notes = req.getParameter("notes");
                
                System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                System.out.println("PurchaseOrderServlet - RECEIVE action");
                System.out.println("  POID param: " + poidParam);
                System.out.println("  Items JSON: " + (itemsJson != null ? itemsJson.substring(0, Math.min(100, itemsJson.length())) : "null"));
                
                if (poidParam == null || poidParam.trim().isEmpty()) {
                    System.err.println("❌ RECEIVE FAILED: Missing POID parameter");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Thiếu thông tin đơn hàng", "UTF-8"));
                    return;
                }
                
                if (userID == null) {
                    System.err.println("❌ RECEIVE FAILED: User not logged in");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Bạn chưa đăng nhập", "UTF-8"));
                    return;
                }
                
                UUID poid = UUID.fromString(poidParam);
                
                // Parse items JSON
                Gson gson = new Gson();
                java.lang.reflect.Type listType = new TypeToken<java.util.List<java.util.Map<String, Object>>>(){}.getType();
                java.util.List<java.util.Map<String, Object>> items = gson.fromJson(itemsJson, listType);
                
                System.out.println("  Calling receiveGoods() with " + items.size() + " items...");
                UUID receiptID = service.receiveGoods(poid, userID, items, notes);
                
                if (receiptID != null) {
                    System.out.println("✅ RECEIVE SUCCESS - Receipt ID: " + receiptID);
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?status=received&receipt=" + receiptID);
                } else {
                    System.err.println("❌ RECEIVE FAILED - service.receiveGoods() returned null");
                    resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                        java.net.URLEncoder.encode("Không thể nhận hàng. Vui lòng kiểm tra console logs.", "UTF-8"));
                }
                System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                
            } catch (IllegalArgumentException e) {
                System.err.println("❌ RECEIVE FAILED: Invalid parameters - " + e.getMessage());
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode("Thông tin không hợp lệ: " + e.getMessage(), "UTF-8"));
            } catch (Exception e) {
                System.err.println("❌ RECEIVE FAILED: Unexpected error - " + e.getMessage());
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/procurement/po?error=" + 
                    java.net.URLEncoder.encode("Lỗi hệ thống: " + e.getMessage(), "UTF-8"));
            }
        }
    }
}
