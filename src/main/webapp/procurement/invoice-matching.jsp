<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đối chiếu Hóa đơn - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    
    <!-- CRITICAL: Define functions BEFORE any HTML to ensure they load first -->
    <script>
        console.log('🚀 Loading invoice-matching functions...');
        
        // Global function to add manual item row
        window.addManualItemRow = function() {
            console.log('🔘 addManualItemRow called');
            
            var container = document.getElementById('manualItemsContainer');
            if (!container) {
                console.error('❌ Container not found');
                alert('Lỗi: Không tìm thấy container');
                return;
            }
            
            var newRow = document.createElement('div');
            newRow.className = 'manual-item-row';
            newRow.style.cssText = 'display:grid;grid-template-columns:2fr 1fr 1.5fr 60px;gap:12px;margin-bottom:12px;align-items:center;padding:12px;background:white;border-radius:8px;border:1px solid #e5e7eb';
            
            newRow.innerHTML = '<input type="text" name="itemName[]" placeholder="Tên sản phẩm" style="padding:10px 14px;border:1px solid #d1d5db;border-radius:6px;font-size:14px">' +
                '<input type="number" name="itemQuantity[]" placeholder="Số lượng" style="padding:10px 14px;border:1px solid #d1d5db;border-radius:6px;font-size:14px" min="1" value="1">' +
                '<input type="number" name="itemPrice[]" placeholder="Đơn giá (₫)" style="padding:10px 14px;border:1px solid #d1d5db;border-radius:6px;font-size:14px" step="1000" min="0">' +
                '<button type="button" onclick="removeManualItemRow(this)" class="btn btn-danger" style="padding:10px;height:42px;border-radius:6px"><i class="bx bx-trash"></i></button>';
            
            container.appendChild(newRow);
            var total = container.querySelectorAll('.manual-item-row').length;
            console.log('✅ Row added! Total:', total);
        };
        
        // Global function to remove manual item row
        window.removeManualItemRow = function(button) {
            console.log('🗑️ removeManualItemRow called');
            
            var container = document.getElementById('manualItemsContainer');
            var rows = container.querySelectorAll('.manual-item-row');
            
            if (rows.length > 1) {
                button.closest('.manual-item-row').remove();
                console.log('✅ Row removed! Remaining:', rows.length - 1);
            } else {
                alert('Phải có ít nhất 1 sản phẩm');
            }
        };
        
        console.log('✅ Functions loaded:', typeof window.addManualItemRow, typeof window.removeManualItemRow);
    </script>
    
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
            margin-bottom: 20px;
        }
        
        .page-title {
            font-size: 28px;
            font-weight: 700;
            color: #1f2937;
        }
        
        /* Tab Switcher */
        .tab-switcher {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            background: white;
            padding: 8px;
            border-radius: 12px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            width: fit-content;
        }
        
        .tab-btn {
            padding: 12px 32px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            background: transparent;
            color: #6b7280;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .tab-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .tab-btn.active {
            background: #3b82f6;
            color: white;
            box-shadow: 0 4px 6px rgba(59, 130, 246, 0.3);
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }
        
        .btn-success {
            background: #10b981;
            color: white;
        }
        
        .btn-success:hover {
            background: #059669;
        }
        
        .btn-warning {
            background: #f59e0b;
            color: white;
            padding: 8px 16px;
        }
        
        .btn-warning:hover {
            background: #d97706;
        }
        
        .btn-danger {
            background: #ef4444;
            color: white;
            padding: 8px 16px;
        }
        
        .btn-danger:hover {
            background: #dc2626;
        }
        
        .alert-success {
            background: #d1fae5;
            border: 1px solid #6ee7b7;
            color: #065f46;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .invoice-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .invoice-table th {
            background: #f8fafc;
            padding: 16px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .invoice-table td {
            padding: 16px;
            border-bottom: 1px solid #f3f4f6;
        }
        
        .invoice-table tr:hover {
            background: #f9fafb;
        }
        
        .invoice-table tr.matched {
            background: #d1fae5;
        }
        
        .invoice-table tr.unmatched {
            background: #fee2e2;
        }
        
        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-matched {
            background: #dcfce7;
            color: #166534;
        }
        
        .status-unmatched {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .amount {
            font-weight: bold;
            color: #10b981;
        }
        
        .difference {
            font-weight: bold;
        }
        
        .difference.positive {
            color: #ef4444;
        }
        
        .difference.negative {
            color: #10b981;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 999999;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
        }
        
        .modal-content {
            background-color: white;
            margin: 80px auto 20px auto;
            padding: 0;
            border-radius: 15px;
            width: 90%;
            max-width: 800px;
            max-height: calc(100vh - 100px);
            overflow-y: auto;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }
        
        .modal-header {
            background: #f8fafc;
            padding: 20px 30px;
            border-radius: 15px 15px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            margin: 0;
            color: #1f2937;
        }
        
        .close {
            color: #6b7280;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .close:hover {
            color: #ef4444;
        }
        
        .modal-body {
            padding: 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #374151;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        .comparison {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin: 20px 0;
        }
        
        .comparison-item {
            padding: 20px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            background: #f9fafb;
        }
        
        .comparison-item h4 {
            margin: 0 0 15px 0;
            color: #1f2937;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            font-weight: 600;
            color: #6b7280;
        }
        
        .info-value {
            color: #1f2937;
        }
        
        .comparison-alert {
            margin-top: 20px;
            padding: 15px;
            border-radius: 8px;
            font-weight: 600;
        }
        
        .comparison-alert.matched {
            background: #d1fae5;
            border: 2px solid #10b981;
            color: #065f46;
        }
        
        .comparison-alert.unmatched {
            background: #fee2e2;
            border: 2px solid #ef4444;
            color: #991b1b;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6b7280;
        }
    </style>
</head>
<body>
    <jsp:include page="/includes/header.jsp">
        <jsp:param name="page" value="procurement"/>
    </jsp:include>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">📦 Hóa đơn Nhập hàng</h1>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="alert-success">
                <i class='bx bx-check-circle'></i> ${successMessage}
            </div>
        </c:if>

        <!-- Purchase Invoice Section -->
            <div style="margin-bottom: 20px; text-align: right; display: flex; gap: 10px; justify-content: flex-end;">
                <button class="btn btn-success" onclick="(function(){ var m=document.getElementById('manualModal'); var n=document.querySelector('.main-nav'); if(m){ m.style.display='block'; var d=document.getElementById('manualInvoiceDate'); if(d) d.value=new Date().toISOString().split('T')[0]; } if(n) n.style.display='none'; document.body.style.overflow='hidden'; })()">
                    <i class='bx bx-edit'></i>
                    Nhập Hóa đơn thủ công
                </button>
            </div>

            <table class="invoice-table">
            <thead>
                <tr>
                    <th>Mã hóa đơn</th>
                    <th>Mã PO</th>
                    <th>Nhà cung cấp</th>
                    <th>Ngày hóa đơn</th>
                    <th>Số tiền HĐ</th>
                    <th>Số tiền PO</th>
                    <th>Chênh lệch</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty invoices}">
                        <tr>
                            <td colspan="9" class="empty-state">
                                <h3>📋 Chưa có hóa đơn nào</h3>
                                <p>Hãy tạo hóa đơn đầu tiên để bắt đầu</p>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="invData" items="${invoices}">
                            <tr class="${invData.matched ? 'matched' : 'unmatched'}">
                                <td><strong>INV-${invData.invoiceID.toString().substring(0,8)}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${invData.poid != null}">
                                            PO-${invData.poid.toString().substring(0,8)}
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #9ca3af; font-style: italic;">Thủ công</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${invData.supplierName}</td>
                                <td>
                                    <span class="date-display" data-date="${invData.invoiceDate}">${invData.invoiceDate}</span>
                                </td>
                                <td class="amount">
                                    <fmt:formatNumber value="${invData.totalAmount}" pattern="#,##0"/> ₫
                                </td>
                                <td class="amount">
                                    <fmt:formatNumber value="${invData.POAmount}" pattern="#,##0"/> ₫
                                </td>
                                <td class="difference ${invData.difference > 0 ? 'positive' : 'negative'}">
                                    <fmt:formatNumber value="${invData.difference}" pattern="+#,##0;-#,##0"/> ₫
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${invData.matched}">
                                            <span class="status-badge status-matched">Đã khớp</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-unmatched">Chưa khớp</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <button class="btn btn-warning" onclick="viewDetails('${invData.invoiceID}')">
                                        <i class='bx bx-detail'></i> Chi tiết
                                    </button>
                                    <c:if test="${!invData.matched}">
                                        <button class="btn btn-danger" onclick="resolveDiscrepancy('${invData.invoiceID}')">
                                            <i class='bx bx-error'></i> Xử lý
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        <!-- End Purchase Invoice Section -->

    </div>

    <!-- Modal Chi tiết Hóa đơn -->
    <div id="detailModal" class="modal">
        <div class="modal-content" style="max-width: 1000px;">
            <div class="modal-header">
                <h2>📋 Chi tiết Hóa đơn</h2>
                <span class="close" onclick="closeDetailModal()">&times;</span>
            </div>
            <div class="modal-body">
                <!-- Invoice Information -->
                <div style="background: #f8fafc; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div>
                            <h3 style="margin: 0 0 15px 0; color: #1f2937;">Thông tin Hóa đơn</h3>
                            <div class="info-row">
                                <span class="info-label">Mã hóa đơn:</span>
                                <span class="info-value" id="detail_invoiceID"></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Ngày hóa đơn:</span>
                                <span class="info-value" id="detail_invoiceDate"></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Tổng tiền:</span>
                                <span class="info-value" id="detail_invoiceAmount"></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Trạng thái:</span>
                                <span class="info-value" id="detail_status"></span>
                            </div>
                        </div>
                        <div>
                            <h3 style="margin: 0 0 15px 0; color: #1f2937;">Thông tin Đơn hàng</h3>
                            <div class="info-row">
                                <span class="info-label">Mã PO:</span>
                                <span class="info-value" id="detail_poID"></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Nhà cung cấp:</span>
                                <span class="info-value" id="detail_supplier"></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Tổng tiền PO:</span>
                                <span class="info-value" id="detail_poAmount"></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Chênh lệch:</span>
                                <span class="info-value" id="detail_difference"></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- PO Items -->
                <div>
                    <h3 style="margin: 0 0 15px 0; color: #1f2937;">📦 Chi tiết sản phẩm</h3>
                    <table class="invoice-table">
                        <thead>
                            <tr>
                                <th>STT</th>
                                <th>Tên sản phẩm</th>
                                <th>Số lượng</th>
                                <th>Đơn giá</th>
                                <th>Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody id="detail_items">
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 20px;">
                                    Đang tải dữ liệu...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Match Note -->
                <div id="detail_matchNote" style="display: none; margin-top: 20px; padding: 15px; background: #fef3c7; border: 2px solid #f59e0b; border-radius: 8px;">
                    <strong>Ghi chú đối chiếu:</strong>
                    <p id="detail_noteText" style="margin: 5px 0 0 0;"></p>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-warning" onclick="closeDetailModal()">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Nhập Hóa đơn thủ công -->
    <div id="manualModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>✍️ Nhập Hóa đơn thủ công</h2>
                <span class="close" onclick="(function(){ var m=document.getElementById('manualModal'); var n=document.querySelector('.main-nav'); if(m) m.style.display='none'; if(n) n.style.display='flex'; document.body.style.overflow='auto'; })()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="manualForm" action="${pageContext.request.contextPath}/procurement/invoice" method="post">
                    <input type="hidden" name="action" value="createManual">
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="manualSupplier" style="font-weight: 600; color: #374151; margin-bottom: 8px; display: block;">🏢 Nhà cung cấp *</label>
                            <select id="manualSupplier" name="supplierID" required style="width: 100%; padding: 10px 14px; border: 2px solid #d1d5db; border-radius: 8px; font-size: 14px; background: white;">
                                <option value="">Chọn nhà cung cấp</option>
                                <c:forEach var="supplier" items="${suppliers}">
                                    <option value="${supplier.supplierID}">
                                        ${supplier.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="manualInvoiceNumber" style="font-weight: 600; color: #374151; margin-bottom: 8px; display: block;">📋 Số hóa đơn</label>
                            <input type="text" id="manualInvoiceNumber" name="invoiceNumber" placeholder="VD: INV-2025-001" style="width: 100%; padding: 10px 14px; border: 2px solid #d1d5db; border-radius: 8px; font-size: 14px;">
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="manualInvoiceDate" style="font-weight: 600; color: #374151; margin-bottom: 8px; display: block;">📅 Ngày hóa đơn *</label>
                            <input type="date" id="manualInvoiceDate" name="invoiceDate" required style="width: 100%; padding: 10px 14px; border: 2px solid #d1d5db; border-radius: 8px; font-size: 14px;">
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label for="manualAmount" style="font-weight: 600; color: #374151; margin-bottom: 8px; display: block;">💰 Tổng số tiền *</label>
                            <input type="number" id="manualAmount" name="totalAmount" step="1000" min="0" required placeholder="VD: 1500000" style="width: 100%; padding: 10px 14px; border: 2px solid #d1d5db; border-radius: 8px; font-size: 14px;">
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 24px;">
                        <label for="manualNote" style="font-weight: 600; color: #374151; margin-bottom: 8px; display: block;">📝 Ghi chú</label>
                        <textarea id="manualNote" name="note" rows="3" placeholder="VD: Mua khẩn cấp, không có đơn đặt hàng" style="width: 100%; padding: 10px 14px; border: 2px solid #d1d5db; border-radius: 8px; font-size: 14px; resize: vertical;"></textarea>
                    </div>

                    <!-- Items Section -->
                    <div class="form-group">
                        <label style="font-weight: 600; color: #374151; margin-bottom: 12px; display: block;">📦 Chi tiết sản phẩm (Tùy chọn)</label>
                        <div id="manualItemsContainer" style="border: 2px dashed #e5e7eb; border-radius: 12px; padding: 20px; background: #f9fafb;">
                            <div class="manual-item-row" style="display: grid; grid-template-columns: 2fr 1fr 1.5fr 60px; gap: 12px; margin-bottom: 12px; align-items: center; padding: 12px; background: white; border-radius: 8px; border: 1px solid #e5e7eb;">
                                <input type="text" name="itemName[]" placeholder="Tên sản phẩm" style="padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px;">
                                <input type="number" name="itemQuantity[]" placeholder="Số lượng" style="padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px;" min="1" value="1">
                                <input type="number" name="itemPrice[]" placeholder="Đơn giá (₫)" style="padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px;" step="1000" min="0">
                                <button type="button" onclick="removeManualItemRow(this)" class="btn btn-danger" style="padding: 10px; height: 42px; border-radius: 6px;">
                                    <i class='bx bx-trash'></i>
                                </button>
                            </div>
                        </div>
                        <button type="button" id="addItemBtn" class="btn" onclick="addManualItemRow()" style="background: #6366f1; color: white; margin-top: 12px; width: 100%; padding: 12px; border-radius: 8px; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 8px;">
                            <i class='bx bx-plus'></i> Thêm sản phẩm
                        </button>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-warning" onclick="(function(){ var m=document.getElementById('manualModal'); var n=document.querySelector('.main-nav'); if(m) m.style.display='none'; if(n) n.style.display='flex'; document.body.style.overflow='auto'; })()">Hủy</button>
                        <button type="submit" class="btn btn-success">
                            <i class='bx bx-check'></i> Lưu hóa đơn
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Function to add new item row
        function addManualItemRow(e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            console.log('🔘 Add item button clicked!');
            
            const container = document.getElementById('manualItemsContainer');
            if (!container) {
                console.error('❌ Container not found');
                return;
            }
            
            const newRow = document.createElement('div');
            newRow.className = 'manual-item-row';
            newRow.style.cssText = 'display: grid; grid-template-columns: 2fr 1fr 1.5fr 60px; gap: 12px; margin-bottom: 12px; align-items: center; padding: 12px; background: white; border-radius: 8px; border: 1px solid #e5e7eb;';
            newRow.innerHTML = `
                <input type="text" name="itemName[]" placeholder="Tên sản phẩm" style="padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px;">
                <input type="number" name="itemQuantity[]" placeholder="Số lượng" style="padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px;" min="1" value="1">
                <input type="number" name="itemPrice[]" placeholder="Đơn giá (₫)" style="padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px;" step="1000" min="0">
                <button type="button" onclick="removeManualItemRow(this, event)" class="btn btn-danger" style="padding: 10px; height: 42px; border-radius: 6px;">
                    <i class='bx bx-trash'></i>
                </button>
            `;
            
            container.appendChild(newRow);
            console.log('✅ Row added! Total rows:', container.querySelectorAll('.manual-item-row').length);
        }
        
        // Function to remove item row
        function removeManualItemRow(button, e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            const container = document.getElementById('manualItemsContainer');
            const rows = container.querySelectorAll('.manual-item-row');
            
            if (rows.length > 1) {
                button.closest('.manual-item-row').remove();
                console.log('🗑️ Row removed! Remaining rows:', container.querySelectorAll('.manual-item-row').length);
            } else {
                alert('Phải có ít nhất 1 sản phẩm');
            }
        }
        
        function closeManualModalSimple() {
            const modal = document.getElementById('manualModal');
            const mainNav = document.querySelector('.main-nav');
            
            if (modal) {
                modal.style.display = 'none';
                const form = document.getElementById('manualForm');
                if (form) form.reset();
            }
            if (mainNav) {
                mainNav.style.display = 'flex';
            }
            document.body.style.overflow = 'auto';
        }
        
        // Page loaded - all event handlers are now inline onclick attributes
        document.addEventListener('DOMContentLoaded', function() {
            console.log('✅ Invoice Matching Page Loaded');
            console.log('✅ All buttons use inline onclick - no addEventListener needed');
        });
        
        function addManualItem() {
            console.log('➕ Adding manual item...');
            const container = document.getElementById('manualItemsContainer');
            if (!container) {
                console.error('❌ Container not found!');
                return;
            }
            
            const newRow = document.createElement('div');
            newRow.className = 'manual-item-row';
            newRow.style.cssText = 'display: flex; gap: 10px; margin-bottom: 10px; align-items: center;';
            newRow.innerHTML = `
                <input type="text" name="itemName[]" placeholder="Tên sản phẩm" style="flex: 2;">
                <input type="number" name="itemQuantity[]" placeholder="SL" style="flex: 1;" min="1">
                <input type="number" name="itemPrice[]" placeholder="Đơn giá" style="flex: 1;" step="1000" min="0">
                <button type="button" onclick="removeManualItem(this)" class="btn btn-danger" style="padding: 8px 12px;">
                    <i class='bx bx-trash'></i>
                </button>
            `;
            container.appendChild(newRow);
            console.log('✅ Item added');
        }

        function removeManualItem(button) {
            console.log('➖ Removing manual item...');
            const container = document.getElementById('manualItemsContainer');
            const rows = container.querySelectorAll('.manual-item-row');
            if (rows.length > 1) {
                button.closest('.manual-item-row').remove();
                console.log('✅ Item removed');
            } else {
                alert('Phải có ít nhất 1 sản phẩm');
            }
        }

        // All modal interactions use inline onclick - no backdrop close needed

        // Store all invoice data for quick lookup
        const invoicesData = {};
        <c:forEach var="invData" items="${invoices}">
            invoicesData['${invData.invoiceID}'] = {
                invoiceID: '${invData.invoiceID}',
                poid: '${invData.poid}',
                invoiceDate: '${invData.invoiceDate}',
                totalAmount: ${invData.totalAmount},
                matched: ${invData.matched},
                matchNote: '${invData.matchNote}',
                supplierName: '${invData.supplierName}',
                poAmount: ${invData.POAmount},
                difference: ${invData.difference}
            };
        </c:forEach>

        // LoadPOItems function for detail modal
        function loadPOItems(poid) {
            const itemsBody = document.getElementById('detail_items');
            itemsBody.innerHTML = '<tr><td colspan="5" style="text-align: center;">Đang tải...</td></tr>';

            // AJAX request to get PO items
            fetch('${pageContext.request.contextPath}/procurement/po-items?poid=' + poid)
                .then(response => response.json())
                .then(items => {
                    if (items && items.length > 0) {
                        let html = '';
                        items.forEach((item, index) => {
                            const total = item.quantity * item.unitPrice;
                            html += `
                                <tr>
                                    <td>${index + 1}</td>
                                    <td>${item.itemName}</td>
                                    <td>${item.quantity}</td>
                                    <td>${formatCurrency(item.unitPrice)}</td>
                                    <td class="amount">${formatCurrency(total)}</td>
                                </tr>
                            `;
                        });
                        itemsBody.innerHTML = html;
                    } else {
                        itemsBody.innerHTML = '<tr><td colspan="5" style="text-align: center;">Không có sản phẩm</td></tr>';
                    }
                })
                .catch(error => {
                    console.error('Error loading PO items:', error);
                    itemsBody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #ef4444;">Lỗi tải dữ liệu</td></tr>';
                });
        }

        function viewDetails(invoiceId) {
            const data = invoicesData[invoiceId];
            if (!data) {
                alert('Không tìm thấy dữ liệu hóa đơn');
                return;
            }

            // Populate invoice info
            document.getElementById('detail_invoiceID').textContent = 'INV-' + invoiceId.substring(0, 8);
            document.getElementById('detail_invoiceDate').textContent = formatDateString(data.invoiceDate);
            document.getElementById('detail_invoiceAmount').textContent = formatCurrency(data.totalAmount);
            
            // Populate status
            const statusBadge = data.matched ? 
                '<span class="status-badge status-matched">Đã khớp</span>' : 
                '<span class="status-badge status-unmatched">Chưa khớp</span>';
            document.getElementById('detail_status').innerHTML = statusBadge;

            // Populate PO info
            document.getElementById('detail_poID').textContent = 'PO-' + data.poid.substring(0, 8);
            document.getElementById('detail_supplier').textContent = data.supplierName;
            document.getElementById('detail_poAmount').textContent = formatCurrency(data.poAmount);
            
            // Populate difference
            const diffClass = data.difference > 0 ? 'positive' : 'negative';
            document.getElementById('detail_difference').innerHTML = 
                '<span class="difference ' + diffClass + '">' + 
                (data.difference >= 0 ? '+' : '') + formatCurrency(data.difference) + 
                '</span>';

            // Show match note if exists
            if (data.matchNote && data.matchNote !== 'null' && data.matchNote !== '') {
                document.getElementById('detail_noteText').textContent = data.matchNote;
                document.getElementById('detail_matchNote').style.display = 'block';
            } else {
                document.getElementById('detail_matchNote').style.display = 'none';
            }

            // Load PO items via AJAX
            loadPOItems(data.poid);

            // Show modal
            document.getElementById('detailModal').style.display = 'block';
        }

        function closeDetailModal() {
            document.getElementById('detailModal').style.display = 'none';
        }

        function formatDateString(dateStr) {
            if (!dateStr || dateStr === 'null') return 'N/A';
            try {
                const date = new Date(dateStr);
                return date.toLocaleDateString('vi-VN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch (e) {
                return dateStr;
            }
        }

        function formatCurrency(amount) {
            if (amount === null || amount === undefined) return '0 ₫';
            return new Intl.NumberFormat('vi-VN').format(amount) + ' ₫';
        }

        function resolveDiscrepancy(invoiceId) {
            const note = prompt('Nhập ghi chú xử lý:');
            if (note) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/procurement/invoice';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'resolve';
                form.appendChild(actionInput);
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'invoiceID';
                idInput.value = invoiceId;
                form.appendChild(idInput);
                
                const noteInput = document.createElement('input');
                noteInput.type = 'hidden';
                noteInput.name = 'note';
                noteInput.value = note;
                form.appendChild(noteInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        // Format dates
        function formatAllDates() {
            const dateElements = document.querySelectorAll('.date-display');
            dateElements.forEach(element => {
                const originalDate = element.getAttribute('data-date');
                if (originalDate && originalDate !== 'null') {
                    try {
                        const date = new Date(originalDate);
                        if (!isNaN(date.getTime())) {
                            const formatted = date.toLocaleDateString('vi-VN', {
                                year: 'numeric',
                                month: '2-digit',
                                day: '2-digit',
                                hour: '2-digit',
                                minute: '2-digit'
                            });
                            element.textContent = formatted;
                        }
                    } catch (e) {
                        console.warn('Date formatting error:', e);
                    }
                }
            });
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const detailModal = document.getElementById('detailModal');
            
            if (event.target === detailModal) {
                closeDetailModal();
            }
        }

        // Initialize on load
        window.onload = function() {
            formatAllDates();
        };
    </script>
</body>
</html>