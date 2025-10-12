<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier - LiteFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.0.7/css/boxicons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cashier.css">
</head>

<body>
<div class="cashier-container">
  <!-- Main Content -->
  <div class="main-content">
    <!-- Left Panel: Tables & Menu -->
    <div class="left-panel">
      <!-- Tab Container -->
      <div class="tab-container">
        <!-- Tab Header -->
        <div class="tab-header">
          <button class="tab-btn active" data-tab="tables">
            <i class='bx bx-table'></i>
            Chọn bàn
          </button>
          <button class="tab-btn" data-tab="menu">
            <i class='bx bx-food-menu'></i>
            Thực đơn
          </button>
        </div>
        
        <!-- Tab Content -->
        <div class="tab-content">
          <!-- Tables Tab -->
          <div class="tab-panel active" id="tables-tab">
            <div class="table-section">
              <div class="section-header">
                <h2><i class='bx bx-table'></i> Chọn bàn</h2>
                <div class="table-filters">
                  <button class="filter-btn active" data-filter="all">Tất cả</button>
                  <button class="filter-btn" data-filter="available">Trống</button>
                  <button class="filter-btn" data-filter="occupied">Có khách</button>
                </div>
                <div class="room-filters">
                  <select id="roomFilter" class="room-select">
                    <option value="all">Tất cả phòng</option>
                  </select>
                </div>
              </div>
              <div class="tables-grid" id="tablesGrid">
                <!-- Tables will be populated by JavaScript -->
              </div>
            </div>
          </div>
          
          <!-- Menu Tab -->
          <div class="tab-panel" id="menu-tab">
            <div class="menu-section">
              <div class="section-header">
                <h2><i class='bx bx-food-menu'></i> Thực đơn</h2>
                <div class="menu-search">
                  <input type="text" id="menuSearch" placeholder="Tìm món ăn..." class="search-input">
                  <i class='bx bx-search'></i>
                </div>
              </div>
              
              <div class="menu-categories" id="menuCategories">
                <button class="category-btn active" data-category="all">Tất cả</button>
                <!-- Categories will be populated by JavaScript -->
              </div>

              <div class="menu-grid" id="menuGrid">
                <!-- Menu items will be populated by JavaScript -->
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Panel: Order & Bill -->
    <div class="right-panel">
      <!-- Combined Order & Bill Section -->
      <div class="section order-bill-section">
        <div class="section-header">
          <h2><i class='bx bx-receipt'></i> Đơn hàng & Thanh toán</h2>
          <span class="table-info" id="selectedTableInfo">Chưa chọn bàn</span>
        </div>
        
        <!-- Order Items -->
        <div class="order-items" id="orderItems">
          <div class="empty-order">
            <i class='bx bx-shopping-cart'></i>
            <p>Chưa có món nào được chọn</p>
          </div>
        </div>

        <!-- Bill Summary -->
        <div class="bill-summary">
          <div class="bill-row">
            <span>Tạm tính:</span>
            <span id="subtotal">0đ</span>
          </div>
          <div class="bill-row">
            <span>VAT (10%):</span>
            <span id="vat">0đ</span>
          </div>
          <div class="bill-row total">
            <span>Tổng cộng:</span>
            <span id="total">0đ</span>
          </div>
        </div>

        <!-- Payment Methods -->
        <div class="payment-methods">
          <button class="payment-btn" data-method="cash">
            <i class='bx bx-money'></i>
            <span>Tiền mặt</span>
          </button>
          <button class="payment-btn" data-method="card">
            <i class='bx bx-credit-card'></i>
            <span>Thẻ</span>
          </button>
          <button class="payment-btn" data-method="transfer">
            <i class='bx bx-transfer'></i>
            <span>Chuyển khoản</span>
          </button>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
          <button class="btn btn-secondary" id="clearOrder">
            <i class='bx bx-trash'></i> Xóa đơn
          </button>
          <button class="btn btn-primary" id="checkoutBtn" disabled>
            <i class='bx bx-check'></i> Thanh toán
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

  <script>
// Database data from server
const tables = <c:choose><c:when test="${tablesJson != null}"><c:out value="${tablesJson}" escapeXml="false"/></c:when><c:otherwise>[]</c:otherwise></c:choose>;
const rooms = <c:choose><c:when test="${roomsJson != null}"><c:out value="${roomsJson}" escapeXml="false"/></c:when><c:otherwise>[]</c:otherwise></c:choose>;
const menuItems = <c:choose><c:when test="${menuItemsJson != null}"><c:out value="${menuItemsJson}" escapeXml="false"/></c:when><c:otherwise>[]</c:otherwise></c:choose>;
const categories = <c:choose><c:when test="${categoriesJson != null}"><c:out value="${categoriesJson}" escapeXml="false"/></c:when><c:otherwise>[]</c:otherwise></c:choose>;

// Global variables
let selectedTable = null;
let orderItems = [];
let currentFilter = 'all';
let currentCategory = 'all';
let currentRoom = 'all';

// Initialize the page
document.addEventListener('DOMContentLoaded', function() {
  console.log('Cashier page loaded');
  console.log('Tables:', tables);
  console.log('Rooms:', rooms);
  console.log('Menu items:', menuItems);
  console.log('Categories:', categories);
  
  // Debug: Log table and room data structure
  if (tables && tables.length > 0) {
    console.log('Sample table data:', tables[0]);
  } else {
    console.log('No tables data found, using fallback data');
    // Add some fallback tables for testing
    if (!tables || tables.length === 0) {
      window.tables = [
        {
          id: 'table1',
          name: 'Bàn 1',
          status: 'available',
          room: 'Tầng 1',
          capacity: 4
        },
        {
          id: 'table2', 
          name: 'Bàn 2',
          status: 'occupied',
          room: 'Tầng 1',
          capacity: 6
        },
        {
          id: 'table3',
          name: 'Bàn 3', 
          status: 'available',
          room: 'Tầng 2',
          capacity: 4
        }
      ];
    }
  }
  
  if (rooms && rooms.length > 0) {
    console.log('Sample room data:', rooms[0]);
  } else {
    console.log('No rooms data found, using fallback data');
    // Add some fallback rooms for testing
    if (!rooms || rooms.length === 0) {
      window.rooms = [
        {
          id: 'room1',
          name: 'Tầng 1',
          description: 'Tầng 1'
        },
        {
          id: 'room2',
          name: 'Tầng 2', 
          description: 'Tầng 2'
        }
      ];
    }
  }
  
  populateRoomFilter();
  populateMenuCategories();
  renderTables();
  renderMenu();
  setupEventListeners();
  setupTabSystem();
});

// Populate room filter dropdown
function populateRoomFilter() {
  const roomFilter = document.getElementById('roomFilter');
  roomFilter.innerHTML = '<option value="all">Tất cả phòng</option>';
  
  const roomsData = window.rooms || rooms || [];
  console.log('Populating room filter with:', roomsData);
  
  if (roomsData && roomsData.length > 0) {
    roomsData.forEach(room => {
      const option = document.createElement('option');
      option.value = room.id;
      option.textContent = room.name;
      roomFilter.appendChild(option);
    });
  } else {
    // Fallback if no rooms in database
    const option = document.createElement('option');
    option.value = 'default';
    option.textContent = 'Phòng mặc định';
    roomFilter.appendChild(option);
  }
}

// Render tables
function renderTables() {
  const tablesGrid = document.getElementById('tablesGrid');
  let filteredTables = window.tables || tables || [];
  
  console.log('Rendering tables:', filteredTables);
  console.log('Current filter:', currentFilter);
  console.log('Current room:', currentRoom);
  
  // Filter by status (convert to lowercase for comparison)
  if (currentFilter !== 'all') {
    console.log('Filtering by status:', currentFilter);
    filteredTables = filteredTables.filter(table => {
      const tableStatus = (table.status || '').toLowerCase();
      console.log('Table:', table.name, 'Status:', tableStatus, 'Original:', table.status);
      if (currentFilter === 'available') {
        return tableStatus === 'available' || tableStatus === 'trống';
      } else if (currentFilter === 'occupied') {
        return tableStatus === 'occupied' || tableStatus === 'có khách';
      }
      return tableStatus === currentFilter;
    });
    console.log('After status filter:', filteredTables.length, 'tables');
  }
  
  // Filter by room
  if (currentRoom !== 'all') {
    console.log('Filtering by room:', currentRoom);
    filteredTables = filteredTables.filter(table => {
      console.log('Table:', table.name, 'Room:', table.room, 'Type:', typeof table.room);
      
      if (currentRoom === 'special') {
        return table.room === 'Đặc biệt';
      }
      
      // Find room name by ID
      const selectedRoom = (window.rooms || rooms || []).find(room => room.id === currentRoom);
      if (selectedRoom) {
        console.log('Selected room:', selectedRoom.name);
        return table.room === selectedRoom.name;
      }
      
      return false;
    });
    console.log('After room filter:', filteredTables.length, 'tables');
  }
  
  if (filteredTables.length === 0) {
    tablesGrid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 20px; color: #6c757d;">
        <i class='bx bx-table' style="font-size: 48px; margin-bottom: 16px; color: #dee2e6;"></i>
        <p>Không có bàn nào</p>
      </div>
    `;
  } else {
    tablesGrid.innerHTML = filteredTables.map(table => {
      const isSelected = selectedTable && selectedTable.id === table.id;
      const tableStatus = (table.status || '').toLowerCase();
      const statusText = (tableStatus === 'available' || tableStatus === 'trống') ? 'Trống' : 'Có khách';
      const statusClass = (tableStatus === 'available' || tableStatus === 'trống') ? 'available' : 'occupied';
      
      // Handle room name - could be string or object
      let roomName = 'Chưa phân loại';
      if (typeof table.room === 'string') {
        roomName = table.room;
      } else if (table.room && table.room.name) {
        roomName = table.room.name;
      }
      
      return `
        <div class="table-item \${statusClass} \${isSelected ? 'selected' : ''}" 
             data-table-id="\${table.id}" data-status="\${statusClass}">
          <div class="table-icon">
            <i class='bx bx-table'></i>
          </div>
          <span class="table-name">\${table.name}</span>
          <span class="table-room">\${roomName}</span>
          <span class="table-capacity">\${table.capacity || 4} người</span>
          <span class="status-badge \${statusClass}">
            \${statusText}
          </span>
        </div>
      `;
    }).join('');
  }
}

// Render menu
function renderMenu() {
  const menuGrid = document.getElementById('menuGrid');
  const searchTerm = document.getElementById('menuSearch').value.toLowerCase();
  
  let filteredItems = menuItems || [];
  
  // Filter by category
  if (currentCategory !== 'all') {
    filteredItems = filteredItems.filter(item => item.category === currentCategory);
  }
  
  // Filter by search term
  if (searchTerm) {
    filteredItems = filteredItems.filter(item => 
      item.name.toLowerCase().includes(searchTerm)
    );
  }
  
  if (filteredItems.length === 0) {
    menuGrid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #6c757d;">
        <i class='bx bx-food-menu' style="font-size: 48px; margin-bottom: 16px; color: #dee2e6;"></i>
        <p>Không có món ăn nào</p>
      </div>
    `;
  } else {
    menuGrid.innerHTML = filteredItems.map(item => {
      const imageUrl = item.imageUrl || '🍽️';
      const displayImage = imageUrl.startsWith('http') || imageUrl.startsWith('/') ? 
        `<img src="\${imageUrl}" alt="\${item.name}" style="width: 32px; height: 32px; object-fit: cover; border-radius: 4px;">` : 
        imageUrl;
      
      return `
        <div class="menu-item" data-item-id="\${item.id}">
          <div class="menu-item-image">\${displayImage}</div>
          <div class="menu-item-info">
            <h4>\${item.name}</h4>
            <p class="price">\${parseFloat(item.price || 0).toLocaleString('vi-VN')}đ</p>
          </div>
          <button class="add-to-cart-btn" onclick="addToCart('\${item.id}')">
            <i class='bx bx-plus'></i>
          </button>
        </div>
      `;
    }).join('');
  }
}

// Populate menu categories
function populateMenuCategories() {
  const menuCategories = document.getElementById('menuCategories');
  menuCategories.innerHTML = '<button class="category-btn active" data-category="all">Tất cả</button>';
  
  if (categories && categories.length > 0) {
    categories.forEach(category => {
      const button = document.createElement('button');
      button.className = 'category-btn';
      button.setAttribute('data-category', category.id);
      button.textContent = category.name;
      menuCategories.appendChild(button);
    });
  }
}

// Add item to cart
function addToCart(itemId) {
  if (!selectedTable) {
    alert('Vui lòng chọn bàn trước khi thêm món!');
    return;
  }
  
  const item = menuItems.find(i => i.id === itemId);
  if (!item) {
    alert('Không tìm thấy món ăn!');
    return;
  }
  
  const existingItem = orderItems.find(i => i.id === itemId);
  
  if (existingItem) {
    existingItem.quantity += 1;
  } else {
    orderItems.push({
      id: item.id,
      name: item.name,
      price: parseFloat(item.price || 0),
      quantity: 1
    });
  }
  
  renderOrderItems();
  updateBill();
}

// Remove item from cart
function removeFromCart(itemId) {
  orderItems = orderItems.filter(item => item.id !== itemId);
  renderOrderItems();
  updateBill();
}

// Update item quantity
function updateQuantity(itemId, newQuantity) {
  if (newQuantity <= 0) {
    removeFromCart(itemId);
    return;
  }
  
  const item = orderItems.find(i => i.id === itemId);
  if (item) {
    item.quantity = newQuantity;
    renderOrderItems();
    updateBill();
  }
}

// Render order items
function renderOrderItems() {
  const orderItemsContainer = document.getElementById('orderItems');
  
  if (orderItems.length === 0) {
    orderItemsContainer.innerHTML = `
      <div class="empty-order">
        <i class='bx bx-shopping-cart'></i>
        <p>Chưa có món nào được chọn</p>
      </div>
    `;
    return;
  }
  
  orderItemsContainer.innerHTML = orderItems.map(item => `
    <div class="order-item">
      <div class="item-info">
        <span class="item-name">\${item.name}</span>
        <span class="item-price">\${item.price.toLocaleString('vi-VN')}đ</span>
      </div>
      <div class="quantity-controls">
        <button onclick="updateQuantity(\${item.id}, \${item.quantity - 1})">
          <i class='bx bx-minus'></i>
        </button>
        <span class="quantity">\${item.quantity}</span>
        <button onclick="updateQuantity(\${item.id}, \${item.quantity + 1})">
          <i class='bx bx-plus'></i>
        </button>
      </div>
      <button class="remove-btn" onclick="removeFromCart(\${item.id})">
        <i class='bx bx-trash'></i>
      </button>
    </div>
  `).join('');
}

// Update bill
function updateBill() {
  const subtotal = orderItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const vat = Math.round(subtotal * 0.1);
  const total = subtotal + vat;
  
  document.getElementById('subtotal').textContent = subtotal.toLocaleString('vi-VN') + 'đ';
  document.getElementById('vat').textContent = vat.toLocaleString('vi-VN') + 'đ';
  document.getElementById('total').textContent = total.toLocaleString('vi-VN') + 'đ';
  
  // Enable/disable checkout button
  const checkoutBtn = document.getElementById('checkoutBtn');
  checkoutBtn.disabled = orderItems.length === 0 || !selectedTable;
}

// Setup tab system
function setupTabSystem() {
  const tabButtons = document.querySelectorAll('.tab-btn');
  const tabPanels = document.querySelectorAll('.tab-panel');
  
  tabButtons.forEach(button => {
    button.addEventListener('click', function() {
      const targetTab = this.dataset.tab;
      
      // Remove active class from all buttons and panels
      tabButtons.forEach(btn => btn.classList.remove('active'));
      tabPanels.forEach(panel => panel.classList.remove('active'));
      
      // Add active class to clicked button and corresponding panel
      this.classList.add('active');
      document.getElementById(targetTab + '-tab').classList.add('active');
      
      console.log('Switched to tab:', targetTab);
    });
  });
}

// Setup event listeners
function setupEventListeners() {
  // Table selection
  document.addEventListener('click', function(e) {
    if (e.target.closest('.table-item')) {
      const tableItem = e.target.closest('.table-item');
      const tableId = tableItem.dataset.tableId;
      const tableStatus = tableItem.dataset.status;
      
      if (tableStatus === 'occupied') {
        alert('Bàn này đang có khách!');
        return;
      }
      
      selectedTable = (window.tables || tables || []).find(t => t.id === tableId);
      if (selectedTable) {
        // Display table info with room name
        let tableInfo = selectedTable.name;
        if (selectedTable.room) {
          if (typeof selectedTable.room === 'string') {
            tableInfo += ` - \${selectedTable.room}`;
          } else if (selectedTable.room.name) {
            tableInfo += ` - \${selectedTable.room.name}`;
          }
        }
        document.getElementById('selectedTableInfo').textContent = tableInfo;
        renderTables();
        updateBill();
      }
    }
  });
  
  // Table filters
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      this.classList.add('active');
      currentFilter = this.dataset.filter;
      renderTables();
    });
  });

  // Menu categories
  document.querySelectorAll('.category-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      document.querySelectorAll('.category-btn').forEach(b => b.classList.remove('active'));
      this.classList.add('active');
      currentCategory = this.dataset.category;
      renderMenu();
    });
  });

  // Menu search
  document.getElementById('menuSearch').addEventListener('input', renderMenu);

  // Room filter
  document.getElementById('roomFilter').addEventListener('change', function() {
    currentRoom = this.value;
    console.log('Room filter changed to:', currentRoom);
    renderTables();
  });
  
  // Clear order
  document.getElementById('clearOrder').addEventListener('click', function() {
    if (confirm('Bạn có chắc muốn xóa toàn bộ đơn hàng?')) {
      orderItems = [];
      renderOrderItems();
      updateBill();
    }
  });
  
  // Payment methods
  document.querySelectorAll('.payment-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      document.querySelectorAll('.payment-btn').forEach(b => b.classList.remove('active'));
      this.classList.add('active');
    });
  });

  // Checkout
  document.getElementById('checkoutBtn').addEventListener('click', function() {
    if (orderItems.length === 0) {
      alert('Vui lòng chọn ít nhất một món!');
    return;
  }

  if (!selectedTable) {
    alert('Vui lòng chọn bàn!');
    return;
  }

    const total = orderItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const vat = Math.round(total * 0.1);
    const finalTotal = total + vat;
    
    if (confirm(`Xác nhận thanh toán cho \${selectedTable.name}?\nTổng tiền: \${finalTotal.toLocaleString('vi-VN')}đ`)) {
  alert('Thanh toán thành công!');
      // Reset order
      orderItems = [];
  selectedTable = null;
      document.getElementById('selectedTableInfo').textContent = 'Chưa chọn bàn';
      renderOrderItems();
  renderTables();
      updateBill();
    }
  });
}
</script>

</body>
</html>