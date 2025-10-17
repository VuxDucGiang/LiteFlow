package com.liteflow.controller;

import com.liteflow.model.inventory.Room;
import com.liteflow.model.inventory.Table;
import com.liteflow.service.inventory.RoomTableService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

public class RoomTableServlet extends HttpServlet {

    private RoomTableService roomTableService;

    @Override
    public void init() throws ServletException {
        roomTableService = new RoomTableService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy danh sách phòng và bàn
            List<Room> rooms = roomTableService.getAllRooms();
            List<Table> tables = roomTableService.getAllTables();
            
            // Debug logging
            System.out.println("=== DEBUG: RoomTableServlet ===");
            System.out.println("Số lượng phòng: " + (rooms != null ? rooms.size() : "null"));
            System.out.println("Số lượng bàn: " + (tables != null ? tables.size() : "null"));

            // Gửi sang JSP
            request.setAttribute("rooms", rooms);
            request.setAttribute("tables", tables);
            request.getRequestDispatcher("/inventory/roomtable.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong RoomTableServlet: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().println("Lỗi: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("=== DEBUG: RoomTableServlet POST method called ===");
        
        // Set encoding for form data
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String action = request.getParameter("action");
            System.out.println("Action: " + action);

            if ("addRoom".equals(action)) {
                addRoom(request, response);
            } else if ("addTable".equals(action)) {
                addTable(request, response);
            } else if ("updateTableStatus".equals(action)) {
                updateTableStatus(request, response);
            } else if ("deleteRoom".equals(action)) {
                deleteRoom(request, response);
            } else if ("deleteTable".equals(action)) {
                deleteTable(request, response);
            } else if ("editRoom".equals(action)) {
                editRoom(request, response);
            } else if ("editTable".equals(action)) {
                editTable(request, response);
            } else if ("getTableDetails".equals(action)) {
                getTableDetails(request, response);
            } else if ("getTableHistory".equals(action)) {
                getTableHistory(request, response);
            } else {
                request.setAttribute("error", "Hành động không hợp lệ");
            }

            // Redirect về trang danh sách
            doGet(request, response);
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong RoomTableServlet POST: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
    
    private void addRoom(HttpServletRequest request, HttpServletResponse response) {
        try {
            String name = request.getParameter("roomName");
            String description = request.getParameter("roomDescription");

            System.out.println("=== DEBUG: Add Room ===");
            System.out.println("Tên phòng: " + name);
            System.out.println("Mô tả: " + description);

            // Validation
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên phòng không được để trống");
                return;
            }

            if (name.trim().length() > 100) {
                request.setAttribute("error", "Tên phòng không được vượt quá 100 ký tự");
                return;
            }

            // Tạo đối tượng Room mới
            Room newRoom = new Room();
            newRoom.setName(name.trim());
            newRoom.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);

            // Lưu phòng
            boolean success = roomTableService.addRoom(newRoom);
            
            if (success) {
                request.setAttribute("success", "Thêm phòng thành công!");
                System.out.println("✅ Thêm phòng thành công: " + name);
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi thêm phòng");
                System.out.println("❌ Lỗi khi thêm phòng: " + name);
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong addRoom: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi thêm phòng: " + e.getMessage());
        }
    }
    
    private void addTable(HttpServletRequest request, HttpServletResponse response) {
        try {
            String roomIdStr = request.getParameter("roomId");
            String tableNumber = request.getParameter("tableNumber");
            String tableName = request.getParameter("tableName");
            String capacityStr = request.getParameter("capacity");
            String status = request.getParameter("status");

            System.out.println("=== DEBUG: Add Table ===");
            System.out.println("Room ID: " + roomIdStr);
            System.out.println("Số bàn: " + tableNumber);
            System.out.println("Tên bàn: " + tableName);
            System.out.println("Sức chứa: " + capacityStr);
            System.out.println("Trạng thái: " + status);

            // Validation
            if (tableNumber == null || tableNumber.trim().isEmpty()) {
                request.setAttribute("error", "Số bàn không được để trống");
                return;
            }

            if (tableName == null || tableName.trim().isEmpty()) {
                request.setAttribute("error", "Tên bàn không được để trống");
                return;
            }

            if (tableNumber.trim().length() > 50) {
                request.setAttribute("error", "Số bàn không được vượt quá 50 ký tự");
                return;
            }

            if (tableName.trim().length() > 100) {
                request.setAttribute("error", "Tên bàn không được vượt quá 100 ký tự");
                return;
            }

            // Tạo đối tượng Table mới
            Table newTable = new Table();
            newTable.setTableNumber(tableNumber.trim());
            newTable.setTableName(tableName.trim());
            newTable.setStatus(status != null && !status.trim().isEmpty() ? status.trim() : "Available");

            // Parse capacity
            if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                try {
                    int capacity = Integer.parseInt(capacityStr.trim());
                    if (capacity > 0 && capacity <= 20) {
                        newTable.setCapacity(capacity);
                    } else {
                        request.setAttribute("error", "Sức chứa phải từ 1 đến 20 người");
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Sức chứa không hợp lệ");
                    return;
                }
            } else {
                newTable.setCapacity(4); // Default capacity
            }

            // Set room if provided
            if (roomIdStr != null && !roomIdStr.trim().isEmpty()) {
                try {
                    UUID roomId = UUID.fromString(roomIdStr.trim());
                    Room room = roomTableService.getRoomById(roomId);
                    if (room != null) {
                        newTable.setRoom(room);
                    }
                } catch (IllegalArgumentException e) {
                    request.setAttribute("error", "ID phòng không hợp lệ");
                    return;
                }
            }

            // Lưu bàn
            boolean success = roomTableService.addTable(newTable);
            
            if (success) {
                request.setAttribute("success", "Thêm bàn thành công!");
                System.out.println("✅ Thêm bàn thành công: " + tableNumber);
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi thêm bàn");
                System.out.println("❌ Lỗi khi thêm bàn: " + tableNumber);
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong addTable: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi thêm bàn: " + e.getMessage());
        }
    }
    
    private void updateTableStatus(HttpServletRequest request, HttpServletResponse response) {
        try {
            String tableIdStr = request.getParameter("tableId");
            String status = request.getParameter("status");

            System.out.println("=== DEBUG: Update Table Status ===");
            System.out.println("Table ID: " + tableIdStr);
            System.out.println("Status: " + status);

            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                request.setAttribute("error", "ID bàn không được để trống");
                return;
            }

            if (status == null || status.trim().isEmpty()) {
                request.setAttribute("error", "Trạng thái không được để trống");
                return;
            }

            try {
                UUID tableId = UUID.fromString(tableIdStr.trim());
                boolean success = roomTableService.updateTableStatus(tableId, status.trim());
                
                if (success) {
                    request.setAttribute("success", "Cập nhật trạng thái bàn thành công!");
                    System.out.println("✅ Cập nhật trạng thái bàn thành công: " + tableId);
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi cập nhật trạng thái bàn");
                    System.out.println("❌ Lỗi khi cập nhật trạng thái bàn: " + tableId);
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "ID bàn không hợp lệ");
                return;
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong updateTableStatus: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi cập nhật trạng thái bàn: " + e.getMessage());
        }
    }
    
    private void deleteRoom(HttpServletRequest request, HttpServletResponse response) {
        try {
            String roomIdStr = request.getParameter("roomId");

            if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
                request.setAttribute("error", "ID phòng không được để trống");
                return;
            }

            try {
                UUID roomId = UUID.fromString(roomIdStr.trim());
                boolean success = roomTableService.deleteRoom(roomId);
                
                if (success) {
                    request.setAttribute("success", "Xóa phòng thành công!");
                    System.out.println("✅ Xóa phòng thành công: " + roomId);
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi xóa phòng");
                    System.out.println("❌ Lỗi khi xóa phòng: " + roomId);
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "ID phòng không hợp lệ");
                return;
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong deleteRoom: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xóa phòng: " + e.getMessage());
        }
    }
    
    private void deleteTable(HttpServletRequest request, HttpServletResponse response) {
        try {
            String tableIdStr = request.getParameter("tableId");

            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                request.setAttribute("error", "ID bàn không được để trống");
                return;
            }

            try {
                UUID tableId = UUID.fromString(tableIdStr.trim());
                boolean success = roomTableService.deleteTable(tableId);
                
                if (success) {
                    request.setAttribute("success", "Xóa bàn thành công!");
                    System.out.println("✅ Xóa bàn thành công: " + tableId);
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi xóa bàn");
                    System.out.println("❌ Lỗi khi xóa bàn: " + tableId);
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "ID bàn không hợp lệ");
                return;
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong deleteTable: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xóa bàn: " + e.getMessage());
        }
    }
    
    private void editRoom(HttpServletRequest request, HttpServletResponse response) {
        try {
            String roomIdStr = request.getParameter("roomId");
            String name = request.getParameter("roomName");
            String description = request.getParameter("roomDescription");

            if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
                request.setAttribute("error", "ID phòng không được để trống");
                return;
            }

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Tên phòng không được để trống");
                return;
            }

            try {
                UUID roomId = UUID.fromString(roomIdStr.trim());
                Room room = roomTableService.getRoomById(roomId);
                
                if (room != null) {
                    room.setName(name.trim());
                    room.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
                    
                    boolean success = roomTableService.updateRoom(room);
                    
                    if (success) {
                        request.setAttribute("success", "Cập nhật phòng thành công!");
                        System.out.println("✅ Cập nhật phòng thành công: " + roomId);
                    } else {
                        request.setAttribute("error", "Có lỗi xảy ra khi cập nhật phòng");
                    }
                } else {
                    request.setAttribute("error", "Không tìm thấy phòng");
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "ID phòng không hợp lệ");
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong editRoom: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi cập nhật phòng: " + e.getMessage());
        }
    }
    
    private void editTable(HttpServletRequest request, HttpServletResponse response) {
        try {
            String tableIdStr = request.getParameter("tableId");
            String tableNumber = request.getParameter("tableNumber");
            String tableName = request.getParameter("tableName");
            String capacityStr = request.getParameter("capacity");
            String roomIdStr = request.getParameter("roomId");
            String status = request.getParameter("status");

            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                request.setAttribute("error", "ID bàn không được để trống");
                return;
            }

            if (tableNumber == null || tableNumber.trim().isEmpty()) {
                request.setAttribute("error", "Số bàn không được để trống");
                return;
            }

            if (tableName == null || tableName.trim().isEmpty()) {
                request.setAttribute("error", "Tên bàn không được để trống");
                return;
            }

            try {
                UUID tableId = UUID.fromString(tableIdStr.trim());
                Table table = roomTableService.getTableById(tableId);
                
                if (table != null) {
                    table.setTableNumber(tableNumber.trim());
                    table.setTableName(tableName.trim());
                    
                    // Parse capacity
                    if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                        try {
                            int capacity = Integer.parseInt(capacityStr.trim());
                            if (capacity > 0 && capacity <= 20) {
                                table.setCapacity(capacity);
                            } else {
                                request.setAttribute("error", "Sức chứa phải từ 1 đến 20 người");
                                return;
                            }
                        } catch (NumberFormatException e) {
                            request.setAttribute("error", "Sức chứa không hợp lệ");
                            return;
                        }
                    }
                    
                    // Set room if provided
                    if (roomIdStr != null && !roomIdStr.trim().isEmpty()) {
                        try {
                            UUID roomId = UUID.fromString(roomIdStr.trim());
                            Room room = roomTableService.getRoomById(roomId);
                            table.setRoom(room);
                        } catch (IllegalArgumentException e) {
                            request.setAttribute("error", "ID phòng không hợp lệ");
                            return;
                        }
                    }
                    
                    // Set status if provided
                    if (status != null && !status.trim().isEmpty()) {
                        table.setStatus(status.trim());
                    }
                    
                    boolean success = roomTableService.updateTable(table);
                    
                    if (success) {
                        request.setAttribute("success", "Cập nhật bàn thành công!");
                        System.out.println("✅ Cập nhật bàn thành công: " + tableId);
                    } else {
                        request.setAttribute("error", "Có lỗi xảy ra khi cập nhật bàn");
                    }
                } else {
                    request.setAttribute("error", "Không tìm thấy bàn");
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "ID bàn không hợp lệ");
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong editTable: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi cập nhật bàn: " + e.getMessage());
        }
    }
    
    private void getTableDetails(HttpServletRequest request, HttpServletResponse response) {
        try {
            String tableIdStr = request.getParameter("tableId");
            
            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                response.getWriter().write("{\"error\": \"ID bàn không được để trống\"}");
                return;
            }

            try {
                UUID tableId = UUID.fromString(tableIdStr.trim());
                Table table = roomTableService.getTableById(tableId);
                
                if (table != null) {
                    // Get active session for this table
                    com.liteflow.model.inventory.TableSession activeSession = 
                        roomTableService.getActiveSessionByTableId(tableId);
                    
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    
                    StringBuilder json = new StringBuilder();
                    json.append("{");
                    json.append("\"tableId\":\"").append(table.getTableId()).append("\",");
                    json.append("\"tableNumber\":\"").append(table.getTableNumber()).append("\",");
                    json.append("\"tableName\":\"").append(table.getTableName()).append("\",");
                    json.append("\"capacity\":").append(table.getCapacity()).append(",");
                    json.append("\"status\":\"").append(table.getStatus()).append("\",");
                    json.append("\"isActive\":").append(table.getIsActive()).append(",");
                    json.append("\"room\":");
                    if (table.getRoom() != null) {
                        json.append("{");
                        json.append("\"roomId\":\"").append(table.getRoom().getRoomId()).append("\",");
                        json.append("\"name\":\"").append(table.getRoom().getName()).append("\"");
                        json.append("}");
                    } else {
                        json.append("null");
                    }
                    json.append(",");
                    json.append("\"activeSession\":");
                    if (activeSession != null) {
                        json.append("{");
                        json.append("\"sessionId\":\"").append(activeSession.getSessionId()).append("\",");
                        json.append("\"customerName\":\"").append(activeSession.getCustomerName() != null ? activeSession.getCustomerName() : "").append("\",");
                        json.append("\"customerPhone\":\"").append(activeSession.getCustomerPhone() != null ? activeSession.getCustomerPhone() : "").append("\",");
                        json.append("\"checkInTime\":\"").append(activeSession.getCheckInTime()).append("\",");
                        json.append("\"totalAmount\":").append(activeSession.getTotalAmount()).append(",");
                        json.append("\"paymentStatus\":\"").append(activeSession.getPaymentStatus()).append("\"");
                        json.append("}");
                    } else {
                        json.append("null");
                    }
                    json.append("}");
                    
                    response.getWriter().write(json.toString());
                } else {
                    response.getWriter().write("{\"error\": \"Không tìm thấy bàn\"}");
                }
            } catch (IllegalArgumentException e) {
                response.getWriter().write("{\"error\": \"ID bàn không hợp lệ\"}");
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong getTableDetails: " + e.getMessage());
            e.printStackTrace();
            try {
                response.getWriter().write("{\"error\": \"Có lỗi xảy ra: " + e.getMessage() + "\"}");
            } catch (Exception ex) {
                // Ignore
            }
        }
    }
    
    private void getTableHistory(HttpServletRequest request, HttpServletResponse response) {
        try {
            String tableIdStr = request.getParameter("tableId");
            
            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                response.getWriter().write("{\"error\": \"ID bàn không được để trống\"}");
                return;
            }

            try {
                UUID tableId = UUID.fromString(tableIdStr.trim());
                java.util.List<com.liteflow.model.inventory.TableSession> sessions = 
                    roomTableService.getTableSessionsByTableId(tableId);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                StringBuilder json = new StringBuilder();
                json.append("{\"sessions\":[");
                
                if (sessions != null && !sessions.isEmpty()) {
                    for (int i = 0; i < sessions.size(); i++) {
                        com.liteflow.model.inventory.TableSession session = sessions.get(i);
                        json.append("{");
                        json.append("\"sessionId\":\"").append(session.getSessionId()).append("\",");
                        json.append("\"customerName\":\"").append(session.getCustomerName() != null ? session.getCustomerName() : "").append("\",");
                        json.append("\"customerPhone\":\"").append(session.getCustomerPhone() != null ? session.getCustomerPhone() : "").append("\",");
                        json.append("\"checkInTime\":\"").append(session.getCheckInTime()).append("\",");
                        json.append("\"checkOutTime\":\"").append(session.getCheckOutTime() != null ? session.getCheckOutTime() : "").append("\",");
                        json.append("\"status\":\"").append(session.getStatus()).append("\",");
                        json.append("\"totalAmount\":").append(session.getTotalAmount()).append("\",");
                        json.append("\"paymentStatus\":\"").append(session.getPaymentStatus()).append("\"");
                        json.append("}");
                        
                        if (i < sessions.size() - 1) {
                            json.append(",");
                        }
                    }
                }
                
                json.append("]}");
                response.getWriter().write(json.toString());
            } catch (IllegalArgumentException e) {
                response.getWriter().write("{\"error\": \"ID bàn không hợp lệ\"}");
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong getTableHistory: " + e.getMessage());
            e.printStackTrace();
            try {
                response.getWriter().write("{\"error\": \"Có lỗi xảy ra: " + e.getMessage() + "\"}");
            } catch (Exception ex) {
                // Ignore
            }
        }
    }
}
