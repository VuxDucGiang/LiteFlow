package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.Table;
import jakarta.persistence.EntityManager;
import java.util.List;
import java.util.Collections;
import java.util.UUID;

public class TableDAO extends GenericDAO<Table, UUID> {
    
    public TableDAO() {
        super(Table.class, UUID.class);
    }
    
    public List<Table> findAll() {
        return super.findAll();
    }
    
    public Table findById(UUID id) {
        return super.findById(id);
    }
    
    public boolean insert(Table table) {
        return super.insert(table);
    }
    
    public boolean update(Table table) {
        return super.update(table);
    }
    
    public boolean delete(UUID id) {
        return super.delete(id);
    }
    
    public List<Table> findByRoomId(UUID roomId) {
        return super.findByAttribute("room", roomId);
    }
    
    public Table findByTableNumber(String tableNumber) {
        return super.findSingleByFieldIgnoreCase("tableNumber", tableNumber);
    }
    
    public List<Table> findByStatus(String status) {
        if (status == null || status.isBlank()) {
            return Collections.emptyList();
        }
        EntityManager em = emf.createEntityManager();
        try {
            return em.createQuery(
                    "SELECT t FROM Table t WHERE t.status = :status AND (t.isActive = true OR t.isActive IS NULL)",
                    Table.class)
                .setParameter("status", status)
                .getResultList();
        } catch (Exception e) {
            System.err.println("❌ Lỗi findByStatus: " + e.getMessage());
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }
}
