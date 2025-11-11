<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán - LiteFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.0.7/css/boxicons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
    <style>
        .payment-result-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
        }
        
        .payment-result-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
        }
        
        .payment-result-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        
        .payment-result-icon.success {
            color: #4caf50;
        }
        
        .payment-result-icon.failed {
            color: #f44336;
        }
        
        .payment-result-icon.pending {
            color: #ff9800;
        }
        
        .payment-result-title {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        
        .payment-result-message {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .payment-details {
            background: #f5f5f5;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
            text-align: left;
        }
        
        .payment-detail-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .payment-detail-row:last-child {
            border-bottom: none;
        }
        
        .payment-detail-label {
            font-weight: 600;
            color: #666;
        }
        
        .payment-detail-value {
            color: #333;
        }
        
        .payment-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
        }
        
        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #e0e0e0;
            color: #333;
        }
        
        .btn-secondary:hover {
            background: #d0d0d0;
        }
        
        .countdown {
            margin-top: 20px;
            font-size: 14px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="payment-result-container">
        <div class="payment-result-card">
            <%
                String status = request.getParameter("status");
                String transactionId = request.getParameter("transactionId");
                String responseCode = request.getParameter("responseCode");
                String successParam = request.getParameter("success");
                String message = request.getParameter("message");
                
                // Xử lý trường hợp status = "Unknown" - coi như failed nếu success = false
                if ("Unknown".equals(status) && "false".equals(successParam)) {
                    status = "Failed";
                }
                
                boolean isSuccess = "true".equals(successParam) || "Completed".equals(status);
                boolean isFailed = "false".equals(successParam) || "Failed".equals(status) || "Unknown".equals(status);
                boolean isPending = "Pending".equals(status) || "Processing".equals(status);
                
                // Nếu không có message và failed, hiển thị message mặc định
                if (isFailed && (message == null || message.trim().isEmpty())) {
                    message = "Giao dịch của bạn không thể được xử lý. Vui lòng thử lại hoặc liên hệ hỗ trợ.";
                }
            %>
            
            <c:choose>
                <c:when test="<%= isSuccess %>">
                    <i class='bx bx-check-circle payment-result-icon success'></i>
                    <h1 class="payment-result-title">Thanh toán thành công!</h1>
                    <p class="payment-result-message">
                        Giao dịch của bạn đã được xử lý thành công. Cảm ơn bạn đã sử dụng dịch vụ!
                    </p>
                </c:when>
                <c:when test="<%= isFailed %>">
                    <i class='bx bx-x-circle payment-result-icon failed'></i>
                    <h1 class="payment-result-title">Thanh toán thất bại</h1>
                    <p class="payment-result-message">
                        <%= message != null ? message : "Giao dịch của bạn không thể được xử lý. Vui lòng thử lại hoặc liên hệ hỗ trợ." %>
                    </p>
                </c:when>
                <c:otherwise>
                    <i class='bx bx-time payment-result-icon pending'></i>
                    <h1 class="payment-result-title">Đang xử lý</h1>
                    <p class="payment-result-message">
                        Giao dịch của bạn đang được xử lý. Vui lòng đợi trong giây lát...
                    </p>
                </c:otherwise>
            </c:choose>
            
            <c:if test="<%= (transactionId != null && !transactionId.isEmpty()) || (responseCode != null && !responseCode.isEmpty()) || isFailed %>">
                <div class="payment-details">
                    <c:if test="<%= transactionId != null && !transactionId.isEmpty() %>">
                        <div class="payment-detail-row">
                            <span class="payment-detail-label">Mã giao dịch:</span>
                            <span class="payment-detail-value"><%= transactionId %></span>
                        </div>
                    </c:if>
                    <c:if test="<%= responseCode != null && !responseCode.isEmpty() %>">
                        <div class="payment-detail-row">
                            <span class="payment-detail-label">Mã phản hồi:</span>
                            <span class="payment-detail-value"><%= responseCode %></span>
                        </div>
                    </c:if>
                    <div class="payment-detail-row">
                        <span class="payment-detail-label">Trạng thái:</span>
                        <span class="payment-detail-value">
                            <c:choose>
                                <c:when test="<%= isSuccess %>">Thành công</c:when>
                                <c:when test="<%= isFailed %>">Thất bại</c:when>
                                <c:otherwise>Đang xử lý</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
            </c:if>
            
            <div class="payment-actions">
                <a href="${pageContext.request.contextPath}/cashier" class="btn btn-primary">
                    <i class='bx bx-home'></i> Quay lại Cashier
                </a>
                <c:if test="<%= isFailed %>">
                    <a href="javascript:history.back()" class="btn btn-secondary">
                        <i class='bx bx-arrow-back'></i> Thử lại
                    </a>
                </c:if>
            </div>
            
            <c:if test="<%= isSuccess %>">
                <div class="countdown">
                    Tự động chuyển về Cashier sau <span id="countdown">5</span> giây...
                </div>
            </c:if>
        </div>
    </div>
    
    <script>
        <c:if test="<%= isSuccess %>">
        // Auto redirect after 5 seconds
        let countdown = 5;
        const countdownElement = document.getElementById('countdown');
        
        const timer = setInterval(function() {
            countdown--;
            if (countdownElement) {
                countdownElement.textContent = countdown;
            }
            
            if (countdown <= 0) {
                clearInterval(timer);
                window.location.href = '${pageContext.request.contextPath}/cashier';
            }
        }, 1000);
        </c:if>
    </script>
</body>
</html>

