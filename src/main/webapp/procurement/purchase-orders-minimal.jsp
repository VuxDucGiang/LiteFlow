<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
        .btn { padding: 10px 20px; margin: 5px; border: none; border-radius: 4px; cursor: pointer; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-warning { background: #ffc107; color: black; }
        .btn-danger { background: #dc3545; color: white; }
        .table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .table th, .table td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        .table th { background: #f8f9fa; font-weight: bold; }
        .table tr:hover { background: #f5f5f5; }
        .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .status-pending { background: #ffc107; color: black; }
        .status-approved { background: #28a745; color: white; }
        .status-rejected { background: #dc3545; color: white; }
        .debug-info { background: #e9ecef; padding: 15px; margin: 20px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 Quản lý Đơn đặt hàng - MINIMAL TEST</h1>
            <div>
                <button class="btn btn-success" onclick="alert('Create PO clicked')">+ Tạo Đơn hàng</button>
                <button class="btn btn-primary" onclick="alert('Export clicked')">📊 Xuất báo cáo</button>
            </div>
        </div>

        <!-- Debug info -->
        <div class="debug-info">
            <h3>🔍 Debug Information</h3>
            <p><strong>Purchase Orders Count:</strong> 
                <c:choose>
                    <c:when test="${not empty purchaseOrders}">
                        ${purchaseOrders.size()}
                    </c:when>
                    <c:otherwise>
                        <span style="color: red;">❌ No data or error</span>
                    </c:otherwise>
                </c:choose>
            </p>
            <p><strong>Suppliers Count:</strong> 
                <c:choose>
                    <c:when test="${not empty suppliers}">
                        ${suppliers.size()}
                    </c:when>
                    <c:otherwise>
                        <span style="color: red;">❌ No data or error</span>
                    </c:otherwise>
                </c:choose>
            </p>
            <p><strong>Page Context:</strong> ${pageContext.request.contextPath}</p>
        </div>

        <!-- Purchase Orders Table -->
        <c:choose>
            <c:when test="${not empty purchaseOrders}">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Mã PO</th>
                            <th>Nhà cung cấp</th>
                            <th>Ngày tạo</th>
                            <th>Ngày giao</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="po" items="${purchaseOrders}" varStatus="status">
                            <tr>
                                <td><strong>PO-${po.poid.toString().substring(0,8)}</strong></td>
                                <td>
                                    <c:forEach var="supplier" items="${suppliers}">
                                        <c:if test="${supplier.supplierID.toString() == po.supplierID.toString()}">
                                            ${supplier.name}
                                        </c:if>
                                    </c:forEach>
                                </td>
                                <td>${po.createDate != null ? po.createDate : 'N/A'}</td>
                                <td>${po.expectedDelivery != null ? po.expectedDelivery : 'N/A'}</td>
                                <td>${po.totalAmount != null ? po.totalAmount : 'N/A'}</td>
                                <td>
                                    <span class="status-badge status-${po.status.toLowerCase()}">${po.status}</span>
                                </td>
                                <td>
                                    <c:if test="${po.status == 'PENDING'}">
                                        <button class="btn btn-success" onclick="approvePO('${po.poid}')">Duyệt</button>
                                        <button class="btn btn-danger" onclick="rejectPO('${po.poid}')">Từ chối</button>
                                    </c:if>
                                    <c:if test="${po.status == 'APPROVED'}">
                                        <button class="btn btn-primary" onclick="receiveGoods('${po.poid}')">Nhận hàng</button>
                                    </c:if>
                                    <button class="btn btn-warning" onclick="viewDetails('${po.poid}')">Chi tiết</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="debug-info">
                    <h3>❌ No Purchase Orders Found</h3>
                    <p>Possible issues:</p>
                    <ul>
                        <li>Database connection problem</li>
                        <li>No data in purchase_orders table</li>
                        <li>Servlet not loading data properly</li>
                        <li>JSP data binding issue</li>
                    </ul>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Navigation -->
        <div style="margin-top: 30px; text-align: center;">
            <button class="btn btn-primary" onclick="window.location.href='${pageContext.request.contextPath}/procurement/test-simple'">
                🧪 Go to Simple Test
            </button>
            <button class="btn btn-primary" onclick="window.location.href='${pageContext.request.contextPath}/procurement/po'">
                📋 Go to Full PO Page
            </button>
        </div>
    </div>

    <script>
        // Simple functions for testing
        function viewDetails(poId) {
            alert('View Details for PO: ' + poId);
            console.log('viewDetails called with:', poId);
        }

        function approvePO(poId) {
            if (confirm('Approve PO: ' + poId + '?')) {
                alert('PO Approved: ' + poId);
                console.log('approvePO called with:', poId);
            }
        }

        function rejectPO(poId) {
            const reason = prompt('Reject PO: ' + poId + '\nReason:');
            if (reason) {
                alert('PO Rejected: ' + poId + '\nReason: ' + reason);
                console.log('rejectPO called with:', poId, 'Reason:', reason);
            }
        }

        function receiveGoods(poId) {
            alert('Receive Goods for PO: ' + poId);
            console.log('receiveGoods called with:', poId);
        }

        // Page load test
        document.addEventListener('DOMContentLoaded', function() {
            console.log('=== MINIMAL PO PAGE LOADED ===');
            console.log('Page context:', '${pageContext.request.contextPath}');
            console.log('Purchase orders count:', ${not empty purchaseOrders ? purchaseOrders.size() : 0});
            console.log('Suppliers count:', ${not empty suppliers ? suppliers.size() : 0});
        });
    </script>
</body>
</html>
