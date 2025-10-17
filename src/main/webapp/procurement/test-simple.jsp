<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Simple - LiteFlow</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .test-box { background: #f0f0f0; padding: 20px; margin: 20px 0; border-radius: 8px; }
        .btn { padding: 10px 20px; margin: 5px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .btn:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Test Simple Page</h1>
        
        <div class="test-box">
            <h2>✅ Basic HTML Test</h2>
            <p>If you can see this page, the basic HTML structure is working.</p>
        </div>
        
        <div class="test-box">
            <h2>🔧 JavaScript Test</h2>
            <button class="btn" onclick="testJS()">Test JavaScript</button>
            <div id="js-result"></div>
        </div>
        
        <div class="test-box">
            <h2>📊 Data Test</h2>
            <p>Purchase Orders Count: <strong id="po-count">Loading...</strong></p>
            <p>Suppliers Count: <strong id="supplier-count">Loading...</strong></p>
        </div>
        
        <div class="test-box">
            <h2>🔗 Navigation Test</h2>
            <button class="btn" onclick="window.location.href='${pageContext.request.contextPath}/procurement/po'">Back to PO Page</button>
        </div>
    </div>

    <script>
        function testJS() {
            document.getElementById('js-result').innerHTML = '✅ JavaScript is working!';
            console.log('JavaScript test successful');
        }

        // Test data availability
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM loaded');
            
            // Try to access data (will show errors if not available)
            try {
                // This will fail if data is not available, but that's OK for testing
                document.getElementById('po-count').textContent = 'Data not available (expected)';
                document.getElementById('supplier-count').textContent = 'Data not available (expected)';
            } catch (error) {
                console.log('Data not available (expected):', error);
            }
        });

        console.log('Test script loaded');
    </script>
</body>
</html>