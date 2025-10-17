<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đối chiếu Hóa đơn - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
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
        .matched {
            background-color: #d4edda;
            color: #155724;
        }
        .unmatched {
            background-color: #f8d7da;
            color: #721c24;
        }
        .amount {
            font-weight: bold;
        }
        .difference {
            font-weight: bold;
            color: #e74c3c;
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
            margin: 5% auto;
            padding: 20px;
            border-radius: 8px;
            width: 80%;
            max-width: 600px;
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
        .comparison {
            display: flex;
            gap: 20px;
            margin: 20px 0;
        }
        .comparison-item {
            flex: 1;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .comparison-item h4 {
            margin-top: 0;
            color: #2c3e50;
        }
        .alert {
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <jsp:include page="../includes/header.jsp">
        <jsp:param name="page" value="procurement" />
    </jsp:include>
    
    <div class="container">
        <div class="header">
            <h1>🧾 Đối chiếu Hóa đơn</h1>
            <button class="btn btn-success" onclick="openMatchModal()">+ Đối chiếu Hóa đơn</button>
        </div>

        <table class="table">
            <thead>
                <tr>
                    <th>Mã hóa đơn</th>
                    <th>Mã PO</th>
                    <th>Nhà cung cấp</th>
                    <th>Ngày hóa đơn</th>
                    <th>Số tiền hóa đơn</th>
                    <th>Số tiền PO</th>
                    <th>Chênh lệch</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="invoice" items="${invoices}">
                    <tr class="${invoice.matched ? 'matched' : 'unmatched'}">
                        <td><strong>INV-${invoice.invoiceID.toString().substring(0,8)}</strong></td>
                        <td>PO-${invoice.poid.toString().substring(0,8)}</td>
                        <td>
                            <!-- TODO: Get supplier name -->
                            Nhà cung cấp
                        </td>
                        <td><fmt:formatDate value="${invoice.invoiceDate}" pattern="dd/MM/yyyy"/></td>
                        <td class="amount">
                            <fmt:formatNumber value="${invoice.totalAmount}" type="currency" currencyCode="VND"/>
                        </td>
                        <td class="amount">
                            <!-- TODO: Get PO amount -->
                            <fmt:formatNumber value="${invoice.totalAmount}" type="currency" currencyCode="VND"/>
                        </td>
                        <td class="difference">
                            <!-- TODO: Calculate difference -->
                            0 VND
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${invoice.matched}">
                                    <span class="alert alert-success">Khớp</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="alert alert-danger">Không khớp</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <button class="btn btn-warning" onclick="viewDetails('${invoice.invoiceID}')">Chi tiết</button>
                            <c:if test="${!invoice.matched}">
                                <button class="btn btn-danger" onclick="resolveDiscrepancy('${invoice.invoiceID}')">Xử lý</button>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Modal đối chiếu hóa đơn -->
    <div id="matchModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Đối chiếu Hóa đơn</h2>
            
            <form id="matchForm" action="${pageContext.request.contextPath}/procurement/invoice" method="post">
                <div class="form-group">
                    <label for="poSelect">Chọn đơn hàng *</label>
                    <select id="poSelect" onchange="loadPODetails()" required>
                        <option value="">Chọn đơn hàng</option>
                        <c:forEach var="po" items="${completedPOs}">
                            <option value="${po.poid}">PO-${po.poid.toString().substring(0,8)} - 
                                <fmt:formatNumber value="${po.totalAmount}" type="currency" currencyCode="VND"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div id="poDetails" style="display: none;">
                    <div class="comparison">
                        <div class="comparison-item">
                            <h4>Thông tin PO</h4>
                            <div id="poInfo"></div>
                        </div>
                        <div class="comparison-item">
                            <h4>Thông tin Hóa đơn</h4>
                            <div class="form-group">
                                <label for="invoiceAmount">Số tiền hóa đơn *</label>
                                <input type="number" id="invoiceAmount" name="total" step="0.01" min="0" required>
                            </div>
                            <div class="form-group">
                                <label for="invoiceDate">Ngày hóa đơn</label>
                                <input type="date" id="invoiceDate" name="invoiceDate">
                            </div>
                        </div>
                    </div>
                    
                    <div id="comparisonResult" style="display: none;">
                        <h4>Kết quả đối chiếu</h4>
                        <div id="comparisonAlert"></div>
                    </div>
                </div>

                <input type="hidden" id="poid" name="poid">
                <input type="hidden" id="supplierID" name="supplierID">
                
                <div style="text-align: right; margin-top: 20px;">
                    <button type="button" class="btn" onclick="closeModal()">Hủy</button>
                    <button type="submit" class="btn btn-success">Đối chiếu</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openMatchModal() {
            document.getElementById('matchModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('matchModal').style.display = 'none';
            document.getElementById('poDetails').style.display = 'none';
            document.getElementById('comparisonResult').style.display = 'none';
            document.getElementById('matchForm').reset();
        }

        function loadPODetails() {
            const poId = document.getElementById('poSelect').value;
            if (poId) {
                document.getElementById('poid').value = poId;
                document.getElementById('supplierID').value = 'supplier-id'; // TODO: Get actual supplier ID
                document.getElementById('poDetails').style.display = 'block';
                
                // TODO: Load PO details via AJAX
                // For now, show placeholder data
                document.getElementById('poInfo').innerHTML = `
                    <p><strong>Mã PO:</strong> PO-${poId.substring(0,8)}</p>
                    <p><strong>Nhà cung cấp:</strong> Nhà cung cấp ABC</p>
                    <p><strong>Tổng tiền PO:</strong> 2,500,000 VND</p>
                   <p><strong>Ngày đặt:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></p>
                `;
                
                // Add event listener for amount comparison
                document.getElementById('invoiceAmount').addEventListener('input', compareAmounts);
            } else {
                document.getElementById('poDetails').style.display = 'none';
                document.getElementById('comparisonResult').style.display = 'none';
            }
        }

        function compareAmounts() {
            const poAmount = 2500000; // TODO: Get actual PO amount
            const invoiceAmount = parseFloat(document.getElementById('invoiceAmount').value) || 0;
            const difference = invoiceAmount - poAmount;
            
            const resultDiv = document.getElementById('comparisonResult');
            const alertDiv = document.getElementById('comparisonAlert');
            
            if (invoiceAmount > 0) {
                resultDiv.style.display = 'block';
                
                if (Math.abs(difference) < 1000) { // Tolerance of 1000 VND
                    alertDiv.innerHTML = `
                        <div class="alert alert-success">
                            <strong>Khớp!</strong> Hóa đơn khớp với đơn hàng.
                            <br>Chênh lệch: ${difference.toLocaleString('vi-VN')} VND
                        </div>
                    `;
                } else if (difference > 0) {
                    alertDiv.innerHTML = `
                        <div class="alert alert-danger">
                            <strong>Vượt giá!</strong> Hóa đơn cao hơn đơn hàng.
                            <br>Chênh lệch: +${difference.toLocaleString('vi-VN')} VND
                        </div>
                    `;
                } else {
                    alertDiv.innerHTML = `
                        <div class="alert alert-danger">
                            <strong>Thiếu tiền!</strong> Hóa đơn thấp hơn đơn hàng.
                            <br>Chênh lệch: ${difference.toLocaleString('vi-VN')} VND
                        </div>
                    `;
                }
            } else {
                resultDiv.style.display = 'none';
            }
        }

        function viewDetails(invoiceId) {
            // TODO: Show invoice details in modal or redirect to details page
            alert('Xem chi tiết hóa đơn: ' + invoiceId);
        }

        function resolveDiscrepancy(invoiceId) {
            // TODO: Open modal to resolve discrepancy
            alert('Xử lý chênh lệch hóa đơn: ' + invoiceId);
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('matchModal');
            if (event.target === modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>
