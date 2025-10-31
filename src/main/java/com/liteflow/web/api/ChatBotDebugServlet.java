package com.liteflow.web.api;

import io.github.cdimascio.dotenv.Dotenv;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;

/**
 * ChatBot Debug Servlet - Diagnose API key loading issues
 */
@WebServlet("/api/chatbot-debug")
public class ChatBotDebugServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JSONObject debug = new JSONObject();
        debug.put("timestamp", System.currentTimeMillis());
        
        // 1. Check system properties
        JSONObject systemProps = new JSONObject();
        systemProps.put("user.dir", System.getProperty("user.dir"));
        systemProps.put("catalina.base", System.getProperty("catalina.base"));
        systemProps.put("catalina.home", System.getProperty("catalina.home"));
        debug.put("systemProperties", systemProps);
        
        // 2. Check servlet context paths
        JSONObject contextPaths = new JSONObject();
        contextPaths.put("contextPath", getServletContext().getContextPath());
        contextPaths.put("realPath_root", getServletContext().getRealPath("/"));
        contextPaths.put("realPath_webinf", getServletContext().getRealPath("/WEB-INF/"));
        debug.put("servletContext", contextPaths);
        
        // 3. Try to load from different locations
        String[] possiblePaths = {
            getServletContext().getRealPath("/"),
            getServletContext().getRealPath("/WEB-INF/"),
            System.getProperty("catalina.base") != null ? System.getProperty("catalina.base") + "/webapps/LiteFlow/" : null,
            System.getProperty("user.dir"),
            "C:/Users/Administrator/Documents/Liteflow/LiteFlow/"
        };
        
        JSONObject envFileChecks = new JSONObject();
        String foundApiKey = null;
        String foundAt = null;
        
        for (String path : possiblePaths) {
            if (path == null) continue;
            
            JSONObject pathCheck = new JSONObject();
            pathCheck.put("path", path);
            
            // Check if .env file exists
            File envFile = new File(path, ".env");
            pathCheck.put("envFileExists", envFile.exists());
            pathCheck.put("envFilePath", envFile.getAbsolutePath());
            
            if (envFile.exists()) {
                pathCheck.put("canRead", envFile.canRead());
                pathCheck.put("fileSize", envFile.length());
            }
            
            // Try to load with dotenv
            try {
                Dotenv dotenv = Dotenv.configure()
                    .directory(path)
                    .ignoreIfMissing()
                    .load();
                
                String apiKey = dotenv.get("OPENAI_API_KEY");
                if (apiKey != null && !apiKey.isEmpty()) {
                    pathCheck.put("dotenvLoaded", true);
                    pathCheck.put("apiKeyFound", true);
                    pathCheck.put("apiKeyLength", apiKey.length());
                    pathCheck.put("apiKeyPreview", apiKey.substring(0, Math.min(15, apiKey.length())) + "...");
                    
                    if (foundApiKey == null) {
                        foundApiKey = apiKey;
                        foundAt = path;
                    }
                } else {
                    pathCheck.put("dotenvLoaded", true);
                    pathCheck.put("apiKeyFound", false);
                }
            } catch (Exception e) {
                pathCheck.put("dotenvError", e.getMessage());
            }
            
            envFileChecks.put("location_" + path.hashCode(), pathCheck);
        }
        
        // 4. Check system environment variable
        String sysEnvKey = System.getenv("OPENAI_API_KEY");
        JSONObject sysEnv = new JSONObject();
        sysEnv.put("exists", sysEnvKey != null && !sysEnvKey.isEmpty());
        if (sysEnvKey != null && !sysEnvKey.isEmpty()) {
            sysEnv.put("length", sysEnvKey.length());
            sysEnv.put("preview", sysEnvKey.substring(0, Math.min(15, sysEnvKey.length())) + "...");
            if (foundApiKey == null) {
                foundApiKey = sysEnvKey;
                foundAt = "System Environment Variable";
            }
        }
        debug.put("systemEnvironment", sysEnv);
        
        debug.put("envFileChecks", envFileChecks);
        
        // 5. Final result
        JSONObject result = new JSONObject();
        result.put("apiKeyFound", foundApiKey != null);
        result.put("foundAt", foundAt);
        if (foundApiKey != null) {
            result.put("keyLength", foundApiKey.length());
            result.put("keyPreview", foundApiKey.substring(0, Math.min(20, foundApiKey.length())) + "..." + foundApiKey.substring(Math.max(0, foundApiKey.length() - 4)));
            result.put("isValid", foundApiKey.startsWith("sk-"));
        }
        debug.put("result", result);
        
        // 6. Recommendations
        JSONObject recommendations = new JSONObject();
        if (foundApiKey == null) {
            recommendations.put("status", "ERROR");
            recommendations.put("message", "No API key found in any location");
            recommendations.put("action", "Set OPENAI_API_KEY as system environment variable or ensure .env file is in webapp root");
        } else if (!foundApiKey.startsWith("sk-")) {
            recommendations.put("status", "WARNING");
            recommendations.put("message", "API key found but format seems invalid (should start with 'sk-')");
            recommendations.put("action", "Verify your OpenAI API key");
        } else {
            recommendations.put("status", "SUCCESS");
            recommendations.put("message", "API key found and format looks valid");
            recommendations.put("action", "ChatBot should work. If not, check servlet initialization logs.");
        }
        debug.put("recommendations", recommendations);
        
        response.getWriter().write(debug.toString(2));
    }
}

