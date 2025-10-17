<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Minimal Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f0f0f0; }
        .test-box { background: white; padding: 20px; margin: 10px 0; border-radius: 5px; border: 2px solid #007bff; }
        .success { border-color: #28a745; background: #d4edda; }
        .error { border-color: #dc3545; background: #f8d7da; }
    </style>
</head>
<body>
    <div class="test-box success">
        <h1>✅ Minimal Test Page Working!</h1>
        <p>If you can see this, the basic JSP is working.</p>
    </div>
    
    <div class="test-box">
        <h2>📊 Data Test</h2>
        <p><strong>Purchase Orders:</strong> ${purchaseOrders != null ? purchaseOrders.size() : 'NULL'}</p>
        <p><strong>Suppliers:</strong> ${suppliers != null ? suppliers.size() : 'NULL'}</p>
        <p><strong>Error:</strong> ${error}</p>
    </div>
    
    <c:if test="${not empty purchaseOrders}">
        <div class="test-box success">
            <h3>✅ Data Found!</h3>
            <p>Found ${purchaseOrders.size()} purchase orders</p>
            <c:forEach var="po" items="${purchaseOrders}" begin="0" end="2">
                <p>• PO-${po.poid.toString().substring(0,8)} - ${po.status} - ${po.totalAmount}</p>
            </c:forEach>
        </div>
    </c:if>
    
    <c:if test="${empty purchaseOrders}">
        <div class="test-box error">
            <h3>❌ No Data</h3>
            <p>No purchase orders found. Check:</p>
            <ul>
                <li>Database connection</li>
                <li>Run PROCUREMENT_SAMPLE_DATA_FIXED.sql</li>
                <li>Servlet errors in server logs</li>
            </ul>
        </div>
    </c:if>
    
    <div class="test-box">
        <h3>🔗 Navigation</h3>
        <p><a href="${pageContext.request.contextPath}/procurement/debug-po">Debug PO Page</a></p>
        <p><a href="${pageContext.request.contextPath}/procurement/test">Test Data</a></p>
        <p><a href="${pageContext.request.contextPath}/procurement/po">Main PO Page</a></p>
    </div>
</body>
</html>






