/**
 * Enhanced Room Table Management JavaScript
 * Optimized for performance and user experience
 * Version: 2.0
 */

// Global variables for caching and performance
let tablesCache = new Map();
let roomsCache = new Map();
let lastUpdateTime = 0;
const CACHE_DURATION = 30000; // 30 seconds

// Performance monitoring
const performanceMonitor = {
    startTime: 0,
    endTime: 0,
    
    start: function() {
        this.startTime = performance.now();
    },
    
    end: function(operation) {
        this.endTime = performance.now();
        const duration = this.endTime - this.startTime;
        console.log(`⚡ ${operation} completed in ${duration.toFixed(2)}ms`);
        return duration;
    }
};

// Enhanced table management class
class RoomTableManager {
    constructor() {
        this.init();
        this.setupEventListeners();
        this.startAutoRefresh();
    }
    
    init() {
        console.log('🚀 Initializing Enhanced Room Table Manager');
        this.loadInitialData();
        this.setupKeyboardShortcuts();
    }
    
    setupEventListeners() {
        // Debounced search
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', this.debounce(this.handleSearch.bind(this), 300));
        }
        
        // Table row click events
        document.addEventListener('click', this.handleTableClick.bind(this));
        
        // Modal close events
        window.addEventListener('click', this.handleModalClose.bind(this));
        
        // Keyboard navigation
        document.addEventListener('keydown', this.handleKeyboardNavigation.bind(this));
    }
    
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    async loadInitialData() {
        performanceMonitor.start();
        
        try {
            // Load data with caching
            await this.loadTablesWithCache();
            await this.loadRoomsWithCache();
            
            performanceMonitor.end('Initial data load');
        } catch (error) {
            console.error('❌ Error loading initial data:', error);
            this.showNotification('Lỗi khi tải dữ liệu', 'error');
        }
    }
    
    async loadTablesWithCache() {
        const now = Date.now();
        if (tablesCache.has('data') && (now - lastUpdateTime) < CACHE_DURATION) {
            return tablesCache.get('data');
        }
        
        // Fetch fresh data
        const response = await fetch('roomtable?action=getAllTables');
        const data = await response.json();
        
        tablesCache.set('data', data);
        lastUpdateTime = now;
        
        return data;
    }
    
    async loadRoomsWithCache() {
        const now = Date.now();
        if (roomsCache.has('data') && (now - lastUpdateTime) < CACHE_DURATION) {
            return roomsCache.get('data');
        }
        
        // Fetch fresh data
        const response = await fetch('roomtable?action=getAllRooms');
        const data = await response.json();
        
        roomsCache.set('data', data);
        return data;
    }
    
    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        const rows = document.querySelectorAll('.table tbody tr');
        
        performanceMonitor.start();
        
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            const isVisible = text.includes(searchTerm);
            
            row.style.display = isVisible ? '' : 'none';
            
            // Add highlight effect
            if (isVisible && searchTerm) {
                row.classList.add('search-highlight');
                setTimeout(() => row.classList.remove('search-highlight'), 2000);
            }
        });
        
        performanceMonitor.end('Search operation');
    }
    
    handleTableClick(event) {
        const target = event.target;
        
        // Handle action buttons
        if (target.classList.contains('btn')) {
            const action = target.getAttribute('onclick');
            if (action) {
                // Extract parameters from onclick
                const match = action.match(/\(['"]([^'"]+)['"]?\)/);
                if (match) {
                    const id = match[1];
                    this.handleTableAction(target, id);
                }
            }
        }
        
        // Handle row selection
        if (target.closest('tr')) {
            this.handleRowSelection(target.closest('tr'));
        }
    }
    
    handleTableAction(button, id) {
        const actionType = button.textContent.trim();
        
        switch (actionType) {
            case '👁️ Chi tiết':
                this.showTableDetails(id);
                break;
            case '✏️ Sửa':
                this.showEditTableModal(id);
                break;
            case '🔄 Đổi trạng thái':
                this.showStatusChangeModal(id);
                break;
            case '📋 Lịch sử':
                this.showTableHistory(id);
                break;
            case '🗑️ Xóa':
                this.confirmDeleteTable(id);
                break;
        }
    }
    
    handleRowSelection(row) {
        // Remove previous selection
        document.querySelectorAll('.table tbody tr').forEach(r => {
            r.classList.remove('selected');
        });
        
        // Add selection to current row
        row.classList.add('selected');
        
        // Store selected table ID
        const tableId = row.dataset.tableId;
        if (tableId) {
            this.selectedTableId = tableId;
        }
    }
    
    async showTableDetails(tableId) {
        try {
            performanceMonitor.start();
            
            const response = await fetch(`roomtable?action=getTableDetails&tableId=${tableId}`);
            const data = await response.json();
            
            if (data.error) {
                this.showNotification('Lỗi: ' + data.error, 'error');
                return;
            }
            
            const details = this.formatTableDetails(data);
            this.showModal('Chi tiết bàn', details);
            
            performanceMonitor.end('Table details load');
        } catch (error) {
            console.error('❌ Error loading table details:', error);
            this.showNotification('Có lỗi xảy ra khi lấy thông tin bàn', 'error');
        }
    }
    
    formatTableDetails(data) {
        let details = `
            <div class="table-details">
                <div class="detail-section">
                    <h4>📋 Thông tin cơ bản</h4>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <label>Số bàn:</label>
                            <span class="detail-value">${data.tableNumber}</span>
                        </div>
                        <div class="detail-item">
                            <label>Tên bàn:</label>
                            <span class="detail-value">${data.tableName}</span>
                        </div>
                        <div class="detail-item">
                            <label>Sức chứa:</label>
                            <span class="detail-value">${data.capacity} người</span>
                        </div>
                        <div class="detail-item">
                            <label>Phòng:</label>
                            <span class="detail-value">${data.room ? data.room.name : 'Không có phòng'}</span>
                        </div>
                        <div class="detail-item">
                            <label>Trạng thái:</label>
                            <span class="status ${data.status.toLowerCase()}">${this.getStatusText(data.status)}</span>
                        </div>
                        <div class="detail-item">
                            <label>Hoạt động:</label>
                            <span class="detail-value">${data.isActive ? '✅ Hoạt động' : '❌ Ngừng hoạt động'}</span>
                        </div>
                    </div>
                </div>
        `;
        
        if (data.activeSession) {
            details += `
                <div class="detail-section">
                    <h4>🔄 Phiên đang hoạt động</h4>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <label>Khách hàng:</label>
                            <span class="detail-value">${data.activeSession.customerName || 'Khách vãng lai'}</span>
                        </div>
                        <div class="detail-item">
                            <label>SĐT:</label>
                            <span class="detail-value">${data.activeSession.customerPhone || 'Không có'}</span>
                        </div>
                        <div class="detail-item">
                            <label>Thời gian vào:</label>
                            <span class="detail-value">${this.formatDate(data.activeSession.checkInTime)}</span>
                        </div>
                        <div class="detail-item">
                            <label>Tổng tiền:</label>
                            <span class="detail-value amount">${this.formatNumber(data.activeSession.totalAmount)} VNĐ</span>
                        </div>
                        <div class="detail-item">
                            <label>Thanh toán:</label>
                            <span class="payment-status ${data.activeSession.paymentStatus.toLowerCase()}">${this.getPaymentStatusText(data.activeSession.paymentStatus)}</span>
                        </div>
                    </div>
                </div>
            `;
        } else {
            details += `
                <div class="detail-section">
                    <h4>📊 Trạng thái</h4>
                    <p class="empty-state">Bàn đang trống</p>
                </div>
            `;
        }
        
        details += `</div>`;
        return details;
    }
    
    async showTableHistory(tableId) {
        try {
            performanceMonitor.start();
            
            const response = await fetch(`roomtable?action=getTableHistory&tableId=${tableId}`);
            const data = await response.json();
            
            if (data.error) {
                this.showNotification('Lỗi: ' + data.error, 'error');
                return;
            }
            
            const history = this.formatTableHistory(data);
            this.showModal('Lịch sử giao dịch', history);
            
            performanceMonitor.end('Table history load');
        } catch (error) {
            console.error('❌ Error loading table history:', error);
            this.showNotification('Có lỗi xảy ra khi lấy lịch sử bàn', 'error');
        }
    }
    
    formatTableHistory(data) {
        let history = `
            <div class="table-history">
                <div class="history-stats">
                    <div class="stat-item">
                        <span class="stat-number">${data.sessions ? data.sessions.length : 0}</span>
                        <span class="stat-label">Tổng phiên</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">${data.sessions ? this.formatNumber(data.sessions.reduce((sum, s) => sum + Number(s.totalAmount || 0), 0)) : '0'}</span>
                        <span class="stat-label">Tổng doanh thu (VNĐ)</span>
                    </div>
                </div>
        `;
        
        if (data.sessions && data.sessions.length > 0) {
            history += `
                <div class="history-table-container">
                    <table class="history-table">
                        <thead>
                            <tr>
                                <th>Khách hàng</th>
                                <th>SĐT</th>
                                <th>Vào</th>
                                <th>Ra</th>
                                <th>Trạng thái</th>
                                <th>Tổng tiền</th>
                                <th>Thanh toán</th>
                            </tr>
                        </thead>
                        <tbody>
            `;
            
            data.sessions.forEach(session => {
                history += `
                    <tr>
                        <td>${session.customerName || 'Khách vãng lai'}</td>
                        <td>${session.customerPhone || '-'}</td>
                        <td>${this.formatDate(session.checkInTime)}</td>
                        <td>${session.checkOutTime ? this.formatDate(session.checkOutTime) : 'Chưa ra'}</td>
                        <td><span class="status ${session.status.toLowerCase()}">${this.getStatusText(session.status)}</span></td>
                        <td class="amount">${this.formatNumber(session.totalAmount)} VNĐ</td>
                        <td><span class="payment-status ${session.paymentStatus.toLowerCase()}">${this.getPaymentStatusText(session.paymentStatus)}</span></td>
                    </tr>
                `;
            });
            
            history += `</tbody></table></div>`;
        } else {
            history += `<div class="empty-state"><p>Chưa có lịch sử giao dịch nào</p></div>`;
        }
        
        history += `</div>`;
        return history;
    }
    
    showModal(title, content) {
        // Remove existing modal
        const existingModal = document.getElementById('dynamicModal');
        if (existingModal) {
            existingModal.remove();
        }
        
        // Create modal with enhanced styling
        const modal = document.createElement('div');
        modal.id = 'dynamicModal';
        modal.className = 'modal enhanced-modal';
        modal.innerHTML = `
            <div class="modal-content enhanced-modal-content">
                <div class="modal-header">
                    <h2>${title}</h2>
                    <span class="close" onclick="roomTableManager.closeModal()">&times;</span>
                </div>
                <div class="modal-body enhanced-modal-body">
                    ${content}
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" onclick="roomTableManager.closeModal()">
                        ✅ Đóng
                    </button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        modal.style.display = 'block';
        
        // Add animation
        setTimeout(() => modal.classList.add('show'), 10);
    }
    
    closeModal() {
        const modal = document.getElementById('dynamicModal');
        if (modal) {
            modal.classList.remove('show');
            setTimeout(() => modal.remove(), 300);
        }
    }
    
    handleModalClose(event) {
        const modal = document.getElementById('dynamicModal');
        if (event.target === modal) {
            this.closeModal();
        }
    }
    
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (event) => {
            // ESC to close modal
            if (event.key === 'Escape') {
                this.closeModal();
            }
            
            // Ctrl+F to focus search
            if (event.ctrlKey && event.key === 'f') {
                event.preventDefault();
                const searchInput = document.getElementById('searchInput');
                if (searchInput) {
                    searchInput.focus();
                }
            }
        });
    }
    
    handleKeyboardNavigation(event) {
        const selectedRow = document.querySelector('.table tbody tr.selected');
        if (!selectedRow) return;
        
        const rows = Array.from(document.querySelectorAll('.table tbody tr:not([style*="display: none"])'));
        const currentIndex = rows.indexOf(selectedRow);
        
        switch (event.key) {
            case 'ArrowUp':
                event.preventDefault();
                if (currentIndex > 0) {
                    this.handleRowSelection(rows[currentIndex - 1]);
                }
                break;
            case 'ArrowDown':
                event.preventDefault();
                if (currentIndex < rows.length - 1) {
                    this.handleRowSelection(rows[currentIndex + 1]);
                }
                break;
            case 'Enter':
                event.preventDefault();
                if (this.selectedTableId) {
                    this.showTableDetails(this.selectedTableId);
                }
                break;
        }
    }
    
    startAutoRefresh() {
        // Auto refresh every 30 seconds
        setInterval(() => {
            if (document.visibilityState === 'visible') {
                this.refreshData();
            }
        }, 30000);
    }
    
    async refreshData() {
        try {
            // Clear cache
            tablesCache.clear();
            roomsCache.clear();
            
            // Reload data
            await this.loadTablesWithCache();
            await this.loadRoomsWithCache();
            
            console.log('🔄 Data refreshed');
        } catch (error) {
            console.error('❌ Error refreshing data:', error);
        }
    }
    
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.classList.add('show');
        }, 100);
        
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
    
    getStatusText(status) {
        const statusMap = {
            'Available': 'Trống',
            'Occupied': 'Đang sử dụng',
            'Reserved': 'Đã đặt',
            'Maintenance': 'Bảo trì'
        };
        return statusMap[status] || status;
    }
    
    getPaymentStatusText(status) {
        const statusMap = {
            'Paid': 'Đã thanh toán',
            'Unpaid': 'Chưa thanh toán',
            'Partial': 'Thanh toán một phần'
        };
        return statusMap[status] || status;
    }
    
    // Helper function to safely format dates
    formatDate(dateString) {
        if (!dateString) return 'N/A';
        try {
            const date = new Date(dateString);
            if (isNaN(date.getTime())) return 'N/A';
            return date.toLocaleString('vi-VN');
        } catch (error) {
            console.warn('Error formatting date:', error);
            return 'N/A';
        }
    }
    
    // Helper function to safely format numbers
    formatNumber(number) {
        if (!number || isNaN(number)) return '0';
        return Number(number).toLocaleString('vi-VN');
    }
    
    // Placeholder methods for future implementation
    showEditTableModal(tableId) {
        this.showNotification('Chức năng sửa bàn đang được phát triển', 'info');
    }
    
    showStatusChangeModal(tableId) {
        this.showNotification('Chức năng đổi trạng thái đang được phát triển', 'info');
    }
    
    confirmDeleteTable(tableId) {
        if (confirm('Bạn có chắc muốn xóa bàn này?')) {
            this.showNotification('Chức năng xóa bàn đang được phát triển', 'info');
        }
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.roomTableManager = new RoomTableManager();
});

// Export for global access
window.RoomTableManager = RoomTableManager;
