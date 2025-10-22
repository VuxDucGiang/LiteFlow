package com.liteflow.dao.timesheet;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.timesheet.EmployeeShiftTimesheet;
import jakarta.persistence.EntityManager;
import java.time.LocalDate;
import java.util.List;

public class EmployeeShiftTimesheetDAO extends GenericDAO<EmployeeShiftTimesheet, java.util.UUID> {

    public EmployeeShiftTimesheetDAO() {
        super(EmployeeShiftTimesheet.class, java.util.UUID.class);
    }

    public List<EmployeeShiftTimesheet> findByWorkDateRange(LocalDate startDate, LocalDate endDate) {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createQuery(
                    "SELECT t FROM EmployeeShiftTimesheet t " +
                    "JOIN FETCH t.employee e " +
                    "LEFT JOIN FETCH t.shift s " +
                    "WHERE t.workDate >= :start AND t.workDate <= :end " +
                    "ORDER BY t.workDate ASC, e.employeeCode ASC", EmployeeShiftTimesheet.class)
                .setParameter("start", startDate)
                .setParameter("end", endDate)
                .getResultList();
        } finally {
            em.close();
        }
    }
}


