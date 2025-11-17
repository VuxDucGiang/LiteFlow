/**
 * ========================================
 * RECEPTION SYSTEM - LITEFLOW
 * Modern Dashboard for Reservation Management
 * ========================================
 */

// ========================================
// GLOBAL VARIABLES
// ========================================

let reservations = [];
let rooms = [];
let tables = [];
let products = [];
let contextPath = '';

let currentDate = new Date();
let currentView = 'timeline'; // timeline or calendar
let currentFilter = {
    status: '',
    search: ''
};

let preOrderedItems = [];
let editingReservationId = null;

// ========================================
// INITIALIZATION
// ========================================

document.addEventListener('DOMContentLoaded', function() {
    console.log('🏨 Reception Dashboard loaded');
    
    // Load data from server
    loadInitialData();
    
    // Initialize UI
    initializeUI();
    
    // Start auto-refresh
    setInterval(refreshData, 30000); // Every 30 seconds
    
    // Update time display
    updateTimeDisplay();
    setInterval(updateTimeDisplay, 1000);
});

function loadInitialData() {
    // Load data from window object (set by JSP)
    reservations = window.reservationsData || [];
    rooms = window.roomsData || [];
    tables = window.tablesData || [];
    products = window.productsData || [];
    contextPath = window.contextPath || '';
    
    console.log('✅ Data loaded successfully:');
    console.log('  📊 Reservations:', reservations.length);
    console.log('  🏠 Rooms:', rooms.length);
    console.log('  🪑 Tables:', tables.length);
    console.log('  🍽️ Products:', products.length);
    console.log('  🔗 Context Path:', contextPath);
}

function initializeUI() {
    // Update stats
    updateStats();
    
    // Render timeline
    renderTimeline();
    
    // Render reservation list
    renderReservationList();
    
    // Load rooms dropdown
    loadRoomsDropdown();
    
    // Load products grid
    loadProductsGrid();
    
    // Update date display
    updateDateDisplay();
}

// ========================================
// TIME & DATE DISPLAY
// ========================================

function updateTimeDisplay() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString('vi-VN', { 
        hour: '2-digit', 
        minute: '2-digit',
        second: '2-digit'
    });
    const dateStr = now.toLocaleDateString('vi-VN', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
    
    document.getElementById('currentTime').textContent = timeStr;
}

function updateDateDisplay() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const selected = new Date(currentDate);
    selected.setHours(0, 0, 0, 0);
    
    let displayText;
    const diff = Math.floor((selected - today) / (1000 * 60 * 60 * 24));
    
    if (diff === 0) {
        displayText = 'Hôm nay';
    } else if (diff === 1) {
        displayText = 'Ngày mai';
    } else if (diff === -1) {
        displayText = 'Hôm qua';
    } else {
        displayText = currentDate.toLocaleDateString('vi-VN', {
            weekday: 'short',
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
    }
    
    document.getElementById('currentDateDisplay').textContent = displayText;
}

// ========================================
// NAVIGATION FUNCTIONS
// ========================================

function previousDay() {
    currentDate.setDate(currentDate.getDate() - 1);
    updateDateDisplay();
    refreshData();
}

function nextDay() {
    currentDate.setDate(currentDate.getDate() + 1);
    updateDateDisplay();
    refreshData();
}

function goToToday() {
    currentDate = new Date();
    updateDateDisplay();
    refreshData();
}

function previousWeek() {
    currentDate.setDate(currentDate.getDate() - 7);
    updateDateDisplay();
    refreshData();
}

function nextWeek() {
    currentDate.setDate(currentDate.getDate() + 7);
    updateDateDisplay();
    refreshData();
}

/**
 * Show date picker when clicking calendar button
 */
function showDatePicker(event) {
    // Prevent default to avoid triggering twice
    if (event) {
        event.stopPropagation();
    }
    
    const picker = document.getElementById('hiddenDatePicker');
    if (!picker) {
        console.error('Date picker input not found');
        return;
    }
    
    // Set picker value to current date
    const dateStr = formatDateForFilter(currentDate);
    picker.value = dateStr;
    
    // Focus on the input to trigger native picker
    picker.focus();
    
    // Try modern showPicker API (works on Chrome 99+, Edge 99+, Safari 16+)
    if (typeof picker.showPicker === 'function') {
        try {
            picker.showPicker();
            console.log('✅ Date picker opened using showPicker()');
        } catch (error) {
            console.warn('⚠️ showPicker() not available, using click fallback');
            picker.click();
        }
    } else {
        // Fallback: trigger click
        picker.click();
    }
}

/**
 * Handle date selection from picker
 */
function selectDateFromPicker() {
    const picker = document.getElementById('hiddenDatePicker');
    if (!picker || !picker.value) {
        console.warn('No date selected');
        return;
    }
    
    console.log('📅 Date selected:', picker.value);
    
    // Parse selected date
    const parts = picker.value.split('-');
    currentDate = new Date(parts[0], parts[1] - 1, parts[2]);
    
    // Update UI and fetch data for selected date
    updateDateDisplay();
    refreshData();
    
    console.log('✅ UI updated for date:', currentDate.toLocaleDateString('vi-VN'));
}

// ========================================
// DROPDOWN MANAGEMENT
// ========================================

function toggleDropdown(dropdownId) {
    const dropdown = document.getElementById(dropdownId);
    if (!dropdown) return;
    
    // Close all other dropdowns
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        if (menu.id !== dropdownId) {
            menu.classList.remove('show');
        }
    });
    
    dropdown.classList.toggle('show');
}

// Close dropdowns when clicking outside
document.addEventListener('click', function(event) {
    if (!event.target.closest('.dropdown')) {
        document.querySelectorAll('.dropdown-menu').forEach(menu => {
            menu.classList.remove('show');
        });
    }
});

// ========================================
// STATS DASHBOARD
// ========================================

function updateStats() {
    const todayReservations = getReservationsForDate(currentDate);
    
    const total = todayReservations.length;
    const pending = todayReservations.filter(r => r.status === 'PENDING').length;
    // ✅ Tính cả CLOSED và NO_SHOW vào trạng thái đã đóng
    const closed = todayReservations.filter(r => r.status === 'CLOSED' || r.status === 'NO_SHOW').length;
    
    document.getElementById('totalReservations').textContent = total;
    document.getElementById('pendingReservations').textContent = pending;
    const closedEl = document.getElementById('closedReservations');
    if (closedEl) closedEl.textContent = closed;
}

function getReservationsForDate(date) {
    const dateStr = formatDateForFilter(date);
    return reservations.filter(r => {
        const arrivalDate = new Date(r.arrivalTime);
        return formatDateForFilter(arrivalDate) === dateStr;
    });
}

function formatDateForFilter(date) {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// ========================================
// TIMELINE VIEW
// ========================================

function switchTimelineView(view) {
    currentView = view;
    
    // Update button states
    document.querySelectorAll('.view-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`.view-btn[data-view="${view}"]`)?.classList.add('active');
    
    // Show/hide views
    if (view === 'timeline') {
        document.getElementById('timelineView').style.display = 'block';
        document.getElementById('calendarView').style.display = 'none';
        renderTimeline();
    } else {
        document.getElementById('timelineView').style.display = 'none';
        document.getElementById('calendarView').style.display = 'block';
        renderCalendar();
    }
}

function renderTimeline() {
    const container = document.getElementById('timelineContainer');
    if (!container) return;
    
    const todayReservations = getReservationsForDate(currentDate);
    
    // Generate time slots from 8:00 to 22:00
    let html = '';
    for (let hour = 8; hour <= 22; hour++) {
        const timeSlot = `${String(hour).padStart(2, '0')}:00`;
        const slotReservations = todayReservations.filter(r => {
            const arrivalTime = new Date(r.arrivalTime);
            return arrivalTime.getHours() === hour;
        });
        
        html += `
            <div class="timeline-slot">
                <div class="timeline-time">${timeSlot}</div>
                <div class="timeline-content">
                    ${slotReservations.map(r => `
                        <div class="timeline-item status-${r.status}" onclick="openEditReservation('${r.reservationId}')">
                            <div class="timeline-item-header">
                                <span class="timeline-item-name">${escapeHtml(r.customerName)}</span>
                                <span class="timeline-item-guests">
                                    <i class='bx bx-user'></i> ${r.numberOfGuests}
                                </span>
                            </div>
                            <div class="timeline-item-info">
                                <span><i class='bx bx-time'></i> ${formatTime(r.arrivalTime)}</span>
                                ${r.tableName ? `<span><i class='bx bx-chair'></i> ${r.tableName}</span>` : ''}
                                <span><i class='bx bx-phone'></i> ${r.customerPhone}</span>
                            </div>
                        </div>
                    `).join('')}
                    ${slotReservations.length === 0 ? '<div style="color: #9ca3af; font-size: 13px; padding: 12px;">Trống</div>' : ''}
                </div>
            </div>
        `;
    }
    
    container.innerHTML = html;
}

// ========================================
// CALENDAR VIEW
// ========================================

function renderCalendar() {
    const container = document.getElementById('calendarGrid');
    if (!container) return;
    
    // Get week start (Monday)
    const weekStart = new Date(currentDate);
    const day = weekStart.getDay();
    const diff = weekStart.getDate() - day + (day === 0 ? -6 : 1);
    weekStart.setDate(diff);
    
    let html = '';
    const dayNames = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];
    
    for (let i = 0; i < 7; i++) {
        const currentDay = new Date(weekStart);
        currentDay.setDate(weekStart.getDate() + i);
        
        const dayId = `cal-${formatDateForFilter(currentDay)}`;
        const isToday = formatDateForFilter(currentDay) === formatDateForFilter(new Date());
        
        html += `
            <div class="calendar-day ${isToday ? 'today' : ''}" onclick="selectDate('${formatDateForFilter(currentDay)}')">
                <div style="font-size: 11px; color: #6b7280; font-weight: 600; margin-bottom: 4px;">
                    ${dayNames[i]}
                </div>
                <div class="calendar-day-number">${currentDay.getDate()}</div>
                <div class="calendar-day-count" id="${dayId}">...
                </div>
            </div>
        `;
    }
    
    container.innerHTML = html;
    
    // Update week display
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 6);
    const weekDisplay = `${weekStart.getDate()}/${weekStart.getMonth() + 1} - ${weekEnd.getDate()}/${weekEnd.getMonth() + 1}/${weekEnd.getFullYear()}`;
    if (document.getElementById('weekDisplay')) {
        document.getElementById('weekDisplay').textContent = weekDisplay;
    }
    // After render, fetch counts for each day in the week from server
    for (let i = 0; i < 7; i++) {
        const d = new Date(weekStart);
        d.setDate(weekStart.getDate() + i);
        const dateStr = formatDateForFilter(d);
        fetch(`${contextPath}/reception/api/reservations?date=${dateStr}`)
            .then(r => r.json())
            .then(res => {
                const count = (res && res.success && Array.isArray(res.reservations)) ? res.reservations.length : 0;
                const el = document.getElementById(`cal-${dateStr}`);
                if (el) el.textContent = `${count} đặt bàn`;
            })
            .catch(() => {
                const el = document.getElementById(`cal-${dateStr}`);
                if (el) el.textContent = '—';
            });
    }
}

function selectDate(dateStr) {
    const parts = dateStr.split('-');
    currentDate = new Date(parts[0], parts[1] - 1, parts[2]);
    updateDateDisplay();
    refreshData();
}

// Triggered by refresh button on top-nav: refresh and show toast
function triggerRefresh() {
    refreshData();
    showNotification('success', 'Đã làm mới', 'Đã làm mới dữ liệu thành công');
}

// ========================================
// RESERVATION LIST
// ========================================

function renderReservationList() {
    const container = document.getElementById('reservationList');
    if (!container) return;
    
    let filteredReservations = getReservationsForDate(currentDate);
    
    // Apply filters
    if (currentFilter.status) {
        filteredReservations = filteredReservations.filter(r => r.status === currentFilter.status);
    }
    
    if (currentFilter.search) {
        const searchLower = currentFilter.search.toLowerCase();
        filteredReservations = filteredReservations.filter(r => 
            r.customerName.toLowerCase().includes(searchLower) ||
            r.customerPhone.includes(searchLower) ||
            r.reservationCode.toLowerCase().includes(searchLower)
        );
    }
    
    if (filteredReservations.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <i class='bx bx-calendar-x'></i>
                <p>Không có đặt bàn nào</p>
                <button class="btn-create" onclick="openCreateReservation()">
                    <i class='bx bx-plus'></i>
                    Tạo đặt bàn mới
                </button>
            </div>
        `;
        return;
    }
    
    // List panel sorting:
    // 1) Push CLOSED items to the bottom
    // 2) Within the same status bucket, newest (createdAt) first; fallback to arrivalTime
    filteredReservations.sort((a, b) => {
        const aClosed = a.status === 'CLOSED' ? 1 : 0;
        const bClosed = b.status === 'CLOSED' ? 1 : 0;
        if (aClosed !== bClosed) return aClosed - bClosed; // non-closed first
        const aKey = new Date(a.createdAt || a.arrivalTime);
        const bKey = new Date(b.createdAt || b.arrivalTime);
        return bKey - aKey; // desc
    });
    
    const html = filteredReservations.map(r => `
        <div class="reservation-card" onclick="openEditReservation('${r.reservationId}')">
            <div class="reservation-card-header">
                <div class="reservation-card-info">
                    <h3>${escapeHtml(r.customerName)}</h3>
                    <p>Mã: ${r.reservationCode}</p>
                </div>
                <span class="status-badge ${r.status}">${getStatusLabel(r.status)}</span>
            </div>
            
            <div class="reservation-card-details">
                <div class="detail-item">
                    <i class='bx bx-time'></i>
                    <span>${formatDateTime(r.arrivalTime)}</span>
                </div>
                <div class="detail-item">
                    <i class='bx bx-user'></i>
                    <span>${r.numberOfGuests} khách</span>
                </div>
                <div class="detail-item">
                    <i class='bx bx-phone'></i>
                    <span>${r.customerPhone}</span>
                </div>
                ${r.tableName ? `
                    <div class="detail-item">
                        <i class='bx bx-chair'></i>
                        <span>${r.tableName}</span>
                    </div>
                ` : ''}
            </div>

            ${r.notes ? `
                <div class="detail-item" style="margin: 6px 0 0 0; color:#4b5563;">
                    <i class='bx bx-note'></i>
                    <span>${escapeHtml(r.notes)}</span>
                </div>
            ` : ''}

            ${(r.preOrderedItems && r.preOrderedItems.length) ? `
                <div class="preordered-chips">
                    ${r.preOrderedItems.map(it => `
                        <span class="chip">${escapeHtml(it.productName)} × ${it.quantity}</span>
                    `).join('')}
                </div>
            ` : ''}
            
            <div class="reservation-card-actions" onclick="event.stopPropagation()">
                ${getQuickActions(r)}
            </div>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

function getStatusLabel(status) {
    const labels = {
        'PENDING': 'Chờ xác nhận',
        'CONFIRMED': 'Đã xác nhận',
        'CANCELLED': 'Đã hủy',
        'NO_SHOW': 'Không đến',
        'CLOSED': 'Đã đóng'
    };
    return labels[status] || status;
}

function getQuickActions(reservation) {
    if (reservation.status === 'PENDING') {
        return `
            <button class="card-action-btn primary" onclick="openActionModal('confirm', '${reservation.reservationId}')">
                <i class='bx bx-check'></i>
                Xác nhận đến
            </button>
            <button class="card-action-btn" onclick="cancelReservation('${reservation.reservationId}')">
                <i class='bx bx-x'></i>
                Hủy
            </button>
        `;
    }
    return '';
}

// Modal-based confirmation for actions
function openActionModal(action, reservationId) {
    const modal = document.getElementById('actionModal');
    const overlay = document.getElementById('actionModalOverlay');
    const titleEl = document.getElementById('actionModalTitle');
    const bodyEl = document.getElementById('actionModalBody');
    const confirmBtn = document.getElementById('actionModalConfirmBtn');

    const reservation = reservations.find(r => r.reservationId === reservationId);
    if (!reservation) return;

    const actionLabel = action === 'confirm' ? 'Xác nhận khách đã đến' : 'Đóng đơn (khách đã thanh toán)';
    titleEl.innerHTML = `<i class='bx bx-question-mark'></i> ${actionLabel}`;

    const itemsHtml = (reservation.preOrderedItems && reservation.preOrderedItems.length)
        ? reservation.preOrderedItems.map(it => `
            <div class="detail-item"><i class='bx bx-dish'></i>
            <span>${escapeHtml(it.productName)} × ${it.quantity}${it.note ? ` — <em>${escapeHtml(it.note)}</em>` : ''}</span></div>
          `).join('')
        : '<div style="color:#6b7280">Không có món đặt trước</div>';

    bodyEl.innerHTML = `
        <div class="detail-item" style="margin-bottom:8px;"><i class='bx bx-id-card'></i><span>${escapeHtml(reservation.customerName)} — ${reservation.customerPhone}</span></div>
        <div class="detail-item" style="margin-bottom:8px;"><i class='bx bx-time-five'></i><span>${formatDateTime(reservation.arrivalTime)}</span></div>
        ${reservation.tableName ? `<div class="detail-item" style="margin-bottom:8px;"><i class='bx bx-chair'></i><span>${reservation.tableName}</span></div>` : ''}
        ${reservation.notes ? `<div class="detail-item" style="margin-bottom:8px;"><i class='bx bx-note'></i><span>${escapeHtml(reservation.notes)}</span></div>` : ''}
        <div style="margin-top:10px; padding-top:10px; border-top:1px solid #e5e7eb;">
            <div style="font-weight:700; margin-bottom:6px;">Món đặt trước</div>
            ${itemsHtml}
        </div>
    `;

    confirmBtn.onclick = () => {
        if (action === 'confirm') confirmArrival(reservationId, { silent: true });
        else closeReservation(reservationId, { silent: true });
        closeActionModal();
    };

    overlay.classList.add('active');
    modal.classList.add('active');
}

function closeActionModal() {
    document.getElementById('actionModalOverlay').classList.remove('active');
    document.getElementById('actionModal').classList.remove('active');
}

// ========================================
// FILTERS & SEARCH
// ========================================

function filterReservations() {
    const select = document.getElementById('statusFilter');
    currentFilter.status = select ? select.value : '';
    renderReservationList();
}

function searchReservations() {
    const input = document.getElementById('searchInput');
    currentFilter.search = input ? input.value : '';
    renderReservationList();
}

// ========================================
// SIDEBAR PANEL
// ========================================

function openCreateReservation() {
    editingReservationId = null;
    document.getElementById('sidebarTitle').innerHTML = `
        <i class='bx bx-calendar-plus'></i>
        Đặt bàn mới
    `;
    
    // Reset form
    resetReservationForm();
    
    // Set default arrival time to next hour
    const now = new Date();
    now.setHours(now.getHours() + 1, 0, 0, 0);
    document.getElementById('arrivalTime').value = formatDateTimeLocal(now);
    
    // Show sidebar
    showSidebar();
}

function openEditReservation(reservationId) {
    editingReservationId = reservationId;
    const reservation = reservations.find(r => r.reservationId === reservationId);
    
    if (!reservation) {
        showNotification('error', 'Không tìm thấy', 'Không tìm thấy thông tin đặt bàn');
        return;
    }
    
    document.getElementById('sidebarTitle').innerHTML = `
        <i class='bx bx-edit'></i>
        Chỉnh sửa đặt bàn
    `;
    
    // Fill form with reservation data
    document.getElementById('reservationId').value = reservation.reservationId;
    document.getElementById('customerName').value = reservation.customerName;
    document.getElementById('customerPhone').value = reservation.customerPhone;
    document.getElementById('customerEmail').value = reservation.customerEmail || '';
    document.getElementById('arrivalTime').value = formatDateTimeLocal(new Date(reservation.arrivalTime));
    document.getElementById('numberOfGuests').value = reservation.numberOfGuests;
    document.getElementById('roomId').value = reservation.roomId || '';
    filterTablesByRoom();
    document.getElementById('tableId').value = reservation.tableId || '';
    document.getElementById('notes').value = reservation.notes || '';
    
    // Load pre-ordered items
    preOrderedItems = reservation.preOrderedItems || [];
    renderPreOrderList();
    
    showSidebar();
}

function showSidebar() {
    document.getElementById('sidebarOverlay').classList.add('active');
    document.getElementById('reservationSidebar').classList.add('active');
}

function closeSidebar() {
    document.getElementById('sidebarOverlay').classList.remove('active');
    document.getElementById('reservationSidebar').classList.remove('active');
    resetReservationForm();
}

function resetReservationForm() {
    document.getElementById('reservationForm').reset();
    document.getElementById('reservationId').value = '';
    preOrderedItems = [];
    renderPreOrderList();
}

// ========================================
// FORM SUBMISSION
// ========================================

function submitReservation() {
    // Validate form
    const customerName = document.getElementById('customerName').value.trim();
    const customerPhone = document.getElementById('customerPhone').value.trim();
    const arrivalTime = document.getElementById('arrivalTime').value;
    const numberOfGuests = parseInt(document.getElementById('numberOfGuests').value);
    
    if (!customerName || !customerPhone || !arrivalTime || !numberOfGuests) {
        showNotification('error', 'Thiếu thông tin', 'Vui lòng điền đầy đủ thông tin bắt buộc');
        return;
    }
    
    // Validate arrival time is not in the past
    const selectedDateTime = new Date(arrivalTime);
    const now = new Date();
    
    if (selectedDateTime < now) {
        showNotification('error', 'Thời gian không hợp lệ', 'Không thể đặt bàn cho thời gian trong quá khứ. Vui lòng chọn lại.');
        // Focus on the datetime input
        document.getElementById('arrivalTime').focus();
        return;
    }
    
    // Validate arrival time is not too far in the future (optional: max 90 days)
    const maxFuture = new Date();
    maxFuture.setDate(maxFuture.getDate() + 90);
    
    if (selectedDateTime > maxFuture) {
        showNotification('warning', 'Thời gian quá xa', 'Chỉ có thể đặt bàn trong vòng 90 ngày. Vui lòng chọn lại.');
        document.getElementById('arrivalTime').focus();
        return;
    }
    
    // Prepare data
    const data = {
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: document.getElementById('customerEmail').value.trim() || null,
        arrivalTime: arrivalTime,
        numberOfGuests: numberOfGuests,
        roomId: document.getElementById('roomId').value || null,
        tableId: document.getElementById('tableId').value || null,
        notes: document.getElementById('notes').value.trim() || null,
        preOrderedItems: preOrderedItems.map(item => ({
            productId: item.productId,
            quantity: item.quantity,
            note: item.note || null
        }))
    };
    
    // Submit to server
    // Include reservationId in body when updating
    if (editingReservationId) {
        data.reservationId = editingReservationId;
    }
    const url = editingReservationId 
        ? `${contextPath}/reception/update`
        : `${contextPath}/reception/create`;
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => {
        // Check if response is ok
        if (!response.ok) {
            // Try to parse error JSON
            return response.json().then(errorData => {
                throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
            }).catch(() => {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            });
        }
        return response.json();
    })
    .then(result => {
        if (result.success) {
            const title = editingReservationId ? 'Cập nhật thành công' : 'Đặt bàn thành công';
            const reservation = result.reservation || {};
            const code = reservation.reservationCode || result.reservationCode || '';
            const message = editingReservationId 
                ? 'Thông tin đặt bàn đã được cập nhật' 
                : `Mã đặt bàn: <span class="reservation-code" style="color:#fff;font-weight:800;letter-spacing:0.5px;">${escapeHtml(code)}</span>`;
            showNotification('success', title, message);
            // Optimistic UI update: insert/update into current list immediately
            try {
                if (reservation && reservation.arrivalTime) {
                    const sameDay = formatDateForFilter(new Date(reservation.arrivalTime)) === formatDateForFilter(currentDate);
                    if (sameDay) {
                        const idx = reservations.findIndex(r => r.reservationId === reservation.reservationId);
                        if (idx >= 0) {
                            reservations[idx] = reservation;
                        } else {
                            reservations.push(reservation);
                        }
                        // Keep list sorted by time
                        reservations.sort((a, b) => new Date(a.arrivalTime) - new Date(b.arrivalTime));
                        updateStats();
                        renderTimeline();
                        renderReservationList();
                    }
                }
            } catch (e) {
                console.warn('Optimistic refresh failed, falling back to full refresh', e);
            }
            closeSidebar();
            // Final sync from server to ensure consistency
            setTimeout(() => refreshData(), 100);
        } else {
            const errorMsg = result.message || 'Có lỗi xảy ra khi lưu đặt bàn';
            console.error('Server returned error:', errorMsg);
            showNotification('error', 'Thất bại', errorMsg);
        }
    })
    .catch(error => {
        console.error('Error submitting reservation:', error);
        let errorMessage = 'Không thể kết nối đến server. Vui lòng thử lại.';
        
        if (error.message) {
            // Use the error message from server if available
            errorMessage = error.message;
        } else if (error instanceof TypeError && error.message.includes('fetch')) {
            errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        }
        
        showNotification('error', 'Lỗi', errorMessage);
    });
}

// ========================================
// PRE-ORDER ITEMS
// ========================================

function openProductSelector() {
    document.getElementById('productSelectorOverlay').classList.add('active');
    document.getElementById('productSelectorModal').classList.add('active');
}

function closeProductSelector() {
    document.getElementById('productSelectorOverlay').classList.remove('active');
    document.getElementById('productSelectorModal').classList.remove('active');
}

function loadProductsGrid() {
    const grid = document.getElementById('productGrid');
    if (!grid) return;
    
    if (products.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #6c757d;">
                <i class='bx bx-food-menu' style="font-size: 48px; margin-bottom: 16px; color: #dee2e6;"></i>
                <p>Không có món ăn nào</p>
            </div>
        `;
        return;
    }
    
    const html = products.map(p => {
        // Kiểm tra hình ảnh
        let imageHTML = '';
        if (p.imageUrl && p.imageUrl !== 'null' && p.imageUrl.trim() !== '') {
            imageHTML = `<img src="${p.imageUrl}" alt="${escapeHtml(p.name)}" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                         <i class='bx bx-restaurant' style="display: none;"></i>`;
        } else {
            imageHTML = `<i class='bx bx-restaurant'></i>`;
        }
        
        // Kiểm tra tồn kho (nếu có)
        const outOfStock = p.quantityAvailable !== undefined && p.quantityAvailable <= 0;
        const stockClass = outOfStock ? ' out-of-stock' : '';
        
        return `
            <div class="product-item${stockClass}" 
                 onclick="${outOfStock ? '' : `addProductToPreOrder('${p.productId}', '${escapeHtml(p.name)}')`}">
                <div class="product-item-image">
                    ${imageHTML}
                </div>
                <span class="product-item-name">${escapeHtml(p.name)}</span>
                ${p.size ? `<span class="product-item-size">${escapeHtml(p.size)}</span>` : ''}
                <span class="product-item-price">${formatCurrency(p.price)}</span>
                ${outOfStock ? '<div class="out-of-stock-badge">Hết hàng</div>' : ''}
            </div>
        `;
    }).join('');
    
    grid.innerHTML = html;
}

function searchProducts() {
    const input = document.getElementById('productSearchInput');
    const search = input ? input.value.toLowerCase() : '';
    const grid = document.getElementById('productGrid');
    if (!grid) return;
    
    const filtered = products.filter(p => 
        p.name.toLowerCase().includes(search)
    );
    
    if (filtered.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #6c757d;">
                <i class='bx bx-search' style="font-size: 48px; margin-bottom: 16px; color: #dee2e6;"></i>
                <p>Không tìm thấy món ăn "${search}"</p>
            </div>
        `;
        return;
    }
    
    const html = filtered.map(p => {
        // Kiểm tra hình ảnh
        let imageHTML = '';
        if (p.imageUrl && p.imageUrl !== 'null' && p.imageUrl.trim() !== '') {
            imageHTML = `<img src="${p.imageUrl}" alt="${escapeHtml(p.name)}" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                         <i class='bx bx-restaurant' style="display: none;"></i>`;
        } else {
            imageHTML = `<i class='bx bx-restaurant'></i>`;
        }
        
        // Kiểm tra tồn kho
        const outOfStock = p.quantityAvailable !== undefined && p.quantityAvailable <= 0;
        const stockClass = outOfStock ? ' out-of-stock' : '';
        
        return `
            <div class="product-item${stockClass}" 
                 onclick="${outOfStock ? '' : `addProductToPreOrder('${p.productId}', '${escapeHtml(p.name)}')`}">
                <div class="product-item-image">
                    ${imageHTML}
                </div>
                <span class="product-item-name">${escapeHtml(p.name)}</span>
                ${p.size ? `<span class="product-item-size">${escapeHtml(p.size)}</span>` : ''}
                <span class="product-item-price">${formatCurrency(p.price)}</span>
                ${outOfStock ? '<div class="out-of-stock-badge">Hết hàng</div>' : ''}
            </div>
        `;
    }).join('');
    
    grid.innerHTML = html;
}

function addProductToPreOrder(productId, productName) {
    // Check if already exists
    const existing = preOrderedItems.find(item => item.productId === productId);
    if (existing) {
        existing.quantity++;
    } else {
        preOrderedItems.push({
            productId: productId,
            productName: productName,
            quantity: 1,
            note: ''
        });
    }
    
    renderPreOrderList();
    closeProductSelector();
}

function renderPreOrderList() {
    const container = document.getElementById('preOrderList');
    if (!container) return;
    
    if (preOrderedItems.length === 0) {
        container.innerHTML = `
            <div class="empty-preorder">
                <i class='bx bx-dish'></i>
                <p>Chưa có món đặt trước</p>
            </div>
        `;
        return;
    }
    
    const html = preOrderedItems.map((item, index) => `
        <div class="preorder-item">
            <div class="preorder-item-info">
                <div class="preorder-item-name">${escapeHtml(item.productName)}</div>
                ${item.note ? `<div class="preorder-item-note">${escapeHtml(item.note)}</div>` : ''}
            </div>
            <div class="preorder-item-quantity">
                <button class="qty-btn" onclick="updatePreOrderQuantity(${index}, -1)">
                    <i class='bx bx-minus'></i>
                </button>
                <span class="qty-value">${item.quantity}</span>
                <button class="qty-btn" onclick="updatePreOrderQuantity(${index}, 1)">
                    <i class='bx bx-plus'></i>
                </button>
            </div>
            <button class="remove-item-btn" onclick="removePreOrderItem(${index})">
                <i class='bx bx-trash'></i>
            </button>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

function updatePreOrderQuantity(index, delta) {
    if (!preOrderedItems[index]) return;
    
    preOrderedItems[index].quantity += delta;
    if (preOrderedItems[index].quantity <= 0) {
        preOrderedItems.splice(index, 1);
    }
    
    renderPreOrderList();
}

function removePreOrderItem(index) {
    preOrderedItems.splice(index, 1);
    renderPreOrderList();
}

// ========================================
// ROOM & TABLE MANAGEMENT
// ========================================

function loadRoomsDropdown() {
    const select = document.getElementById('roomId');
    if (!select) return;
    
    const html = '<option value="">-- Chọn phòng --</option>' +
        rooms.map(r => `<option value="${r.roomId}">${escapeHtml(r.name)}</option>`).join('');
    
    select.innerHTML = html;
}

function filterTablesByRoom() {
    const roomSelect = document.getElementById('roomId');
    const tableSelect = document.getElementById('tableId');
    const numberOfGuestsInput = document.getElementById('numberOfGuests');
    
    if (!roomSelect || !tableSelect) return;
    
    const selectedRoomId = roomSelect.value;
    const numberOfGuests = numberOfGuestsInput ? parseInt(numberOfGuestsInput.value) || 0 : 0;
    
    // Filter tables
    let filtered = tables;
    
    // Filter by room if selected
    if (selectedRoomId) {
        filtered = filtered.filter(t => t.roomId === selectedRoomId);
    }
    
    // Filter by capacity (only show tables that can fit the number of guests)
    if (numberOfGuests > 0) {
        filtered = filtered.filter(t => t.capacity >= numberOfGuests);
    }
    
    // Build options HTML
    let html = '<option value="">-- Chọn bàn (nếu có) --</option>';
    
    if (filtered.length === 0 && numberOfGuests > 0) {
        html += `<option value="" disabled>Không có bàn phù hợp cho ${numberOfGuests} khách</option>`;
    } else {
        html += filtered.map(t => {
            const capacityInfo = numberOfGuests > 0 ? ` (${t.capacity} chỗ)` : '';
            return `<option value="${t.tableId}">${escapeHtml(t.tableName)}${capacityInfo}</option>`;
        }).join('');
    }
    
    tableSelect.innerHTML = html;
}

// ========================================
// QUICK ACTIONS
// ========================================

function confirmArrival(reservationId, opts = {}) {
    if (!opts.silent && !confirm('Xác nhận khách đã đến?')) return;
    
    fetch(`${contextPath}/reception/arrive`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            reservationId: reservationId
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            if (!opts.silent) showNotification('success', 'Xác nhận thành công', 'Khách hàng đã check-in');
            refreshData();
        } else {
            if (!opts.silent) showNotification('error', 'Xác nhận thất bại', result.message || 'Có lỗi xảy ra');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('error', 'Lỗi kết nối', 'Không thể kết nối đến server');
    });
}

function cancelReservation(reservationId) {
    if (!confirm('Bạn có chắc muốn hủy đặt bàn này?')) return;
    
    fetch(`${contextPath}/reception/cancel`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            reservationId: reservationId,
            reason: 'Hủy từ trang lễ tân'
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            showNotification('success', 'Hủy thành công', 'Đặt bàn đã được hủy');
            refreshData();
        } else {
            showNotification('error', 'Hủy thất bại', result.message || 'Có lỗi xảy ra');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('error', 'Lỗi kết nối', 'Không thể kết nối đến server');
    });
}

function closeReservation(reservationId, opts = {}) {
    if (!opts.silent && !confirm('Xác nhận khách đã thanh toán và đóng đơn?')) return;
    
    fetch(`${contextPath}/reception/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            reservationId: reservationId
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            if (!opts.silent) showNotification('success', 'Đã đóng đơn', 'Đặt bàn đã được thanh toán và đóng');
            refreshData();
        } else {
            if (!opts.silent) showNotification('error', 'Thất bại', result.message || 'Không thể đóng đơn');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('error', 'Lỗi kết nối', 'Không thể kết nối đến server');
    });
}

// Removed viewOrder(); navigation handled inline in action button

// ========================================
// IMPORT / EXPORT
// ========================================

function showImportModal() {
    document.getElementById('importModalOverlay').classList.add('active');
    document.getElementById('importModal').classList.add('active');
}

function closeImportModal() {
    document.getElementById('importModalOverlay').classList.remove('active');
    document.getElementById('importModal').classList.remove('active');
}

function handleFileSelect(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    const formData = new FormData();
    formData.append('file', file);
    
    fetch(`${contextPath}/reception/import`, {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            showNotification('success', 'Import thành công', `Đã import ${result.count || 0} đặt bàn`);
            closeImportModal();
            refreshData();
        } else {
            showNotification('error', 'Import thất bại', result.message || 'Có lỗi xảy ra khi import file');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('error', 'Lỗi kết nối', 'Không thể kết nối đến server');
    });
}

function exportToExcel() {
    window.location.href = `${contextPath}/reception/export?date=${formatDateForFilter(currentDate)}`;
}

function downloadTemplate() {
    window.location.href = `${contextPath}/reception/template`;
}

// ========================================
// NOTIFICATIONS
// ========================================

function toggleNotifications() {
    // TODO: Implement notifications panel
    showNotification('info', 'Thông báo', 'Tính năng đang được phát triển');
}

function showNotification(type, title, message) {
    // Support old signature: showNotification(message, type)
    if (typeof type === 'string' && !message) {
        const temp = type;
        type = title || 'info';
        message = temp;
        title = getTitleForType(type);
    }
    
    // Create or get notification stack
    let stack = document.getElementById('notification-stack');
    if (!stack) {
        stack = document.createElement('div');
        stack.id = 'notification-stack';
        stack.className = 'notification-stack';
        document.body.appendChild(stack);
    }

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    
    const icon = getNotificationIcon(type);
    notification.innerHTML = `
        <div class="notification-icon">${icon}</div>
        <div class="notification-content">
            <div class="notification-title">${title}</div>
            <div class="notification-message">${message}</div>
        </div>
        <div class="notification-close" onclick="this.parentElement.remove()">×</div>
        <div class="notification-progress"></div>
    `;

    // Add to stack
    stack.appendChild(notification);

    // Show notification with animation
    setTimeout(() => {
        notification.classList.add('show');
    }, 100);

    // Auto remove after 5 seconds
    setTimeout(() => {
        if (notification.parentElement) {
            notification.classList.remove('show');
            setTimeout(() => {
                if (notification.parentElement) {
                    notification.remove();
                }
            }, 300);
        }
    }, 5000);
}

function getNotificationIcon(type) {
    const icons = {
        success: '✅',
        error: '❌',
        warning: '⚠️',
        info: 'ℹ️'
    };
    return icons[type] || 'ℹ️';
}

function getTitleForType(type) {
    const titles = {
        success: 'Thành công',
        error: 'Lỗi',
        warning: 'Cảnh báo',
        info: 'Thông báo'
    };
    return titles[type] || 'Thông báo';
}

// ========================================
// NAVIGATION
// ========================================

function navigate(page) {
    const urls = {
        'management': `${contextPath}/dashboard`,
        'cashier': `${contextPath}/cashier`,
        'kitchen': `${contextPath}/kitchen`
    };
    
    if (urls[page]) {
        window.location.href = urls[page];
    }
}

/**
 * Logout functions (matching kitchen style)
 */
function logout() {
    openLogoutModal();
}

function openLogoutModal() {
    const modal = document.getElementById('logoutModal');
    const overlay = document.getElementById('logoutModalOverlay');
    if (modal && overlay) {
        overlay.style.display = 'block';
        modal.style.display = 'flex';
        setTimeout(() => {
            overlay.classList.add('active');
            modal.classList.add('show');
        }, 10);
    }
}

function closeLogoutModal() {
    const modal = document.getElementById('logoutModal');
    const overlay = document.getElementById('logoutModalOverlay');
    if (modal && overlay) {
        modal.classList.remove('show');
        overlay.classList.remove('active');
        setTimeout(() => {
            modal.style.display = 'none';
            overlay.style.display = 'none';
        }, 300);
    }
}

function confirmLogout() {
    window.location.href = contextPath + '/logout';
}

// ========================================
// DATA REFRESH
// ========================================

function refreshData() {
    fetch(`${contextPath}/reception/api/reservations?date=${formatDateForFilter(currentDate)}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                reservations = data.reservations || [];
                updateStats();
                renderTimeline();
                renderReservationList();
            }
        })
        .catch(error => {
            console.error('Error refreshing data:', error);
        });
}

function refreshReservations() {
    refreshData();
}

// ========================================
// UTILITY FUNCTIONS
// ========================================

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatDateTime(dateTimeStr) {
    const date = new Date(dateTimeStr);
    return date.toLocaleString('vi-VN', {
        hour: '2-digit',
        minute: '2-digit',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
}

function formatTime(dateTimeStr) {
    const date = new Date(dateTimeStr);
    return date.toLocaleTimeString('vi-VN', {
        hour: '2-digit',
        minute: '2-digit'
    });
}

function formatDateTimeLocal(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day}T${hours}:${minutes}`;
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}

console.log('✅ Reception script loaded successfully');
