package com.liteflow.filter;

import com.liteflow.model.auth.User;
import com.liteflow.security.JwtUtil;
import com.liteflow.service.auth.AuditService;
import com.liteflow.service.auth.UserService;
import io.jsonwebtoken.JwtException;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebFilter("/*")
public class AuthenticationFilter extends BaseFilter {

    private static volatile boolean AUTH_ENABLED = false;

    private final AuditService auditService = new AuditService();
    private final UserService userService = new UserService();

    private static final Map<String, Set<String>> ROLE_FUNCTIONS = new HashMap<>();

    static {
        ROLE_FUNCTIONS.put("Cashier", Set.of("/pos", "/sales", "/cart", "/checkout"));
        ROLE_FUNCTIONS.put("Inventory Manager", Set.of("/inventory", "/products", "/stock", "/purchaseOrders"));
        ROLE_FUNCTIONS.put("Procurement Officer", Set.of("/purchaseOrders", "/suppliers", "/invoices"));
        ROLE_FUNCTIONS.put("HR Officer", Set.of("/employees", "/payroll", "/timesheets", "/leaveRequests"));
        // Allow employees to access their own user pages and dashboard
        ROLE_FUNCTIONS.put("Employee", Set.of(
                "/dashboard",
                "/user/profile",
                "/user/timesheet",
                "/user/payroll"
        ));
        ROLE_FUNCTIONS.put("Admin", Set.of("/*")); // full quyền
    }

    @Override
    public void init(FilterConfig filterConfig) {
        try {
            String env = System.getenv("LITEFLOW_AUTH_ENABLED");
            if (env == null) {
                env = System.getProperty("LITEFLOW_AUTH_ENABLED");
            }
            if (env != null) {
                AUTH_ENABLED = Boolean.parseBoolean(env);
            }
        } catch (Exception ignore) {
        }
        java.util.logging.Logger.getLogger(AuthenticationFilter.class.getName()).info("[AuthenticationFilter] AUTH_ENABLED = " + AUTH_ENABLED);
    }

    private boolean isStaticResource(String path) {
        return path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/") || path.startsWith("/img/")
                || path.endsWith(".css") || path.endsWith(".js")
                || path.endsWith(".jpg") || path.endsWith(".jpeg") || path.endsWith(".png")
                || path.endsWith(".gif") || path.endsWith(".svg") || path.endsWith(".ico")
                || path.endsWith(".woff") || path.endsWith(".woff2") || path.endsWith(".ttf") || path.endsWith(".map");
    }

    private boolean isPublicPage(String path) {
    return path.equals("/login") || path.equals("/register") || path.equals("/logout")
        || path.equals("/auth/google") || path.equals("/oauth2callback")
        || path.equals("/auth/forgot") || path.equals("/auth/reset") || path.equals("/verify-otp")
        || path.equals("/auth/verify") || path.equals("/auth/verify-otp")
        || path.equals("/send-otp")
                || (path.endsWith(".jsp") && (path.startsWith("/auth/") || path.equals("/login.jsp") || path.equals("/register.jsp")))
                || path.equals("/health") || path.equals("/access-denied.jsp")
                || path.startsWith("/public/") || path.startsWith("/api/public/");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (!AUTH_ENABLED) {
            chain.doFilter(request, response);
            return;
        }

        HttpServletRequest req = asHttp(request);
        HttpServletResponse res = asHttp(response);
        String path = getPath(req);

        if (isStaticResource(path) || isPublicPage(path)) {
            chain.doFilter(req, res);
            return;
        }

        User user = null;
        List<String> roles = Collections.emptyList();

        // JWT
        String authHeader = req.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            try {
                var ctx = JwtUtil.parseToUserContext(authHeader.substring(7));
                user = userService.getUserById(UUID.fromString(ctx.userId())).orElse(null);
                if (user != null) {
                    roles = (ctx.roles() == null || ctx.roles().isEmpty())
                            ? userService.getRoleNames(user.getUserID())
                            : ctx.roles();
                    HttpSession session = getSession(req, true);
                    session.setAttribute("UserLogin", user.getUserID().toString());
                    session.setAttribute("UserRoles", roles);
                }
            } catch (JwtException e) {
                auditService.logLoginFail("Invalid JWT", req.getRemoteAddr());
            }
        }

        // Session fallback: accept User object, UUID, or String (uuid or email)
        if (user == null) {
            HttpSession session = getSession(req, false);
            if (session != null) {
                Object sUser = session.getAttribute("UserLogin");
                if (sUser instanceof User u) {
                    user = u;
                } else if (sUser instanceof java.util.UUID) {
                    user = userService.getUserById((java.util.UUID) sUser).orElse(null);
                } else if (sUser instanceof String) {
                    String sval = (String) sUser;
                    try {
                        user = userService.getUserById(java.util.UUID.fromString(sval)).orElse(null);
                    } catch (IllegalArgumentException ex) {
                        user = userService.findByEmail(sval);
                    }
                }

                if (user != null) {
                    @SuppressWarnings("unchecked")
                    List<String> sRoles = (List<String>) session.getAttribute("UserRoles");
                    roles = (sRoles != null) ? sRoles : userService.getRoleNames(user.getUserID());
                }
            }
            // NOTE: "Remember me" cookie is intended only to help the client
            // (browser) remember the account for autofill. The server MUST NOT
            // automatically restore session or skip 2FA based solely on this
            // cookie. If you need server-side long-lived login, use a proper
            // refresh token flow.
        }

        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (isAuthorized(roles, path)) {
            chain.doFilter(req, res);
        } else {
            auditService.logDenied(user, path, req.getRemoteAddr());
            res.sendRedirect(req.getContextPath() + "/access-denied.jsp");
        }
    }

    private boolean isAuthorized(List<String> roles, String path) {
        if (roles == null || roles.isEmpty()) {
            return false;
        }
        if (roles.stream().anyMatch(r -> r.equalsIgnoreCase("owner") || r.equalsIgnoreCase("admin"))) {
            return true;
        }
        String lowerPath = path.toLowerCase();
        for (String role : roles) {
            Set<String> funcs = ROLE_FUNCTIONS.getOrDefault(role, Collections.emptySet());
            if (funcs.stream().anyMatch(f -> lowerPath.startsWith(f.toLowerCase()))) {
                return true;
            }
        }
        return false;
    }
}
