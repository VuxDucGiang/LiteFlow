package com.liteflow.web.api;

import com.liteflow.service.ai.AIAgentConfigService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.UUID;

/**
 * API Servlet for AI Agent Configuration
 * 
 * Endpoints:
 * - GET /api/ai-agent-config - Get all configurations
 * - GET /api/ai-agent-config?category=STOCK_ALERT - Get configurations by category
 * - POST /api/ai-agent-config - Update configurations
 * - POST /api/ai-agent-config/reset - Reset configuration(s) to default
 */
@WebServlet("/api/ai-agent-config")
public class AIAgentConfigAPIServlet extends HttpServlet {
    
    private AIAgentConfigService configService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.configService = new AIAgentConfigService();
        System.out.println("✅ AIAgentConfigAPIServlet initialized");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session == null) {
            sendError(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        // Check if user has permission (Admin, Manager, or Owner)
        @SuppressWarnings("unchecked")
        java.util.List<String> userRoles = (java.util.List<String>) session.getAttribute("UserRoles");
        
        boolean hasPermission = false;
        if (userRoles != null) {
            for (String role : userRoles) {
                if ("ADMIN".equalsIgnoreCase(role) || 
                    "MANAGER".equalsIgnoreCase(role) || 
                    "Owner".equalsIgnoreCase(role)) {
                    hasPermission = true;
                    break;
                }
            }
        }
        
        if (!hasPermission) {
            sendError(response, "Forbidden: Admin, Manager, or Owner role required", HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        try {
            String category = request.getParameter("category");
            JSONObject result;
            
            if (category != null && !category.isEmpty()) {
                // Get configs by category
                result = configService.getConfigsByCategoryAsJSON(category);
                result.put("success", true);
                result.put("category", category);
            } else {
                // Get all configs
                result = configService.getAllConfigsAsJSON();
                result.put("success", true);
            }
            
            result.put("timestamp", System.currentTimeMillis());
            response.getWriter().write(result.toString(2));
            System.out.println("✅ AI Agent Config API Response sent");
            
        } catch (Exception e) {
            System.err.println("❌ AI Agent Config API Error: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Error retrieving configurations: " + e.getMessage(), 
                     HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session == null) {
            sendError(response, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        // Check if user has permission (Admin, Manager, or Owner)
        @SuppressWarnings("unchecked")
        java.util.List<String> userRoles = (java.util.List<String>) session.getAttribute("UserRoles");
        
        boolean hasPermission = false;
        if (userRoles != null) {
            for (String role : userRoles) {
                if ("ADMIN".equalsIgnoreCase(role) || 
                    "MANAGER".equalsIgnoreCase(role) || 
                    "Owner".equalsIgnoreCase(role)) {
                    hasPermission = true;
                    break;
                }
            }
        }
        
        if (!hasPermission) {
            sendError(response, "Forbidden: Admin, Manager, or Owner role required", HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        // Get user ID
        UUID userId = null;
        try {
            String userLogin = (String) session.getAttribute("UserLogin");
            if (userLogin != null && !userLogin.isEmpty()) {
                userId = UUID.fromString(userLogin);
            }
        } catch (Exception e) {
            System.err.println("⚠️ Could not get user ID from session: " + e.getMessage());
        }
        
        if (userId == null) {
            sendError(response, "User ID not found in session", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            // Read request body
            StringBuilder requestBody = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    requestBody.append(line);
                }
            }
            
            JSONObject requestJson = new JSONObject(requestBody.toString());
            String action = requestJson.optString("action", "");
            
            if ("reset".equals(action)) {
                // Reset to default
                handleReset(requestJson, userId, response);
            } else {
                // Update configurations
                handleUpdate(requestJson, userId, response);
            }
            
        } catch (Exception e) {
            System.err.println("❌ AI Agent Config API Error: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Error processing request: " + e.getMessage(), 
                     HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void handleUpdate(JSONObject requestJson, UUID userId, HttpServletResponse response) 
            throws IOException {
        
        JSONObject configs = requestJson.optJSONObject("configs");
        if (configs == null) {
            sendError(response, "Missing 'configs' object in request body", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        java.util.Map<String, String> updates = new java.util.HashMap<>();
        for (String key : configs.keySet()) {
            updates.put(key, configs.getString(key));
        }
        
        java.util.Map<String, Boolean> results = configService.updateConfigs(updates, userId);
        
        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("message", "Configurations updated");
        result.put("results", new JSONObject(results));
        result.put("timestamp", System.currentTimeMillis());
        
        response.getWriter().write(result.toString(2));
        System.out.println("✅ Updated " + updates.size() + " AI Agent configurations");
    }
    
    private void handleReset(JSONObject requestJson, UUID userId, HttpServletResponse response) 
            throws IOException {
        
        String key = requestJson.optString("key", null);
        String category = requestJson.optString("category", null);
        
        JSONObject result = new JSONObject();
        
        if (key != null && !key.isEmpty()) {
            // Reset single config
            boolean success = configService.resetToDefault(key);
            result.put("success", success);
            result.put("message", success ? "Configuration reset to default" : "Failed to reset configuration");
            result.put("key", key);
        } else if (category != null && !category.isEmpty()) {
            // Reset category
            boolean success = configService.resetCategoryToDefault(category);
            result.put("success", success);
            result.put("message", success ? "Category reset to default" : "Failed to reset category");
            result.put("category", category);
        } else {
            sendError(response, "Missing 'key' or 'category' in request body", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        result.put("timestamp", System.currentTimeMillis());
        response.getWriter().write(result.toString(2));
        System.out.println("✅ Reset AI Agent configuration: " + (key != null ? key : category));
    }
    
    private void sendError(HttpServletResponse response, String message, int statusCode) throws IOException {
        JSONObject error = new JSONObject();
        error.put("success", false);
        error.put("error", message);
        response.setStatus(statusCode);
        response.getWriter().write(error.toString(2));
    }
}

