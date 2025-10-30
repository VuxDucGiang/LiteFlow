<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Màn hình Bếp - LiteFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.0.7/css/boxicons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/kitchen.css">
</head>

<body>
<div class="kitchen-container">
  <!-- Header -->
  <header class="kitchen-header">
    <div class="header-left">
      <i class='bx bxs-bowl-hot'></i>
      <h1>Màn hình Bếp</h1>
    </div>
    <div class="header-right">
      <!-- Time Display -->
      <div class="time-display" id="currentTime"></div>
      
      <!-- Refresh Button -->
      <button class="btn-refresh" onclick="refreshOrders()">
        <i class='bx bx-refresh'></i>
        <span>Làm mới</span>
      </button>
      
      <!-- Header Actions Group -->
      <div class="header-actions-group">
        <!-- Back Button -->
        <a href="${pageContext.request.contextPath}/dashboard" class="btn-back">
          <i class='bx bx-arrow-back'></i>
        </a>
        
        <!-- Sound Toggle -->
        <button class="sound-toggle-btn" id="soundToggle" onclick="toggleSound()" title="Bật/tắt âm thanh">
          <i class='bx bx-volume-full'></i>
        </button>
        
        <!-- Notifications -->
        <button class="notification-btn" onclick="toggleNotifications()" title="Lịch sử thao tác">
          <i class='bx bx-bell'></i>
          <span class="notification-badge" id="notificationCount" style="display: none;">0</span>
        </button>
        
        <!-- User Menu -->
        <div class="user-menu-wrapper">
          <button class="user-menu-btn" onclick="toggleUserMenu()">
            <i class='bx bx-user-circle' style="font-size: 20px;"></i>
            <span class="user-name">
              <c:choose>
                <c:when test="${not empty sessionScope.UserDisplayName}">
                  ${sessionScope.UserDisplayName}
                </c:when>
                <c:otherwise>
                  Tài khoản
                </c:otherwise>
              </c:choose>
            </span>
            <i class='bx bx-chevron-down'></i>
          </button>
          
          <!-- User Dropdown -->
          <div class="user-dropdown" id="userDropdown">
            <button class="user-dropdown-item" onclick="navigate('management')">
              <i class='bx bx-category'></i>
              <span>Quản lý</span>
            </button>
            <button class="user-dropdown-item" onclick="navigate('cashier')">
              <i class='bx bx-cart'></i>
              <span>Thu ngân</span>
            </button>
            <button class="user-dropdown-item" onclick="navigate('ledger')">
              <i class='bx bx-book'></i>
              <span>Lễ tân</span>
            </button>
            <div class="dropdown-divider"></div>
            <button class="user-dropdown-item danger" onclick="logout()">
              <i class='bx bx-log-out'></i>
              <span>Đăng xuất</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </header>
  
  <!-- Notification Panel -->
  <div class="notification-panel" id="notificationPanel">
    <div class="notification-header">
      <h3>Lịch sử thao tác</h3>
      <button onclick="toggleNotifications()"><i class='bx bx-x'></i></button>
    </div>
    <div class="notification-list" id="notificationList">
      <div class="notification-empty">
        <i class='bx bx-bell-off'></i>
        <p>Không có thông báo nào</p>
      </div>
    </div>
  </div>

  <!-- Stats -->
  <div class="stats-bar">
    <div class="stat-card pending">
      <i class='bx bx-time-five'></i>
      <div class="stat-info">
        <span class="stat-value" id="pendingCount">0</span>
        <span class="stat-label">Chờ làm</span>
      </div>
    </div>
    <div class="stat-card preparing">
      <i class='bx bx-food-menu'></i>
      <div class="stat-info">
        <span class="stat-value" id="preparingCount">0</span>
        <span class="stat-label">Đang làm</span>
      </div>
    </div>
    <div class="stat-card ready">
      <i class='bx bx-check-circle'></i>
      <div class="stat-info">
        <span class="stat-value" id="readyCount">0</span>
        <span class="stat-label">Sẵn sàng</span>
      </div>
    </div>
  </div>

  <!-- Main Content -->
  <div class="orders-section">
    <div class="section-header">
      <h2><i class='bx bx-list-ul'></i> Đơn hàng</h2>
      <div class="filter-buttons">
        <button class="filter-btn active" data-filter="all" onclick="filterOrders('all')">
          Tất cả <span class="badge" id="allCount">0</span>
        </button>
        <button class="filter-btn" data-filter="Pending" onclick="filterOrders('Pending')">
          Chờ làm <span class="badge" id="pendingBadge">0</span>
        </button>
        <button class="filter-btn" data-filter="Preparing" onclick="filterOrders('Preparing')">
          Đang làm <span class="badge" id="preparingBadge">0</span>
        </button>
        <button class="filter-btn" data-filter="Ready" onclick="filterOrders('Ready')">
          Sẵn sàng <span class="badge" id="readyBadge">0</span>
        </button>
      </div>
    </div>

    <div class="orders-grid" id="ordersGrid">
      <!-- Orders will be populated by JavaScript -->
      <div class="empty-state">
        <i class='bx bx-bowl-hot'></i>
        <p>Chưa có đơn hàng nào</p>
      </div>
    </div>
  </div>
</div>

<!-- Logout Modal -->
<div id="logoutModal" class="modal" style="display: none;">
  <div class="modal-content">
    <div class="modal-header">
      <h3><i class='bx bx-log-out'></i> Xác nhận đăng xuất</h3>
      <button class="close-modal-btn" onclick="closeLogoutModal()">
        <i class='bx bx-x'></i>
      </button>
    </div>
    
    <div class="modal-body">
      <p>Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?</p>
    </div>
    
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="closeLogoutModal()">
        <i class='bx bx-x'></i> Hủy
      </button>
      <button class="btn btn-danger" onclick="confirmLogout()">
        <i class='bx bx-log-out'></i> Đăng xuất
      </button>
    </div>
  </div>
</div>

<!-- Initialize data from server BEFORE loading kitchen.js -->
<script>
  // Set context path for JavaScript
  window.contextPath = '${pageContext.request.contextPath}';
  
  // Database data from server
  const ordersData = <c:choose><c:when test="${ordersJson != null}"><c:out value="${ordersJson}" escapeXml="false"/></c:when><c:otherwise>[]</c:otherwise></c:choose>;
  
  // Set global orders array BEFORE kitchen.js loads
  window.orders = ordersData || [];
  
  console.log('📦 Data initialized:', window.orders.length, 'orders');
</script>

<!-- Import Kitchen JavaScript - will read from window.orders -->
<script src="${pageContext.request.contextPath}/js/kitchen.js"></script>

</body>
</html>


