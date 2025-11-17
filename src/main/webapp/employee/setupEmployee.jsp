<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/includes/header.jsp">
  <jsp:param name="page" value="employees"/>
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/setup-employee.css">

<style>
/* Prevent horizontal scroll on setup page */
body {
    overflow-x: hidden !important;
    max-width: 100vw;
}

html {
    overflow-x: hidden !important;
    max-width: 100vw;
}

.setup-container,
.setup-main,
.salary-config-section,
.salary-table-container-main,
.salary-table-container-main > div {
    overflow-x: hidden !important;
    max-width: 100%;
}
</style>

<div class="setup-container">
    <!-- Main Content -->
    <main class="setup-main" style="width: 100%; max-width: 100%;">
        <!-- Header -->
        <div class="setup-header" style="margin-bottom: 2rem;">
            <h1 style="font-size: 2rem; font-weight: 700; color: #111827; margin-bottom: 0.5rem;">
                <i class='bx bx-dollar' style="color: #0080FF; margin-right: 8px;"></i>
                Thiết lập lương
            </h1>
            <p style="color: #6c757d; font-size: 1rem;">Quản lý và điều chỉnh cấu hình lương cho từng nhân viên</p>
        </div>

        <!-- Salary Configuration Section -->
        <div id="salary-section" class="salary-config-section">

            <!-- Search and Filter -->
            <div class="salary-controls" style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding: 16px; background: #f9fafb; border-radius: 8px;">
                <input type="text" id="salarySearchInput" placeholder="Tìm kiếm theo mã, tên nhân viên..." 
                       style="flex: 1; padding: 10px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px;"
                       onkeyup="filterSalaryTable()">
                <button class="btn-setup" onclick="loadSalaryDataMain()" style="white-space: nowrap;">
                    <i class='bx bx-refresh'></i> Tải lại
                </button>
            </div>

            <!-- Salary Table -->
            <div class="salary-table-container-main" style="background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                <div style="width: 100%; overflow: hidden;">
                    <table class="salary-table">
                        <thead>
                            <tr style="background: #f9fafb;">
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">STT</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Nhân viên</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Loại lương</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Lương chính</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Làm thêm</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Thưởng</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Hoa hồng</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Phụ cấp</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Giảm trừ</th>
                                <th style="text-align: left; font-weight: 600; color: #374151; border-bottom: 2px solid #e5e7eb;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="salaryTableBodyMain">
                            <tr>
                                <td colspan="10" style="text-align: center; padding: 40px; color: #6b7280;">
                                    <i class='bx bx-loader-alt bx-spin' style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
                                    Đang tải dữ liệu...
                                </td>
                            </tr>
                        </tbody>
                    </table>
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
                            <th>STT</th>
                            <th>Nhân viên</th>
                            <th>Lương chính</th>
                            <th>Làm thêm</th>
                            <th>Thưởng</th>
                            <th>Hoa hồng</th>
                            <th>Phụ cấp</th>
                            <th>Giảm trừ</th>
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

<!-- Full Compensation Modal -->
<div id="fullCompensationModal" class="edit-comp-modal-overlay" style="display: none;">
    <div class="edit-comp-modal" style="max-width: 700px;">
        <div class="edit-comp-header">
            <h3 id="fullEditModalTitle">Cấu hình lương</h3>
            <button type="button" class="close-btn" onclick="closeFullCompensationModal()">✕</button>
        </div>
        <div class="edit-comp-body">
            <input type="hidden" id="fullEditEmployeeCode">
            <input type="hidden" id="fullEditCompensationId">
            
            <div class="form-group">
                <label>Loại lương <span style="color: red;">*</span></label>
                <select id="fullEditCompensationType" class="form-control" onchange="handleFullCompensationTypeChange()">
                    <option value="">-- Chọn loại --</option>
                    <option value="Fixed">Lương cứng</option>
                    <option value="Hybrid">Theo giờ</option>
                    <option value="PerShift">Theo ca</option>
                </select>
            </div>
            
            <div id="fullSalaryInputContainer" style="display: flex; flex-direction: column; gap: 12px; margin-top: 12px;">
                <div class="form-group" id="fullBaseMonthlySalaryGroup" style="display: none;">
                    <label>Lương tháng cơ bản</label>
                    <input type="number" id="fullBaseMonthlySalary" class="form-control" placeholder="VD: 3000000" step="1000">
                </div>
                <div class="form-group" id="fullHourlyRateGroup" style="display: none;">
                    <label>Lương giờ</label>
                    <input type="number" id="fullHourlyRate" class="form-control" placeholder="VD: 25000" step="1000">
                </div>
                <div class="form-group" id="fullPerShiftRateGroup" style="display: none;">
                    <label>Lương ca</label>
                    <input type="number" id="fullPerShiftRate" class="form-control" placeholder="VD: 100000" step="1000">
                </div>
            </div>
            
            <div class="form-group" style="margin-top: 16px;">
                <label>Làm thêm giờ</label>
                <input type="number" id="fullOvertimeRate" class="form-control" placeholder="VD: 30000 VND/giờ" step="1000">
            </div>
            
            <div class="form-group">
                <label>Thưởng</label>
                <input type="number" id="fullBonusAmount" class="form-control" placeholder="VD: 1000000 VND" step="1000">
            </div>
            
            <div class="form-group">
                <label>Hoa hồng (%)</label>
                <input type="number" id="fullCommissionRate" class="form-control" placeholder="VD: 5.5" step="0.1">
            </div>
            
            <div class="form-group">
                <label>Phụ cấp</label>
                <input type="number" id="fullAllowanceAmount" class="form-control" placeholder="VD: 500000 VND" step="1000">
            </div>
            
            <div class="form-group">
                <label>Giảm trừ</label>
                <input type="number" id="fullDeductionAmount" class="form-control" placeholder="VD: 200000 VND" step="1000">
            </div>
        </div>
        <div class="edit-comp-footer">
            <button type="button" class="btn-cancel" onclick="closeFullCompensationModal()">Hủy</button>
            <button type="button" class="btn-save" onclick="saveFullCompensation()">Lưu</button>
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

.compensation-type-badge {
    display: inline-block;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.compensation-type-badge.fixed {
    background: #dbeafe;
    color: #1e40af;
}

.compensation-type-badge.hybrid {
    background: #d1fae5;
    color: #065f46;
}

.compensation-type-badge.pershift {
    background: #fef3c7;
    color: #92400e;
}

.btn-edit-salary {
    transition: all 0.2s;
}

.btn-edit-salary:hover {
    background: #1d4ed8 !important;
    transform: translateY(-1px);
    box-shadow: 0 2px 4px rgba(37, 99, 235, 0.2);
}

.salary-row {
    transition: background-color 0.2s;
}
</style>

<script>
let employeesData = [];
let compensationsData = {};

// Load data when page loads
document.addEventListener('DOMContentLoaded', function() {
    try {
        // Only load main table data, skip modal data for now
        loadSalaryDataMain();
    } catch (error) {
        console.error('Error loading salary data:', error);
    }
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
    const employeeInfoDiv2 = document.createElement('div');
    employeeInfoDiv2.className = 'employee-info';
    
    const nameDiv2 = document.createElement('div');
    nameDiv2.className = 'employee-name';
    nameDiv2.textContent = employee.fullName || 'N/A';
    
    const codeDiv2 = document.createElement('div');
    codeDiv2.className = 'employee-code';
    codeDiv2.textContent = employee.employeeCode || 'N/A';
    
    employeeInfoDiv2.appendChild(nameDiv2);
    employeeInfoDiv2.appendChild(codeDiv2);
    tdEmployee.appendChild(employeeInfoDiv2);
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
        return '<button class="add-btn" onclick="editMainSalary(\'' + escapeHtml(employeeCode) + '\')">+</button>';
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

    return '<div class="salary-type-info">' +
           '<div class="salary-amount">' + escapeHtml(amount) + '</div>' +
           '<div class="salary-type">' + escapeHtml(type) + '</div>' +
           '</div>';
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


// Load salary data for main table
function loadSalaryDataMain() {
    try {
        console.log('=== loadSalaryDataMain called ===');
        const tbody = document.getElementById('salaryTableBodyMain');
        if (!tbody) {
            console.warn('salaryTableBodyMain not found');
            return;
        }

        tbody.innerHTML = '<tr><td colspan="10" style="text-align: center; padding: 40px; color: #6b7280;"><i class=\'bx bx-loader-alt bx-spin\' style="font-size: 24px; margin-bottom: 8px; display: block;"></i>Đang tải dữ liệu...</td></tr>';

        const url = '${pageContext.request.contextPath}/compensation?action=getAllWithEmployees';
        console.log('Fetching from:', url);
        
        fetch(url)
            .then(response => {
                console.log('Response status:', response.status, response.statusText);
                if (!response.ok) {
                    throw new Error('HTTP ' + response.status + ': ' + response.statusText);
                }
                return response.text();
            })
            .then(text => {
                console.log('Response received, length:', text ? text.length : 0);
                console.log('Response preview:', text ? text.substring(0, 200) : 'empty');
                try {
                    if (!text || text.trim() === '') {
                        throw new Error('Response is empty');
                    }
                    const data = JSON.parse(text);
                    console.log('Parsed data:', data);
                    console.log('Employees count:', data.employees ? data.employees.length : 0);
                    console.log('Compensations count:', data.compensations ? data.compensations.length : 0);
                    
                    employeesData = data.employees || [];
                    compensationsData = {};

                    if (data.compensations && Array.isArray(data.compensations)) {
                        data.compensations.forEach(comp => {
                            compensationsData[comp.employeeCode] = comp;
                        });
                    }

                    console.log('Rendering table with', employeesData.length, 'employees');
                    renderSalaryTableMain();
                } catch (parseError) {
                    console.error('JSON parse error:', parseError);
                    console.error('Response text:', text);
                    throw new Error('Không thể parse JSON response: ' + parseError.message);
                }
            })
            .catch(error => {
                console.error('❌ Error loading salary data:', error);
                console.error('Error stack:', error.stack);
                if (tbody) {
                    tbody.innerHTML = '<tr><td colspan="10" style="text-align: center; padding: 40px; color: red;"><strong>Lỗi tải dữ liệu:</strong><br>' + escapeHtml(error.message) + '<br><small>Vui lòng mở Console (F12) để xem chi tiết</small></td></tr>';
                }
            });
    } catch (error) {
        console.error('Error in loadSalaryDataMain:', error);
    }
}

function renderSalaryTableMain() {
    const tbody = document.getElementById('salaryTableBodyMain');
    if (!tbody) return;

    tbody.innerHTML = '';

    if (employeesData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="10" style="text-align: center; padding: 40px; color: #6b7280;">Không có nhân viên nào.</td></tr>';
        return;
    }

    employeesData.forEach((emp, index) => {
        const comp = compensationsData[emp.employeeCode] || {};
        const row = createSalaryRowMain(index + 1, emp, comp);
        tbody.appendChild(row);
    });
}

function createSalaryRowMain(stt, employee, compensation) {
    const tr = document.createElement('tr');
    tr.className = 'salary-row';
    tr.setAttribute('data-employee-code', employee.employeeCode);
    tr.setAttribute('data-employee-name', employee.fullName || '');

    // STT
    const tdStt = document.createElement('td');
    tdStt.textContent = stt;
    tr.appendChild(tdStt);

    // Nhân viên
    const tdEmployee = document.createElement('td');
    const employeeInfoDiv = document.createElement('div');
    employeeInfoDiv.className = 'employee-info';
    
    const nameDiv = document.createElement('div');
    nameDiv.className = 'employee-name';
    nameDiv.textContent = employee.fullName || 'N/A';
    
    const codeDiv = document.createElement('div');
    codeDiv.className = 'employee-code';
    codeDiv.textContent = employee.employeeCode || 'N/A';
    
    employeeInfoDiv.appendChild(nameDiv);
    employeeInfoDiv.appendChild(codeDiv);
    tdEmployee.appendChild(employeeInfoDiv);
    tr.appendChild(tdEmployee);

    // Loại lương
    const tdType = document.createElement('td');
    if (compensation.compensationType) {
        const typeLabels = {
            'Fixed': 'Lương cứng',
            'Hybrid': 'Theo giờ',
            'PerShift': 'Theo ca'
        };
        const typeClasses = {
            'Fixed': 'fixed',
            'Hybrid': 'hybrid',
            'PerShift': 'pershift'
        };
        const badge = document.createElement('span');
        badge.className = 'compensation-type-badge ' + typeClasses[compensation.compensationType];
        badge.textContent = typeLabels[compensation.compensationType] || compensation.compensationType;
        tdType.appendChild(badge);
    } else {
        tdType.innerHTML = '<span style="color: #9ca3af;">Chưa thiết lập</span>';
    }
    tr.appendChild(tdType);

    // Lương chính
    const tdSalary = document.createElement('td');
    tdSalary.innerHTML = renderMainSalaryMain(employee.employeeCode, compensation);
    tr.appendChild(tdSalary);

    // Làm thêm
    tr.appendChild(renderCompFieldMain(employee.employeeCode, 'overtimeRate', compensation.overtimeRate, 'Làm thêm giờ'));

    // Thưởng
    tr.appendChild(renderCompFieldMain(employee.employeeCode, 'bonusAmount', compensation.bonusAmount, 'Thưởng'));

    // Hoa hồng
    tr.appendChild(renderCompFieldMain(employee.employeeCode, 'commissionRate', compensation.commissionRate, 'Hoa hồng', true));

    // Phụ cấp
    tr.appendChild(renderCompFieldMain(employee.employeeCode, 'allowanceAmount', compensation.allowanceAmount, 'Phụ cấp'));

    // Giảm trừ
    tr.appendChild(renderCompFieldMain(employee.employeeCode, 'deductionAmount', compensation.deductionAmount, 'Giảm trừ'));

    // Thao tác
    const tdAction = document.createElement('td');
    const editBtn = document.createElement('button');
    editBtn.className = 'btn-edit-salary';
    editBtn.style.cssText = 'padding: 6px 12px; background: #2563eb; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 13px; font-weight: 500;';
    editBtn.onclick = function() { openEditSalaryModal(employee.employeeCode); };
    
    const icon = document.createElement('i');
    icon.className = 'bx bx-edit';
    editBtn.appendChild(icon);
    editBtn.appendChild(document.createTextNode(' Chỉnh sửa'));
    
    tdAction.appendChild(editBtn);
    tr.appendChild(tdAction);

    return tr;
}

function renderMainSalaryMain(employeeCode, compensation) {
    if (!compensation || !compensation.compensationType) {
        return '<button class="add-btn" onclick="openEditSalaryModal(\'' + escapeHtml(employeeCode) + '\')" style="background: none; border: 1px dashed #d1d5db; color: #6b7280; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; font-size: 18px;">+</button>';
    }

    let amount = '';
    let type = '';

    switch(compensation.compensationType) {
        case 'Fixed':
            amount = formatCurrency(compensation.baseMonthlySalary) + ' / tháng';
            type = 'Lương cứng';
            break;
        case 'Hybrid':
            // Theo giờ: chỉ hiển thị hourlyRate, không có baseMonthlySalary
            amount = formatCurrency(compensation.hourlyRate) + ' / giờ';
            type = 'Theo giờ';
            break;
        case 'PerShift':
            amount = formatCurrency(compensation.perShiftRate) + ' / ca';
            type = 'Theo ca';
            break;
    }

    return '<div class="salary-type-info">' +
           '<div class="salary-amount">' + escapeHtml(amount) + '</div>' +
           '<div class="salary-type">' + escapeHtml(type) + '</div>' +
           '</div>';
}

function renderCompFieldMain(employeeCode, fieldName, value, label, isPercentage = false) {
    const td = document.createElement('td');

    if (!value) {
        const btn = document.createElement('button');
        btn.className = 'add-btn';
        btn.textContent = '+';
        btn.onclick = () => editCompensationField(employeeCode, fieldName, label, value);
        btn.style.cssText = 'background: none; border: 1px dashed #d1d5db; color: #6b7280; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; font-size: 18px;';
        td.appendChild(btn);
    } else {
        const div = document.createElement('div');
        div.className = 'value-display';
        div.style.cssText = 'display: flex; align-items: center; gap: 8px;';

        const span = document.createElement('span');
        span.className = 'value-text';
        span.textContent = isPercentage ? value + '%' : formatCurrency(value);
        span.style.cssText = 'font-weight: 500; color: #111827;';

        const editBtn = document.createElement('button');
        editBtn.className = 'edit-icon';
        editBtn.innerHTML = '✎';
        editBtn.onclick = () => editCompensationField(employeeCode, fieldName, label, value);
        editBtn.style.cssText = 'background: none; border: none; color: #6b7280; cursor: pointer; padding: 4px; border-radius: 4px; font-size: 14px; opacity: 0; transition: all 0.2s;';
        editBtn.onmouseover = () => editBtn.style.opacity = '1';
        editBtn.onmouseout = () => editBtn.style.opacity = '0';

        div.appendChild(span);
        div.appendChild(editBtn);
        td.appendChild(div);
    }

    return td;
}

function openEditSalaryModal(employeeCode) {
    const employee = employeesData.find(e => e.employeeCode === employeeCode);
    if (!employee) {
        alert('Không tìm thấy nhân viên');
        return;
    }

    const compensation = compensationsData[employeeCode] || {};
    
    // Populate edit compensation modal
    document.getElementById('editCompEmployeeName').textContent = 'Chỉnh sửa lương - ' + employee.fullName;
    document.getElementById('editEmployeeCode').value = employeeCode;
    document.getElementById('editCompensationId').value = compensation.compensationId || '';
    
    // Show full compensation form in modal
    openFullCompensationModal(employeeCode, employee, compensation);
}

function openFullCompensationModal(employeeCode, employee, compensation) {
    try {
        // Get full compensation modal (already exists in HTML)
        let fullModal = document.getElementById('fullCompensationModal');
        if (!fullModal) {
            console.error('fullCompensationModal not found');
            return;
        }
        
        // Populate form
        const titleEl = document.getElementById('fullEditModalTitle');
        if (titleEl) {
            titleEl.textContent = 'Cấu hình lương - ' + escapeHtml(employee.fullName);
        }
        
        const codeEl = document.getElementById('fullEditEmployeeCode');
        if (codeEl) codeEl.value = employeeCode;
        
        const compIdEl = document.getElementById('fullEditCompensationId');
        if (compIdEl) compIdEl.value = compensation.compensationId || '';
        
        const typeEl = document.getElementById('fullEditCompensationType');
        if (typeEl) typeEl.value = compensation.compensationType || '';
        
        const baseSalaryEl = document.getElementById('fullBaseMonthlySalary');
        if (baseSalaryEl) baseSalaryEl.value = compensation.baseMonthlySalary || '';
        
        const hourlyRateEl = document.getElementById('fullHourlyRate');
        if (hourlyRateEl) hourlyRateEl.value = compensation.hourlyRate || '';
        
        const perShiftRateEl = document.getElementById('fullPerShiftRate');
        if (perShiftRateEl) perShiftRateEl.value = compensation.perShiftRate || '';
        
        const overtimeRateEl = document.getElementById('fullOvertimeRate');
        if (overtimeRateEl) overtimeRateEl.value = compensation.overtimeRate || '';
        
        const bonusAmountEl = document.getElementById('fullBonusAmount');
        if (bonusAmountEl) bonusAmountEl.value = compensation.bonusAmount || '';
        
        const commissionRateEl = document.getElementById('fullCommissionRate');
        if (commissionRateEl) commissionRateEl.value = compensation.commissionRate || '';
        
        const allowanceAmountEl = document.getElementById('fullAllowanceAmount');
        if (allowanceAmountEl) allowanceAmountEl.value = compensation.allowanceAmount || '';
        
        const deductionAmountEl = document.getElementById('fullDeductionAmount');
        if (deductionAmountEl) deductionAmountEl.value = compensation.deductionAmount || '';
        
        handleFullCompensationTypeChange();
        
        fullModal.style.display = 'flex';
    } catch (error) {
        console.error('Error opening full compensation modal:', error);
        alert('Có lỗi khi mở form chỉnh sửa lương');
    }
}

function handleFullCompensationTypeChange() {
    const type = document.getElementById('fullEditCompensationType').value;
    const baseGroup = document.getElementById('fullBaseMonthlySalaryGroup');
    const hourlyGroup = document.getElementById('fullHourlyRateGroup');
    const perShiftGroup = document.getElementById('fullPerShiftRateGroup');
    
    baseGroup.style.display = 'none';
    hourlyGroup.style.display = 'none';
    perShiftGroup.style.display = 'none';
    
    if (type === 'Fixed') {
        baseGroup.style.display = 'block';
    } else if (type === 'Hybrid') {
        // Theo giờ: chỉ hiển thị hourlyRate, không có baseMonthlySalary
        hourlyGroup.style.display = 'block';
    } else if (type === 'PerShift') {
        perShiftGroup.style.display = 'block';
    }
}

function closeFullCompensationModal() {
    const modal = document.getElementById('fullCompensationModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Close modal when clicking outside
document.addEventListener('DOMContentLoaded', function() {
    // Setup close on outside click for full compensation modal
    document.addEventListener('click', function(e) {
        const fullModal = document.getElementById('fullCompensationModal');
        if (fullModal && fullModal.style.display === 'flex' && e.target === fullModal) {
            closeFullCompensationModal();
        }
    });
});

function saveFullCompensation() {
    const employeeCode = document.getElementById('fullEditEmployeeCode').value;
    const compensationType = document.getElementById('fullEditCompensationType').value;
    const compensationId = document.getElementById('fullEditCompensationId').value;
    
    if (!compensationType) {
        alert('Vui lòng chọn loại lương');
        return;
    }
    
    const formData = new URLSearchParams();
    formData.append('action', compensationId ? 'update' : 'save');
    formData.append('employeeCode', employeeCode);
    formData.append('compensationType', compensationType);
    
    if (compensationId) {
        formData.append('compensationId', compensationId);
    }
    
    formData.append('baseMonthlySalary', document.getElementById('fullBaseMonthlySalary').value || '');
    formData.append('hourlyRate', document.getElementById('fullHourlyRate').value || '');
    formData.append('perShiftRate', document.getElementById('fullPerShiftRate').value || '');
    formData.append('overtimeRate', document.getElementById('fullOvertimeRate').value || '');
    formData.append('bonusAmount', document.getElementById('fullBonusAmount').value || '');
    formData.append('commissionRate', document.getElementById('fullCommissionRate').value || '');
    formData.append('allowanceAmount', document.getElementById('fullAllowanceAmount').value || '');
    formData.append('deductionAmount', document.getElementById('fullDeductionAmount').value || '');
    
    console.log('Saving compensation:', {
        employeeCode: employeeCode,
        compensationType: compensationType,
        compensationId: compensationId
    });
    
    fetch('${pageContext.request.contextPath}/compensation', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData
    })
    .then(response => {
        console.log('Response status:', response.status);
        if (!response.ok) {
            return response.text().then(text => {
                console.error('Response error:', text);
                throw new Error('HTTP ' + response.status + ': ' + text);
            });
        }
        return response.text();
    })
    .then(text => {
        console.log('Response text:', text);
        try {
            const result = JSON.parse(text);
            console.log('Parsed result:', result);
            if (result.success) {
                closeFullCompensationModal();
                loadSalaryDataMain();
                alert('Lưu cấu hình lương thành công!');
            } else {
                alert('Lỗi: ' + (result.error || 'Không thể lưu'));
            }
        } catch (parseError) {
            console.error('JSON parse error:', parseError);
            console.error('Response text:', text);
            alert('Lỗi: Không thể parse response từ server');
        }
    })
    .catch(error => {
        console.error('Error saving:', error);
        alert('Có lỗi xảy ra khi lưu: ' + error.message);
    });
}

function filterSalaryTable() {
    const searchTerm = document.getElementById('salarySearchInput').value.toLowerCase().trim();
    const rows = document.querySelectorAll('#salaryTableBodyMain tr.salary-row');

    rows.forEach(row => {
        const employeeCode = row.getAttribute('data-employee-code') || '';
        const employeeName = row.getAttribute('data-employee-name') || '';
        
        if (searchTerm === '' || 
            employeeCode.toLowerCase().includes(searchTerm) || 
            employeeName.toLowerCase().includes(searchTerm)) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
</script>

<jsp:include page="/includes/footer.jsp"/>


