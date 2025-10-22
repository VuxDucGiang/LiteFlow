<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Đơn đặt hàng - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <script src="${pageContext.request.contextPath}/js/dropdown-simple.js"></script>
    
    <style>
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .page-title {
            font-size: 28px;
            font-weight: 700;
            color: #1f2937;
        }
        
        .btn-primary {
            background: #3b82f6;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary:hover {
            background: #2563eb;
        }
        
        .btn-success {
            background: #10b981;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-success:hover {
            background: #059669;
        }
        
        .btn-warning {
            background: #f59e0b;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            margin-right: 8px;
        }
        
        .btn-warning:hover {
            background: #d97706;
        }
        
        .btn-danger {
            background: #ef4444;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            margin-right: 8px;
        }
        
        .btn-danger:hover {
            background: #dc2626;
        }
        
        .btn-info {
            background: #6366f1;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            margin-right: 8px;
        }
        
        .btn-info:hover {
            background: #4f46e5;
        }
        
        .filters {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .search-box {
            position: relative;
            flex: 1;
            min-width: 300px;
        }
        
        .search-box input {
            width: 100%;
            padding: 12px 40px 12px 15px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .search-box input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        
        .search-box::after {
            content: '🔍';
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 16px;
        }
        
        .filter-select {
            padding: 12px 15px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            background: white;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .filter-select:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-left: 4px solid;
            transition: all 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.15);
        }
        
        .stat-card.pending { border-left-color: #f59e0b; }
        .stat-card.approved { border-left-color: #10b981; }
        .stat-card.rejected { border-left-color: #ef4444; }
        .stat-card.total { border-left-color: #3b82f6; }
        
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #6b7280;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .po-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .po-table th {
            background: #f8fafc;
            padding: 16px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .po-table td {
            padding: 16px;
            border-bottom: 1px solid #f3f4f6;
        }
        
        .po-table tr:hover {
            background: #f9fafb;
        }
        
        .po-table tr:last-child td {
            border-bottom: none;
        }
        
        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }
        
        .status-approved {
            background: #dcfce7;
            color: #166534;
        }
        
        .status-rejected {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .status-receiving {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .status-completed {
            background: #e5e7eb;
            color: #374151;
        }
        
        .amount {
            font-weight: bold;
            color: #10b981;
            font-size: 16px;
        }
        
        .po-id {
            font-family: 'Courier New', monospace;
            background: #f3f4f6;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .date-display {
            font-family: 'Courier New', monospace;
            font-size: 13px;
            color: #374151;
        }
        
        .debug-info {
            background: #eff6ff;
            padding: 20px;
            margin: 20px 0;
            border-radius: 12px;
            border-left: 4px solid #3b82f6;
        }
        
        .error-info {
            background: #fef2f2;
            padding: 20px;
            margin: 20px 0;
            border-radius: 12px;
            border-left: 4px solid #ef4444;
            color: #dc2626;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6b7280;
        }
        
        .empty-state h3 {
            font-size: 1.5em;
            margin-bottom: 10px;
            color: #374151;
        }
        
        .empty-state p {
            margin-bottom: 20px;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
        }
        
        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 0;
            border-radius: 15px;
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            animation: modalSlideIn 0.3s ease;
        }
        
        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .modal-header {
            background: #f8fafc;
            color: #1f2937;
            padding: 20px 30px;
            border-radius: 15px 15px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .modal-header h2 {
            margin: 0;
            font-size: 1.5em;
        }
        
        .close {
            color: #6b7280;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .close:hover {
            color: #ef4444;
            transform: scale(1.1);
        }
        
        .modal-body {
            padding: 30px;
        }
        
        .modal-footer {
            padding: 20px 30px;
            border-top: 1px solid #e5e7eb;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        /* Form Styles */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #374151;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
            box-sizing: border-box;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        
        .form-group.required label::after {
            content: ' *';
            color: #ef4444;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .form-row.full {
            grid-template-columns: 1fr;
        }
        
        .items-section {
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .items-section h4 {
            margin: 0 0 15px 0;
            color: #374151;
            font-size: 16px;
        }
        
        .item-row {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr auto;
            gap: 15px;
            align-items: end;
            margin-bottom: 15px;
            padding: 15px;
            background: #f9fafb;
            border-radius: 8px;
        }
        
        .item-row input {
            margin-bottom: 0;
        }
        
        .btn-remove-item {
            background: #ef4444;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 8px 12px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s ease;
        }
        
        .btn-remove-item:hover {
            background: #dc2626;
        }
        
        .btn-add-item {
            background: #10b981;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-add-item:hover {
            background: #059669;
        }
        
        .total-section {
            background: #f8fafc;
            padding: 20px;
            border-radius: 8px;
            border: 2px solid #e5e7eb;
            margin-bottom: 20px;
        }
        
        .total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 18px;
            font-weight: bold;
        }
        
        .total-amount {
            color: #10b981;
            font-size: 24px;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
        }
        
        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .item-row {
                grid-template-columns: 1fr;
                gap: 10px;
            }
            
            .form-actions {
                flex-direction: column;
            }
        }
        
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }
            
            .filters {
                flex-direction: column;
            }
            
            .search-box {
                min-width: auto;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .po-table {
                overflow-x: auto;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/includes/header.jsp">
        <jsp:param name="page" value="procurement"/>
    </jsp:include>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">📋 Quản lý Đơn đặt hàng</h1>
            <div>
                <button class="btn-success" onclick="openCreateModal()">
                    <i class='bx bx-plus'></i>
                    Tạo Đơn hàng
                </button>
                <button class="btn-primary" onclick="exportPOs()">
                    <i class='bx bx-download'></i>
                    Xuất báo cáo
                </button>
            </div>
        </div>


        <!-- Error Display -->
        <c:if test="${not empty error}">
            <div class="error-info">
                <h3>⚠️ Lỗi hệ thống</h3>
                <p>${error}</p>
                <a href="/LiteFlow/dashboard" class="btn-primary">Quay về Dashboard</a>
            </div>
        </c:if>

        <!-- Filters -->
        <div class="filters">
            <div class="search-box">
                <input type="text" id="searchInput" placeholder="Tìm kiếm đơn hàng, nhà cung cấp..." onkeyup="filterTable()">
            </div>
            <select class="filter-select" id="statusFilter" onchange="filterTable()">
                <option value="">Tất cả trạng thái</option>
                <option value="PENDING">Chờ duyệt</option>
                <option value="APPROVED">Đã duyệt</option>
                <option value="REJECTED">Từ chối</option>
                <option value="RECEIVING">Đang nhận hàng</option>
                <option value="COMPLETED">Hoàn thành</option>
            </select>
            <input type="date" class="filter-select" id="dateFilter" onchange="filterTable()">
        </div>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card pending">
                <div class="stat-number" id="pendingCount">0</div>
                <div class="stat-label">Chờ duyệt</div>
            </div>
            <div class="stat-card approved">
                <div class="stat-number" id="approvedCount">0</div>
                <div class="stat-label">Đã duyệt</div>
            </div>
            <div class="stat-card rejected">
                <div class="stat-number" id="rejectedCount">0</div>
                <div class="stat-label">Từ chối</div>
            </div>
            <div class="stat-card total">
                <div class="stat-number" id="totalCount">0</div>
                <div class="stat-label">Tổng đơn hàng</div>
            </div>
        </div>

        <!-- Purchase Orders Table -->
        <table class="po-table" id="poTable">
            <thead>
                <tr>
                    <th>Mã PO</th>
                    <th>Nhà cung cấp</th>
                    <th>Ngày tạo</th>
                    <th>Ngày giao dự kiến</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th>Người tạo</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty purchaseOrders}">
                        <tr>
                            <td colspan="8" class="empty-state">
                                <c:choose>
                                    <c:when test="${not empty error}">
                                        <h3>⚠️ Lỗi tải dữ liệu</h3>
                                        <p>${error}</p>
                                        <a href="/LiteFlow/dashboard" class="btn-primary">Quay về Dashboard</a>
                                    </c:when>
                                    <c:otherwise>
                                        <h3>📋 Chưa có đơn đặt hàng</h3>
                                        <p>Hãy tạo đơn hàng đầu tiên hoặc kiểm tra kết nối database.</p>
                                        <button class="btn-success" onclick="openCreateModal()">Tạo đơn hàng đầu tiên</button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="po" items="${purchaseOrders}">
                            <tr>
                                <td>
                                    <span class="po-id">PO-${po.poid.toString().substring(0,8)}</span>
                                </td>
                                <td>
                                    <c:forEach var="supplier" items="${suppliers}">
                                        <c:if test="${supplier.supplierID.toString() == po.supplierID.toString()}">
                                            ${supplier.name}
                                        </c:if>
                                    </c:forEach>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.createDate != null}">
                                            <span class="date-display" data-date="${po.createDate}">${po.createDate}</span>
                                        </c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.expectedDelivery != null}">
                                            <span class="date-display" data-date="${po.expectedDelivery}">${po.expectedDelivery}</span>
                                        </c:when>
                                        <c:otherwise>Chưa xác định</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="amount">
                                    <c:choose>
                                        <c:when test="${po.totalAmount != null}">
                                            ${po.totalAmount} ₫
                                        </c:when>
                                        <c:otherwise>0 ₫</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.status == 'PENDING'}">
                                            <span class="status-badge status-pending">Chờ duyệt</span>
                                        </c:when>
                                        <c:when test="${po.status == 'APPROVED'}">
                                            <span class="status-badge status-approved">Đã duyệt</span>
                                        </c:when>
                                        <c:when test="${po.status == 'REJECTED'}">
                                            <span class="status-badge status-rejected">Từ chối</span>
                                        </c:when>
                                        <c:when test="${po.status == 'RECEIVING'}">
                                            <span class="status-badge status-receiving">Đang nhận hàng</span>
                                        </c:when>
                                        <c:when test="${po.status == 'COMPLETED'}">
                                            <span class="status-badge status-completed">Hoàn thành</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-pending">${po.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    ${po.createdBy != null ? po.createdBy.toString().substring(0,8) : 'N/A'}
                                </td>
                                <td>
                                    <div style="display: flex; gap: 5px; flex-wrap: wrap;">
                                        <c:if test="${po.status == 'PENDING'}">
                                            <button class="btn-success" onclick="approvePO('${po.poid}')">Duyệt</button>
                                            <button class="btn-danger" onclick="rejectPO('${po.poid}')">Từ chối</button>
                                        </c:if>
                                        <c:if test="${po.status == 'APPROVED'}">
                                            <button class="btn-info" onclick="receiveGoods('${po.poid}')">Nhận hàng</button>
                                        </c:if>
                                        <button class="btn-warning" onclick="viewDetails('${po.poid}')">Chi tiết</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Create PO Modal -->
    <div id="createModal" class="modal">
        <div class="modal-content" style="max-width: 1000px;">
            <div class="modal-header">
                <h2>📋 Tạo Đơn đặt hàng mới</h2>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="createPOForm" action="${pageContext.request.contextPath}/procurement/po" method="post">
                    <input type="hidden" name="action" value="create">
                    
                    <!-- Basic Information -->
                    <div class="form-row">
                        <div class="form-group required">
                            <label for="supplierSelect">Nhà cung cấp</label>
                            <select id="supplierSelect" name="supplierID" required>
                                <option value="">Chọn nhà cung cấp</option>
                                <c:forEach var="supplier" items="${suppliers}">
                                    <option value="${supplier.supplierID}">${supplier.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group required">
                            <label for="expectedDelivery">Ngày giao dự kiến</label>
                            <input type="datetime-local" id="expectedDelivery" name="expectedDelivery" required>
                        </div>
                    </div>
                    
                    <div class="form-row full">
                        <div class="form-group">
                            <label for="notes">Ghi chú</label>
                            <textarea id="notes" name="notes" rows="3" placeholder="Nhập ghi chú cho đơn hàng..."></textarea>
                        </div>
                    </div>
                    
                    <!-- Items Section -->
                    <div class="items-section">
                        <h4>📦 Chi tiết sản phẩm</h4>
                        <div id="itemsContainer">
                            <div class="item-row">
                                <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                                <input type="number" name="quantity" placeholder="Số lượng" min="1" required>
                                <input type="number" name="unitPrice" placeholder="Đơn giá (₫)" min="0" step="1000" required>
                                <input type="text" name="total" placeholder="Thành tiền" readonly>
                                <button type="button" class="btn-remove-item" onclick="removeItem(this)" style="display: none;">🗑️</button>
                            </div>
                        </div>
                        <button type="button" class="btn-add-item" onclick="addItem()">
                            ➕ Thêm sản phẩm
                        </button>
                    </div>
                    
                    <!-- Total Section -->
                    <div class="total-section">
                        <div class="total-row">
                            <span>Tổng tiền:</span>
                            <span id="totalAmount" class="total-amount">0 ₫</span>
                        </div>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="form-actions">
                        <button type="button" class="btn-primary" onclick="closeModal()">Hủy</button>
                        <button type="submit" class="btn-success">✅ Tạo đơn hàng</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Statistics calculation
        function updateStatistics() {
            const rows = document.querySelectorAll('#poTable tbody tr');
            let pending = 0, approved = 0, rejected = 0, total = 0;
            
            rows.forEach(row => {
                if (row.cells.length > 1) { // Skip empty state row
                    total++;
                    const statusCell = row.cells[5];
                    if (statusCell) {
                        const statusText = statusCell.textContent.trim();
                        if (statusText.includes('Chờ duyệt')) pending++;
                        else if (statusText.includes('Đã duyệt')) approved++;
                        else if (statusText.includes('Từ chối')) rejected++;
                    }
                }
            });
            
            document.getElementById('pendingCount').textContent = pending;
            document.getElementById('approvedCount').textContent = approved;
            document.getElementById('rejectedCount').textContent = rejected;
            document.getElementById('totalCount').textContent = total;
        }

        // Filter table
        function filterTable() {
            const statusFilter = document.getElementById('statusFilter').value;
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const dateFilter = document.getElementById('dateFilter').value;
            const table = document.getElementById('poTable');
            const rows = table.getElementsByTagName('tr');

            for (let i = 1; i < rows.length; i++) {
                const row = rows[i];
                if (row.cells.length <= 1) continue; // Skip empty state row
                
                const statusCell = row.cells[5];
                const supplierCell = row.cells[1];
                const dateCell = row.cells[2];
                
                let show = true;

                if (statusFilter) {
                    const statusText = statusCell.textContent.trim();
                    if (!statusText.includes(statusFilter)) {
                        show = false;
                    }
                }

                if (searchInput) {
                    const rowText = row.textContent.toLowerCase();
                    if (!rowText.includes(searchInput)) {
                        show = false;
                    }
                }

                if (dateFilter && dateCell.textContent.trim() !== dateFilter) {
                    show = false;
                }

                row.style.display = show ? '' : 'none';
            }
            
            updateStatistics();
        }

        // Action functions
        function approvePO(poId) {
            if (confirm('Bạn có chắc chắn muốn duyệt đơn hàng này?')) {
                alert('✅ Đã duyệt đơn hàng: ' + poId);
                // TODO: Implement approve functionality
            }
        }

        function rejectPO(poId) {
            const reason = prompt('Lý do từ chối:');
            if (reason && reason.trim() !== '') {
                alert('❌ Đã từ chối đơn hàng: ' + poId + '\nLý do: ' + reason);
                // TODO: Implement reject functionality
            }
        }

        function receiveGoods(poId) {
            alert('📦 Nhận hàng cho đơn: ' + poId);
            // TODO: Implement receive goods functionality
        }

        function viewDetails(poId) {
            alert('👁️ Xem chi tiết đơn hàng: ' + poId);
            // TODO: Implement view details functionality
        }

        function openCreateModal() {
            document.getElementById('createModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('createModal').style.display = 'none';
        }

        function exportPOs() {
            alert('📊 Xuất báo cáo đơn hàng');
            // TODO: Implement export functionality
        }

        // Form management functions
        function addItem() {
            const container = document.getElementById('itemsContainer');
            const newRow = document.createElement('div');
            newRow.className = 'item-row';
            newRow.innerHTML = `
                <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                <input type="number" name="quantity" placeholder="Số lượng" min="1" required onchange="calculateItemTotal(this)">
                <input type="number" name="unitPrice" placeholder="Đơn giá (₫)" min="0" step="1000" required onchange="calculateItemTotal(this)">
                <input type="text" name="total" placeholder="Thành tiền" readonly>
                <button type="button" class="btn-remove-item" onclick="removeItem(this)">🗑️</button>
            `;
            container.appendChild(newRow);
            updateRemoveButtons();
        }

        function removeItem(button) {
            const container = document.getElementById('itemsContainer');
            if (container.children.length > 1) {
                button.parentElement.remove();
                updateRemoveButtons();
                calculateTotal();
            }
        }

        function updateRemoveButtons() {
            const container = document.getElementById('itemsContainer');
            const removeButtons = container.querySelectorAll('.btn-remove-item');
            
            removeButtons.forEach((button, index) => {
                if (container.children.length === 1) {
                    button.style.display = 'none';
                } else {
                    button.style.display = 'block';
                }
            });
        }

        function calculateItemTotal(input) {
            const row = input.parentElement;
            const quantity = row.querySelector('input[name="quantity"]').value;
            const unitPrice = row.querySelector('input[name="unitPrice"]').value;
            const totalInput = row.querySelector('input[name="total"]');
            
            if (quantity && unitPrice) {
                const total = parseInt(quantity) * parseInt(unitPrice);
                totalInput.value = total.toLocaleString('vi-VN') + ' ₫';
                calculateTotal();
            } else {
                totalInput.value = '';
                calculateTotal();
            }
        }

        function calculateTotal() {
            const totalInputs = document.querySelectorAll('input[name="total"]');
            let total = 0;
            
            totalInputs.forEach(input => {
                const value = input.value.replace(/[^\d]/g, '');
                if (value) {
                    total += parseInt(value);
                }
            });
            
            document.getElementById('totalAmount').textContent = total.toLocaleString('vi-VN') + ' ₫';
        }

        function resetForm() {
            document.getElementById('createPOForm').reset();
            const container = document.getElementById('itemsContainer');
            container.innerHTML = `
                <div class="item-row">
                    <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                    <input type="number" name="quantity" placeholder="Số lượng" min="1" required onchange="calculateItemTotal(this)">
                    <input type="number" name="unitPrice" placeholder="Đơn giá (₫)" min="0" step="1000" required onchange="calculateItemTotal(this)">
                    <input type="text" name="total" placeholder="Thành tiền" readonly>
                    <button type="button" class="btn-remove-item" onclick="removeItem(this)" style="display: none;">🗑️</button>
                </div>
            `;
            calculateTotal();
        }

        function closeModal() {
            document.getElementById('createModal').style.display = 'none';
            resetForm();
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('createModal');
            if (event.target === modal) {
                closeModal();
            }
        }

        // Format date function
        function formatDate(dateString) {
            if (!dateString || dateString === 'null' || dateString === 'N/A') {
                return 'N/A';
            }
            
            try {
                const date = new Date(dateString);
                if (isNaN(date.getTime())) {
                    return dateString; // Return original if can't parse
                }
                
                return date.toLocaleDateString('vi-VN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch (e) {
                console.warn('Date formatting error:', e, 'for date:', dateString);
                return dateString; // Return original if error
            }
        }

        // Format all dates on page load
        function formatAllDates() {
            const dateElements = document.querySelectorAll('.date-display');
            dateElements.forEach(element => {
                const originalDate = element.getAttribute('data-date');
                if (originalDate) {
                    const formattedDate = formatDate(originalDate);
                    element.textContent = formattedDate;
                }
            });
        }

        // Initialize on page load
        window.onload = function() {
            formatAllDates();
            updateStatistics();
            updateRemoveButtons();
            calculateTotal();
            
            // Set default date to tomorrow
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const dateString = tomorrow.toISOString().slice(0, 16);
            document.getElementById('expectedDelivery').value = dateString;
            
            console.log('Purchase Orders:', ${purchaseOrders != null ? purchaseOrders.size() : 0});
            console.log('Suppliers:', ${suppliers != null ? suppliers.size() : 0});
        };
    </script>
</body>
</html>