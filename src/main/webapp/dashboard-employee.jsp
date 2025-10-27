<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="includes/header.jsp">
  <jsp:param name="page" value="dashboard-employee" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-employee.css">

<div class="dashboard-employee-container">
  <!-- Header Section -->


  <!-- Main Content Area -->
  <div class="main-content-grid">
    <!-- Top Row -->
    <div class="widget personal-schedule">
      <h2 class="widget-title">LỊCH CÁ NHÂN</h2>
      <div class="date-selector">
        <div class="date-box">Th11 01</div>
        <div class="date-box">Th11 02</div>
        <div class="date-box active">Th12 03</div>
        <div class="date-box">Th12 04</div>
      </div>
      <div class="schedule-list">
        <div class="schedule-item">
          <div class="schedule-title">Thiết kế giao diện Web Portal</div>
          <div class="schedule-meta">Người giao: Đăng Vũ</div>
          <div class="schedule-tag">04 Th12</div>
        </div>
        <div class="schedule-item">
          <div class="schedule-title">Seminar</div>
          <div class="schedule-meta">Lầu G, chia sẻ về cuộc đời</div>
          <div class="schedule-time">10:00AM-11:30AM</div>
        </div>
        <div class="schedule-item">
          <div class="schedule-title">Phỏng vấn</div>
          <div class="schedule-meta">Lầu 4, ứng viên Front-End</div>
          <div class="schedule-time">08:00AM-10:30AM</div>
        </div>
      </div>
    </div>

    <div class="widget work-progress">
      <h2 class="widget-title">TIẾN ĐỘ CÔNG VIỆC</h2>
      <div class="progress-summary">
        <div class="progress-stat">
          <div class="stat-value">50</div>
          <div class="stat-label">Tổng công việc</div>
        </div>
        <div class="progress-stat">
          <div class="stat-value blue">42</div>
          <div class="stat-label">Hoàn thành</div>
        </div>
      </div>
      <div class="chart-container">
        <canvas id="workProgressChart"></canvas>
      </div>
    </div>

    <div class="widget quick-actions">
      <h2 class="widget-title">THAO TÁC NHANH</h2>
      
      <!-- Primary Action Buttons -->
      <div class="action-buttons">
        <button class="btn-action purple">
          <i class='bx bx-calendar-check'></i>
          <span>Xin nghỉ phép</span>
        </button>
        <button class="btn-action red">
          <i class='bx bx-plus'></i>
          <span>Thêm tăng ca</span>
        </button>
        <button class="btn-action orange">
          <i class='bx bx-error-circle'></i>
          <span>Quên chấm công</span>
        </button>
        <button class="btn-action green">
          <i class='bx bx-briefcase'></i>
          <span>Đi công tác</span>
        </button>
      </div>
      
      <!-- Secondary Navigation Icons -->
      <div class="nav-icons-section">
        <h3 class="section-subtitle">Danh sách</h3>
        <div class="nav-icons">
          <div class="nav-icon" title="Công">
            <i class='bx bx-calendar-check'></i>
            <span>Công</span>
          </div>
          <div class="nav-icon" title="Hồ sơ cá nhân">
            <i class='bx bx-user-circle'></i>
            <span>Hồ sơ cá nhân</span>
          </div>
          <div class="nav-icon" title="DS quên chấm công">
            <i class='bx bx-search-alt'></i>
            <span>DS quên chấm công</span>
          </div>
          <div class="nav-icon" title="DS ngày nghỉ">
            <i class='bx bx-calendar-x'></i>
            <span>DS ngày nghỉ</span>
          </div>
          <div class="nav-icon" title="DS tăng ca">
            <i class='bx bx-time-five'></i>
            <span>DS tăng ca</span>
          </div>
          <div class="nav-icon" title="Xem thêm">
            <i class='bx bx-dots-horizontal-rounded'></i>
            <span>Xem thêm</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Bottom Row -->
    <div class="widget timesheet-calendar large">
      <h2 class="widget-title">LỊCH CHẤM CÔNG - KỲ CÔNG THÁNG 12</h2>
      <div class="timesheet-legend">
        <div class="legend-dot red"></div><span>Tăng ca</span>
        <div class="legend-dot gray"></div><span>Vắng mặt</span>
        <div class="legend-dot blue"></div><span>Công tác</span>
        <div class="legend-dot green"></div><span>Ca đủ công</span>
        <div class="legend-dot light-blue"></div><span>Trễ sớm</span>
        <div class="legend-dot orange"></div><span>Quên chấm công</span>
        <div class="legend-dot purple"></div><span>Nghỉ lễ</span>
      </div>
      <div class="calendar-grid">
        <div class="calendar-header">
          <div>Chủ nhật</div>
          <div>Thứ 2</div>
          <div>Thứ 3</div>
          <div>Thứ 4</div>
          <div>Thứ 5</div>
          <div>Thứ 6</div>
          <div>Thứ 7</div>
        </div>
        <div class="calendar-body">
          <div class="calendar-day"><span>4</span><div class="status-dot red"></div></div>
          <div class="calendar-day"><span>5</span><div class="status-dot green"></div></div>
          <div class="calendar-day off">OFF</div>
          <div class="calendar-day"><span>6</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>7</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>8</span><div class="status-dot light-blue"></div></div>
          <div class="calendar-day"><span>9</span><div class="status-dot blue"></div></div>
          <div class="calendar-day"><span>10</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>11</span><div class="status-dot orange"></div></div>
          <div class="calendar-day"><span>12</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>13</span><div class="status-dot gray"></div></div>
          <div class="calendar-day"><span>14</span><div class="status-dot red"></div></div>
          <div class="calendar-day"><span>15</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>16</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>17</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>18</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>19</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>20</span><div class="status-dot light-blue"></div></div>
          <div class="calendar-day"><span>21</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>22</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>23</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>24</span><div class="status-dot blue"></div></div>
          <div class="calendar-day"><span>25</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>26</span><div class="status-dot purple"></div></div>
          <div class="calendar-day"><span>27</span><div class="status-dot purple"></div></div>
          <div class="calendar-day"><span>28</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>29</span><div class="status-dot purple"></div></div>
          <div class="calendar-day"><span>30</span><div class="status-dot green"></div></div>
          <div class="calendar-day"><span>31</span><div class="status-dot green"></div></div>
        </div>
      </div>
    </div>

    <div class="widget internal-news">
      <h2 class="widget-title">TIN TỨC NỘI BỘ</h2>
      <div class="news-list">
        <div class="news-item">
          <div class="news-thumbnail">
            <i class='bx bx-handshake'></i>
          </div>
          <div class="news-content">
            <div class="news-category">Phòng nhân sự</div>
            <div class="news-title">Wellcome đồng nghiệp</div>
            <div class="news-text">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</div>
          </div>
        </div>
        <div class="news-item">
          <div class="news-thumbnail">
            <i class='bx bx-building'></i>
          </div>
          <div class="news-content">
            <div class="news-category">Hội chị em cây khế</div>
            <div class="news-title">Than thở chuyện công sở</div>
            <div class="news-text">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
// Simple line chart for work progress
document.addEventListener('DOMContentLoaded', function() {
  const canvas = document.getElementById('workProgressChart');
  if (canvas) {
    const ctx = canvas.getContext('2d');
    canvas.width = 280;
    canvas.height = 120;
    
    const data = [15, 25, 20, 30, 35, 42, 40];
    const labels = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    const maxValue = 50;
    
    ctx.strokeStyle = '#3b82f6';
    ctx.lineWidth = 2;
    ctx.beginPath();
    
    data.forEach((value, index) => {
      const x = (index * (canvas.width - 40) / (data.length - 1)) + 20;
      const y = canvas.height - 30 - (value / maxValue) * (canvas.height - 60);
      
      if (index === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    });
    
    ctx.stroke();
    
    // Draw points
    data.forEach((value, index) => {
      const x = (index * (canvas.width - 40) / (data.length - 1)) + 20;
      const y = canvas.height - 30 - (value / maxValue) * (canvas.height - 60);
      
      ctx.fillStyle = '#3b82f6';
      ctx.beginPath();
      ctx.arc(x, y, 3, 0, 2 * Math.PI);
      ctx.fill();
    });
  }
});
</script>

<jsp:include page="includes/footer.jsp" />
