package com.liteflow.web.procurement;

import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

@WebServlet(urlPatterns = {"/procurement/invoice"})
public class InvoiceServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, jakarta.servlet.ServletException {
        // TODO: Load invoices and completed POs
        req.getRequestDispatcher("/procurement/invoice-matching.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UUID poid = UUID.fromString(req.getParameter("poid"));
        UUID supplierID = UUID.fromString(req.getParameter("supplierID"));
        double total = Double.parseDouble(req.getParameter("total"));
        service.matchInvoice(poid, supplierID, total);
        resp.sendRedirect(req.getContextPath() + "/procurement/invoice?status=matched");
    }
}
