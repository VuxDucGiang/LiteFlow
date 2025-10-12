package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.Table;
import java.util.List;
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
        return super.findByAttribute("status", status);
    }
}
