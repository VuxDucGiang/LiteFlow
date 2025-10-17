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
    
    <!-- CRITICAL: JavaScript functions defined in HEAD to ensure availability -->
    <script>
        // Global variables
        let currentPOData = null;
        let allPOs = [];
        let allSuppliers = [];

        // CRITICAL: viewDetails function defined FIRST in HEAD
        function viewDetails(poId) {
            console.log('=== viewDetails called from HEAD ===');
            console.log('PO ID:', poId);
            console.log('allPOs length:', allPOs.length);
            
            // Find PO data
            const poData = allPOs.find(po => po.poid === poId);
            console.log('Found PO data:', poData);
            
            if (!poData) {
                console.error('PO data not found for ID:', poId);
                alert('Không tìm thấy thông tin đơn hàng: ' + poId);
                return;
            }

            console.log('Setting currentPOData and calling showPODetailsModal...');
            currentPOData = poData;
            showPODetailsModal(poData);
        }

        // CRITICAL: Immediate global assignment
        window.viewDetails = viewDetails;

        // Data initialization function
        function initializeData() {
            console.log('Initializing data from HEAD...');
            
            allPOs = [
                <c:forEach var="po" items="${purchaseOrders}" varStatus="status">
                {
                    poid: '${po.poid}',
                    supplierID: '${po.supplierID}',
                    createdBy: '${po.createdBy}',
                    createDate: '${po.createDate}',
                    expectedDelivery: '${po.expectedDelivery}',
                    totalAmount: ${po.totalAmount},
                    status: '${po.status}',
                    approvalLevel: ${po.approvalLevel},
                    approvedBy: '${po.approvedBy}',
                    approvedAt: '${po.approvedAt}',
                    notes: '${po.notes}'
                }<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];

            allSuppliers = [
                <c:forEach var="supplier" items="${suppliers}" varStatus="status">
                {
                    supplierID: '${supplier.supplierID}',
                    name: '${supplier.name}'
                }<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];
            
            console.log('Data initialized from HEAD:', {
                posCount: allPOs.length,
                suppliersCount: allSuppliers.length,
                samplePO: allPOs[0],
                sampleSupplier: allSuppliers[0]
            });
        }

        // Modal functions
        function showPODetailsModal(poData) {
            console.log('=== showPODetailsModal called ===');
            console.log('PO Data:', poData);
            
            try {
                // Find supplier name
                const supplier = allSuppliers.find(s => s.supplierID === poData.supplierID);
                const supplierName = supplier ? supplier.name : 'Không tìm thấy';
                console.log('Supplier found:', supplier, 'Name:', supplierName);

                // Populate basic information
                console.log('Populating basic information...');
                document.getElementById('detailPOId').textContent = poData.poid.substring(0, 8) + '...';
                document.getElementById('detailSupplier').textContent = supplierName;
                document.getElementById('detailCreatedBy').textContent = poData.createdBy ? poData.createdBy.substring(0, 8) + '...' : 'Chưa cập nhật';
                document.getElementById('detailCreateDate').textContent = formatDate(poData.createDate);
                document.getElementById('detailExpectedDelivery').textContent = formatDate(poData.expectedDelivery);
                document.getElementById('detailNotes').textContent = poData.notes || 'Không có ghi chú';

                // Status with badge
                console.log('Setting status badge...');
                const statusElement = document.getElementById('detailStatus');
                statusElement.innerHTML = generateStatusBadge(poData.status);

                // Approval information
                console.log('Setting approval information...');
                document.getElementById('detailApprovedBy').textContent = poData.approvedBy ? poData.approvedBy.substring(0, 8) + '...' : 'Chưa duyệt';
                document.getElementById('detailApprovedAt').textContent = formatDate(poData.approvedAt);
                document.getElementById('detailApprovalLevel').textContent = poData.approvalLevel || 'Chưa duyệt';

                // Show approval section if needed
                if (poData.status === 'APPROVED' || poData.status === 'REJECTED') {
                    document.getElementById('approvalSection').style.display = 'block';
                } else {
                    document.getElementById('approvalSection').style.display = 'none';
                }

                // Populate items table (mock data for now)
                console.log('Populating items table...');
                populateItemsTable();

                // Total amount
                console.log('Setting total amount...');
                document.getElementById('detailTotalAmount').textContent = formatCurrency(poData.totalAmount);

                // Show modal
                console.log('Showing modal...');
                const modal = document.getElementById('poDetailsModal');
                console.log('Modal element:', modal);
                modal.style.display = 'flex';
                console.log('Modal display set to flex');
                
            } catch (error) {
                console.error('Error in showPODetailsModal:', error);
                alert('Lỗi khi hiển thị chi tiết: ' + error.message);
            }
        }

        function populateItemsTable() {
            const tbody = document.getElementById('detailItemsTable');
            tbody.innerHTML = '';

            // Mock items data - in real implementation, this would come from the server
            const mockItems = [
                { name: 'Sản phẩm A', quantity: 10, unitPrice: 100000, total: 1000000 },
                { name: 'Sản phẩm B', quantity: 5, unitPrice: 200000, total: 1000000 },
                { name: 'Sản phẩm C', quantity: 3, unitPrice: 500000, total: 1500000 }
            ];

            mockItems.forEach(item => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${item.name}</td>
                    <td>${item.quantity}</td>
                    <td>${formatCurrency(item.unitPrice)}</td>
                    <td>${formatCurrency(item.total)}</td>
                `;
                tbody.appendChild(row);
            });
        }

        function closePODetailsModal() {
            document.getElementById('poDetailsModal').style.display = 'none';
            currentPOData = null;
        }

        function formatDate(dateString) {
            if (!dateString || dateString === 'null') return 'Chưa cập nhật';
            try {
                const date = new Date(dateString);
                return date.toLocaleDateString('vi-VN') + ' ' + date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
            } catch (e) {
                return 'Chưa cập nhật';
            }
        }

        function formatCurrency(amount) {
            if (!amount) return '0 VND';
            return new Intl.NumberFormat('vi-VN', { 
                style: 'currency', 
                currency: 'VND' 
            }).format(amount);
        }

        function generateStatusBadge(status) {
            const badges = {
                'PENDING': '<span class="status-badge status-pending">Chờ duyệt</span>',
                'APPROVED': '<span class="status-badge status-approved">Đã duyệt</span>',
                'REJECTED': '<span class="status-badge status-rejected">Từ chối</span>',
                'RECEIVING': '<span class="status-badge status-receiving">Đang nhận hàng</span>',
                'COMPLETED': '<span class="status-badge status-completed">Hoàn thành</span>'
            };
            return badges[status] || '<span class="status-badge">' + status + '</span>';
        }

        // Test function for debugging
        function testViewDetails() {
            console.log('=== Testing viewDetails Function from HEAD ===');
            console.log('viewDetails function type:', typeof viewDetails);
            console.log('window.viewDetails function type:', typeof window.viewDetails);
            
            if (allPOs.length > 0) {
                const testPOId = allPOs[0].poid;
                console.log('Testing with first PO ID:', testPOId);
                viewDetails(testPOId);
            } else {
                alert('Không có dữ liệu PO để test');
            }
        }

        // CRITICAL: Make all functions globally accessible from HEAD
        window.viewDetails = viewDetails;
        window.closePODetailsModal = closePODetailsModal;
        window.showPODetailsModal = showPODetailsModal;
        window.testViewDetails = testViewDetails;
        window.initializeData = initializeData;

        console.log('=== HEAD SCRIPT LOADED ===');
        console.log('viewDetails function available:', typeof viewDetails);
        console.log('window.viewDetails available:', typeof window.viewDetails);
    </script>
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
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e0e0e0;
        }
        .header h1 {
            color: #2c3e50;
            margin: 0;
        }
        .btn {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            margin-left: 10px;
        }
        .btn:hover {
            background: #2980b9;
        }
        .btn-success {
            background: #27ae60;
        }
        .btn-success:hover {
            background: #229954;
        }
        .btn-warning {
            background: #f39c12;
        }
        .btn-warning:hover {
            background: #e67e22;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 999999;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 800px;
            max-height: 85vh;
            overflow-y: auto;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
            margin-top: 8vh;
        }

        .po-details-modal {
            max-width: 900px;
            width: 95%;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #e5e7eb;
            background: #f8fafc;
            border-radius: 12px 12px 0 0;
        }

        .modal-header h2 {
            margin: 0;
            color: #1f2937;
            font-size: 24px;
        }

        .close {
            color: #6b7280;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            line-height: 1;
        }

        .close:hover {
            color: #374151;
        }

        .modal-body {
            padding: 20px;
            max-height: 60vh;
            overflow-y: auto;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            padding: 20px;
            border-top: 1px solid #e5e7eb;
            background: #f8fafc;
            border-radius: 0 0 12px 12px;
        }

        /* PO Details Styles */
        .po-details {
            padding: 0;
        }

        .detail-section {
            margin-bottom: 32px;
            padding-bottom: 24px;
            border-bottom: 1px solid #e5e7eb;
        }

        .detail-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .detail-section h3 {
            margin: 0 0 16px 0;
            font-size: 18px;
            font-weight: 600;
            color: #1f2937;
            padding-bottom: 8px;
            border-bottom: 2px solid #3b82f6;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .detail-item.full-width {
            grid-column: 1 / -1;
        }

        .detail-item label {
            font-weight: 600;
            color: #374151;
            font-size: 14px;
        }

        .detail-item span {
            color: #6b7280;
            font-size: 14px;
            padding: 8px 12px;
            background: #f9fafb;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
            min-height: 20px;
        }

        .detail-item span:empty::before {
            content: "Chưa cập nhật";
            color: #9ca3af;
            font-style: italic;
        }

        /* Items Table */
        .items-table-container {
            overflow-x: auto;
            margin-bottom: 20px;
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .items-table th {
            background: #f8fafc;
            color: #374151;
            font-weight: 600;
            padding: 12px;
            text-align: left;
            border-bottom: 2px solid #e5e7eb;
        }

        .items-table td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            color: #6b7280;
        }

        .items-table tr:hover {
            background: #f9fafb;
        }

        .items-table tr:last-child td {
            border-bottom: none;
        }

        /* Total Section */
        .total-section {
            background: #f8fafc;
            padding: 16px;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .total-row label {
            font-weight: 600;
            color: #374151;
            font-size: 16px;
        }

        .total-amount {
            font-weight: 700;
            color: #059669;
            font-size: 18px;
        }

        /* Status badges */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
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
        .btn-danger {
            background: #e74c3c;
        }
        .btn-danger:hover {
            background: #c0392b;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .table th, .table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        .table th {
            background-color: #34495e;
            color: white;
            font-weight: 600;
        }
        .table tr:hover {
            background-color: #f8f9fa;
        }
        .status-pending {
            background: #f39c12;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        .status-approved {
            background: #27ae60;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        .status-rejected {
            background: #e74c3c;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        .status-receiving {
            background: #3498db;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        .status-completed {
            background: #2c3e50;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        .amount {
            font-weight: bold;
            color: #27ae60;
        }
        .overdue {
            background-color: #ffebee;
            color: #c62828;
        }
        .filters {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            align-items: center;
        }
        .filters select, .filters input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
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
        }
        .modal-content {
            background-color: white;
            margin: 2% auto;
            padding: 20px;
            border-radius: 8px;
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            overflow-y: auto;
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: black;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .item-row {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
            align-items: end;
        }
        .item-row input {
            flex: 1;
        }
        .item-row button {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <!-- Simple header for testing -->
    <div style="background: #007bff; color: white; padding: 10px; margin-bottom: 20px;">
        <h1 style="margin: 0;">📋 Quản lý Đơn đặt hàng - LiteFlow</h1>
    </div>
    
    <div class="container">
        <div class="header">
            <h1>📋 Quản lý Đơn đặt hàng</h1>
            <div>
                <button class="btn btn-success" onclick="openCreateModal()">+ Tạo Đơn hàng</button>
                <button class="btn" onclick="exportPOs()">📊 Xuất báo cáo</button>
            </div>
        </div>

        <div class="filters">
            <select id="statusFilter" onchange="filterTable()">
                <option value="">Tất cả trạng thái</option>
                <option value="PENDING">Chờ duyệt</option>
                <option value="APPROVED">Đã duyệt</option>
                <option value="REJECTED">Từ chối</option>
                <option value="RECEIVING">Đang nhận hàng</option>
                <option value="COMPLETED">Hoàn thành</option>
            </select>
            <input type="text" id="searchInput" placeholder="Tìm kiếm đơn hàng..." onkeyup="filterTable()">
            <input type="date" id="dateFilter" onchange="filterTable()">
        </div>

        <!-- Debug info -->
        <div style="background: #f0f0f0; padding: 10px; margin: 10px 0; border-radius: 5px;">
            <strong>Debug Info:</strong>
            <br>Purchase Orders: ${purchaseOrders != null ? purchaseOrders.size() : 'null'}
            <br>Suppliers: ${suppliers != null ? suppliers.size() : 'null'}
            <c:if test="${not empty error}">
                <br><span style="color: red;">Error: ${error}</span>
            </c:if>
        </div>

        <table class="table" id="poTable">
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
                <!-- Debug info -->
                <c:if test="${empty purchaseOrders}">
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 20px; color: #666;">
                            <c:choose>
                                <c:when test="${not empty error}">
                                    <div style="color: red;">⚠️ ${error}</div>
                                </c:when>
                                <c:otherwise>
                                    📋 Chưa có đơn đặt hàng nào. 
                                    <br><small>Hãy tạo đơn hàng đầu tiên hoặc kiểm tra kết nối database.</small>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:if>
                
                <c:forEach var="po" items="${purchaseOrders}">
                    <tr>
                        <td><strong>PO-${po.poid.toString().substring(0,8)}</strong></td>
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
                                    ${po.createDate}
                                </c:when>
                                <c:otherwise>N/A</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${po.expectedDelivery != null}">
                                    ${po.expectedDelivery}
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
                                    <span class="status-pending">Chờ duyệt</span>
                                </c:when>
                                <c:when test="${po.status == 'APPROVED'}">
                                    <span class="status-approved">Đã duyệt</span>
                                </c:when>
                                <c:when test="${po.status == 'REJECTED'}">
                                    <span class="status-rejected">Từ chối</span>
                                </c:when>
                                <c:when test="${po.status == 'RECEIVING'}">
                                    <span class="status-receiving">Đang nhận hàng</span>
                                </c:when>
                                <c:when test="${po.status == 'COMPLETED'}">
                                    <span class="status-completed">Hoàn thành</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-pending">${po.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            ${po.createdBy != null ? po.createdBy.toString().substring(0,8) : 'N/A'}
                        </td>
                        <td>
                            <c:if test="${po.status == 'PENDING'}">
                                <button class="btn btn-success" onclick="approvePO('${po.poid}')">Duyệt</button>
                                <button class="btn btn-danger" onclick="rejectPO('${po.poid}')">Từ chối</button>
                            </c:if>
                            <c:if test="${po.status == 'APPROVED'}">
                                <button class="btn" onclick="receiveGoods('${po.poid}')">Nhận hàng</button>
                            </c:if>
                            <button class="btn btn-warning" onclick="viewDetails('${po.poid}')">Chi tiết</button>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Modal tạo đơn hàng -->
    <div id="createModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Tạo Đơn đặt hàng</h2>
            <form id="createPOForm" action="${pageContext.request.contextPath}/procurement/po" method="post">
                <input type="hidden" name="action" value="create">
                
                <div class="form-group">
                    <label for="supplierSelect">Nhà cung cấp *</label>
                    <select id="supplierSelect" name="supplierID" required>
                        <option value="">Chọn nhà cung cấp</option>
                        <c:forEach var="supplier" items="${suppliers}">
                            <option value="${supplier.supplierID}">${supplier.name}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="expectedDelivery">Ngày giao dự kiến *</label>
                    <input type="datetime-local" id="expectedDelivery" name="expected" required>
                </div>
                
                <div class="form-group">
                    <label for="notes">Ghi chú</label>
                    <textarea id="notes" name="notes" rows="3"></textarea>
                </div>
                
                <div class="form-group">
                    <label>Chi tiết sản phẩm</label>
                    <div id="itemsContainer">
                        <div class="item-row">
                            <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                            <input type="number" name="qty" placeholder="Số lượng" min="1" required>
                            <input type="number" name="price" placeholder="Đơn giá" min="0" step="0.01" required>
                            <button type="button" onclick="removeItem(this)" style="display: none;">Xóa</button>
                        </div>
                    </div>
                    <button type="button" class="btn" onclick="addItem()">+ Thêm sản phẩm</button>
                </div>
                
                <div style="text-align: right; margin-top: 20px;">
                    <button type="button" class="btn" onclick="closeModal()">Hủy</button>
                    <button type="submit" class="btn btn-success">Tạo đơn hàng</button>
                </div>
            </form>
        </div>
    </div>

    <!-- PO Details Modal -->
    <div id="poDetailsModal" class="modal" style="display: none;">
        <div class="modal-content po-details-modal">
            <div class="modal-header">
                <h2>Chi tiết đơn đặt hàng</h2>
                <span class="close" onclick="closePODetailsModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="po-details">
                    <!-- Basic Information -->
                    <div class="detail-section">
                        <h3>Thông tin cơ bản</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <label>Mã đơn hàng:</label>
                                <span id="detailPOId">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Nhà cung cấp:</label>
                                <span id="detailSupplier">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Người tạo:</label>
                                <span id="detailCreatedBy">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Ngày tạo:</label>
                                <span id="detailCreateDate">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Ngày giao dự kiến:</label>
                                <span id="detailExpectedDelivery">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Trạng thái:</label>
                                <span id="detailStatus">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Người duyệt:</label>
                                <span id="detailApprovedBy">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Ngày duyệt:</label>
                                <span id="detailApprovedAt">-</span>
                            </div>
                            <div class="detail-item full-width">
                                <label>Ghi chú:</label>
                                <span id="detailNotes">-</span>
                            </div>
                        </div>
                    </div>

                    <!-- Order Items -->
                    <div class="detail-section">
                        <h3>Chi tiết sản phẩm</h3>
                        <div class="items-table-container">
                            <table class="items-table">
                                <thead>
                                    <tr>
                                        <th>Tên sản phẩm</th>
                                        <th>Số lượng</th>
                                        <th>Đơn giá</th>
                                        <th>Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody id="detailItemsTable">
                                    <!-- Items will be populated here -->
                                </tbody>
                            </table>
                        </div>
                        <div class="total-section">
                            <div class="total-row">
                                <label>Tổng tiền:</label>
                                <span id="detailTotalAmount" class="total-amount">-</span>
                            </div>
                        </div>
                    </div>

                    <!-- Approval Information -->
                    <div class="detail-section" id="approvalSection" style="display: none;">
                        <h3>Thông tin duyệt</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <label>Cấp duyệt:</label>
                                <span id="detailApprovalLevel">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Lý do từ chối:</label>
                                <span id="detailRejectionReason">-</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closePODetailsModal()">Đóng</button>
                <button type="button" class="btn btn-primary" id="actionButton" onclick="handlePODetailsAction()" style="display: none;">Thực hiện</button>
            </div>
        </div>
    </div>

    <!-- Body script for DOM manipulation -->
    <script>
        // DOM Ready initialization - functions already defined in HEAD
        document.addEventListener('DOMContentLoaded', function() {
            console.log('=== DOM CONTENT LOADED - INITIALIZING FROM BODY ===');
            console.log('viewDetails function available:', typeof viewDetails);
            console.log('window.viewDetails available:', typeof window.viewDetails);
            
            // Initialize data
            initializeData();
            
            // Test if modal element exists
            const modal = document.getElementById('poDetailsModal');
            console.log('Modal element found:', modal);
            
            // Test function availability
            console.log('Testing function availability...');
            if (typeof viewDetails === 'function') {
                console.log('✅ viewDetails function is available');
            } else {
                console.error('❌ viewDetails function is NOT available');
            }
            
            if (typeof window.viewDetails === 'function') {
                console.log('✅ window.viewDetails function is available');
            } else {
                console.error('❌ window.viewDetails function is NOT available');
            }
        });

        // Additional functions for modal management
        function openCreateModal() {
            document.getElementById('createModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('createModal').style.display = 'none';
        }

        function addItem() {
            const container = document.getElementById('itemsContainer');
            const newRow = document.createElement('div');
            newRow.className = 'item-row';
            newRow.innerHTML = `
                <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                <input type="number" name="quantity" placeholder="Số lượng" min="1" required>
                <input type="number" name="unitPrice" placeholder="Đơn giá" min="0" step="0.01" required>
                <button type="button" onclick="removeItem(this)" class="btn btn-danger">Xóa</button>
            `;
            container.appendChild(newRow);
        }

        function removeItem(button) {
            button.parentElement.remove();
        }

        function approvePO(poId) {
            if (confirm('Bạn có chắc chắn muốn duyệt đơn hàng này?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/procurement/po';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'approve';
                
                const poidInput = document.createElement('input');
                poidInput.type = 'hidden';
                poidInput.name = 'poid';
                poidInput.value = poId;
                
                const levelInput = document.createElement('input');
                levelInput.type = 'hidden';
                levelInput.name = 'level';
                levelInput.value = '1'; // Default approval level
                
                form.appendChild(actionInput);
                form.appendChild(poidInput);
                form.appendChild(levelInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        function rejectPO(poId) {
            const reason = prompt('Lý do từ chối:');
            if (reason && reason.trim() !== '') {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/procurement/po';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'reject';
                
                const poidInput = document.createElement('input');
                poidInput.type = 'hidden';
                poidInput.name = 'poid';
                poidInput.value = poId;
                
                const reasonInput = document.createElement('input');
                reasonInput.type = 'hidden';
                reasonInput.name = 'reason';
                reasonInput.value = reason.trim();
                
                form.appendChild(actionInput);
                form.appendChild(poidInput);
                form.appendChild(reasonInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        function receiveGoods(poId) {
            window.location.href = '${pageContext.request.contextPath}/procurement/gr?poid=' + poId;
        }

        function filterTable() {
            const statusFilter = document.getElementById('statusFilter').value;
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const dateFilter = document.getElementById('dateFilter').value;
            const table = document.getElementById('poTable');
            const rows = table.getElementsByTagName('tr');

            for (let i = 1; i < rows.length; i++) {
                const row = rows[i];
                const statusCell = row.cells[4];
                const supplierCell = row.cells[1];
                const dateCell = row.cells[2];
                
                let show = true;

                if (statusFilter && statusCell.textContent.trim() !== statusFilter) {
                    show = false;
                }

                if (searchInput && !supplierCell.textContent.toLowerCase().includes(searchInput)) {
                    show = false;
                }

                if (dateFilter && dateCell.textContent.trim() !== dateFilter) {
                    show = false;
                }

                row.style.display = show ? '' : 'none';
            }
        }

        function exportPOs() {
            alert('Xuất báo cáo đơn hàng');
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const createModal = document.getElementById('createModal');
            const poDetailsModal = document.getElementById('poDetailsModal');
            
            if (event.target === createModal) {
                closeModal();
            } else if (event.target === poDetailsModal) {
                closePODetailsModal();
            }
        }
    </script>
</body>
</html>
