<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/includes/header.jsp">
  <jsp:param name="page" value="employees"/>
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/setup-employee.css">

<div class="setup-container">
    <!-- Sidebar -->
    <aside class="setup-sidebar">
        <h2>Thiết lập nhân viên</h2>
        <ul class="sidebar-menu">
            <li>
                <a href="#" class="active">
                    <i class='bx bx-cog'></i>
                    <span>Khởi tạo</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-time'></i>
                    <span>Ca làm việc</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-clipboard'></i>
                    <span>Chấm công</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-dollar'></i>
                    <span>Tính lương</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-calendar'></i>
                    <span>Ngày làm & Nghỉ</span>
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="setup-main">
        <div class="setup-header">
            <h1>Thiết lập nhanh</h1>
            <p>Chỉ vài bước cài đặt để quản lý nhân viên hiệu quả, tối ưu vận hành và tính lương chính xác</p>
        </div>

        <div class="setup-checklist">
            <!-- Thêm nhân viên -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Thêm nhân viên</h3>
                        <p>Cửa hàng đang có 3 nhân viên. <a href="${pageContext.request.contextPath}/employees">Xem danh sách</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="${pageContext.request.contextPath}/employees" class="btn-setup">Thêm nhân viên</a>
                </div>
            </div>

            <!-- Tạo ca làm việc -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Tạo ca làm việc</h3>
                        <p>Cửa hàng đang có 3 ca làm việc. <a href="${pageContext.request.contextPath}/schedule">Xem danh sách</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="${pageContext.request.contextPath}/schedule" class="btn-setup">Tạo ca</a>
                </div>
            </div>

            <!-- Xếp lịch làm việc -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Xếp lịch làm việc</h3>
                        <p>Đã xếp lịch cho 1/3 nhân viên trong cửa hàng. <a href="${pageContext.request.contextPath}/schedule">Xem lịch</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="${pageContext.request.contextPath}/schedule" class="btn-setup">Xếp lịch</a>
                </div>
            </div>

            <!-- Hình thức chấm công -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Hình thức chấm công</h3>
                        <p>Cửa hàng đã thiết lập hình thức chấm công. <a href="#">Xem chi tiết</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="#" class="btn-setup">Thiết lập</a>
                </div>
            </div>

            <!-- Thiết lập lương -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Thiết lập lương</h3>
                        <p>Đã thiết lập lương cho <span id="salaryConfigCount">0</span>/<span id="totalEmployeeCount">0</span> nhân viên. <a href="#" onclick="openSalaryModal(); return false;">Xem chi tiết</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="#" class="btn-setup" onclick="openSalaryModal(); return false;">Thiết lập</a>
                </div>
            </div>

            <!-- Thiết lập bảng lương -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Thiết lập bảng lương</h3>
                        <p>Theo dõi chính xác và tự động tính lương của nhân viên. <a href="#">Xem danh sách</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="#" class="btn-setup">Tạo bảng lương</a>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Salary Configuration Modal -->
<div id="salaryModal" class="salary-modal-overlay" style="display: none;">
    <div class="salary-modal">
        <div class="salary-modal-header">
            <h2>Thiết lập lương</h2>
            <button type="button" class="close-btn" onclick="closeSalaryModal()">✕</button>
        </div>
        <div class="salary-modal-body">
            <!-- Debug Info (can be removed in production) -->
            <div id="debugInfo" style="background: #fff3cd; padding: 12px; border-radius: 6px; margin-bottom: 16px; display: none;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <strong>🔧 Debug Mode</strong>
                        <span id="debugStatus" style="margin-left: 12px; font-size: 13px;">Đang tải...</span>
                    </div>
                    <button type="button" onclick="testWithMockData()" style="padding: 6px 12px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 13px;">
                        Test với dữ liệu mẫu
                    </button>
                </div>
            </div>

            <div class="salary-table-container">
                <table class="salary-table">
                    <thead>
                        <tr>
                            <th style="width: 50px;">STT</th>
                            <th style="width: 200px;">Nhân viên</th>
                            <th style="width: 200px;">Lương chính</th>
                            <th style="width: 120px;">Làm thêm</th>
                            <th style="width: 120px;">Thưởng</th>
                            <th style="width: 120px;">Hoa hồng</th>
                            <th style="width: 120px;">Phụ cấp</th>
                            <th style="width: 120px;">Giảm trừ</th>
                        </tr>
                    </thead>
                    <tbody id="salaryTableBody">
                        <!-- Rows will be populated by JavaScript -->
                    </tbody>
                </table>
            </div>
        </div>
        <div class="salary-modal-footer">
            <button type="button" class="btn-done" onclick="closeSalaryModal()">Xong</button>
        </div>
    </div>
</div>

<!-- Edit Compensation Modal -->
<div id="editCompensationModal" class="edit-comp-modal-overlay" style="display: none;">
    <div class="edit-comp-modal">
        <div class="edit-comp-header">
            <h3 id="editCompEmployeeName">Chỉnh sửa lương</h3>
            <button type="button" class="close-btn" onclick="closeEditCompModal()">✕</button>
        </div>
        <div class="edit-comp-body">
            <input type="hidden" id="editEmployeeCode">
            <input type="hidden" id="editCompensationId">
            <input type="hidden" id="editFieldName">

            <div class="form-group">
                <label id="editFieldLabel">Giá trị</label>
                <input type="number" id="editFieldValue" class="form-control" step="1000">
            </div>
        </div>
        <div class="edit-comp-footer">
            <button type="button" class="btn-cancel" onclick="closeEditCompModal()">Hủy</button>
            <button type="button" class="btn-save" onclick="saveCompField()">Lưu</button>
        </div>
    </div>
</div>

<style>
.salary-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
}

.salary-modal {
    background: white;
    width: 90%;
    max-width: 1400px;
    max-height: 85vh;
    border-radius: 12px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
    display: flex;
    flex-direction: column;
}

.salary-modal-header {
    padding: 20px 24px;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.salary-modal-header h2 {
    margin: 0;
    font-size: 20px;
    font-weight: 600;
    color: #111827;
}

.close-btn {
    background: none;
    border: none;
    font-size: 24px;
    cursor: pointer;
    color: #6b7280;
    padding: 4px 8px;
    border-radius: 6px;
    transition: all 0.2s;
}

.close-btn:hover {
    background: #f3f4f6;
    color: #111827;
}

.salary-modal-body {
    flex: 1;
    overflow: auto;
    padding: 20px 24px;
}

.salary-table-container {
    overflow-x: auto;
}

.salary-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
}

.salary-table thead {
    background: #f9fafb;
    position: sticky;
    top: 0;
    z-index: 10;
}

.salary-table th {
    padding: 12px 16px;
    text-align: left;
    font-weight: 600;
    color: #374151;
    border-bottom: 2px solid #e5e7eb;
}

.salary-table tbody tr {
    border-bottom: 1px solid #f3f4f6;
}

.salary-table tbody tr:hover {
    background: #f9fafb;
}

.salary-table td {
    padding: 12px 16px;
    color: #111827;
}

.employee-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.employee-name {
    font-weight: 500;
    color: #111827;
}

.employee-code {
    font-size: 12px;
    color: #6b7280;
}

.salary-type-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.salary-amount {
    font-weight: 500;
    color: #111827;
}

.salary-type {
    font-size: 12px;
    color: #6b7280;
}

.add-btn {
    background: none;
    border: 1px dashed #d1d5db;
    color: #6b7280;
    width: 32px;
    height: 32px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
}

.add-btn:hover {
    border-color: #2563eb;
    color: #2563eb;
    background: #eff6ff;
}

.value-display {
    display: flex;
    align-items: center;
    gap: 8px;
}

.value-text {
    font-weight: 500;
    color: #111827;
}

.edit-icon {
    background: none;
    border: none;
    color: #6b7280;
    cursor: pointer;
    padding: 4px;
    border-radius: 4px;
    font-size: 14px;
    opacity: 0;
    transition: all 0.2s;
}

.value-display:hover .edit-icon {
    opacity: 1;
}

.edit-icon:hover {
    background: #f3f4f6;
    color: #2563eb;
}

.salary-modal-footer {
    padding: 16px 24px;
    border-top: 1px solid #e5e7eb;
    display: flex;
    justify-content: flex-end;
}

.btn-done {
    padding: 10px 24px;
    background: #2563eb;
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-done:hover {
    background: #1d4ed8;
}

/* Edit Compensation Modal */
.edit-comp-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10000;
}

.edit-comp-modal {
    background: white;
    width: 90%;
    max-width: 500px;
    border-radius: 12px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.edit-comp-header {
    padding: 20px 24px;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.edit-comp-header h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
}

.edit-comp-body {
    padding: 24px;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.form-group label {
    font-size: 14px;
    font-weight: 500;
    color: #374151;
}

.form-control {
    padding: 10px 12px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-size: 14px;
    transition: all 0.2s;
}

.form-control:focus {
    outline: none;
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.edit-comp-footer {
    padding: 16px 24px;
    border-top: 1px solid #e5e7eb;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
}

.btn-cancel {
    padding: 10px 20px;
    background: white;
    color: #374151;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-cancel:hover {
    background: #f3f4f6;
}

.btn-save {
    padding: 10px 20px;
    background: #2563eb;
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-save:hover {
    background: #1d4ed8;
}
</style>

<script>
let employeesData = [];
let compensationsData = {};

// Load data when page loads
document.addEventListener('DOMContentLoaded', function() {
    loadSalaryData();
});

function openSalaryModal() {
    console.log('=== openSalaryModal called ===');
    document.getElementById('salaryModal').style.display = 'flex';

    // Show debug info
    document.getElementById('debugInfo').style.display = 'block';
    document.getElementById('debugStatus').textContent = 'Đang tải dữ liệu từ server...';

    loadSalaryData();
}

// Test function - to test with mock data
function testWithMockData() {
    console.log('=== Testing with mock data ===');

    // Create mock employees
    employeesData = [
        { employeeCode: 'EMP001', fullName: 'Nguyễn Văn A' },
        { employeeCode: 'EMP002', fullName: 'Trần Thị B' },
        { employeeCode: 'EMP003', fullName: 'Lê Văn C' },
        { employeeCode: 'EMP004', fullName: 'Phạm Thị D' },
        { employeeCode: 'EMP005', fullName: 'Hoàng Văn E' }
    ];

    // Mock some compensations
    compensationsData = {
        'EMP001': {
            compensationId: 'test-1',
            employeeCode: 'EMP001',
            compensationType: 'Fixed',
            baseMonthlySalary: 5000000,
            overtimeRate: 30000,
            bonusAmount: 1000000
        },
        'EMP002': {
            compensationId: 'test-2',
            employeeCode: 'EMP002',
            compensationType: 'Hybrid',
            hourlyRate: 25000,
            commissionRate: 5.5
        }
    };

    console.log('Mock data created:', employeesData.length, 'employees');

    // Update debug status
    const debugStatus = document.getElementById('debugStatus');
    if (debugStatus) {
        debugStatus.textContent = '✓ Test Mode: ' + employeesData.length + ' nhân viên mẫu, ' +
                                Object.keys(compensationsData).length + ' cấu hình mẫu';
        debugStatus.style.color = 'blue';
    }

    renderSalaryTable();
    updateCounts();
}

function closeSalaryModal() {
    document.getElementById('salaryModal').style.display = 'none';
}

function loadSalaryData() {
    console.log('=== loadSalaryData called ===');

    // Show loading in table
    const tbody = document.getElementById('salaryTableBody');
    tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px;">Đang tải dữ liệu...</td></tr>';

    // Fetch employees and compensations
    const url = '${pageContext.request.contextPath}/compensation?action=getAllWithEmployees';
    console.log('Fetching from:', url);

    fetch(url)
        .then(response => {
            console.log('Response status:', response.status);
            console.log('Response ok:', response.ok);

            if (!response.ok) {
                throw new Error('HTTP ' + response.status + ': ' + response.statusText);
            }
            return response.text(); // Get as text first to see raw response
        })
        .then(text => {
            console.log('Raw response:', text.substring(0, 200));

            // Try to parse as JSON
            try {
                const data = JSON.parse(text);
                console.log('Parsed data:', data);

                employeesData = data.employees || [];
                compensationsData = {};

                // Build compensation map
                if (data.compensations && Array.isArray(data.compensations)) {
                    data.compensations.forEach(comp => {
                        compensationsData[comp.employeeCode] = comp;
                    });
                }

                console.log('✓ Employees loaded:', employeesData.length);
                console.log('✓ Compensations loaded:', Object.keys(compensationsData).length);

                // Update debug status
                const debugStatus = document.getElementById('debugStatus');
                if (debugStatus) {
                    debugStatus.textContent = '✓ Đã tải: ' + employeesData.length + ' nhân viên, ' +
                                            Object.keys(compensationsData).length + ' cấu hình lương';
                    debugStatus.style.color = 'green';
                }

                // Always render table if we have employees
                if (employeesData.length > 0) {
                    renderSalaryTable();
                    updateCounts();
                } else {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px;">Không có nhân viên nào.</td></tr>';
                    if (debugStatus) {
                        debugStatus.textContent = '⚠ Không có nhân viên trong database';
                        debugStatus.style.color = 'orange';
                    }
                }
            } catch (parseError) {
                console.error('JSON parse error:', parseError);
                console.error('Response text:', text);
                throw new Error('Không thể parse JSON response: ' + parseError.message);
            }
        })
        .catch(error => {
            console.error('❌ Error loading salary data:', error);
            console.error('Error stack:', error.stack);

            // Update debug status
            const debugStatus = document.getElementById('debugStatus');
            if (debugStatus) {
                debugStatus.textContent = '✗ Lỗi: ' + error.message;
                debugStatus.style.color = 'red';
            }

            tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px; color: red;">' +
                             '<strong>Lỗi tải dữ liệu:</strong><br>' + error.message +
                             '<br><br><small>Kiểm tra console (F12) để xem chi tiết<br>' +
                             'Hoặc click nút "Test với dữ liệu mẫu" ở trên để test giao diện</small>' +
                             '</td></tr>';
        });
}

function renderSalaryTable() {
    console.log('=== renderSalaryTable called ===');
    console.log('Rendering', employeesData.length, 'employees');

    const tbody = document.getElementById('salaryTableBody');
    tbody.innerHTML = '';

    if (employeesData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px;">Không có nhân viên nào.</td></tr>';
        return;
    }

    employeesData.forEach((emp, index) => {
        const comp = compensationsData[emp.employeeCode] || {};
        const row = createSalaryRow(index + 1, emp, comp);
        tbody.appendChild(row);
    });

    console.log('✓ Table rendered with', employeesData.length, 'rows');
}

function createSalaryRow(stt, employee, compensation) {
    const tr = document.createElement('tr');

    // STT
    const tdStt = document.createElement('td');
    tdStt.textContent = stt;
    tr.appendChild(tdStt);

    // Nhân viên
    const tdEmployee = document.createElement('td');
    tdEmployee.innerHTML = `
        <div class="employee-info">
            <div class="employee-name">${employee.fullName || 'N/A'}</div>
            <div class="employee-code">${employee.employeeCode || 'N/A'}</div>
        </div>
    `;
    tr.appendChild(tdEmployee);

    // Lương chính
    const tdSalary = document.createElement('td');
    tdSalary.innerHTML = renderMainSalary(employee.employeeCode, compensation);
    tr.appendChild(tdSalary);

    // Làm thêm
    tr.appendChild(renderCompField(employee.employeeCode, 'overtimeRate', compensation.overtimeRate, 'Làm thêm giờ'));

    // Thưởng
    tr.appendChild(renderCompField(employee.employeeCode, 'bonusAmount', compensation.bonusAmount, 'Thưởng'));

    // Hoa hồng
    tr.appendChild(renderCompField(employee.employeeCode, 'commissionRate', compensation.commissionRate, 'Hoa hồng', true));

    // Phụ cấp
    tr.appendChild(renderCompField(employee.employeeCode, 'allowanceAmount', compensation.allowanceAmount, 'Phụ cấp'));

    // Giảm trừ
    tr.appendChild(renderCompField(employee.employeeCode, 'deductionAmount', compensation.deductionAmount, 'Giảm trừ'));

    return tr;
}

function renderMainSalary(employeeCode, compensation) {
    if (!compensation || !compensation.compensationType) {
        return `<button class="add-btn" onclick="editMainSalary('${employeeCode}')">+</button>`;
    }

    let amount = '';
    let type = '';

    switch(compensation.compensationType) {
        case 'Fixed':
            amount = formatCurrency(compensation.baseMonthlySalary) + ' / tháng';
            type = 'Lương cứng';
            break;
        case 'Hybrid':
            amount = formatCurrency(compensation.hourlyRate) + ' / giờ';
            type = 'Theo giờ';
            break;
        case 'PerShift':
            amount = formatCurrency(compensation.perShiftRate) + ' / ca';
            type = 'Theo ca làm việc';
            break;
    }

    return `
        <div class="salary-type-info">
            <div class="salary-amount">${amount}</div>
            <div class="salary-type">${type}</div>
        </div>
    `;
}

function renderCompField(employeeCode, fieldName, value, label, isPercentage = false) {
    const td = document.createElement('td');

    if (!value) {
        const btn = document.createElement('button');
        btn.className = 'add-btn';
        btn.textContent = '+';
        btn.onclick = () => editCompensationField(employeeCode, fieldName, label, value);
        td.appendChild(btn);
    } else {
        const div = document.createElement('div');
        div.className = 'value-display';

        const span = document.createElement('span');
        span.className = 'value-text';
        span.textContent = isPercentage ? value + '%' : formatCurrency(value);

        const editBtn = document.createElement('button');
        editBtn.className = 'edit-icon';
        editBtn.innerHTML = '✎';
        editBtn.onclick = () => editCompensationField(employeeCode, fieldName, label, value);

        div.appendChild(span);
        div.appendChild(editBtn);
        td.appendChild(div);
    }

    return td;
}

function formatCurrency(amount) {
    if (!amount) return '0';
    return new Intl.NumberFormat('vi-VN').format(amount);
}

function editMainSalary(employeeCode) {
    // Open employee detail modal with salary tab
    window.location.href = '${pageContext.request.contextPath}/employees';
}

function editCompensationField(employeeCode, fieldName, label, currentValue) {
    const employee = employeesData.find(e => e.employeeCode === employeeCode);
    if (!employee) return;

    document.getElementById('editCompEmployeeName').textContent = employee.fullName + ' - ' + label;
    document.getElementById('editEmployeeCode').value = employeeCode;
    document.getElementById('editFieldName').value = fieldName;
    document.getElementById('editFieldLabel').textContent = label;
    document.getElementById('editFieldValue').value = currentValue || '';

    const compensation = compensationsData[employeeCode];
    if (compensation) {
        document.getElementById('editCompensationId').value = compensation.compensationId || '';
    }

    document.getElementById('editCompensationModal').style.display = 'flex';
}

function closeEditCompModal() {
    document.getElementById('editCompensationModal').style.display = 'none';
}

function saveCompField() {
    const employeeCode = document.getElementById('editEmployeeCode').value;
    const fieldName = document.getElementById('editFieldName').value;
    const fieldValue = document.getElementById('editFieldValue').value;
    const compensationId = document.getElementById('editCompensationId').value;

    if (!fieldValue || !employeeCode) {
        alert('Vui lòng nhập giá trị');
        return;
    }

    // Get existing compensation or create new one
    const compensation = compensationsData[employeeCode] || {};

    const formData = new URLSearchParams();
    formData.append('action', compensationId ? 'update' : 'save');
    formData.append('employeeCode', employeeCode);

    if (compensationId) {
        formData.append('compensationId', compensationId);
    }

    // Set field value
    formData.append(fieldName, fieldValue);

    // Set other fields from existing compensation
    formData.append('compensationType', compensation.compensationType || 'Fixed');
    formData.append('baseMonthlySalary', compensation.baseMonthlySalary || '');
    formData.append('hourlyRate', compensation.hourlyRate || '');
    formData.append('perShiftRate', compensation.perShiftRate || '');
    formData.append('overtimeRate', fieldName === 'overtimeRate' ? fieldValue : (compensation.overtimeRate || ''));
    formData.append('bonusAmount', fieldName === 'bonusAmount' ? fieldValue : (compensation.bonusAmount || ''));
    formData.append('commissionRate', fieldName === 'commissionRate' ? fieldValue : (compensation.commissionRate || ''));
    formData.append('allowanceAmount', fieldName === 'allowanceAmount' ? fieldValue : (compensation.allowanceAmount || ''));
    formData.append('deductionAmount', fieldName === 'deductionAmount' ? fieldValue : (compensation.deductionAmount || ''));

    fetch('${pageContext.request.contextPath}/compensation', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            closeEditCompModal();
            loadSalaryData();
            alert('Lưu thành công!');
        } else {
            alert('Lỗi: ' + (result.error || 'Không thể lưu'));
        }
    })
    .catch(error => {
        console.error('Error saving:', error);
        alert('Có lỗi xảy ra khi lưu');
    });
}

function updateCounts() {
    const totalCount = employeesData.length;
    const configuredCount = Object.keys(compensationsData).length;

    document.getElementById('totalEmployeeCount').textContent = totalCount;
    document.getElementById('salaryConfigCount').textContent = configuredCount;
}
</script>

<jsp:include page="/includes/footer.jsp"/>


