<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Debug PO Page</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f0f0f0; }
        .debug-box { background: white; padding: 20px; margin: 10px 0; border-radius: 5px; border: 1px solid #ccc; }
        .error { background: #ffebee; color: #c62828; }
        .success { background: #e8f5e8; color: #2e7d32; }
        .info { background: #e3f2fd; color: #1565c0; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>🔍 Debug Purchase Orders Page</h1>
    
    <div class="debug-box info">
        <h3>📊 Session Info</h3>
        <p>UserLogin: ${sessionScope.UserLogin}</p>
        <p>UserRoles: ${sessionScope.UserRoles}</p>
        <p>Current Time: <%= new java.util.Date() %></p>
    </div>
    
    <div class="debug-box">
        <h3>📋 Data Status</h3>
        <p><strong>Purchase Orders:</strong> ${purchaseOrders != null ? purchaseOrders.size() : 'NULL'}</p>
        <p><strong>Suppliers:</strong> ${suppliers != null ? suppliers.size() : 'NULL'}</p>
        <p><strong>Error Message:</strong> ${error}</p>
    </div>
    
    <c:if test="${not empty purchaseOrders}">
        <div class="debug-box success">
            <h3>✅ Purchase Orders Data</h3>
            <table>
                <tr>
                    <th>PO ID</th>
                    <th>Supplier ID</th>
                    <th>Status</th>
                    <th>Amount</th>
                    <th>Create Date</th>
                </tr>
                <c:forEach var="po" items="${purchaseOrders}" begin="0" end="5">
                    <tr>
                        <td>${po.poid}</td>
                        <td>${po.supplierID}</td>
                        <td>${po.status}</td>
                        <td>${po.totalAmount}</td>
                        <td>${po.createDate}</td>
                    </tr>
                </c:forEach>
            </table>
            <p><em>Showing first 6 records...</em></p>
        </div>
    </c:if>
    
    <c:if test="${not empty suppliers}">
        <div class="debug-box success">
            <h3>✅ Suppliers Data</h3>
            <table>
                <tr>
                    <th>Supplier ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Rating</th>
                </tr>
                <c:forEach var="supplier" items="${suppliers}">
                    <tr>
                        <td>${supplier.supplierID}</td>
                        <td>${supplier.name}</td>
                        <td>${supplier.email}</td>
                        <td>${supplier.rating}</td>
                    </tr>
                </c:forEach>
            </table>
        </div>
    </c:if>
    
    <c:if test="${empty purchaseOrders && empty suppliers}">
        <div class="debug-box error">
            <h3>❌ No Data Found</h3>
            <p>Either:</p>
            <ul>
                <li>Database connection failed</li>
                <li>No data in database (run PROCUREMENT_SAMPLE_DATA_FIXED.sql)</li>
                <li>Servlet error occurred</li>
                <li>JSP rendering issue</li>
            </ul>
        </div>
    </c:if>
    
    <div class="debug-box">
        <h3>🔧 Quick Actions</h3>
        <p><a href="${pageContext.request.contextPath}/procurement/test" target="_blank">Test Data Servlet</a></p>
        <p><a href="${pageContext.request.contextPath}/procurement/simple-test" target="_blank">Simple Test Servlet</a></p>
        <p><a href="${pageContext.request.contextPath}/procurement/po" target="_blank">Main PO Page</a></p>
    </div>
</body>
</html>






