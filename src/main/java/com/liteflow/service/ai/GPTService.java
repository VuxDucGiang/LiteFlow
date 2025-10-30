package com.liteflow.service.ai;

import com.liteflow.service.analytics.DemandForecastService;
import okhttp3.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * GPT Service - Integration with OpenAI GPT API
 * Handles chat completions using GPT-3.5-turbo or GPT-4
 */
public class GPTService {
    
    private static final String OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";
    private static final String DEFAULT_MODEL = "gpt-3.5-turbo";
    private static final int MAX_TOKENS = 500;
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");
    
    private final OkHttpClient client;
    private final String apiKey;
    private final DemandForecastService demandService;
    
    public GPTService(String apiKey) {
        this.apiKey = apiKey;
        this.client = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .build();
        this.demandService = new DemandForecastService();
    }
    
    /**
     * Send a message to GPT and get response
     * @param userMessage User's message
     * @param systemPrompt Optional system prompt (null for default)
     * @return GPT's response text
     */
    public String chat(String userMessage, String systemPrompt) throws IOException {
        if (apiKey == null || apiKey.isEmpty()) {
            throw new IllegalStateException("OpenAI API key is not configured");
        }
        
        System.out.println("🤖 GPT Request: " + userMessage);
        
        // Build request JSON
        JSONObject requestBody = new JSONObject();
        requestBody.put("model", DEFAULT_MODEL);
        requestBody.put("max_tokens", MAX_TOKENS);
        requestBody.put("temperature", 0.7);
        
        // Build messages array
        JSONArray messages = new JSONArray();
        
        // Add system message (if provided)
        if (systemPrompt != null && !systemPrompt.isEmpty()) {
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", systemPrompt);
            messages.put(systemMessage);
        } else {
            // Default system prompt for LiteFlow assistant
            JSONObject systemMessage = new JSONObject();
            systemMessage.put("role", "system");
            systemMessage.put("content", 
                "Bạn là trợ lý AI thông minh của LiteFlow - hệ thống quản lý nhà hàng. " +
                "Hãy trả lời bằng tiếng Việt, ngắn gọn, hữu ích và thân thiện. " +
                "Giúp người dùng về các vấn đề liên quan đến quản lý nhà hàng, đơn hàng, báo cáo, và tính năng hệ thống.");
            messages.put(systemMessage);
        }
        
        // Add user message
        JSONObject userMessageObj = new JSONObject();
        userMessageObj.put("role", "user");
        userMessageObj.put("content", userMessage);
        messages.put(userMessageObj);
        
        requestBody.put("messages", messages);
        
        System.out.println("📤 Sending request to OpenAI...");
        
        // Create HTTP request
        RequestBody body = RequestBody.create(requestBody.toString(), JSON);
        Request request = new Request.Builder()
            .url(OPENAI_API_URL)
            .addHeader("Authorization", "Bearer " + apiKey)
            .addHeader("Content-Type", "application/json")
            .post(body)
            .build();
        
        // Execute request
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                String errorBody = response.body() != null ? response.body().string() : "Unknown error";
                System.err.println("❌ OpenAI API Error (" + response.code() + "): " + errorBody);
                throw new IOException("OpenAI API error: " + response.code() + " - " + errorBody);
            }
            
            String responseBody = response.body().string();
            System.out.println("📥 Received response from OpenAI");
            
            // Parse response
            JSONObject jsonResponse = new JSONObject(responseBody);
            
            // Extract message content
            JSONArray choices = jsonResponse.getJSONArray("choices");
            if (choices.length() > 0) {
                JSONObject firstChoice = choices.getJSONObject(0);
                JSONObject message = firstChoice.getJSONObject("message");
                String content = message.getString("content");
                
                System.out.println("✅ GPT Response: " + content.substring(0, Math.min(100, content.length())) + "...");
                
                return content.trim();
            } else {
                throw new IOException("No response from GPT");
            }
        }
    }
    
    /**
     * Intelligent chat with demand forecasting capabilities
     * Detects keywords and provides data-driven responses
     */
    public String chatWithIntelligence(String userMessage) throws IOException {
        System.out.println("🧠 Intelligent Chat: Analyzing message...");
        
        // Detect if user is asking about stock/inventory/demand forecasting
        String lowerMessage = userMessage.toLowerCase();
        boolean askingAboutDemand = lowerMessage.contains("nhập hàng") || 
                                    lowerMessage.contains("tồn kho") || 
                                    lowerMessage.contains("hết hàng") ||
                                    lowerMessage.contains("out of stock") ||
                                    lowerMessage.contains("dự đoán") ||
                                    lowerMessage.contains("forecast") ||
                                    lowerMessage.contains("gợi ý") ||
                                    lowerMessage.contains("cần mua") ||
                                    lowerMessage.contains("stock");
        
        boolean askingAboutAlerts = lowerMessage.contains("cảnh báo") ||
                                   lowerMessage.contains("alert") ||
                                   lowerMessage.contains("nguy hiểm") ||
                                   lowerMessage.contains("sắp hết");
        
        if (askingAboutDemand) {
            return handleDemandForecastQuery(userMessage);
        } else if (askingAboutAlerts) {
            return handleStockAlertQuery(userMessage);
        } else {
            // Normal chat
            return chat(userMessage, null);
        }
    }
    
    /**
     * Handle demand forecasting queries with real data
     */
    private String handleDemandForecastQuery(String userMessage) throws IOException {
        System.out.println("📊 Handling Demand Forecast Query...");
        
        try {
            // Get real demand forecast data
            JSONObject forecast = demandService.generateReplenishmentSuggestions();
            
            if (!forecast.getBoolean("success")) {
                return "Xin lỗi, tôi gặp lỗi khi phân tích dữ liệu tồn kho. Vui lòng thử lại sau.";
            }
            
            // Build context from real data
            StringBuilder context = new StringBuilder();
            context.append("Dựa trên phân tích dữ liệu thực tế của hệ thống:\n\n");
            
            JSONObject summary = forecast.getJSONObject("summary");
            context.append("**Tổng quan:**\n");
            context.append("- Tổng số sản phẩm cần nhập: ").append(summary.getInt("totalSuggestions")).append("\n");
            context.append("- Sản phẩm URGENT: ").append(summary.getInt("urgentItems")).append("\n");
            context.append("- Sản phẩm ưu tiên cao: ").append(summary.getInt("highPriorityItems")).append("\n");
            context.append("- Giá trị đơn hàng ước tính: ").append(String.format("%,d", summary.getLong("estimatedOrderValue"))).append(" VNĐ\n\n");
            
            // Add urgent items
            JSONArray urgentItems = forecast.getJSONArray("urgentItems");
            if (urgentItems.length() > 0) {
                context.append("**Top sản phẩm cần nhập NGAY:**\n");
                for (int i = 0; i < Math.min(5, urgentItems.length()); i++) {
                    JSONObject item = urgentItems.getJSONObject(i);
                    context.append(String.format("%d. %s (%s) - Tồn kho: %d - Gợi ý nhập: %d - Nguy cơ: %s\n",
                        i + 1,
                        item.getString("productName"),
                        item.getString("size"),
                        item.getInt("currentStock"),
                        item.getInt("suggestedOrderQty"),
                        item.getString("stockoutRisk")
                    ));
                }
            }
            
            // Add insights
            JSONObject insights = forecast.getJSONObject("insights");
            if (insights.has("recommendations")) {
                JSONArray recommendations = insights.getJSONArray("recommendations");
                if (recommendations.length() > 0) {
                    context.append("\n**Khuyến nghị:**\n");
                    for (int i = 0; i < recommendations.length(); i++) {
                        context.append("- ").append(recommendations.getString(i)).append("\n");
                    }
                }
            }
            
            // Create enhanced system prompt with real data
            String enhancedPrompt = String.format(
                "Bạn là AI Analyst thông minh của LiteFlow. " +
                "Dựa vào dữ liệu phân tích thực tế bên dưới, hãy trả lời câu hỏi của người dùng một cách chi tiết, chuyên nghiệp và hữu ích.\n\n" +
                "%s\n\n" +
                "Hãy diễn giải dữ liệu trên một cách dễ hiểu, đưa ra insight và khuyến nghị cụ thể.",
                context.toString()
            );
            
            // Call GPT with enhanced context
            return chat(userMessage, enhancedPrompt);
            
        } catch (Exception e) {
            System.err.println("❌ Error in demand forecast query: " + e.getMessage());
            e.printStackTrace();
            return "Xin lỗi, tôi gặp lỗi khi phân tích dữ liệu. Vui lòng thử lại sau.";
        }
    }
    
    /**
     * Handle stock alert queries
     */
    private String handleStockAlertQuery(String userMessage) throws IOException {
        System.out.println("⚠️ Handling Stock Alert Query...");
        
        try {
            JSONObject alerts = demandService.getStockAlerts();
            
            if (!alerts.getBoolean("success")) {
                return "Xin lỗi, tôi gặp lỗi khi kiểm tra cảnh báo tồn kho.";
            }
            
            StringBuilder context = new StringBuilder();
            context.append("**Cảnh báo tồn kho hiện tại:**\n\n");
            
            JSONArray critical = alerts.getJSONArray("criticalStock");
            JSONArray warning = alerts.getJSONArray("lowStock");
            
            if (critical.length() > 0) {
                context.append("🔴 **NGUY HIỂM (≤5 sản phẩm):**\n");
                for (int i = 0; i < Math.min(5, critical.length()); i++) {
                    JSONObject item = critical.getJSONObject(i);
                    context.append(String.format("- %s (%s): %d sản phẩm\n",
                        item.getString("productName"),
                        item.getString("size"),
                        item.getInt("currentStock")
                    ));
                }
                context.append("\n");
            }
            
            if (warning.length() > 0) {
                context.append("🟡 **CẢNH BÁO (≤20 sản phẩm):**\n");
                for (int i = 0; i < Math.min(5, warning.length()); i++) {
                    JSONObject item = warning.getJSONObject(i);
                    context.append(String.format("- %s (%s): %d sản phẩm\n",
                        item.getString("productName"),
                        item.getString("size"),
                        item.getInt("currentStock")
                    ));
                }
            }
            
            if (critical.length() == 0 && warning.length() == 0) {
                return "✅ Tốt! Hiện tại không có cảnh báo tồn kho nào. Tất cả sản phẩm đều đủ số lượng.";
            }
            
            String enhancedPrompt = String.format(
                "Bạn là AI Analyst của LiteFlow. Dựa vào dữ liệu cảnh báo tồn kho bên dưới, hãy phân tích và đưa ra khuyến nghị:\n\n%s\n\n" +
                "Hãy ưu tiên giải quyết các sản phẩm NGUY HIỂM trước, sau đó đến CẢNH BÁO.",
                context.toString()
            );
            
            return chat(userMessage, enhancedPrompt);
            
        } catch (Exception e) {
            System.err.println("❌ Error in stock alert query: " + e.getMessage());
            e.printStackTrace();
            return "Xin lỗi, tôi gặp lỗi khi kiểm tra cảnh báo. Vui lòng thử lại sau.";
        }
    }
    
    /**
     * Simple chat without custom system prompt
     */
    public String chat(String userMessage) throws IOException {
        return chat(userMessage, null);
    }
    
    /**
     * Check if API key is configured
     */
    public boolean isConfigured() {
        return apiKey != null && !apiKey.isEmpty();
    }
}

