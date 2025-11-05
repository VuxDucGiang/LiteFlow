package com.liteflow.controller.report;

import com.liteflow.service.report.RevenueReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.IOException;
import java.time.LocalDate;

/**
 * Test servlet to debug revenue report API
 * Access: /report/test-api
 */
@WebServlet("/report/test-api")
public class TestRevenueAPIServlet extends HttpServlet {
    
    private final RevenueReportService reportService;
    
    public TestRevenueAPIServlet() {
        this.reportService = new RevenueReportService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            LocalDate endDate = LocalDate.now();
            LocalDate startDate = endDate.minusDays(30);
            
            System.out.println("🧪 TEST API: Generating report from " + startDate + " to " + endDate);
            
            JSONObject report = reportService.generateReport(startDate, endDate);
            
            // Debug output
            System.out.println("📊 Total Revenue: " + report.optDouble("totalRevenue", 0));
            System.out.println("📦 Total Orders: " + report.optLong("totalOrders", 0));
            System.out.println("🏆 Top Products: " + report.optJSONArray("topProducts"));
            System.out.println("📈 Category Data: " + report.optJSONObject("productData"));
            
            report.put("success", true);
            report.put("testMode", true);
            report.put("startDate", startDate.toString());
            report.put("endDate", endDate.toString());
            
            response.getWriter().write(report.toString(2)); // Pretty print with indent
            
        } catch (Exception e) {
            System.err.println("❌ TEST API Error: " + e.getMessage());
            e.printStackTrace();
            
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("error", e.getMessage());
            error.put("errorClass", e.getClass().getName());
            
            response.getWriter().write(error.toString(2));
        }
    }
}

