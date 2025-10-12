<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="includes/header.jsp">
  <jsp:param name="page" value="schedule" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/schedule.css">

<div class="schedule-container">
  <!-- Header Section -->
  <div class="schedule-header">
    <h1>Lịch làm việc</h1>
    <div class="header-actions">
      <button class="btn btn-primary">
        <i class='bx bx-plus'></i> Thêm lịch làm việc
      </button>
    </div>
  </div>

  <!-- Main Content Area -->
  <div class="main-content">
    <!-- Schedule Content will be implemented here -->
    <div class="schedule-content">
      <div class="empty-state">
        <i class='bx bx-calendar'></i>
        <h3>Chưa có lịch làm việc</h3>
        <p>Bắt đầu tạo lịch làm việc cho nhân viên của bạn</p>
      </div>
    </div>
  </div>
</div>

<jsp:include page="includes/footer.jsp" />

<style>
.schedule-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.schedule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #e0e0e0;
}

.schedule-header h1 {
  font-size: 28px;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0;
}

.header-actions .btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.header-actions .btn:hover {
  background: #0056b3;
}

.main-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 40px;
}

.schedule-content {
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-state {
  text-align: center;
  color: #666;
}

.empty-state i {
  font-size: 64px;
  color: #ccc;
  margin-bottom: 20px;
}

.empty-state h3 {
  font-size: 20px;
  font-weight: 600;
  margin: 0 0 10px 0;
  color: #333;
}

.empty-state p {
  font-size: 16px;
  margin: 0;
  color: #666;
}
</style>
