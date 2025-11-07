package com.liteflow.controller.procurement;


import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import java.io.IOException;

@WebServlet(urlPatterns = {"/procurement/dashboard"})
public class ProcurementDashboardServlet extends HttpServlet {
   
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
       
        req.getRequestDispatcher("/procurement/dashboard.jsp").forward(req, resp);
    }
}
