<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Nhà cung cấp</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }
        .header h1 {
            margin: 0;
            color: #333;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
        }
        .btn-success {
            background-color: #28a745;
            color: white;
        }
        .btn-edit {
            background-color: #007bff;
            color: white;
            padding: 5px 10px;
            font-size: 12px;
        }
        .btn-details {
            background-color: #6c757d;
            color: white;
            padding: 5px 10px;
            font-size: 12px;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .table th, .table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        .table th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #495057;
        }
        .table tbody tr:hover {
            background-color: #f8f9fa;
        }
        .search-box {
            margin-bottom: 20px;
        }
        .search-box input {
            width: 300px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .status-active {
            color: #28a745;
            font-weight: bold;
        }
        .status-inactive {
            color: #dc3545;
            font-weight: bold;
        }
        .debug-info {
            background: #e9ecef;
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="debug-info">
            <strong>Debug Info:</strong> 
            Suppliers count: ${suppliers != null ? suppliers.size() : 'null'} |
            Session suppliers: ${sessionScope.suppliers != null ? sessionScope.suppliers.size() : 'null'}
        </div>
        
        <div class="header">
            <h1>📦 Quản lý Nhà cung cấp</h1>
            <button class="btn btn-success">+ Thêm Nhà cung cấp</button>
        </div>
        
        <div class="search-box">
            <input type="text" placeholder="Tìm kiếm nhà cung cấp..." />
        </div>
        
        <c:choose>
            <c:when test="${suppliers != null && suppliers.size() > 0}">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Tên</th>
                            <th>Liên hệ</th>
                            <th>Email</th>
                            <th>Điện thoại</th>
                            <th>Đánh giá</th>
                            <th>Tỷ lệ đúng hạn</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="supplier" items="${suppliers}">
                            <tr>
                                <td>${supplier.name}</td>
                                <td>${supplier.contact != null ? supplier.contact : 'N/A'}</td>
                                <td>${supplier.email}</td>
                                <td>${supplier.phone != null ? supplier.phone : 'N/A'}</td>
                                <td>${supplier.rating != null ? supplier.rating : 0}/5</td>
                                <td>${supplier.onTimeRate != null ? supplier.onTimeRate : 0}%</td>
                                <td>
                                    <span class="${supplier.isActive ? 'status-active' : 'status-inactive'}">
                                        ${supplier.isActive ? 'Hoạt động' : 'Ngừng hoạt động'}
                                    </span>
                                </td>
                                <td>
                                    <button class="btn btn-edit" onclick="editSupplier('${supplier.supplierID}')">Sửa</button>
                                    <button class="btn btn-details" onclick="viewDetails('${supplier.supplierID}')">Chi tiết</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div style="text-align: center; padding: 40px; color: #6c757d;">
                    <h3>Không có nhà cung cấp nào</h3>
                    <p>Vui lòng thêm nhà cung cấp mới hoặc kiểm tra kết nối database.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <script>
        function editSupplier(supplierId) {
            alert('Chức năng sửa nhà cung cấp: ' + supplierId);
        }
        
        function viewDetails(supplierId) {
            alert('Xem chi tiết nhà cung cấp: ' + supplierId);
        }
    </script>
</body>
</html>
