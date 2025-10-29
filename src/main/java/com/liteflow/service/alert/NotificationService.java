package com.liteflow.service.alert;

import com.liteflow.dao.alert.NotificationChannelDAO;
import com.liteflow.model.alert.NotificationChannel;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.UUID;

/**
 * Service for sending notifications to multiple channels
 * Supports: Slack, Telegram, Email, In-App
 */
public class NotificationService {
    
    private final NotificationChannelDAO channelDAO;
    
    public NotificationService() {
        this.channelDAO = new NotificationChannelDAO();
    }
    
    /**
     * Send notification to all configured channels
     */
    public boolean sendToAllChannels(String title, String message, String priority) {
        List<NotificationChannel> channels = channelDAO.getAllActive();
        boolean anySuccess = false;
        
        for (NotificationChannel channel : channels) {
            boolean sent = sendToChannel(channel, title, message, priority);
            if (sent) {
                anySuccess = true;
            }
        }
        
        return anySuccess;
    }
    
    /**
     * Send notification to specific channel
     */
    public boolean sendToChannel(NotificationChannel channel, String title, String message, String priority) {
        if (!channel.isConfigured()) {
            System.err.println("❌ Channel not configured: " + channel.getName());
            return false;
        }
        
        if (channel.isRateLimitExceeded()) {
            System.err.println("⚠️ Rate limit exceeded for channel: " + channel.getName());
            channelDAO.recordUsage(channel.getChannelID(), false, "Rate limit exceeded");
            return false;
        }
        
        boolean success = false;
        String errorMessage = null;
        
        try {
            switch (channel.getChannelType().toUpperCase()) {
                case "SLACK":
                    success = sendToSlack(channel, title, message, priority);
                    break;
                case "TELEGRAM":
                    success = sendToTelegram(channel, title, message, priority);
                    break;
                case "EMAIL":
                    success = sendEmail(channel, title, message, priority);
                    break;
                default:
                    errorMessage = "Unsupported channel type: " + channel.getChannelType();
                    System.err.println("❌ " + errorMessage);
            }
        } catch (Exception e) {
            errorMessage = e.getMessage();
            System.err.println("❌ Failed to send to " + channel.getName() + ": " + errorMessage);
            e.printStackTrace();
        }
        
        // Record usage
        channelDAO.recordUsage(channel.getChannelID(), success, errorMessage);
        
        return success;
    }
    
    /**
     * Send to Slack webhook
     */
    private boolean sendToSlack(NotificationChannel channel, String title, String message, String priority) {
        try {
            String webhookUrl = channel.getSlackWebhookURL();
            if (webhookUrl == null || webhookUrl.isEmpty()) {
                System.err.println("❌ Slack webhook URL not configured");
                return false;
            }
            
            // Build Slack message
            JSONObject slackMessage = new JSONObject();
            
            // Add emoji based on priority
            String emoji = getPriorityEmoji(priority);
            slackMessage.put("text", emoji + " *" + title + "*");
            
            // Add blocks for better formatting
            org.json.JSONArray blocks = new org.json.JSONArray();
            
            // Header block
            JSONObject headerBlock = new JSONObject();
            headerBlock.put("type", "header");
            JSONObject headerText = new JSONObject();
            headerText.put("type", "plain_text");
            headerText.put("text", emoji + " " + title);
            headerBlock.put("text", headerText);
            blocks.put(headerBlock);
            
            // Message block
            JSONObject messageBlock = new JSONObject();
            messageBlock.put("type", "section");
            JSONObject messageText = new JSONObject();
            messageText.put("type", "mrkdwn");
            messageText.put("text", message);
            messageBlock.put("text", messageText);
            blocks.put(messageBlock);
            
            // Context block (priority + timestamp)
            JSONObject contextBlock = new JSONObject();
            contextBlock.put("type", "context");
            org.json.JSONArray contextElements = new org.json.JSONArray();
            JSONObject contextText = new JSONObject();
            contextText.put("type", "mrkdwn");
            contextText.put("text", "*Priority:* " + priority + " | " + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
            contextElements.put(contextText);
            contextBlock.put("elements", contextElements);
            blocks.put(contextBlock);
            
            slackMessage.put("blocks", blocks);
            
            // Send HTTP POST
            URL url = new URL(webhookUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = slackMessage.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                System.out.println("✅ Slack notification sent: " + title);
                return true;
            } else {
                System.err.println("❌ Slack returned: " + responseCode);
                return false;
            }
            
        } catch (Exception e) {
            System.err.println("❌ Slack send failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Send to Telegram bot
     */
    private boolean sendToTelegram(NotificationChannel channel, String title, String message, String priority) {
        try {
            String botToken = channel.getTelegramBotToken();
            String chatId = channel.getTelegramChatID();
            
            if (botToken == null || botToken.isEmpty() || chatId == null || chatId.isEmpty()) {
                System.err.println("❌ Telegram bot token or chat ID not configured");
                return false;
            }
            
            // Build Telegram message (HTML format)
            String emoji = getPriorityEmoji(priority);
            StringBuilder telegramMessage = new StringBuilder();
            telegramMessage.append(emoji).append(" <b>").append(escapeHtml(title)).append("</b>\n\n");
            telegramMessage.append(escapeHtml(message)).append("\n\n");
            telegramMessage.append("<i>Priority: ").append(priority).append(" | ");
            telegramMessage.append(java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
            telegramMessage.append("</i>");
            
            // Build request
            JSONObject requestBody = new JSONObject();
            requestBody.put("chat_id", chatId);
            requestBody.put("text", telegramMessage.toString());
            requestBody.put("parse_mode", "HTML");
            
            // Send HTTP POST
            String apiUrl = "https://api.telegram.org/bot" + botToken + "/sendMessage";
            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            // Read response
            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                System.out.println("✅ Telegram notification sent: " + title);
                return true;
            } else {
                // Read error
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }
                    System.err.println("❌ Telegram error: " + response.toString());
                }
                return false;
            }
            
        } catch (Exception e) {
            System.err.println("❌ Telegram send failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Send email (simplified - would use JavaMail in production)
     */
    private boolean sendEmail(NotificationChannel channel, String title, String message, String priority) {
        // TODO: Implement email sending using JavaMail
        // For now, just log
        System.out.println("📧 Email notification (not implemented yet): " + title);
        System.out.println("   To: " + channel.getEmailRecipients());
        System.out.println("   Message: " + message);
        
        // Return true for demo purposes
        return true;
    }
    
    /**
     * Get emoji based on priority
     */
    private String getPriorityEmoji(String priority) {
        if (priority == null) return "ℹ️";
        
        switch (priority.toUpperCase()) {
            case "CRITICAL":
                return "🚨";
            case "HIGH":
                return "⚠️";
            case "MEDIUM":
                return "ℹ️";
            case "LOW":
                return "📝";
            default:
                return "ℹ️";
        }
    }
    
    /**
     * Escape HTML for Telegram
     */
    private String escapeHtml(String text) {
        if (text == null) return "";
        return text
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;");
    }
    
    /**
     * Send notification to specific channel by ID
     */
    public boolean sendToChannelById(UUID channelID, String title, String message, String priority) {
        NotificationChannel channel = channelDAO.getById(channelID);
        if (channel == null) {
            System.err.println("❌ Channel not found: " + channelID);
            return false;
        }
        
        return sendToChannel(channel, title, message, priority);
    }
    
    /**
     * Send to default Slack channel
     */
    public boolean sendToDefaultSlack(String title, String message, String priority) {
        NotificationChannel channel = channelDAO.getDefaultSlackChannel();
        if (channel == null) {
            System.err.println("❌ No default Slack channel configured");
            return false;
        }
        
        return sendToChannel(channel, title, message, priority);
    }
    
    /**
     * Send to default Telegram channel
     */
    public boolean sendToDefaultTelegram(String title, String message, String priority) {
        NotificationChannel channel = channelDAO.getDefaultTelegramChannel();
        if (channel == null) {
            System.err.println("❌ No default Telegram channel configured");
            return false;
        }
        
        return sendToChannel(channel, title, message, priority);
    }
    
    /**
     * Test notification (for setup verification)
     */
    public boolean sendTestNotification(UUID channelID) {
        String title = "🧪 Test Notification";
        String message = "This is a test notification from LiteFlow Alert System.\n" +
                       "If you receive this, the channel is configured correctly! ✅";
        String priority = "LOW";
        
        return sendToChannelById(channelID, title, message, priority);
    }
    
    /**
     * Get all active channels
     */
    public List<NotificationChannel> getAllActiveChannels() {
        return channelDAO.getAllActive();
    }
    
    /**
     * Get channel by ID
     */
    public NotificationChannel getChannelById(UUID channelID) {
        return channelDAO.getById(channelID);
    }
}


