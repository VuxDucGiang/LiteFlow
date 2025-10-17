<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Database Test - Procurement</title>
</head>
<body>
    <h1>🔍 Database Connection Test</h1>
    
    <h2>Test Results:</h2>
    <div style="background: #f0f0f0; padding: 20px; margin: 10px 0;">
        <c:choose>
            <c:when test="${not empty error}">
                <div style="color: red;">❌ <strong>ERROR:</strong> ${error}</div>
            </c:when>
            <c:otherwise>
                <div style="color: green;">✅ <strong>SUCCESS:</strong> Database connection working</div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <h2>Data Count:</h2>
    <ul>
        <li>Suppliers: ${suppliers != null ? suppliers.size() : 'null'}</li>
        <li>Purchase Orders: ${purchaseOrders != null ? purchaseOrders.size() : 'null'}</li>
    </ul>
    
    <h2>Sample Data:</h2>
    <c:if test="${not empty suppliers}">
        <h3>First 3 Suppliers:</h3>
        <c:forEach var="supplier" items="${suppliers}" begin="0" end="2">
            <div>• ${supplier.name} (${supplier.email})</div>
        </c:forEach>
    </c:if>
    
    <c:if test="${not empty purchaseOrders}">
        <h3>First 3 Purchase Orders:</h3>
        <c:forEach var="po" items="${purchaseOrders}" begin="0" end="2">
            <div>• PO-${po.poid.toString().substring(0,8)} - ${po.status} - ${po.totalAmount}</div>
        </c:forEach>
    </c:if>
    
    <h2>Next Steps:</h2>
    <ol>
        <li>If no data: Run <code>PROCUREMENT_SAMPLE_DATA_FIXED.sql</code></li>
        <li>If error: Check database connection in <code>persistence.xml</code></li>
        <li>If still issues: Check server logs for detailed errors</li>
    </ol>
    
    <p><a href="${pageContext.request.contextPath}/procurement/po">← Back to Purchase Orders</a></p>
</body>
</html>






