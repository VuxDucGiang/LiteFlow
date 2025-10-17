<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Debug Supplier List - LiteFlow</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .debug-info { background: #e9ecef; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
        .btn-edit { background: #f39c12; color: white; }
        .btn-details { background: #3498db; color: white; }
        .btn:hover { opacity: 0.8; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .error { background: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; }
        .success { background: #d4edda; color: #155724; padding: 10px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Debug Supplier List</h1>
        
        <!-- Debug Information -->
        <div class="debug-info">
            <h3>📊 Debug Information:</h3>
            <p><strong>Suppliers in request:</strong> ${suppliers != null ? suppliers.size() : 'null'}</p>
            <p><strong>Suppliers in session:</strong> ${sessionScope.suppliers != null ? sessionScope.suppliers.size() : 'null'}</p>
            <p><strong>Page context:</strong> ${pageContext.request.contextPath}</p>
        </div>
        
        <c:choose>
            <c:when test="${empty suppliers}">
                <div class="error">
                    <h3>❌ No Suppliers Found</h3>
                    <p>Suppliers list is empty or null. Check:</p>
                    <ul>
                        <li>Database connection</li>
                        <li>ProcurementService.getAllSuppliers()</li>
                        <li>Servlet data loading</li>
                    </ul>
                </div>
            </c:when>
            <c:otherwise>
                <div class="success">
                    <h3>✅ Found ${suppliers.size()} Suppliers</h3>
                </div>
                
                <table id="supplierTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Contact</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Rating</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="supplier" items="${suppliers}">
                            <tr>
                                <td>${supplier.supplierID}</td>
                                <td><strong>${supplier.name}</strong></td>
                                <td>${supplier.contact}</td>
                                <td>${supplier.email}</td>
                                <td>${supplier.phone}</td>
                                <td>${supplier.rating}</td>
                                <td>
                                    <button class="btn btn-edit" onclick="testEdit('${supplier.supplierID}')">
                                        ✏️ Edit
                                    </button>
                                    <button class="btn btn-details" onclick="testDetails('${supplier.supplierID}')">
                                        👁️ Details
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
        
        <div class="debug-info">
            <h3>🧪 Test Functions:</h3>
            <button class="btn" onclick="testConsole()">Test Console</button>
            <button class="btn" onclick="testAlert()">Test Alert</button>
            <button class="btn" onclick="checkFunctions()">Check Functions</button>
        </div>
    </div>

    <script>
        console.log('🔧 Debug page loaded');
        
        function testEdit(supplierId) {
            console.log('🔧 Edit button clicked:', supplierId);
            alert('Edit clicked for: ' + supplierId);
        }
        
        function testDetails(supplierId) {
            console.log('🔧 Details button clicked:', supplierId);
            alert('Details clicked for: ' + supplierId);
        }
        
        function testConsole() {
            console.log('🧪 Console test successful');
            alert('Console test - check browser console');
        }
        
        function testAlert() {
            alert('🧪 Alert test successful');
        }
        
        function checkFunctions() {
            const functions = ['testEdit', 'testDetails', 'testConsole', 'testAlert'];
            const results = {};
            
            functions.forEach(func => {
                results[func] = typeof window[func];
            });
            
            console.log('🔧 Function check results:', results);
            alert('Function check complete - see console for details');
        }
        
        // Global function assignment
        window.testEdit = testEdit;
        window.testDetails = testDetails;
        window.testConsole = testConsole;
        window.testAlert = testAlert;
        window.checkFunctions = checkFunctions;
        
        console.log('🔧 Debug functions assigned to window');
    </script>
</body>
</html>

