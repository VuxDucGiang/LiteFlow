package com.liteflow.service.inventory;

import com.liteflow.dao.inventory.RoomDAO;
import com.liteflow.dao.inventory.TableDAO;
import com.liteflow.model.inventory.Room;
import com.liteflow.model.inventory.Table;
import java.util.List;
import java.util.UUID;

public class RoomTableService {
    
    private RoomDAO roomDAO;
    private TableDAO tableDAO;
    
    public RoomTableService() {
        this.roomDAO = new RoomDAO();
        this.tableDAO = new TableDAO();
    }
    
    // Room operations
    public List<Room> getAllRooms() {
        try {
            return roomDAO.findAll();
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy danh sách phòng: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    public Room getRoomById(UUID roomId) {
        try {
            return roomDAO.findById(roomId);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy phòng theo ID: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    public boolean addRoom(Room room) {
        try {
            // Set created date
            room.setCreatedAt(java.time.LocalDateTime.now());
            return roomDAO.insert(room);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi thêm phòng: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateRoom(Room room) {
        try {
            return roomDAO.update(room);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi cập nhật phòng: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteRoom(UUID roomId) {
        try {
            return roomDAO.delete(roomId);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi xóa phòng: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Table operations
    public List<Table> getAllTables() {
        try {
            return tableDAO.findAll();
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy danh sách bàn: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    public List<Table> getTablesByRoomId(UUID roomId) {
        try {
            return tableDAO.findByRoomId(roomId);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy bàn theo phòng: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    public Table getTableById(UUID tableId) {
        try {
            return tableDAO.findById(tableId);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy bàn theo ID: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    public boolean addTable(Table table) {
        try {
            // Set created date
            table.setCreatedAt(new java.util.Date());
            // Set default status if not set
            if (table.getStatus() == null || table.getStatus().trim().isEmpty()) {
                table.setStatus("Available");
            }
            return tableDAO.insert(table);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi thêm bàn: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateTable(Table table) {
        try {
            return tableDAO.update(table);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi cập nhật bàn: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteTable(UUID tableId) {
        try {
            return tableDAO.delete(tableId);
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi xóa bàn: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateTableStatus(UUID tableId, String status) {
        try {
            Table table = tableDAO.findById(tableId);
            if (table != null) {
                table.setStatus(status);
                return tableDAO.update(table);
            }
            return false;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi cập nhật trạng thái bàn: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Statistics
    public int getTotalRooms() {
        try {
            List<Room> rooms = roomDAO.findAll();
            return rooms != null ? rooms.size() : 0;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi đếm số phòng: " + e.getMessage());
            return 0;
        }
    }
    
    public int getTotalTables() {
        try {
            List<Table> tables = tableDAO.findAll();
            return tables != null ? tables.size() : 0;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi đếm số bàn: " + e.getMessage());
            return 0;
        }
    }
    
    public int getAvailableTables() {
        try {
            List<Table> availableTables = tableDAO.findByStatus("Available");
            return availableTables != null ? availableTables.size() : 0;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi đếm số bàn trống: " + e.getMessage());
            return 0;
        }
    }
    
    public int getOccupiedTables() {
        try {
            List<Table> occupiedTables = tableDAO.findByStatus("Occupied");
            return occupiedTables != null ? occupiedTables.size() : 0;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi đếm số bàn đang sử dụng: " + e.getMessage());
            return 0;
        }
    }

    // Tổng giá trị các đơn đang phục vụ dựa trên tổng OrderDetail.totalPrice của các phiên Active
    public java.math.BigDecimal getTotalActiveSessionsAmount() {
        jakarta.persistence.EntityManager em = com.liteflow.dao.BaseDAO.emf.createEntityManager();
        try {
            jakarta.persistence.Query q = em.createQuery(
                "SELECT COALESCE(SUM(od.totalPrice), 0) " +
                "FROM OrderDetail od " +
                "JOIN od.order o " +
                "JOIN o.session s " +
                "WHERE (s.status = 'Active' OR (s.status IS NULL AND s.checkOutTime IS NULL))"
            );
            Object result = q.getSingleResult();
            if (result instanceof java.math.BigDecimal) {
                return (java.math.BigDecimal) result;
            }
            if (result instanceof Number) {
                return java.math.BigDecimal.valueOf(((Number) result).doubleValue());
            }
            return java.math.BigDecimal.ZERO;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi tính tổng giá trị phiên đang phục vụ: " + e.getMessage());
            return java.math.BigDecimal.ZERO;
        } finally {
            em.close();
        }
    }
}
