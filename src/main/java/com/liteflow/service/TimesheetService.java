package com.liteflow.service;

import com.liteflow.dao.timesheet.EmployeeShiftTimesheetDAO;
import com.liteflow.dao.timesheet.EmployeeAttendanceDAO;
import com.liteflow.model.timesheet.EmployeeShiftTimesheet;
import com.liteflow.model.timesheet.EmployeeAttendance;
import com.liteflow.dao.employee.EmployeeDAO;
import com.liteflow.model.auth.Employee;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class TimesheetService {

    private final EmployeeShiftTimesheetDAO timesheetDAO = new EmployeeShiftTimesheetDAO();
    private final EmployeeAttendanceDAO attendanceDAO = new EmployeeAttendanceDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();

    public List<EmployeeShiftTimesheet> getTimesheetsForWeek(LocalDate weekStart) {
        if (weekStart == null) return new ArrayList<>();
        LocalDate start = weekStart;
        LocalDate end = weekStart.plusDays(6);
        return new ArrayList<>(timesheetDAO.findByWorkDateRange(start, end));
    }

    public List<EmployeeAttendance> getAttendanceForWeek(LocalDate weekStart) {
        if (weekStart == null) return new ArrayList<>();
        LocalDate start = weekStart;
        LocalDate end = weekStart.plusDays(6);
        return new ArrayList<>(attendanceDAO.findByWorkDateRange(start, end));
    }

    public EmployeeAttendance upsertAttendance(String employeeCode, LocalDate workDate, String status,
                                               String checkIn, String checkOut) {
        if (employeeCode == null || employeeCode.isBlank() || workDate == null || status == null || status.isBlank()) {
            return null;
        }
        Employee emp = employeeDAO.findByEmployeeCode(employeeCode.trim());
        if (emp == null) return null;

        EmployeeAttendance att = attendanceDAO.findByEmployeeAndDate(emp.getEmployeeID(), workDate);
        if (att == null) {
            att = new EmployeeAttendance();
            att.setEmployee(emp);
            att.setWorkDate(workDate);
        }
        // Map UI values to DB values
        String st;
        switch (status) {
            case "work": st = "Work"; break;
            case "leave_paid": st = "LeavePaid"; break;
            case "leave_unpaid": st = "LeaveUnpaid"; break;
            default: st = "Work";
        }
        att.setStatus(st);

        LocalTime inT = null;
        LocalTime outT = null;
        try { if (checkIn != null && !checkIn.isBlank()) inT = LocalTime.parse(checkIn); } catch (Exception ignored) {}
        try { if (checkOut != null && !checkOut.isBlank()) outT = LocalTime.parse(checkOut); } catch (Exception ignored) {}
        att.setCheckInTime(inT);
        att.setCheckOutTime(outT);

        if (att.getAttendanceId() == null) {
            attendanceDAO.insert(att);
        } else {
            attendanceDAO.update(att);
        }
        return att;
    }
}


