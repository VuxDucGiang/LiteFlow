package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("Room Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class RoomTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        Room room = new Room();
        
        assertNotNull(room.getTables());
        assertEquals(0, room.getTableCount());
        assertEquals(0, room.getTotalCapacity());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        Room room = new Room();
        UUID id = UUID.randomUUID();
        String name = "VIP Room";
        String description = "Luxury room";
        LocalDateTime createdAt = LocalDateTime.now();
        Integer tableCount = 5;
        Integer totalCapacity = 20;
        
        room.setRoomId(id);
        room.setName(name);
        room.setDescription(description);
        room.setCreatedAt(createdAt);
        room.setTableCount(tableCount);
        room.setTotalCapacity(totalCapacity);
        
        assertEquals(id, room.getRoomId());
        assertEquals(name, room.getName());
        assertEquals(description, room.getDescription());
        assertEquals(createdAt, room.getCreatedAt());
        assertEquals(tableCount, room.getTableCount());
        assertEquals(totalCapacity, room.getTotalCapacity());
    }
    
    @Test
    @DisplayName("Test getTableCount with null")
    public void testGetTableCountNull() {
        Room room = new Room();
        room.setTableCount(null);
        
        assertEquals(0, room.getTableCount());
    }
    
    @Test
    @DisplayName("Test getTotalCapacity with null")
    public void testGetTotalCapacityNull() {
        Room room = new Room();
        room.setTotalCapacity(null);
        
        assertEquals(0, room.getTotalCapacity());
    }
    
    @Test
    @DisplayName("Test addTable")
    public void testAddTable() {
        Room room = new Room();
        Table table = new Table();
        
        room.addTable(table);
        
        assertTrue(room.getTables().contains(table));
        assertEquals(room, table.getRoom());
    }
    
    @Test
    @DisplayName("Test addTable with null list")
    public void testAddTableWithNullList() {
        Room room = new Room();
        room.setTables(null);
        
        Table table = new Table();
        room.addTable(table);
        
        assertNotNull(room.getTables());
        assertTrue(room.getTables().contains(table));
    }
    
    @Test
    @DisplayName("Test removeTable")
    public void testRemoveTable() {
        Room room = new Room();
        Table table = new Table();
        
        room.addTable(table);
        assertTrue(room.getTables().contains(table));
        
        room.removeTable(table);
        
        assertFalse(room.getTables().contains(table));
        assertNull(table.getRoom());
    }
    
    @Test
    @DisplayName("Test getActualTableCount")
    public void testGetActualTableCount() {
        Room room = new Room();
        Table table1 = new Table();
        Table table2 = new Table();
        room.addTable(table1);
        room.addTable(table2);
        
        assertEquals(2, room.getActualTableCount());
    }
    
    @Test
    @DisplayName("Test getActualTableCount with null list")
    public void testGetActualTableCountNull() {
        Room room = new Room();
        room.setTables(null);
        
        assertEquals(0, room.getActualTableCount());
    }
    
    @Test
    @DisplayName("Test getAvailableTableCount")
    public void testGetAvailableTableCount() {
        Room room = new Room();
        Table table1 = new Table();
        table1.setStatus("Available");
        table1.setIsActive(true);
        Table table2 = new Table();
        table2.setStatus("Occupied");
        table2.setIsActive(true);
        room.addTable(table1);
        room.addTable(table2);
        
        assertEquals(1, room.getAvailableTableCount());
    }
    
    @Test
    @DisplayName("Test getAvailableTableCount with null list")
    public void testGetAvailableTableCountNull() {
        Room room = new Room();
        room.setTables(null);
        
        assertEquals(0, room.getAvailableTableCount());
    }
    
    @Test
    @DisplayName("Test getOccupiedTableCount")
    public void testGetOccupiedTableCount() {
        Room room = new Room();
        Table table1 = new Table();
        table1.setStatus("Occupied");
        Table table2 = new Table();
        table2.setStatus("Available");
        room.addTable(table1);
        room.addTable(table2);
        
        assertEquals(1, room.getOccupiedTableCount());
    }
    
    @Test
    @DisplayName("Test getOccupiedTableCount with null list")
    public void testGetOccupiedTableCountNull() {
        Room room = new Room();
        room.setTables(null);
        
        assertEquals(0, room.getOccupiedTableCount());
    }
    
    @Test
    @DisplayName("Test setTables")
    public void testSetTables() {
        Room room = new Room();
        List<Table> tables = new ArrayList<>();
        Table t1 = new Table();
        Table t2 = new Table();
        tables.add(t1);
        tables.add(t2);
        
        room.setTables(tables);
        
        assertEquals(2, room.getTables().size());
        assertEquals(tables, room.getTables());
    }
    
    @Test
    @DisplayName("Test toString")
    public void testToString() {
        Room room = new Room();
        UUID id = UUID.randomUUID();
        room.setRoomId(id);
        room.setName("VIP Room");
        room.setTableCount(5);
        
        String result = room.toString();
        
        assertTrue(result.contains(id.toString()));
        assertTrue(result.contains("VIP Room"));
        assertTrue(result.contains("5"));
        assertTrue(result.contains("Room"));
    }
}

