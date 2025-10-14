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
    <div class="schedule-toolbar">
      <div class="week-chip" id="weekChip">
        <a class="chip-btn prev" href="${pageContext.request.contextPath}/schedule?weekStart=${prevWeekStart}"><i class='bx bx-chevron-left'></i></a>
        <button type="button" class="chip-label" id="openCalendar">${controlLabel}</button>
        <a class="chip-btn next" href="${pageContext.request.contextPath}/schedule?weekStart=${nextWeekStart}"><i class='bx bx-chevron-right'></i></a>
      </div>
      <a class="btn btn-light" href="${pageContext.request.contextPath}/schedule">Tuần này</a>
    </div>

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
                            <div class="shift-block">
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

<script>
(function() {
  const gridBody = document.getElementById('scheduleBody');
  const weekLabel = document.getElementById('weekLabel');
  const headerCells = Array.prototype.slice.call(document.querySelectorAll('.schedule-grid thead th[data-day]'));

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

  document.getElementById('prevWeek').addEventListener('click', function() {
    currentWeekStart.setDate(currentWeekStart.getDate() - 7);
    renderHeader();
  });
  document.getElementById('nextWeek').addEventListener('click', function() {
    currentWeekStart.setDate(currentWeekStart.getDate() + 7);
    renderHeader();
  });
  document.getElementById('todayWeek').addEventListener('click', function() {
    currentWeekStart = startOfWeek(new Date());
    renderHeader();
  });

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
</script>

<jsp:include page="includes/footer.jsp" />
