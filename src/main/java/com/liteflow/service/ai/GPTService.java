package com.liteflow.service.ai;

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
    
    public GPTService(String apiKey) {
        this.apiKey = apiKey;
        this.client = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .build();
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

