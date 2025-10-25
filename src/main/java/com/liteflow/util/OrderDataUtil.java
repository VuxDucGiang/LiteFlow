package com.liteflow.util;

import com.google.gson.Gson;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.*;

/**
 * Utility class for order data processing
 * Used by both production code and test code
 */
public class OrderDataUtil {
    
    private static final Gson gson = new Gson();
    
    /**
     * Read JSON from request body
     */
    public static String readRequestBody(BufferedReader reader) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        return sb.toString();
    }
    
    /**
     * Parse JSON request data
     */
    @SuppressWarnings("unchecked")
    public static Map<String, Object> parseRequestData(String requestBody) {
        return gson.fromJson(requestBody, Map.class);
    }
    
    /**
     * Validate table ID
     */
    public static String validateTableId(Map<String, Object> requestData) {
        String tableIdStr = (String) requestData.get("tableId");
        if (tableIdStr == null || tableIdStr.isEmpty()) {
            return "Table ID không được rỗng";
        }
        return null; // Valid
    }
    
    /**
     * Validate items array
     */
    @SuppressWarnings("unchecked")
    public static String validateItems(Map<String, Object> requestData) {
        List<Map<String, Object>> items = (List<Map<String, Object>>) requestData.get("items");
        if (items == null || items.isEmpty()) {
            return "Danh sách món không được rỗng";
        }
        return null; // Valid
    }
    
    /**
     * Convert string to UUID with validation
     */
    public static UUID parseTableId(String tableIdStr) throws IllegalArgumentException {
        return UUID.fromString(tableIdStr);
    }
    
    /**
     * Extract table ID from request data
     */
    @SuppressWarnings("unchecked")
    public static String extractTableId(Map<String, Object> requestData) {
        return (String) requestData.get("tableId");
    }
    
    /**
     * Extract items from request data
     */
    public static List<Map<String, Object>> extractItems(Map<String, Object> requestData) {
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> items = (List<Map<String, Object>>) requestData.get("items");
        return items;
    }
    
    /**
     * Check if UUID string is valid
     */
    public static boolean isValidUUID(String uuid) {
        if (uuid == null) return false;
        try {
            UUID.fromString(uuid);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
    
    /**
     * Generate test UUID for testing purposes
     */
    public static UUID generateTestUUID() {
        return UUID.randomUUID();
    }
    
    /**
     * Generate deterministic UUID for testing
     */
    public static UUID generateTestUUID(int seed) {
        String uuidString = String.format("%08d-0000-0000-0000-000000000000", seed);
        return UUID.fromString(uuidString);
    }
}
