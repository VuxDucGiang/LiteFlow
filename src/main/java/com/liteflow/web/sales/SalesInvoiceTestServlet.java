package com.liteflow.web.sales;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.IOException;

/**
 * Test servlet to verify SalesInvoice API is accessible
 */
@WebServlet("/api/sales-test")
public class SalesInvoiceTestServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        System.out.println("✅ SalesInvoiceTestServlet - Test endpoint called!");
        
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("message", "Sales Invoice API is working!");
        result.put("timestamp", System.currentTimeMillis());
        result.put("contextPath", request.getContextPath());
        result.put("servletPath", request.getServletPath());
        
        response.getWriter().write(result.toString());
    }
}

