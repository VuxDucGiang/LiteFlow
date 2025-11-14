<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hoá đơn Bán hàng - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/design-system.css">
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    
    <style>
        :root {
            --primary-500: #0080FF;
            --primary-600: #0066cc;
            --secondary-500: #00c6ff;
            --color-primary: #0080FF;
            --color-secondary: #00c6ff;
            --color-accent: #7d2ae8;
        }
        
        * {
            box-sizing: border-box;
        }
        
        html, body {
            overflow-x: hidden;
            width: 100%;
            max-width: 100vw;
        }
        
        body {
            background: var(--gray-50, #f9fafb);
            margin: 0;
            padding: 0;
        }
        
        .container {
            max-width: 1800px;
            margin: 0 auto;
            padding: 20px;
            width: 100%;
            box-sizing: border-box;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border: 2px solid rgba(255,255,255,0.3);
            width: 100%;
            box-sizing: border-box;
            flex-wrap: wrap;
        }
        
        .page-title {
            font-size: 32px;
            font-weight: 700;
            background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .page-title .icon {
            background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
            color: white;
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 4px 12px rgba(0, 128, 255, 0.3);
        }
        
        .table-wrapper {
            width: 100%;
            overflow-x: auto;
            overflow-y: visible;
            -webkit-overflow-scrolling: touch;
            box-sizing: border-box;
        }
        
        .invoice-table {
            width: 100%;
            min-width: 800px;
            border-collapse: collapse;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border: 1px solid var(--color-primary);
            position: relative;
            table-layout: auto;
        }
        
        .invoice-table::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--secondary-500));
        }
        
        .invoice-table th {
            background: linear-gradient(135deg, var(--primary-50, #f2f7ff) 0%, var(--secondary-50, #f0f9ff) 100%);
            padding: 16px;
            text-align: left;
            font-weight: 600;
            color: var(--gray-800, #1f2937);
            border-bottom: 2px solid var(--color-primary);
        }
        
        .invoice-table td {
            padding: 16px;
            border-bottom: 1px solid var(--gray-200, #e5e7eb);
        }
        
        .invoice-table tr:hover {
            background: rgba(0, 128, 255, 0.05);
            transition: all 0.2s ease;
        }
        
        @media (min-width: 1024px) {
            .invoice-table tr:hover {
                transform: translateX(2px);
            }
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.12);
        }
        
        .btn-info {
            background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
            color: white;
        }
        
        .btn-info:hover {
            background: linear-gradient(135deg, var(--primary-600), var(--secondary-500));
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 128, 255, 0.3);
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
        
        /* Responsive fixes */
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .page-header {
                padding: 20px;
            }
            
            .page-title {
                font-size: 24px;
            }
            
            .filters-container {
                flex-direction: column;
            }
            
            .filters-container > div {
                flex: 1 1 100% !important;
                min-width: 100% !important;
            }
            
            .invoice-table {
                min-width: 600px;
            }
            
            .invoice-table th,
            .invoice-table td {
                padding: 12px 8px;
                font-size: 13px;
            }
        }
        
        @media (max-width: 480px) {
            .page-title {
                font-size: 20px;
                flex-wrap: wrap;
            }
            
            .invoice-table {
                min-width: 500px;
            }
            
            .invoice-table th,
            .invoice-table td {
                padding: 10px 6px;
                font-size: 12px;
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
        <div class="filters-container" style="margin-bottom: 20px; display: flex; gap: 15px; align-items: flex-start; background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%); padding: 25px; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); border: 1px solid var(--color-primary); position: relative; overflow: hidden; width: 100%; box-sizing: border-box; flex-wrap: wrap;">
            <div style="position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, var(--primary-500), var(--secondary-500));"></div>
            <div style="flex: 1 1 250px; min-width: 200px; margin-top: 4px; box-sizing: border-box;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: var(--gray-800, #1f2937);">🔍 Tìm kiếm</label>
                <input type="text" id="salesSearchInput" placeholder="Tên khách hàng, SĐT, mã đơn..." 
                       style="width: 100%; padding: 12px 16px; border: 2px solid var(--color-primary); border-radius: 8px; font-size: 14px; transition: all 0.2s; box-sizing: border-box;"
                       onkeyup="debouncedSalesSearch()"
                       onfocus="this.style.borderColor='var(--secondary-500)'; this.style.boxShadow='0 0 0 3px rgba(0, 198, 255, 0.1)'"
                       onblur="this.style.borderColor='var(--color-primary)'; this.style.boxShadow='none'">
            </div>
            <div style="flex: 0 1 180px; min-width: 150px; margin-top: 4px; box-sizing: border-box;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: var(--gray-800, #1f2937);">📅 Từ ngày</label>
                <input type="date" id="salesStartDate" 
                       style="width: 100%; padding: 12px 16px; border: 2px solid var(--color-primary); border-radius: 8px; font-size: 14px; transition: all 0.2s; box-sizing: border-box;"
                       onchange="filterSalesInvoices()"
                       onfocus="this.style.borderColor='var(--secondary-500)'; this.style.boxShadow='0 0 0 3px rgba(0, 198, 255, 0.1)'"
                       onblur="this.style.borderColor='var(--color-primary)'; this.style.boxShadow='none'">
            </div>
            <div style="flex: 0 1 180px; min-width: 150px; margin-top: 4px; box-sizing: border-box;">
                <label style="display: block; font-weight: 600; margin-bottom: 8px; color: var(--gray-800, #1f2937);">📅 Đến ngày</label>
                <input type="date" id="salesEndDate" 
                       style="width: 100%; padding: 12px 16px; border: 2px solid var(--color-primary); border-radius: 8px; font-size: 14px; transition: all 0.2s; box-sizing: border-box;"
                       onchange="filterSalesInvoices()"
                       onfocus="this.style.borderColor='var(--secondary-500)'; this.style.boxShadow='0 0 0 3px rgba(0, 198, 255, 0.1)'"
                       onblur="this.style.borderColor='var(--color-primary)'; this.style.boxShadow='none'">
            </div>
            <div style="flex: 0 1 120px; min-width: 100px; align-self: flex-end; margin-top: 4px; box-sizing: border-box;">
                <button class="btn" onclick="resetSalesFilters()" 
                        style="width: 100%; padding: 12px; background: linear-gradient(135deg, var(--color-primary), var(--color-secondary)); color: white; border: none; border-radius: 8px; cursor: pointer; box-shadow: 0 2px 6px rgba(0, 128, 255, 0.3); transition: all 0.2s; box-sizing: border-box;"
                        onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 12px rgba(0, 128, 255, 0.4)'"
                        onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0, 128, 255, 0.3)'">
                    🔄 Reload
                </button>
            </div>
        </div>

        <div class="table-wrapper">
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
                            <i class='bx bx-loader-alt bx-spin' style="font-size: 48px; background: linear-gradient(135deg, var(--color-primary), var(--color-secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;"></i>
                            <p style="margin-top: 15px; color: var(--gray-600, #6b7280);">Đang tải dữ liệu...</p>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
        </div>
        
        <!-- Pagination -->
        <div id="salesPagination" style="margin-top: 20px; text-align: center; display: none;">
            <button class="btn" onclick="loadSalesInvoices(salesCurrentPage - 1)" id="salesPrevBtn" 
                    style="background: var(--gray-200, #e5e7eb); color: var(--gray-800, #374151); margin-right: 10px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);" disabled>
                ← Trước
            </button>
            <span id="salesPageInfo" style="margin: 0 20px; font-weight: 600; color: var(--gray-800, #374151);"></span>
            <button class="btn" onclick="loadSalesInvoices(salesCurrentPage + 1)" id="salesNextBtn"
                    style="background: linear-gradient(135deg, var(--color-primary), var(--color-secondary)); color: white; margin-left: 10px; box-shadow: 0 2px 6px rgba(0, 128, 255, 0.3); transition: all 0.2s;"
                    onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 12px rgba(0, 128, 255, 0.4)'"
                    onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0, 128, 255, 0.3)'">
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
                        '<tr><td colspan="8" style="text-align: center; padding: 40px; color: var(--error-500, #ef4444);">' +
                        '<i class="bx bx-error" style="font-size: 48px;"></i>' +
                        '<p style="margin-top: 15px;">Lỗi: ' + error.message + '</p></td></tr>';
                });
        }
        
        function renderSalesInvoices(invoices) {
            const tbody = document.getElementById('salesInvoiceTableBody');
            
            if (!invoices || invoices.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px;">' +
                    '<i class="bx bx-receipt" style="font-size: 64px; color: var(--gray-300, #d1d5db);"></i>' +
                    '<h3 style="margin: 20px 0 10px 0; color: var(--gray-600, #6b7280);">Không tìm thấy hóa đơn</h3></td></tr>';
                return;
            }
            
            let html = '';
            invoices.forEach((inv, i) => {
                // ✅ Chuyển đổi paymentMethod từ lowercase (cash, transfer) sang title case để match với badges
                const paymentMethodKey = inv.paymentMethod ? 
                    inv.paymentMethod.charAt(0).toUpperCase() + inv.paymentMethod.slice(1).toLowerCase() : 
                    'Cash';
                
                const badges = {
                    'Cash': '<span style="background: linear-gradient(135deg, var(--success-500, #22c55e), var(--success-600, #16a34a)); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(34, 197, 94, 0.3);">💵 Tiền mặt</span>',
                    'cash': '<span style="background: linear-gradient(135deg, var(--success-500, #22c55e), var(--success-600, #16a34a)); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(34, 197, 94, 0.3);">💵 Tiền mặt</span>',
                    'Card': '<span style="background: linear-gradient(135deg, var(--color-primary), var(--color-secondary)); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(0, 128, 255, 0.3);">💳 Thẻ</span>',
                    'card': '<span style="background: linear-gradient(135deg, var(--color-primary), var(--color-secondary)); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(0, 128, 255, 0.3);">💳 Thẻ</span>',
                    'Transfer': '<span style="background: linear-gradient(135deg, var(--color-accent), var(--color-primary)); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(125, 42, 232, 0.3);">🏦 Chuyển khoản</span>',
                    'transfer': '<span style="background: linear-gradient(135deg, var(--color-accent), var(--color-primary)); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(125, 42, 232, 0.3);">🏦 Chuyển khoản</span>',
                    'E-Wallet': '<span style="background: linear-gradient(135deg, var(--warning-500, #f59e0b), var(--warning-600, #d97706)); color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(245, 158, 11, 0.3);">📱 Ví điện tử</span>'
                };
                const paymentBadge = badges[inv.paymentMethod] || badges[paymentMethodKey] || '<span style="color: var(--gray-600, #6b7280);">' + (inv.paymentMethod || 'N/A') + '</span>';
                
                html += '<tr style="animation: slideIn 0.3s ease ' + (i * 0.05) + 's both;">';
                html += '<td><strong>' + (inv.orderNumber || 'N/A') + '</strong></td>';
                html += '<td>' + (inv.orderDateFormatted || '') + '</td>';
                html += '<td><strong>' + (inv.customerName || 'Khách lẻ') + '</strong>';
                if (inv.customerPhone) html += '<br><small style="color: var(--gray-600, #6b7280);">' + inv.customerPhone + '</small>';
                html += '</td>';
                html += '<td>' + ((inv.roomName || '') + (inv.roomName && inv.tableName ? ' - ' : '') + (inv.tableName || '-')) + '</td>';
                html += '<td><strong style="background: linear-gradient(135deg, var(--color-primary), var(--color-secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; font-size: 15px;">' + (inv.totalAmount ? inv.totalAmount.toLocaleString('vi-VN') + ' ₫' : '0 ₫') + '</strong></td>';
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
            if (inv.discount) summaryRows += '<div style="display:flex;justify-content:space-between;color:var(--error-500, #ef4444)"><span>Giảm giá</span><span>-' + formatCurrency(inv.discount) + '</span></div>';
            summaryRows += '<hr style="border:none;border-top:1px solid var(--gray-200, #e5e7eb);margin:8px 0">' +
                           '<div style="display:flex;justify-content:space-between;font-weight:800;background:linear-gradient(135deg, var(--color-primary), var(--color-secondary));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text"><span>TỔNG</span><span>' + formatCurrency(inv.totalAmount) + '</span></div>';

            var html = '';
            html += '<div id="salesDetailModal" style="position:fixed;inset:0;background:rgba(0,0,0,.4);display:flex;align-items:center;justify-content:center;z-index:9999;overflow-y:auto;padding:20px;box-sizing:border-box;">';
            html += '  <div style="width:900px;max-width:100%;background:white;border-radius:16px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,.2);border:1px solid var(--color-primary);box-sizing:border-box;margin:auto;">';
            html += '    <div style="background:linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);color:white;padding:18px 22px;display:flex;justify-content:space-between;align-items:center;position:relative;flex-wrap:wrap;gap:10px;box-sizing:border-box;">';
            html += '      <div style="position:absolute;top:0;left:0;right:0;height:4px;background:linear-gradient(90deg, var(--primary-500), var(--secondary-500))"></div>';
            html += '      <div style="font-size:20px;font-weight:800;margin-top:4px;flex:1;min-width:200px;">🧾 Chi tiết Hóa đơn</div>';
            html += '      <div style="margin-top:4px;display:flex;gap:8px;flex-wrap:wrap;">';
            html += '        <button onclick="printInvoice()" class="btn" style="background:white;color:var(--color-primary);box-shadow:0 2px 6px rgba(0,0,0,0.2);box-sizing:border-box;">🖨️ In</button>';
            html += '        <button onclick="closeSalesDetail()" class="btn" style="background:rgba(255,255,255,0.2);color:white;border:1px solid rgba(255,255,255,0.3);box-shadow:0 2px 6px rgba(0,0,0,0.2);box-sizing:border-box;">✖</button>';
            html += '      </div>';
            html += '    </div>';
            html += '    <div id="printArea" style="padding:22px;box-sizing:border-box;overflow-x:auto;">';
            html += '      <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;background:linear-gradient(135deg, var(--primary-50, #f2f7ff) 0%, var(--secondary-50, #f0f9ff) 100%);border-left:4px solid var(--color-primary);padding:14px;border-radius:8px">';
            html += '        <div><div style="color:var(--color-primary);font-weight:700">Mã đơn</div><div style="font-size:18px">' + (inv.orderNumber || '-') + '</div></div>';
            html += '        <div><div style="color:var(--color-primary);font-weight:700">Ngày bán</div><div>' + (inv.orderDateFormatted || formatDateTime(inv.orderDate)) + '</div></div>';
            html += '        <div><div style="color:var(--color-primary);font-weight:700">Khách hàng</div><div>' + (inv.customerName || 'Khách lẻ') + (inv.customerPhone ? (' - ' + inv.customerPhone) : '') + '</div></div>';
            html += '        <div><div style="color:var(--color-primary);font-weight:700">Bàn/Phòng</div><div>' + ((inv.roomName || '') + (inv.roomName && inv.tableName ? ' - ' : '') + (inv.tableName || '-')) + '</div></div>';
            // ✅ Hiển thị phương thức thanh toán với text tiếng Việt
            let paymentMethodText = 'Tiền mặt'; // Default
            if (inv.paymentMethod) {
                const pm = inv.paymentMethod.toLowerCase();
                if (pm === 'cash') {
                    paymentMethodText = 'Tiền mặt';
                } else if (pm === 'card') {
                    paymentMethodText = 'Thẻ';
                } else if (pm === 'transfer') {
                    paymentMethodText = 'Chuyển khoản';
                } else {
                    paymentMethodText = inv.paymentMethod;
                }
            }
            html += '        <div><div style="color:var(--color-primary);font-weight:700">Thanh toán</div><div>' + paymentMethodText + '</div></div>';
            html += '        <div><div style="color:var(--color-primary);font-weight:700">Nhân viên</div><div>' + (inv.createdByName || '-') + '</div></div>';
            html += '      </div>';
            html += '      <h3 style="margin:8px 0 10px 0;color:var(--gray-800, #374151)">Sản phẩm</h3>';
            html += '      <div style="overflow-x:auto;width:100%;">';
            html += '        <table class="invoice-table" style="min-width:600px;">';
            html += '          <thead><tr><th>Sản phẩm</th><th>Size</th><th style="text-align:right">SL</th><th style="text-align:right">Đơn giá</th><th style="text-align:right">Thành tiền</th></tr></thead>';
            html += '          <tbody>' + (items || '<tr><td colspan="5" style="text-align:center;color:var(--gray-600, #6b7280);padding:16px">Không có sản phẩm</td></tr>') + '</tbody>';
            html += '        </table>';
            html += '      </div>';
            html += '      <div style="margin-top:16px;background:var(--gray-50, #f8fafc);border:1px solid var(--gray-200, #e5e7eb);border-radius:8px;padding:14px">' + summaryRows + '</div>';
            if (inv.notes) {
                html += '      <div style="margin-top:10px;color:var(--gray-800, #374151)"><strong>Ghi chú:</strong><br>' + inv.notes + '</div>';
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


