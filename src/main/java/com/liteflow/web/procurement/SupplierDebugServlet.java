package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import com.liteflow.model.procurement.Supplier;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/supplier-debug"})
public class SupplierDebugServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== SUPPLIER DEBUG SERVLET ===");
            
            // Test database connection
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Suppliers loaded: " + suppliers.size());
            
            if (suppliers.isEmpty()) {
                System.out.println("WARNING: No suppliers found in database");
            } else {
                System.out.println("First supplier: " + suppliers.get(0).getName());
            }
            
            // Set in request scope
            req.setAttribute("suppliers", suppliers);
            
            System.out.println("Forwarding to supplier-debug.jsp");
            req.getRequestDispatcher("/procurement/supplier-debug.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in SupplierDebugServlet: " + e.getMessage());
            e.printStackTrace();
            
            // Set error in request
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/procurement/supplier-debug.jsp").forward(req, resp);
        }
    }
}

