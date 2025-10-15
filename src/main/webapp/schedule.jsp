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
    <div class="header-actions" style="display:flex; align-items:center; gap:12px; flex-wrap:nowrap;">
      <div class="schedule-toolbar" style="margin: 0 12px 0 0;">
        <div class="week-chip" id="weekChip">
          <a class="chip-btn prev" href="${pageContext.request.contextPath}/schedule?weekStart=${prevWeekStart}"><i class='bx bx-chevron-left'></i></a>
          <button type="button" class="chip-label" id="openCalendar">${controlLabel}</button>
          <a class="chip-btn next" href="${pageContext.request.contextPath}/schedule?weekStart=${nextWeekStart}"><i class='bx bx-chevron-right'></i></a>
        </div>
        <a class="btn btn-light" href="${pageContext.request.contextPath}/schedule">Tuần này</a>
      </div>
      <button class="btn btn-primary" id="openAddShift" type="button">
        <i class='bx bx-plus'></i> Thêm lịch làm việc
      </button>
    </div>
  </div>

  <!-- Main Content Area -->
  <div class="main-content">
    

    <div class="calendar-popover" id="calendarPopover" hidden>
      <div class="calendar-header">
        <button class="cal-nav" id="calPrev"><i class='bx bx-chevron-left'></i></button>
        <div class="cal-title" id="calTitle"></div>
        <button class="cal-nav" id="calNext"><i class='bx bx-chevron-right'></i></button>
      </div>
      <div class="calendar-grid" id="calendarGrid"></div>
    </div>

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
          <!-- Render each base shift row (templates) -->
          <c:forEach var="t" items="${templates}">
            <tr>
              <td class="time-col">
                <div class="slot-title">${t.name}</div>
                <div class="slot-time">${t.startTime} - ${t.endTime}</div>
              </td>
              <c:forEach var="d" items="${weekDays}">
                <td class="schedule-cell">
                  <c:set var="rowFound" value="false" />
                  <c:forEach var="row" items="${d.rows}">
                    <c:if test="${row.templateName == t.name}">
                      <c:choose>
                        <c:when test="${empty row.items}">
                          <div class="empty-day">—</div>
                        </c:when>
                        <c:otherwise>
                          <c:forEach var="s" items="${row.items}">
                            <div class="shift-block"
                                 data-shift-id="${s.shiftId}"
                                 data-title="${s.title}"
                                 data-employee="${s.employee}"
                                 data-notes="${s.notes}"
                                 data-location="${s.location}"
                                 data-status="${s.status}"
                                 data-start-at="${s.startAt}"
                                 data-end-at="${s.endAt}">
                              <div class="shift-emp">${s.employee}</div>
                              <c:if test="${not empty s.notes}">
                                <div class="shift-notes">${s.notes}</div>
                              </c:if>
                              <c:if test="${not empty s.location}">
                                <div class="shift-location"><i class='bx bx-map'></i> ${s.location}</div>
                              </c:if>
                            </div>
                          </c:forEach>
                        </c:otherwise>
                      </c:choose>
                      <c:set var="rowFound" value="true" />
                    </c:if>
                  </c:forEach>
                  <c:if test="${!rowFound}">
                    <div class="empty-day">—</div>
                  </c:if>
                </td>
              </c:forEach>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- Add Shift Modal -->
<div id="addShiftOverlay" style="position:fixed; inset:0; background:rgba(0,0,0,.45); display:none; align-items:center; justify-content:center; z-index:1000;">
  <div style="background:#fff; width:95%; max-width:640px; border-radius:10px; box-shadow:0 10px 30px rgba(0,0,0,0.2); overflow:hidden;">
    <div style="display:flex; align-items:center; justify-content:space-between; padding:16px 20px; border-bottom:1px solid #eee;">
      <h3 style="margin:0; font-size:18px; font-weight:600;">Thêm lịch làm việc</h3>
      <button type="button" id="closeAddShift" style="background:transparent; border:none; font-size:20px; cursor:pointer; padding:6px 10px; border-radius:6px;">✕</button>
    </div>
    <form id="addShiftForm" method="post" action="${pageContext.request.contextPath}/schedule" style="padding:20px; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px;">
      <input type="hidden" name="action" value="create" />
      <input type="hidden" name="weekStart" value="${currentWeekStart}" />

      <div style="grid-column:1 / -1;">
        <label for="employeeCode" style="font-size:12px; color:#6b7280;">Nhân viên</label>
        <select id="employeeCode" name="employeeCode" required style="width:100%; padding:10px 12px; border:1px solid #e5e7eb; border-radius:8px;">
          <option value="" disabled selected>Chọn nhân viên</option>
          <c:forEach var="e" items="${employees}">
            <option value="${e.employeeCode}">${e.employeeCode} - ${e.fullName}</option>
          </c:forEach>
        </select>
      </div>

      <div>
        <label for="date" style="font-size:12px; color:#6b7280;">Ngày</label>
        <input id="date" name="date" type="date" required style="width:100%; padding:10px 12px; border:1px solid #e5e7eb; border-radius:8px;" />
      </div>
      <div>
        <label for="location" style="font-size:12px; color:#6b7280;">Địa điểm</label>
        <input id="location" name="location" type="text" placeholder="VD: Quầy, Bếp..." style="width:100%; padding:10px 12px; border:1px solid #e5e7eb; border-radius:8px;" />
      </div>

      <div style="grid-column:1 / -1;">
        <label style="font-size:12px; color:#6b7280; display:block; margin-bottom:6px;">Chọn ca</label>
        <div id="templateOptions" style="display:flex; flex-wrap:wrap; gap:8px;">
          <c:forEach var="t" items="${templates}">
            <button type="button"
                    class="tmpl-option"
                    data-start="${t.startTime.toString().substring(0,5)}"
                    data-end="${t.endTime.toString().substring(0,5)}"
                    style="padding:8px 10px; border:1px solid #e5e7eb; border-radius:8px; background:#fff; cursor:pointer;">
              <span style="font-weight:600;">${t.name}</span>
              <span style="color:#6b7280; margin-left:6px;">${t.startTime.toString().substring(0,5)} - ${t.endTime.toString().substring(0,5)}</span>
            </button>
          </c:forEach>
        </div>
        <div style="margin-top:6px; font-size:12px; color:#374151;">Đã chọn: <span id="selectedTemplateLabel" style="font-weight:600;">Chưa chọn</span></div>
        <div id="hiddenTimesContainer"></div>
      </div>

      <div>
        <label for="title" style="font-size:12px; color:#6b7280;">Tiêu đề</label>
        <input id="title" name="title" type="text" placeholder="Ca sáng, Ca tối..." style="width:100%; padding:10px 12px; border:1px solid #e5e7eb; border-radius:8px;" />
      </div>
      <div>
        <label for="notes" style="font-size:12px; color:#6b7280;">Ghi chú</label>
        <input id="notes" name="notes" type="text" placeholder="Ghi chú thêm" style="width:100%; padding:10px 12px; border:1px solid #e5e7eb; border-radius:8px;" />
      </div>

      <div style="grid-column:1 / -1; display:flex; gap:10px; justify-content:flex-end; margin-top:8px;">
        <button type="button" id="cancelAddShift" class="btn btn-light">Hủy</button>
        <button type="submit" class="btn btn-primary">Lưu</button>
      </div>
    </form>
  </div>
  
</div>

<!-- Shift Detail Modal -->
<div id="shiftDetailOverlay" style="position:fixed; inset:0; background:rgba(0,0,0,.45); display:none; align-items:center; justify-content:center; z-index:1000;">
  <div style="background:#fff; width:95%; max-width:560px; border-radius:10px; box-shadow:0 10px 30px rgba(0,0,0,0.2); overflow:hidden;">
    <div style="display:flex; align-items:center; justify-content:space-between; padding:16px 20px; border-bottom:1px solid #eee;">
      <h3 style="margin:0; font-size:18px; font-weight:600;">Chi tiết ca làm việc</h3>
      <div>
        <form id="deleteShiftForm" method="post" action="${pageContext.request.contextPath}/schedule" style="display:inline; margin-right:8px;">
          <input type="hidden" name="action" value="delete" />
          <input type="hidden" name="weekStart" value="${currentWeekStart}" />
          <input type="hidden" name="shiftId" id="deleteShiftId" />
          <button type="submit" class="btn btn-danger" id="deleteShiftBtn">Xóa</button>
        </form>
        <button type="button" id="closeShiftDetail" class="btn btn-light">Đóng</button>
      </div>
    </div>
    <div style="padding:20px; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px;">
      <div><label style="font-size:12px; color:#6b7280;">Nhân viên</label><div id="sdEmployee" style="margin-top:6px; font-weight:600;"></div></div>
      <div><label style="font-size:12px; color:#6b7280;">Tiêu đề</label><div id="sdTitle" style="margin-top:6px;"></div></div>
      <div><label style="font-size:12px; color:#6b7280;">Trạng thái</label><div id="sdStatus" style="margin-top:6px;"></div></div>
      <div><label style="font-size:12px; color:#6b7280;">Địa điểm</label><div id="sdLocation" style="margin-top:6px;"></div></div>
      <div><label style="font-size:12px; color:#6b7280;">Bắt đầu</label><div id="sdStartAt" style="margin-top:6px;"></div></div>
      <div><label style="font-size:12px; color:#6b7280;">Kết thúc</label><div id="sdEndAt" style="margin-top:6px;"></div></div>
      <div style="grid-column:1 / -1;"><label style="font-size:12px; color:#6b7280;">Ghi chú</label><div id="sdNotes" style="margin-top:6px;"></div></div>
    </div>
  </div>
</div>
<script>
(function() {
  const gridBody = document.getElementById('scheduleBody');
  const weekLabel = document.getElementById('weekLabel');
  const headerCells = Array.prototype.slice.call(document.querySelectorAll('.schedule-grid thead th[data-day]'));
  // If legacy dynamic grid anchors are not present (server-rendered table), skip this block
  if (!gridBody || !weekLabel) {
    return;
  }

  function startOfWeek(date) {
    const d = new Date(date);
    const day = (d.getDay() + 6) % 7; // Monday = 0
    d.setDate(d.getDate() - day);
    d.setHours(0, 0, 0, 0);
    return d;
  }

  function formatDate(d) {
    const dd = ('0' + d.getDate()).slice(-2);
    const mm = ('0' + (d.getMonth() + 1)).slice(-2);
    return dd + '/' + mm;
  }

  function formatFullDate(d) {
    const dd = ('0' + d.getDate()).slice(-2);
    const mm = ('0' + (d.getMonth() + 1)).slice(-2);
    return dd + '/' + mm + '/' + d.getFullYear();
  }

  let currentWeekStart = startOfWeek(new Date());

  function renderHeader() {
    headerCells.forEach(function(th, idx) {
      const date = new Date(currentWeekStart);
      date.setDate(currentWeekStart.getDate() + idx);
      const small = th.querySelector('.date');
      if (small) small.textContent = formatDate(date);
    });
    const end = new Date(currentWeekStart);
    end.setDate(end.getDate() + 6);
    weekLabel.textContent = 'Tuần ' + formatDate(currentWeekStart) + ' - ' + formatFullDate(end);
  }

  function renderBody() {
    gridBody.innerHTML = '';
    var startHour = 7, endHour = 22;
    for (var h = startHour; h <= endHour; h++) {
      var tr = document.createElement('tr');
      var timeTd = document.createElement('td');
      timeTd.className = 'time-col';
      var label = (h < 10 ? '0' : '') + h + ':00';
      timeTd.textContent = label;
      tr.appendChild(timeTd);
      for (var day = 0; day < 7; day++) {
        var td = document.createElement('td');
        td.className = 'schedule-cell';
        td.setAttribute('data-day-index', String(day));
        td.setAttribute('data-hour', String(h));
        tr.appendChild(td);
      }
      gridBody.appendChild(tr);
    }
  }

  function addShift(td) {
    if (td.querySelector('.shift-block')) return;
    var hour = parseInt(td.getAttribute('data-hour'), 10);
    var block = document.createElement('div');
    block.className = 'shift-block';
    block.innerHTML = "<div class='shift-time'>" + (hour < 10 ? '0' : '') + hour + ":00 - " + (hour + 1 < 10 ? '0' : '') + (hour + 1) + ":00</div>" +
                      "<div class='shift-title'>Ca mới</div>";
    td.appendChild(block);
  }

  var prevBtn = document.getElementById('prevWeek');
  var nextBtn = document.getElementById('nextWeek');
  var todayBtn = document.getElementById('todayWeek');
  if (prevBtn) prevBtn.addEventListener('click', function() { currentWeekStart.setDate(currentWeekStart.getDate() - 7); renderHeader(); });
  if (nextBtn) nextBtn.addEventListener('click', function() { currentWeekStart.setDate(currentWeekStart.getDate() + 7); renderHeader(); });
  if (todayBtn) todayBtn.addEventListener('click', function() { currentWeekStart = startOfWeek(new Date()); renderHeader(); });

  document.querySelector('.schedule-grid').addEventListener('click', function(e) {
    var td = e.target.closest('td.schedule-cell');
    if (!td) return;
    addShift(td);
  });

  renderBody();
  renderHeader();
  // Lightweight calendar popover for choosing a date -> navigate to its week
  var openBtn = document.getElementById('openCalendar');
  var pop = document.getElementById('calendarPopover');
  var calTitle = document.getElementById('calTitle');
  var calGrid = document.getElementById('calendarGrid');
  var calPrev = document.getElementById('calPrev');
  var calNext = document.getElementById('calNext');

  var viewYear, viewMonth; // 0-based month

  function setViewToToday() {
    var today = new Date();
    viewYear = today.getFullYear();
    viewMonth = today.getMonth();
  }

  function renderCalendar() {
    calTitle.textContent = 'Thg ' + (viewMonth + 1) + ' ' + viewYear;
    calGrid.innerHTML = '';

    var header = ['T2','T3','T4','T5','T6','T7','CN'];
    var headRow = document.createElement('div');
    headRow.className = 'cal-row cal-head';
    header.forEach(function(h){
      var c = document.createElement('div'); c.textContent = h; headRow.appendChild(c);
    });
    calGrid.appendChild(headRow);

    var first = new Date(viewYear, viewMonth, 1);
    var startIdx = (first.getDay() + 6) % 7; // Monday=0
    var daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
    var day = 1 - startIdx;
    for (var r = 0; r < 6; r++) {
      var row = document.createElement('div');
      row.className = 'cal-row';
      for (var c = 0; c < 7; c++, day++) {
        var cell = document.createElement('button');
        cell.className = 'cal-cell';
        var thisDate = new Date(viewYear, viewMonth, day);
        if (day < 1 || day > daysInMonth) {
          cell.classList.add('muted');
          cell.textContent = thisDate.getDate();
          cell.disabled = true;
        } else {
          cell.textContent = day;
          cell.addEventListener('click', function(ev){
            var picked = new Date(viewYear, viewMonth, parseInt(ev.target.textContent, 10));
            var ws = startOfWeek(picked);
            var y = ws.getFullYear();
            var m = ('0' + (ws.getMonth()+1)).slice(-2);
            var d = ('0' + ws.getDate()).slice(-2);
            window.location.href = '${pageContext.request.contextPath}/schedule?weekStart=' + y + '-' + m + '-' + d;
          });
        }
        row.appendChild(cell);
      }
      calGrid.appendChild(row);
    }
  }

  openBtn.addEventListener('click', function(){
    if (pop.hasAttribute('hidden')) {
      setViewToToday();
      renderCalendar();
      pop.removeAttribute('hidden');
    } else {
      pop.setAttribute('hidden', 'hidden');
    }
  });
  calPrev.addEventListener('click', function(){ viewMonth -= 1; if (viewMonth<0){viewMonth=11; viewYear-=1;} renderCalendar(); });
  calNext.addEventListener('click', function(){ viewMonth += 1; if (viewMonth>11){viewMonth=0; viewYear+=1;} renderCalendar(); });

})();

// Add Shift Modal wiring
(function(){
  var overlay = document.getElementById('addShiftOverlay');
  var openBtn = document.getElementById('openAddShift');
  var closeBtn = document.getElementById('closeAddShift');
  var cancelBtn = document.getElementById('cancelAddShift');
  function open(){ overlay.style.display = 'flex'; }
  function close(){ overlay.style.display = 'none'; }
  if (openBtn) openBtn.addEventListener('click', open);
  if (closeBtn) closeBtn.addEventListener('click', close);
  if (cancelBtn) cancelBtn.addEventListener('click', close);
  if (overlay) overlay.addEventListener('click', function(e){ if (e.target === overlay) close(); });
  document.addEventListener('keydown', function(e){ if (e.key === 'Escape') close(); });

  // Template selection wiring
  var selectedLabel = document.getElementById('selectedTemplateLabel');
  var hiddenContainer = document.getElementById('hiddenTimesContainer');
  var options = Array.prototype.slice.call(document.querySelectorAll('.tmpl-option'));
  function fmt(s, e){ return s + ' - ' + e; }
  function updateSelectedLabel(){
    var chips = Array.prototype.slice.call(hiddenContainer.querySelectorAll('input[name="startTime"]'));
    if (!chips.length) { selectedLabel.textContent = 'Chưa chọn'; return; }
    var labels = [];
    chips.forEach(function(inp){
      var s = inp.value;
      var e = inp.nextSibling && inp.nextSibling.name === 'endTime' ? inp.nextSibling.value : '';
      // end input is not reliably nextSibling if nodes differ; query accordingly
    });
    // Build labels from pairs
    var starts = Array.prototype.slice.call(hiddenContainer.querySelectorAll('input[name="startTime"]'));
    var ends = Array.prototype.slice.call(hiddenContainer.querySelectorAll('input[name="endTime"]'));
    for (var i = 0; i < starts.length; i++) {
      labels.push(fmt(starts[i].value, ends[i] ? ends[i].value : ''));
    }
    selectedLabel.textContent = labels.join(', ');
  }
  function isSelected(s, e){
    var starts = hiddenContainer.querySelectorAll('input[name="startTime"][value="' + s + '"]');
    var ends = hiddenContainer.querySelectorAll('input[name="endTime"][value="' + e + '"]');
    return starts.length > 0 && ends.length > 0;
  }
  function addHidden(s, e){
    var si = document.createElement('input'); si.type = 'hidden'; si.name = 'startTime'; si.value = s;
    var ei = document.createElement('input'); ei.type = 'hidden'; ei.name = 'endTime'; ei.value = e;
    hiddenContainer.appendChild(si);
    hiddenContainer.appendChild(ei);
  }
  function removeHidden(s, e){
    var starts = Array.prototype.slice.call(hiddenContainer.querySelectorAll('input[name="startTime"]'));
    var ends = Array.prototype.slice.call(hiddenContainer.querySelectorAll('input[name="endTime"]'));
    for (var i = 0; i < starts.length; i++) {
      if (starts[i].value === s && ends[i] && ends[i].value === e) {
        hiddenContainer.removeChild(starts[i]);
        hiddenContainer.removeChild(ends[i]);
        break;
      }
    }
  }
  function setActive(btn, active){
    btn.style.background = active ? '#eef2ff' : '#fff';
    btn.style.borderColor = active ? '#6366f1' : '#e5e7eb';
  }
  options.forEach(function(btn){
    btn.addEventListener('click', function(){
      var s = btn.getAttribute('data-start');
      var e = btn.getAttribute('data-end');
      if (isSelected(s, e)) {
        removeHidden(s, e);
        setActive(btn, false);
      } else {
        addHidden(s, e);
        setActive(btn, true);
      }
      updateSelectedLabel();
    });
  });

  // Validate before submit
  var form = document.getElementById('addShiftForm');
  if (form) form.addEventListener('submit', function(e){
    if (!hiddenContainer.querySelector('input[name="startTime"]')) {
      e.preventDefault();
      alert('Vui lòng chọn ít nhất một ca làm việc.');
    }
  });
})();

// Shift Detail Modal wiring
(function(){
  var overlay = document.getElementById('shiftDetailOverlay');
  var closeBtn = document.getElementById('closeShiftDetail');
  function open(){ if (overlay) overlay.style.display = 'flex'; }
  function close(){ if (overlay) overlay.style.display = 'none'; }
  if (closeBtn) closeBtn.addEventListener('click', close);
  if (overlay) overlay.addEventListener('click', function(e){ if (e.target === overlay) close(); });
  document.addEventListener('keydown', function(e){ if (e.key === 'Escape') close(); });

  function setText(id, v){ var el = document.getElementById(id); if (el) el.textContent = v || ''; }
  function formatDT(dt){
    if (!dt) return '';
    try { var d = new Date(dt); return d.toLocaleString('vi-VN'); } catch(e) { return dt; }
  }

  document.addEventListener('click', function(e){
    var block = e.target.closest('.shift-block');
    if (!block) return;
    var emp = block.getAttribute('data-employee') || '';
    var title = block.getAttribute('data-title') || '';
    var status = block.getAttribute('data-status') || '';
    var loc = block.getAttribute('data-location') || '';
    var startAt = block.getAttribute('data-start-at') || '';
    var endAt = block.getAttribute('data-end-at') || '';
    var notes = block.getAttribute('data-notes') || '';
    var sid = block.getAttribute('data-shift-id') || '';

    setText('sdEmployee', emp);
    setText('sdTitle', title);
    setText('sdStatus', status);
    setText('sdLocation', loc);
    setText('sdStartAt', formatDT(startAt));
    setText('sdEndAt', formatDT(endAt));
    setText('sdNotes', notes);
    var delId = document.getElementById('deleteShiftId');
    if (delId) delId.value = sid;
    open();
  });
})();
</script>

<jsp:include page="includes/footer.jsp" />
