package com.liteflow.dao.employee;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.auth.Employee;
import jakarta.persistence.EntityManager;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

/**
 * DAO cho Employee entity
 */
public class EmployeeDAO extends GenericDAO<Employee, UUID> {

    public EmployeeDAO() {
        super(Employee.class, UUID.class);
    }

    /**
     * Tìm employee theo mã nhân viên
     */
    public Employee findByEmployeeCode(String employeeCode) {
        if (employeeCode == null || employeeCode.trim().isEmpty()) {
            return null;
        }
        
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT e FROM Employee e WHERE e.employeeCode = :code";
            List<Employee> result = em.createQuery(jpql, Employee.class)
                    .setParameter("code", employeeCode.trim())
                    .setMaxResults(1)
                    .getResultList();
            return result.isEmpty() ? null : result.get(0);
        } catch (Exception e) {
            System.err.println("❌ Error finding employee by code: " + e.getMessage());
            return null;
        } finally {
            em.close();
        }
    }

    /**
     * Tìm kiếm employees theo từ khóa
     */
    public List<Employee> searchEmployees(String searchTerm) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return getAll();
        }
        
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT e FROM Employee e WHERE " +
                         "LOWER(e.fullName) LIKE LOWER(:term) OR " +
                         "LOWER(e.employeeCode) LIKE LOWER(:term) OR " +
                         "LOWER(e.email) LIKE LOWER(:term) OR " +
                         "LOWER(e.phone) LIKE LOWER(:term) " +
                         "ORDER BY e.fullName";
            return em.createQuery(jpql, Employee.class)
                    .setParameter("term", "%" + searchTerm.trim() + "%")
                    .getResultList();
        } catch (Exception e) {
            System.err.println("❌ Error searching employees: " + e.getMessage());
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy danh sách employees đang làm việc
     */
    public List<Employee> getActiveEmployees() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT e FROM Employee e WHERE e.employmentStatus = 'Đang làm' ORDER BY e.fullName";
            return em.createQuery(jpql, Employee.class).getResultList();
        } catch (Exception e) {
            System.err.println("❌ Error getting active employees: " + e.getMessage());
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy thống kê employees
     */
    public long getTotalEmployeeCount() {
        return count();
    }

    public long getActiveEmployeeCount() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT COUNT(e) FROM Employee e WHERE e.employmentStatus = 'Đang làm'";
            return em.createQuery(jpql, Long.class).getSingleResult();
        } catch (Exception e) {
            System.err.println("❌ Error getting active employee count: " + e.getMessage());
            return 0L;
        } finally {
            em.close();
        }
    }

    public long getEmployeeCountByPosition(String position) {
        if (position == null || position.trim().isEmpty()) {
            return 0L;
        }
        
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT COUNT(e) FROM Employee e WHERE e.position = :position";
            return em.createQuery(jpql, Long.class)
                    .setParameter("position", position.trim())
                    .getSingleResult();
        } catch (Exception e) {
            System.err.println("❌ Error getting employee count by position: " + e.getMessage());
            return 0L;
        } finally {
            em.close();
        }
    }
}
