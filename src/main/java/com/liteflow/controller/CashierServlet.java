package com.liteflow.controller;

import com.liteflow.dao.BaseDAO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

@WebServlet("/cashier")
public class CashierServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy danh sách sản phẩm cho menu
            List<Map<String, Object>> menuItems = getMenuItems();
            
            // Lấy danh sách bàn
            List<Map<String, Object>> tables = getTables();
            
            // Lấy danh sách phòng
            List<Map<String, Object>> rooms = getRooms();
            
            // Lấy danh sách danh mục
            List<Map<String, Object>> categories = getCategories();
            
            // Convert to JSON strings for JavaScript
            com.google.gson.Gson gson = new com.google.gson.Gson();
            request.setAttribute("menuItemsJson", gson.toJson(menuItems));
            request.setAttribute("tablesJson", gson.toJson(tables));
            request.setAttribute("roomsJson", gson.toJson(rooms));
            request.setAttribute("categoriesJson", gson.toJson(categories));
            
            request.getRequestDispatcher("/cart/cashier.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi trong CashierServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi server");
        }
    }
    
    private List<Map<String, Object>> getMenuItems() {
        List<Map<String, Object>> menuItems = new ArrayList<>();
        EntityManager em = BaseDAO.emf.createEntityManager();
        
        try {
            String jpql = """
                SELECT p.productId, p.name, p.description, p.imageUrl, 
                       pv.productVariantId, pv.size, pv.price, 
                       c.name as categoryName
                FROM Product p 
                LEFT JOIN ProductVariant pv ON p.productId = pv.product.productId 
                LEFT JOIN ProductCategory pc ON p.productId = pc.product.productId
                LEFT JOIN Category c ON pc.category.categoryId = c.categoryId
                WHERE p.isDeleted = false 
                  AND (pv.isDeleted = false OR pv.isDeleted IS NULL)
                ORDER BY c.name, p.name, pv.size
                """;
            
            Query query = em.createQuery(jpql);
            @SuppressWarnings("unchecked")
            List<Object[]> results = query.getResultList();
            
            for (Object[] row : results) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", row[0]);
                item.put("name", row[1]);
                item.put("description", row[2]);
                item.put("imageUrl", row[3]);
                item.put("variantId", row[4]);
                item.put("size", row[5]);
                item.put("price", row[6]);
                item.put("category", row[7]);
                
                // Xử lý đường dẫn hình ảnh
                String imageUrl = (String) row[3];
                if (imageUrl != null && !imageUrl.isEmpty()) {
                    // Nếu là đường link đầy đủ (bắt đầu bằng http/https), sử dụng trực tiếp
                    if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")) {
                        item.put("imageUrl", imageUrl);
                    } else {
                        // Nếu là đường dẫn tương đối, thêm context path
                        item.put("imageUrl", getServletContext().getContextPath() + "/" + imageUrl);
                    }
                } else {
                    // Hình ảnh mặc định nếu không có
                    item.put("imageUrl", getServletContext().getContextPath() + "/images/default-product.jpg");
                }
                
                menuItems.add(item);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy menu items: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        return menuItems;
    }
    
    private List<Map<String, Object>> getTables() {
        List<Map<String, Object>> tables = new ArrayList<>();
        EntityManager em = BaseDAO.emf.createEntityManager();
        
        try {
            String jpql = """
                SELECT t.tableId, t.tableNumber, t.status, r.name as roomName
                FROM Table t 
                LEFT JOIN Room r ON t.room.roomId = r.roomId
                ORDER BY r.name, t.tableNumber
                """;
            
            Query query = em.createQuery(jpql);
            @SuppressWarnings("unchecked")
            List<Object[]> results = query.getResultList();
            
            for (Object[] row : results) {
                Map<String, Object> table = new HashMap<>();
                table.put("id", row[0]);
                table.put("name", row[1]);
                table.put("status", row[2]);
                table.put("room", row[3]);
                table.put("capacity", 4); // Mặc định 4 người
                
                tables.add(table);
            }
            
            // Thêm bàn đặc biệt
            Map<String, Object> takeaway = new HashMap<>();
            takeaway.put("id", "takeaway");
            takeaway.put("name", "Mang về");
            takeaway.put("status", "available");
            takeaway.put("room", "Đặc biệt");
            takeaway.put("capacity", 0);
            tables.add(takeaway);
            
            Map<String, Object> delivery = new HashMap<>();
            delivery.put("id", "delivery");
            delivery.put("name", "Giao hàng");
            delivery.put("status", "available");
            delivery.put("room", "Đặc biệt");
            delivery.put("capacity", 0);
            tables.add(delivery);
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy danh sách bàn: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        return tables;
    }
    
    private List<Map<String, Object>> getRooms() {
        List<Map<String, Object>> rooms = new ArrayList<>();
        EntityManager em = BaseDAO.emf.createEntityManager();
        
        try {
            String jpql = "SELECT r.roomId, r.name, r.description FROM Room r ORDER BY r.name";
            Query query = em.createQuery(jpql);
            @SuppressWarnings("unchecked")
            List<Object[]> results = query.getResultList();
            
            for (Object[] row : results) {
                Map<String, Object> room = new HashMap<>();
                room.put("id", row[0]);
                room.put("name", row[1]);
                room.put("description", row[2]);
                rooms.add(room);
            }
            
            // Thêm phòng đặc biệt
            Map<String, Object> specialRoom = new HashMap<>();
            specialRoom.put("id", "special");
            specialRoom.put("name", "Đặc biệt");
            specialRoom.put("description", "Bàn mang về và giao hàng");
            rooms.add(specialRoom);
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy danh sách phòng: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        return rooms;
    }
    
    private List<Map<String, Object>> getCategories() {
        List<Map<String, Object>> categories = new ArrayList<>();
        EntityManager em = BaseDAO.emf.createEntityManager();
        
        try {
            String jpql = "SELECT c.categoryId, c.name, c.description FROM Category c ORDER BY c.name";
            Query query = em.createQuery(jpql);
            @SuppressWarnings("unchecked")
            List<Object[]> results = query.getResultList();
            
            for (Object[] row : results) {
                Map<String, Object> category = new HashMap<>();
                category.put("id", row[0]);
                category.put("name", row[1]);
                category.put("description", row[2]);
                categories.add(category);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Lỗi khi lấy danh mục: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        return categories;
    }
}
