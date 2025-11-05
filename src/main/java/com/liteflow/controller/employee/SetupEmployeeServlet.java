package com.liteflow.controller.employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "SetupEmployeeServlet", urlPatterns = {"/employee/setup"})
public class SetupEmployeeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set page attribute for header menu highlighting
        request.setAttribute("page", "setup-employee");

        // Forward to the setup employee JSP page
        request.getRequestDispatcher("/employee/setupEmployee.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // For any POST requests, redirect to GET
        response.sendRedirect(request.getContextPath() + "/employee/setup");
    }
}
