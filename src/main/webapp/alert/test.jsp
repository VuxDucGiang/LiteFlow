<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alert System Test - LiteFlow</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            background: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .header h1 {
            font-size: 2.5em;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
        }
        
        .header p {
            color: #666;
            font-size: 1.1em;
        }
        
        .section {
            background: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .section h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        
        .button-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }
        
        .test-btn {
            padding: 15px 25px;
            border: none;
            border-radius: 10px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
            justify-content: center;
        }
        
        .test-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .btn-warning {
            background: linear-gradient(135deg, #ff9800, #f57c00);
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #dc3545, #c82333);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #4caf50, #388e3c);
        }
        
        .btn-info {
            background: linear-gradient(135deg, #2196f3, #1976d2);
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #6c757d, #5a6268);
        }
        
        .result-box {
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .result-success {
            background: linear-gradient(135deg, rgba(76,175,80,0.1), rgba(56,142,60,0.1));
            border-left: 5px solid #4caf50;
        }
        
        .result-error {
            background: linear-gradient(135deg, rgba(220,53,69,0.1), rgba(200,35,51,0.1));
            border-left: 5px solid #dc3545;
        }
        
        .result-icon {
            font-size: 2em;
        }
        
        .result-text {
            flex: 1;
        }
        
        .result-text h3 {
            margin-bottom: 5px;
            color: #333;
        }
        
        .result-text p {
            color: #666;
        }
        
        form {
            display: inline;
        }
        
        .info-box {
            background: linear-gradient(135deg, rgba(33,150,243,0.1), rgba(25,118,210,0.1));
            padding: 20px;
            border-radius: 10px;
            border-left: 5px solid #2196f3;
            margin-bottom: 20px;
        }
        
        .info-box h4 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .info-box ul {
            margin-left: 20px;
            color: #666;
        }
        
        .info-box li {
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>🧪 Alert System Test Dashboard</h1>
            <p>Test and verify Alert System functionality</p>
        </div>
        
        <!-- Result Display -->
        <c:if test="${not empty param.result}">
            <div class="result-box ${param.success == 'true' ? 'result-success' : 'result-error'}">
                <div class="result-icon">
                    ${param.success == 'true' ? '✅' : '❌'}
                </div>
                <div class="result-text">
                    <h3>${param.success == 'true' ? 'Success' : 'Error'}</h3>
                    <p>${param.result}</p>
                </div>
            </div>
        </c:if>
        
        <!-- Alert Type Tests -->
        <div class="section">
            <h2>📢 Alert Type Tests</h2>
            <div class="info-box">
                <h4>ℹ️ About Alert Tests</h4>
                <ul>
                    <li>These buttons trigger different types of alerts</li>
                    <li>Alerts will be sent to configured notification channels (Slack/Telegram)</li>
                    <li>Check the Alert Dashboard to see the triggered alerts</li>
                    <li>GPT summaries will be generated if GPT API is configured</li>
                </ul>
            </div>
            <div class="button-grid">
                <form method="post">
                    <input type="hidden" name="action" value="test-daily-summary">
                    <button type="submit" class="test-btn btn-primary">
                        📊 Daily Summary
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="test-po-pending">
                    <button type="submit" class="test-btn btn-warning">
                        ⏳ PO Pending
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="test-po-overdue">
                    <button type="submit" class="test-btn btn-danger">
                        ⏰ PO Overdue
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="test-low-inventory">
                    <button type="submit" class="test-btn btn-warning">
                        📦 Low Inventory
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="test-out-of-stock">
                    <button type="submit" class="test-btn btn-danger">
                        🚨 Out of Stock
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="test-revenue-anomaly">
                    <button type="submit" class="test-btn btn-info">
                        📈 Revenue Anomaly
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="test-high-value-po">
                    <button type="submit" class="test-btn btn-warning">
                        💰 High Value PO
                    </button>
                </form>
            </div>
        </div>
        
        <!-- Notification Channel Tests -->
        <div class="section">
            <h2>📡 Notification Channel Tests</h2>
            <div class="info-box">
                <h4>ℹ️ About Channel Tests</h4>
                <ul>
                    <li>Test individual notification channels</li>
                    <li>Make sure channels are configured in the database first</li>
                    <li>Check Slack workspace or Telegram chat for test messages</li>
                </ul>
            </div>
            <div class="button-grid">
                <form method="post">
                    <input type="hidden" name="action" value="test-slack">
                    <button type="submit" class="test-btn btn-success">
                        💬 Test Slack
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="test-telegram">
                    <button type="submit" class="test-btn btn-info">
                        ✈️ Test Telegram
                    </button>
                </form>
            </div>
        </div>
        
        <!-- Scheduler Controls -->
        <div class="section">
            <h2>⏰ Scheduler Controls</h2>
            <div class="info-box">
                <h4>ℹ️ About Scheduler</h4>
                <ul>
                    <li>Start/Stop the background alert scheduler</li>
                    <li>Scheduler checks for pending POs, overdue deliveries, etc.</li>
                    <li>Runs every 5 minutes for scheduled alerts, every hour for condition checks</li>
                </ul>
            </div>
            <div class="button-grid">
                <form method="post">
                    <input type="hidden" name="action" value="start-scheduler">
                    <button type="submit" class="test-btn btn-success">
                        ▶️ Start Scheduler
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="stop-scheduler">
                    <button type="submit" class="test-btn btn-danger">
                        ⏸️ Stop Scheduler
                    </button>
                </form>
                
                <form method="post">
                    <input type="hidden" name="action" value="init-scheduled-runs">
                    <button type="submit" class="test-btn btn-secondary">
                        🔄 Initialize Schedules
                    </button>
                </form>
            </div>
        </div>
        
        <!-- Quick Links -->
        <div class="section">
            <h2>🔗 Quick Links</h2>
            <div class="button-grid">
                <a href="${pageContext.request.contextPath}/alert/" class="test-btn btn-primary" style="text-decoration: none;">
                    🔔 Alert Dashboard
                </a>
                
                <a href="${pageContext.request.contextPath}/dashboard" class="test-btn btn-secondary" style="text-decoration: none;">
                    🏠 Main Dashboard
                </a>
            </div>
        </div>
    </div>
</body>
</html>

