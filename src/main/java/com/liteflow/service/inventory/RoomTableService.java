package com.liteflow.service.inventory;

import com.liteflow.dao.inventory.RoomDAO;
import com.liteflow.dao.inventory.TableDAO;
import com.liteflow.model.inventory.Room;
import com.liteflow.model.inventory.Table;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.UUID;

public class RoomTableService {
    
    private RoomDAO roomDAO;
    private TableDAO tableDAO;
    private EntityManagerFactory emf;
    
    public RoomTableService() {
        this.roomDAO = new RoomDAO();
        this.tableDAO = new TableDAO();
        this.emf = com.liteflow.dao.BaseDAO.emf;
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
            System.out.println("=== DEBUG: RoomTableService.addRoom ===");
            System.out.println("Room: " + room);
            System.out.println("Room Name: " + room.getName());
            System.out.println("Room Description: " + room.getDescription());
            System.out.println("Room TableCount: " + room.getTableCount());
            System.out.println("Room TotalCapacity: " + room.getTotalCapacity());
            
            // Set created date
            room.setCreatedAt(java.time.LocalDateTime.now());
            
            System.out.println("Calling roomDAO.insert...");
            boolean result = roomDAO.insert(room);
            System.out.println("roomDAO.insert result: " + result);
            
            return result;
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
            System.out.println("=== DEBUG: RoomTableService.deleteRoom ===");
            System.out.println("Room ID to delete: " + roomId);
            
            // Check if room exists first
            Room room = roomDAO.findById(roomId);
            if (room == null) {
                System.out.println("❌ Room not found with ID: " + roomId);
                return false;
            }
            
            System.out.println("Room found: " + room.getName());
            
            // Check if room has related data
            boolean hasRelatedData = roomDAO.checkRoomHasRelatedData(roomId);
            System.out.println("Room has related data: " + hasRelatedData);
            
            // First, manually delete all related data using JPA
            System.out.println("Manually deleting related data...");
            boolean relatedDataDeleted = deleteAllRelatedData(roomId);
            System.out.println("Related data deletion result: " + relatedDataDeleted);
            
            // Then try to delete the room
            System.out.println("Trying to delete room...");
            boolean result = roomDAO.delete(roomId);
            System.out.println("Room deletion result: " + result);
            
            if (!result) {
                System.out.println("JPA delete failed, trying Native SQL delete...");
                result = roomDAO.deleteWithNativeSQL(roomId);
                System.out.println("Native SQL delete result: " + result);
            }
            
            return result;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi xóa phòng: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    private boolean deleteAllRelatedData(UUID roomId) {
        try {
            System.out.println("=== DEBUG: deleteAllRelatedData ===");
            System.out.println("Room ID: " + roomId);
            
            // Get all tables in this room
            List<Table> tablesInRoom = tableDAO.findByRoomId(roomId);
            System.out.println("Found " + (tablesInRoom != null ? tablesInRoom.size() : 0) + " tables in room");
            
            if (tablesInRoom != null && !tablesInRoom.isEmpty()) {
                for (Table table : tablesInRoom) {
                    System.out.println("Deleting table: " + table.getTableId());
                    
                    // Force load table sessions to avoid lazy loading issues
                    try {
                        table.getTableSessions().size(); // This will trigger lazy loading
                        System.out.println("Table has " + table.getTableSessions().size() + " sessions");
                    } catch (Exception e) {
                        System.out.println("Could not load table sessions: " + e.getMessage());
                    }
                    
                    // Delete the table (cascade should handle the rest)
                    boolean tableDeleted = tableDAO.delete(table.getTableId());
                    System.out.println("Table deletion result: " + tableDeleted);
                }
            }
            
            System.out.println("All related data deleted successfully");
            return true;
        } catch (Exception e) {
            System.err.println("❌ Error deleting related data: " + e.getMessage());
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

    // TableSession operations
    public com.liteflow.model.inventory.TableSession getActiveSessionByTableId(UUID tableId) {
        EntityManager em = this.emf.createEntityManager();
        try {
            jakarta.persistence.Query q = em.createQuery(
                "SELECT ts FROM TableSession ts " +
                "WHERE ts.table.tableId = :tableId " +
                "AND (ts.status = 'Active' OR (ts.status IS NULL AND ts.checkOutTime IS NULL))"
            );
            q.setParameter("tableId", tableId);
            q.setMaxResults(1);
            return (com.liteflow.model.inventory.TableSession) q.getSingleResult();
        } catch (jakarta.persistence.NoResultException e) {
            return null;
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy phiên hoạt động của bàn: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }
    
    // Method to get table sessions (alias for existing method)
    public java.util.List<com.liteflow.model.inventory.TableSession> getTableSessions(UUID tableId) {
        return getTableSessionsByTableId(tableId);
    }
    
    // Method to get table payments
    @SuppressWarnings("unchecked")
    public java.util.List<com.liteflow.model.inventory.PaymentTransaction> getTablePayments(UUID tableId) {
        EntityManager em = this.emf.createEntityManager();
        try {
            jakarta.persistence.Query q = em.createQuery(
                "SELECT pt FROM PaymentTransaction pt " +
                "JOIN pt.session ts " +
                "WHERE ts.table.tableId = :tableId " +
                "ORDER BY pt.processedAt DESC"
            );
            q.setParameter("tableId", tableId);
            return q.getResultList();
        } catch (Exception e) {
            System.err.println("Error getting table payments: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        } finally {
            em.close();
        }
    }
    
    // Method to get session orders
    @SuppressWarnings("unchecked")
    public java.util.List<com.liteflow.model.inventory.Order> getSessionOrders(UUID sessionId) {
        EntityManager em = this.emf.createEntityManager();
        try {
            jakarta.persistence.Query q = em.createQuery(
                "SELECT o FROM Order o " +
                "WHERE o.session.sessionId = :sessionId " +
                "ORDER BY o.orderDate DESC"
            );
            q.setParameter("sessionId", sessionId);
            return q.getResultList();
        } catch (Exception e) {
            System.err.println("Error getting session orders: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        } finally {
            em.close();
        }
    }
    
    // Method to get order details
    @SuppressWarnings("unchecked")
    public java.util.List<com.liteflow.model.inventory.OrderDetail> getOrderDetails(UUID orderId) {
        EntityManager em = this.emf.createEntityManager();
        try {
            jakarta.persistence.Query q = em.createQuery(
                "SELECT od FROM OrderDetail od " +
                "WHERE od.order.orderId = :orderId " +
                "ORDER BY od.orderDetailId"
            );
            q.setParameter("orderId", orderId);
            return q.getResultList();
        } catch (Exception e) {
            System.err.println("Error getting order details: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        } finally {
            em.close();
        }
    }

    @SuppressWarnings("unchecked")
    public java.util.List<com.liteflow.model.inventory.TableSession> getTableSessionsByTableId(UUID tableId) {
        EntityManager em = this.emf.createEntityManager();
        try {
            jakarta.persistence.Query q = em.createQuery(
                "SELECT ts FROM TableSession ts " +
                "WHERE ts.table.tableId = :tableId " +
                "ORDER BY ts.checkInTime DESC"
            );
            q.setParameter("tableId", tableId);
            return q.getResultList();
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy lịch sử phiên của bàn: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        } finally {
            em.close();
        }
    }

    // Tổng giá trị các đơn đang phục vụ dựa trên tổng OrderDetail.totalPrice của các phiên Active
    public java.math.BigDecimal getTotalActiveSessionsAmount() {
        EntityManager em = this.emf.createEntityManager();
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
    
    /**
     * Get current table count for a specific room
     */
    public int getCurrentTableCountForRoom(UUID roomId) {
        EntityManager em = this.emf.createEntityManager();
        try {
            String jpql = "SELECT COUNT(t) FROM Table t WHERE t.room.roomId = :roomId AND t.isActive = true";
            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            query.setParameter("roomId", roomId);
            Long count = query.getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            System.err.println("Error getting current table count for room: " + e.getMessage());
            return 0;
        } finally {
            em.close();
        }
    }
    
    /**
     * Get current total capacity for a specific room
     */
    public int getCurrentTotalCapacityForRoom(UUID roomId) {
        EntityManager em = this.emf.createEntityManager();
        try {
            String jpql = "SELECT COALESCE(SUM(t.capacity), 0) FROM Table t WHERE t.room.roomId = :roomId AND t.isActive = true";
            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            query.setParameter("roomId", roomId);
            Long totalCapacity = query.getSingleResult();
            return totalCapacity != null ? totalCapacity.intValue() : 0;
        } catch (Exception e) {
            System.err.println("Error getting current total capacity for room: " + e.getMessage());
            return 0;
        } finally {
            em.close();
        }
    }
}
