package com.liteflow.controller;

import com.liteflow.model.auth.EmployeeShift;
import com.liteflow.service.EmployeeService;
import com.liteflow.service.ScheduleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet(name = "ScheduleServlet", urlPatterns = {"/schedule"})
public class ScheduleServlet extends HttpServlet {

    private final ScheduleService scheduleService = new ScheduleService();
    private final EmployeeService employeeService = new EmployeeService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String weekStartParam = req.getParameter("weekStart");
        LocalDate now = LocalDate.now();
        LocalDate weekStart;
        if (weekStartParam != null && !weekStartParam.isBlank()) {
            weekStart = LocalDate.parse(weekStartParam);
        } else {
            // Monday as the first day
            DayOfWeek dow = now.getDayOfWeek();
            int shift = (dow.getValue() + 7 - DayOfWeek.MONDAY.getValue()) % 7;
            weekStart = now.minusDays(shift);
        }

        List<EmployeeShift> shifts = scheduleService.getShiftsForWeek(weekStart);
        var templates = scheduleService.getActiveTemplates();

        // Build week metadata for JSP rendering
        DateTimeFormatter dmy = DateTimeFormatter.ofPattern("dd/MM", Locale.forLanguageTag("vi"));
        DateTimeFormatter dmyFull = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.forLanguageTag("vi"));

        LocalDate weekEnd = weekStart.plusDays(6);
        String weekLabel = "Tuần " + weekStart.format(dmy) + " - " + weekEnd.format(dmyFull);

        // Week-of-month label for control chip like: "Tuần 2 - Th. 10 2025"
        var wf = java.time.temporal.WeekFields.of(DayOfWeek.MONDAY, 1);
        int weekOfMonth = weekStart.get(wf.weekOfMonth());
        String monthShort = String.format("%02d", weekStart.getMonthValue());
        String controlLabel = "Tuần " + weekOfMonth + " - Th. " + monthShort + " " + weekStart.getYear();

        // Prepare per-day buckets with 3 base shift rows (templates)
        List<Map<String, Object>> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = weekStart.plusDays(i);
            Map<String, Object> dayMap = new HashMap<>();
            String label;
            switch (i) {
                case 0: label = "Thứ 2"; break;
                case 1: label = "Thứ 3"; break;
                case 2: label = "Thứ 4"; break;
                case 3: label = "Thứ 5"; break;
                case 4: label = "Thứ 6"; break;
                case 5: label = "Thứ 7"; break;
                default: label = "Chủ nhật";
            }
            dayMap.put("label", label);
            dayMap.put("dateStr", day.format(dmy));

            // For each template, collect shifts of that template time range (best-effort match by time)
            List<Map<String, Object>> rows = new ArrayList<>();
            templates.forEach(t -> {
                Map<String, Object> row = new HashMap<>();
                row.put("templateName", t.getName());
                row.put("templateTime", String.format("%s - %s", t.getStartTime().toString().substring(0,5), t.getEndTime().toString().substring(0,5)));
                List<Map<String, String>> cellShifts = new ArrayList<>();
                for (EmployeeShift s : shifts) {
                    if (!s.getStartAt().toLocalDate().equals(day)) continue;
                    String sStart = s.getStartAt().toLocalTime().toString().substring(0,5);
                    String sEnd = s.getEndAt().toLocalTime().toString().substring(0,5);
                    String tStart = t.getStartTime().toString().substring(0,5);
                    String tEnd = t.getEndTime().toString().substring(0,5);
                    if (sStart.equals(tStart) && sEnd.equals(tEnd)) {
                        Map<String, String> vm = new HashMap<>();
                        vm.put("employee", s.getEmployee() != null ? s.getEmployee().getFullName() : "");
                        vm.put("notes", s.getNotes() != null ? s.getNotes() : "");
                        vm.put("location", s.getLocation() != null ? s.getLocation() : "");
                        vm.put("shiftId", s.getShiftID() != null ? s.getShiftID().toString() : "");
                        vm.put("title", s.getTitle() != null ? s.getTitle() : "");
                        vm.put("status", s.getStatus() != null ? s.getStatus() : "");
                        vm.put("startAt", s.getStartAt().toString());
                        vm.put("endAt", s.getEndAt().toString());
                        vm.put("isRecurring", s.getIsRecurring() != null ? s.getIsRecurring().toString() : "false");
                        cellShifts.add(vm);
                    }
                }
                row.put("items", cellShifts);
                rows.add(row);
            });
            dayMap.put("rows", rows);
            weekDays.add(dayMap);
        }

        // Prev/Next links
        String prevWeekStart = weekStart.minusDays(7).toString();
        String nextWeekStart = weekStart.plusDays(7).toString();

        req.setAttribute("weekLabel", weekLabel);
        req.setAttribute("controlLabel", controlLabel);
        req.setAttribute("weekDays", weekDays);
        req.setAttribute("prevWeekStart", prevWeekStart);
        req.setAttribute("nextWeekStart", nextWeekStart);
        req.setAttribute("templates", templates);
        req.setAttribute("currentWeekStart", weekStart.toString());
        req.setAttribute("employees", employeeService.getAllEmployees());
        req.getRequestDispatcher("/schedule.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        String weekStartParam = req.getParameter("weekStart");
        if (weekStartParam == null || weekStartParam.isBlank()) {
            weekStartParam = LocalDate.now().toString();
        }

        if (action == null || action.isBlank() || "create".equals(action)) {
            try {
                String[] employeeCodes = req.getParameterValues("employeeCode");
                String dateStr = req.getParameter("date");
                String[] startTimes = req.getParameterValues("startTime");
                String[] endTimes = req.getParameterValues("endTime");
                String title = req.getParameter("title");
                String notes = req.getParameter("notes");
                String location = req.getParameter("location");
                String isRecurringStr = req.getParameter("isRecurring");
                boolean isRecurring = "true".equals(isRecurringStr);

                LocalDate date = LocalDate.parse(dateStr);
                boolean anyCreated = false;
                if (employeeCodes != null && employeeCodes.length > 0 && startTimes != null && endTimes != null && startTimes.length == endTimes.length) {
                    for (String employeeCode : employeeCodes) {
                        if (employeeCode == null || employeeCode.isBlank()) continue;
                        for (int i = 0; i < startTimes.length; i++) {
                            LocalTime st = LocalTime.parse(startTimes[i]);
                            LocalTime et = LocalTime.parse(endTimes[i]);
                            boolean ok = scheduleService.createShift(employeeCode, date, st, et, title, notes, location, isRecurring);
                            anyCreated = anyCreated || ok;
                        }
                    }
                }

                if (anyCreated) {
                    resp.sendRedirect(req.getContextPath() + "/schedule?weekStart=" + weekStartParam);
                    return;
                } else {
                    req.setAttribute("error", "Không thể tạo ca làm việc. Vui lòng kiểm tra dữ liệu.");
                }
            } catch (Exception ex) {
                req.setAttribute("error", "Lỗi khi tạo ca làm việc: " + ex.getMessage());
            }
        } else if ("delete".equals(action)) {
            try {
                String shiftIdStr = req.getParameter("shiftId");
                java.util.UUID sid = java.util.UUID.fromString(shiftIdStr);
                boolean ok = scheduleService.deleteShift(sid);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/schedule?weekStart=" + (weekStartParam != null ? weekStartParam : LocalDate.now().toString()));
                    return;
                } else {
                    req.setAttribute("error", "Không thể xóa ca làm việc");
                }
            } catch (Exception ex) {
                req.setAttribute("error", "Lỗi khi xóa ca làm việc: " + ex.getMessage());
            }
        } else if ("toggleRecurring".equals(action)) {
            try {
                String shiftIdStr = req.getParameter("shiftId");
                String isRecurringStr = req.getParameter("isRecurring");
                java.util.UUID sid = java.util.UUID.fromString(shiftIdStr);
                boolean isRecurring = "true".equals(isRecurringStr);
                
                boolean ok = scheduleService.toggleRecurring(sid, isRecurring);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/schedule?weekStart=" + (weekStartParam != null ? weekStartParam : LocalDate.now().toString()));
                    return;
                } else {
                    req.setAttribute("error", "Không thể cập nhật trạng thái lặp lại");
                }
            } catch (Exception ex) {
                req.setAttribute("error", "Lỗi khi cập nhật trạng thái lặp lại: " + ex.getMessage());
            }
        }

        // Fallback: render GET with error message
        doGet(req, resp);
    }
}


