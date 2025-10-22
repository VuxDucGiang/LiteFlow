<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Supplier Page</title>
</head>
<body>
    <h1>Test Supplier Page</h1>
    <p>Current time: <%= new java.util.Date() %></p>
    
    <h2>Session Info:</h2>
    <p>UserLogin: ${sessionScope.UserLogin}</p>
    <p>UserRoles: ${sessionScope.UserRoles}</p>
    
    <h2>Suppliers Data:</h2>
    <p>Suppliers count: ${suppliers != null ? suppliers.size() : 'null'}</p>
    
    <c:if test="${suppliers != null && suppliers.size() > 0}">
        <ul>
            <c:forEach var="supplier" items="${suppliers}" begin="0" end="2">
                <li>${supplier.name} - ${supplier.email}</li>
            </c:forEach>
        </ul>
    </c:if>
    
    <h2>Debug Info:</h2>
    <p>Request attributes: ${requestScope}</p>
    <p>Session attributes: ${sessionScope}</p>
    
    <a href="${pageContext.request.contextPath}/procurement/supplier-simple">Try Simple Version</a>
</body>
</html>
