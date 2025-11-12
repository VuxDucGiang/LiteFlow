package com.liteflow.service.payroll;

import com.liteflow.dao.employee.EmployeeDAO;
import com.liteflow.dao.payroll.PayrollEntryDAO;
import com.liteflow.dao.payroll.PayPeriodDAO;
import com.liteflow.dao.payroll.PayrollRunDAO;
import com.liteflow.model.auth.Employee;
import com.liteflow.model.payroll.PayPeriod;
import com.liteflow.model.payroll.PayrollEntry;
import com.liteflow.model.payroll.PayrollRun;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

/**
 * Service for managing payroll entries and payments
 */
public class PayrollService {

    private final PayrollEntryDAO payrollEntryDAO;
    private final PayrollCalculationService calculationService;
    private final EmployeeDAO employeeDAO;
    private final PayPeriodDAO payPeriodDAO;
    private final PayrollRunDAO payrollRunDAO;

    public PayrollService() {
        this.payrollEntryDAO = new PayrollEntryDAO();
        this.calculationService = new PayrollCalculationService();
        this.employeeDAO = new EmployeeDAO();
        this.payPeriodDAO = new PayPeriodDAO();
        this.payrollRunDAO = new PayrollRunDAO();
    }

    /**
     * Get payroll list for all employees in a specific month
     */
    public List<PayrollEntryDTO> getPayrollForMonth(int month, int year) {
        List<PayrollEntryDTO> result = new ArrayList<>();
        
        // Get all active employees
        List<Employee> employees = employeeDAO.getActiveEmployees();
        
        for (Employee employee : employees) {
            PayrollEntryDTO dto = getPayrollForEmployee(employee.getEmployeeID(), month, year);
            if (dto != null) {
                result.add(dto);
            }
        }
        
        return result;
    }

    /**
     * Get payroll for a specific employee in a month
     */
    public PayrollEntryDTO getPayrollForEmployee(UUID employeeId, int month, int year) {
        Employee employee = employeeDAO.findById(employeeId);
        if (employee == null) {
            return null;
        }

        // Check if payroll entry exists
        PayrollEntry existingEntry = payrollEntryDAO.findByEmployeeAndMonthYear(employeeId, month, year);
        
        if (existingEntry == null) {
            // Create payroll entry if it doesn't exist
            existingEntry = createPayrollEntry(employeeId, month, year);
        }

        if (existingEntry == null) {
            return null;
        }

        // Calculate current salary
        PayrollCalculationService.MonthlySalaryResult salaryResult = 
            calculationService.calculateMonthlySalary(employeeId, month, year);
        
        BigDecimal totalPaid = payrollEntryDAO.getTotalPaidForMonth(employeeId, month, year);
        BigDecimal totalRemaining = salaryResult.getTotalSalary()
            .subtract(salaryResult.getDeductions())
            .subtract(totalPaid);

        PayrollEntryDTO dto = new PayrollEntryDTO();
        dto.setPayrollEntryId(existingEntry.getPayrollEntryId());
        dto.setEmployeeId(employeeId);
        dto.setEmployeeCode(employee.getEmployeeCode());
        dto.setEmployeeName(employee.getFullName());
        dto.setCompensationType(existingEntry.getCompensationType());
        dto.setTotalSalary(salaryResult.getTotalSalary());
        dto.setAllowances(salaryResult.getAllowances());
        dto.setBonuses(salaryResult.getBonuses());
        dto.setDeductions(salaryResult.getDeductions());
        dto.setTotalPaid(totalPaid);
        dto.setTotalRemaining(totalRemaining);
        dto.setIsPaid(existingEntry.getIsPaid());
        
        return dto;
    }

    /**
     * Create a new payroll entry for an employee in a month
     */
    private PayrollEntry createPayrollEntry(UUID employeeId, int month, int year) {
        try {
            // Get or create pay period for the month
            PayPeriod payPeriod = getOrCreatePayPeriod(month, year);
            
            // Get or create payroll run
            PayrollRun payrollRun = getOrCreatePayrollRun(payPeriod);
            
            // Calculate salary
            PayrollCalculationService.MonthlySalaryResult salaryResult = 
                calculationService.calculateMonthlySalary(employeeId, month, year);
            
            Employee employee = employeeDAO.findById(employeeId);
            if (employee == null) {
                return null;
            }

            // Create payroll entry
            PayrollEntry entry = new PayrollEntry();
            entry.setPayrollRun(payrollRun);
            entry.setEmployee(employee);
            
            // Get compensation type from active compensation
            com.liteflow.dao.payroll.EmployeeCompensationDAO compDAO = 
                new com.liteflow.dao.payroll.EmployeeCompensationDAO();
            com.liteflow.model.payroll.EmployeeCompensation compensation = 
                compDAO.getActiveCompensation(employeeId);
            
            if (compensation != null) {
                entry.setCompensationType(compensation.getCompensationType());
                entry.setBaseSalary(compensation.getBaseMonthlySalary());
                entry.setHourlyRate(compensation.getHourlyRate());
                entry.setPerShiftRate(compensation.getPerShiftRate());
                entry.setAllowances(compensation.getAllowanceAmount() != null ? 
                    compensation.getAllowanceAmount() : BigDecimal.ZERO);
                entry.setBonuses(compensation.getBonusAmount() != null ? 
                    compensation.getBonusAmount() : BigDecimal.ZERO);
                entry.setDeductions(compensation.getDeductionAmount() != null ? 
                    compensation.getDeductionAmount() : BigDecimal.ZERO);
            } else {
                entry.setCompensationType("Fixed");
                entry.setAllowances(BigDecimal.ZERO);
                entry.setBonuses(BigDecimal.ZERO);
                entry.setDeductions(BigDecimal.ZERO);
            }
            
            // Set hours/shifts worked
            if ("Hybrid".equals(entry.getCompensationType())) {
                BigDecimal hours = calculationService.getTotalHoursWorked(employeeId, month, year);
                entry.setHoursWorked(hours);
            } else if ("PerShift".equals(entry.getCompensationType())) {
                int shifts = calculationService.getShiftsWorked(employeeId, month, year);
                entry.setShiftsWorked(shifts);
            }
            
            entry.setGrossPay(salaryResult.getTotalSalary());
            entry.setNetPay(salaryResult.getTotalSalary().subtract(salaryResult.getDeductions()));
            entry.setIsPaid(false);
            
            payrollEntryDAO.insert(entry);
            return entry;
        } catch (Exception e) {
            System.err.println("Error creating payroll entry: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Get or create pay period for a month
     */
    private PayPeriod getOrCreatePayPeriod(int month, int year) {
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = LocalDate.of(year, month, startDate.lengthOfMonth());
        
        // Try to find existing pay period
        List<PayPeriod> periods = payPeriodDAO.getAll();
        for (PayPeriod period : periods) {
            if (period.getStartDate().equals(startDate) && 
                period.getEndDate().equals(endDate)) {
                return period;
            }
        }
        
        // Create new pay period
        PayPeriod period = new PayPeriod();
        period.setName("Tháng " + month + "/" + year);
        period.setPeriodType("Monthly");
        period.setStartDate(startDate);
        period.setEndDate(endDate);
        period.setStatus("Open");
        payPeriodDAO.insert(period);
        return period;
    }

    /**
     * Get or create payroll run for a pay period
     */
    private PayrollRun getOrCreatePayrollRun(PayPeriod payPeriod) {
        // Try to find existing run
        List<PayrollRun> runs = payrollRunDAO.getAll();
        for (PayrollRun run : runs) {
            if (run.getPayPeriod().getPayPeriodId().equals(payPeriod.getPayPeriodId())) {
                return run;
            }
        }
        
        // Create new run
        PayrollRun run = new PayrollRun();
        run.setPayPeriod(payPeriod);
        run.setRunNumber(1);
        run.setStatus("Draft");
        payrollRunDAO.insert(run);
        return run;
    }

    /**
     * Mark payroll entry as paid
     */
    public boolean markAsPaid(UUID payrollEntryId) {
        return payrollEntryDAO.markAsPaid(payrollEntryId);
    }

    /**
     * DTO for payroll entry display
     */
    public static class PayrollEntryDTO {
        private UUID payrollEntryId;
        private UUID employeeId;
        private String employeeCode;
        private String employeeName;
        private String compensationType;
        private BigDecimal totalSalary;
        private BigDecimal allowances;
        private BigDecimal bonuses;
        private BigDecimal deductions;
        private BigDecimal totalPaid;
        private BigDecimal totalRemaining;
        private Boolean isPaid;

        // Getters and setters
        public UUID getPayrollEntryId() { return payrollEntryId; }
        public void setPayrollEntryId(UUID payrollEntryId) { this.payrollEntryId = payrollEntryId; }
        public UUID getEmployeeId() { return employeeId; }
        public void setEmployeeId(UUID employeeId) { this.employeeId = employeeId; }
        public String getEmployeeCode() { return employeeCode; }
        public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }
        public String getEmployeeName() { return employeeName; }
        public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
        public String getCompensationType() { return compensationType; }
        public void setCompensationType(String compensationType) { this.compensationType = compensationType; }
        public BigDecimal getTotalSalary() { return totalSalary; }
        public void setTotalSalary(BigDecimal totalSalary) { this.totalSalary = totalSalary; }
        public BigDecimal getAllowances() { return allowances; }
        public void setAllowances(BigDecimal allowances) { this.allowances = allowances; }
        public BigDecimal getBonuses() { return bonuses; }
        public void setBonuses(BigDecimal bonuses) { this.bonuses = bonuses; }
        public BigDecimal getDeductions() { return deductions; }
        public void setDeductions(BigDecimal deductions) { this.deductions = deductions; }
        public BigDecimal getTotalPaid() { return totalPaid; }
        public void setTotalPaid(BigDecimal totalPaid) { this.totalPaid = totalPaid; }
        public BigDecimal getTotalRemaining() { return totalRemaining; }
        public void setTotalRemaining(BigDecimal totalRemaining) { this.totalRemaining = totalRemaining; }
        public Boolean getIsPaid() { return isPaid; }
        public void setIsPaid(Boolean isPaid) { this.isPaid = isPaid; }
    }
}

