<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Đơn đặt hàng - LiteFlow</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        .btn:hover { background: #0056b3; }
        .btn-success { background: #28a745; }
        .btn-success:hover { background: #1e7e34; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .status-pending { background: #fff3cd; color: #856404; padding: 4px 8px; border-radius: 4px; }
        .status-approved { background: #d4edda; color: #155724; padding: 4px 8px; border-radius: 4px; }
        .status-rejected { background: #f8d7da; color: #721c24; padding: 4px 8px; border-radius: 4px; }
        .status-receiving { background: #d1ecf1; color: #0c5460; padding: 4px 8px; border-radius: 4px; }
        .status-completed { background: #e2e3e5; color: #383d41; padding: 4px 8px; border-radius: 4px; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 5% auto; padding: 20px; border-radius: 8px; width: 80%; max-width: 600px; }
        .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer; }
        .close:hover { color: black; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        .item-row { display: flex; gap: 10px; margin-bottom: 10px; }
        .item-row input { flex: 1; }
        .debug-info { background: #e9ecef; padding: 10px; margin: 10px 0; border-radius: 4px; font-size: 12px; }
    </style>
</head>
<body>
    <jsp:include page="../includes/header.jsp">
        <jsp:param name="page" value="procurement" />
    </jsp:include>
    
    <div class="container">
        <div class="header">
            <h1>📋 Quản lý Đơn đặt hàng</h1>
            <button class="btn btn-success" onclick="openCreateModal()">+ Tạo Đơn hàng</button>
        </div>

        <!-- Debug info -->
        <div class="debug-info">
            <strong>Debug Info:</strong>
            Purchase Orders: ${purchaseOrders != null ? purchaseOrders.size() : 'null'} | 
            Suppliers: ${suppliers != null ? suppliers.size() : 'null'}
            <c:if test="${not empty error}">
                | <span style="color: red;">Error: ${error}</span>
            </c:if>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Mã PO</th>
                    <th>Nhà cung cấp</th>
                    <th>Ngày tạo</th>
                    <th>Ngày giao dự kiến</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty purchaseOrders}">
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 20px;">
                                📋 Chưa có đơn đặt hàng nào. Hãy tạo đơn hàng đầu tiên!
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="po" items="${purchaseOrders}">
                            <tr>
                                <td><strong>PO-${po.poid.toString().substring(0,8)}</strong></td>
                                <td>
                                    <c:forEach var="supplier" items="${suppliers}">
                                        <c:if test="${supplier.supplierID.toString().equals(po.supplierID.toString())}">
                                            ${supplier.name}
                                        </c:if>
                                    </c:forEach>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.createDate != null}">
                                            <fmt:formatDate value="${po.createDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.expectedDelivery != null}">
                                            <fmt:formatDate value="${po.expectedDelivery}" pattern="dd/MM/yyyy"/>
                                        </c:when>
                                        <c:otherwise>Chưa xác định</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.totalAmount != null}">
                                            <fmt:formatNumber value="${po.totalAmount}" type="currency" currencyCode="VND"/>
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
                                        <c:otherwise>${po.status}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.status == 'PENDING'}">
                                            <button class="btn" onclick="approvePO('${po.poid}')">Duyệt</button>
                                            <button class="btn" onclick="rejectPO('${po.poid}')">Từ chối</button>
                                        </c:when>
                                        <c:when test="${po.status == 'APPROVED'}">
                                            <button class="btn" onclick="viewPO('${po.poid}')">Xem</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn" onclick="viewPO('${po.poid}')">Xem</button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
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
                    <textarea id="notes" name="notes" rows="3" placeholder="Nhập ghi chú cho đơn hàng..."></textarea>
                </div>
                
                <div class="form-group">
                    <label>Chi tiết sản phẩm</label>
                    <div id="itemsContainer">
                        <div class="item-row">
                            <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                            <input type="number" name="qty" placeholder="Số lượng" min="1" required>
                            <input type="number" name="price" placeholder="Đơn giá" min="0" step="0.01" required>
                        </div>
                    </div>
                    <button type="button" onclick="addItem()" class="btn">+ Thêm sản phẩm</button>
                </div>
                
                <div style="text-align: right; margin-top: 20px;">
                    <button type="button" onclick="closeModal()" class="btn">Hủy</button>
                    <button type="submit" class="btn btn-success">Tạo Đơn hàng</button>
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
                <button type="button" onclick="removeItem(this)" class="btn" style="background: #dc3545;">X</button>
            `;
            container.appendChild(newRow);
        }

        function removeItem(button) {
            button.parentElement.remove();
        }

        function approvePO(poid) {
            if (confirm('Bạn có chắc chắn muốn duyệt đơn hàng này?')) {
                // TODO: Implement approve functionality
                alert('Chức năng duyệt đơn hàng đang được phát triển');
            }
        }

        function rejectPO(poid) {
            if (confirm('Bạn có chắc chắn muốn từ chối đơn hàng này?')) {
                // TODO: Implement reject functionality
                alert('Chức năng từ chối đơn hàng đang được phát triển');
            }
        }

        function viewPO(poid) {
            alert('Xem chi tiết đơn hàng: ' + poid);
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






