<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Nhà cung cấp</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dropdown-fix.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/nav-hover-fix.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auto-hide-fix.css">
    <script src="${pageContext.request.contextPath}/js/dropdown-fix.js"></script>
    
    <!-- Simple JavaScript functions -->
    <script>
        function simpleEdit(supplierId) {
            editSupplier(supplierId);
        }
        
        function simpleDetails(supplierId) {
            viewDetails(supplierId);
        }
        
        window.simpleEdit = simpleEdit;
        window.simpleDetails = simpleDetails;
        
        // Global variables
        let currentSupplierId = null;
        let pendingChanges = {};
        
        // Main functions for edit and details
        function editSupplier(supplierId) {
            // Validate supplierId
            if (!supplierId || supplierId === 'undefined' || supplierId === 'null') {
                alert('❌ Lỗi: Không tìm thấy ID nhà cung cấp');
                return;
            }
            
            currentSupplierId = supplierId;
            pendingChanges = {};
            
            // Load supplier data and show edit modal
            loadSupplierData(supplierId);
        }
        
        function viewDetails(supplierId) {
            // Validate supplierId
            if (!supplierId || supplierId === 'undefined' || supplierId === 'null') {
                alert('❌ Lỗi: Không tìm thấy ID nhà cung cấp');
                return;
            }
            
            // Find supplier data from the table
            const supplierData = findSupplierInTable(supplierId);
            
            if (supplierData) {
                showSupplierDetails(supplierData);
            } else {
                alert('❌ Không tìm thấy thông tin nhà cung cấp');
            }
        }
        
        // Helper functions
        function loadSupplierData(supplierId) {
            const supplierData = findSupplierInTable(supplierId);
            if (supplierData) {
                showEditForm(supplierData);
            } else {
                alert('❌ Không tìm thấy thông tin nhà cung cấp');
            }
        }
        
        function findSupplierInTable(supplierId) {
            const table = document.getElementById('supplierTable');
            if (!table) {
                alert('❌ Không tìm thấy bảng nhà cung cấp');
                return null;
            }
            
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 1; i < rows.length; i++) {
                const cells = rows[i].getElementsByTagName('td');
                if (cells.length >= 7) { // Ensure we have enough columns
                    const actionButtons = cells[cells.length - 1].querySelectorAll('.action-btn');
                    for (let btn of actionButtons) {
                        const btnSupplierId = btn.getAttribute('data-supplier-id');
                        
                        if (btnSupplierId === supplierId) {
                            // Extract data more carefully
                            const name = cells[0] ? cells[0].textContent.trim() : '';
                            const contact = cells[1] ? cells[1].textContent.trim() : '';
                            const email = cells[2] ? cells[2].textContent.trim() : '';
                            const phone = cells[3] ? cells[3].textContent.trim() : '';
                            const rating = cells[4] ? extractRating(cells[4]) : 0;
                            const onTimeRate = cells[5] ? extractOnTimeRate(cells[5]) : 0;
                            const isActive = cells[6] ? cells[6].textContent.includes('Hoạt động') : true;
                            
                            return {
                                id: supplierId,
                                name: name,
                                contact: contact,
                                email: email,
                                phone: phone,
                                rating: rating,
                                onTimeRate: onTimeRate,
                                isActive: isActive
                            };
                        }
                    }
                }
            }
            
            alert('❌ Không tìm thấy nhà cung cấp với ID: ' + supplierId);
            return null;
        }
        
        function extractRating(cell) {
            const text = cell.textContent.trim();
            const match = text.match(/(\d+\.?\d*)/);
            return match ? parseFloat(match[1]) : 0;
        }
        
        function extractOnTimeRate(cell) {
            const text = cell.textContent.trim();
            const match = text.match(/(\d+\.?\d*)/);
            return match ? parseFloat(match[1]) : 0;
        }
        
        // Make functions globally available
        // Modal functions
        function showEditForm(supplierData) {
            // Wait for DOM to be ready
            setTimeout(() => {
                const container = document.getElementById('editFormContainer');
                
                if (!container) {
                    alert('❌ Edit form container not found');
                    return;
                }
            
            // Create modern compact edit form with current info display
            container.innerHTML = `
                <form id="editForm" class="compact-form" onsubmit="saveEditForm(event)">
                    <input type="hidden" id="supplierId" value="${supplierData.id}">
                    
                    <!-- Current Information Display -->
                    <div class="current-info">
                        <h3>📋 Thông tin hiện tại</h3>
                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">Tên:</span>
                                <span class="info-value">${supplierData.name != null && supplierData.name != '' ? supplierData.name : 'Chưa có'}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Email:</span>
                                <span class="info-value">${supplierData.email != null && supplierData.email != '' ? supplierData.email : 'Chưa có'}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Liên hệ:</span>
                                <span class="info-value">${supplierData.contact != null && supplierData.contact != '' ? supplierData.contact : 'Chưa có'}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Điện thoại:</span>
                                <span class="info-value">${supplierData.phone != null && supplierData.phone != '' ? supplierData.phone : 'Chưa có'}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Đánh giá:</span>
                                <span class="info-value">${supplierData.rating != null ? supplierData.rating : 0}/5 ⭐</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Đúng hạn:</span>
                                <span class="info-value">${supplierData.onTimeRate != null ? supplierData.onTimeRate : 0}%</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Trạng thái:</span>
                                <span class="info-value">${supplierData.isActive ? '🟢 Hoạt động' : '🔴 Ngừng hoạt động'}</span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Edit Form -->
                    <h3 style="margin: 0 0 16px 0; font-size: 16px; color: #374151;">✏️ Chỉnh sửa thông tin</h3>
                    
                     <div class="form-row">
                         <div class="form-group">
                             <label for="editName">Tên nhà cung cấp</label>
                             <input type="text" id="editName" name="name" value="${supplierData.name != null ? supplierData.name : ''}" placeholder="Nhập tên nhà cung cấp">
                         </div>
                         <div class="form-group">
                             <label for="editContact">Người liên hệ</label>
                             <input type="text" id="editContact" name="contact" value="${supplierData.contact != null ? supplierData.contact : ''}" placeholder="Tên người liên hệ">
                         </div>
                     </div>
                     
                     <div class="form-row">
                         <div class="form-group">
                             <label for="editEmail">Email</label>
                             <input type="email" id="editEmail" name="email" value="${supplierData.email != null ? supplierData.email : ''}" placeholder="email@example.com">
                         </div>
                         <div class="form-group">
                             <label for="editPhone">Điện thoại</label>
                             <input type="tel" id="editPhone" name="phone" value="${supplierData.phone != null ? supplierData.phone : ''}" placeholder="Số điện thoại">
                         </div>
                     </div>
                    
                    <div class="form-row full-width">
                        <div class="form-group">
                            <label for="editAddress">Địa chỉ</label>
                            <textarea id="editAddress" name="address" rows="2" placeholder="Địa chỉ nhà cung cấp">${supplierData.address != null ? supplierData.address : ''}</textarea>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="editRating">Đánh giá (0-5)</label>
                            <input type="number" id="editRating" name="rating" value="${supplierData.rating != null ? supplierData.rating : 0}" min="0" max="5" step="0.1" placeholder="0.0">
                        </div>
                        <div class="form-group">
                            <label for="editOnTimeRate">Tỷ lệ đúng hạn (%)</label>
                            <input type="number" id="editOnTimeRate" name="onTimeRate" value="${supplierData.onTimeRate != null ? supplierData.onTimeRate : 0}" min="0" max="100" step="0.1" placeholder="0">
                        </div>
                    </div>
                    
                    <div class="form-row full-width">
                        <div class="form-group">
                            <label for="editIsActive">Trạng thái</label>
                            <select id="editIsActive" name="isActive">
                                <option value="true" ${supplierData.isActive ? 'selected' : ''}>🟢 Hoạt động</option>
                                <option value="false" ${!supplierData.isActive ? 'selected' : ''}>🔴 Ngừng hoạt động</option>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Actions moved to modal footer -->
                </form>
                
                 <!-- Modal Footer with Actions -->
                 <div class="compact-actions">
                     <button type="button" class="btn btn-secondary" onclick="closeEditModal(); event.stopPropagation();">❌ Hủy</button>
                     <button type="submit" class="btn btn-primary" onclick="document.getElementById('editForm').requestSubmit(); event.stopPropagation();">💾 Lưu thay đổi</button>
                 </div>
            `;
            
                // Show modal with animation
                const editModal = document.getElementById('editModal');
                if (!editModal) {
                    alert('❌ Edit modal not found');
                    return;
                }
                
                editModal.style.display = 'block';
                
                // Trigger animation
                setTimeout(() => {
                    editModal.classList.add('show');
                }, 10);
                
                // Add backdrop click to close
                const backdrop = document.createElement('div');
                backdrop.className = 'modal-backdrop';
                backdrop.onclick = closeEditModal;
                document.body.appendChild(backdrop);
                
                setTimeout(() => {
                    backdrop.classList.add('show');
                }, 10);
            }, 100); // Wait 100ms for DOM to be ready
        }
        
        function showSupplierDetails(supplierData) {
            const detailsHtml = `
                <div class="supplier-details">
                    <div class="details-header">
                        <h3>📋 Chi tiết Nhà cung cấp</h3>
                        <span class="close" onclick="closeDetailsModal()">&times;</span>
                    </div>
                    
                    <div class="details-content">
                        <div class="details-grid">
                            <div class="detail-item">
                                <label>🏢 Tên nhà cung cấp:</label>
                                <span class="detail-value">${supplierData.name}</span>
                            </div>
                            
                            <div class="detail-item">
                                <label>👤 Người liên hệ:</label>
                                <span class="detail-value">${supplierData.contact != null && supplierData.contact != '' ? supplierData.contact : 'Chưa cập nhật'}</span>
                            </div>
                            
                            <div class="detail-item">
                                <label>📧 Email:</label>
                                <span class="detail-value">
                                    <a href="mailto:${supplierData.email}">${supplierData.email}</a>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>📞 Điện thoại:</label>
                                <span class="detail-value">
                                    ${supplierData.phone ? '<a href="tel:' + supplierData.phone + '">' + supplierData.phone + '</a>' : 'Chưa cập nhật'}
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>⭐ Đánh giá:</label>
                                <span class="detail-value rating-display">
                                    <span class="stars-placeholder" data-rating="${supplierData.rating}"></span> 
                                    <span class="rating-number">${supplierData.rating}/5</span>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>⏰ Tỷ lệ đúng hạn:</label>
                                <span class="detail-value">
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: ${supplierData.onTimeRate}%"></div>
                                        <span class="progress-text">${supplierData.onTimeRate}%</span>
                                    </div>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>🔄 Trạng thái:</label>
                                <span class="detail-value">
                                    <span class="status-badge ${supplierData.isActive ? 'active' : 'inactive'}">
                                        ${supplierData.isActive ? 'Hoạt động' : 'Ngừng hoạt động'}
                                    </span>
                                </span>
                            </div>
                        </div>
                        
                        <div class="details-actions">
                            <button class="btn-edit" onclick="editSupplier('${supplierData.id}'); closeDetailsModal();">
                                <i class='bx bx-edit'></i>
                                <span>Sửa thông tin</span>
                            </button>
                            <button class="btn-details" onclick="closeDetailsModal()">
                                <i class='bx bx-x'></i>
                                <span>Đóng</span>
                            </button>
                        </div>
                    </div>
                </div>
            `;
            
            // Create and show modal
            const modal = document.createElement('div');
            modal.id = 'detailsModal';
            modal.className = 'modal';
            modal.innerHTML = detailsHtml;
            document.body.appendChild(modal);
            modal.style.display = 'block';
            
            // Populate stars after modal is created
            const starPlaceholders = modal.querySelectorAll('.stars-placeholder');
            starPlaceholders.forEach(placeholder => {
                const rating = parseFloat(placeholder.getAttribute('data-rating'));
                placeholder.innerHTML = generateStars(rating);
            });
        }
        
        function generateStars(rating) {
            let stars = '';
            for (let i = 1; i <= 5; i++) {
                if (i <= rating) {
                    stars += '★';
                } else {
                    stars += '☆';
                }
            }
            return stars;
        }
        
        function closeDetailsModal() {
            const modal = document.getElementById('detailsModal');
            if (modal) {
                modal.remove();
            }
        }
        
        window.editSupplier = editSupplier;
        window.viewDetails = viewDetails;
        window.loadSupplierData = loadSupplierData;
        window.findSupplierInTable = findSupplierInTable;
        window.showEditForm = showEditForm;
        window.showSupplierDetails = showSupplierDetails;
        window.closeDetailsModal = closeDetailsModal;
        
        // Save edit form function with enhanced validation
        function saveEditForm(event) {
            event.preventDefault();
            
            const form = document.getElementById('editForm');
            const formData = new FormData(form);
            const originalData = findSupplierInTable(document.getElementById('supplierId').value);
            
            if (!originalData) {
                alert('❌ Không tìm thấy dữ liệu gốc của nhà cung cấp');
                return;
            }
            
            // Only send changed fields
            const changes = {};
            const supplierID = document.getElementById('supplierId').value;
            
            // Check each field for changes
            const name = formData.get('name');
            if (name && name !== originalData.name) {
                changes.name = name;
            }
            
            const contact = formData.get('contact');
            if (contact !== originalData.contact) {
                changes.contact = contact;
            }
            
            const email = formData.get('email');
            if (email && email !== originalData.email) {
                changes.email = email;
            }
            
            const phone = formData.get('phone');
            if (phone !== originalData.phone) {
                changes.phone = phone;
            }
            
            const address = formData.get('address');
            if (address !== originalData.address) {
                changes.address = address;
            }
            
            const rating = parseFloat(formData.get('rating'));
            if (rating !== originalData.rating) {
                changes.rating = rating;
            }
            
            const onTimeRate = parseFloat(formData.get('onTimeRate'));
            if (onTimeRate !== originalData.onTimeRate) {
                changes.onTimeRate = onTimeRate;
            }
            
            const isActive = formData.get('isActive') === 'true';
            if (isActive !== originalData.isActive) {
                changes.isActive = isActive;
            }
            
            // Check if any changes were made
            if (Object.keys(changes).length === 0) {
                alert('ℹ️ Không có thay đổi nào để lưu');
                return;
            }
            
            // Add supplierID and action to changes
            changes.supplierId = supplierID;
            changes.action = 'update';
            
            // Show loading state
            const submitBtn = form.querySelector('button[type="submit"]');
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;
            
            // Disable all form inputs during save
            const inputs = form.querySelectorAll('input, textarea, select');
            inputs.forEach(input => input.disabled = true);
            
            // Send AJAX request with only changed fields
            fetch('/procurement/supplier', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(changes)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    showSuccessMessage(data.message || `✅ Cập nhật ${Object.keys(changes).length - 2} thay đổi thành công!`);
                    closeEditModal();
                    // Reload page to show updated data
                    setTimeout(() => {
                        window.location.reload();
                    }, 1500);
                } else {
                    showErrorMessage(data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showErrorMessage('Có lỗi xảy ra khi lưu dữ liệu: ' + error.message);
            })
            .finally(() => {
                // Restore button state
                submitBtn.classList.remove('loading');
                submitBtn.disabled = false;
                inputs.forEach(input => input.disabled = false);
            });
        }
        
        // Client-side form validation
        function validateEditForm() {
            const form = document.getElementById('editForm');
            const name = form.querySelector('#editName').value.trim();
            const email = form.querySelector('#editEmail').value.trim();
            const rating = parseFloat(form.querySelector('#editRating').value);
            const onTimeRate = parseFloat(form.querySelector('#editOnTimeRate').value);
            
            // Clear previous errors
            clearFormErrors();
            
            let isValid = true;
            let errorMessages = [];
            
            // Name validation
            if (!name) {
                showFieldError('editName', 'Tên nhà cung cấp không được để trống');
                isValid = false;
            } else if (name.length < 2) {
                showFieldError('editName', 'Tên nhà cung cấp phải có ít nhất 2 ký tự');
                isValid = false;
            }
            
            // Email validation
            if (!email) {
                showFieldError('editEmail', 'Email không được để trống');
                isValid = false;
            } else if (!email.match(/^[A-Za-z0-9+_.-]+@(.+)$/)) {
                showFieldError('editEmail', 'Email không đúng định dạng');
                isValid = false;
            }
            
            // Rating validation
            if (isNaN(rating) || rating < 0 || rating > 5) {
                showFieldError('editRating', 'Đánh giá phải từ 0 đến 5');
                isValid = false;
            }
            
            // On-time rate validation
            if (isNaN(onTimeRate) || onTimeRate < 0 || onTimeRate > 100) {
                showFieldError('editOnTimeRate', 'Tỷ lệ đúng hạn phải từ 0 đến 100%');
                isValid = false;
            }
            
            if (!isValid) {
                showErrorMessage('Vui lòng kiểm tra lại thông tin đã nhập');
            }
            
            return isValid;
        }
        
        // Show field error
        function showFieldError(fieldId, message) {
            const field = document.getElementById(fieldId);
            field.style.borderColor = '#dc3545';
            
            // Add error message
            let errorDiv = field.parentNode.querySelector('.field-error');
            if (!errorDiv) {
                errorDiv = document.createElement('div');
                errorDiv.className = 'field-error';
                errorDiv.style.color = '#dc3545';
                errorDiv.style.fontSize = '12px';
                errorDiv.style.marginTop = '4px';
                field.parentNode.appendChild(errorDiv);
            }
            errorDiv.textContent = message;
        }
        
        // Clear form errors
        function clearFormErrors() {
            const errorMessages = document.querySelectorAll('.field-error');
            errorMessages.forEach(error => error.remove());
            
            const inputs = document.querySelectorAll('#editForm input, #editForm textarea, #editForm select');
            inputs.forEach(input => input.style.borderColor = '#e9ecef');
        }
        
        // Show success message
        function showSuccessMessage(message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-success';
            alertDiv.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #d4edda;
                color: #155724;
                padding: 15px 20px;
                border: 1px solid #c3e6cb;
                border-radius: 6px;
                z-index: 10000;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            `;
            alertDiv.innerHTML = `✅ ${message}`;
            document.body.appendChild(alertDiv);
            
            // Auto remove after 3 seconds
            setTimeout(() => {
                alertDiv.remove();
            }, 3000);
        }
        
        // Show error message
        function showErrorMessage(message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-error';
            alertDiv.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #f8d7da;
                color: #721c24;
                padding: 15px 20px;
                border: 1px solid #f5c6cb;
                border-radius: 6px;
                z-index: 10000;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            `;
            alertDiv.innerHTML = `❌ ${message}`;
            document.body.appendChild(alertDiv);
            
            // Auto remove after 5 seconds
            setTimeout(() => {
                alertDiv.remove();
            }, 5000);
        }
        
        window.saveEditForm = saveEditForm;
        
        // Event delegation for action buttons (fallback approach)
        document.addEventListener('click', function(e) {
            if (e.target.closest('.action-btn')) {
                const button = e.target.closest('.action-btn');
                const action = button.getAttribute('data-action');
                const supplierId = button.getAttribute('data-supplier-id');
                
                console.log('🔧 Action button clicked:', { action, supplierId });
                
                e.preventDefault();
                
                if (action === 'edit') {
                    if (typeof window.simpleEdit === 'function') {
                        window.simpleEdit(supplierId);
                    } else {
                        alert('✏️ Edit clicked for: ' + supplierId + ' (via event delegation)');
                    }
                } else if (action === 'details') {
                    if (typeof window.simpleDetails === 'function') {
                        window.simpleDetails(supplierId);
                    } else {
                        alert('👁️ Details clicked for: ' + supplierId + ' (via event delegation)');
                    }
                }
            }
        });
    </script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Nhà cung cấp - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e0e0e0;
        }
        .header h1 {
            color: #2c3e50;
            margin: 0;
        }
        .btn {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
        }
        .btn:hover {
            background: #2980b9;
        }
        .btn-success {
            background: #27ae60;
        }
        .btn-success:hover {
            background: #229954;
        }
        .btn-warning {
            background: #f39c12;
        }
        .btn-warning:hover {
            background: #e67e22;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .table th, .table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        .table th {
            background-color: #34495e;
            color: white;
            font-weight: 600;
        }
        .table tr:hover {
            background-color: #f8f9fa;
        }
        .rating {
            color: #f39c12;
            font-weight: bold;
        }
        .status-active {
            color: #27ae60;
            font-weight: bold;
        }
        .status-inactive {
            color: #e74c3c;
            font-weight: bold;
        }
        .search-box {
            margin-bottom: 20px;
        }
        .search-box input {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: 300px;
            font-size: 14px;
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 20px;
            border-radius: 8px;
            width: 80%;
            max-width: 500px;
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: black;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        
        /* Action Buttons Styling */
        .action-buttons {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .btn-edit, .btn-details {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 8px 12px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s ease;
            text-decoration: none;
            min-width: 80px;
            justify-content: center;
        }
        
        .btn-edit {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white;
            box-shadow: 0 2px 4px rgba(243, 156, 18, 0.3);
        }
        
        .btn-edit:hover {
            background: linear-gradient(135deg, #e67e22, #d35400);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(243, 156, 18, 0.4);
        }
        
        .btn-edit:active {
            transform: translateY(0);
            box-shadow: 0 2px 4px rgba(243, 156, 18, 0.3);
        }
        
        .btn-details {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
            box-shadow: 0 2px 4px rgba(52, 152, 219, 0.3);
        }
        
        .btn-details:hover {
            background: linear-gradient(135deg, #2980b9, #1f618d);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(52, 152, 219, 0.4);
        }
        
        .btn-details:active {
            transform: translateY(0);
            box-shadow: 0 2px 4px rgba(52, 152, 219, 0.3);
        }
        
        .btn-edit i, .btn-details i {
            font-size: 14px;
        }
        
        /* Loading state for buttons */
        .btn-edit.loading, .btn-details.loading {
            opacity: 0.7;
            cursor: not-allowed;
            pointer-events: none;
        }
        
        .btn-edit.loading::after, .btn-details.loading::after {
            content: '';
            width: 12px;
            height: 12px;
            border: 2px solid transparent;
            border-top: 2px solid currentColor;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 6px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* Responsive buttons */
        @media (max-width: 768px) {
            .action-buttons {
                flex-direction: column;
                gap: 4px;
            }
            
            .btn-edit, .btn-details {
                min-width: 70px;
                padding: 6px 10px;
                font-size: 12px;
            }
            
            .btn-edit span, .btn-details span {
                display: none;
            }
            
            .btn-edit i, .btn-details i {
                font-size: 16px;
            }
        }
        
        /* Details Modal Styling */
        .supplier-details {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            max-width: 600px;
            margin: 5% auto;
            overflow: hidden;
        }
        
        .details-header {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .details-header h3 {
            margin: 0;
            font-size: 20px;
            font-weight: 600;
        }
        
        .details-header .close {
            color: white;
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        
        .details-header .close:hover {
            opacity: 0.7;
        }
        
        .details-content {
            padding: 30px;
        }
        
        .details-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .detail-item {
            display: flex;
            align-items: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #3498db;
        }
        
        .detail-item label {
            font-weight: 600;
            color: #2c3e50;
            min-width: 150px;
            margin-right: 15px;
        }
        
        .detail-value {
            flex: 1;
            color: #34495e;
        }
        
        .detail-value a {
            color: #3498db;
            text-decoration: none;
        }
        
        .detail-value a:hover {
            text-decoration: underline;
        }
        
        .rating-display {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .rating-display .rating-number {
            font-weight: 600;
            color: #f39c12;
        }
        
        .progress-bar {
            position: relative;
            background: #e9ecef;
            border-radius: 10px;
            height: 20px;
            overflow: hidden;
            width: 200px;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #27ae60, #2ecc71);
            border-radius: 10px;
            transition: width 0.3s ease;
        }
        
        .progress-text {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 12px;
            font-weight: 600;
            color: white;
            text-shadow: 0 1px 2px rgba(0,0,0,0.5);
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-badge.active {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .status-badge.inactive {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .details-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }
        
        /* Edit Form Styling */
        #editForm {
            padding: 20px;
        }
        
        #editForm .form-group {
            margin-bottom: 20px;
        }
        
        #editForm label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #2c3e50;
        }
        
        #editForm input, #editForm textarea, #editForm select {
            width: 100%;
            padding: 10px;
            border: 2px solid #e9ecef;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.3s ease;
            box-sizing: border-box;
        }
        
        #editForm input:focus, #editForm textarea:focus, #editForm select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        
        #editForm textarea {
            resize: vertical;
            min-height: 80px;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }
        
        .form-actions .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .form-actions .btn-primary {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
        }
        
        .form-actions .btn-primary:hover {
            background: linear-gradient(135deg, #2980b9, #1f618d);
            transform: translateY(-1px);
        }
        
        .form-actions .btn-primary:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
        
        .form-actions .btn:not(.btn-primary) {
            background: #6c757d;
            color: white;
        }
        
        .form-actions .btn:not(.btn-primary):hover {
            background: #5a6268;
        }
        
        /* Modern Modal Styling */
        .modern-modal {
            max-width: 800px;
            width: 90%;
            max-height: 85vh;
            margin: 8vh auto 2vh auto; /* Push down to avoid header overlap */
            border-radius: 16px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            overflow: hidden;
            background: white;
            display: flex;
            flex-direction: column;
            position: relative;
            z-index: 99999; /* CRITICAL: Highest z-index */
        }
        
        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .modal-header h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 600;
        }
        
        .close-btn {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            padding: 8px;
            border-radius: 8px;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .close-btn:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: scale(1.1);
        }
        
        .close-btn:active {
            transform: scale(0.95);
        }
        
        .modal-body {
            flex: 1;
            overflow-y: auto;
            padding: 0;
        }
        
        /* Compact Form Styling */
        .compact-form {
            padding: 24px;
        }
        
        .compact-form .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 16px;
        }
        
        .compact-form .form-row.full-width {
            grid-template-columns: 1fr;
        }
        
        .compact-form .form-group {
            margin-bottom: 0;
        }
        
        .compact-form label {
            font-size: 13px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
            display: block;
        }
        
        .compact-form input,
        .compact-form textarea,
        .compact-form select {
            padding: 10px 12px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.2s ease;
            background: #fafafa;
        }
        
        .compact-form input:focus,
        .compact-form textarea:focus,
        .compact-form select:focus {
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            outline: none;
        }
        
        .compact-form textarea {
            resize: vertical;
            min-height: 60px;
        }
        
        /* Current Info Display */
        .current-info {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 20px;
        }
        
        .current-info h3 {
            margin: 0 0 12px 0;
            font-size: 14px;
            color: #475569;
            font-weight: 600;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px;
        }
        
        .info-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .info-label {
            font-size: 12px;
            color: #64748b;
            font-weight: 500;
            min-width: 80px;
        }
        
        .info-value {
            font-size: 13px;
            color: #1e293b;
            font-weight: 600;
        }
        
        /* Compact Actions */
        .compact-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 20px 24px;
            border-top: 1px solid #e5e7eb;
            background: #fafafa;
        }
        
        .compact-actions .btn {
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .compact-actions .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .compact-actions .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        .compact-actions .btn-secondary {
            background: #6b7280;
            color: white;
        }
        
        .compact-actions .btn-secondary:hover {
            background: #4b5563;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .modern-modal {
                width: 95%;
                margin: 2vh auto;
                max-height: 96vh;
            }
            
            .compact-form .form-row {
                grid-template-columns: 1fr;
                gap: 12px;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .compact-actions {
                flex-direction: column;
            }
        }
        
        /* Scroll Styling */
        .modal-body::-webkit-scrollbar {
            width: 6px;
        }
        
        .modal-body::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        
        .modal-body::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 3px;
        }
        
        .modal-body::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }
        
        /* Modal Animation */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 10000; /* CRITICAL: Highest z-index */
            transition: all 0.3s ease;
        }
        
        .modal-content {
            transition: all 0.3s ease;
        }
        
        .modal.show .modal-content {
            transform: scale(1);
            opacity: 1;
        }
        
        .modal-content {
            transform: scale(0.9);
            opacity: 0;
        }
        
        /* Backdrop click to close */
        .modal-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 9999; /* High z-index for backdrop */
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }
        
        .modal-backdrop.show {
            opacity: 1;
            visibility: visible;
        }
        
        /* Enhanced close button functionality */
        .close-btn:focus {
            outline: 2px solid rgba(255, 255, 255, 0.5);
            outline-offset: 2px;
        }
        
        /* Form enhancement */
        .compact-form input:invalid,
        .compact-form textarea:invalid {
            border-color: #ef4444;
        }
        
        .compact-form input:valid,
        .compact-form textarea:valid {
            border-color: #10b981;
        }
        
        /* Loading state for save button */
        .btn-primary.loading {
            position: relative;
            color: transparent;
        }
        
        .btn-primary.loading::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 16px;
            height: 16px;
            border: 2px solid transparent;
            border-top: 2px solid currentColor;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: translate(-50%, -50%) rotate(0deg); }
            100% { transform: translate(-50%, -50%) rotate(360deg); }
        }
        
        /* CRITICAL: Ensure modal is always on top */
        .modal {
            position: fixed !important;
            z-index: 99999 !important;
        }
        
        .modal-content {
            position: relative !important;
            z-index: 100000 !important;
        }
        
        /* Override any conflicting styles */
        .modal.modal.show {
            z-index: 99999 !important;
        }
        
        /* Ensure backdrop is below modal but above everything else */
        .modal-backdrop {
            z-index: 99998 !important;
        }
    </style>
</head>
<body>
    <jsp:include page="../includes/header.jsp">
        <jsp:param name="page" value="procurement" />
    </jsp:include>
    
    <div class="container">
        
        <div class="header">
            <h1>📦 Quản lý Nhà cung cấp</h1>
            <button class="btn btn-success" onclick="openAddModal()">+ Thêm Nhà cung cấp</button>
        </div>

        <div class="search-box">
            <input type="text" id="searchInput" placeholder="Tìm kiếm nhà cung cấp..." onkeyup="filterTable()">
        </div>

        <table class="table" id="supplierTable">
            <thead>
                <tr>
                    <th>Tên Nhà cung cấp</th>
                    <th>Liên hệ</th>
                    <th>Email</th>
                    <th>Điện thoại</th>
                    <th>Đánh giá</th>
                    <th>Tỷ lệ đúng hạn</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="supplier" items="${suppliers}">
                    <tr>
                        <td><strong>${supplier.name}</strong></td>
                        <td>${supplier.contact}</td>
                        <td>${supplier.email}</td>
                        <td>${supplier.phone}</td>
                        <td>
                            <span class="rating">
                                <c:forEach begin="1" end="5" var="i">
                                    <c:choose>
                                        <c:when test="${i <= supplier.rating}">★</c:when>
                                        <c:otherwise>☆</c:otherwise>
                                    </c:choose>
                                </c:forEach>
                                <fmt:formatNumber value="${supplier.rating}" pattern="#.#"/>
                            </span>
                        </td>
                        <td><fmt:formatNumber value="${supplier.onTimeRate}" pattern="#.#"/>%</td>
                        <td>
                            <c:choose>
                                <c:when test="${supplier.isActive}">
                                    <span class="status-active">Hoạt động</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-inactive">Ngừng hoạt động</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-edit action-btn" data-action="edit" data-supplier-id="${supplier.supplierID}" title="Sửa thông tin nhà cung cấp">
                                    <i class='bx bx-edit'></i>
                                    <span>Sửa</span>
                                </button>
                                <button class="btn-details action-btn" data-action="details" data-supplier-id="${supplier.supplierID}" title="Xem chi tiết nhà cung cấp">
                                    <i class='bx bx-show'></i>
                                    <span>Chi tiết</span>
                                </button>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Modal thêm nhà cung cấp -->
    <div id="supplierModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2 id="modalTitle">Thêm Nhà cung cấp</h2>
            <form id="supplierForm" action="${pageContext.request.contextPath}/procurement/supplier" method="post">
                <div class="form-group">
                    <label for="name">Tên nhà cung cấp *</label>
                    <input type="text" id="name" name="name" required>
                </div>
                <div class="form-group">
                    <label for="contact">Người liên hệ</label>
                    <input type="text" id="contact" name="contact">
                </div>
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" required>
                </div>
                <div class="form-group">
                    <label for="phone">Điện thoại</label>
                    <input type="tel" id="phone" name="phone">
                </div>
                <div class="form-group">
                    <label for="address">Địa chỉ</label>
                    <textarea id="address" name="address" rows="3"></textarea>
                </div>
                <div style="text-align: right; margin-top: 20px;">
                    <button type="button" class="btn" onclick="closeModal()">Hủy</button>
                    <button type="submit" class="btn btn-success">Lưu</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal sửa nhà cung cấp -->
    <div id="editModal" class="modal">
        <div class="modal-content modern-modal">
            <div class="modal-header">
                <h2>✏️ Sửa Nhà cung cấp</h2>
                <button type="button" class="close-btn" onclick="closeEditModal(); event.stopPropagation();" title="Đóng">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </button>
            </div>
            <div class="modal-body">
                <div id="editFormContainer">
                    <!-- Form sẽ được load động -->
                </div>
            </div>
        </div>
    </div>

    <!-- Modal xác nhận -->
    <div id="confirmModal" class="modal">
        <div class="modal-content" style="max-width: 400px;">
            <h2>⚠️ Xác nhận thay đổi</h2>
            <p id="confirmMessage">Bạn có chắc chắn muốn lưu các thay đổi này không?</p>
            <div style="text-align: right; margin-top: 20px;">
                <button type="button" class="btn" onclick="closeConfirmModal()">Hủy</button>
                <button type="button" class="btn btn-success" onclick="confirmSave()">Xác nhận</button>
            </div>
        </div>
    </div>

    <script>
        // Global variables
        let currentSupplierId = null;
        let pendingChanges = {};
        
        // Functions are now defined in head section for immediate availability

        function openAddModal() {
            document.getElementById('modalTitle').textContent = 'Thêm Nhà cung cấp';
            document.getElementById('supplierForm').reset();
            document.getElementById('supplierModal').style.display = 'block';
        }

        // editSupplier function is now defined in head section

        // loadSupplierData function is now defined in head section

        // extractRating and extractOnTimeRate functions are now defined in head section

        function showEditForm(supplierData) {
            const container = document.getElementById('editFormContainer');
            container.innerHTML = `
                <form id="editForm">
                    <input type="hidden" id="supplierId" value="${supplierData.id}">
                    
                    <div class="form-group">
                        <label for="editName">Tên nhà cung cấp *</label>
                        <input type="text" id="editName" value="${supplierData.name}" 
                               onchange="markFieldChanged('name', this.value)" 
                               onblur="updateField('name', this.value)">
                        <small style="color: #666;">Chỉ thay đổi nếu cần sửa</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editContact">Người liên hệ</label>
                        <input type="text" id="editContact" value="${supplierData.contact}" 
                               onchange="markFieldChanged('contact', this.value)" 
                               onblur="updateField('contact', this.value)">
                        <small style="color: #666;">Chỉ thay đổi nếu cần sửa</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editEmail">Email *</label>
                        <input type="email" id="editEmail" value="${supplierData.email}" 
                               onchange="markFieldChanged('email', this.value)" 
                               onblur="updateField('email', this.value)">
                        <small style="color: #666;">Chỉ thay đổi nếu cần sửa</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editPhone">Điện thoại</label>
                        <input type="tel" id="editPhone" value="${supplierData.phone}" 
                               onchange="markFieldChanged('phone', this.value)" 
                               onblur="updateField('phone', this.value)">
                        <small style="color: #666;">Chỉ thay đổi nếu cần sửa</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editRating">Đánh giá (1-5)</label>
                        <input type="number" id="editRating" min="1" max="5" step="0.1" value="${supplierData.rating}" 
                               onchange="markFieldChanged('rating', this.value)" 
                               onblur="updateField('rating', this.value)">
                        <small style="color: #666;">Chỉ thay đổi nếu cần sửa</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editOnTimeRate">Tỷ lệ đúng hạn (%)</label>
                        <input type="number" id="editOnTimeRate" min="0" max="100" step="0.1" value="${supplierData.onTimeRate}" 
                               onchange="markFieldChanged('onTimeRate', this.value)" 
                               onblur="updateField('onTimeRate', this.value)">
                        <small style="color: #666;">Chỉ thay đổi nếu cần sửa</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editIsActive">Trạng thái</label>
                        <select id="editIsActive" onchange="markFieldChanged('isActive', this.value)">
                            <option value="true" ${supplierData.isActive ? 'selected' : ''}>Hoạt động</option>
                            <option value="false" ${!supplierData.isActive ? 'selected' : ''}>Ngừng hoạt động</option>
                        </select>
                        <small style="color: #666;">Chỉ thay đổi nếu cần sửa</small>
                    </div>
                    
                    <div style="text-align: right; margin-top: 20px;">
                        <button type="button" class="btn" onclick="closeEditModal()">Hủy</button>
                        <button type="button" class="btn btn-success" onclick="saveChanges()" id="saveBtn" disabled>Lưu thay đổi</button>
                    </div>
                </form>
                
                <div id="changesSummary" style="margin-top: 20px; padding: 10px; background: #f8f9fa; border-radius: 5px; display: none;">
                    <h4>📝 Thay đổi đã thực hiện:</h4>
                    <ul id="changesList"></ul>
                </div>
            `;
            
            document.getElementById('editModal').style.display = 'block';
        }

        function markFieldChanged(fieldName, value) {
            pendingChanges[fieldName] = value;
            updateChangesSummary();
            updateSaveButton();
        }

        function updateField(fieldName, value) {
            if (value !== pendingChanges[fieldName]) {
                markFieldChanged(fieldName, value);
            }
        }

        function updateChangesSummary() {
            const summary = document.getElementById('changesSummary');
            const list = document.getElementById('changesList');
            
            if (Object.keys(pendingChanges).length > 0) {
                summary.style.display = 'block';
                list.innerHTML = '';
                
                Object.entries(pendingChanges).forEach(([field, value]) => {
                    const fieldNames = {
                        'name': 'Tên nhà cung cấp',
                        'contact': 'Người liên hệ',
                        'email': 'Email',
                        'phone': 'Điện thoại',
                        'rating': 'Đánh giá',
                        'onTimeRate': 'Tỷ lệ đúng hạn',
                        'isActive': 'Trạng thái'
                    };
                    
                    const li = document.createElement('li');
                    li.textContent = `${fieldNames[field]}: ${value}`;
                    list.appendChild(li);
                });
            } else {
                summary.style.display = 'none';
            }
        }

        function updateSaveButton() {
            const saveBtn = document.getElementById('saveBtn');
            if (Object.keys(pendingChanges).length > 0) {
                saveBtn.disabled = false;
                saveBtn.textContent = `Lưu thay đổi (${Object.keys(pendingChanges).length})`;
            } else {
                saveBtn.disabled = true;
                saveBtn.textContent = 'Lưu thay đổi';
            }
        }

        function saveChanges() {
            if (Object.keys(pendingChanges).length === 0) {
                alert('Không có thay đổi nào để lưu');
                return;
            }
            
            // Show confirmation modal
            document.getElementById('confirmModal').style.display = 'block';
        }

        function confirmSave() {
            const formData = new FormData();
            formData.append('action', 'update');
            formData.append('supplierId', currentSupplierId);
            
            // Add only changed fields
            Object.entries(pendingChanges).forEach(([field, value]) => {
                formData.append(field, value);
            });
            
            // Send AJAX request
            fetch('${pageContext.request.contextPath}/procurement/supplier', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('✅ ' + data.message);
                    closeEditModal();
                    location.reload(); // Reload to show updated data
                } else {
                    alert('❌ ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('❌ Có lỗi xảy ra khi lưu dữ liệu');
            });
        }

        function viewDetails(supplierId) {
            console.log('View details clicked:', supplierId);
            
            // Validate supplierId
            if (!supplierId || supplierId === 'undefined' || supplierId === 'null') {
                alert('❌ Lỗi: Không tìm thấy ID nhà cung cấp');
                console.error('Invalid supplier ID:', supplierId);
                return;
            }
            
            // Add loading state
            const detailsBtn = event.target.closest('.btn-details');
            if (detailsBtn) {
                detailsBtn.classList.add('loading');
            }
            
            setTimeout(() => {
                try {
                    // Find supplier data from the table
                    const supplierData = findSupplierInTable(supplierId);
                    
                    if (supplierData) {
                        showSupplierDetails(supplierData);
                    } else {
                        alert('❌ Không tìm thấy thông tin nhà cung cấp');
                        console.error('Supplier data not found for ID:', supplierId);
                    }
                } catch (error) {
                    console.error('Error showing supplier details:', error);
                    alert('❌ Lỗi khi hiển thị chi tiết nhà cung cấp');
                } finally {
                    if (detailsBtn) {
                        detailsBtn.classList.remove('loading');
                    }
                }
            }, 300);
        }
        
        function findSupplierInTable(supplierId) {
            const table = document.getElementById('supplierTable');
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 1; i < rows.length; i++) {
                const cells = rows[i].getElementsByTagName('td');
                if (cells.length > 0) {
                    const editButton = cells[cells.length - 1].querySelector('button[onclick*="' + supplierId + '"]');
                    if (editButton) {
                        return {
                            id: supplierId,
                            name: cells[0].textContent.trim(),
                            contact: cells[1].textContent.trim(),
                            email: cells[2].textContent.trim(),
                            phone: cells[3].textContent.trim(),
                            rating: extractRating(cells[4]),
                            onTimeRate: extractOnTimeRate(cells[5]),
                            isActive: cells[6].textContent.includes('Hoạt động')
                        };
                    }
                }
            }
            return null;
        }
        
        function showSupplierDetails(supplierData) {
            const detailsHtml = `
                <div class="supplier-details">
                    <div class="details-header">
                        <h3>📋 Chi tiết Nhà cung cấp</h3>
                        <span class="close" onclick="closeDetailsModal()">&times;</span>
                    </div>
                    
                    <div class="details-content">
                        <div class="details-grid">
                            <div class="detail-item">
                                <label>🏢 Tên nhà cung cấp:</label>
                                <span class="detail-value">${supplierData.name}</span>
                            </div>
                            
                            <div class="detail-item">
                                <label>👤 Người liên hệ:</label>
                                <span class="detail-value">${supplierData.contact != null && supplierData.contact != '' ? supplierData.contact : 'Chưa cập nhật'}</span>
                            </div>
                            
                            <div class="detail-item">
                                <label>📧 Email:</label>
                                <span class="detail-value">
                                    <a href="mailto:${supplierData.email}">${supplierData.email}</a>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>📞 Điện thoại:</label>
                                <span class="detail-value">
                                    ${supplierData.phone ? '<a href="tel:' + supplierData.phone + '">' + supplierData.phone + '</a>' : 'Chưa cập nhật'}
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>⭐ Đánh giá:</label>
                                <span class="detail-value rating-display">
                                    <span class="stars-placeholder" data-rating="${supplierData.rating}"></span> 
                                    <span class="rating-number">${supplierData.rating}/5</span>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>⏰ Tỷ lệ đúng hạn:</label>
                                <span class="detail-value">
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: ${supplierData.onTimeRate}%"></div>
                                        <span class="progress-text">${supplierData.onTimeRate}%</span>
                                    </div>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <label>🔄 Trạng thái:</label>
                                <span class="detail-value">
                                    <span class="status-badge ${supplierData.isActive ? 'active' : 'inactive'}">
                                        ${supplierData.isActive ? 'Hoạt động' : 'Ngừng hoạt động'}
                                    </span>
                                </span>
                            </div>
                        </div>
                        
                        <div class="details-actions">
                            <button class="btn-edit" onclick="editSupplier('${supplierData.id}'); closeDetailsModal();">
                                <i class='bx bx-edit'></i>
                                <span>Sửa thông tin</span>
                            </button>
                            <button class="btn-details" onclick="closeDetailsModal()">
                                <i class='bx bx-x'></i>
                                <span>Đóng</span>
                            </button>
                        </div>
                    </div>
                </div>
            `;
            
            // Create and show modal
            const modal = document.createElement('div');
            modal.id = 'detailsModal';
            modal.className = 'modal';
            modal.innerHTML = detailsHtml;
            document.body.appendChild(modal);
            modal.style.display = 'block';
        }
        
        function generateStars(rating) {
            let stars = '';
            for (let i = 1; i <= 5; i++) {
                if (i <= rating) {
                    stars += '★';
                } else if (i - 0.5 <= rating) {
                    stars += '☆';
                } else {
                    stars += '☆';
                }
            }
            return stars;
        }
        
        function closeDetailsModal() {
            const modal = document.getElementById('detailsModal');
            if (modal) {
                modal.remove();
            }
        }

        function closeModal() {
            document.getElementById('supplierModal').style.display = 'none';
        }

        function closeEditModal() {
            const editModal = document.getElementById('editModal');
            const backdrop = document.querySelector('.modal-backdrop');
            
            if (editModal) {
                // Remove show class for animation
                editModal.classList.remove('show');
                
                if (backdrop) {
                    backdrop.classList.remove('show');
                }
                
                setTimeout(() => {
                    editModal.style.display = 'none';
                    
                    // Remove backdrop
                    if (backdrop) {
                        backdrop.remove();
                    }
                    
                    // Clear form container
                    const container = document.getElementById('editFormContainer');
                    if (container) {
                        container.innerHTML = '';
                    }
                }, 300);
            }
            currentSupplierId = null;
            pendingChanges = {};
        }
        
        window.closeEditModal = closeEditModal;

        function closeConfirmModal() {
            document.getElementById('confirmModal').style.display = 'none';
        }

        function filterTable() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const table = document.getElementById('supplierTable');
            const tr = table.getElementsByTagName('tr');

            for (let i = 1; i < tr.length; i++) {
                const td = tr[i].getElementsByTagName('td');
                let found = false;
                for (let j = 0; j < td.length; j++) {
                    if (td[j].textContent.toLowerCase().indexOf(filter) > -1) {
                        found = true;
                        break;
                    }
                }
                tr[i].style.display = found ? '' : 'none';
            }
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const supplierModal = document.getElementById('supplierModal');
            const editModal = document.getElementById('editModal');
            const confirmModal = document.getElementById('confirmModal');
            
            if (event.target === supplierModal) {
                closeModal();
            } else if (event.target === editModal) {
                closeEditModal();
            } else if (event.target === confirmModal) {
                closeConfirmModal();
            }
        }
        
        // Initialize page functionality
        document.addEventListener('DOMContentLoaded', function() {
            
            // Add event delegation for action buttons
            document.addEventListener('click', function(e) {
                if (e.target.closest('.btn-edit, .btn-details')) {
                    const button = e.target.closest('.btn-edit, .btn-details');
                    const supplierId = button.getAttribute('data-supplier-id');
                    const action = button.getAttribute('data-action');
                    
                    e.preventDefault();
                    
                    if (action === 'edit' && typeof editSupplier === 'function') {
                        editSupplier(supplierId);
                    } else if (action === 'details' && typeof viewDetails === 'function') {
                        viewDetails(supplierId);
                    } else {
                        alert('❌ Chức năng chưa sẵn sàng. Vui lòng thử lại sau.');
                    }
                }
            });
            
        });
        
        // Ensure functions are globally accessible
        window.editSupplier = editSupplier;
        window.viewDetails = viewDetails;
        window.openAddModal = openAddModal;
        window.closeModal = closeModal;
        window.closeEditModal = closeEditModal;
        window.closeConfirmModal = closeConfirmModal;
        window.saveChanges = saveChanges;
        window.confirmSave = confirmSave;
        window.filterTable = filterTable;
        
    </script>
</body>
</html>
