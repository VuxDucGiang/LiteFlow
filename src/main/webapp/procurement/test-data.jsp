<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Test Data - Procurement</title>
</head>
<body>
    <h1>🔍 Test Procurement Data</h1>
    
    <h2>Suppliers (${suppliers.size()})</h2>
    <c:forEach var="supplier" items="${suppliers}">
        <div>
            <strong>${supplier.name}</strong> - ${supplier.email}
            <br>ID: ${supplier.supplierID}
        </div>
    </c:forEach>
    
    <h2>Purchase Orders (${purchaseOrders.size()})</h2>
    <c:forEach var="po" items="${purchaseOrders}">
        <div>
            <strong>PO-${po.poid}</strong> - Supplier: ${po.supplierID}
            <br>Status: ${po.status} - Amount: ${po.totalAmount}
        </div>
    </c:forEach>
    
    <h2>Session Attributes</h2>
    <div>UserLogin: ${sessionScope.UserLogin}</div>
    <div>UserRoles: ${sessionScope.UserRoles}</div>
    
    <h2>Error Info</h2>
    <div style="color: red;">${error}</div>
</body>
</html>






