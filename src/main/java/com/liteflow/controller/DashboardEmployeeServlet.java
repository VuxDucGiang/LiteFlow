package com.liteflow.controller;

import com.liteflow.service.EmployeeService;
import com.liteflow.service.auth.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "DashboardEmployeeServlet", urlPatterns = {"/dashboard-employee"})
public class DashboardEmployeeServlet extends HttpServlet {

    private final UserService userService = new UserService();
    private final EmployeeService employeeService = new EmployeeService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Load UserRoles từ session hoặc database
        @SuppressWarnings("unchecked")
        List<String> userRoles = (List<String>) req.getSession().getAttribute("UserRoles");
        
        // Nếu chưa có UserRoles trong session, load từ database
        if (userRoles == null || userRoles.isEmpty()) {
            Object userLogin = req.getSession().getAttribute("UserLogin");
            if (userLogin != null) {
                UUID userId = null;
                if (userLogin instanceof UUID) {
                    userId = (UUID) userLogin;
                } else if (userLogin instanceof String) {
                    try {
                        userId = UUID.fromString((String) userLogin);
                    } catch (IllegalArgumentException e) {
                        // Ignore
                    }
                }
                
                if (userId != null) {
                    userRoles = userService.getRoleNames(userId);
                    req.getSession().setAttribute("UserRoles", userRoles);
                    
                    // Load UserEmployeeCode
                    employeeService.getEmployeeByUserID(userId).ifPresent(emp -> {
                        req.getSession().setAttribute("UserEmployeeCode", emp.getEmployeeCode());
                    });
                }
            }
        }
        
        // Kiểm tra role Employee
        boolean isEmployee = false;
        if (userRoles != null) {
            for (String role : userRoles) {
                if ("Employee".equalsIgnoreCase(role)) {
                    isEmployee = true;
                    break;
                }
            }
        }
        
        // Nếu không phải Employee, redirect về dashboard thường
        if (!isEmployee) {
            resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
            return;
        }
        
        req.getRequestDispatcher("/dashboard-employee.jsp").forward(req, resp);
    }
}

