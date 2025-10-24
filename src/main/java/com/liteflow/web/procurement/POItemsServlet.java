package com.liteflow.web.procurement;

import com.liteflow.model.procurement.PurchaseOrderItem;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.UUID;

// @WebServlet(urlPatterns = {"/procurement/po-items"})  // Disabled - using web.xml
public class POItemsServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String poidStr = req.getParameter("poid");
            
            if (poidStr == null || poidStr.isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("[]");
                return;
            }

            UUID poid = UUID.fromString(poidStr);
            List<PurchaseOrderItem> items = service.getPOItems(poid);
            
            // Set response as JSON
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            
            PrintWriter out = resp.getWriter();
            out.write("[");
            
            if (items != null && !items.isEmpty()) {
                for (int i = 0; i < items.size(); i++) {
                    PurchaseOrderItem item = items.get(i);
                    out.write("{");
                    out.write("\"itemID\":" + item.getItemID() + ",");
                    out.write("\"itemName\":\"" + escapeJson(item.getItemName()) + "\",");
                    out.write("\"quantity\":" + item.getQuantity() + ",");
                    out.write("\"unitPrice\":" + item.getUnitPrice());
                    out.write("}");
                    
                    if (i < items.size() - 1) {
                        out.write(",");
                    }
                }
            }
            
            out.write("]");
            out.flush();
            
        } catch (Exception e) {
            System.err.println("ERROR in POItemsServlet: " + e.getMessage());
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("[]");
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

