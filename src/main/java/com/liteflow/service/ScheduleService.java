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
        return createShift(employeeCode, date, startTime, endTime, title, notes, location, false);
    }

    public boolean createShift(String employeeCode,
                               java.time.LocalDate date,
                               LocalTime startTime,
                               LocalTime endTime,
                               String title,
                               String notes,
                               String location,
                               boolean isRecurring) {
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
        shift.setIsRecurring(isRecurring);
        // status default = "Scheduled" via entity default

        boolean result = shiftDAO.insert(shift);
        
        // Nếu tạo thành công và là ca lặp lại, tạo các ca tiếp theo
        if (result && isRecurring) {
            for (int week = 1; week <= 4; week++) {
                LocalDate futureDate = date.plusWeeks(week);
                LocalDateTime futureStart = futureDate.atTime(startTime);
                LocalDateTime futureEnd = futureDate.atTime(endTime);
                
                // Kiểm tra xem ca đã tồn tại chưa
                List<EmployeeShift> existingShifts = shiftDAO.findByDateRange(
                    futureStart.minusMinutes(1), 
                    futureEnd.plusMinutes(1)
                );
                
                boolean shiftExists = existingShifts.stream()
                    .anyMatch(s -> s.getEmployee().getEmployeeID().equals(shift.getEmployee().getEmployeeID()) &&
                                  s.getStartAt().equals(futureStart));
                
                if (!shiftExists) {
                    // Tạo ca lặp lại mới
                    EmployeeShift recurringShift = new EmployeeShift();
                    recurringShift.setEmployee(shift.getEmployee());
                    recurringShift.setTitle(shift.getTitle());
                    recurringShift.setNotes(shift.getNotes());
                    recurringShift.setLocation(shift.getLocation());
                    recurringShift.setStartAt(futureStart);
                    recurringShift.setEndAt(futureEnd);
                    recurringShift.setStatus(shift.getStatus());
                    recurringShift.setIsRecurring(false); // Ca con không lặp lại
                    recurringShift.setCreatedBy(shift.getCreatedBy());
                    
                    shiftDAO.insert(recurringShift);
                }
            }
        }
        
        return result;
    }

    /**
     * Xóa ca làm việc theo ID
     */
    public boolean deleteShift(java.util.UUID shiftId) {
        if (shiftId == null) return false;
        return shiftDAO.delete(shiftId);
    }

    /**
     * Toggle trạng thái lặp lại của ca làm việc và tạo các ca lặp lại hằng tuần
     */
    public boolean toggleRecurring(java.util.UUID shiftId, boolean isRecurring) {
        if (shiftId == null) return false;
        
        // Lấy ca làm việc hiện tại
        EmployeeShift originalShift = shiftDAO.findById(shiftId);
        if (originalShift == null) return false;
        originalShift.setIsRecurring(isRecurring);
        
        if (isRecurring) {
            // Tạo các ca lặp lại cho 4 tuần tiếp theo (có thể điều chỉnh số tuần)
            LocalDate originalDate = originalShift.getStartAt().toLocalDate();
            LocalTime startTime = originalShift.getStartAt().toLocalTime();
            LocalTime endTime = originalShift.getEndAt().toLocalTime();
            
            for (int week = 1; week <= 4; week++) {
                LocalDate futureDate = originalDate.plusWeeks(week);
                LocalDateTime futureStart = futureDate.atTime(startTime);
                LocalDateTime futureEnd = futureDate.atTime(endTime);
                
                // Kiểm tra xem ca đã tồn tại chưa
                List<EmployeeShift> existingShifts = shiftDAO.findByDateRange(
                    futureStart.minusMinutes(1), 
                    futureEnd.plusMinutes(1)
                );
                
                boolean shiftExists = existingShifts.stream()
                    .anyMatch(s -> s.getEmployee().getEmployeeID().equals(originalShift.getEmployee().getEmployeeID()) &&
                                  s.getStartAt().equals(futureStart));
                
                if (!shiftExists) {
                    // Tạo ca lặp lại mới
                    EmployeeShift recurringShift = new EmployeeShift();
                    recurringShift.setEmployee(originalShift.getEmployee());
                    recurringShift.setTitle(originalShift.getTitle());
                    recurringShift.setNotes(originalShift.getNotes());
                    recurringShift.setLocation(originalShift.getLocation());
                    recurringShift.setStartAt(futureStart);
                    recurringShift.setEndAt(futureEnd);
                    recurringShift.setStatus(originalShift.getStatus());
                    recurringShift.setIsRecurring(false); // Ca con không lặp lại
                    recurringShift.setCreatedBy(originalShift.getCreatedBy());
                    
                    shiftDAO.insert(recurringShift);
                }
            }
        } else {
            // Nếu tắt lặp lại, xóa các ca lặp lại tương lai (tùy chọn)
            // Ở đây chúng ta chỉ tắt trạng thái lặp lại của ca gốc
        }
        
        return shiftDAO.update(originalShift);
    }

    /**
     * Lấy ca làm việc theo ID
     */
    public EmployeeShift getShiftById(java.util.UUID shiftId) {
        if (shiftId == null) return null;
        return shiftDAO.findById(shiftId);
    }
}


