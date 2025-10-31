package com.liteflow.service.procurement;

import com.liteflow.model.procurement.PurchaseOrderItem;
import org.json.JSONArray;
import org.json.JSONObject;

import java.time.LocalDateTime;
import java.util.*;

/**
 * Service để tự động tạo PO từ low stock items
 */
public class POAutoCreationService {
    
    private final ProcurementService procurementService;
    private final SupplierMappingService supplierMappingService;
    private static final int DEFAULT_LEAD_TIME_DAYS = 7;
    private static final int DEFAULT_REORDER_QUANTITY = 20; // Số lượng mặc định để đưa stock về mức an toàn
    
    public POAutoCreationService() {
        this.procurementService = new ProcurementService();
        this.supplierMappingService = new SupplierMappingService();
    }
    
    /**
     * Tạo PO tự động từ low stock items
     * @param lowStockItems JSONArray chứa các item low stock (từ getAllLowStockProducts)
     * @param createdBy User ID người tạo
     * @return Map với key = Supplier ID, value = PO ID đã tạo
     */
    public Map<UUID, UUID> createPOsFromLowStockItems(JSONArray lowStockItems, UUID createdBy) {
        System.out.println("=== POAutoCreationService.createPOsFromLowStockItems START ===");
        System.out.println("Low stock items count: " + lowStockItems.length());
        System.out.println("CreatedBy: " + createdBy);
        
        Map<UUID, UUID> createdPOs = new HashMap<>();
        
        if (lowStockItems == null || lowStockItems.length() == 0) {
            System.out.println("⚠️ No low stock items to process");
            return createdPOs;
        }
        
        // Group items by category -> supplier
        Map<UUID, List<JSONObject>> supplierItemsMap = new HashMap<>();
        
        for (int i = 0; i < lowStockItems.length(); i++) {
            JSONObject item = lowStockItems.getJSONObject(i);
            String categoryName = item.optString("categoryName", "");
            
            if (categoryName == null || categoryName.trim().isEmpty()) {
                System.out.println("⚠️ Item '" + item.getString("productName") + "' has no category, skipping");
                continue;
            }
            
            // Map category -> supplier
            UUID supplierId = supplierMappingService.getSupplierIdForCategory(categoryName);
            if (supplierId == null) {
                System.out.println("⚠️ No supplier mapping for category '" + categoryName + "', skipping item: " + item.getString("productName"));
                continue;
            }
            
            // Group by supplier
            if (!supplierItemsMap.containsKey(supplierId)) {
                supplierItemsMap.put(supplierId, new ArrayList<>());
            }
            supplierItemsMap.get(supplierId).add(item);
        }
        
        if (supplierItemsMap.isEmpty()) {
            System.out.println("⚠️ No items could be mapped to suppliers");
            return createdPOs;
        }
        
        // Create PO for each supplier
        LocalDateTime expectedDelivery = LocalDateTime.now().plusDays(DEFAULT_LEAD_TIME_DAYS);
        
        for (Map.Entry<UUID, List<JSONObject>> entry : supplierItemsMap.entrySet()) {
            UUID supplierId = entry.getKey();
            List<JSONObject> items = entry.getValue();
            
            try {
                UUID poId = createPOForSupplier(supplierId, items, createdBy, expectedDelivery);
                createdPOs.put(supplierId, poId);
                System.out.println("✅ Created PO " + poId + " for supplier " + supplierId + " with " + items.size() + " items");
            } catch (Exception e) {
                System.err.println("❌ Failed to create PO for supplier " + supplierId + ": " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        System.out.println("=== POAutoCreationService.createPOsFromLowStockItems END ===");
        System.out.println("Created " + createdPOs.size() + " PO(s)");
        return createdPOs;
    }
    
    /**
     * Tạo PO cho một supplier cụ thể
     */
    private UUID createPOForSupplier(UUID supplierId, List<JSONObject> items, UUID createdBy, LocalDateTime expectedDelivery) {
        System.out.println("📋 Creating PO for supplier: " + supplierId);
        
        List<PurchaseOrderItem> poItems = new ArrayList<>();
        StringBuilder notes = new StringBuilder("Tự động tạo bởi AI từ low stock items. ");
        
        for (JSONObject item : items) {
            String productName = item.getString("productName");
            String size = item.optString("size", "");
            int currentStock = item.getInt("stockAmount");
            double unitPrice = item.getDouble("price");
            
            // Tính số lượng đặt hàng
            // Logic: Đưa về mức DEFAULT_REORDER_QUANTITY, tối thiểu 15 đơn vị
            int reorderQuantity = Math.max(DEFAULT_REORDER_QUANTITY - currentStock, 15);
            
            // Tạo item name với size (nếu có)
            String itemName = productName;
            if (size != null && !size.trim().isEmpty() && !size.equals("N/A")) {
                itemName = productName + " (Size: " + size + ")";
            }
            
            PurchaseOrderItem poItem = new PurchaseOrderItem();
            poItem.setItemName(itemName);
            poItem.setQuantity(reorderQuantity);
            poItem.setUnitPrice(unitPrice > 0 ? unitPrice : getDefaultPrice(productName)); // Fallback nếu không có giá
            
            poItems.add(poItem);
            
            notes.append(String.format("%s x%d, ", itemName, reorderQuantity));
            
            System.out.println("  - Item: " + itemName + ", Qty: " + reorderQuantity + ", Price: " + poItem.getUnitPrice());
        }
        
        notes.append("Ngày giao dự kiến: ").append(expectedDelivery.toLocalDate());
        
        // Tạo PO
        return procurementService.createPurchaseOrder(
            supplierId,
            createdBy,
            expectedDelivery,
            notes.toString(),
            poItems
        );
    }
    
    /**
     * Lấy giá mặc định nếu không có giá từ item
     * Có thể query từ Product hoặc PO history sau
     */
    private double getDefaultPrice(String productName) {
        // Default price: 50000 VND
        // Có thể cải thiện bằng cách query từ ProductVariant.price hoặc PO history
        return 50000.0;
    }
}

