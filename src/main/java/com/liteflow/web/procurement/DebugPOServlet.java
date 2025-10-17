package com.liteflow.web.procurement;

import com.liteflow.model.procurement.Supplier;
import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/debug-po"})
public class DebugPOServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== DEBUG PO SERVLET START ===");
            
            // Check session
            HttpSession session = req.getSession(false);
            String userLogin = session != null ? (String) session.getAttribute("UserLogin") : null;
            System.out.println("UserLogin from session: " + userLogin);
            
            // Load data
            System.out.println("Loading suppliers...");
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Suppliers loaded: " + suppliers.size());
            
            System.out.println("Loading purchase orders...");
            List<PurchaseOrder> purchaseOrders = service.getAllPOs();
            System.out.println("Purchase orders loaded: " + purchaseOrders.size());
            
            // Print sample data
            if (!suppliers.isEmpty()) {
                Supplier firstSupplier = suppliers.get(0);
                System.out.println("First supplier: " + firstSupplier.getName() + " (ID: " + firstSupplier.getSupplierID() + ")");
            }
            
            if (!purchaseOrders.isEmpty()) {
                PurchaseOrder firstPO = purchaseOrders.get(0);
                System.out.println("First PO: " + firstPO.getPoid() + " - Status: " + firstPO.getStatus() + " - Amount: " + firstPO.getTotalAmount());
            }
            
            // Set attributes
            req.setAttribute("suppliers", suppliers);
            req.setAttribute("purchaseOrders", purchaseOrders);
            
            System.out.println("Forwarding to debug JSP...");
            req.getRequestDispatcher("/procurement/debug-po.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in DebugPOServlet: " + e.getMessage());
            e.printStackTrace();
            
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/procurement/debug-po.jsp").forward(req, resp);
        }
        
        System.out.println("=== DEBUG PO SERVLET END ===");
    }
}






