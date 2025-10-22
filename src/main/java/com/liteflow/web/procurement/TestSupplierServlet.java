package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import com.liteflow.model.procurement.Supplier;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/test-supplier"})
public class TestSupplierServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== TEST SUPPLIER SERVLET DEBUG ===");
            
            // Set content type and encoding
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Suppliers loaded: " + suppliers.size());
            
            // Set in request scope for JSP
            req.setAttribute("suppliers", suppliers);
            
            System.out.println("Forwarding to test-supplier.jsp");
            req.getRequestDispatcher("/procurement/test-supplier.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in TestSupplierServlet doGet: " + e.getMessage());
            e.printStackTrace();
            
            // Send error response with proper encoding
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("<html><head><meta charset='UTF-8'></head><body><h1>Lỗi hệ thống</h1><p>" + e.getMessage() + "</p></body></html>");
            resp.getWriter().flush();
        }
    }
}
