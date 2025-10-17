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
        .debug-info { background: #e9ecef; padding: 10px; margin: 10px 0; border-radius: 4px; font-size: 12px; }
        .error { background: #f8d7da; color: #721c24; padding: 10px; margin: 10px 0; border-radius: 4px; }
    </style>
</head>
<body>
    <div style="background: #007bff; color: white; padding: 10px; margin-bottom: 20px;">
        <h1 style="margin: 0;">📋 Quản lý Đơn đặt hàng - LiteFlow (Fixed Version)</h1>
    </div>
    
    <div class="container">
        <div class="header">
            <h1>📋 Quản lý Đơn đặt hàng</h1>
            <button class="btn btn-success" onclick="alert('Tạo đơn hàng - Chức năng đang phát triển')">+ Tạo Đơn hàng</button>
        </div>

        <!-- Debug info -->
        <div class="debug-info">
            <strong>Debug Info:</strong>
            Purchase Orders: ${purchaseOrders != null ? purchaseOrders.size() : 'null'} | 
            Suppliers: ${suppliers != null ? suppliers.size() : 'null'}
        </div>
        
        <!-- Error message -->
        <c:if test="${not empty error}">
            <div class="error">
                <strong>⚠️ Error:</strong> ${error}
            </div>
        </c:if>

        <table>
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
                            <td colspan="8" style="text-align: center; padding: 20px;">
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
                                <td>${po.createDate}</td>
                                <td>${po.expectedDelivery}</td>
                                <td>${po.totalAmount} ₫</td>
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
                                <td>${po.createdBy != null ? po.createdBy.toString().substring(0,8) : 'N/A'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.status == 'PENDING'}">
                                            <button class="btn" onclick="alert('Duyệt PO: ${po.poid}')">Duyệt</button>
                                            <button class="btn" onclick="alert('Từ chối PO: ${po.poid}')">Từ chối</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn" onclick="alert('Xem PO: ${po.poid}')">Xem</button>
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
</body>
</html>






