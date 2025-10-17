<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Test Simple - LiteFlow</title>
</head>
<body>
    <h1>🧪 Simple Test Page</h1>
    
    <c:choose>
        <c:when test="${not empty suppliers}">
            <p>✅ Found ${suppliers.size()} suppliers</p>
            <ul>
                <c:forEach var="supplier" items="${suppliers}" begin="0" end="2">
                    <li>
                        <strong>${supplier.name}</strong> - 
                        Rating: ${supplier.rating}/5 - 
                        <button onclick="testEdit('${supplier.supplierID}')">Test Edit</button>
                    </li>
                </c:forEach>
            </ul>
        </c:when>
        <c:otherwise>
            <p>❌ No suppliers found</p>
            <p>Debug: suppliers = ${suppliers}</p>
        </c:otherwise>
    </c:choose>
    
    <script>
        function testEdit(supplierId) {
            alert('Test edit for: ' + supplierId);
        }
    </script>
</body>
</html>

