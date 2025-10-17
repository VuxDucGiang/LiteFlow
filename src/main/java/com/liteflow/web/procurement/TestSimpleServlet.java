package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import com.liteflow.model.procurement.Supplier;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/procurement/test-simple"})
public class TestSimpleServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        try {
            System.out.println("=== TEST SIMPLE SERVLET ===");
            
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Suppliers loaded: " + suppliers.size());
            
            req.setAttribute("suppliers", suppliers);
            req.getRequestDispatcher("/procurement/test-simple.jsp").forward(req, resp);
            
        } catch (Exception e) {
            System.err.println("ERROR in TestSimpleServlet: " + e.getMessage());
            e.printStackTrace();
            
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/procurement/test-simple.jsp").forward(req, resp);
        }
    }
}

