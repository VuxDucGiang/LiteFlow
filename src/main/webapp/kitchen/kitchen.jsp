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
      <button class="btn-refresh" onclick="refreshOrders()">
        <i class='bx bx-refresh'></i>
        <span>Làm mới</span>
      </button>
      <div class="time-display" id="currentTime"></div>
      <a href="${pageContext.request.contextPath}/dashboard" class="btn-back">
        <i class='bx bx-arrow-back'></i>
        <span>Quay lại</span>
      </a>
    </div>
  </header>

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

<script>
// Database data from server
const ordersData = <c:choose><c:when test="${ordersJson != null}"><c:out value="${ordersJson}" escapeXml="false"/></c:when><c:otherwise>[]</c:otherwise></c:choose>;

// Global variables
let orders = [];
let currentFilter = 'all';
let autoRefreshInterval = null;

// Initialize the page
document.addEventListener('DOMContentLoaded', function() {
  console.log('Kitchen page loaded');
  console.log('Orders data:', ordersData);
  
  orders = ordersData || [];
  renderOrders();
  updateStats();
  updateTime();
  
  // Update time every second
  setInterval(updateTime, 1000);
  
  // Auto refresh every 30 seconds
  autoRefreshInterval = setInterval(refreshOrders, 30000);
});

// Update current time display
function updateTime() {
  const now = new Date();
  const timeString = now.toLocaleTimeString('vi-VN', { 
    hour: '2-digit', 
    minute: '2-digit', 
    second: '2-digit' 
  });
  document.getElementById('currentTime').textContent = timeString;
}

// Render orders
function renderOrders() {
  const ordersGrid = document.getElementById('ordersGrid');
  
  // Filter orders
  let filteredOrders = orders;
  if (currentFilter !== 'all') {
    filteredOrders = orders.filter(order => order.status === currentFilter);
  }
  
  if (filteredOrders.length === 0) {
    ordersGrid.innerHTML = `
      <div class="empty-state">
        <i class='bx bx-bowl-hot'></i>
        <p>Không có đơn hàng nào</p>
      </div>
    `;
    return;
  }
  
  ordersGrid.innerHTML = filteredOrders.map(order => {
    const statusClass = order.status.toLowerCase();
    const statusText = getStatusText(order.status);
    const statusIcon = getStatusIcon(order.status);
    const timeAgo = getTimeAgo(order.orderDate);
    
    return `
      <div class="order-card \${statusClass}" data-order-id="\${order.orderId}">
        <div class="order-header">
          <div class="order-info">
            <h3>\${order.orderNumber}</h3>
            <span class="table-badge">
              <i class='bx bx-table'></i> \${order.tableName}
            </span>
          </div>
          <div class="order-time">
            <i class='bx bx-time'></i>
            <span>\${timeAgo}</span>
          </div>
        </div>
        
        <div class="order-status-badge \${statusClass}">
          <i class='bx \${statusIcon}'></i>
          <span>\${statusText}</span>
        </div>
        
        <div class="order-items">
          \${order.items.map(item => `
            <div class="order-item">
              <div class="item-quantity">\${item.quantity}x</div>
              <div class="item-name">\${item.productName}</div>
              <div class="item-status \${item.status.toLowerCase()}">
                \${getStatusText(item.status)}
              </div>
            </div>
          `).join('')}
        </div>
        
        <div class="order-actions">
          \${renderActionButtons(order.status, order.orderId)}
        </div>
      </div>
    `;
  }).join('');
}

// Render action buttons based on status
function renderActionButtons(status, orderId) {
  switch (status) {
    case 'Pending':
      return `
        <button class="btn btn-primary" onclick="updateStatus('\${orderId}', 'Preparing')">
          <i class='bx bx-play'></i> Bắt đầu làm
        </button>
      `;
    case 'Preparing':
      return `
        <button class="btn btn-success" onclick="updateStatus('\${orderId}', 'Ready')">
          <i class='bx bx-check'></i> Hoàn thành
        </button>
      `;
    case 'Ready':
      return `
        <button class="btn btn-info" onclick="updateStatus('\${orderId}', 'Served')">
          <i class='bx bx-dish'></i> Đã phục vụ
        </button>
      `;
    default:
      return '';
  }
}

// Get status text in Vietnamese
function getStatusText(status) {
  const statusMap = {
    'Pending': 'Chờ làm',
    'Preparing': 'Đang làm',
    'Ready': 'Sẵn sàng',
    'Served': 'Đã phục vụ',
    'Cancelled': 'Đã hủy'
  };
  return statusMap[status] || status;
}

// Get status icon
function getStatusIcon(status) {
  const iconMap = {
    'Pending': 'bx-time-five',
    'Preparing': 'bx-food-menu',
    'Ready': 'bx-check-circle',
    'Served': 'bx-dish',
    'Cancelled': 'bx-x-circle'
  };
  return iconMap[status] || 'bx-help-circle';
}

// Get time ago string
function getTimeAgo(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now - date;
  const diffMins = Math.floor(diffMs / 60000);
  
  if (diffMins < 1) return 'Vừa xong';
  if (diffMins < 60) return diffMins + ' phút trước';
  
  const diffHours = Math.floor(diffMins / 60);
  if (diffHours < 24) return diffHours + ' giờ trước';
  
  return date.toLocaleDateString('vi-VN');
}

// Update statistics
function updateStats() {
  const pendingCount = orders.filter(o => o.status === 'Pending').length;
  const preparingCount = orders.filter(o => o.status === 'Preparing').length;
  const readyCount = orders.filter(o => o.status === 'Ready').length;
  const allCount = orders.length;
  
  document.getElementById('pendingCount').textContent = pendingCount;
  document.getElementById('preparingCount').textContent = preparingCount;
  document.getElementById('readyCount').textContent = readyCount;
  document.getElementById('allCount').textContent = allCount;
  document.getElementById('pendingBadge').textContent = pendingCount;
  document.getElementById('preparingBadge').textContent = preparingCount;
  document.getElementById('readyBadge').textContent = readyCount;
}

// Filter orders
function filterOrders(filter) {
  currentFilter = filter;
  
  // Update active filter button
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.classList.remove('active');
    if (btn.dataset.filter === filter) {
      btn.classList.add('active');
    }
  });
  
  renderOrders();
}

// Update order status
async function updateStatus(orderId, newStatus) {
  console.log('Updating order', orderId, 'to', newStatus);
  
  try {
    const response = await fetch('${pageContext.request.contextPath}/api/order/status', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        orderId: orderId,
        status: newStatus
      })
    });
    
    const result = await response.json();
    
    if (result.success) {
      // Update local data
      const order = orders.find(o => o.orderId === orderId);
      if (order) {
        order.status = newStatus;
        // Update all items status
        order.items.forEach(item => {
          item.status = newStatus;
        });
      }
      
      // If status is Served, remove from list after a delay
      if (newStatus === 'Served') {
        setTimeout(() => {
          orders = orders.filter(o => o.orderId !== orderId);
          renderOrders();
          updateStats();
        }, 1000);
      }
      
      renderOrders();
      updateStats();
      
      // Show success message
      showNotification('✅ Đã cập nhật trạng thái thành công!', 'success');
    } else {
      showNotification('❌ Lỗi: ' + result.message, 'error');
    }
  } catch (error) {
    console.error('Error updating status:', error);
    showNotification('❌ Không thể cập nhật trạng thái', 'error');
  }
}

// Refresh orders
async function refreshOrders() {
  console.log('Refreshing orders...');
  
  try {
    const response = await fetch('${pageContext.request.contextPath}/kitchen');
    const html = await response.text();
    
    // Parse the response to get new orders data
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    const script = doc.querySelector('script');
    
    if (script) {
      // Extract orders data from script
      const scriptContent = script.textContent;
      const match = scriptContent.match(/const ordersData = (.*?);/);
      if (match) {
        const newOrders = JSON.parse(match[1]);
        orders = newOrders;
        renderOrders();
        updateStats();
        showNotification('✅ Đã làm mới danh sách', 'success');
      }
    }
  } catch (error) {
    console.error('Error refreshing orders:', error);
    // Just reload the page as fallback
    window.location.reload();
  }
}

// Show notification
function showNotification(message, type = 'info') {
  // Remove existing notification
  const existing = document.querySelector('.notification');
  if (existing) {
    existing.remove();
  }
  
  const notification = document.createElement('div');
  notification.className = `notification \${type}`;
  notification.innerHTML = `
    <i class='bx \${type === 'success' ? 'bx-check-circle' : 'bx-error-circle'}'></i>
    <span>\${message}</span>
  `;
  
  document.body.appendChild(notification);
  
  // Auto remove after 3 seconds
  setTimeout(() => {
    notification.classList.add('fade-out');
    setTimeout(() => notification.remove(), 300);
  }, 3000);
}

// Cleanup on page unload
window.addEventListener('beforeunload', function() {
  if (autoRefreshInterval) {
    clearInterval(autoRefreshInterval);
  }
});
</script>

</body>
</html>

