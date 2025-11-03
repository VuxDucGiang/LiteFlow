package com.liteflow.service.procurement;

import com.liteflow.model.procurement.Supplier;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Service để map category -> supplier
 * Demo: Cà phê -> Cà phê Trung Nguyên
 */
public class SupplierMappingService {
    
    private static final Map<String, String> CATEGORY_SUPPLIER_MAP = new HashMap<>();
    
    static {
        // Hardcode mapping theo yêu cầu demo
        CATEGORY_SUPPLIER_MAP.put("Cà phê", "Công ty Cà phê Trung Nguyên");
        // Có thể thêm mapping khác sau
    }
    
    public SupplierMappingService() {
        // No initialization needed
    }
    
    /**
     * Get supplier ID cho category
     * @param categoryName Tên category (ví dụ: "Cà phê")
     * @return Supplier ID hoặc null nếu không tìm thấy
     */
    public UUID getSupplierIdForCategory(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        
        String supplierName = CATEGORY_SUPPLIER_MAP.get(categoryName.trim());
        if (supplierName == null) {
            System.out.println("⚠️ No supplier mapping found for category: " + categoryName);
            return null;
        }
        
        // Tìm supplier theo tên
        try {
            var em = com.liteflow.dao.BaseDAO.emf.createEntityManager();
            try {
                var query = em.createQuery(
                    "SELECT s FROM com.liteflow.model.procurement.Supplier s WHERE s.name = :name",
                    Supplier.class
                );
                query.setParameter("name", supplierName);
                var results = query.getResultList();
                
                if (results.isEmpty()) {
                    System.err.println("❌ Supplier not found: " + supplierName);
                    return null;
                }
                
                UUID supplierId = results.get(0).getSupplierID();
                System.out.println("✅ Mapped category '" + categoryName + "' -> Supplier '" + supplierName + "' (ID: " + supplierId + ")");
                return supplierId;
                
            } finally {
                em.close();
            }
        } catch (Exception e) {
            System.err.println("❌ Error getting supplier for category '" + categoryName + "': " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Get supplier name cho category
     * @param categoryName Tên category
     * @return Supplier name hoặc null
     */
    public String getSupplierNameForCategory(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        return CATEGORY_SUPPLIER_MAP.get(categoryName.trim());
    }
    
    /**
     * Check if category has supplier mapping
     */
    public boolean hasMapping(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return false;
        }
        return CATEGORY_SUPPLIER_MAP.containsKey(categoryName.trim());
    }
}

