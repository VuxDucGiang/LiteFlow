package com.liteflow.controller;

import com.liteflow.model.auth.Employee;
import com.liteflow.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "EmployeeServlet", urlPatterns = {"/employees"})
public class EmployeeServlet extends HttpServlet {

    private EmployeeService employeeService;

    @Override
    public void init() throws ServletException {
        employeeService = new EmployeeService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Kiểm tra employeeService
            if (employeeService == null) {
                employeeService = new EmployeeService();
            }
            
            // Lấy danh sách employees
            List<Employee> employees = employeeService.getAllEmployees();
            
            // Lấy thống kê
            EmployeeService.EmployeeStatistics stats = employeeService.getEmployeeStatistics();

            // Đảm bảo stats không null
            if (stats == null) {
                stats = new EmployeeService.EmployeeStatistics();
                stats.totalEmployees = 0;
                stats.activeEmployees = 0;
                stats.inactiveEmployees = 0;
                stats.managerCount = 0;
                stats.staffCount = 0;
                stats.cashierCount = 0;
                stats.chefCount = 0;
            }

            // Gửi sang JSP
            request.setAttribute("employees", employees);
            request.setAttribute("stats", stats);
            request.getRequestDispatcher("/employee/employeeList.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong EmployeeServlet: " + e.getMessage());
            e.printStackTrace();
            
            // Gửi lỗi về JSP thay vì response trực tiếp
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.setAttribute("employees", null);
            
            // Tạo stats object mặc định
            EmployeeService.EmployeeStatistics defaultStats = new EmployeeService.EmployeeStatistics();
            defaultStats.totalEmployees = 0;
            defaultStats.activeEmployees = 0;
            defaultStats.managerCount = 0;
            request.setAttribute("stats", defaultStats);
            try {
                request.getRequestDispatcher("/employee/employeeList.jsp").forward(request, response);
            } catch (Exception ex) {
                response.getWriter().println("Lỗi: " + e.getMessage());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set encoding for form data
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String action = request.getParameter("action");
            System.out.println("Action: " + action);

            if ("create".equals(action)) {
                handleCreateEmployee(request, response);
            } else if ("update".equals(action)) {
                handleUpdateEmployee(request, response);
            } else if ("delete".equals(action)) {
                handleDeleteEmployee(request, response);
            }

            // Redirect về trang danh sách
            doGet(request, response);
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong EmployeeServlet POST: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }

    private void handleCreateEmployee(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("=== DEBUG: Creating Employee ===");
        
        String employeeCode = request.getParameter("employeeCode");
        String fullName = request.getParameter("fullName");
        String nationalID = request.getParameter("nationalID");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String position = request.getParameter("position");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");

        System.out.println("Employee Code: " + employeeCode);
        System.out.println("Full Name: " + fullName);

        // Validation
        if (employeeCode == null || employeeCode.trim().isEmpty()) {
            request.setAttribute("error", "Mã nhân viên không được để trống");
            return;
        }

        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Họ tên không được để trống");
            return;
        }

        if (phone == null || phone.trim().isEmpty()) {
            request.setAttribute("error", "Số điện thoại không được để trống");
            return;
        }

        // Create employee
        Employee employee = new Employee();
        employee.setEmployeeCode(employeeCode.trim());
        employee.setFullName(fullName.trim());
        employee.setNationalID(nationalID != null ? nationalID.trim() : null);
        employee.setPhone(phone.trim());
        employee.setEmail(email != null ? email.trim() : null);
        employee.setPosition(position != null ? position.trim() : null);
        employee.setGender(gender != null ? gender.trim() : null);
        employee.setAddress(address != null ? address.trim() : null);
        employee.setEmploymentStatus("Đang làm");

        boolean success = employeeService.createEmployee(employee);
        
        if (success) {
            request.setAttribute("success", "Thêm nhân viên thành công!");
            System.out.println("✅ Thêm nhân viên thành công: " + fullName);
        } else {
            request.setAttribute("error", "Có lỗi xảy ra khi thêm nhân viên");
            System.out.println("❌ Lỗi khi thêm nhân viên: " + fullName);
        }
    }

    private void handleUpdateEmployee(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("=== DEBUG: Updating Employee ===");

        String employeeCode = request.getParameter("employeeCode");
        if (employeeCode == null || employeeCode.trim().isEmpty()) {
            request.setAttribute("error", "Thiếu mã nhân viên để cập nhật");
            return;
        }

        try {
            var optEmp = employeeService.getEmployeeByCode(employeeCode.trim());
            if (optEmp.isEmpty()) {
                request.setAttribute("error", "Không tìm thấy nhân viên: " + employeeCode);
                return;
            }

            Employee employee = optEmp.get();

            String fullName = request.getParameter("fullName");
            String nationalID = request.getParameter("nationalID");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            String position = request.getParameter("position");
            String gender = request.getParameter("gender");
            String address = request.getParameter("address");
            String employmentStatus = request.getParameter("employmentStatus");
            String bankName = request.getParameter("bankName");
            String bankAccount = request.getParameter("bankAccount");
            String notes = request.getParameter("notes");
            String salaryStr = request.getParameter("salary");
            String birthDateStr = request.getParameter("birthDate");

            if (fullName != null) employee.setFullName(fullName.trim());
            if (nationalID != null) employee.setNationalID(nationalID.trim());
            if (phone != null) employee.setPhone(phone.trim());
            if (email != null) employee.setEmail(email.trim());
            if (position != null) employee.setPosition(position.trim());
            if (gender != null) employee.setGender(gender.trim());
            if (address != null) employee.setAddress(address.trim());
            if (employmentStatus != null) employee.setEmploymentStatus(employmentStatus.trim());
            if (bankName != null) employee.setBankName(bankName.trim());
            if (bankAccount != null) employee.setBankAccount(bankAccount.trim());
            if (notes != null) employee.setNotes(notes.trim());

            if (salaryStr != null && !salaryStr.trim().isEmpty()) {
                try {
                    employee.setSalary(new java.math.BigDecimal(salaryStr.trim()));
                } catch (NumberFormatException nfe) {
                    System.err.println("⚠️ Salary parse error: " + salaryStr);
                }
            }

            if (birthDateStr != null && !birthDateStr.trim().isEmpty()) {
                try {
                    employee.setBirthDate(java.time.LocalDate.parse(birthDateStr.trim()));
                } catch (Exception pe) {
                    System.err.println("⚠️ BirthDate parse error: " + birthDateStr);
                }
            }

            boolean ok = employeeService.updateEmployee(employee);
            if (ok) {
                request.setAttribute("success", "Cập nhật nhân viên thành công");
            } else {
                request.setAttribute("error", "Cập nhật nhân viên thất bại");
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi cập nhật nhân viên: " + e.getMessage());
            request.setAttribute("error", "Có lỗi xảy ra khi cập nhật");
        }
    }

    private void handleDeleteEmployee(HttpServletRequest request, HttpServletResponse response) {
        // Implementation for delete
        System.out.println("Delete employee functionality");
    }
}
