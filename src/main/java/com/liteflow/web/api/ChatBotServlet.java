package com.liteflow.web.api;

import com.liteflow.service.ai.GPTService;
import io.github.cdimascio.dotenv.Dotenv;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;

/**
 * ChatBot API Servlet
 * Handles chat messages and returns GPT responses
 * Endpoint: /api/chatbot
 */
@WebServlet("/api/chatbot")
public class ChatBotServlet extends HttpServlet {
    
    private GPTService gptService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        
        // Load API key from environment or config
        String apiKey = getOpenAIApiKey();
        
        if (apiKey == null || apiKey.isEmpty()) {
            System.err.println("⚠️ WARNING: OPENAI_API_KEY not configured. ChatBot will not work.");
            System.err.println("   Please set OPENAI_API_KEY in .env file or system environment.");
        } else {
            System.out.println("✅ OpenAI API Key loaded successfully");
            System.out.println("   Key preview: " + apiKey.substring(0, 10) + "..." + apiKey.substring(apiKey.length() - 4));
            gptService = new GPTService(apiKey);
        }
    }
    
    /**
     * GET: Check chatbot status
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JSONObject status = new JSONObject();
        status.put("status", "active");
        status.put("configured", gptService != null && gptService.isConfigured());
        status.put("model", "gpt-3.5-turbo");
        status.put("message", "LiteFlow ChatBot API is ready");
        
        response.getWriter().write(status.toString());
    }
    
    /**
     * POST: Send message and get response
     * Request JSON: { "message": "user message", "systemPrompt": "optional" }
     * Response JSON: { "success": true, "response": "GPT response", "error": null }
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JSONObject jsonResponse = new JSONObject();
        
        try {
            // Check if GPT service is configured
            if (gptService == null || !gptService.isConfigured()) {
                jsonResponse.put("success", false);
                jsonResponse.put("error", "ChatBot is not configured. Please contact administrator.");
                response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
                response.getWriter().write(jsonResponse.toString());
                return;
            }
            
            // Read request body
            StringBuilder requestBody = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    requestBody.append(line);
                }
            }
            
            JSONObject requestJson = new JSONObject(requestBody.toString());
            String userMessage = requestJson.optString("message", "");
            String systemPrompt = requestJson.optString("systemPrompt", null);
            
            // Validate message
            if (userMessage.isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("error", "Message is required");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(jsonResponse.toString());
                return;
            }
            
            System.out.println("💬 ChatBot request from: " + request.getRemoteAddr());
            System.out.println("   Message: " + userMessage);
            
            // Get GPT response
            String gptResponse = gptService.chat(userMessage, systemPrompt);
            
            // Build success response
            jsonResponse.put("success", true);
            jsonResponse.put("response", gptResponse);
            jsonResponse.put("timestamp", System.currentTimeMillis());
            
            System.out.println("✅ ChatBot response sent successfully");
            
        } catch (Exception e) {
            System.err.println("❌ ChatBot error: " + e.getMessage());
            e.printStackTrace();
            
            jsonResponse.put("success", false);
            jsonResponse.put("error", "Đã xảy ra lỗi khi xử lý tin nhắn. Vui lòng thử lại.");
            jsonResponse.put("details", e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    /**
     * Get OpenAI API Key from environment
     * Priority: 1. .env file (development), 2. System environment variable (production)
     * 
     * SECURITY: No hardcoded API keys allowed
     */
    private String getOpenAIApiKey() {
        String apiKey = null;
        
        // Priority 1: Load from .env file (recommended for development)
        try {
            Dotenv dotenv = Dotenv.configure()
                .directory(System.getProperty("user.dir"))  // Project root directory
                .ignoreIfMissing()
                .load();
            
            apiKey = dotenv.get("OPENAI_API_KEY");
            if (apiKey != null && !apiKey.isEmpty()) {
                System.out.println("✅ Loaded OPENAI_API_KEY from .env file");
                return apiKey;
            }
        } catch (Exception e) {
            System.out.println("ℹ️ .env file not found, checking system environment...");
        }
        
        // Priority 2: System environment variable (recommended for production)
        apiKey = System.getenv("OPENAI_API_KEY");
        if (apiKey != null && !apiKey.isEmpty()) {
            System.out.println("✅ Loaded OPENAI_API_KEY from system environment");
            return apiKey;
        }
        
        // No API key found - return null
        System.err.println("❌ OPENAI_API_KEY not found!");
        System.err.println("   Please set it in one of these locations:");
        System.err.println("   1. .env file in project root (for development)");
        System.err.println("   2. System environment variable (for production)");
        System.err.println("   ");
        System.err.println("   See .env.example for setup instructions");
        
        return null;
    }
}

