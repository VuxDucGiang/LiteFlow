package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import com.liteflow.model.procurement.Supplier;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/supplier-simple"})
public class SupplierSimpleServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== SUPPLIER SIMPLE SERVLET DEBUG ===");
            
            // Set content type and encoding
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Suppliers loaded: " + suppliers.size());
            
            // Set in request scope for JSP
            req.setAttribute("suppliers", suppliers);
            
            System.out.println("Forwarding to supplier-list-simple.jsp");
            req.getRequestDispatcher("/procurement/supplier-list-simple.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in SupplierSimpleServlet doGet: " + e.getMessage());
            e.printStackTrace();
            
            // Send error response
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("<html><body><h1>Error</h1><p>" + e.getMessage() + "</p></body></html>");
        }
    }
}
