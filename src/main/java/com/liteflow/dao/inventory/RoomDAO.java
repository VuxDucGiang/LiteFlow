package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.Room;
import java.util.List;
import java.util.UUID;

public class RoomDAO extends GenericDAO<Room, UUID> {
    
    public RoomDAO() {
        super(Room.class, UUID.class);
    }
    
    public List<Room> findAll() {
        return super.findAll();
    }
    
    public Room findById(UUID id) {
        return super.findById(id);
    }
    
    public boolean insert(Room room) {
        return super.insert(room);
    }
    
    public boolean update(Room room) {
        return super.update(room);
    }
    
    public boolean delete(UUID id) {
        return super.delete(id);
    }
    
    public List<Room> findByName(String name) {
        return super.findByName(name);
    }
    
    public Room findSingleByName(String name) {
        return super.findSingleByFieldIgnoreCase("name", name);
    }
}
