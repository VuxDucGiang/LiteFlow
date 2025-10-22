package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import java.io.IOException;

@WebServlet(urlPatterns = {"/procurement/dashboard"})
public class ProcurementDashboardServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // TODO: Load procurement statistics and recent activities
        // For now, just forward to the JSP
        req.getRequestDispatcher("/procurement/dashboard.jsp").forward(req, resp);
    }
}
