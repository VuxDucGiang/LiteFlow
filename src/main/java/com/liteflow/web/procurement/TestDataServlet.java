package com.liteflow.web.procurement;

import com.liteflow.model.procurement.Supplier;
import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/test"})
public class TestDataServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== TESTING PROCUREMENT DATA ===");
            
            List<Supplier> suppliers = service.getAllSuppliers();
            List<PurchaseOrder> purchaseOrders = service.getAllPOs();
            
            System.out.println("Suppliers loaded: " + suppliers.size());
            System.out.println("Purchase Orders loaded: " + purchaseOrders.size());
            
            // Print suppliers
            for (Supplier s : suppliers) {
                System.out.println("Supplier: " + s.getName() + " (ID: " + s.getSupplierID() + ")");
            }
            
            // Print purchase orders
            for (PurchaseOrder po : purchaseOrders) {
                System.out.println("PO: " + po.getPoid() + " - Status: " + po.getStatus() + " - Amount: " + po.getTotalAmount());
            }
            
            req.setAttribute("suppliers", suppliers);
            req.setAttribute("purchaseOrders", purchaseOrders);
            
            req.getRequestDispatcher("/procurement/database-test.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in TestDataServlet: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/procurement/database-test.jsp").forward(req, resp);
        }
    }
}
