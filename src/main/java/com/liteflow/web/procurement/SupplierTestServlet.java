package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import com.liteflow.model.procurement.Supplier;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/supplier-test"})
public class SupplierTestServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== SUPPLIER TEST SERVLET ===");
            
            // Set proper encoding
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            
            // Load suppliers
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Loaded " + suppliers.size() + " suppliers");
            
            // Set in request scope
            req.setAttribute("suppliers", suppliers);
            
            // Forward to minimal JSP
            System.out.println("Forwarding to supplier-minimal.jsp");
            req.getRequestDispatcher("/procurement/supplier-minimal.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in SupplierTestServlet: " + e.getMessage());
            e.printStackTrace();
            
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("<html><head><meta charset='UTF-8'></head><body><h1>Error</h1><p>" + e.getMessage() + "</p></body></html>");
        }
    }
}
