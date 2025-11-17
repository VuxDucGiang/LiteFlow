package com.liteflow.controller.employee;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.auth.Employee;
import com.liteflow.model.auth.User;
import com.liteflow.service.auth.UserService;
import com.liteflow.service.employee.EmployeeService;
import com.liteflow.util.PasswordUtil;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

// @WebServlet annotation removed - using web.xml mapping
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
            
            // Tạo Map để lưu passwordHash theo employeeCode (tránh LazyInitializationException)
            // Query passwordHash trực tiếp từ database bằng cách JOIN với User table
            Map<String, String> passwordMap = new HashMap<>();
            if (employees != null && !employees.isEmpty() && BaseDAO.emf != null) {
                EntityManager em = BaseDAO.emf.createEntityManager();
                try {
                    // Query tất cả passwordHash cùng lúc bằng JOIN
                    String jpql = "SELECT e.employeeCode, u.passwordHash " +
                                 "FROM Employee e " +
                                 "LEFT JOIN e.user u " +
                                 "WHERE e.employeeCode IN :codes";
                    
                    List<String> employeeCodes = new java.util.ArrayList<>();
                    for (Employee emp : employees) {
                        if (emp.getEmployeeCode() != null) {
                            employeeCodes.add(emp.getEmployeeCode());
                        }
                    }
                    
                    if (!employeeCodes.isEmpty()) {
                        jakarta.persistence.Query query = em.createQuery(jpql);
                        query.setParameter("codes", employeeCodes);
                        @SuppressWarnings("unchecked")
                        List<Object[]> results = query.getResultList();
                        
                        for (Object[] result : results) {
                            String code = (String) result[0];
                            String passwordHash = result[1] != null ? (String) result[1] : "";
                            passwordMap.put(code, passwordHash);
                        }
                    }
                    
                    // Đảm bảo tất cả employees đều có entry trong map
                    for (Employee emp : employees) {
                        if (emp.getEmployeeCode() != null && !passwordMap.containsKey(emp.getEmployeeCode())) {
                            passwordMap.put(emp.getEmployeeCode(), "");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("⚠️ Error loading passwords: " + e.getMessage());
                    e.printStackTrace();
                    // Fallback: set empty password cho tất cả
                    for (Employee emp : employees) {
                        if (emp.getEmployeeCode() != null) {
                            passwordMap.put(emp.getEmployeeCode(), "");
                        }
                    }
                } finally {
                    em.close();
                }
            }
            
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
            request.setAttribute("passwordMap", passwordMap);
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
        
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Validation
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Họ tên không được để trống");
            return;
        }

        if (phone == null || phone.trim().isEmpty()) {
            request.setAttribute("error", "Số điện thoại không được để trống");
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email không được để trống");
            return;
        }

        if (password == null || password.trim().isEmpty() || password.length() < 8) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 8 ký tự");
            return;
        }

        email = email.trim().toLowerCase();
        phone = phone.trim();
        fullName = fullName.trim();

        try {
            UserService userService = new UserService();
            
            // Kiểm tra email đã tồn tại chưa
            if (userService.findByEmail(email) != null) {
                request.setAttribute("error", "Email đã được sử dụng. Vui lòng chọn email khác.");
                return;
            }

            // Kiểm tra phone đã tồn tại chưa
            if (userService.findByPhone(phone) != null) {
                request.setAttribute("error", "Số điện thoại đã được sử dụng. Vui lòng chọn số khác.");
                return;
            }

            // Tạo User trước
            User user = new User();
            user.setUserID(UUID.randomUUID());
            user.setEmail(email);
            user.setPhone(phone);
            user.setDisplayName(fullName);
            // Hash mật khẩu
            String passwordHash = PasswordUtil.hash(password, 12);
            user.setPasswordHash(passwordHash);
            user.setIsActive(true);

            boolean userCreated = userService.createUser(user);
            if (!userCreated) {
                request.setAttribute("error", "Không thể tạo tài khoản người dùng");
                return;
            }

            // Gán role Employee cho User
            try {
                String clientIp = request.getRemoteAddr();
                userService.assignRole(user.getUserID(), "Employee", clientIp);
            } catch (Exception e) {
                System.err.println("⚠️ Warning: Could not assign Employee role: " + e.getMessage());
                // Tiếp tục tạo Employee dù không gán được role
            }

            // Tự động sinh employeeCode
            String employeeCode = generateEmployeeCode();
            
            // Tạo Employee
            Employee employee = new Employee();
            employee.setEmployeeCode(employeeCode);
            employee.setFullName(fullName);
            employee.setPhone(phone);
            employee.setEmail(email);
            employee.setUser(user);
            employee.setEmploymentStatus("Đang làm");

            boolean employeeCreated = employeeService.createEmployee(employee);
            
            if (employeeCreated) {
                request.setAttribute("success", "Thêm nhân viên thành công! Mã nhân viên: " + employeeCode);
                System.out.println("✅ Thêm nhân viên thành công: " + fullName + " (Code: " + employeeCode + ")");
            } else {
                // Rollback: xóa User nếu không tạo được Employee
                // Note: Có thể cần thêm logic xóa User nếu cần
                request.setAttribute("error", "Tạo tài khoản thành công nhưng không thể tạo thông tin nhân viên");
                System.out.println("❌ Lỗi khi tạo Employee sau khi đã tạo User: " + fullName);
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi tạo nhân viên: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }
    }

    /**
     * Tự động sinh mã nhân viên (EMP001, EMP002, ...)
     */
    private String generateEmployeeCode() {
        try {
            List<Employee> allEmployees = employeeService.getAllEmployees();
            int maxNumber = 0;
            
            for (Employee emp : allEmployees) {
                String code = emp.getEmployeeCode();
                if (code != null && code.startsWith("EMP")) {
                    try {
                        String numberPart = code.substring(3);
                        int number = Integer.parseInt(numberPart);
                        if (number > maxNumber) {
                            maxNumber = number;
                        }
                    } catch (NumberFormatException e) {
                        // Bỏ qua nếu không parse được
                    }
                }
            }
            
            maxNumber++;
            return String.format("EMP%03d", maxNumber);
        } catch (Exception e) {
            System.err.println("⚠️ Error generating employee code: " + e.getMessage());
            // Fallback: sử dụng timestamp
            return "EMP" + System.currentTimeMillis() % 10000;
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
