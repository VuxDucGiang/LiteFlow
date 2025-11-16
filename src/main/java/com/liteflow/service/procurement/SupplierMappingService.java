package com.liteflow.service.procurement;

import com.liteflow.model.procurement.Supplier;
import com.liteflow.service.ai.AIAgentConfigService;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Service để map category -> supplier
 * Đọc từ AI Agent Config (po.supplier_mapping) hoặc fallback về hardcode mapping
 */
public class SupplierMappingService {
    
    // Fallback hardcode mapping (backward compatibility)
    private static final Map<String, String> FALLBACK_CATEGORY_SUPPLIER_MAP = new HashMap<>();
    
    static {
        // Hardcode mapping theo yêu cầu demo (fallback)
        FALLBACK_CATEGORY_SUPPLIER_MAP.put("Cà phê", "Công ty Cà phê Trung Nguyên");
        // Có thể thêm mapping khác sau
    }
    
    private final AIAgentConfigService configService;
    private Map<String, String> cachedMapping = null;
    private long lastCacheUpdate = 0;
    private static final long CACHE_TTL_MS = 60000; // 1 minute cache
    
    public SupplierMappingService() {
        this.configService = new AIAgentConfigService();
    }
    
    /**
     * Get supplier mapping from config (with caching)
     */
    private Map<String, String> getSupplierMappingFromConfig() {
        long now = System.currentTimeMillis();
        
        // Use cache if still valid
        if (cachedMapping != null && (now - lastCacheUpdate) < CACHE_TTL_MS) {
            return cachedMapping;
        }
        
        // Load from config
        JSONObject jsonConfig = configService.getJSONConfig("po.supplier_mapping", new JSONObject());
        Map<String, String> mapping = new HashMap<>();
        
        if (jsonConfig != null && jsonConfig.length() > 0) {
            for (String categoryName : jsonConfig.keySet()) {
                try {
                    String supplierIdStr = jsonConfig.getString(categoryName);
                    mapping.put(categoryName, supplierIdStr);
                } catch (Exception e) {
                    System.err.println("⚠️ Error reading supplier mapping for category '" + categoryName + "': " + e.getMessage());
                }
            }
            System.out.println("✅ Loaded " + mapping.size() + " supplier mappings from config");
        } else {
            System.out.println("ℹ️ No supplier mapping in config, using fallback");
        }
        
        // Update cache
        cachedMapping = mapping;
        lastCacheUpdate = now;
        
        return mapping;
    }
    
    /**
     * Clear cache (call this after updating config)
     */
    public void clearCache() {
        cachedMapping = null;
        lastCacheUpdate = 0;
    }
    
    /**
     * Get supplier ID cho category
     * Ưu tiên đọc từ config, nếu không có thì fallback về hardcode mapping
     * @param categoryName Tên category (ví dụ: "Cà phê")
     * @return Supplier ID hoặc null nếu không tìm thấy
     */
    public UUID getSupplierIdForCategory(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        
        String trimmedCategory = categoryName.trim();
        
        // Try config first
        Map<String, String> configMapping = getSupplierMappingFromConfig();
        String supplierIdStr = configMapping.get(trimmedCategory);
        
        if (supplierIdStr != null && !supplierIdStr.isEmpty()) {
            try {
                UUID supplierId = UUID.fromString(supplierIdStr);
                System.out.println("✅ Mapped category '" + trimmedCategory + "' -> Supplier ID: " + supplierId + " (from config)");
                return supplierId;
            } catch (IllegalArgumentException e) {
                System.err.println("⚠️ Invalid Supplier ID format in config for category '" + trimmedCategory + "': " + supplierIdStr);
                // Fall through to fallback
            }
        }
        
        // Fallback to hardcode mapping
        String supplierName = FALLBACK_CATEGORY_SUPPLIER_MAP.get(trimmedCategory);
        if (supplierName == null) {
            System.out.println("⚠️ No supplier mapping found for category: " + trimmedCategory);
            return null;
        }
        
        // Tìm supplier theo tên (fallback)
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
                System.out.println("✅ Mapped category '" + trimmedCategory + "' -> Supplier '" + supplierName + "' (ID: " + supplierId + ") [fallback]");
                return supplierId;
                
            } finally {
                em.close();
            }
        } catch (Exception e) {
            System.err.println("❌ Error getting supplier for category '" + trimmedCategory + "': " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Get supplier name cho category (fallback only, vì config lưu SupplierID)
     * @param categoryName Tên category
     * @return Supplier name hoặc null
     */
    public String getSupplierNameForCategory(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        return FALLBACK_CATEGORY_SUPPLIER_MAP.get(categoryName.trim());
    }
    
    /**
     * Check if category has supplier mapping
     */
    public boolean hasMapping(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return false;
        }
        
        String trimmedCategory = categoryName.trim();
        
        // Check config first
        Map<String, String> configMapping = getSupplierMappingFromConfig();
        if (configMapping.containsKey(trimmedCategory)) {
            return true;
        }
        
        // Check fallback
        return FALLBACK_CATEGORY_SUPPLIER_MAP.containsKey(trimmedCategory);
    }
    
    /**
     * Get all mappings (for debugging/admin)
     */
    public Map<String, String> getAllMappings() {
        Map<String, String> result = new HashMap<>();
        
        // Add config mappings
        Map<String, String> configMapping = getSupplierMappingFromConfig();
        result.putAll(configMapping);
        
        // Add fallback mappings (only if not in config)
        for (Map.Entry<String, String> entry : FALLBACK_CATEGORY_SUPPLIER_MAP.entrySet()) {
            if (!result.containsKey(entry.getKey())) {
                result.put(entry.getKey(), entry.getValue());
            }
        }
        
        return result;
    }
}

