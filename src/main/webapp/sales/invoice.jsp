<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hoá đơn Bán hàng - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    
    <style>
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .page-title {
            font-size: 32px;
            font-weight: 700;
            color: #1f2937;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .page-title .icon {
            background: linear-gradient(135deg, #059669 0%, #10b981 100%);
            color: white;
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        
        .invoice-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .invoice-table th {
            background: #f8fafc;
            padding: 16px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 2px solid #e5e7eb;
        }
        
        .invoice-table td {
            padding: 16px;
            border-bottom: 1px solid #f3f4f6;
        }
        
        .invoice-table tr:hover {
            background: #f9fafb;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-info {
            background: #3b82f6;
            color: white;
        }
        
        .btn-info:hover {
            background: #2563eb;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <%@ include file="/includes/header.jsp" %>
    
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">
                <span class="icon">🧾</span>
                Hoá đơn Bán hàng
            </h1>
        </div>
        
        <!-- Filters & Search -->
        <div style="margin-bottom: 20px; display: flex; gap: 15px; align-items: center; background: white; padding: 25px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);">
            <div style="flex: 1;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #374151;">🔍 Tìm kiếm</label>
                <input type="text" id="salesSearchInput" placeholder="Tên khách hàng, SĐT, mã đơn..." 
                       style="width: 100%; padding: 12px 16px; border: 2px solid #e5e7eb; border-radius: 8px; font-size: 14px;"
                       onkeyup="debouncedSalesSearch()">
            </div>
            <div style="flex: 0.7;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #374151;">📅 Từ ngày</label>
                <input type="date" id="salesStartDate" 
                       style="width: 100%; padding: 12px 16px; border: 2px solid #e5e7eb; border-radius: 8px; font-size: 14px;"
                       onchange="filterSalesInvoices()">
            </div>
            <div style="flex: 0.7;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: #374151;">📅 Đến ngày</label>
                <input type="date" id="salesEndDate" 
                       style="width: 100%; padding: 12px 16px; border: 2px solid #e5e7eb; border-radius: 8px; font-size: 14px;"
                       onchange="filterSalesInvoices()">
            </div>
            <div style="flex: 0.5; align-self: flex-end;">
                <button class="btn" onclick="resetSalesFilters()" 
                        style="width: 100%; padding: 12px; background: #4986FF; color: white; border: none; border-radius: 8px; cursor: pointer;">
                    🔄 Reload
                </button>
            </div>
        </div>

        <table class="invoice-table">
            <thead>
                <tr>
                    <th>Mã đơn</th>
                    <th>Ngày bán</th>
                    <th>Khách hàng</th>
                    <th>Bàn/Phòng</th>
                    <th>Tổng tiền</th>
                    <th>Thanh toán</th>
                    <th>Nhân viên</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody id="salesInvoiceTableBody">
                <tr>
                    <td colspan="8" style="text-align: center; padding: 40px;">
                        <div class="loading-state">
                            <i class='bx bx-loader-alt bx-spin' style="font-size: 48px; color: #3b82f6;"></i>
                            <p style="margin-top: 15px; color: #6b7280;">Đang tải dữ liệu...</p>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
        
        <!-- Pagination -->
        <div id="salesPagination" style="margin-top: 20px; text-align: center; display: none;">
            <button class="btn" onclick="loadSalesInvoices(salesCurrentPage - 1)" id="salesPrevBtn" 
                    style="background: #e5e7eb; color: #374151; margin-right: 10px;" disabled>
                ← Trước
            </button>
            <span id="salesPageInfo" style="margin: 0 20px; font-weight: 600; color: #374151;"></span>
            <button class="btn" onclick="loadSalesInvoices(salesCurrentPage + 1)" id="salesNextBtn"
                    style="background: #10b981; color: white; margin-left: 10px;">
                Tiếp →
            </button>
        </div>
    </div>
    
    <script>
        // Sales Invoice variables
        var salesCurrentPage = 0;
        var salesTotalCount = 0;
        var salesPageSize = 50;
        var salesSearchKeyword = '';
        var salesStartDateFilter = '';
        var salesEndDateFilter = '';
        var salesSearchTimeout = null;
        
        /**
         * Load sales invoices from API
         */
        function loadSalesInvoices(page) {
            page = page || 0;
            if (page < 0) return;
            
            salesCurrentPage = page;
            const offset = page * salesPageSize;
            
            let url = '${pageContext.request.contextPath}/sales/invoices?action=list&limit=' + salesPageSize + '&offset=' + offset;
            
            if (salesSearchKeyword.trim()) {
                url = '${pageContext.request.contextPath}/sales/invoices?action=search&keyword=' + 
                      encodeURIComponent(salesSearchKeyword) + '&limit=' + salesPageSize + '&offset=' + offset;
            } else if (salesStartDateFilter && salesEndDateFilter) {
                url = '${pageContext.request.contextPath}/sales/invoices?action=filter&startDate=' + 
                      salesStartDateFilter + '&endDate=' + salesEndDateFilter + 
                      '&limit=' + salesPageSize + '&offset=' + offset;
            }
            
            console.log('📊 Loading sales invoices from:', url);
            
            fetch(url)
                .then(response => {
                    if (!response.ok) throw new Error('HTTP ' + response.status);
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        renderSalesInvoices(data.invoices);
                        salesTotalCount = data.totalCount || data.count || 0;
                        updateSalesPagination();
                    } else {
                        throw new Error(data.message || 'Failed to load');
                    }
                })
                .catch(error => {
                    console.error('❌ Error:', error);
                    document.getElementById('salesInvoiceTableBody').innerHTML = 
                        '<tr><td colspan="8" style="text-align: center; padding: 40px; color: #ef4444;">' +
                        '<i class="bx bx-error" style="font-size: 48px;"></i>' +
                        '<p style="margin-top: 15px;">Lỗi: ' + error.message + '</p></td></tr>';
                });
        }
        
        function renderSalesInvoices(invoices) {
            const tbody = document.getElementById('salesInvoiceTableBody');
            
            if (!invoices || invoices.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px;">' +
                    '<i class="bx bx-receipt" style="font-size: 64px; color: #d1d5db;"></i>' +
                    '<h3 style="margin: 20px 0 10px 0; color: #6b7280;">Không tìm thấy hóa đơn</h3></td></tr>';
                return;
            }
            
            let html = '';
            invoices.forEach((inv, i) => {
                const badges = {
                    'Cash': '<span style="background: #10b981; color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600;">💵 Tiền mặt</span>',
                    'Card': '<span style="background: #3b82f6; color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600;">💳 Thẻ</span>',
                    'Transfer': '<span style="background: #8b5cf6; color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600;">🏦 Chuyển khoản</span>',
                    'E-Wallet': '<span style="background: #f59e0b; color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600;">📱 Ví điện tử</span>'
                };
                const paymentBadge = badges[inv.paymentMethod] || '<span style="color: #6b7280;">' + (inv.paymentMethod || 'N/A') + '</span>';
                
                html += '<tr style="animation: slideIn 0.3s ease ' + (i * 0.05) + 's both;">';
                html += '<td><strong>' + (inv.orderNumber || 'N/A') + '</strong></td>';
                html += '<td>' + (inv.orderDateFormatted || '') + '</td>';
                html += '<td><strong>' + (inv.customerName || 'Khách lẻ') + '</strong>';
                if (inv.customerPhone) html += '<br><small style="color: #6b7280;">' + inv.customerPhone + '</small>';
                html += '</td>';
                html += '<td>' + ((inv.roomName || '') + (inv.roomName && inv.tableName ? ' - ' : '') + (inv.tableName || '-')) + '</td>';
                html += '<td><strong style="color: #059669; font-size: 15px;">' + (inv.totalAmount ? inv.totalAmount.toLocaleString('vi-VN') + ' ₫' : '0 ₫') + '</strong></td>';
                html += '<td>' + paymentBadge + '</td>';
                html += '<td>' + (inv.createdByName || '-') + '</td>';
                html += '<td><button class="btn btn-info" onclick="viewDetails(\'' + inv.orderId + '\')"><i class="bx bx-show"></i></button></td>';
                html += '</tr>';
            });
            
            tbody.innerHTML = html;
        }
        
        function updateSalesPagination() {
            const paginationDiv = document.getElementById('salesPagination');
            const prevBtn = document.getElementById('salesPrevBtn');
            const nextBtn = document.getElementById('salesNextBtn');
            const pageInfo = document.getElementById('salesPageInfo');
            
            const totalPages = Math.ceil(salesTotalCount / salesPageSize);
            const currentPageNum = salesCurrentPage + 1;
            
            if (totalPages > 1) {
                paginationDiv.style.display = 'block';
                pageInfo.textContent = 'Trang ' + currentPageNum + ' / ' + totalPages + ' (Tổng: ' + salesTotalCount + ' hóa đơn)';
                prevBtn.disabled = salesCurrentPage === 0;
                nextBtn.disabled = salesCurrentPage >= totalPages - 1;
            } else {
                paginationDiv.style.display = 'none';
            }
        }
        
        function viewDetails(orderId) {
            fetch('${pageContext.request.contextPath}/sales/invoices?action=details&id=' + orderId)
                .then(r => r.json())
                .then(data => {
                    if (!data.success || !data.invoice) throw new Error(data.message || 'Không có dữ liệu');
                    showInvoiceModal(data.invoice);
                })
                .catch(err => {
                    console.error('❌ Detail error:', err);
                    alert('Lỗi tải chi tiết hóa đơn: ' + err.message);
                });
        }

        function formatCurrency(n) {
            if (!n && n !== 0) return '0 ₫';
            return Number(n).toLocaleString('vi-VN') + ' ₫';
        }

        function formatDateTime(iso) {
            try {
                const d = new Date(iso);
                return d.toLocaleDateString('vi-VN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
            } catch(e){ return iso; }
        }

        function showInvoiceModal(inv) {
            var items = '';
            (inv.items || []).forEach(function(it){
                items += '<tr>' +
                         '<td>' + (it.productName || '-') + '</td>' +
                         '<td>' + (it.size || '-') + '</td>' +
                         '<td style="text-align:right">' + (it.quantity || 0) + '</td>' +
                         '<td style="text-align:right">' + formatCurrency(it.unitPrice) + '</td>' +
                         '<td style="text-align:right"><strong>' + formatCurrency(it.totalPrice) + '</strong></td>' +
                         '</tr>';
            });

            var summaryRows = '';
            if (inv.subTotal) summaryRows += '<div style="display:flex;justify-content:space-between"><span>Tạm tính</span><span>' + formatCurrency(inv.subTotal) + '</span></div>';
            if (inv.vat) summaryRows += '<div style="display:flex;justify-content:space-between"><span>VAT</span><span>' + formatCurrency(inv.vat) + '</span></div>';
            if (inv.discount) summaryRows += '<div style="display:flex;justify-content:space-between;color:#ef4444"><span>Giảm giá</span><span>-' + formatCurrency(inv.discount) + '</span></div>';
            summaryRows += '<hr style="border:none;border-top:1px solid #e5e7eb;margin:8px 0">' +
                           '<div style="display:flex;justify-content:space-between;font-weight:800;color:#059669"><span>TỔNG</span><span>' + formatCurrency(inv.totalAmount) + '</span></div>';

            var html = '';
            html += '<div id="salesDetailModal" style="position:fixed;inset:0;background:rgba(0,0,0,.4);display:flex;align-items:center;justify-content:center;z-index:9999;">';
            html += '  <div style="width:900px;max-width:95vw;background:white;border-radius:12px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,.2)">';
            html += '    <div style="background:linear-gradient(135deg,#059669 0%, #10b981 100%);color:white;padding:18px 22px;display:flex;justify-content:space-between;align-items:center">';
            html += '      <div style="font-size:20px;font-weight:800">🧾 Chi tiết Hóa đơn</div>';
            html += '      <div>';
            html += '        <button onclick="printInvoice()" class="btn" style="background:white;color:#065f46;margin-right:8px">🖨️ In</button>';
            html += '        <button onclick="closeSalesDetail()" class="btn" style="background:#065f46;color:white">✖</button>';
            html += '      </div>';
            html += '    </div>';
            html += '    <div id="printArea" style="padding:22px">';
            html += '      <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;background:#f0fdf4;border-left:4px solid #10b981;padding:14px;border-radius:8px">';
            html += '        <div><div style="color:#065f46;font-weight:700">Mã đơn</div><div style="font-size:18px">' + (inv.orderNumber || '-') + '</div></div>';
            html += '        <div><div style="color:#065f46;font-weight:700">Ngày bán</div><div>' + (inv.orderDateFormatted || formatDateTime(inv.orderDate)) + '</div></div>';
            html += '        <div><div style="color:#065f46;font-weight:700">Khách hàng</div><div>' + (inv.customerName || 'Khách lẻ') + (inv.customerPhone ? (' - ' + inv.customerPhone) : '') + '</div></div>';
            html += '        <div><div style="color:#065f46;font-weight:700">Bàn/Phòng</div><div>' + ((inv.roomName || '') + (inv.roomName && inv.tableName ? ' - ' : '') + (inv.tableName || '-')) + '</div></div>';
            html += '        <div><div style="color:#065f46;font-weight:700">Thanh toán</div><div>' + (inv.paymentMethod || '-') + '</div></div>';
            html += '        <div><div style="color:#065f46;font-weight:700">Nhân viên</div><div>' + (inv.createdByName || '-') + '</div></div>';
            html += '      </div>';
            html += '      <h3 style="margin:8px 0 10px 0;color:#374151">Sản phẩm</h3>';
            html += '      <table class="invoice-table">';
            html += '        <thead><tr><th>Sản phẩm</th><th>Size</th><th style="text-align:right">SL</th><th style="text-align:right">Đơn giá</th><th style="text-align:right">Thành tiền</th></tr></thead>';
            html += '        <tbody>' + (items || '<tr><td colspan="5" style="text-align:center;color:#6b7280;padding:16px">Không có sản phẩm</td></tr>') + '</tbody>';
            html += '      </table>';
            html += '      <div style="margin-top:16px;background:#f8fafc;border:1px solid #e5e7eb;border-radius:8px;padding:14px">' + summaryRows + '</div>';
            if (inv.notes) {
                html += '      <div style="margin-top:10px;color:#374151"><strong>Ghi chú:</strong><br>' + inv.notes + '</div>';
            }
            html += '    </div>';
            html += '  </div>';
            html += '</div>';

            var old = document.getElementById('salesDetailModal');
            if (old) old.remove();
            document.body.insertAdjacentHTML('beforeend', html);
        }

        function closeSalesDetail(){
            const m = document.getElementById('salesDetailModal');
            if (m) m.remove();
        }

        function printInvoice(){
            const area = document.getElementById('printArea');
            if (!area) return window.print();
            const w = window.open('', '_blank');
            w.document.write('<html><head><title>In hóa đơn</title>');
            w.document.write('<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">');
            w.document.write('</head><body>' + area.innerHTML + '</body></html>');
            w.document.close();
            w.focus();
            setTimeout(() => { w.print(); w.close(); }, 300);
        }
        
        function debouncedSalesSearch() {
            clearTimeout(salesSearchTimeout);
            salesSearchTimeout = setTimeout(() => {
                salesSearchKeyword = document.getElementById('salesSearchInput').value;
                salesCurrentPage = 0;
                loadSalesInvoices(0);
            }, 500);
        }
        
        function filterSalesInvoices() {
            salesStartDateFilter = document.getElementById('salesStartDate').value;
            salesEndDateFilter = document.getElementById('salesEndDate').value;
            salesSearchKeyword = '';
            salesCurrentPage = 0;
            loadSalesInvoices(0);
        }
        
        function resetSalesFilters() {
            document.getElementById('salesSearchInput').value = '';
            document.getElementById('salesStartDate').value = '';
            document.getElementById('salesEndDate').value = '';
            salesSearchKeyword = '';
            salesStartDateFilter = '';
            salesEndDateFilter = '';
            salesCurrentPage = 0;
            loadSalesInvoices(0);
        }
        
        // Auto-load on page load
        window.onload = function() {
            loadSalesInvoices(0);
        };
    </script>
</body>
</html>

