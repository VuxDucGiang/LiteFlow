package com.liteflow.service;

import com.liteflow.dao.employee.EmployeeShiftDAO;
import com.liteflow.model.auth.EmployeeShift;
import com.liteflow.model.auth.ShiftTemplate;
import com.liteflow.dao.employee.ShiftTemplateDAO;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ScheduleService {

    private final EmployeeShiftDAO shiftDAO = new EmployeeShiftDAO();
    private final ShiftTemplateDAO templateDAO = new ShiftTemplateDAO();

    public List<EmployeeShift> getShiftsForWeek(LocalDate weekStart) {
        LocalDateTime start = weekStart.atStartOfDay();
        LocalDateTime end = weekStart.plusDays(7).atStartOfDay();
        return new ArrayList<>(shiftDAO.findByDateRange(start, end));
    }

    public List<ShiftTemplate> getActiveTemplates() {
        return templateDAO.findActiveOrdered();
    }
}


