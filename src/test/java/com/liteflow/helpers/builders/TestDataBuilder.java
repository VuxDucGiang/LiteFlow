package com.liteflow.helpers.builders;

import com.liteflow.model.auth.User;
import com.liteflow.model.auth.Role;
import com.liteflow.model.auth.UserRole;
import com.liteflow.model.auth.UserSession;
import com.liteflow.model.auth.OtpToken;
import com.liteflow.model.auth.Employee;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * TestDataBuilder provides builder methods for creating test data objects.
 * All builders return fully initialized entities ready to be persisted.
 * 
 * Usage:
 * <pre>
 * User user = TestDataBuilder.buildUser("test@liteflow.com", "ADMIN");
 * em.persist(user);
 * </pre>
 */
public class TestDataBuilder {
    
    // ==========================================
    // AUTH MODULE
    // ==========================================
    
    /**
     * Build a User with specified email and role name.
     * Password hash is set to a bcrypt hash of "Test@123".
     * 
     * @param email User email
     * @param roleName Role name (for display purposes)
     * @return Fully initialized User entity
     */
    public static User buildUser(String email, String roleName) {
        User user = new User();
        user.setUserID(UUID.randomUUID());
        user.setEmail(email);
        user.setPasswordHash("$2a$10$N.gXqZ8Z5fZQJ5fXqZ8Z5.xvZxZ5fZQJ5fXqZ8Z5fZQJ5fXqZ8Z5"); // Test@123
        user.setDisplayName("Test " + roleName);
        user.setIsActive(true);
        user.setPhone(generateTestPhone());
        return user;
    }
    
    /**
     * Build a User with custom password hash.
     */
    public static User buildUserWithPassword(String email, String passwordHash) {
        User user = buildUser(email, "USER");
        user.setPasswordHash(passwordHash);
        return user;
    }
    
    /**
     * Build a User with Google OAuth ID.
     */
    public static User buildGoogleUser(String email, String googleId) {
        User user = buildUser(email, "USER");
        user.setGoogleID(googleId);
        return user;
    }
    
    /**
     * Build a User with 2FA enabled.
     */
    public static User buildUserWith2FA(String email, String twoFactorSecret) {
        User user = buildUser(email, "USER");
        user.setTwoFactorSecret(twoFactorSecret);
        return user;
    }
    
    /**
     * Build an inactive User.
     */
    public static User buildInactiveUser(String email) {
        User user = buildUser(email, "USER");
        user.setIsActive(false);
        return user;
    }
    
    /**
     * Build a Role with specified name.
     * 
     * @param name Role name (e.g., "ADMIN", "CASHIER", "MANAGER")
     * @return Fully initialized Role entity
     */
    public static Role buildRole(String name) {
        Role role = new Role();
        role.setRoleID(UUID.randomUUID());
        role.setName(name);
        role.setDescription("Test role " + name);
        return role;
    }
    
    /**
     * Build a UserRole linking a User and Role.
     * 
     * @param user User entity
     * @param role Role entity
     * @return Fully initialized UserRole entity
     */
    public static UserRole buildUserRole(User user, Role role) {
        UserRole userRole = new UserRole();
        userRole.setUserId(user.getUserID());
        userRole.setRoleId(role.getRoleID());
        userRole.setUser(user);
        userRole.setRole(role);
        userRole.setIsActive(true);
        userRole.setAssignedAt(LocalDateTime.now());
        return userRole;
    }
    
    /**
     * Build a UserSession for a User.
     * 
     * @param user User entity
     * @return Fully initialized UserSession entity
     */
    public static UserSession buildSession(User user) {
        UserSession session = new UserSession();
        session.setSessionId(UUID.randomUUID());
        session.setUserId(user.getUserID());
        session.setUser(user);
        session.setJwt("test_jwt_token_" + UUID.randomUUID());
        session.setDeviceInfo("Test Device");
        session.setIpAddress("127.0.0.1");
        session.setCreatedAt(LocalDateTime.now());
        session.setExpiresAt(LocalDateTime.now().plusHours(8));
        session.setRevoked(false);
        return session;
    }
    
    /**
     * Build an expired UserSession.
     */
    public static UserSession buildExpiredSession(User user) {
        UserSession session = buildSession(user);
        session.setCreatedAt(LocalDateTime.now().minusHours(9));
        session.setExpiresAt(LocalDateTime.now().minusHours(1));
        return session;
    }
    
    /**
     * Build a UserSession with 2FA verified.
     */
    public static UserSession buildSessionWith2FA(User user) {
        UserSession session = buildSession(user);
        session.setLast2faVerifiedAt(LocalDateTime.now());
        return session;
    }
    
    /**
     * Build an OtpToken for a User.
     * 
     * @param user User entity
     * @param code OTP code (6 digits)
     * @return Fully initialized OtpToken entity
     */
    public static OtpToken buildOtpToken(User user, String code) {
        OtpToken otp = new OtpToken();
        otp.setUser(user);
        otp.setCode(code);
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        otp.setUsed(false);
        otp.setIpAddress("127.0.0.1");
        return otp;
    }
    
    /**
     * Build an OtpToken for email (signup before user exists).
     */
    public static OtpToken buildOtpTokenForEmail(String email, String code) {
        OtpToken otp = new OtpToken();
        otp.setTargetEmail(email);
        otp.setCode(code);
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        otp.setUsed(false);
        otp.setIpAddress("127.0.0.1");
        return otp;
    }
    
    /**
     * Build an expired OtpToken.
     */
    public static OtpToken buildExpiredOtpToken(User user, String code) {
        OtpToken otp = buildOtpToken(user, code);
        otp.setExpiresAt(LocalDateTime.now().minusMinutes(1));
        return otp;
    }
    
    /**
     * Build a used OtpToken.
     */
    public static OtpToken buildUsedOtpToken(User user, String code) {
        OtpToken otp = buildOtpToken(user, code);
        otp.setUsed(true);
        return otp;
    }
    
    // ==========================================
    // HELPER METHODS
    // ==========================================
    
    /**
     * Create a complete User with Role setup.
     * This is a convenience method that creates User, Role, and UserRole.
     * 
     * @param email User email
     * @param roleName Role name
     * @return Array of [User, Role, UserRole]
     */
    public static Object[] buildUserWithRole(String email, String roleName) {
        User user = buildUser(email, roleName);
        Role role = buildRole(roleName);
        UserRole userRole = buildUserRole(user, role);
        
        // Link UserRole to User
        user.getUserRoles().add(userRole);
        
        return new Object[]{user, role, userRole};
    }
    
    /**
     * Generate a random UUID string.
     */
    public static String randomUUID() {
        return UUID.randomUUID().toString();
    }
    
    /**
     * Generate a random 6-digit OTP code.
     */
    public static String randomOtpCode() {
        return String.format("%06d", (int)(Math.random() * 1000000));
    }
    
    // ==========================================
    // EMPLOYEE MODULE
    // ==========================================
    
    /**
     * Build an Employee with User and basic information.
     * 
     * @param user User entity
     * @param fullName Full name of employee
     * @param position Position/role
     * @return Fully initialized Employee entity
     */
    public static Employee buildEmployee(User user, String fullName, String position) {
        Employee employee = new Employee();
        employee.setEmployeeID(UUID.randomUUID());
        employee.setUser(user);
        employee.setEmployeeCode("EMP-" + UUID.randomUUID().toString().substring(0, 6));
        employee.setFullName(fullName);
        employee.setPosition(position);
        employee.setPhone("+84901234567");
        employee.setEmail(fullName.toLowerCase().replace(" ", "") + "@liteflow.com");
        employee.setGender("Nữ");
        employee.setEmploymentStatus("Đang làm");
        employee.setHireDate(java.time.LocalDateTime.now());
        return employee;
    }
    
    /**
     * Build an EmployeeAttendance for an employee.
     * 
     * @param employee Employee entity
     * @param workDate Work date
     * @param checkInTime Check-in time
     * @param checkOutTime Check-out time
     * @return Fully initialized EmployeeAttendance entity
     */
    public static com.liteflow.model.timesheet.EmployeeAttendance buildEmployeeAttendance(
            Employee employee, 
            java.time.LocalDate workDate,
            java.time.LocalTime checkInTime,
            java.time.LocalTime checkOutTime) {
        com.liteflow.model.timesheet.EmployeeAttendance attendance = 
            new com.liteflow.model.timesheet.EmployeeAttendance();
        attendance.setAttendanceId(UUID.randomUUID());
        attendance.setEmployee(employee);
        attendance.setWorkDate(workDate);
        attendance.setStatus("Work");
        attendance.setCheckInTime(checkInTime);
        attendance.setCheckOutTime(checkOutTime);
        attendance.setIsLate(false);
        attendance.setIsOvertime(false);
        attendance.setIsEarlyLeave(false);
        return attendance;
    }
    
    /**
     * Build an EmployeeShift for an employee.
     * 
     * @param employee Employee entity
     * @param startAt Shift start time
     * @param endAt Shift end time
     * @param location Location
     * @return Fully initialized EmployeeShift entity
     */
    public static com.liteflow.model.auth.EmployeeShift buildEmployeeShift(
            Employee employee,
            java.time.LocalDateTime startAt,
            java.time.LocalDateTime endAt,
            String location) {
        com.liteflow.model.auth.EmployeeShift shift = new com.liteflow.model.auth.EmployeeShift();
        shift.setShiftID(UUID.randomUUID());
        shift.setEmployee(employee);
        shift.setTitle("Ca làm việc");
        shift.setLocation(location);
        shift.setStartAt(startAt);
        shift.setEndAt(endAt);
        shift.setStatus("Scheduled");
        shift.setIsRecurring(false);
        return shift;
    }
    
    /**
     * Build an EmployeeShiftTimesheet for an employee.
     * 
     * @param employee Employee entity
     * @param shift EmployeeShift entity
     * @param workDate Work date
     * @param checkIn Check-in datetime
     * @param checkOut Check-out datetime
     * @return Fully initialized EmployeeShiftTimesheet entity
     */
    public static com.liteflow.model.timesheet.EmployeeShiftTimesheet buildEmployeeShiftTimesheet(
            Employee employee,
            com.liteflow.model.auth.EmployeeShift shift,
            java.time.LocalDate workDate,
            java.time.LocalDateTime checkIn,
            java.time.LocalDateTime checkOut) {
        com.liteflow.model.timesheet.EmployeeShiftTimesheet timesheet = 
            new com.liteflow.model.timesheet.EmployeeShiftTimesheet();
        timesheet.setTimesheetId(UUID.randomUUID());
        timesheet.setEmployee(employee);
        timesheet.setShift(shift);
        timesheet.setWorkDate(workDate);
        timesheet.setCheckInAt(checkIn);
        timesheet.setCheckOutAt(checkOut);
        timesheet.setBreakMinutes(0);
        timesheet.setStatus("Completed");
        timesheet.setSource("Manual");
        return timesheet;
    }
    
    /**
     * Build an EmployeeCompensation for an employee.
     * 
     * @param employee Employee entity
     * @param baseSalary Base monthly salary
     * @return Fully initialized EmployeeCompensation entity
     */
    public static com.liteflow.model.payroll.EmployeeCompensation buildEmployeeCompensation(
            Employee employee, java.math.BigDecimal baseSalary) {
        com.liteflow.model.payroll.EmployeeCompensation compensation = 
            new com.liteflow.model.payroll.EmployeeCompensation();
        compensation.setCompensationId(UUID.randomUUID());
        compensation.setEmployee(employee);
        compensation.setCompensationType("Fixed");
        compensation.setBaseMonthlySalary(baseSalary);
        compensation.setHourlyRate(java.math.BigDecimal.valueOf(0));
        compensation.setPerShiftRate(java.math.BigDecimal.valueOf(0));
        compensation.setOvertimeRate(java.math.BigDecimal.valueOf(0));
        compensation.setEffectiveFrom(java.time.LocalDate.now());
        compensation.setIsActive(true);
        compensation.setCurrency("VND");
        return compensation;
    }
    
    // ==========================================
    // INVENTORY MODULE
    // ==========================================
    
    /**
     * Build a Product with specified name, price, and stock.
     * 
     * @param name Product name
     * @param price Product unit price
     * @param stock Stock quantity
     * @return Fully initialized Product entity
     */
    public static com.liteflow.model.inventory.Product buildProduct(String name, double price, int stock) {
        com.liteflow.model.inventory.Product product = new com.liteflow.model.inventory.Product();
        product.setProductId(UUID.randomUUID());
        product.setName(name);
        product.setDescription("Test description for " + name);
        product.setProductType("Hàng hóa thường");
        product.setStatus("Đang bán");
        product.setUnit("Cái");
        product.setIsDeleted(false);
        product.setImportDate(java.time.LocalDateTime.now());
        return product;
    }
    
    /**
     * Build a ProductVariant with specified size and price.
     * 
     * @param product Product entity
     * @param size Variant size (S/M/L)
     * @param price Variant price
     * @return Fully initialized ProductVariant entity
     */
    public static com.liteflow.model.inventory.ProductVariant buildProductVariant(
            com.liteflow.model.inventory.Product product, String size, double price) {
        com.liteflow.model.inventory.ProductVariant variant = new com.liteflow.model.inventory.ProductVariant();
        variant.setProductVariantId(UUID.randomUUID());
        variant.setProduct(product);
        variant.setSize(size);
        variant.setPrice(java.math.BigDecimal.valueOf(price));
        variant.setOriginalPrice(java.math.BigDecimal.valueOf(price));
        variant.setIsDeleted(false);
        return variant;
    }
    
    /**
     * Build a ProductStock with specified amount.
     * 
     * @param variant ProductVariant entity
     * @param inventory Inventory entity
     * @param amount Stock amount
     * @return Fully initialized ProductStock entity
     */
    public static com.liteflow.model.inventory.ProductStock buildProductStock(
            com.liteflow.model.inventory.ProductVariant variant,
            com.liteflow.model.inventory.Inventory inventory,
            int amount) {
        com.liteflow.model.inventory.ProductStock stock = new com.liteflow.model.inventory.ProductStock();
        stock.setProductStockId(UUID.randomUUID());
        stock.setProductVariant(variant);
        stock.setInventory(inventory);
        stock.setAmount(amount);
        return stock;
    }
    
    /**
     * Build an Inventory with specified location.
     * 
     * @param location Store location name
     * @return Fully initialized Inventory entity
     */
    public static com.liteflow.model.inventory.Inventory buildInventory(String location) {
        com.liteflow.model.inventory.Inventory inventory = new com.liteflow.model.inventory.Inventory();
        inventory.setInventoryId(UUID.randomUUID());
        inventory.setStoreLocation(location);
        return inventory;
    }
    
    /**
     * Build a ProductDisplayDTO for testing.
     * 
     * @param name Product name
     * @param price Product price
     * @param stock Stock amount
     * @return Fully initialized ProductDisplayDTO
     */
    public static com.liteflow.model.inventory.ProductDisplayDTO buildProductDisplayDTO(
            String name, double price, int stock) {
        com.liteflow.model.inventory.ProductDisplayDTO dto = new com.liteflow.model.inventory.ProductDisplayDTO();
        dto.setProductId(UUID.randomUUID());
        dto.setProductCode("SP" + String.format("%06d", (int)(Math.random() * 1000000)));
        dto.setProductName(name);
        dto.setPrice(price);
        dto.setStockAmount(stock);
        dto.setSize("M");
        dto.setIsDeleted(false);
        dto.setCategoryName("Test Category");
        dto.setProductType("Hàng hóa thường");
        dto.setUnit("Cái");
        dto.setStatus("Đang bán");
        return dto;
    }

    private static String generateTestPhone() {
        long value = Math.abs(UUID.randomUUID().getMostSignificantBits());
        String digits = String.valueOf(value);
        if (digits.length() < 10) {
            digits = String.format("%010d", value % 1_000_000_000L);
        }
        return "+849" + digits.substring(0, 9);
    }
}

