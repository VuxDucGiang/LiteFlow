<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Nhà cung cấp</title>
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
        
        .supplier-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .supplier-table th {
            background: #f8fafc;
            padding: 16px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .supplier-table td {
            padding: 16px;
            border-bottom: 1px solid #f3f4f6;
        }
        
        .supplier-table tr:hover {
            background: #f9fafb;
        }
        
        .btn-edit, .btn-details {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            margin-right: 8px;
        }
        
        .btn-edit {
            background: #10b981;
            color: white;
        }
        
        .btn-edit:hover {
            background: #059669;
        }
        
        .btn-details {
            background: #6366f1;
            color: white;
        }
        
        .btn-details:hover {
            background: #4f46e5;
        }
        
        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-active {
            background: #dcfce7;
            color: #166534;
        }
        
        .status-inactive {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6b7280;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 16px;
            color: #d1d5db;
        }
    </style>
</head>
<body>
    <jsp:include page="/includes/header.jsp">
        <jsp:param name="page" value="procurement"/>
    </jsp:include>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Quản lý Nhà cung cấp</h1>
            <button class="btn-primary" onclick="openAddModal()">
                <i class='bx bx-plus'></i>
                Thêm nhà cung cấp
            </button>
        </div>

        <c:choose>
            <c:when test="${suppliers != null && suppliers.size() > 0}">
                <table class="supplier-table">
                    <thead>
                        <tr>
                            <th>Tên nhà cung cấp</th>
                            <th>Người liên hệ</th>
                            <th>Email</th>
                            <th>Số điện thoại</th>
                            <th>Đánh giá</th>
                            <th>Tỷ lệ đúng hẹn</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="supplier" items="${suppliers}">
                            <tr>
                                <td>
                                    <strong>${supplier.name != null ? supplier.name : 'Chưa cập nhật'}</strong>
                                </td>
                                <td>${supplier.contact != null ? supplier.contact : 'Chưa cập nhật'}</td>
                                <td>${supplier.email != null ? supplier.email : 'Chưa cập nhật'}</td>
                                <td>${supplier.phone != null ? supplier.phone : 'Chưa cập nhật'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${supplier.rating != null && supplier.rating > 0}">
                                            ${supplier.rating}/5
                                        </c:when>
                                        <c:otherwise>
                                            Chưa đánh giá
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${supplier.onTimeRate != null && supplier.onTimeRate > 0}">
                                            ${supplier.onTimeRate}%
                                        </c:when>
                                        <c:otherwise>
                                            Chưa có dữ liệu
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="status-badge ${supplier.isActive ? 'status-active' : 'status-inactive'}">
                                        ${supplier.isActive ? 'Hoạt động' : 'Không hoạt động'}
                                    </span>
                                </td>
                                <td>
                                    <button class="btn-edit" onclick="editSupplier('${supplier.supplierID}')">
                                        <i class='bx bx-edit'></i>
                                        Sửa
                                    </button>
                                    <button class="btn-details" onclick="viewDetails('${supplier.supplierID}')">
                                        <i class='bx bx-show'></i>
                                        Chi tiết
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class='bx bx-store'></i>
                    <h3>Chưa có nhà cung cấp nào</h3>
                    <p>Hãy thêm nhà cung cấp đầu tiên để bắt đầu quản lý</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Edit Modal -->
    <div id="editModal" class="modal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Sửa nhà cung cấp</h2>
                <span class="close" onclick="closeEditModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="editForm">
                    <div class="form-group">
                        <label for="editName">Tên nhà cung cấp *</label>
                        <input type="text" id="editName" name="name" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editContact">Người liên hệ</label>
                        <input type="text" id="editContact" name="contact">
                    </div>
                    
                    <div class="form-group">
                        <label for="editEmail">Email</label>
                        <input type="email" id="editEmail" name="email">
                    </div>
                    
                    <div class="form-group">
                        <label for="editPhone">Số điện thoại</label>
                        <input type="tel" id="editPhone" name="phone">
                    </div>
                    
                    <div class="form-group">
                        <label for="editAddress">Địa chỉ</label>
                        <textarea id="editAddress" name="address" rows="3"></textarea>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="editRating">Đánh giá (1-5)</label>
                            <input type="number" id="editRating" name="rating" min="0" max="5" step="0.1">
                        </div>
                        
                        <div class="form-group">
                            <label for="editOnTimeRate">Tỷ lệ đúng hẹn (%)</label>
                            <input type="number" id="editOnTimeRate" name="onTimeRate" min="0" max="100" step="0.1">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="checkbox" id="editIsActive" name="isActive">
                            Hoạt động
                        </label>
                    </div>
                    
                    <input type="hidden" id="editSupplierId" name="supplierId">
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Hủy</button>
                <button type="button" class="btn btn-primary" onclick="saveSupplier()">Lưu thay đổi</button>
            </div>
        </div>
    </div>

    <!-- Details Modal -->
    <div id="detailsModal" class="modal" style="display: none;">
        <div class="modal-content details-modal">
            <div class="modal-header">
                <h2>Chi tiết nhà cung cấp</h2>
                <span class="close" onclick="closeDetailsModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="supplier-details">
                    <div class="detail-section">
                        <h3>Thông tin cơ bản</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <label>Tên nhà cung cấp:</label>
                                <span id="detailName">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Người liên hệ:</label>
                                <span id="detailContact">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Email:</label>
                                <span id="detailEmail">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Số điện thoại:</label>
                                <span id="detailPhone">-</span>
                            </div>
                            <div class="detail-item full-width">
                                <label>Địa chỉ:</label>
                                <span id="detailAddress">-</span>
                            </div>
                        </div>
                    </div>

                    <div class="detail-section">
                        <h3>Đánh giá & Hiệu suất</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <label>Đánh giá:</label>
                                <span id="detailRating">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Tỷ lệ đúng hẹn:</label>
                                <span id="detailOnTimeRate">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Trạng thái:</label>
                                <span id="detailStatus">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Ngày tạo:</label>
                                <span id="detailCreatedAt">-</span>
                            </div>
                        </div>
                    </div>

                    <div class="detail-section">
                        <h3>Thống kê đơn hàng</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <label>Tổng đơn hàng:</label>
                                <span id="detailTotalOrders">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Đơn hàng thành công:</label>
                                <span id="detailSuccessfulOrders">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Đơn hàng trễ:</label>
                                <span id="detailLateOrders">-</span>
                            </div>
                            <div class="detail-item">
                                <label>Giá trị trung bình:</label>
                                <span id="detailAvgOrderValue">-</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeDetailsModal()">Đóng</button>
                <button type="button" class="btn btn-primary" onclick="editFromDetails()">Chỉnh sửa</button>
            </div>
        </div>
    </div>

    <!-- Add Supplier Modal -->
    <div id="addModal" class="modal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Thêm nhà cung cấp mới</h2>
                <span class="close" onclick="closeAddModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="addForm">
                    <div class="form-group">
                        <label for="addName">Tên nhà cung cấp *</label>
                        <input type="text" id="addName" name="name" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="addContact">Người liên hệ</label>
                        <input type="text" id="addContact" name="contact">
                    </div>
                    
                    <div class="form-group">
                        <label for="addEmail">Email *</label>
                        <input type="email" id="addEmail" name="email" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="addPhone">Số điện thoại</label>
                        <input type="tel" id="addPhone" name="phone">
                    </div>
                    
                    <div class="form-group">
                        <label for="addAddress">Địa chỉ</label>
                        <textarea id="addAddress" name="address" rows="3"></textarea>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="addRating">Đánh giá ban đầu (1-5)</label>
                            <input type="number" id="addRating" name="rating" min="0" max="5" step="0.1" value="0">
                        </div>
                        
                        <div class="form-group">
                            <label for="addOnTimeRate">Tỷ lệ đúng hẹn (%)</label>
                            <input type="number" id="addOnTimeRate" name="onTimeRate" min="0" max="100" step="0.1" value="0">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="checkbox" id="addIsActive" name="isActive" checked>
                            Hoạt động
                        </label>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeAddModal()">Hủy</button>
                <button type="button" class="btn btn-primary" onclick="saveNewSupplier()">Thêm nhà cung cấp</button>
            </div>
        </div>
    </div>

    <style>
        .modal {
            position: fixed !important;
            z-index: 999999 !important;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 600px;
            max-height: 80vh;
            z-index: 1000000 !important;
            overflow-y: auto;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
            margin-top: 12vh;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 24px;
            border-bottom: 1px solid #e5e7eb;
        }

        .modal-header h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 600;
            color: #1f2937;
        }

        .close {
            font-size: 24px;
            font-weight: bold;
            color: #6b7280;
            cursor: pointer;
            line-height: 1;
        }

        .close:hover {
            color: #374151;
        }

        .modal-body {
            padding: 24px;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 20px 24px;
            border-top: 1px solid #e5e7eb;
            background: #f9fafb;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 500;
            color: #374151;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-primary {
            background: #3b82f6;
            color: white;
        }

        .btn-primary:hover {
            background: #2563eb;
        }

        .btn-secondary {
            background: #6b7280;
            color: white;
        }

        .btn-secondary:hover {
            background: #4b5563;
        }

        .loading {
            opacity: 0.7;
            pointer-events: none;
        }

        /* Details Modal Specific Styles */
        .details-modal {
            max-width: 800px;
            width: 95%;
            max-height: 75vh;
            margin-top: 10vh;
        }

        .supplier-details {
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

        /* Status badges */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-active {
            background: #dcfce7;
            color: #166534;
        }

        .status-inactive {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Rating stars */
        .rating-stars {
            display: flex;
            gap: 2px;
        }

        .star {
            color: #fbbf24;
            font-size: 16px;
        }

        .star.empty {
            color: #d1d5db;
        }

        /* Force modal to be above everything */
        #editModal, #detailsModal, #addModal {
            z-index: 999999 !important;
            position: fixed !important;
        }
        
        #editModal .modal-content, #detailsModal .modal-content, #addModal .modal-content {
            z-index: 1000000 !important;
            position: relative !important;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .detail-grid {
                grid-template-columns: 1fr;
            }
            
            .details-modal {
                width: 98%;
                margin: 10px;
                margin-top: 15vh;
            }
            
            .modal-content {
                margin-top: 15vh;
                max-height: 75vh;
            }
        }
    </style>

    <script>
        let currentSupplierData = null;

        function editSupplier(supplierId) {
            console.log('Edit supplier:', supplierId);
            
            // Find supplier data from table
            const supplierData = findSupplierInTable(supplierId);
            
            if (!supplierData) {
                alert('Không tìm thấy thông tin nhà cung cấp');
                return;
            }
            
            currentSupplierData = supplierData;
            showEditModal(supplierData);
        }
        
        function viewDetails(supplierId) {
            console.log('View details for supplier:', supplierId);
            
            // Find supplier data from table
            const supplierData = findSupplierInTable(supplierId);
            
            if (!supplierData) {
                alert('Không tìm thấy thông tin nhà cung cấp');
                return;
            }
            
            currentSupplierData = supplierData;
            showDetailsModal(supplierData);
        }

        function findSupplierInTable(supplierId) {
            const table = document.querySelector('.supplier-table');
            if (!table) return null;
            
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 1; i < rows.length; i++) {
                const cells = rows[i].getElementsByTagName('td');
                if (cells.length >= 7) {
                    const actionButtons = cells[cells.length - 1].querySelectorAll('button');
                    for (let btn of actionButtons) {
                        if (btn.onclick && btn.onclick.toString().includes(supplierId)) {
                            return {
                                id: supplierId,
                                name: cells[0] ? cells[0].textContent.trim() : '',
                                contact: cells[1] ? cells[1].textContent.trim() : '',
                                email: cells[2] ? cells[2].textContent.trim() : '',
                                phone: cells[3] ? cells[3].textContent.trim() : '',
                                rating: extractNumber(cells[4].textContent),
                                onTimeRate: extractNumber(cells[5].textContent),
                                isActive: cells[6].textContent.includes('Hoạt động')
                            };
                        }
                    }
                }
            }
            return null;
        }

        function extractNumber(text) {
            const match = text.match(/(\d+\.?\d*)/);
            return match ? parseFloat(match[1]) : 0;
        }

        function showEditModal(supplierData) {
            // Populate form with current data
            document.getElementById('editSupplierId').value = supplierData.id;
            document.getElementById('editName').value = supplierData.name || '';
            document.getElementById('editContact').value = supplierData.contact || '';
            document.getElementById('editEmail').value = supplierData.email || '';
            document.getElementById('editPhone').value = supplierData.phone || '';
            document.getElementById('editAddress').value = supplierData.address || '';
            document.getElementById('editRating').value = supplierData.rating || 0;
            document.getElementById('editOnTimeRate').value = supplierData.onTimeRate || 0;
            document.getElementById('editIsActive').checked = supplierData.isActive;
            
            // Show modal
            document.getElementById('editModal').style.display = 'flex';
        }

        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
            currentSupplierData = null;
        }

        function showDetailsModal(supplierData) {
            // Populate detail fields
            document.getElementById('detailName').textContent = supplierData.name || 'Chưa cập nhật';
            document.getElementById('detailContact').textContent = supplierData.contact || 'Chưa cập nhật';
            document.getElementById('detailEmail').textContent = supplierData.email || 'Chưa cập nhật';
            document.getElementById('detailPhone').textContent = supplierData.phone || 'Chưa cập nhật';
            document.getElementById('detailAddress').textContent = supplierData.address || 'Chưa cập nhật';
            
            // Rating with stars
            const ratingElement = document.getElementById('detailRating');
            if (supplierData.rating && supplierData.rating > 0) {
                ratingElement.innerHTML = generateStarRating(supplierData.rating) + ' (' + supplierData.rating + '/5)';
            } else {
                ratingElement.textContent = 'Chưa đánh giá';
            }
            
            // On-time rate
            const onTimeRateElement = document.getElementById('detailOnTimeRate');
            if (supplierData.onTimeRate && supplierData.onTimeRate > 0) {
                onTimeRateElement.textContent = supplierData.onTimeRate + '%';
            } else {
                onTimeRateElement.textContent = 'Chưa có dữ liệu';
            }
            
            // Status
            const statusElement = document.getElementById('detailStatus');
            if (supplierData.isActive) {
                statusElement.innerHTML = '<span class="status-badge status-active">Hoạt động</span>';
            } else {
                statusElement.innerHTML = '<span class="status-badge status-inactive">Không hoạt động</span>';
            }
            
            // Created date (placeholder)
            document.getElementById('detailCreatedAt').textContent = 'Chưa có thông tin';
            
            // Statistics (placeholder data)
            document.getElementById('detailTotalOrders').textContent = '0';
            document.getElementById('detailSuccessfulOrders').textContent = '0';
            document.getElementById('detailLateOrders').textContent = '0';
            document.getElementById('detailAvgOrderValue').textContent = '0 VND';
            
            // Show modal
            document.getElementById('detailsModal').style.display = 'flex';
        }

        function closeDetailsModal() {
            document.getElementById('detailsModal').style.display = 'none';
            currentSupplierData = null;
        }

        function editFromDetails() {
            closeDetailsModal();
            if (currentSupplierData) {
                showEditModal(currentSupplierData);
            }
        }

        function openAddModal() {
            console.log('Opening add supplier modal');
            
            // Clear form
            document.getElementById('addForm').reset();
            
            // Set default values
            document.getElementById('addIsActive').checked = true;
            document.getElementById('addRating').value = 0;
            document.getElementById('addOnTimeRate').value = 0;
            
            // Show modal
            document.getElementById('addModal').style.display = 'flex';
        }

        function closeAddModal() {
            document.getElementById('addModal').style.display = 'none';
        }

        function saveNewSupplier() {
            const form = document.getElementById('addForm');
            
            // Get form values
            const data = {
                action: 'create',
                name: document.getElementById('addName').value,
                contact: document.getElementById('addContact').value,
                email: document.getElementById('addEmail').value,
                phone: document.getElementById('addPhone').value,
                address: document.getElementById('addAddress').value,
                rating: parseFloat(document.getElementById('addRating').value) || 0,
                onTimeRate: parseFloat(document.getElementById('addOnTimeRate').value) || 0,
                isActive: document.getElementById('addIsActive').checked
            };
            
            console.log('Creating new supplier:', data);
            
            // Validate required fields
            if (!data.name || data.name.trim() === '') {
                alert('Tên nhà cung cấp không được để trống');
                return;
            }
            
            if (!data.email || data.email.trim() === '') {
                alert('Email không được để trống');
                return;
            }
            
            // Basic email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(data.email)) {
                alert('Email không đúng định dạng');
                return;
            }
            
            // Show loading state
            const saveBtn = document.querySelector('#addModal .btn-primary');
            saveBtn.textContent = 'Đang thêm...';
            saveBtn.classList.add('loading');
            
            // Send create request
            fetch('${pageContext.request.contextPath}/procurement/supplier', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(result => {
                if (result.success) {
                    alert('Thêm nhà cung cấp thành công!');
                    closeAddModal();
                    location.reload(); // Refresh page to show new supplier
                } else {
                    alert('Lỗi: ' + (result.message || 'Không thể thêm nhà cung cấp'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Lỗi kết nối: ' + error.message);
            })
            .finally(() => {
                // Reset button state
                saveBtn.textContent = 'Thêm nhà cung cấp';
                saveBtn.classList.remove('loading');
            });
        }

        function generateStarRating(rating) {
            let stars = '';
            const fullStars = Math.floor(rating);
            const hasHalfStar = rating % 1 !== 0;
            
            for (let i = 0; i < fullStars; i++) {
                stars += '<span class="star">★</span>';
            }
            
            if (hasHalfStar) {
                stars += '<span class="star">☆</span>';
            }
            
            const emptyStars = 5 - Math.ceil(rating);
            for (let i = 0; i < emptyStars; i++) {
                stars += '<span class="star empty">★</span>';
            }
            
            return '<span class="rating-stars">' + stars + '</span>';
        }

        function saveSupplier() {
            const form = document.getElementById('editForm');
            
            // Get form values directly to avoid FormData issues
            const data = {
                action: 'update',
                supplierId: document.getElementById('editSupplierId').value,
                name: document.getElementById('editName').value,
                contact: document.getElementById('editContact').value,
                email: document.getElementById('editEmail').value,
                phone: document.getElementById('editPhone').value,
                address: document.getElementById('editAddress').value,
                rating: parseFloat(document.getElementById('editRating').value) || 0,
                onTimeRate: parseFloat(document.getElementById('editOnTimeRate').value) || 0,
                isActive: document.getElementById('editIsActive').checked
            };
            
            console.log('Sending data:', data);
            
            // Show loading state
            const saveBtn = document.querySelector('.btn-primary');
            saveBtn.textContent = 'Đang lưu...';
            saveBtn.classList.add('loading');
            
            // Send update request
            fetch('${pageContext.request.contextPath}/procurement/supplier', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(result => {
                if (result.success) {
                    alert('Cập nhật nhà cung cấp thành công!');
                    closeEditModal();
                    location.reload(); // Refresh page to show updated data
                } else {
                    alert('Lỗi: ' + (result.message || 'Không thể cập nhật nhà cung cấp'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Lỗi kết nối: ' + error.message);
            })
            .finally(() => {
                // Reset button state
                saveBtn.textContent = 'Lưu thay đổi';
                saveBtn.classList.remove('loading');
            });
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const editModal = document.getElementById('editModal');
            const detailsModal = document.getElementById('detailsModal');
            const addModal = document.getElementById('addModal');
            
            if (event.target === editModal) {
                closeEditModal();
            } else if (event.target === detailsModal) {
                closeDetailsModal();
            } else if (event.target === addModal) {
                closeAddModal();
            }
        }
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            console.log('✅ Supplier list page loaded successfully');
        });
    </script>
</body>
</html>