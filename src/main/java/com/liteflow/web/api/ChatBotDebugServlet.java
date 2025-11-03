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
        
        // 3. Find project root dynamically
        String projectRoot = findProjectRoot();
        
        // 4. Try to load from different locations
        java.util.List<String> pathList = new java.util.ArrayList<>();
        
        // Add servlet context paths
        String servletRoot = getServletContext().getRealPath("/");
        if (servletRoot != null) {
            pathList.add(servletRoot);
            String webInfPath = getServletContext().getRealPath("/WEB-INF/");
            if (webInfPath != null) {
                pathList.add(webInfPath);
            }
        }
        
        // Add Tomcat webapps path
        String catalinaBase = System.getProperty("catalina.base");
        if (catalinaBase != null) {
            pathList.add(catalinaBase + "/webapps/LiteFlow/");
        }
        
        // Add project root (where pom.xml is located)
        if (projectRoot != null) {
            pathList.add(projectRoot);
        }
        
        // Add current working directory as fallback
        String userDir = System.getProperty("user.dir");
        if (userDir != null && !pathList.contains(userDir)) {
            pathList.add(userDir);
        }
        
        String[] possiblePaths = pathList.toArray(new String[0]);
        
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
        debug.put("projectRoot", projectRoot != null ? projectRoot : "Not found");
        
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
            recommendations.put("action", "Create .env file in project root (same level as pom.xml) with: OPENAI_API_KEY=sk-your-key-here, or set as system environment variable");
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
    
    /**
     * Find project root by locating pom.xml file
     * @return Path to project root, or user.dir if not found
     */
    private String findProjectRoot() {
        String userDir = System.getProperty("user.dir");
        if (userDir == null) {
            return null;
        }
        
        // Check current directory first
        File currentDir = new File(userDir);
        File pomFile = new File(currentDir, "pom.xml");
        if (pomFile.exists() && pomFile.isFile()) {
            return currentDir.getAbsolutePath();
        }
        
        // Walk up directories to find pom.xml (max 5 levels up)
        File dir = currentDir;
        int maxLevels = 5;
        int level = 0;
        while (dir != null && dir.getParentFile() != null && level < maxLevels) {
            dir = dir.getParentFile();
            pomFile = new File(dir, "pom.xml");
            if (pomFile.exists() && pomFile.isFile()) {
                return dir.getAbsolutePath();
            }
            level++;
        }
        
        // Fallback to user.dir if pom.xml not found
        return userDir;
    }
}

