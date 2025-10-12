package com.liteflow.web.auth;

import com.liteflow.model.auth.User;
import com.liteflow.service.auth.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.InetAddress;
import java.util.List;

/**
 * Temporary debug servlet (LOCALHOST ONLY) to inspect stored password hash for a user.
 * Usage: GET /LiteFlow/auth/debug-hash?email=admin@liteflow.com
 */
@WebServlet(urlPatterns = {"/auth/debug-hash"})
public class DebugHashServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String remote = req.getRemoteAddr();
        // allow only loopback addresses for safety
        if (!isLocalhost(remote)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
            return;
        }

        String email = req.getParameter("email");
        if (email == null || email.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing email param");
            return;
        }
        email = email.trim().toLowerCase();

        User u = userService.getUserByEmail(email);
        if (u == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"error\":\"user not found\"}");
            return;
        }

        List<String> roles = userService.getRoleNames(u.getUserID());

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        // minimal JSON output
        String json = String.format(
                "{\"email\":\"%s\",\"passwordHash\":\"%s\",\"isActive\":%s,\"roles\":%s}",
                escapeJson(u.getEmail()),
                escapeJson(u.getPasswordHash()),
                Boolean.TRUE.equals(u.getIsActive()) ? "true" : "false",
                roles == null ? "[]" : roles.toString()
        );
        resp.getWriter().write(json);
    }

    private boolean isLocalhost(String addr) {
        if (addr == null) return false;
        if (addr.equals("127.0.0.1") || addr.equals("::1") || addr.equals("0:0:0:0:0:0:0:1")) return true;
        try {
            InetAddress ia = InetAddress.getByName(addr);
            return ia.isLoopbackAddress();
        } catch (Exception e) {
            return false;
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
