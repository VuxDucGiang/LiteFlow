<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="contextPath" content="${pageContext.request.contextPath}">
  <title>Cài đặt - LiteFlow</title>
  
  <!-- Icons + Fonts -->
  <link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  
  <!-- CSS -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/design-system.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/settings.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ai-agent-config.css">
</head>
<body class="settings-page-body">

<%
    // Get user roles from session
    java.util.List<String> userRoles = (java.util.List<String>) session.getAttribute("UserRoles");
    if (userRoles == null) {
        userRoles = new java.util.ArrayList<>();
    }
    
    // Check which settings cards user can access
    boolean canAccessAI = false;
    for (String role : userRoles) {
        if ("ADMIN".equalsIgnoreCase(role) || 
            "MANAGER".equalsIgnoreCase(role) || 
            "Owner".equalsIgnoreCase(role)) {
            canAccessAI = true;
            break;
        }
    }
    
    // Store in page context for JSTL
    pageContext.setAttribute("canAccessAI", canAccessAI);
    pageContext.setAttribute("userRoles", userRoles);
%>

<!-- Top Bar with Back Button -->
<div class="settings-top-bar">
    <a href="${pageContext.request.contextPath}/dashboard" class="back-button">
        <i class='bx bx-arrow-back'></i>
        <span>Trở về trang chủ</span>
    </a>
</div>

<!-- Main Layout -->
<div class="settings-layout">
    <!-- Sidebar -->
    <aside class="settings-sidebar" id="settingsSidebar">
        <div class="sidebar-header">
            <div class="sidebar-logo">
                <i class='bx bx-cog'></i>
                <span class="sidebar-title">Cài đặt</span>
            </div>
            <button class="sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
                <i class='bx bx-menu'></i>
            </button>
        </div>
        
        <nav class="sidebar-nav">
            <c:if test="${canAccessAI}">
                <a href="#ai-agent" class="sidebar-item active" data-section="ai-agent">
                    <i class='bx bx-brain'></i>
                    <span class="sidebar-item-text">AI Agent</span>
                </a>
            </c:if>
            
            <!-- Placeholder for future menu items -->
            <!--
            <a href="#system" class="sidebar-item" data-section="system">
                <i class='bx bx-cog'></i>
                <span class="sidebar-item-text">Hệ thống</span>
            </a>
            <a href="#notifications" class="sidebar-item" data-section="notifications">
                <i class='bx bx-bell'></i>
                <span class="sidebar-item-text">Thông báo</span>
            </a>
            -->
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="settings-main-content">
        <div class="settings-content-wrapper">
            <!-- AI Agent Section -->
            <c:if test="${canAccessAI}">
                <section id="ai-agent-section" class="settings-section active">
                    <div class="ai-config-container">
                        <div class="config-header">
                            <h1><i class='bx bx-cog'></i> LiteFlow Agent Configure</h1>
                            <p class="subtitle">Điều chỉnh các thông số của AI Agent để tối ưu hoạt động</p>
                        </div>

                        <!-- Tabs Navigation -->
                        <div class="config-tabs">
                            <button class="tab-btn active" data-category="STOCK_ALERT">
                                <i class='bx bx-package'></i> Cảnh báo Tồn kho
                            </button>
                            <button class="tab-btn" data-category="DEMAND_FORECAST">
                                <i class='bx bx-trending-up'></i> Dự báo Nhu cầu
                            </button>
                            <button class="tab-btn" data-category="PO_AUTO">
                                <i class='bx bx-cart'></i> Tự động Đặt hàng
                            </button>
                            <button class="tab-btn" data-category="GPT_SERVICE">
                                <i class='bx bx-brain'></i> GPT Service
                            </button>
                            <button class="tab-btn" data-category="NOTIFICATION">
                                <i class='bx bx-bell'></i> Thông báo
                            </button>
                        </div>

                        <!-- Loading Indicator -->
                        <div id="loadingIndicator" class="loading-indicator">
                            <div class="spinner"></div>
                            <p>Đang tải cấu hình...</p>
                        </div>

                        <!-- Error Message -->
                        <div id="errorMessage" class="error-message" style="display: none;"></div>

                        <!-- Success Message -->
                        <div id="successMessage" class="success-message" style="display: none;"></div>

                        <!-- Config Content -->
                        <div id="configContent" class="config-content" style="display: none;">
                            <!-- Content will be dynamically loaded by JavaScript -->
                        </div>

                        <!-- Action Buttons -->
                        <div class="config-actions" style="display: none;">
                            <button id="saveBtn" class="btn btn-primary">
                                <i class='bx bx-save'></i> Lưu thay đổi
                            </button>
                            <button id="resetBtn" class="btn btn-secondary">
                                <i class='bx bx-reset'></i> Khôi phục mặc định
                            </button>
                            <button id="cancelBtn" class="btn btn-outline">
                                <i class='bx bx-x'></i> Hủy
                            </button>
                        </div>
                    </div>
                </section>
            </c:if>
            
            <!-- Empty State Section (if no accessible settings) -->
            <c:if test="${!canAccessAI}">
                <section id="empty-section" class="settings-section active">
                    <div class="settings-empty">
                        <i class='bx bx-info-circle'></i>
                        <h3>Không có cài đặt khả dụng</h3>
                        <p>Tài khoản của bạn hiện không có quyền truy cập vào bất kỳ cài đặt nào.</p>
                        <p class="empty-hint">Vui lòng liên hệ quản trị viên nếu bạn cần quyền truy cập.</p>
                    </div>
                </section>
            </c:if>

            <!-- Placeholder for future sections -->
            <!--
            <section id="system-section" class="settings-section">
                <div class="section-header">
                    <h1><i class='bx bx-cog'></i> Hệ thống</h1>
                    <p class="section-description">Cấu hình hệ thống và thông số chung</p>
                </div>
                <div class="settings-grid">
                    Settings cards here
                </div>
            </section>
            -->
        </div>
    </main>
</div>

<!-- JavaScript -->
<script src="${pageContext.request.contextPath}/js/settings.js"></script>
<script src="${pageContext.request.contextPath}/js/ai-agent-config.js"></script>

</body>
</html>
