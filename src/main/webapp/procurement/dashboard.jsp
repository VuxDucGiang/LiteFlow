<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Mua sắm - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        .header {
            margin-bottom: 30px;
        }
        .header h1 {
            color: #2c3e50;
            margin: 0 0 10px 0;
        }
        .header p {
            color: #6c757d;
            margin: 0;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid #3498db;
        }
        .stat-card.success {
            border-left-color: #27ae60;
        }
        .stat-card.warning {
            border-left-color: #f39c12;
        }
        .stat-card.danger {
            border-left-color: #e74c3c;
        }
        .stat-card.info {
            border-left-color: #17a2b8;
        }
        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .stat-title {
            font-size: 14px;
            color: #6c757d;
            font-weight: 500;
        }
        .stat-icon {
            font-size: 24px;
            color: #3498db;
        }
        .stat-value {
            font-size: 28px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        .stat-change {
            font-size: 12px;
            color: #27ae60;
        }
        .stat-change.negative {
            color: #e74c3c;
        }
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .action-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.2s;
            cursor: pointer;
        }
        .action-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        .action-icon {
            font-size: 32px;
            margin-bottom: 10px;
            color: #3498db;
        }
        .action-title {
            font-size: 16px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        .action-desc {
            font-size: 12px;
            color: #6c757d;
        }
        .recent-activities {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e9ecef;
        }
        .activity-item {
            display: flex;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #f8f9fa;
        }
        .activity-item:last-child {
            border-bottom: none;
        }
        .activity-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #e3f2fd;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            color: #1976d2;
        }
        .activity-content {
            flex: 1;
        }
        .activity-text {
            font-size: 14px;
            color: #2c3e50;
            margin-bottom: 2px;
        }
        .activity-time {
            font-size: 12px;
            color: #6c757d;
        }
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .alert-warning {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
        }
        .alert-info {
            background-color: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
        }
    </style>
</head>
<body>
    <jsp:include page="../includes/header.jsp">
        <jsp:param name="page" value="procurement" />
    </jsp:include>
    
    <div class="container">
        <div class="header">
            <h1>📦 Dashboard Mua sắm</h1>
            <p>Tổng quan về hoạt động mua sắm và quản lý nhà cung cấp</p>
        </div>

        <!-- Alerts -->
        <div class="alert alert-warning">
            <strong>⚠️ Cảnh báo:</strong> Có 2 đơn hàng sắp đến hạn giao và 1 đơn hàng đã trễ hạn.
        </div>

        <div class="alert alert-info">
            <strong>ℹ️ Thông tin:</strong> Có 3 hóa đơn chờ đối chiếu từ nhà cung cấp.
        </div>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card success">
                <div class="stat-header">
                    <div class="stat-title">Tổng Nhà cung cấp</div>
                    <div class="stat-icon">🏢</div>
                </div>
                <div class="stat-value">5</div>
                <div class="stat-change">+2 tháng này</div>
            </div>
            
            <div class="stat-card warning">
                <div class="stat-header">
                    <div class="stat-title">Đơn hàng chờ duyệt</div>
                    <div class="stat-icon">⏳</div>
                </div>
                <div class="stat-value">3</div>
                <div class="stat-change">Cần xử lý ngay</div>
            </div>
            
            <div class="stat-card info">
                <div class="stat-header">
                    <div class="stat-title">Đơn hàng đang giao</div>
                    <div class="stat-icon">🚚</div>
                </div>
                <div class="stat-value">4</div>
                <div class="stat-change">Theo dõi tiến độ</div>
            </div>
            
            <div class="stat-card danger">
                <div class="stat-header">
                    <div class="stat-title">Đơn hàng trễ hạn</div>
                    <div class="stat-icon">⚠️</div>
                </div>
                <div class="stat-value">1</div>
                <div class="stat-change negative">Cần liên hệ NCC</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <div class="action-card" onclick="window.location.href='${pageContext.request.contextPath}/procurement/supplier'">
                <div class="action-icon">🏢</div>
                <div class="action-title">Quản lý Nhà cung cấp</div>
                <div class="action-desc">Thêm, sửa, xem thông tin NCC</div>
            </div>
            
            <div class="action-card" onclick="window.location.href='${pageContext.request.contextPath}/procurement/po'">
                <div class="action-icon">📋</div>
                <div class="action-title">Tạo Đơn đặt hàng</div>
                <div class="action-desc">Lập đơn hàng mới từ NCC</div>
            </div>
            
            <div class="action-card" onclick="window.location.href='${pageContext.request.contextPath}/procurement/gr'">
                <div class="action-icon">📦</div>
                <div class="action-title">Nhận hàng</div>
                <div class="action-desc">Xác nhận nhận hàng từ NCC</div>
            </div>
            
            <div class="action-card" onclick="window.location.href='${pageContext.request.contextPath}/procurement/invoice'">
                <div class="action-icon">📦</div>
                <div class="action-title">Hóa đơn Nhập hàng</div>
                <div class="action-desc">Đối chiếu hóa đơn từ NCC</div>
            </div>
            
            <div class="action-card" onclick="window.location.href='${pageContext.request.contextPath}/sales/invoice'">
                <div class="action-icon">🧾</div>
                <div class="action-title">Hoá đơn Bán hàng</div>
                <div class="action-desc">Quản lý hóa đơn bán cho khách</div>
            </div>
        </div>

        <!-- Recent Activities -->
        <div class="recent-activities">
            <div class="section-title">Hoạt động gần đây</div>
            
            <div class="activity-item">
                <div class="activity-icon">📋</div>
                <div class="activity-content">
                    <div class="activity-text">Đơn hàng PO-12345678 đã được duyệt bởi Manager</div>
                    <div class="activity-time">2 giờ trước</div>
                </div>
            </div>
            
            <div class="activity-item">
                <div class="activity-icon">📦</div>
                <div class="activity-content">
                    <div class="activity-text">Đã nhận hàng từ Công ty Cà phê Trung Nguyên</div>
                    <div class="activity-time">4 giờ trước</div>
                </div>
            </div>
            
            <div class="activity-item">
                <div class="activity-icon">🧾</div>
                <div class="activity-content">
                    <div class="activity-text">Hóa đơn INV-87654321 đã được đối chiếu thành công</div>
                    <div class="activity-time">1 ngày trước</div>
                </div>
            </div>
            
            <div class="activity-item">
                <div class="activity-icon">🏢</div>
                <div class="activity-content">
                    <div class="activity-text">Thêm nhà cung cấp mới: Nguyên liệu pha chế ABC</div>
                    <div class="activity-time">2 ngày trước</div>
                </div>
            </div>
            
            <div class="activity-item">
                <div class="activity-icon">⚠️</div>
                <div class="activity-content">
                    <div class="activity-text">Cảnh báo: Đơn hàng PO-11111111 trễ hạn 3 ngày</div>
                    <div class="activity-time">3 ngày trước</div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Auto refresh stats every 5 minutes
        setInterval(function() {
            // TODO: Implement AJAX call to refresh stats
            console.log('Refreshing procurement stats...');
        }, 300000);

        // Add click handlers for quick actions
        document.querySelectorAll('.action-card').forEach(card => {
            card.addEventListener('click', function() {
                // Add visual feedback
                this.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    this.style.transform = '';
                }, 150);
            });
        });
    </script>
</body>
</html>






