<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Include Header -->
<jsp:include page="/includes/header.jsp">
    <jsp:param name="page" value="report" />
</jsp:include>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<style>
        /* Design System */
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --success-gradient: linear-gradient(135deg, #4caf50 0%, #388e3c 100%);
            --warning-gradient: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
            --danger-gradient: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            --info-gradient: linear-gradient(135deg, #2196f3 0%, #1976d2 100%);
            
            --card-shadow: 0 10px 30px rgba(0,0,0,0.1);
            --card-hover-shadow: 0 15px 40px rgba(0,0,0,0.15);
            
            --text-primary: #1f2937;
            --text-secondary: #6b7280;
            --border-color: #e5e7eb;
        }
        
        /* Override body styling for report page */
        .content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: calc(100vh - 120px);
            padding: 20px;
        }
        
        .container {
            max-width: 1600px;
            margin: 0 auto;
        }
        
        /* Header */
        .page-header {
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 30px;
            border-radius: 20px;
            margin-bottom: 30px;
            box-shadow: var(--card-shadow);
            border: 2px solid rgba(255,255,255,0.3);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .page-header h1 {
            font-size: 2.5em;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .header-actions {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .date-range-picker {
            display: flex;
            gap: 10px;
            align-items: center;
            background: white;
            padding: 10px 15px;
            border-radius: 12px;
            border: 2px solid var(--border-color);
        }
        
        .date-range-picker input {
            padding: 8px 12px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 0.95em;
        }
        
        .date-range-picker input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        /* Statistics Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 25px;
            border-radius: 15px;
            box-shadow: var(--card-shadow);
            border: 2px solid rgba(255,255,255,0.3);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--card-hover-shadow);
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
        }
        
        .stat-card.revenue::before {
            background: var(--primary-gradient);
        }
        
        .stat-card.orders::before {
            background: var(--success-gradient);
        }
        
        .stat-card.avg::before {
            background: var(--info-gradient);
        }
        
        .stat-card.growth::before {
            background: var(--warning-gradient);
        }
        
        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .stat-icon {
            font-size: 2.5em;
            opacity: 0.2;
        }
        
        .stat-label {
            color: var(--text-secondary);
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
            margin-bottom: 8px;
        }
        
        .stat-value {
            font-size: 2.2em;
            font-weight: bold;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
        }
        
        .stat-change {
            font-size: 0.85em;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .stat-change.positive {
            color: #4caf50;
        }
        
        .stat-change.negative {
            color: #dc3545;
        }
        
        /* Charts */
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .chart-card {
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 25px;
            border-radius: 15px;
            box-shadow: var(--card-shadow);
            border: 2px solid rgba(255,255,255,0.3);
        }
        
        .chart-card.full-width {
            grid-column: 1 / -1;
        }
        
        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }
        
        .chart-title {
            font-size: 1.3em;
            font-weight: 600;
            color: var(--text-primary);
        }
        
        .chart-container {
            position: relative;
            height: 350px;
        }
        
        /* Table */
        .table-card {
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 25px;
            border-radius: 15px;
            box-shadow: var(--card-shadow);
            border: 2px solid rgba(255,255,255,0.3);
            margin-bottom: 30px;
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }
        
        .table-title {
            font-size: 1.3em;
            font-weight: 600;
            color: var(--text-primary);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.85em;
            letter-spacing: 0.5px;
        }
        
        tbody tr {
            border-bottom: 1px solid var(--border-color);
            transition: all 0.3s ease;
        }
        
        tbody tr:hover {
            background: rgba(102, 126, 234, 0.05);
            transform: scale(1.01);
        }
        
        td {
            padding: 15px;
            color: var(--text-primary);
        }
        
        .rank-badge {
            display: inline-block;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            text-align: center;
            line-height: 30px;
            font-weight: bold;
            color: white;
        }
        
        .rank-1 { background: linear-gradient(135deg, #ffd700, #ffed4e); color: #333; }
        .rank-2 { background: linear-gradient(135deg, #c0c0c0, #e8e8e8); color: #333; }
        .rank-3 { background: linear-gradient(135deg, #cd7f32, #e0a878); color: white; }
        .rank-other { background: linear-gradient(135deg, #9e9e9e, #bdbdbd); color: white; }
        
        /* Buttons */
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            font-size: 0.95em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: white;
        }
        
        .btn-primary {
            background: var(--primary-gradient);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
        }
        
        .btn-success {
            background: var(--success-gradient);
            box-shadow: 0 4px 15px rgba(76, 175, 80, 0.4);
        }
        
        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(76, 175, 80, 0.6);
        }
        
        /* Loading */
        .loading {
            text-align: center;
            padding: 40px;
            color: white;
        }
        
        .loading-spinner {
            display: inline-block;
            width: 40px;
            height: 40px;
            border: 4px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        /* Responsive */
        @media (max-width: 1200px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .header-actions {
                width: 100%;
                flex-direction: column;
            }
            
            .date-range-picker {
                width: 100%;
                flex-direction: column;
            }
        }
</style>

<div class="container">
        <!-- Header -->
        <div class="page-header">
            <h1>
                📊 Báo cáo Doanh thu
            </h1>
            <div class="header-actions">
                <div class="date-range-picker">
                    <label>Từ:</label>
                    <input type="date" id="startDate" value="${startDate}">
                    <label>Đến:</label>
                    <input type="date" id="endDate" value="${endDate}">
                    <button class="btn btn-primary" onclick="applyDateRange()">
                        🔍 Xem
                    </button>
                </div>
                <button class="btn btn-success" onclick="exportReport()">
                    📥 Xuất Excel
                </button>
            </div>
        </div>
        
        <!-- Statistics Cards -->
        <div class="stats-grid">
            <div class="stat-card revenue">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Tổng Doanh Thu</div>
                        <div class="stat-value" id="stat-revenue">125,750,000 ₫</div>
                        <div class="stat-change positive">
                            ↑ <span id="stat-revenue-change">+15.5%</span> so với kỳ trước
                        </div>
                    </div>
                    <div class="stat-icon">💰</div>
                </div>
            </div>
            
            <div class="stat-card orders">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Số Đơn Hàng</div>
                        <div class="stat-value" id="stat-orders">485</div>
                        <div class="stat-change positive">
                            ↑ <span id="stat-orders-change">+12.3%</span> so với kỳ trước
                        </div>
                    </div>
                    <div class="stat-icon">🛒</div>
                </div>
            </div>
            
            <div class="stat-card avg">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Giá Trị TB/Đơn</div>
                        <div class="stat-value" id="stat-avg">259,278 ₫</div>
                        <div class="stat-change positive">
                            ↑ <span id="stat-avg-change">+8.7%</span> so với kỳ trước
                        </div>
                    </div>
                    <div class="stat-icon">📈</div>
                </div>
            </div>
            
            <div class="stat-card growth">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Khách Hàng Mới</div>
                        <div class="stat-value" id="stat-customers">87</div>
                        <div class="stat-change positive">
                            ↑ <span id="stat-customers-change">+23.4%</span> so với kỳ trước
                        </div>
                    </div>
                    <div class="stat-icon">👥</div>
                </div>
            </div>
        </div>
        
        <!-- Charts -->
        <div class="charts-grid">
            <!-- Revenue Trend Chart -->
            <div class="chart-card full-width">
                <div class="chart-header">
                    <div class="chart-title">📈 Xu hướng Doanh thu theo Ngày</div>
                </div>
                <div class="chart-container">
                    <canvas id="revenueTrendChart"></canvas>
                </div>
            </div>
            
            <!-- Product Category Chart -->
            <div class="chart-card">
                <div class="chart-header">
                    <div class="chart-title">🍰 Doanh thu theo Danh mục</div>
                </div>
                <div class="chart-container">
                    <canvas id="productCategoryChart"></canvas>
                </div>
            </div>
            
            <!-- Hourly Revenue Chart -->
            <div class="chart-card">
                <div class="chart-header">
                    <div class="chart-title">⏰ Doanh thu theo Giờ</div>
                </div>
                <div class="chart-container">
                    <canvas id="hourlyRevenueChart"></canvas>
                </div>
            </div>
        </div>
        
        <!-- Top Products Table -->
        <div class="table-card">
            <div class="table-header">
                <div class="table-title">🏆 Top 10 Sản phẩm Bán chạy</div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Xếp hạng</th>
                        <th>Sản phẩm</th>
                        <th>Số lượng</th>
                        <th>Đơn giá</th>
                        <th>Doanh thu</th>
                        <th>% Tổng DT</th>
                    </tr>
                </thead>
                <tbody id="topProductsTable">
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px;">
                            <div class="loading-spinner"></div>
                            <p>Đang tải dữ liệu...</p>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
</div>

<script>
    let reportData = null;
        let charts = {};
        
        // Load report data on page load
        window.onload = function() {
            loadReportData();
        };
        
        // Load report data from servlet
        function loadReportData() {
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;
            
            fetch('${pageContext.request.contextPath}/report/revenue?action=api&startDate=' + startDate + '&endDate=' + endDate)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        reportData = data;
                        renderDashboard(data);
                    } else {
                        alert('Lỗi tải dữ liệu: ' + data.error);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi kết nối: ' + error.message);
                });
        }
        
        // Render dashboard with data
        function renderDashboard(data) {
            // Update statistics
            updateStatistics(data);
            
            // Render charts
            renderRevenueTrendChart(data.trendData);
            renderProductCategoryChart(data.productData);
            renderHourlyRevenueChart(data.hourlyData);
            
            // Render top products table
            renderTopProductsTable(data.topProducts);
        }
        
        // Update statistics cards
        function updateStatistics(data) {
            document.getElementById('stat-revenue').textContent = 
                formatCurrency(data.totalRevenue);
            document.getElementById('stat-orders').textContent = 
                formatNumber(data.totalOrders);
            document.getElementById('stat-avg').textContent = 
                formatCurrency(data.avgOrderValue);
            document.getElementById('stat-customers').textContent = 
                formatNumber(data.newCustomers || 87);
        }
        
        // Render revenue trend chart
        function renderRevenueTrendChart(trendData) {
            const ctx = document.getElementById('revenueTrendChart');
            
            if (charts.trend) {
                charts.trend.destroy();
            }
            
            charts.trend = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: trendData.dates,
                    datasets: [{
                        label: 'Doanh thu (VNĐ)',
                        data: trendData.revenues,
                        borderColor: 'rgba(102, 126, 234, 1)',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 4,
                        pointHoverRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return formatCurrency(context.parsed.y);
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return formatCurrency(value, true);
                                }
                            }
                        }
                    }
                }
            });
        }
        
        // Render product category chart
        function renderProductCategoryChart(productData) {
            const ctx = document.getElementById('productCategoryChart');
            
            if (charts.category) {
                charts.category.destroy();
            }
            
            charts.category = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: productData.categories,
                    datasets: [{
                        data: productData.revenues,
                        backgroundColor: productData.colors,
                        borderWidth: 2,
                        borderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right'
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = ((context.parsed / total) * 100).toFixed(1);
                                    return context.label + ': ' + formatCurrency(context.parsed) + ' (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });
        }
        
        // Render hourly revenue chart
        function renderHourlyRevenueChart(hourlyData) {
            const ctx = document.getElementById('hourlyRevenueChart');
            
            if (charts.hourly) {
                charts.hourly.destroy();
            }
            
            charts.hourly = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: hourlyData.hours,
                    datasets: [{
                        label: 'Doanh thu (VNĐ)',
                        data: hourlyData.revenues,
                        backgroundColor: 'rgba(118, 75, 162, 0.8)',
                        borderColor: 'rgba(118, 75, 162, 1)',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return formatCurrency(context.parsed.y);
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return formatCurrency(value, true);
                                }
                            }
                        }
                    }
                }
            });
        }
        
        // Render top products table
        function renderTopProductsTable(products) {
            const tbody = document.getElementById('topProductsTable');
            tbody.innerHTML = '';
            
            products.forEach((product, index) => {
                const row = document.createElement('tr');
                
                let rankClass = 'rank-other';
                if (index === 0) rankClass = 'rank-1';
                else if (index === 1) rankClass = 'rank-2';
                else if (index === 2) rankClass = 'rank-3';
                
                row.innerHTML = '<td><span class="rank-badge ' + rankClass + '">' + (index + 1) + '</span></td>' +
                    '<td><strong>' + product.name + '</strong></td>' +
                    '<td>' + formatNumber(product.quantity) + '</td>' +
                    '<td>' + formatCurrency(product.price) + '</td>' +
                    '<td><strong>' + formatCurrency(product.revenue) + '</strong></td>' +
                    '<td>' + product.share + '</td>';
                
                tbody.appendChild(row);
            });
        }
        
        // Apply date range filter
        function applyDateRange() {
            loadReportData();
        }
        
        // Export report to Excel
        function exportReport() {
            alert('Tính năng xuất Excel đang được phát triển...');
        }
        
        // Format currency
        function formatCurrency(value, short = false) {
            if (short && value >= 1000000) {
                return (value / 1000000).toFixed(1) + 'M ₫';
            }
            return new Intl.NumberFormat('vi-VN').format(value) + ' ₫';
        }
        
        // Format number
        function formatNumber(value) {
            return new Intl.NumberFormat('vi-VN').format(value);
        }
</script>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

