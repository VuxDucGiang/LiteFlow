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

    <script>
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
                <input type="number" name="qty" placeholder="Số lượng" min="1" required>
                <input type="number" name="price" placeholder="Đơn giá" min="0" step="0.01" required>
                <button type="button" onclick="removeItem(this)">Xóa</button>
            `;
            container.appendChild(newRow);
            updateRemoveButtons();
        }

        function removeItem(button) {
            button.parentElement.remove();
            updateRemoveButtons();
        }

        function updateRemoveButtons() {
            const rows = document.querySelectorAll('.item-row');
            rows.forEach((row, index) => {
                const removeBtn = row.querySelector('button');
                if (rows.length > 1) {
                    removeBtn.style.display = 'block';
                } else {
                    removeBtn.style.display = 'none';
                }
            });
        }

        function approvePO(poId) {
            if (confirm('Bạn có chắc chắn muốn duyệt đơn hàng này?')) {
                // TODO: Implement approve functionality
                alert('Đã duyệt đơn hàng: ' + poId);
            }
        }

        function rejectPO(poId) {
            const reason = prompt('Lý do từ chối:');
            if (reason) {
                // TODO: Implement reject functionality
                alert('Đã từ chối đơn hàng: ' + poId + ' - Lý do: ' + reason);
            }
        }

        function receiveGoods(poId) {
            // TODO: Redirect to goods receipt page
            window.location.href = '${pageContext.request.contextPath}/procurement/gr?poid=' + poId;
        }

        function viewDetails(poId) {
            // TODO: Show PO details in modal or redirect to details page
            alert('Xem chi tiết đơn hàng: ' + poId);
        }

        function exportPOs() {
            // TODO: Implement export functionality
            alert('Xuất báo cáo đơn hàng');
        }

        function filterTable() {
            const statusFilter = document.getElementById('statusFilter').value;
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const dateFilter = document.getElementById('dateFilter').value;
            const table = document.getElementById('poTable');
            const tr = table.getElementsByTagName('tr');

            for (let i = 1; i < tr.length; i++) {
                const td = tr[i].getElementsByTagName('td');
                let show = true;

                // Status filter
                if (statusFilter) {
                    const statusSpan = td[5].querySelector('span');
                    if (!statusSpan || !statusSpan.textContent.toLowerCase().includes(statusFilter.toLowerCase())) {
                        show = false;
                    }
                }

                // Search filter
                if (searchInput && show) {
                    let found = false;
                    for (let j = 0; j < td.length; j++) {
                        if (td[j].textContent.toLowerCase().indexOf(searchInput) > -1) {
                            found = true;
                            break;
                        }
                    }
                    show = found;
                }

                tr[i].style.display = show ? '' : 'none';
            }
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('createModal');
            if (event.target === modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>
