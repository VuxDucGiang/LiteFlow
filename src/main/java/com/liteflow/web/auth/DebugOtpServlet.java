package com.liteflow.web.auth;

import com.liteflow.model.auth.OtpToken;
import com.liteflow.model.auth.User;
import com.liteflow.service.auth.OtpService;
import com.liteflow.service.auth.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.Optional;
import java.util.logging.Logger;

/**
 * Local-only debug endpoint to inspect latest OTP for a user.
 * Usage (from server machine): /debug-otp?email=admin@liteflow.com
 */
@WebServlet("/debug-otp")
public class DebugOtpServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(DebugOtpServlet.class.getName());
    private final UserService userService = new UserService();
    private final OtpService otpService = new OtpService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String remote = req.getRemoteAddr();
        // Restrict to localhost for safety
        if (!"127.0.0.1".equals(remote) && !"0:0:0:0:0:0:0:1".equals(remote)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("Forbidden");
            return;
        }

        String email = req.getParameter("email");
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            if (email == null || email.isBlank()) {
                out.print("{\"error\":\"email parameter required\"}");
                return;
            }

            User u = userService.getUserByEmail(email.trim().toLowerCase());
            if (u == null) {
                out.print("{\"error\":\"user not found\"}");
                return;
            }

            Optional<OtpToken> tok = otpService.getLatestOtp(u.getUserID());
            if (tok.isEmpty()) {
                out.print("{\"msg\":\"no active otp\"}");
                return;
            }

            OtpToken t = tok.get();
            String expires = t.getExpiresAt() == null ? null : t.getExpiresAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            StringBuilder sb = new StringBuilder();
            sb.append('{');
            sb.append("\"email\":\"").append(email).append('\"');
            sb.append(",\"code\":\"").append(t.getCode()).append('\"');
            sb.append(",\"used\":").append(t.isUsed());
            sb.append(",\"expiresAt\":\"").append(expires).append('\"');
            sb.append('}');
            out.print(sb.toString());
        } catch (Exception ex) {
            LOG.severe("DebugOtpServlet error: " + ex.getMessage());
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"internal\"}");
        }
    }
}
