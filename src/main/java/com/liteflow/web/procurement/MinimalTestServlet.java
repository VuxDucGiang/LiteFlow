package com.liteflow.web.procurement;

import com.liteflow.model.procurement.Supplier;
import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/minimal-test"})
public class MinimalTestServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== MINIMAL TEST SERVLET ===");
            
            List<Supplier> suppliers = service.getAllSuppliers();
            List<PurchaseOrder> purchaseOrders = service.getAllPOs();
            
            System.out.println("Suppliers: " + suppliers.size());
            System.out.println("Purchase Orders: " + purchaseOrders.size());
            
            req.setAttribute("suppliers", suppliers);
            req.setAttribute("purchaseOrders", purchaseOrders);
            
            req.getRequestDispatcher("/procurement/minimal-test.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in MinimalTestServlet: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/procurement/minimal-test.jsp").forward(req, resp);
        }
    }
}






