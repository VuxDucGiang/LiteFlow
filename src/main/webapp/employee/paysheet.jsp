<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="../includes/header.jsp">
  <jsp:param name="page" value="paysheet" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/employee.css">
<style>
    .paysheet-controls {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 24px;
        background: white;
        padding: 16px;
        border-radius: 12px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    
    .month-year-selector {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .month-year-selector select,
    .month-year-selector input {
        padding: 8px 12px;
        border: 1px solid #d1d5db;
        border-radius: 6px;
        font-size: 14px;
    }
    
    .paysheet-table {
        background: white;
        border-radius: 12px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        overflow: hidden;
    }
    
    .paysheet-table table {
        width: 100%;
        border-collapse: collapse;
    }
    
    .paysheet-table thead {
        background: #f9fafb;
    }
    
    .paysheet-table th {
        padding: 12px 16px;
        text-align: left;
        font-weight: 600;
        color: #374151;
        border-bottom: 2px solid #e5e7eb;
    }
    
    .paysheet-table td {
        padding: 12px 16px;
        border-bottom: 1px solid #e5e7eb;
    }
    
    .paysheet-table tbody tr:hover {
        background: #f9fafb;
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
    
    .paid-badge {
        display: inline-block;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
        background: #d1fae5;
        color: #065f46;
    }
    
    .unpaid-badge {
        display: inline-block;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
        background: #fee2e2;
        color: #991b1b;
    }
    
    .btn-mark-paid {
        padding: 6px 12px;
        background: #10b981;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-size: 13px;
        font-weight: 600;
    }
    
    .btn-mark-paid:hover {
        background: #059669;
    }
    
    .btn-mark-paid:disabled {
        background: #9ca3af;
        cursor: not-allowed;
    }
    
    .currency {
        font-weight: 600;
        color: #111827;
    }
</style>

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
    </div>

    <!-- Month/Year Selector -->
    <div class="paysheet-controls">
        <div class="month-year-selector">
            <label style="font-weight: 600;">Tháng/Năm:</label>
            <select id="monthSelect" onchange="loadPayroll()">
                <option value="1">Tháng 1</option>
                <option value="2">Tháng 2</option>
                <option value="3">Tháng 3</option>
                <option value="4">Tháng 4</option>
                <option value="5">Tháng 5</option>
                <option value="6">Tháng 6</option>
                <option value="7">Tháng 7</option>
                <option value="8">Tháng 8</option>
                <option value="9">Tháng 9</option>
                <option value="10">Tháng 10</option>
                <option value="11">Tháng 11</option>
                <option value="12">Tháng 12</option>
            </select>
            <input type="number" id="yearSelect" min="2020" max="2030" onchange="loadPayroll()" />
            <button class="btn btn-primary" onclick="loadPayroll()">
                <i class='bx bx-refresh'></i> Tải lại
            </button>
        </div>
    </div>

    <!-- Statistics -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-number" id="totalPayrollCount">0</div>
            <div class="stat-label">Tổng nhân viên</div>
        </div>
        <div class="stat-card">
            <div class="stat-number currency" id="totalSalaryAmount">0 ₫</div>
            <div class="stat-label">Tổng tiền lương tháng</div>
        </div>
        <div class="stat-card">
            <div class="stat-number" id="paidCount">0</div>
            <div class="stat-label">Đã thanh toán</div>
        </div>
        <div class="stat-card">
            <div class="stat-number currency" id="totalRemainingAmount">0 ₫</div>
            <div class="stat-label">Tổng chưa thanh toán</div>
        </div>
    </div>

    <!-- Payroll Table -->
    <div class="paysheet-table" id="payrollTableContainer" style="display: none;">
        <table>
            <thead>
                <tr>
                    <th>Mã NV</th>
                    <th>Họ tên</th>
                    <th>Loại lương</th>
                    <th>Tổng lương</th>
                    <th>Phụ cấp</th>
                    <th>Thưởng</th>
                    <th>Giảm trừ</th>
                    <th>Đã thanh toán</th>
                    <th>Chưa nhận</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody id="payrollTableBody">
                <!-- Data will be loaded here -->
            </tbody>
        </table>
    </div>

    <!-- Empty State -->
    <div id="emptyState" style="background: white; border-radius: 12px; padding: 48px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
        <i class='bx bx-money' style="font-size: 64px; color: #d1d5db; margin-bottom: 16px;"></i>
        <h3 style="font-size: 20px; font-weight: 600; margin: 0 0 8px 0; color: #374151;">
            Đang tải dữ liệu...
        </h3>
    </div>
</div>

<script>
    const CONTEXT_PATH = '<c:out value="${pageContext.request.contextPath}" />';

    // Initialize current month/year
    document.addEventListener('DOMContentLoaded', function() {
        const now = new Date();
        document.getElementById('monthSelect').value = now.getMonth() + 1;
        document.getElementById('yearSelect').value = now.getFullYear();
        loadPayroll();
    });

    function formatCurrency(amount) {
        if (!amount || amount === '0' || amount === 0) return '0 ₫';
        return new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND'
        }).format(parseFloat(amount));
    }

    function getCompensationTypeLabel(type) {
        switch(type) {
            case 'Fixed': return 'Lương cứng';
            case 'Hybrid': return 'Theo giờ';
            case 'PerShift': return 'Theo ca';
            default: return type;
        }
    }

    function getCompensationTypeClass(type) {
        switch(type) {
            case 'Fixed': return 'fixed';
            case 'Hybrid': return 'hybrid';
            case 'PerShift': return 'pershift';
            default: return '';
        }
    }

    async function loadPayroll() {
        const month = document.getElementById('monthSelect').value;
        const year = document.getElementById('yearSelect').value;

        try {
            const response = await fetch(CONTEXT_PATH + '/api/payroll/list?month=' + month + '&year=' + year);
            if (!response.ok) {
                throw new Error('Failed to load payroll');
            }

            const data = await response.json();
            
            if (data.success) {
                updateStatistics(data);
                updatePayrollTable(data.entries);
            } else {
                console.error('Error loading payroll:', data.error);
                showError('Không thể tải dữ liệu bảng lương');
            }
        } catch (error) {
            console.error('Error loading payroll:', error);
            showError('Có lỗi xảy ra khi tải dữ liệu');
        }
    }

    function updateStatistics(data) {
        document.getElementById('totalPayrollCount').textContent = data.entries ? data.entries.length : 0;
        document.getElementById('totalSalaryAmount').textContent = formatCurrency(data.totalSalary || 0);
        document.getElementById('paidCount').textContent = data.paidCount || 0;
        document.getElementById('totalRemainingAmount').textContent = formatCurrency(data.totalRemaining || 0);
    }

    function updatePayrollTable(entries) {
        const tbody = document.getElementById('payrollTableBody');
        const tableContainer = document.getElementById('payrollTableContainer');
        const emptyState = document.getElementById('emptyState');

        if (!entries || entries.length === 0) {
            tableContainer.style.display = 'none';
            emptyState.style.display = 'block';
            emptyState.querySelector('h3').textContent = 'Chưa có dữ liệu bảng lương';
            return;
        }

        tableContainer.style.display = 'block';
        emptyState.style.display = 'none';

        tbody.innerHTML = entries.map(entry => {
            const isPaid = entry.isPaid === true;
            return `
                <tr>
                    <td>${escapeHtml(entry.employeeCode)}</td>
                    <td>${escapeHtml(entry.employeeName)}</td>
                    <td>
                        <span class="compensation-type-badge ${getCompensationTypeClass(entry.compensationType)}">
                            ${getCompensationTypeLabel(entry.compensationType)}
                        </span>
                    </td>
                    <td class="currency">${formatCurrency(entry.totalSalary)}</td>
                    <td class="currency">${formatCurrency(entry.allowances)}</td>
                    <td class="currency">${formatCurrency(entry.bonuses)}</td>
                    <td class="currency">${formatCurrency(entry.deductions)}</td>
                    <td class="currency">${formatCurrency(entry.totalPaid)}</td>
                    <td class="currency">${formatCurrency(entry.totalRemaining)}</td>
                    <td>
                        ${isPaid 
                            ? '<span class="paid-badge">Đã thanh toán</span>' 
                            : '<span class="unpaid-badge">Chưa thanh toán</span>'}
                    </td>
                    <td>
                        <button class="btn-mark-paid" 
                                onclick="markAsPaid('${entry.payrollEntryId}')"
                                ${isPaid ? 'disabled' : ''}>
                            ${isPaid ? 'Đã thanh toán' : 'Đánh dấu đã thanh toán'}
                        </button>
                    </td>
                </tr>
            `;
        }).join('');
    }

    async function markAsPaid(payrollEntryId) {
        if (!confirm('Bạn có chắc chắn muốn đánh dấu đã thanh toán lương cho nhân viên này?')) {
            return;
        }

        try {
            const formData = new URLSearchParams();
            formData.append('payrollEntryId', payrollEntryId);

            const response = await fetch(CONTEXT_PATH + '/api/payroll/mark-paid', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData
            });

            const data = await response.json();

            if (data.success) {
                alert('Đánh dấu đã thanh toán thành công!');
                loadPayroll(); // Reload to update the table
            } else {
                alert('Lỗi: ' + (data.error || 'Không thể đánh dấu đã thanh toán'));
            }
        } catch (error) {
            console.error('Error marking as paid:', error);
            alert('Có lỗi xảy ra khi đánh dấu đã thanh toán');
        }
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function showError(message) {
        const emptyState = document.getElementById('emptyState');
        emptyState.style.display = 'block';
        emptyState.querySelector('h3').textContent = message;
        document.getElementById('payrollTableContainer').style.display = 'none';
    }
</script>

<jsp:include page="../includes/footer.jsp" />
