package com.liteflow.web.settings;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet to display Settings page
 */
@WebServlet("/settings")
public class SettingsPageServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in (all logged-in users can access settings page)
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        
        // Check if user has UserLogin attribute (indicates logged in)
        Object userLogin = session.getAttribute("UserLogin");
        if (userLogin == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        
        // Forward to JSP page (role-based filtering will be done in JSP)
        request.getRequestDispatcher("/settings.jsp").forward(request, response);
    }
}

