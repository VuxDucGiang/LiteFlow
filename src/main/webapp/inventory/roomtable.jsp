<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="../includes/header.jsp">
  <jsp:param name="page" value="rooms" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/roomtable.css">
<script src="${pageContext.request.contextPath}/js/roomtable-enhancements.js"></script>
<script src="${pageContext.request.contextPath}/js/roomtable-enhanced.js"></script>

<div class="content">
    <!-- Statistics -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-number">${rooms.size()}</div>
            <div class="stat-label">Tổng số phòng</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">${tables.size()}</div>
            <div class="stat-label">Tổng số bàn</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <c:set var="availableTables" value="0" />
                <c:forEach var="table" items="${tables}">
                    <c:if test="${table.status == 'Available'}">
                        <c:set var="availableTables" value="${availableTables + 1}" />
                    </c:if>
                </c:forEach>
                ${availableTables}
            </div>
            <div class="stat-label">Bàn trống</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <c:set var="occupiedTables" value="0" />
                <c:forEach var="table" items="${tables}">
                    <c:if test="${table.status == 'Occupied'}">
                        <c:set var="occupiedTables" value="${occupiedTables + 1}" />
                    </c:if>
                </c:forEach>
                ${occupiedTables}
            </div>
            <div class="stat-label">Bàn đang sử dụng</div>
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

    <!-- Toolbar -->
    <div class="toolbar">
        <div class="search-box">
            <input type="text" class="search-input" placeholder="Tìm kiếm phòng, bàn..." id="searchInput">
            <button class="btn btn-primary" onclick="searchItems()">🔍 Tìm kiếm</button>
        </div>
        <div>
            <a href="#" class="btn btn-success" onclick="addRoom()">🏢 Thêm phòng</a>
            <a href="#" class="btn btn-primary" onclick="addTable()">🪑 Thêm bàn</a>
        </div>
    </div>

    <!-- Rooms Section -->
    <div class="room-table-container">
        <div class="section-title">🏢 Danh sách phòng</div>
        <c:choose>
            <c:when test="${empty rooms}">
                <div class="empty-state">
                    <h3>🏢 Chưa có phòng nào</h3>
                    <p>Hãy thêm phòng đầu tiên để bắt đầu quản lý</p>
                    <a href="#" class="btn btn-success" onclick="addRoom()" style="margin-top: 1rem;">🏢 Thêm phòng</a>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table">
                    <thead>
                        <tr>
                            <th class="sortable" onclick="sortTable(0, 'string', 'rooms')">
                                Tên phòng
                                <span class="sort-icon"></span>
                            </th>
                            <th>
                                Mô tả
                            </th>
                            <th class="sortable" onclick="sortTable(2, 'date', 'rooms')">
                                Ngày tạo
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(3, 'number', 'rooms')">
                                Số lượng bàn
                                <span class="sort-icon"></span>
                            </th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="room" items="${rooms}">
                            <tr>
                                <td>
                                    <div class="room-name">${room.name}</div>
                                </td>
                                <td>${room.description != null ? room.description : 'Không có mô tả'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${room.createdAt != null}">
                                            <c:set var="dateValue" value="${room.createdAt}" />
                                            <c:choose>
                                                <c:when test="${dateValue.getClass().simpleName == 'LocalDateTime'}">
                                                    ${room.createdAt}
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatDate value="${room.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:set var="tableCount" value="0" />
                                    <c:forEach var="table" items="${tables}">
                                        <c:if test="${table.room != null && table.room.roomId == room.roomId}">
                                            <c:set var="tableCount" value="${tableCount + 1}" />
                                        </c:if>
                                    </c:forEach>
                                    ${tableCount}
                                </td>
                                <td>
                                    <div class="actions">
                                        <button class="btn btn-warning btn-sm" onclick="editRoom('${room.roomId}')">
                                            ✏️ Sửa
                                        </button>
                                        <button class="btn btn-danger btn-sm" onclick="deleteRoom('${room.roomId}')">
                                            🗑️ Xóa
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Tables Section -->
    <div class="room-table-container">
        <div class="section-title">🪑 Danh sách bàn</div>
        <c:choose>
            <c:when test="${empty tables}">
                <div class="empty-state">
                    <h3>🪑 Chưa có bàn nào</h3>
                    <p>Hãy thêm bàn đầu tiên để bắt đầu quản lý</p>
                    <a href="#" class="btn btn-success" onclick="addTable()" style="margin-top: 1rem;">🪑 Thêm bàn</a>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table">
                    <thead>
                        <tr>
                            <th class="sortable" onclick="sortTable(0, 'string', 'tables')">
                                Số bàn
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(1, 'string', 'tables')">
                                Tên bàn
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(2, 'string', 'tables')">
                                Phòng
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(3, 'number', 'tables')">
                                Sức chứa
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(4, 'string', 'tables')">
                                Trạng thái
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(5, 'date', 'tables')">
                                Ngày tạo
                                <span class="sort-icon"></span>
                            </th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="table" items="${tables}">
                            <tr>
                                <td>
                                    <span class="table-number">${table.tableNumber}</span>
                                </td>
                                <td>
                                    <span class="table-name">${table.tableName != null ? table.tableName : 'Không có tên'}</span>
                                </td>
                                <td>${table.room != null ? table.room.name : 'Không có phòng'}</td>
                                <td>
                                    <span class="capacity-badge">${table.capacity != null ? table.capacity : 4} người</span>
                                </td>
                                <td>
                                    <span class="status ${table.status.toLowerCase()}">
                                        <c:choose>
                                            <c:when test="${table.status == 'Available'}">Trống</c:when>
                                            <c:when test="${table.status == 'Occupied'}">Đang sử dụng</c:when>
                                            <c:when test="${table.status == 'Reserved'}">Đã đặt</c:when>
                                            <c:when test="${table.status == 'Maintenance'}">Bảo trì</c:when>
                                            <c:otherwise>${table.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${table.createdAt != null}">
                                            <c:set var="tableDateValue" value="${table.createdAt}" />
                                            <c:choose>
                                                <c:when test="${tableDateValue.getClass().simpleName == 'LocalDateTime'}">
                                                    ${table.createdAt}
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatDate value="${table.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="actions">
                                        <button class="btn btn-info btn-sm" onclick="viewTableDetails('${table.tableId}')">
                                            👁️ Chi tiết
                                        </button>
                                        <button class="btn btn-warning btn-sm" onclick="editTable('${table.tableId}')">
                                            ✏️ Sửa
                                        </button>
                                        <button class="btn btn-primary btn-sm" onclick="changeTableStatus('${table.tableId}', '${table.status}')">
                                            🔄 Đổi trạng thái
                                        </button>
                                        <button class="btn btn-success btn-sm" onclick="viewTableHistory('${table.tableId}')">
                                            📋 Lịch sử
                                        </button>
                                        <button class="btn btn-danger btn-sm" onclick="deleteTable('${table.tableId}')">
                                            🗑️ Xóa
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
    // Biến để theo dõi trạng thái sắp xếp
    let currentSortColumn = -1;
    let currentSortDirection = 'asc';
    let currentSortTable = '';

    function searchItems() {
        const searchTerm = document.getElementById('searchInput').value.toLowerCase();
        const rows = document.querySelectorAll('.table tbody tr');

        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            if (text.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    function sortTable(columnIndex, dataType, tableType) {
        console.log('🔄 Sorting table:', tableType, 'column:', columnIndex, 'type:', dataType);
        
        // Tìm bảng theo cách đơn giản hơn
        let table;
        if (tableType === 'rooms') {
            // Tìm bảng phòng đầu tiên
            table = document.querySelector('.room-table-container .table');
        } else {
            // Tìm bảng bàn thứ hai
            const containers = document.querySelectorAll('.room-table-container');
            table = containers.length > 1 ? containers[1].querySelector('.table') : null;
        }
        
        if (!table) {
            console.error('❌ Table not found for type:', tableType);
            return;
        }
        
        console.log('✅ Table found:', table);
        
        const tbody = table.querySelector('tbody');
        if (!tbody) {
            console.log('Tbody not found');
            return;
        }
        
        const rows = Array.from(tbody.querySelectorAll('tr'));
        console.log('Found rows:', rows.length);
        
        if (rows.length === 0) {
            console.log('No rows to sort');
            return;
        }
        
        // Xóa class sort cũ cho bảng hiện tại
        const currentTableHeaders = table.querySelectorAll('th');
        currentTableHeaders.forEach(th => {
            th.classList.remove('sort-asc', 'sort-desc');
        });

        // Xác định hướng sắp xếp
        console.log('Previous sort:', currentSortColumn, currentSortTable, currentSortDirection);
        if (currentSortColumn === columnIndex && currentSortTable === tableType) {
            currentSortDirection = currentSortDirection === 'asc' ? 'desc' : 'asc';
            console.log('🔄 Toggle sort direction to:', currentSortDirection);
        } else {
            currentSortDirection = 'asc';
            console.log('🆕 New sort direction:', currentSortDirection);
        }
        currentSortColumn = columnIndex;
        currentSortTable = tableType;

        // Thêm class sort cho header hiện tại
        const currentHeader = currentTableHeaders[columnIndex];
        if (currentHeader) {
            currentHeader.classList.add(currentSortDirection === 'asc' ? 'sort-asc' : 'sort-desc');
            console.log('✅ Added sort class:', currentSortDirection === 'asc' ? 'sort-asc' : 'sort-desc');
        }

        // Sắp xếp các hàng
        console.log('🔄 Starting sort with direction:', currentSortDirection);
        rows.sort((a, b) => {
            let aValue, bValue;
            
            try {
                if (tableType === 'rooms') {
                    // Sắp xếp cho bảng phòng
                    if (columnIndex === 0) { // Tên phòng
                        aValue = a.cells[0].textContent.trim();
                        bValue = b.cells[0].textContent.trim();
                    } else if (columnIndex === 2) { // Ngày tạo
                        const aDateStr = a.cells[2].textContent.trim();
                        const bDateStr = b.cells[2].textContent.trim();
                        aValue = aDateStr === 'N/A' ? new Date(0) : new Date(aDateStr);
                        bValue = bDateStr === 'N/A' ? new Date(0) : new Date(bDateStr);
                    } else if (columnIndex === 3) { // Số lượng bàn
                        aValue = parseInt(a.cells[3].textContent.trim()) || 0;
                        bValue = parseInt(b.cells[3].textContent.trim()) || 0;
                    }
                } else {
                    // Sắp xếp cho bảng bàn
                    if (columnIndex === 0) { // Số bàn
                        aValue = a.cells[0].textContent.trim();
                        bValue = b.cells[0].textContent.trim();
                    } else if (columnIndex === 1) { // Tên bàn
                        aValue = a.cells[1].textContent.trim();
                        bValue = b.cells[1].textContent.trim();
                    } else if (columnIndex === 2) { // Phòng
                        aValue = a.cells[2].textContent.trim();
                        bValue = b.cells[2].textContent.trim();
                    } else if (columnIndex === 3) { // Sức chứa
                        const aText = a.cells[3].textContent.trim();
                        const bText = b.cells[3].textContent.trim();
                        aValue = parseInt(aText.replace(' người', '')) || 0;
                        bValue = parseInt(bText.replace(' người', '')) || 0;
                    } else if (columnIndex === 4) { // Trạng thái
                        aValue = a.cells[4].textContent.trim();
                        bValue = b.cells[4].textContent.trim();
                    } else if (columnIndex === 5) { // Ngày tạo
                        const aDateStr = a.cells[5].textContent.trim();
                        const bDateStr = b.cells[5].textContent.trim();
                        aValue = aDateStr === 'N/A' ? new Date(0) : new Date(aDateStr);
                        bValue = bDateStr === 'N/A' ? new Date(0) : new Date(bDateStr);
                    }
                }

                // So sánh dựa trên kiểu dữ liệu
                let comparison = 0;
                if (dataType === 'number') {
                    // Xử lý trường hợp NaN
                    if (isNaN(aValue)) aValue = 0;
                    if (isNaN(bValue)) bValue = 0;
                    comparison = aValue - bValue;
                } else if (dataType === 'date') {
                    // Xử lý trường hợp Invalid Date
                    if (isNaN(aValue.getTime())) aValue = new Date(0);
                    if (isNaN(bValue.getTime())) bValue = new Date(0);
                    comparison = aValue - bValue;
                } else {
                    // Xử lý trường hợp null/undefined
                    const aStr = aValue || '';
                    const bStr = bValue || '';
                    comparison = aStr.localeCompare(bStr, 'vi', { numeric: true });
                }

                const result = currentSortDirection === 'asc' ? comparison : -comparison;
                
                // Debug log cho lần đầu
                if (Math.random() < 0.1) { // Chỉ log 10% để không spam
                    console.log('Sort comparison:', aValue, 'vs', bValue, '=', result);
                }
                
                return result;
            } catch (error) {
                console.error('Error sorting:', error);
                return 0;
            }
        });

        // Cập nhật DOM
        console.log('🔄 Updating DOM with sorted rows...');
        
        // Xóa tất cả rows hiện tại
        tbody.innerHTML = '';
        
        // Thêm lại rows đã sắp xếp
        rows.forEach(row => {
            tbody.appendChild(row);
        });
        
        console.log('✅ Sorting completed successfully');
        console.log('Rows after sort:', tbody.querySelectorAll('tr').length);
    }

    function addRoom() {
        document.getElementById('addRoomModal').style.display = 'block';
    }

    function closeAddRoomModal() {
        document.getElementById('addRoomModal').style.display = 'none';
        document.getElementById('addRoomForm').reset();
    }

    function addTable() {
        document.getElementById('addTableModal').style.display = 'block';
    }

    function closeAddTableModal() {
        document.getElementById('addTableModal').style.display = 'none';
        document.getElementById('addTableForm').reset();
    }

    function submitAddRoom() {
        const form = document.getElementById('addRoomForm');
        const formData = new FormData(form);

        const name = formData.get('roomName');
        const description = formData.get('roomDescription');

        if (!name || name.trim() === '') {
            alert('Vui lòng nhập tên phòng');
            document.getElementById('roomName').focus();
            return;
        }

        if (name.trim().length > 100) {
            alert('Tên phòng không được vượt quá 100 ký tự');
            document.getElementById('roomName').focus();
            return;
        }

        form.submit();
    }

    function submitAddTable() {
        const form = document.getElementById('addTableForm');
        const formData = new FormData(form);

        const tableNumber = formData.get('tableNumber');
        const tableName = formData.get('tableName');
        const capacity = formData.get('capacity');

        if (!tableNumber || tableNumber.trim() === '') {
            alert('Vui lòng nhập số bàn');
            document.getElementById('tableNumber').focus();
            return;
        }

        if (!tableName || tableName.trim() === '') {
            alert('Vui lòng nhập tên bàn');
            document.getElementById('tableName').focus();
            return;
        }

        if (!capacity || capacity.trim() === '') {
            alert('Vui lòng nhập sức chứa');
            document.getElementById('capacity').focus();
            return;
        }

        if (tableNumber.trim().length > 50) {
            alert('Số bàn không được vượt quá 50 ký tự');
            document.getElementById('tableNumber').focus();
            return;
        }

        if (tableName.trim().length > 100) {
            alert('Tên bàn không được vượt quá 100 ký tự');
            document.getElementById('tableName').focus();
            return;
        }

        const capacityNum = parseInt(capacity.trim());
        if (isNaN(capacityNum) || capacityNum < 1 || capacityNum > 20) {
            alert('Sức chứa phải từ 1 đến 20 người');
            document.getElementById('capacity').focus();
            return;
        }

        form.submit();
    }

    function editRoom(roomId) {
        // TODO: Implement edit room modal
        alert('Chức năng sửa phòng sẽ được triển khai cho ID: ' + roomId);
    }

    function editTable(tableId) {
        // TODO: Implement edit table modal
        alert('Chức năng sửa bàn sẽ được triển khai cho ID: ' + tableId);
    }
    
    function viewTableDetails(tableId) {
        fetch('roomtable?action=getTableDetails&tableId=' + tableId)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    alert('Lỗi: ' + data.error);
                    return;
                }
                
                let details = `
                    <h3>📋 Chi tiết bàn ${data.tableNumber}</h3>
                    <div style="text-align: left; margin: 20px;">
                        <p><strong>Tên bàn:</strong> ${data.tableName}</p>
                        <p><strong>Sức chứa:</strong> ${data.capacity} người</p>
                        <p><strong>Phòng:</strong> ${data.room ? data.room.name : 'Không có phòng'}</p>
                        <p><strong>Trạng thái:</strong> ${data.status}</p>
                        <p><strong>Trạng thái hoạt động:</strong> ${data.isActive ? 'Hoạt động' : 'Ngừng hoạt động'}</p>
                `;
                
                if (data.activeSession) {
                    details += `
                        <hr>
                        <h4>🔄 Phiên đang hoạt động:</h4>
                        <p><strong>Khách hàng:</strong> ${data.activeSession.customerName || 'Khách vãng lai'}</p>
                        <p><strong>SĐT:</strong> ${data.activeSession.customerPhone || 'Không có'}</p>
                        <p><strong>Thời gian vào:</strong> ${formatDate(data.activeSession.checkInTime)}</p>
                        <p><strong>Tổng tiền:</strong> ${formatNumber(data.activeSession.totalAmount)} VNĐ</p>
                        <p><strong>Trạng thái thanh toán:</strong> ${data.activeSession.paymentStatus}</p>
                    `;
                } else {
                    details += `<p><strong>Trạng thái:</strong> Bàn trống</p>`;
                }
                
                details += `</div>`;
                
                // Create modal
                showModal('Chi tiết bàn', details);
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi lấy thông tin bàn');
            });
    }
    
    function viewTableHistory(tableId) {
        fetch('roomtable?action=getTableHistory&tableId=' + tableId)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    alert('Lỗi: ' + data.error);
                    return;
                }
                
                let history = `
                    <h3>📋 Lịch sử giao dịch bàn</h3>
                    <div style="max-height: 400px; overflow-y: auto;">
                `;
                
                if (data.sessions && data.sessions.length > 0) {
                    history += `
                        <table class="table" style="margin-top: 20px;">
                            <thead>
                                <tr>
                                    <th>Khách hàng</th>
                                    <th>SĐT</th>
                                    <th>Vào</th>
                                    <th>Ra</th>
                                    <th>Trạng thái</th>
                                    <th>Tổng tiền</th>
                                    <th>Thanh toán</th>
                                </tr>
                            </thead>
                            <tbody>
                    `;
                    
                    data.sessions.forEach(session => {
                        history += `
                            <tr>
                                <td>${session.customerName || 'Khách vãng lai'}</td>
                                <td>${session.customerPhone || '-'}</td>
                                <td>${formatDate(session.checkInTime)}</td>
                                <td>${session.checkOutTime ? formatDate(session.checkOutTime) : 'Chưa ra'}</td>
                                <td><span class="status ${session.status.toLowerCase()}">${session.status}</span></td>
                                <td>${formatNumber(session.totalAmount)} VNĐ</td>
                                <td><span class="payment-status ${session.paymentStatus.toLowerCase()}">${session.paymentStatus}</span></td>
                            </tr>
                        `;
                    });
                    
                    history += `</tbody></table>`;
                } else {
                    history += `<p style="text-align: center; margin: 40px; color: #666;">Chưa có lịch sử giao dịch nào</p>`;
                }
                
                history += `</div>`;
                
                // Create modal
                showModal('Lịch sử giao dịch', history);
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi lấy lịch sử bàn');
            });
    }
    
    function showModal(title, content) {
        // Remove existing modal if any
        const existingModal = document.getElementById('dynamicModal');
        if (existingModal) {
            existingModal.remove();
        }
        
        // Create modal
        const modal = document.createElement('div');
        modal.id = 'dynamicModal';
        modal.className = 'modal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 800px;">
                <div class="modal-header">
                    <h2>${title}</h2>
                    <span class="close" onclick="closeDynamicModal()">&times;</span>
                </div>
                <div class="modal-body">
                    ${content}
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" onclick="closeDynamicModal()">
                        ✅ Đóng
                    </button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
    }
    
    function closeDynamicModal() {
        const modal = document.getElementById('dynamicModal');
        if (modal) {
            modal.remove();
        }
    }

    function deleteRoom(roomId) {
        if (confirm('Bạn có chắc muốn xóa phòng này? Tất cả bàn trong phòng cũng sẽ bị xóa.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'roomtable';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'deleteRoom';
            
            const roomIdInput = document.createElement('input');
            roomIdInput.type = 'hidden';
            roomIdInput.name = 'roomId';
            roomIdInput.value = roomId;
            
            form.appendChild(actionInput);
            form.appendChild(roomIdInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

    function deleteTable(tableId) {
        if (confirm('Bạn có chắc muốn xóa bàn này?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'roomtable';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'deleteTable';
            
            const tableIdInput = document.createElement('input');
            tableIdInput.type = 'hidden';
            tableIdInput.name = 'tableId';
            tableIdInput.value = tableId;
            
            form.appendChild(actionInput);
            form.appendChild(tableIdInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

    function changeTableStatus(tableId, currentStatus) {
        const newStatus = prompt('Nhập trạng thái mới (Available/Occupied/Reserved):', currentStatus);
        if (newStatus && newStatus !== currentStatus) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'roomtable';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'updateTableStatus';
            
            const tableIdInput = document.createElement('input');
            tableIdInput.type = 'hidden';
            tableIdInput.name = 'tableId';
            tableIdInput.value = tableId;
            
            const statusInput = document.createElement('input');
            statusInput.type = 'hidden';
            statusInput.name = 'status';
            statusInput.value = newStatus;
            
            form.appendChild(actionInput);
            form.appendChild(tableIdInput);
            form.appendChild(statusInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

    // Auto search when typing
    document.getElementById('searchInput').addEventListener('input', searchItems);

    // Debug function to check table data
    function debugTables() {
        console.log('=== DEBUG TABLES ===');
        
        // Check rooms table
        const roomContainer = document.querySelector('.room-table-container');
        if (roomContainer) {
            const roomTable = roomContainer.querySelector('.table');
            const roomRows = roomTable ? roomTable.querySelectorAll('tbody tr') : [];
            console.log('Rooms table found:', roomTable !== null);
            console.log('Rooms rows count:', roomRows.length);
            
            // Debug headers
            const headers = roomTable ? roomTable.querySelectorAll('th') : [];
            console.log('Rooms headers count:', headers.length);
            headers.forEach((header, index) => {
                console.log(`  Header ${index}:`, header.textContent.trim(), 'sortable:', header.classList.contains('sortable'));
            });
            
            // Debug first row
            if (roomRows.length > 0) {
                const firstRow = roomRows[0];
                console.log('First room row cells:', firstRow.cells.length);
                for (let i = 0; i < firstRow.cells.length; i++) {
                    console.log(`  Cell ${i}:`, firstRow.cells[i].textContent.trim());
                }
            }
        } else {
            console.log('Rooms container not found');
        }
        
        // Check tables table
        const tableContainers = document.querySelectorAll('.room-table-container');
        if (tableContainers.length > 1) {
            const tableTable = tableContainers[1].querySelector('.table');
            const tableRows = tableTable ? tableTable.querySelectorAll('tbody tr') : [];
            console.log('Tables table found:', tableTable !== null);
            console.log('Tables rows count:', tableRows.length);
            
            // Debug headers
            const headers = tableTable ? tableTable.querySelectorAll('th') : [];
            console.log('Tables headers count:', headers.length);
            headers.forEach((header, index) => {
                console.log(`  Header ${index}:`, header.textContent.trim(), 'sortable:', header.classList.contains('sortable'));
            });
            
            // Debug first row
            if (tableRows.length > 0) {
                const firstRow = tableRows[0];
                console.log('First table row cells:', firstRow.cells.length);
                for (let i = 0; i < firstRow.cells.length; i++) {
                    console.log(`  Cell ${i}:`, firstRow.cells[i].textContent.trim());
                }
            }
        } else {
            console.log('Tables container not found');
        }
    }

    // Run debug when page loads
    window.addEventListener('load', function() {
        setTimeout(debugTables, 1000); // Wait 1 second for data to load
    });
    
    // Global test function
    window.testSort = function() {
        console.log('🧪 Testing sort function...');
        testSorting();
    };

    // Test function for sorting
    function testSorting() {
        console.log('🧪 Testing sorting...');
        console.log('Available containers:', document.querySelectorAll('.room-table-container').length);
        
        // Test bảng phòng
        const roomTable = document.querySelector('.room-table-container .table');
        if (roomTable) {
            const roomRows = roomTable.querySelectorAll('tbody tr');
            console.log('Room table found with', roomRows.length, 'rows');
            
            // Test sort tên phòng
            console.log('Testing room name sort...');
            sortTable(0, 'string', 'rooms');
        }
        
        // Test bảng bàn
        const tableContainers = document.querySelectorAll('.room-table-container');
        if (tableContainers.length > 1) {
            const tableTable = tableContainers[1].querySelector('.table');
            if (tableTable) {
                const tableRows = tableTable.querySelectorAll('tbody tr');
                console.log('Table table found with', tableRows.length, 'rows');
                
                // Test sort số bàn
                console.log('Testing table number sort...');
                sortTable(0, 'string', 'tables');
            }
        }
    }

    // Helper functions for safe formatting
    function formatDate(dateString) {
        if (!dateString) return 'N/A';
        try {
            const date = new Date(dateString);
            if (isNaN(date.getTime())) return 'N/A';
            return date.toLocaleString('vi-VN');
        } catch (error) {
            console.warn('Error formatting date:', error);
            return 'N/A';
        }
    }
    
    function formatNumber(number) {
        if (!number || isNaN(number)) return '0';
        return Number(number).toLocaleString('vi-VN');
    }

    // Close modal when clicking outside
    window.onclick = function (event) {
        const roomModal = document.getElementById('addRoomModal');
        const tableModal = document.getElementById('addTableModal');
        if (event.target === roomModal) {
            closeAddRoomModal();
        }
        if (event.target === tableModal) {
            closeAddTableModal();
        }
    }
</script>

<!-- Add Room Modal -->
<div id="addRoomModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>🏢 Thêm phòng mới</h2>
            <span class="close" onclick="closeAddRoomModal()">&times;</span>
        </div>
        <form id="addRoomForm" action="roomtable" method="post">
            <input type="hidden" name="action" value="addRoom">
            <div class="modal-body">
                <div class="form-group">
                    <label for="roomName">Tên phòng *</label>
                    <input type="text" id="roomName" name="roomName" required 
                           placeholder="Nhập tên phòng">
                </div>
                <div class="form-group">
                    <label for="roomDescription">Mô tả phòng</label>
                    <textarea id="roomDescription" name="roomDescription" 
                              placeholder="Nhập mô tả phòng (tùy chọn)" rows="4"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-warning" onclick="closeAddRoomModal()">
                    ❌ Hủy
                </button>
                <button type="button" class="btn btn-success" onclick="submitAddRoom()">
                    ✅ Thêm phòng
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Add Table Modal -->
<div id="addTableModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>🪑 Thêm bàn mới</h2>
            <span class="close" onclick="closeAddTableModal()">&times;</span>
        </div>
        <form id="addTableForm" action="roomtable" method="post">
            <input type="hidden" name="action" value="addTable">
            <div class="modal-body">
                <div class="form-group">
                    <label for="tableNumber">Số bàn *</label>
                    <input type="text" id="tableNumber" name="tableNumber" required 
                           placeholder="Nhập số bàn">
                </div>
                <div class="form-group">
                    <label for="tableName">Tên bàn *</label>
                    <input type="text" id="tableName" name="tableName" required 
                           placeholder="Nhập tên bàn">
                </div>
                <div class="form-group">
                    <label for="capacity">Sức chứa *</label>
                    <input type="number" id="capacity" name="capacity" required 
                           min="1" max="20" value="4" placeholder="Nhập sức chứa">
                </div>
                <div class="form-group">
                    <label for="roomId">Phòng</label>
                    <select id="roomId" name="roomId">
                        <option value="">Chọn phòng (tùy chọn)</option>
                        <c:forEach var="room" items="${rooms}">
                            <option value="${room.roomId}">${room.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label for="status">Trạng thái</label>
                    <select id="status" name="status">
                        <option value="Available">Trống</option>
                        <option value="Occupied">Đang sử dụng</option>
                        <option value="Reserved">Đã đặt</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-warning" onclick="closeAddTableModal()">
                    ❌ Hủy
                </button>
                <button type="button" class="btn btn-success" onclick="submitAddTable()">
                    ✅ Thêm bàn
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../includes/footer.jsp" />
