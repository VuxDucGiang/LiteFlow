package com.liteflow.service;

import com.liteflow.dao.employee.EmployeeShiftDAO;
import com.liteflow.dao.employee.ShiftTemplateDAO;
import com.liteflow.model.auth.Employee;
import com.liteflow.model.auth.EmployeeShift;
import com.liteflow.model.auth.ShiftTemplate;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

    /**
     * Tạo ca làm việc mới
     */
public class ScheduleService {

    private final EmployeeShiftDAO shiftDAO = new EmployeeShiftDAO();
    private final ShiftTemplateDAO templateDAO = new ShiftTemplateDAO();
    private final EmployeeService employeeService = new EmployeeService();

    public List<EmployeeShift> getShiftsForWeek(LocalDate weekStart) {
        LocalDateTime start = weekStart.atStartOfDay();
        LocalDateTime end = weekStart.plusDays(7).atStartOfDay();
        return new ArrayList<>(shiftDAO.findByDateRange(start, end));
    }

    public List<ShiftTemplate> getActiveTemplates() {
        return templateDAO.findActiveOrdered();
    }

    public boolean createShift(String employeeCode,
                               java.time.LocalDate date,
                               LocalTime startTime,
                               LocalTime endTime,
                               String title,
                               String notes,
                               String location) {
        if (employeeCode == null || employeeCode.isBlank() || date == null || startTime == null || endTime == null) {
            return false;
        }
        if (!endTime.isAfter(startTime)) {
            return false;
        }

        Optional<Employee> empOpt = employeeService.getEmployeeByCode(employeeCode);
        if (empOpt.isEmpty()) {
            return false;
        }

        EmployeeShift shift = new EmployeeShift();
        shift.setEmployee(empOpt.get());
        shift.setTitle(title);
        shift.setNotes(notes);
        shift.setLocation(location);
        shift.setStartAt(date.atTime(startTime));
        shift.setEndAt(date.atTime(endTime));
        // status default = "Scheduled" via entity default

        return shiftDAO.insert(shift);
    }
}


