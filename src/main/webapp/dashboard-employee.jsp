<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.DayOfWeek" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.liteflow.model.timesheet.EmployeeAttendance" %>

<jsp:include page="includes/header.jsp">
  <jsp:param name="page" value="dashboard-employee" />
</jsp:include>

<%
// Lấy thông tin tháng hiện tại
Integer currentYear = (Integer) request.getAttribute("currentYear");
Integer currentMonth = (Integer) request.getAttribute("currentMonth");
Map<Integer, EmployeeAttendance> attendanceMap = (Map<Integer, EmployeeAttendance>) request.getAttribute("attendanceMap");

if (currentYear == null) currentYear = LocalDate.now().getYear();
if (currentMonth == null) currentMonth = LocalDate.now().getMonthValue();
if (attendanceMap == null) attendanceMap = new java.util.HashMap<>();

LocalDate firstDay = LocalDate.of(currentYear, currentMonth, 1);
int daysInMonth = firstDay.lengthOfMonth();
DayOfWeek firstDayOfWeek = firstDay.getDayOfWeek();
// Java DayOfWeek: Monday=1, Tuesday=2, ..., Sunday=7
// Calendar header: Sunday=0, Monday=1, ..., Saturday=6
// Nếu getValue()=7 (Sunday) → offset=0, nếu getValue()=1 (Monday) → offset=1
int offset = firstDayOfWeek.getValue() % 7;

// Tên tháng tiếng Việt
String[] monthNames = {"Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6", 
                      "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"};
%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-employee.css">

<div class="dashboard-employee-container">
  <!-- Header Section -->


  <!-- Main Content Area -->
  <div class="main-content-grid">
    <!-- Top Row -->
    <div class="widget personal-schedule">
      <div class="widget-title-row">
        <h2 class="widget-title">LỊCH CÁ NHÂN</h2>
        <button class="btn-add-schedule" id="btnAddSchedule" type="button">
          <i class='bx bx-plus'></i> Thêm mới
        </button>
      </div>
      <div class="schedule-list" id="personalScheduleList">
        <!-- Dữ liệu sẽ được load từ API -->
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
      <h2 class="widget-title">LỊCH CHẤM CÔNG - KỲ CÔNG <%= monthNames[currentMonth - 1] %> <%= currentYear %></h2>
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
<%
// Tạo calendar
// Offset đầu tháng (fill empty cells)
for (int i = 0; i < offset; i++) {
%>
          <div class="calendar-day empty"></div>
<%
}

// Tạo các ngày trong tháng
for (int day = 1; day <= daysInMonth; day++) {
    EmployeeAttendance attendance = attendanceMap.get(day);
    String statusDot = "gray"; // Mặc định là vắng mặt (gray)
    
    if (attendance != null) {
        Boolean isOvertime = attendance.getIsOvertime();
        Boolean isLate = attendance.getIsLate();
        Boolean isEarlyLeave = attendance.getIsEarlyLeave();
        
        if (isOvertime != null && isOvertime) {
            statusDot = "red"; // Tăng ca
        } else if (isLate != null && isLate && isEarlyLeave != null && isEarlyLeave) {
            statusDot = "light-blue"; // Trễ và sớm
        } else if (isLate != null && isLate) {
            statusDot = "light-blue"; // Trễ
        } else if (isEarlyLeave != null && isEarlyLeave) {
            statusDot = "light-blue"; // Sớm
        } else if (attendance.getCheckInTime() != null && attendance.getCheckOutTime() != null) {
            statusDot = "green"; // Ca đủ công
        } else {
            statusDot = "orange"; // Quên chấm công
        }
    }
    
    LocalDate today = LocalDate.now();
    boolean isToday = (day == today.getDayOfMonth() && 
                        currentMonth == today.getMonthValue() && 
                        currentYear == today.getYear());
    
    String todayClass = isToday ? " today" : "";
%>
          <div class="calendar-day<%= todayClass %>">
            <span><%= day %></span>
            <div class="status-dot <%= statusDot %>"></div>
          </div>
<%
}
%>
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
// Context path for API calls
const CONTEXT_PATH = '<c:out value="${pageContext.request.contextPath}" />';

// Global variable
let currentEditingSchedule = null;

// Helper function to escape HTML
function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// Priority sort order: High -> Medium -> Low
function getPriorityOrder(priority) {
  switch(priority) {
    case 'High': return 1;
    case 'Medium': return 2;
    case 'Low': return 3;
    default: return 4;
  }
}

// Format date to Vietnamese format
function formatDate(dateString) {
  if (!dateString) return '';
  const date = new Date(dateString + 'T00:00:00');
  const days = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
  const dayName = days[date.getDay()];
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  return `${dayName}, ${day}/${month}/${date.getFullYear()}`;
}

// Open add schedule modal - MUST be available immediately
function openAddScheduleModal() {
  console.log('=== openAddScheduleModal called ===');
  try {
    currentEditingSchedule = null;
    
    // Reset form fields
    const modalScheduleId = document.getElementById('modalScheduleId');
    const modalTitle = document.getElementById('modalTitle');
    const modalDescription = document.getElementById('modalDescription');
    const modalStartDate = document.getElementById('modalStartDate');
    const modalStartTime = document.getElementById('modalStartTime');
    const modalEndTime = document.getElementById('modalEndTime');
    const modalPriority = document.getElementById('modalPriority');
    const scheduleModalTitle = document.getElementById('scheduleModalTitle');
    const scheduleModal = document.getElementById('scheduleModal');
    
    console.log('Modal element:', scheduleModal);
    console.log('Title element:', modalTitle);
    
    if (!scheduleModal) {
      console.error('❌ Modal element not found!');
      alert('Không thể mở form. Modal element không tồn tại. Vui lòng tải lại trang.');
      return;
    }
    
    // Reset form
    if (modalScheduleId) modalScheduleId.value = '';
    if (modalTitle) modalTitle.value = '';
    if (modalDescription) modalDescription.value = '';
    if (modalStartDate) {
      modalStartDate.value = '';
      // Set default to today
      const today = new Date().toISOString().split('T')[0];
      modalStartDate.value = today;
    }
    if (modalStartTime) modalStartTime.value = '';
    if (modalEndTime) modalEndTime.value = '';
    if (modalPriority) modalPriority.value = 'Medium';
    if (scheduleModalTitle) scheduleModalTitle.textContent = 'Thêm lịch cá nhân';
    
    // Show modal
    scheduleModal.style.display = 'flex';
    scheduleModal.style.zIndex = '10000';
    scheduleModal.style.visibility = 'visible';
    scheduleModal.style.opacity = '1';
    
    console.log('✅ Modal display:', scheduleModal.style.display);
    console.log('✅ Modal opened successfully');
    
    // Focus on title input after a short delay
    if (modalTitle) {
      setTimeout(() => {
        modalTitle.focus();
        console.log('✅ Focused on title input');
      }, 100);
    }
  } catch (error) {
    console.error('❌ Error opening modal:', error);
    console.error('Error stack:', error.stack);
    alert('Có lỗi xảy ra khi mở form: ' + error.message);
  }
}

// Make functions available globally immediately
window.openAddScheduleModal = openAddScheduleModal;
window.saveSchedule = saveSchedule;
window.editSchedule = editSchedule;
window.deleteSchedule = deleteSchedule;
window.closeScheduleModal = closeScheduleModal;

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

// ==============================
// Personal Schedule Functions
// ==============================

// Load personal schedules
async function loadPersonalSchedules() {
  try {
    const response = await fetch(CONTEXT_PATH + '/api/personal-schedule/');
    if (!response.ok) throw new Error('Failed to load schedules');
    
    const schedules = await response.json();
    const scheduleList = document.getElementById('personalScheduleList');
    
    if (schedules.length === 0) {
      scheduleList.innerHTML = '<div class="empty-state">Chưa có lịch cá nhân nào. Nhấn "Thêm mới" để tạo lịch.</div>';
      return;
    }
    
    // Sort schedules: by priority first (High -> Medium -> Low), then by date
    schedules.sort((a, b) => {
      const priorityDiff = getPriorityOrder(a.priority) - getPriorityOrder(b.priority);
      if (priorityDiff !== 0) return priorityDiff;
      // If same priority, sort by date (earlier dates first)
      return new Date(a.startDate) - new Date(b.startDate);
    });
    
    scheduleList.innerHTML = schedules.map(schedule => {
      const priorityClass = schedule.priority.toLowerCase();
      const priorityLabel = schedule.priority === 'High' ? 'Cao' : schedule.priority === 'Medium' ? 'Trung bình' : 'Thấp';
      
      // Format date
      const dateDisplay = formatDate(schedule.startDate);
      
      // Format time
      let timeDisplay = '';
      if (schedule.startTime || schedule.endTime) {
        const startTime = schedule.startTime ? schedule.startTime.substring(0, 5) : '';
        const endTime = schedule.endTime ? schedule.endTime.substring(0, 5) : '';
        timeDisplay = startTime + (endTime ? ' - ' + endTime : '');
      }
      
      let html = '<div class="schedule-item priority-' + priorityClass + '" data-id="' + schedule.scheduleId + '" data-priority="' + schedule.priority + '">';
      html += '<div class="schedule-header">';
      html += '<div class="schedule-title">' + escapeHtml(schedule.title) + '</div>';
      html += '<div class="schedule-actions">';
      html += '<button class="btn-edit-schedule" onclick="editSchedule(\'' + schedule.scheduleId + '\')" title="Sửa">';
      html += '<i class=\'bx bx-edit\'></i>';
      html += '</button>';
      html += '<button class="btn-delete-schedule" onclick="deleteSchedule(\'' + schedule.scheduleId + '\')" title="Xóa">';
      html += '<i class=\'bx bx-trash\'></i>';
      html += '</button>';
      html += '</div>';
      html += '</div>';
      
      if (schedule.description) {
        html += '<div class="schedule-meta">' + escapeHtml(schedule.description) + '</div>';
      }
      
      html += '<div class="schedule-footer">';
      html += '<span class="schedule-priority priority-' + priorityClass + '">' + priorityLabel + '</span>';
      if (dateDisplay) {
        html += '<span class="schedule-date">' + escapeHtml(dateDisplay) + '</span>';
      }
      if (timeDisplay) {
        html += '<span class="schedule-time">' + escapeHtml(timeDisplay) + '</span>';
      }
      html += '</div>';
      html += '</div>';
      
      return html;
    }).join('');
  } catch (error) {
    console.error('Error loading schedules:', error);
    document.getElementById('personalScheduleList').innerHTML = '<div class="error-state">Lỗi khi tải lịch cá nhân</div>';
  }
}

// Edit schedule
function editSchedule(scheduleId) {
  fetch(CONTEXT_PATH + '/api/personal-schedule/' + scheduleId)
    .then(res => res.json())
    .then(schedule => {
      currentEditingSchedule = schedule;
      document.getElementById('modalScheduleId').value = schedule.scheduleId;
      document.getElementById('modalTitle').value = schedule.title;
      document.getElementById('modalDescription').value = schedule.description || '';
      document.getElementById('modalStartDate').value = schedule.startDate;
      document.getElementById('modalStartTime').value = schedule.startTime || '';
      document.getElementById('modalEndTime').value = schedule.endTime || '';
      document.getElementById('modalPriority').value = schedule.priority;
      document.getElementById('scheduleModalTitle').textContent = 'Sửa lịch cá nhân';
      document.getElementById('scheduleModal').style.display = 'flex';
    })
    .catch(err => {
      console.error('Error loading schedule:', err);
      alert('Không thể tải thông tin lịch');
    });
}

// Delete schedule
async function deleteSchedule(scheduleId) {
  if (!confirm('Bạn có chắc chắn muốn xóa lịch này?')) return;
  
  try {
    const response = await fetch(CONTEXT_PATH + '/api/personal-schedule/' + scheduleId, {
      method: 'DELETE'
    });
    
    if (!response.ok) throw new Error('Failed to delete schedule');
    
    alert('Xóa lịch thành công');
    loadPersonalSchedules();
  } catch (error) {
    console.error('Error deleting schedule:', error);
    alert('Không thể xóa lịch');
  }
}

// Save schedule
async function saveSchedule() {
  const title = document.getElementById('modalTitle').value.trim();
  const description = document.getElementById('modalDescription').value.trim();
  const startDate = document.getElementById('modalStartDate').value;
  const startTime = document.getElementById('modalStartTime').value;
  const endTime = document.getElementById('modalEndTime').value;
  const priority = document.getElementById('modalPriority').value;
  
  if (!title || !startDate) {
    alert('Vui lòng điền đầy đủ thông tin bắt buộc');
    return;
  }
  
  const formData = new URLSearchParams();
  formData.append('title', title);
  formData.append('description', description);
  formData.append('startDate', startDate);
  if (startTime) formData.append('startTime', startTime);
  if (endTime) formData.append('endTime', endTime);
  formData.append('priority', priority);
  
  try {
    let response;
    if (currentEditingSchedule) {
      // Update existing schedule
      response = await fetch(CONTEXT_PATH + '/api/personal-schedule/' + currentEditingSchedule.scheduleId, {
        method: 'PUT',
        body: formData
      });
    } else {
      // Create new schedule
      response = await fetch(CONTEXT_PATH + '/api/personal-schedule/', {
        method: 'POST',
        body: formData
      });
    }
    
    if (!response.ok) throw new Error('Failed to save schedule');
    
    alert(currentEditingSchedule ? 'Cập nhật lịch thành công' : 'Thêm lịch thành công');
    document.getElementById('scheduleModal').style.display = 'none';
    loadPersonalSchedules();
  } catch (error) {
    console.error('Error saving schedule:', error);
    alert('Không thể lưu lịch');
  }
}

// Close modal
function closeScheduleModal() {
  const scheduleModal = document.getElementById('scheduleModal');
  if (scheduleModal) {
    scheduleModal.style.display = 'none';
  }
}

// Close modal when clicking outside
function setupModalCloseOnOutsideClick() {
  const modal = document.getElementById('scheduleModal');
  if (modal) {
    modal.addEventListener('click', function(e) {
      if (e.target === modal) {
        closeScheduleModal();
      }
    });
  }
}

// Load schedules when page loads
document.addEventListener('DOMContentLoaded', function() {
  console.log('DOMContentLoaded - Setting up schedule functions');
  
  // Setup button click event
  const btnAddSchedule = document.getElementById('btnAddSchedule');
  if (btnAddSchedule) {
    btnAddSchedule.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      console.log('Add button clicked');
      openAddScheduleModal();
    });
    console.log('Add button event listener attached');
  } else {
    console.error('btnAddSchedule button not found!');
  }
  
  loadPersonalSchedules();
  setupModalCloseOnOutsideClick();
  
  console.log('All schedule functions initialized');
});
</script>

<!-- Schedule Modal -->
<div id="scheduleModal" class="modal-overlay" style="display: none; z-index: 10000;">
  <div class="modal-content" onclick="event.stopPropagation();">
    <div class="modal-header">
      <h3 id="scheduleModalTitle">Thêm lịch cá nhân</h3>
      <button class="modal-close" onclick="closeScheduleModal()">
        <i class='bx bx-x'></i>
      </button>
    </div>
    <div class="modal-body">
      <input type="hidden" id="modalScheduleId" />
      
      <div class="form-group">
        <label>Tên công việc <span class="required">*</span></label>
        <input type="text" id="modalTitle" class="form-control" placeholder="Nhập tên công việc" required />
      </div>
      
      <div class="form-group">
        <label>Mô tả</label>
        <textarea id="modalDescription" class="form-control" rows="3" placeholder="Nhập mô tả chi tiết"></textarea>
      </div>
      
      <div class="form-group">
        <label>Ngày <span class="required">*</span></label>
        <input type="date" id="modalStartDate" class="form-control" required />
      </div>
      
      <div class="form-row">
        <div class="form-group">
          <label>Giờ bắt đầu</label>
          <input type="time" id="modalStartTime" class="form-control" />
        </div>
        <div class="form-group">
          <label>Giờ kết thúc</label>
          <input type="time" id="modalEndTime" class="form-control" />
        </div>
      </div>
      
      <div class="form-group">
        <label>Mức độ ưu tiên</label>
        <select id="modalPriority" class="form-control">
          <option value="Low">Thấp</option>
          <option value="Medium" selected>Trung bình</option>
          <option value="High">Cao</option>
        </select>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn-cancel" onclick="closeScheduleModal()">Hủy</button>
      <button class="btn-save" onclick="saveSchedule()">Lưu</button>
    </div>
  </div>
</div>

<jsp:include page="includes/footer.jsp" />
