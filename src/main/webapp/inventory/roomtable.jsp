<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="../includes/header.jsp">
  <jsp:param name="page" value="rooms" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/roomtable.css">

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
                            <th class="sortable" onclick="sortTable(1, 'string', 'rooms')">
                                Mô tả
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(2, 'date', 'rooms')">
                                Ngày tạo
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(3, 'number', 'rooms')">
                                Số bàn
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
                                    <fmt:formatDate value="${room.createdAt}" pattern="dd/MM/yyyy HH:mm" />
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
                                Phòng
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(2, 'string', 'tables')">
                                Trạng thái
                                <span class="sort-icon"></span>
                            </th>
                            <th class="sortable" onclick="sortTable(3, 'date', 'tables')">
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
                                <td>${table.room != null ? table.room.name : 'Không có phòng'}</td>
                                <td>
                                    <span class="status ${table.status.toLowerCase()}">
                                        <c:choose>
                                            <c:when test="${table.status == 'Available'}">Trống</c:when>
                                            <c:when test="${table.status == 'Occupied'}">Đang sử dụng</c:when>
                                            <c:when test="${table.status == 'Reserved'}">Đã đặt</c:when>
                                            <c:otherwise>${table.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td>
                                    <fmt:formatDate value="${table.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </td>
                                <td>
                                    <div class="actions">
                                        <button class="btn btn-warning btn-sm" onclick="editTable('${table.tableId}')">
                                            ✏️ Sửa
                                        </button>
                                        <button class="btn btn-primary btn-sm" onclick="changeTableStatus('${table.tableId}', '${table.status}')">
                                            🔄 Đổi trạng thái
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
        console.log('Sorting table:', tableType, 'column:', columnIndex, 'type:', dataType);
        
        // Xác định bảng cần sắp xếp - sử dụng selector chính xác hơn
        let table;
        if (tableType === 'rooms') {
            // Tìm bảng phòng (bảng đầu tiên)
            const roomContainer = document.querySelector('.room-table-container');
            table = roomContainer ? roomContainer.querySelector('.table') : null;
        } else {
            // Tìm bảng bàn (bảng thứ hai)
            const tableContainers = document.querySelectorAll('.room-table-container');
            table = tableContainers.length > 1 ? tableContainers[1].querySelector('.table') : null;
        }
        
        if (!table) {
            console.log('Table not found for type:', tableType);
            return;
        }
        
        const tbody = table.querySelector('tbody');
        if (!tbody) {
            console.log('Tbody not found');
            return;
        }
        
        const rows = Array.from(tbody.querySelectorAll('tr'));
        console.log('Found rows:', rows.length);
        
        // Xóa class sort cũ cho bảng hiện tại
        const currentTableHeaders = table.querySelectorAll('th');
        currentTableHeaders.forEach(th => {
            th.classList.remove('sort-asc', 'sort-desc');
        });

        // Xác định hướng sắp xếp
        if (currentSortColumn === columnIndex && currentSortTable === tableType) {
            currentSortDirection = currentSortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            currentSortDirection = 'asc';
        }
        currentSortColumn = columnIndex;
        currentSortTable = tableType;

        // Thêm class sort cho header hiện tại
        const currentHeader = currentTableHeaders[columnIndex];
        if (currentHeader) {
            currentHeader.classList.add(currentSortDirection === 'asc' ? 'sort-asc' : 'sort-desc');
        }

        // Sắp xếp các hàng
        rows.sort((a, b) => {
            let aValue, bValue;
            
            try {
                if (tableType === 'rooms') {
                    // Sắp xếp cho bảng phòng
                    if (columnIndex === 0) { // Tên phòng
                        const aElement = a.cells[0].querySelector('.room-name');
                        const bElement = b.cells[0].querySelector('.room-name');
                        aValue = aElement ? aElement.textContent.trim() : '';
                        bValue = bElement ? bElement.textContent.trim() : '';
                    } else if (columnIndex === 1) { // Mô tả
                        aValue = a.cells[1].textContent.trim();
                        bValue = b.cells[1].textContent.trim();
                    } else if (columnIndex === 2) { // Ngày tạo
                        aValue = new Date(a.cells[2].textContent.trim());
                        bValue = new Date(b.cells[2].textContent.trim());
                    } else if (columnIndex === 3) { // Số bàn
                        aValue = parseInt(a.cells[3].textContent.trim()) || 0;
                        bValue = parseInt(b.cells[3].textContent.trim()) || 0;
                    }
                } else {
                    // Sắp xếp cho bảng bàn
                    if (columnIndex === 0) { // Số bàn
                        const aElement = a.cells[0].querySelector('.table-number');
                        const bElement = b.cells[0].querySelector('.table-number');
                        aValue = aElement ? aElement.textContent.trim() : '';
                        bValue = bElement ? bElement.textContent.trim() : '';
                    } else if (columnIndex === 1) { // Phòng
                        aValue = a.cells[1].textContent.trim();
                        bValue = b.cells[1].textContent.trim();
                    } else if (columnIndex === 2) { // Trạng thái
                        const aElement = a.cells[2].querySelector('.status');
                        const bElement = b.cells[2].querySelector('.status');
                        aValue = aElement ? aElement.textContent.trim() : '';
                        bValue = bElement ? bElement.textContent.trim() : '';
                    } else if (columnIndex === 3) { // Ngày tạo
                        aValue = new Date(a.cells[3].textContent.trim());
                        bValue = new Date(b.cells[3].textContent.trim());
                    }
                }

                // So sánh dựa trên kiểu dữ liệu
                let comparison = 0;
                if (dataType === 'number') {
                    comparison = aValue - bValue;
                } else if (dataType === 'date') {
                    comparison = aValue - bValue;
                } else {
                    comparison = aValue.localeCompare(bValue, 'vi', { numeric: true });
                }

                return currentSortDirection === 'asc' ? comparison : -comparison;
            } catch (error) {
                console.error('Error sorting:', error);
                return 0;
            }
        });

        // Cập nhật DOM
        rows.forEach(row => tbody.appendChild(row));
        console.log('Sorting completed');
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

        if (!tableNumber || tableNumber.trim() === '') {
            alert('Vui lòng nhập số bàn');
            document.getElementById('tableNumber').focus();
            return;
        }

        if (tableNumber.trim().length > 50) {
            alert('Số bàn không được vượt quá 50 ký tự');
            document.getElementById('tableNumber').focus();
            return;
        }

        form.submit();
    }

    function editRoom(roomId) {
        alert('Chức năng sửa phòng sẽ được triển khai cho ID: ' + roomId);
    }

    function editTable(tableId) {
        alert('Chức năng sửa bàn sẽ được triển khai cho ID: ' + tableId);
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
        } else {
            console.log('Tables container not found');
        }
    }

    // Run debug when page loads
    window.addEventListener('load', function() {
        setTimeout(debugTables, 1000); // Wait 1 second for data to load
    });

    // Test function for sorting
    function testSorting() {
        console.log('Testing sorting...');
        sortTable(0, 'string', 'rooms');
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
