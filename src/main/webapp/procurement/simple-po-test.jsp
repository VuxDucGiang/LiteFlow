<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Simple PO Test</title>
</head>
<body>
    <h1>🔍 Simple Purchase Orders Test</h1>
    
    <h2>Debug Info:</h2>
    <ul>
        <li>Purchase Orders: ${purchaseOrders != null ? purchaseOrders.size() : 'null'}</li>
        <li>Suppliers: ${suppliers != null ? suppliers.size() : 'null'}</li>
        <li>Error: ${error}</li>
    </ul>
    
    <h2>Purchase Orders:</h2>
    <c:choose>
        <c:when test="${empty purchaseOrders}">
            <p>No purchase orders found</p>
        </c:when>
        <c:otherwise>
            <table border="1" style="border-collapse: collapse; width: 100%;">
                <tr>
                    <th>PO ID</th>
                    <th>Supplier</th>
                    <th>Status</th>
                    <th>Amount</th>
                    <th>Create Date</th>
                </tr>
                <c:forEach var="po" items="${purchaseOrders}">
                    <tr>
                        <td>PO-${po.poid.toString().substring(0,8)}</td>
                        <td>
                            <c:forEach var="supplier" items="${suppliers}">
                                <c:if test="${supplier.supplierID.toString().equals(po.supplierID.toString())}">
                                    ${supplier.name}
                                </c:if>
                            </c:forEach>
                        </td>
                        <td>${po.status}</td>
                        <td>${po.totalAmount}</td>
                        <td>${po.createDate}</td>
                    </tr>
                </c:forEach>
            </table>
        </c:otherwise>
    </c:choose>
    
    <p><a href="${pageContext.request.contextPath}/procurement/po">← Back to Purchase Orders</a></p>
</body>
</html>






