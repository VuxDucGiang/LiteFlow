<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Test Supplier Page</title>
</head>
<body>
    <h1>Test Supplier Page</h1>
    <p>Current time: <%= new java.util.Date() %></p>
    
    <h2>Suppliers Data:</h2>
    <c:choose>
        <c:when test="${suppliers != null}">
            <p>Found ${suppliers.size()} suppliers</p>
            <ul>
                <c:forEach var="supplier" items="${suppliers}" begin="0" end="2">
                    <li>${supplier.name} - ${supplier.email}</li>
                </c:forEach>
            </ul>
        </c:when>
        <c:otherwise>
            <p>No suppliers data found</p>
        </c:otherwise>
    </c:choose>
    
    <h2>Debug Info:</h2>
    <p>Request URI: ${pageContext.request.requestURI}</p>
    <p>Context Path: ${pageContext.request.contextPath}</p>
    <p>Servlet Path: ${pageContext.request.servletPath}</p>
</body>
</html>
