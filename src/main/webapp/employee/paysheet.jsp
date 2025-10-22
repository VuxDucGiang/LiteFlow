<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="../includes/header.jsp">
  <jsp:param name="page" value="paysheet" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/employee.css">

<div class="content">
    <!-- Page Header -->
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px;">
        <div>
            <h1 style="font-size: 28px; font-weight: 700; margin: 0; margin-bottom: 8px;">
                <i class='bx bx-money' style="color: #0080FF; margin-right: 8px;"></i>
                Bảng lương
            </h1>
            <p style="color: #6b7280; margin: 0;">
                Quản lý bảng lương và thanh toán cho nhân viên
            </p>
        </div>
        <div>
            <button class="btn btn-success" onclick="createPayroll()">
                <i class='bx bx-plus'></i> Tạo bảng lương
            </button>
        </div>
    </div>

    <!-- Statistics -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-number">0</div>
            <div class="stat-label">Tổng bảng lương</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">0 VNĐ</div>
            <div class="stat-label">Tổng tiền lương tháng này</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">0</div>
            <div class="stat-label">Đã thanh toán</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">0</div>
            <div class="stat-label">Chưa thanh toán</div>
        </div>
    </div>

    <!-- Empty State -->
    <div style="background: white; border-radius: 12px; padding: 48px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
        <i class='bx bx-money' style="font-size: 64px; color: #d1d5db; margin-bottom: 16px;"></i>
        <h3 style="font-size: 20px; font-weight: 600; margin: 0 0 8px 0; color: #374151;">
            Chưa có dữ liệu bảng lương
        </h3>
        <p style="color: #6b7280; margin: 0 0 24px 0;">
            Hãy tạo bảng lương đầu tiên để bắt đầu quản lý
        </p>
        <button class="btn btn-primary" onclick="createPayroll()">
            <i class='bx bx-plus'></i> Tạo bảng lương mới
        </button>
    </div>
</div>

<script>
    function createPayroll() {
        alert('Chức năng tạo bảng lương sẽ được triển khai');
    }
</script>

<jsp:include page="../includes/footer.jsp" />

