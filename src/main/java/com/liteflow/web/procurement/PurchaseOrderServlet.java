package com.liteflow.web.procurement;

import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.model.procurement.PurchaseOrderItem;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

// @WebServlet(urlPatterns = {"/procurement/po"}) // Disabled - using web.xml mapping
public class PurchaseOrderServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String action = req.getParameter("action");
        String userLogin = (String) req.getSession().getAttribute("UserLogin");
        UUID userID = userLogin != null ? UUID.fromString(userLogin) : null;

        if ("create".equals(action)) {
            UUID supplierID = UUID.fromString(req.getParameter("supplierID"));
            LocalDateTime expected = LocalDateTime.parse(req.getParameter("expected"));
            String notes = req.getParameter("notes");

            String[] names = req.getParameterValues("itemName");
            String[] qtys = req.getParameterValues("qty");
            String[] prices = req.getParameterValues("price");

            List<PurchaseOrderItem> items = new ArrayList<>();
            for (int i = 0; i < names.length; i++) {
                PurchaseOrderItem item = new PurchaseOrderItem();
                item.setItemName(names[i]);
                item.setQuantity(Integer.parseInt(qtys[i]));
                item.setUnitPrice(Double.parseDouble(prices[i]));
                items.add(item);
            }

            service.createPurchaseOrder(supplierID, userID, expected, notes, items);
            resp.sendRedirect(req.getContextPath() + "/procurement/po?status=created");
        }

        if ("approve".equals(action)) {
            UUID poid = UUID.fromString(req.getParameter("poid"));
            int level = Integer.parseInt(req.getParameter("level"));
            service.approvePO(poid, userID, level);
            resp.sendRedirect(req.getContextPath() + "/procurement/po?status=approved");
        }

        if ("reject".equals(action)) {
            UUID poid = UUID.fromString(req.getParameter("poid"));
            String reason = req.getParameter("reason");
            service.rejectPO(poid, userID, reason);
            resp.sendRedirect(req.getContextPath() + "/procurement/po?status=rejected");
        }
    }
}
