<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="includes/header.jsp">
  <jsp:param name="page" value="attendance" />
  <jsp:param name="pageTitle" value="Bảng chấm công" />
  <jsp:param name="pageDescription" value="Theo dõi trạng thái chấm công theo ca" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/schedule.css">

<div class="schedule-container">
  <div class="schedule-header">
    <h1>Bảng chấm công</h1>
    <div class="header-actions" style="display:flex; align-items:center; gap:12px; flex-wrap:nowrap;">
      <form method="get" action="${pageContext.request.contextPath}/attendance" style="display:flex; align-items:center; gap:8px; flex-wrap:nowrap; background:#fff; padding:8px 12px; border:1px solid #e5e7eb; border-radius:10px;">
        <input type="hidden" name="weekStart" value="${currentWeekStart}" />
        <select name="employeeCode" style="width:220px; padding:8px 10px; border:1px solid #e5e7eb; border-radius:8px;">
          <option value="">Chọn nhân viên</option>
          <c:forEach var="e" items="${employees}">
            <option value="${e.employeeCode}" <c:if test='${selectedEmployeeCode == e.employeeCode}'>selected</c:if>>${e.employeeCode} - ${e.fullName}</option>
          </c:forEach>
        </select>
        <button type="submit" class="btn btn-primary" title="Tìm kiếm" style="display:flex; align-items:center; justify-content:center; width:40px; height:36px; padding:0;">
          <i class='bx bx-search'></i>
        </button>
        <a href="${pageContext.request.contextPath}/attendance?weekStart=${currentWeekStart}" class="btn btn-light" title="Hủy lọc" style="display:flex; align-items:center; justify-content:center; width:36px; height:36px; padding:0;">
          <i class='bx bx-filter-alt-off'></i>
        </a>
      </form>
      <div class="schedule-toolbar" style="margin: 0 12px 0 0;">
        <div class="week-chip" id="weekChip">
          <a class="chip-btn prev" href="${pageContext.request.contextPath}/attendance?weekStart=${prevWeekStart}${filterQuery}"><i class='bx bx-chevron-left'></i></a>
          <button type="button" class="chip-label">${controlLabel}</button>
          <a class="chip-btn next" href="${pageContext.request.contextPath}/attendance?weekStart=${nextWeekStart}${filterQuery}"><i class='bx bx-chevron-right'></i></a>
        </div>
        <a class="btn btn-light" href="${pageContext.request.contextPath}/attendance?weekStart=${currentWeekStart}${filterQuery}">Tuần này</a>
      </div>
    </div>
  </div>

  <div class="main-content">
    <div class="schedule-table">
      <table class="schedule-grid">
        <thead>
          <tr>
            <th class="time-col">Ca làm việc</th>
            <c:forEach var="d" items="${weekDays}">
              <th><span>${d.label}</span><small class="date">${d.dateStr}</small></th>
            </c:forEach>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="t" items="${templates}">
            <tr>
              <td class="time-col">
                <div class="slot-title">${t.name}</div>
                <div class="slot-time">${t.startTime.toString().substring(0,5)} - ${t.endTime.toString().substring(0,5)}</div>
              </td>
              <c:forEach var="d" items="${weekDays}">
                <td class="schedule-cell">
                  <c:forEach var="row" items="${d.rows}">
                    <c:if test="${row.templateName == t.name}">
                      <c:choose>
                        <c:when test="${empty row.items}">
                          <div class="empty-day">—</div>
                        </c:when>
                        <c:otherwise>
                          <c:forEach var="item" items="${row.items}">
                            <c:set var="attStatus" value="${empty item.attendanceStatus ? item.status : item.attendanceStatus}" />
                            <div class="shift-block" title="${item.employee}"
                              data-employee="${item.employee}"
                              data-employee-code="${item.employeeCode}"
                              data-status="${item.status}"
                              data-att-status="${attStatus}"
                              data-date="${d.dateStr}"
                              data-template-name="${t.name}"
                              data-start-time="${t.startTime.toString().substring(0,5)}"
                              data-end-time="${t.endTime.toString().substring(0,5)}"
                              data-check-in-at="${item.checkInAt}"
                              data-check-out-at="${item.checkOutAt}"
                              data-source="${item.source}">
                              <div class="shift-emp">${item.employee}</div>
                              <div class="shift-status">
                                <c:choose>
                                  <c:when test="${attStatus == 'Work' || attStatus == 'Approved'}">
                                    <span class="badge" style="background:#dcfce7;color:#166534;border:1px solid #86efac;">Đi làm</span>
                                  </c:when>
                                  <c:when test="${attStatus == 'LeavePaid'}">
                                    <span class="badge" style="background:#e0f2fe;color:#075985;border:1px solid #bae6fd;">Nghỉ có phép</span>
                                  </c:when>
                                  <c:when test="${attStatus == 'LeaveUnpaid'}">
                                    <span class="badge" style="background:#fee2e2;color:#991b1b;border:1px solid #fecaca;">Nghỉ không phép</span>
                                  </c:when>
                                  <c:otherwise>
                                    <span class="badge" style="background:#fef9c3;color:#854d0e;border:1px solid #fde68a;">Chưa xác định</span>
                                  </c:otherwise>
                                </c:choose>
                              </div>
                              <c:if test="${not empty item.checkInAt}">
                                <div class="shift-time" style="color:#6b7280; font-size:12px;">${item.checkInAt} - ${item.checkOutAt}</div>
                              </c:if>
                            </div>
                          </c:forEach>
                        </c:otherwise>
                      </c:choose>
                    </c:if>
                  </c:forEach>
                </td>
              </c:forEach>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<jsp:include page="includes/footer.jsp" />


<!-- Shift Detail Modal for Attendance -->
<div id="attShiftDetailOverlay" style="position:fixed; inset:0; background:rgba(0,0,0,.45); display:none; align-items:center; justify-content:center; z-index:1000;">
  <div style="background:#fff; width:95%; max-width:720px; border-radius:10px; box-shadow:0 10px 30px rgba(0,0,0,0.2); overflow:hidden;">
    <div style="display:flex; align-items:center; justify-content:space-between; padding:16px 20px; border-bottom:1px solid #eee;">
      <h3 style="margin:0; font-size:18px; font-weight:600;">Chi tiết ca làm</h3>
      <button type="button" id="attCloseShiftDetail" class="btn btn-light">Đóng</button>
    </div>
    <div style="padding:16px 20px;">
      <!-- Tab headers -->
      <div id="attTabs" style="display:flex; gap:8px; border-bottom:1px solid #e5e7eb;">
        <button class="att-tab att-tab-active" data-tab="overview" style="padding:8px 12px; border:none; background:transparent; border-bottom:2px solid #3b82f6; color:#1f2937; cursor:pointer;">Tổng quan</button>
        <button class="att-tab" data-tab="history" style="padding:8px 12px; border:none; background:transparent; color:#6b7280; cursor:pointer;">Lịch sử chấm công</button>
        <button class="att-tab" data-tab="penalty" style="padding:8px 12px; border:none; background:transparent; color:#6b7280; cursor:pointer;">Phạt vi phạm</button>
        <button class="att-tab" data-tab="bonus" style="padding:8px 12px; border:none; background:transparent; color:#6b7280; cursor:pointer;">Thưởng</button>
      </div>

      <!-- Tab panels -->
      <div id="attTabPanels" style="padding-top:12px;">
        <!-- Overview -->
        <div class="att-panel" data-panel="overview" style="display:block;">
          <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px 16px;">
            <div><label style="font-size:12px; color:#6b7280;">Nhân viên</label><div id="attSdEmployee" style="margin-top:6px; font-weight:600;"></div></div>
            <div>
              <label style="font-size:12px; color:#6b7280;">Trạng thái</label>
              <select id="attStatusSelect" name="status" form="attSaveForm" style="margin-top:6px; width:100%; padding:8px 10px; border:1px solid #e5e7eb; border-radius:8px;">
                <option value="">Chọn trạng thái</option>
                <option value="work">Đi làm</option>
                <option value="leave_paid">Nghỉ có phép</option>
                <option value="leave_unpaid">Nghỉ không phép</option>
              </select>
            </div>
            <div><label style="font-size:12px; color:#6b7280;">Ngày</label><div id="attSdDate" style="margin-top:6px;"></div></div>
            <div><label style="font-size:12px; color:#6b7280;">Ca</label><div id="attSdTemplate" style="margin-top:6px;"></div></div>
            <div><label style="font-size:12px; color:#6b7280;">Giờ ca</label><div id="attSdShiftTime" style="margin-top:6px;"></div></div>
            <div><label style="font-size:12px; color:#6b7280;">Chấm công</label><div id="attSdCheckTime" style="margin-top:6px;"></div></div>
            <div id="attWorkTimeRow" style="grid-column:1 / -1; display:none;">
              <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px 16px;">
                <div>
                  <label for="attCheckInInput" style="font-size:12px; color:#6b7280;">Giờ vào</label>
                  <input id="attCheckInInput" name="checkIn" form="attSaveForm" type="time" style="margin-top:6px; width:100%; padding:8px 10px; border:1px solid #e5e7eb; border-radius:8px;" />
                </div>
                <div>
                  <label for="attCheckOutInput" style="font-size:12px; color:#6b7280;">Giờ ra</label>
                  <input id="attCheckOutInput" name="checkOut" form="attSaveForm" type="time" style="margin-top:6px; width:100%; padding:8px 10px; border:1px solid #e5e7eb; border-radius:8px;" />
                </div>
              </div>
            </div>
            <div style="grid-column:1 / -1; margin-top:12px; display:flex; gap:8px; justify-content:flex-end;">
              <form id="attSaveForm" method="post" action="${pageContext.request.contextPath}/attendance" style="margin:0;">
                <input type="hidden" name="action" value="save" />
                <input type="hidden" name="weekStart" value="${currentWeekStart}" />
                <input type="hidden" name="employeeCode" id="attFormEmployeeCode" />
                <input type="hidden" name="date" id="attFormDate" />
                <input type="hidden" name="redirectEmployeeCode" value="${selectedEmployeeCode}" />
                <button type="submit" class="btn btn-primary">Lưu trạng thái</button>
              </form>
            </div>
          </div>
        </div>

        <!-- Attendance history -->
        <div class="att-panel" data-panel="history" style="display:none;">
          <div id="attHistoryEmpty" style="font-size:13px; color:#6b7280;">Chưa có dữ liệu lịch sử.</div>
          <div id="attHistoryList" style="display:none; max-height:260px; overflow:auto; border:1px solid #e5e7eb; border-radius:8px;">
            <table style="width:100%; border-collapse:collapse; font-size:13px;">
              <thead>
                <tr style="background:#f9fafb; text-align:left;">
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Ngày</th>
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Check-in</th>
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Check-out</th>
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Ghi chú</th>
                </tr>
              </thead>
              <tbody id="attHistoryTbody"></tbody>
            </table>
          </div>
        </div>

        <!-- Penalties -->
        <div class="att-panel" data-panel="penalty" style="display:none;">
          <div id="attPenaltyEmpty" style="font-size:13px; color:#6b7280;">Không có vi phạm nào.</div>
          <div id="attPenaltyList" style="display:none; max-height:260px; overflow:auto; border:1px solid #e5e7eb; border-radius:8px;">
            <table style="width:100%; border-collapse:collapse; font-size:13px;">
              <thead>
                <tr style="background:#f9fafb; text-align:left;">
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Ngày</th>
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Lý do</th>
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Số tiền</th>
                </tr>
              </thead>
              <tbody id="attPenaltyTbody"></tbody>
            </table>
          </div>
        </div>

        <!-- Bonuses -->
        <div class="att-panel" data-panel="bonus" style="display:none;">
          <div id="attBonusEmpty" style="font-size:13px; color:#6b7280;">Chưa có thưởng nào.</div>
          <div id="attBonusList" style="display:none; max-height:260px; overflow:auto; border:1px solid #e5e7eb; border-radius:8px;">
            <table style="width:100%; border-collapse:collapse; font-size:13px;">
              <thead>
                <tr style="background:#f9fafb; text-align:left;">
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Ngày</th>
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Lý do</th>
                  <th style="padding:8px 10px; border-bottom:1px solid #e5e7eb;">Số tiền</th>
                </tr>
              </thead>
              <tbody id="attBonusTbody"></tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
  
</div>

<script>
(function(){
  function setText(id, v){ var el = document.getElementById(id); if (el) el.textContent = v || ''; }
  function open(){ var ov = document.getElementById('attShiftDetailOverlay'); if (ov) ov.style.display = 'flex'; }
  function close(){ var ov = document.getElementById('attShiftDetailOverlay'); if (ov) ov.style.display = 'none'; }
  var closeBtn = document.getElementById('attCloseShiftDetail');
  if (closeBtn) closeBtn.addEventListener('click', close);
  var overlay = document.getElementById('attShiftDetailOverlay');
  if (overlay) overlay.addEventListener('click', function(e){ if (e.target === overlay) close(); });
  document.addEventListener('keydown', function(e){ if (e.key === 'Escape') close(); });

  // Tabs wiring
  function activateTab(name){
    var tabs = Array.prototype.slice.call(document.querySelectorAll('#attTabs .att-tab'));
    var panels = Array.prototype.slice.call(document.querySelectorAll('#attTabPanels .att-panel'));
    tabs.forEach(function(t){
      var isActive = t.getAttribute('data-tab') === name;
      t.className = 'att-tab' + (isActive ? ' att-tab-active' : '');
      // inline style updates for bottom border and colors
      if (isActive) {
        t.style.borderBottom = '2px solid #3b82f6';
        t.style.color = '#1f2937';
      } else {
        t.style.borderBottom = '2px solid transparent';
        t.style.color = '#6b7280';
      }
    });
    panels.forEach(function(p){ p.style.display = (p.getAttribute('data-panel') === name) ? 'block' : 'none'; });
  }
  document.addEventListener('click', function(e){
    var tabBtn = e.target.closest('#attTabs .att-tab');
    if (tabBtn) {
      var name = tabBtn.getAttribute('data-tab');
      if (name) activateTab(name);
    }
  });

  document.addEventListener('click', function(e){
    var block = e.target.closest('.shift-block');
    if (!block) return;
    // Extract attributes populated on the block
    var emp = block.getAttribute('data-employee') || '';
    var status = block.getAttribute('data-status') || '';
    var att = block.getAttribute('data-att-status') || '';
    var date = block.getAttribute('data-date') || '';
    var tmpl = block.getAttribute('data-template-name') || '';
    var s = block.getAttribute('data-start-time') || '';
    var en = block.getAttribute('data-end-time') || '';
    var ci = block.getAttribute('data-check-in-at') || '';
    var co = block.getAttribute('data-check-out-at') || '';
    var src = block.getAttribute('data-source') || '';
    var empCode = block.getAttribute('data-employee-code') || block.getAttribute('data-emp-code') || '';

    // Populate overview
    setText('attSdEmployee', emp);
    setText('attSdDate', date);
    setText('attSdTemplate', tmpl);
    setText('attSdShiftTime', (s && en) ? (s + ' - ' + en) : '');
    setText('attSdCheckTime', (ci && co) ? (ci + ' - ' + co) : (ci ? (ci + ' - —') : ''));

    // Initialize status dropdown
    var sel = document.getElementById('attStatusSelect');
    var workRow = document.getElementById('attWorkTimeRow');
    var inInput = document.getElementById('attCheckInInput');
    var outInput = document.getElementById('attCheckOutInput');
    if (sel) {
      if (att) {
        // Prefer new DB-driven attendance status
        if (att === 'Work') sel.value = 'work';
        else if (att === 'LeavePaid') sel.value = 'leave_paid';
        else if (att === 'LeaveUnpaid') sel.value = 'leave_unpaid';
        else sel.value = '';
      } else {
        // Fallback to legacy mapping
        var normalized = (status || '').toLowerCase();
        if (normalized.indexOf('approved') !== -1 || normalized.indexOf('đã duyệt') !== -1 || normalized.indexOf('chờ') !== -1 || ci) {
          sel.value = 'work';
        } else if (normalized.indexOf('paid') !== -1 || normalized.indexOf('có phép') !== -1) {
          sel.value = 'leave_paid';
        } else if (normalized.indexOf('unpaid') !== -1 || normalized.indexOf('không phép') !== -1) {
          sel.value = 'leave_unpaid';
        } else {
          sel.value = '';
        }
      }
    }
    if (inInput) inInput.value = (ci && ci.length >= 5) ? ci.substring(0,5) : '';
    if (outInput) outInput.value = (co && co.length >= 5) ? co.substring(0,5) : '';
    if (workRow) workRow.style.display = (sel && sel.value === 'work') ? 'block' : 'none';

    // Fill form hidden fields
    var formEmp = document.getElementById('attFormEmployeeCode');
    var formDate = document.getElementById('attFormDate');
    if (formEmp) formEmp.value = (block.getAttribute('data-employee-code') || '');
    // Convert dd/MM to yyyy-MM-dd using current/selected week year from URL if present
    if (formDate) {
      var parts = (date || '').split('/');
      if (parts.length === 2) {
        var urlParams = new URLSearchParams(window.location.search);
        var weekStart = urlParams.get('weekStart');
        var year = new Date().getFullYear();
        if (weekStart) { var wsDate = new Date(weekStart); if (!isNaN(wsDate.getTime())) { year = wsDate.getFullYear(); } }
        formDate.value = year + '-' + parts[1] + '-' + parts[0];
      } else {
        formDate.value = '';
      }
    }

    // Reset secondary tabs to empty state (placeholder demo)
    var histEmpty = document.getElementById('attHistoryEmpty');
    var histList = document.getElementById('attHistoryList');
    var histBody = document.getElementById('attHistoryTbody');
    if (histEmpty && histList && histBody) { histEmpty.style.display = 'block'; histList.style.display = 'none'; histBody.innerHTML = ''; }

    var penEmpty = document.getElementById('attPenaltyEmpty');
    var penList = document.getElementById('attPenaltyList');
    var penBody = document.getElementById('attPenaltyTbody');
    if (penEmpty && penList && penBody) { penEmpty.style.display = 'block'; penList.style.display = 'none'; penBody.innerHTML = ''; }

    var bonEmpty = document.getElementById('attBonusEmpty');
    var bonList = document.getElementById('attBonusList');
    var bonBody = document.getElementById('attBonusTbody');
    if (bonEmpty && bonList && bonBody) { bonEmpty.style.display = 'block'; bonList.style.display = 'none'; bonBody.innerHTML = ''; }

    // Default to Overview tab each time open
    activateTab('overview');

    // Build history table rows with status evaluation (đúng giờ / muộn / về sớm / tăng ca)
    var histEmpty = document.getElementById('attHistoryEmpty');
    var histList = document.getElementById('attHistoryList');
    var histBody = document.getElementById('attHistoryTbody');
    if (histEmpty && histList && histBody) {
      histBody.innerHTML = '';
      var haveAny = false;
      function addRow(timeStr, statusLabel, methodLabel, content) {
        var tr = document.createElement('tr');
        var td1 = document.createElement('td'); td1.style.padding = '8px 10px'; td1.textContent = timeStr || '';
        var td2 = document.createElement('td'); td2.style.padding = '8px 10px'; td2.textContent = statusLabel || '';
        var td3 = document.createElement('td'); td3.style.padding = '8px 10px'; td3.textContent = methodLabel || '';
        var td4 = document.createElement('td'); td4.style.padding = '8px 10px'; td4.textContent = content || '';
        tr.appendChild(td1); tr.appendChild(td2); tr.appendChild(td3); tr.appendChild(td4);
        histBody.appendChild(tr);
        haveAny = true;
      }

      var method = '—';
      if (src) {
        if (src === 'Auto') method = 'Chấm công tự động';
        else if (src === 'Manual') method = 'Chấm công thủ công';
        else if (src === 'Import') method = 'Chấm công bằng máy chấm công';
        else method = src;
      }
      var contentBase = 'Giờ ca: ' + (s && en ? (s + ' - ' + en) : '—');

      function toMinutes(hhmm){
        if (!hhmm) return null;
        // Try HH:mm first
        if (/^\d{2}:\d{2}$/.test(hhmm)) {
          var p = hhmm.split(':');
          return parseInt(p[0],10)*60 + parseInt(p[1],10);
        }
        // Try Date string
        var d = new Date(hhmm);
        if (!isNaN(d.getTime())) return d.getHours()*60 + d.getMinutes();
        // Try substring
        if (hhmm.length >= 5 && hhmm.indexOf(':') === 2) {
          var p2 = hhmm.substring(0,5).split(':');
          return parseInt(p2[0],10)*60 + parseInt(p2[1],10);
        }
        return null;
      }
      function fmtDuration(mins){
        var m = Math.abs(mins|0); var h = Math.floor(m/60); var r = m%60;
        return h + ' giờ ' + r + ' phút';
      }

      var startM = toMinutes(s);
      var endM = toMinutes(en);
      var inM = toMinutes(ci);
      var outM = toMinutes(co);

      // Check-in row with status
      if (inM != null && startM != null) {
        var statusIn;
        if (inM === startM) statusIn = 'Đúng giờ';
        else if (inM > startM) statusIn = 'Muộn ' + fmtDuration(inM - startM);
        else statusIn = 'Tăng ca ' + fmtDuration(startM - inM); // đến sớm
        addRow((ci && ci.substring ? ci.substring(0,5) : ci), statusIn, method, contentBase);
      } else if (ci) {
        addRow(ci, 'Đã chấm công vào', method, contentBase);
      }

      // Check-out row with status
      if (outM != null && endM != null) {
        var statusOut;
        if (outM === endM) statusOut = 'Đúng giờ';
        else if (outM < endM) statusOut = 'Về sớm ' + fmtDuration(endM - outM);
        else statusOut = 'Tăng ca ' + fmtDuration(outM - endM);
        addRow((co && co.substring ? co.substring(0,5) : co), statusOut, method, contentBase);
      } else if (co) {
        addRow(co, 'Đã chấm công ra', method, contentBase);
      }

      histEmpty.style.display = haveAny ? 'none' : 'block';
      histList.style.display = haveAny ? 'block' : 'none';
    }

    open();
  });

  // React to status change to show/hide time fields
  document.addEventListener('change', function(e){
    if (e.target && e.target.id === 'attStatusSelect') {
      var workRow = document.getElementById('attWorkTimeRow');
      if (workRow) workRow.style.display = (e.target.value === 'work') ? 'block' : 'none';
      // Clear time inputs when not work to avoid stale values
      if (e.target.value !== 'work') {
        var inInput = document.getElementById('attCheckInInput');
        var outInput = document.getElementById('attCheckOutInput');
        if (inInput) inInput.value = '';
        if (outInput) outInput.value = '';
      }
    }
  });
})();
</script>
