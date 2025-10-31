package com.liteflow.model.inventory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@DisplayName("Table Model Tests")
@Tag("unit")
@Tag("model")
@Tag("inventory")
public class TableTest {
    
    @Test
    @DisplayName("Test default constructor")
    public void testDefaultConstructor() {
        Table table = new Table();
        
        assertEquals("Available", table.getStatus());
        assertEquals(true, table.getIsActive());
        assertEquals(4, table.getCapacity());
        assertNotNull(table.getTableSessions());
    }
    
    @Test
    @DisplayName("Test setters and getters")
    public void testSettersAndGetters() {
        Table table = new Table();
        UUID id = UUID.randomUUID();
        Room room = new Room();
        String tableNumber = "T01";
        String tableName = "Table 1";
        Integer capacity = 6;
        String status = "Occupied";
        Boolean isActive = true;
        LocalDateTime createdAt = LocalDateTime.now();
        LocalDateTime updatedAt = LocalDateTime.now();
        
        table.setTableId(id);
        table.setRoom(room);
        table.setTableNumber(tableNumber);
        table.setTableName(tableName);
        table.setCapacity(capacity);
        table.setStatus(status);
        table.setIsActive(isActive);
        table.setCreatedAt(createdAt);
        table.setUpdatedAt(updatedAt);
        
        assertEquals(id, table.getTableId());
        assertEquals(room, table.getRoom());
        assertEquals(tableNumber, table.getTableNumber());
        assertEquals(tableName, table.getTableName());
        assertEquals(capacity, table.getCapacity());
        assertEquals(status, table.getStatus());
        assertEquals(isActive, table.getIsActive());
        assertEquals(createdAt, table.getCreatedAt());
        assertEquals(updatedAt, table.getUpdatedAt());
    }
    
    @Test
    @DisplayName("Test addTableSession")
    public void testAddTableSession() {
        Table table = new Table();
        TableSession session = new TableSession();
        
        table.addTableSession(session);
        
        assertTrue(table.getTableSessions().contains(session));
        assertEquals(table, session.getTable());
    }
    
    @Test
    @DisplayName("Test addTableSession with null list")
    public void testAddTableSessionWithNullList() {
        Table table = new Table();
        table.setTableSessions(null);
        
        TableSession session = new TableSession();
        table.addTableSession(session);
        
        assertNotNull(table.getTableSessions());
        assertTrue(table.getTableSessions().contains(session));
    }
    
    @Test
    @DisplayName("Test removeTableSession")
    public void testRemoveTableSession() {
        Table table = new Table();
        TableSession session = new TableSession();
        
        table.addTableSession(session);
        assertTrue(table.getTableSessions().contains(session));
        
        table.removeTableSession(session);
        
        assertFalse(table.getTableSessions().contains(session));
        assertNull(session.getTable());
    }
    
    @Test
    @DisplayName("Test removeTableSession with null list")
    public void testRemoveTableSessionWithNullList() {
        Table table = new Table();
        table.setTableSessions(null);
        
        TableSession session = new TableSession();
        // Should not throw exception
        table.removeTableSession(session);
    }
    
    @Test
    @DisplayName("Test isAvailable - available and active")
    public void testIsAvailable() {
        Table table = new Table();
        table.setStatus("Available");
        table.setIsActive(true);
        
        assertTrue(table.isAvailable());
    }
    
    @Test
    @DisplayName("Test isAvailable - occupied")
    public void testIsAvailableOccupied() {
        Table table = new Table();
        table.setStatus("Occupied");
        table.setIsActive(true);
        
        assertFalse(table.isAvailable());
    }
    
    @Test
    @DisplayName("Test isAvailable - inactive")
    public void testIsAvailableInactive() {
        Table table = new Table();
        table.setStatus("Available");
        table.setIsActive(false);
        
        assertFalse(table.isAvailable());
    }
    
    @Test
    @DisplayName("Test isOccupied")
    public void testIsOccupied() {
        Table table = new Table();
        table.setStatus("Occupied");
        
        assertTrue(table.isOccupied());
    }
    
    @Test
    @DisplayName("Test isReserved")
    public void testIsReserved() {
        Table table = new Table();
        table.setStatus("Reserved");
        
        assertTrue(table.isReserved());
    }
    
    @Test
    @DisplayName("Test isMaintenance")
    public void testIsMaintenance() {
        Table table = new Table();
        table.setStatus("Maintenance");
        
        assertTrue(table.isMaintenance());
    }
    
    @Test
    @DisplayName("Test status methods return false for wrong status")
    public void testStatusMethodsFalse() {
        Table table = new Table();
        table.setStatus("Unknown");
        
        assertFalse(table.isAvailable());
        assertFalse(table.isOccupied());
        assertFalse(table.isReserved());
        assertFalse(table.isMaintenance());
    }
    
    @Test
    @DisplayName("Test setTableSessions")
    public void testSetTableSessions() {
        Table table = new Table();
        List<TableSession> sessions = new ArrayList<>();
        TableSession s1 = new TableSession();
        TableSession s2 = new TableSession();
        sessions.add(s1);
        sessions.add(s2);
        
        table.setTableSessions(sessions);
        
        assertEquals(2, table.getTableSessions().size());
        assertEquals(sessions, table.getTableSessions());
    }
}

