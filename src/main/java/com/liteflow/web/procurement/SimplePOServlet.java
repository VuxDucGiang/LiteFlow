package com.liteflow.web.procurement;

import com.liteflow.model.procurement.Supplier;
import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/po-simple"})
public class SimplePOServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== LOADING SIMPLE PO PAGE ===");
            
            List<Supplier> suppliers = service.getAllSuppliers();
            List<PurchaseOrder> purchaseOrders = service.getAllPOs();
            
            System.out.println("Suppliers loaded: " + suppliers.size());
            System.out.println("Purchase Orders loaded: " + purchaseOrders.size());
            
            req.setAttribute("suppliers", suppliers);
            req.setAttribute("purchaseOrders", purchaseOrders);
            
            req.getRequestDispatcher("/procurement/po-simple.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in SimplePOServlet: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Lỗi tải dữ liệu: " + e.getMessage());
            req.getRequestDispatcher("/procurement/po-simple.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String action = req.getParameter("action");
            System.out.println("POST action: " + action);
            
            if ("create".equals(action)) {
                String userLogin = (String) req.getSession().getAttribute("UserLogin");
                if (userLogin == null) {
                    resp.sendRedirect(req.getContextPath() + "/login");
                    return;
                }
                
                String supplierIDStr = req.getParameter("supplierID");
                String expectedStr = req.getParameter("expected");
                String notes = req.getParameter("notes");
                
                System.out.println("Creating PO with supplier: " + supplierIDStr);
                System.out.println("Expected delivery: " + expectedStr);
                
                // TODO: Implement PO creation
                resp.sendRedirect(req.getContextPath() + "/procurement/po-simple?status=created");
            }
            
        } catch (Exception e) {
            System.err.println("ERROR in SimplePOServlet POST: " + e.getMessage());
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/procurement/po-simple?error=" + e.getMessage());
        }
    }
}






