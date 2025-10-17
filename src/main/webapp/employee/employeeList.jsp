<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="../includes/header.jsp">
  <jsp:param name="page" value="employees" />
</jsp:include>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/employee.css">
        <style>
            /* Minimal modal styles scoped to this page */
            .employee-modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.45); display: none; align-items: center; justify-content: center; z-index: 1000; }
            .employee-modal { background: #fff; width: 95%; max-width: 1100px; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); overflow: hidden; }
            .employee-modal__header { display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; border-bottom: 1px solid #eee; }
            .employee-modal__title { font-size: 18px; font-weight: 600; margin: 0; }
            .employee-modal__close { background: transparent; border: none; font-size: 20px; cursor: pointer; padding: 6px 10px; border-radius: 6px; }
            .employee-modal__close:hover { background: #f3f4f6; }
            .employee-modal__body { padding: 20px; max-height: 70vh; overflow: auto; }
            .employee-modal__grid { display: grid; grid-template-columns: 160px 1fr; gap: 20px; }
            .employee-modal__avatar { width: 140px; height: 140px; border-radius: 50%; object-fit: cover; border: 2px solid #eee; }
            .employee-modal__fields { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px 20px; }
            .employee-field { display: flex; flex-direction: column; gap: 6px; }
            .employee-field label { font-size: 12px; color: #6b7280; }
            .employee-field .value { font-size: 14px; color: #111827; background: #f9fafb; padding: 10px 12px; border-radius: 8px; border: 1px solid #f3f4f6; }
            @media (max-width: 680px) { .employee-modal__grid { grid-template-columns: 1fr; } .employee-modal__fields { grid-template-columns: 1fr; } }
            .employee-row { cursor: pointer; }
            .employee-row:hover { background: #f9fafb; }
        </style>

<div class="content">
    <!-- Statistics -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-number">${stats.totalEmployees}</div>
            <div class="stat-label">Tổng nhân viên</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">${stats.activeEmployees}</div>
            <div class="stat-label">Đang làm việc</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">${stats.managerCount}</div>
            <div class="stat-label">Quản lý</div>
        </div>
    </div>

    <!-- Success/Error Messages -->
    <c:if test="${not empty success}">
        <div style="background: #d4edda; color: #155724; padding: 1rem; border-radius: 6px; margin-bottom: 1rem; border: 1px solid #c3e6cb;">
            ✅ ${success}
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 6px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
            ❌ ${error}
        </div>
    </c:if>

    <!-- Main Content Layout -->
    <div class="main-layout">
        <!-- Left Sidebar - Employee Filters -->
        <div class="sidebar">
            <div class="filter-section">
                <h3 class="filter-title">Tìm kiếm</h3>
                <div class="search-box">
                    <input type="text" class="search-input" placeholder="Theo mã, tên nhân viên" id="searchInput" onkeyup="searchEmployees()">
                </div>
            </div>

            <div class="filter-section">
                <h3 class="filter-title">Vị trí</h3>
                <div class="filter-options">
                    <label class="filter-option">
                        <input type="checkbox" name="positionFilter" value="Quản lý" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Quản lý
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="positionFilter" value="Nhân viên" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Nhân viên
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="positionFilter" value="Thu ngân" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Thu ngân
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="positionFilter" value="Đầu bếp" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Đầu bếp
                    </label>
                </div>
            </div>

            <div class="filter-section">
                <h3 class="filter-title">Trạng thái</h3>
                <div class="filter-options">
                    <label class="filter-option">
                        <input type="checkbox" name="statusFilter" value="Đang làm" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Đang làm việc
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="statusFilter" value="Đã nghỉ" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Nghỉ việc
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="statusFilter" value="Tạm nghỉ" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Nghỉ phép
                    </label>
                </div>
            </div>

            <div class="filter-section">
                <h3 class="filter-title collapsible" onclick="toggleFilterSection(this)">
                    Bộ phận
                    <span class="collapse-icon">▼</span>
                </h3>
                <div class="filter-options collapsed">
                    <label class="filter-option">
                        <input type="checkbox" name="departmentFilter" value="KITCHEN" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Bếp
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="departmentFilter" value="FRONT_DESK" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Lễ tân
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="departmentFilter" value="SERVICE" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Phục vụ
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="departmentFilter" value="MANAGEMENT" onchange="filterEmployees()">
                        <span class="checkmark"></span>
                        Quản lý
                    </label>
                </div>
            </div>
        </div>

        <!-- Right Content - Employee List -->
        <div class="main-content">
            <!-- Toolbar -->
            <div class="toolbar">
                <div>
                    <a href="#" class="btn btn-success" onclick="addEmployee()">➕ Thêm nhân viên</a>
                    <button class="btn btn-primary" onclick="exportEmployees()">📊 Xuất file</button>
                    <button class="btn btn-primary" onclick="importEmployees()">📥 Import</button>
                </div>
            </div>

            <!-- Employee Table -->
            <div class="employee-table">
                <c:choose>
                    <c:when test="${empty employees}">
                        <div class="empty-state">
                            <h3>👥 Chưa có nhân viên nào</h3>
                            <p>Hãy thêm nhân viên đầu tiên để bắt đầu quản lý</p>
                            <a href="#" class="btn btn-success" onclick="addEmployee()" style="margin-top: 1rem;">➕ Thêm nhân viên</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th class="sortable" onclick="sortTable(0, 'string')">
                                        Mã NV
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(1, 'string')">
                                        Họ tên
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(2, 'string')">
                                        CCCD/CMND
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(3, 'string')">
                                        Số điện thoại
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(4, 'string')">
                                        Trạng thái
                                        <span class="sort-icon"></span>
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="emp" items="${employees}">
                                    <tr
                                        class="employee-row"
                                        onclick="viewEmployee('${emp.employeeCode}')"
                                        data-employee-code="${emp.employeeCode}"
                                        data-full-name="${emp.fullName}"
                                        data-email="${emp.email}"
                                        data-phone="${emp.phone}"
                                        data-national-id="${emp.nationalID}"
                                        data-gender="${emp.gender}"
                                        data-birth-date="${emp.birthDate}"
                                        data-address="${emp.address}"
                                        data-position="${emp.position}"
                                        data-status="${emp.employmentStatus}"
                                        data-salary="${emp.salary}"
                                        data-bank-account="${emp.bankAccount}"
                                        data-bank-name="${emp.bankName}"
                                        data-notes="${emp.notes}"
                                        data-avatar-url="${emp.avatarURL}"
                                        data-hire-date="${emp.hireDate}"
                                        data-termination-date="${emp.terminationDate}"
                                        data-created-at="${emp.createdAt}"
                                        data-updated-at="${emp.updatedAt}"
                                    >
                                        <td>
                                            <span class="employee-code">${emp.employeeCode}</span>
                                        </td>
                                        <td>
                                            <div class="employee-info">
                                                <div class="employee-name">${emp.fullName}</div>
                                                <div class="employee-email">${emp.email}</div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="national-id">${emp.nationalID}</span>
                                        </td>
                                        <td>
                                            <span class="phone">${emp.phone}</span>
                                        </td>
                                        <td>
                                            <span class="status status-${emp.employmentStatus.toLowerCase().replace(' ', '-')}">
                                                <c:choose>
                                                    <c:when test="${emp.employmentStatus == 'Đang làm'}">Đang làm việc</c:when>
                                                    <c:when test="${emp.employmentStatus == 'Đã nghỉ'}">Nghỉ việc</c:when>
                                                    <c:when test="${emp.employmentStatus == 'Tạm nghỉ'}">Nghỉ phép</c:when>
                                                    <c:otherwise>${emp.employmentStatus}</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<!-- Employee Detail Modal -->
<div id="employeeDetailModal" class="employee-modal-overlay">
    <div class="employee-modal" role="dialog" aria-modal="true" aria-labelledby="employeeDetailTitle">
        <div class="employee-modal__header">
            <h3 id="employeeDetailTitle" class="employee-modal__title">Thông tin nhân viên</h3>
            <button type="button" class="employee-modal__close" id="employeeModalCloseBtn" aria-label="Đóng">✕</button>
        </div>
        <div class="employee-modal__body">
            <form id="employeeEditForm" method="post" action="${pageContext.request.contextPath}/employees">
                <input type="hidden" name="action" value="update" />
                <div class="employee-modal__grid">
                    <div style="display:flex; align-items:center; justify-content:center;">
                        <img id="modalAvatar" class="employee-modal__avatar" src="" alt="Avatar">
                    </div>
                    <div class="employee-modal__fields">
                        <div class="employee-field"><label>Mã nhân viên</label><input id="modalEmployeeCode" name="employeeCode" class="value" readonly></div>
                        <div class="employee-field"><label>Họ tên</label><input id="modalFullName" name="fullName" class="value"></div>
                        <div class="employee-field"><label>Email</label><input id="modalEmail" name="email" class="value"></div>
                        <div class="employee-field"><label>Số điện thoại</label><input id="modalPhone" name="phone" class="value"></div>
                        <div class="employee-field"><label>CCCD/CMND</label><input id="modalNationalID" name="nationalID" class="value"></div>
                        <div class="employee-field"><label>Giới tính</label><input id="modalGender" name="gender" class="value"></div>
                        <div class="employee-field"><label>Ngày sinh</label><input id="modalBirthDate" name="birthDate" type="date" class="value"></div>
                        <div class="employee-field"><label>Địa chỉ</label><input id="modalAddress" name="address" class="value"></div>
                        <div class="employee-field"><label>Vị trí</label><input id="modalPosition" name="position" class="value"></div>
                        <div class="employee-field"><label>Trạng thái</label><input id="modalStatus" name="employmentStatus" class="value"></div>
                        <div class="employee-field"><label>Lương</label><input id="modalSalary" name="salary" type="number" step="0.01" class="value"></div>
                        <div class="employee-field"><label>Ngân hàng</label><input id="modalBankName" name="bankName" class="value"></div>
                        <div class="employee-field"><label>Số tài khoản</label><input id="modalBankAccount" name="bankAccount" class="value"></div>
                        <div class="employee-field" style="grid-column: 1 / -1;"><label>Ghi chú</label><textarea id="modalNotes" name="notes" rows="3" class="value"></textarea></div>
                        <div class="employee-field"><label>Ngày vào làm</label><input id="modalHireDate" name="hireDate" type="datetime-local" class="value" readonly></div>
                        <div class="employee-field"><label>Ngày nghỉ việc</label><input id="modalTerminationDate" name="terminationDate" type="datetime-local" class="value" readonly></div>
                        <div class="employee-field"><label>Tạo lúc</label><input id="modalCreatedAt" name="createdAt" class="value" readonly></div>
                        <div class="employee-field"><label>Cập nhật lúc</label><input id="modalUpdatedAt" name="updatedAt" class="value" readonly></div>
                    </div>
                </div>
                <div style="margin-top: 16px; display: flex; gap: 8px; justify-content: flex-end;">
                    <button type="button" class="btn" onclick="closeEmployeeModal()">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

        <script>
            // Biến để theo dõi trạng thái sắp xếp
            let currentSortColumn = -1;
            let currentSortDirection = 'asc';

            function searchEmployees() {
                const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
                const rows = document.querySelectorAll('.table tbody tr');

                if (searchTerm === '') {
                    // Nếu không có từ khóa tìm kiếm, hiển thị tất cả
                    rows.forEach(row => {
                        row.style.display = '';
                    });
                    return;
                }

                rows.forEach(row => {
                    const employeeCode = row.querySelector('.employee-code').textContent.toLowerCase();
                    const employeeName = row.querySelector('.employee-name').textContent.toLowerCase();
                    const employeeEmail = row.querySelector('.employee-email').textContent.toLowerCase();
                    const phone = row.querySelector('.phone').textContent.toLowerCase();
                    const nationalID = row.querySelector('.national-id').textContent.toLowerCase();

                    // Tìm kiếm trong mã nhân viên, tên, email, số điện thoại và CCCD
                    if (employeeCode.includes(searchTerm) || 
                        employeeName.includes(searchTerm) || 
                        employeeEmail.includes(searchTerm) ||
                        phone.includes(searchTerm) ||
                        nationalID.includes(searchTerm)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }

            function filterEmployees() {
                // Áp dụng tất cả bộ lọc
                applyAllFilters();
            }

            function applyAllFilters() {
                const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
                const positionFilters = Array.from(document.querySelectorAll('input[name="positionFilter"]:checked')).map(cb => cb.value);
                const statusFilters = Array.from(document.querySelectorAll('input[name="statusFilter"]:checked')).map(cb => cb.value);
                const departmentFilters = Array.from(document.querySelectorAll('input[name="departmentFilter"]:checked')).map(cb => cb.value);
                const rows = document.querySelectorAll('.table tbody tr');

                rows.forEach((row, index) => {
                    let showRow = true;
                    
                    // Áp dụng tìm kiếm
                    if (searchTerm !== '') {
                        const employeeCode = row.querySelector('.employee-code').textContent.toLowerCase();
                        const employeeName = row.querySelector('.employee-name').textContent.toLowerCase();
                        const employeeEmail = row.querySelector('.employee-email').textContent.toLowerCase();
                        const phone = row.querySelector('.phone').textContent.toLowerCase();
                        const nationalID = row.querySelector('.national-id').textContent.toLowerCase();
                        
                        if (!employeeCode.includes(searchTerm) && 
                            !employeeName.includes(searchTerm) && 
                            !employeeEmail.includes(searchTerm) &&
                            !phone.includes(searchTerm) &&
                            !nationalID.includes(searchTerm)) {
                            showRow = false;
                        }
                    }
                    
                    // Áp dụng lọc theo trạng thái
                    if (showRow && statusFilters.length > 0) {
                        const status = row.cells[4].querySelector('.status').textContent.trim();
                        const statusValue = getStatusValue(status);
                        if (!statusFilters.includes(statusValue)) {
                            showRow = false;
                        }
                    }

                    row.style.display = showRow ? '' : 'none';
                });
            }

            function getPositionValue(positionText) {
                switch(positionText) {
                    case 'Quản lý': return 'MANAGER';
                    case 'Nhân viên': return 'STAFF';
                    case 'Thu ngân': return 'CASHIER';
                    case 'Đầu bếp': return 'CHEF';
                    default: return positionText;
                }
            }

            function getStatusValue(statusText) {
                switch(statusText) {
                    case 'Đang làm việc': return 'Đang làm';
                    case 'Nghỉ việc': return 'Đã nghỉ';
                    case 'Nghỉ phép': return 'Tạm nghỉ';
                    default: return statusText;
                }
            }

            function toggleFilterSection(element) {
                const options = element.nextElementSibling;
                const icon = element.querySelector('.collapse-icon');
                
                if (options.classList.contains('collapsed')) {
                    options.classList.remove('collapsed');
                    icon.textContent = '▲';
                } else {
                    options.classList.add('collapsed');
                    icon.textContent = '▼';
                }
            }

            function sortTable(columnIndex, dataType) {
                const table = document.querySelector('.table');
                const tbody = table.querySelector('tbody');
                const rows = Array.from(tbody.querySelectorAll('tr'));
                
                // Xóa class sort cũ
                document.querySelectorAll('.table th').forEach(th => {
                    th.classList.remove('sort-asc', 'sort-desc');
                });

                // Xác định hướng sắp xếp
                if (currentSortColumn === columnIndex) {
                    currentSortDirection = currentSortDirection === 'asc' ? 'desc' : 'asc';
                } else {
                    currentSortDirection = 'asc';
                }
                currentSortColumn = columnIndex;

                // Thêm class sort cho header hiện tại
                const currentHeader = document.querySelectorAll('.table th')[columnIndex];
                currentHeader.classList.add(currentSortDirection === 'asc' ? 'sort-asc' : 'sort-desc');

                // Sắp xếp các hàng
                rows.sort((a, b) => {
                    let aValue, bValue;
                    
                    if (columnIndex === 0) { // Mã NV
                        aValue = a.cells[0].querySelector('.employee-code').textContent.trim();
                        bValue = b.cells[0].querySelector('.employee-code').textContent.trim();
                    } else if (columnIndex === 1) { // Họ tên
                        aValue = a.cells[1].querySelector('.employee-name').textContent.trim();
                        bValue = b.cells[1].querySelector('.employee-name').textContent.trim();
                    } else if (columnIndex === 2) { // CCCD/CMND
                        aValue = a.cells[2].querySelector('.national-id').textContent.trim();
                        bValue = b.cells[2].querySelector('.national-id').textContent.trim();
                    } else if (columnIndex === 3) { // Số điện thoại
                        aValue = a.cells[3].querySelector('.phone').textContent.trim();
                        bValue = b.cells[3].querySelector('.phone').textContent.trim();
                    } else if (columnIndex === 4) { // Trạng thái
                        aValue = a.cells[4].querySelector('.status').textContent.trim();
                        bValue = b.cells[4].querySelector('.status').textContent.trim();
                    }

                    // So sánh dựa trên kiểu dữ liệu
                    let comparison = 0;
                    if (dataType === 'number') {
                        comparison = aValue - bValue;
                    } else {
                        comparison = aValue.localeCompare(bValue, 'vi', { numeric: true });
                    }

                    return currentSortDirection === 'asc' ? comparison : -comparison;
                });

                // Cập nhật DOM
                rows.forEach(row => tbody.appendChild(row));
            }

            function addEmployee() {
                alert('Chức năng thêm nhân viên sẽ được triển khai');
            }

            function viewEmployee(employeeCode) {
                const row = document.querySelector('tr[data-employee-code="' + employeeCode + '"]');
                if (!row) {
                    alert('Không tìm thấy dữ liệu nhân viên: ' + employeeCode);
                    return;
                }

                const get = (k) => (row.getAttribute(k) || '').trim();
                const setVal = (id, v) => { const el = document.getElementById(id); if (el) el.value = v || ''; };
                const setText = (id, v) => { const el = document.getElementById(id); if (el) el.textContent = v || ''; };

                const avatar = get('data-avatar-url') || '';
                const avatarEl = document.getElementById('modalAvatar');
                if (avatarEl) {
                    avatarEl.src = avatar || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(get('data-full-name') || employeeCode) + '&background=E5E7EB&color=111827';
                }

                setVal('modalEmployeeCode', get('data-employee-code'));
                setVal('modalFullName', get('data-full-name'));
                setVal('modalEmail', get('data-email'));
                setVal('modalPhone', get('data-phone'));
                setVal('modalNationalID', get('data-national-id'));
                setVal('modalGender', get('data-gender'));
                // birthDate from data may be ISO or yyyy-MM-dd
                setVal('modalBirthDate', (get('data-birth-date') || '').substring(0, 10));
                setVal('modalAddress', get('data-address'));
                setVal('modalPosition', get('data-position'));
                setVal('modalStatus', get('data-status'));
                setVal('modalSalary', get('data-salary'));
                setVal('modalBankName', get('data-bank-name'));
                setVal('modalBankAccount', get('data-bank-account'));
                document.getElementById('modalNotes').value = get('data-notes') || '';
                // datetime-local expects yyyy-MM-ddTHH:mm
                const toLocalDT = (s) => {
                    if (!s) return '';
                    const t = s.replace(' ', 'T');
                    return t.length >= 16 ? t.substring(0,16) : t;
                };
                setVal('modalHireDate', toLocalDT(get('data-hire-date')));
                setVal('modalTerminationDate', toLocalDT(get('data-termination-date')));
                setVal('modalCreatedAt', get('data-created-at'));
                setVal('modalUpdatedAt', get('data-updated-at'));

                openEmployeeModal();
            }

            function openEmployeeModal() {
                const overlay = document.getElementById('employeeDetailModal');
                if (!overlay) return;
                overlay.style.display = 'flex';
                // close on outside click
                overlay.addEventListener('click', function onOverlay(e) {
                    if (e.target === overlay) {
                        closeEmployeeModal();
                    }
                }, { once: true });
            }

            function closeEmployeeModal() {
                const overlay = document.getElementById('employeeDetailModal');
                if (!overlay) return;
                overlay.style.display = 'none';
            }

            function editEmployee(employeeCode) {
                alert('Chức năng chỉnh sửa nhân viên sẽ được triển khai cho mã: ' + employeeCode);
            }

            function activateEmployee(employeeCode) {
                if (confirm('Bạn có chắc muốn kích hoạt nhân viên này?')) {
                    alert('Chức năng kích hoạt nhân viên sẽ được triển khai cho mã: ' + employeeCode);
                }
            }

            function deactivateEmployee(employeeCode) {
                if (confirm('Bạn có chắc muốn vô hiệu hóa nhân viên này?')) {
                    alert('Chức năng vô hiệu hóa nhân viên sẽ được triển khai cho mã: ' + employeeCode);
                }
            }

            function exportEmployees() {
                alert('Chức năng xuất file sẽ được triển khai');
            }

            function importEmployees() {
                alert('Chức năng import sẽ được triển khai');
            }

            // Auto search khi gõ
            document.getElementById('searchInput').addEventListener('input', searchEmployees);
            
            // Thêm event listener cho các checkbox filter
            document.querySelectorAll('input[name="positionFilter"], input[name="statusFilter"]').forEach(checkbox => {
                checkbox.addEventListener('change', applyAllFilters);
            });

            // Close modal button and ESC
            (function initEmployeeModalControls(){
                const btn = document.getElementById('employeeModalCloseBtn');
                if (btn) btn.addEventListener('click', closeEmployeeModal);
                document.addEventListener('keydown', function(e){ if (e.key === 'Escape') closeEmployeeModal(); });
            })();
        </script>

<jsp:include page="../includes/footer.jsp" />
