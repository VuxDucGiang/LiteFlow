/**
 * Dashboard Revenue Data Loader
 * Fetches and displays revenue data from API
 */

class DashboardRevenue {
  constructor() {
    this.currentTab = 'hour'; // Default to hourly view
    this.revenueData = null;
    this.init();
  }

  init() {
    this.setupTabListeners();
    this.loadRevenueData();
  }

  setupTabListeners() {
    const tabs = document.querySelectorAll('.revenue-tabs .tab');
    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        // Remove active from all tabs
        tabs.forEach(t => t.classList.remove('active'));
        
        // Add active to clicked tab
        tab.classList.add('active');
        
        // Update current tab
        this.currentTab = tab.dataset.tab || 'hour';
        
        // Render table for selected tab
        this.renderTable();
      });
    });
  }

  async loadRevenueData() {
    try {
      // Get date range (last 30 days)
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 30);
      
      const startDateStr = this.formatDate(startDate);
      const endDateStr = this.formatDate(endDate);
      
      // Get context path from page (set by JSP)
      const contextPath = window.CONTEXT_PATH || '';
      const baseUrl = contextPath.endsWith('/') ? contextPath.slice(0, -1) : contextPath;
      
      // Fetch data from API
      const url = `${baseUrl}/report/revenue?action=api&startDate=${startDateStr}&endDate=${endDateStr}`;
      
      console.log('📊 Loading revenue data from:', url);
      
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      console.log('✅ Revenue data loaded:', data);
      
      this.revenueData = data;
      this.renderTable();
      
    } catch (error) {
      console.error('❌ Error loading revenue data:', error);
      this.showError('Không thể tải dữ liệu doanh thu');
    }
  }

  formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  renderTable() {
    if (!this.revenueData) {
      return;
    }

    const tbody = document.getElementById('revenueTableBody');
    if (!tbody) return;

    let rows = [];

    switch (this.currentTab) {
      case 'day':
        rows = this.renderDailyTable();
        break;
      case 'hour':
        rows = this.renderHourlyTable();
        break;
      case 'weekday':
        rows = this.renderWeekdayTable();
        break;
      default:
        rows = this.renderHourlyTable();
    }

    tbody.innerHTML = rows.join('');
    
    // Add animation
    const tableRows = tbody.querySelectorAll('tr');
    tableRows.forEach((row, index) => {
      row.style.animationDelay = `${index * 0.05}s`;
      row.classList.add('fade-in');
    });
  }

  renderDailyTable() {
    if (!this.revenueData.trendData) {
      return ['<tr><td colspan="3" class="empty-text">Không có dữ liệu</td></tr>'];
    }

    const dates = this.revenueData.trendData.dates || [];
    const revenues = this.revenueData.trendData.revenues || [];
    const orders = this.revenueData.trendData.orders || [];

    if (dates.length === 0) {
      return ['<tr><td colspan="3" class="empty-text">Không có dữ liệu</td></tr>'];
    }

    // Show last 7 days
    const startIndex = Math.max(0, dates.length - 7);
    const rows = [];

    for (let i = startIndex; i < dates.length; i++) {
      const date = dates[i];
      const revenue = revenues[i] || 0;
      const orderCount = orders[i] || 0;

      rows.push(`
        <tr>
          <td>${date}</td>
          <td class="revenue-amount">${this.formatCurrency(revenue)}</td>
          <td>${this.formatNumber(orderCount)}</td>
        </tr>
      `);
    }

    return rows;
  }

  renderHourlyTable() {
    if (!this.revenueData.hourlyData) {
      return ['<tr><td colspan="3" class="empty-text">Không có dữ liệu</td></tr>'];
    }

    const hours = this.revenueData.hourlyData.hours || [];
    const revenues = this.revenueData.hourlyData.revenues || [];

    if (hours.length === 0) {
      return ['<tr><td colspan="3" class="empty-text">Không có dữ liệu</td></tr>'];
    }

    const rows = [];

    for (let i = 0; i < hours.length; i++) {
      const hour = hours[i];
      const revenue = revenues[i] || 0;

      rows.push(`
        <tr>
          <td>${hour}</td>
          <td class="revenue-amount">${this.formatCurrency(revenue)}</td>
          <td>-</td>
        </tr>
      `);
    }

    return rows;
  }

  renderWeekdayTable() {
    if (!this.revenueData.weekdayData) {
      return ['<tr><td colspan="3" class="empty-text">Không có dữ liệu</td></tr>'];
    }

    const weekdayNames = this.revenueData.weekdayData.weekdayNames || [];
    const revenues = this.revenueData.weekdayData.revenues || [];
    const orders = this.revenueData.weekdayData.orders || [];

    if (weekdayNames.length === 0) {
      return ['<tr><td colspan="3" class="empty-text">Không có dữ liệu</td></tr>'];
    }

    const rows = [];

    for (let i = 0; i < weekdayNames.length; i++) {
      const weekdayName = weekdayNames[i];
      const revenue = revenues[i] || 0;
      const orderCount = orders[i] || 0;

      rows.push(`
        <tr>
          <td>${weekdayName}</td>
          <td class="revenue-amount">${this.formatCurrency(revenue)}</td>
          <td>${this.formatNumber(orderCount)}</td>
        </tr>
      `);
    }

    return rows;
  }

  formatCurrency(amount) {
    if (amount === 0 || !amount) return '0 ₫';
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  }

  formatNumber(num) {
    if (num === 0 || !num) return '0';
    return new Intl.NumberFormat('vi-VN').format(num);
  }

  showError(message) {
    const tbody = document.getElementById('revenueTableBody');
    if (tbody) {
      tbody.innerHTML = `<tr><td colspan="3" class="error-text">${message}</td></tr>`;
    }
  }

  refresh() {
    this.loadRevenueData();
  }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    window.dashboardRevenue = new DashboardRevenue();
  });
} else {
  window.dashboardRevenue = new DashboardRevenue();
}

// Export for global access
window.DashboardRevenue = DashboardRevenue;

