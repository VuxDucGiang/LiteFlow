package com.liteflow.web.procurement;

import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.model.procurement.PurchaseOrderItem;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet(urlPatterns = {"/procurement/po"})
public class PurchaseOrderServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            List<PurchaseOrder> purchaseOrders = service.getAllPOs();
            List<com.liteflow.model.procurement.Supplier> suppliers = service.getAllSuppliers();
            
            System.out.println("DEBUG: Loaded " + purchaseOrders.size() + " purchase orders");
            System.out.println("DEBUG: Loaded " + suppliers.size() + " suppliers");
            
            req.setAttribute("purchaseOrders", purchaseOrders);
            req.setAttribute("suppliers", suppliers);
            
            req.getRequestDispatcher("/procurement/purchase-orders.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("ERROR in PurchaseOrderServlet.doGet: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Không thể tải dữ liệu đơn đặt hàng: " + e.getMessage());
            req.getRequestDispatcher("/procurement/purchase-orders.jsp").forward(req, resp);
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
