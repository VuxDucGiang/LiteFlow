<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.liteflow.model.inventory.ProductDisplayDTO" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="../includes/header.jsp">
  <jsp:param name="page" value="products" />
</jsp:include>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/productlist.css">

<div class="content">
    <!-- Statistics -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-number">${products.size()}</div>
            <div class="stat-label">Tổng sản phẩm</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <c:set var="totalStock" value="0" />
                <c:forEach var="p" items="${products}">
                    <c:set var="totalStock" value="${totalStock + p.stockAmount}" />
                </c:forEach>
                <fmt:formatNumber value="${totalStock}" pattern="#,###" />
            </div>
            <div class="stat-label">Tổng tồn kho</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <c:set var="activeProducts" value="0" />
                <c:forEach var="p" items="${products}">
                    <c:if test="${!p.isDeleted}">
                        <c:set var="activeProducts" value="${activeProducts + 1}" />
                    </c:if>
                </c:forEach>
                ${activeProducts}
            </div>
            <div class="stat-label">Đang bán</div>
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
        <!-- Left Sidebar - Product Filters -->
        <div class="sidebar">
            <div class="filter-section">
                <h3 class="filter-title">Tìm kiếm</h3>
                <div class="search-box">
                    <input type="text" class="search-input" placeholder="Theo mã, tên hàng" id="searchInput" onkeyup="searchProducts()">
                </div>
            </div>

            <div class="filter-section">
                <h3 class="filter-title">Danh Mục</h3>
                <div class="filter-options">
                    <c:choose>
                        <c:when test="${not empty categories}">
                            <c:forEach var="category" items="${categories}">
                                <label class="filter-option">
                                    <input type="checkbox" name="categoryFilter" value="${category}" onchange="filterProducts()">
                                    <span class="checkmark"></span>
                                    ${category}
                                </label>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p style="color: #666; font-style: italic;">Chưa có danh mục nào từ sản phẩm</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="filter-section">
                <h3 class="filter-title">Loại hàng</h3>
                <div class="filter-options">
                    <label class="filter-option">
                        <input type="checkbox" name="productType" value="regular" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Hàng hóa thường
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productType" value="processed" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Chế biến
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productType" value="service" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Dịch vụ
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productType" value="combo" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Combo - Đóng gói
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productType" value="custom-combo" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Combo tùy chọn
                    </label>
                </div>
            </div>

            <div class="filter-section">
                <h3 class="filter-title collapsible" onclick="toggleFilterSection(this)">
                    Nhóm hàng
                    <span class="collapse-icon">▼</span>
                </h3>
                <div class="filter-options collapsed">
                    <label class="filter-option">
                        <input type="checkbox" name="productGroup" value="beverages" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Đồ uống
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productGroup" value="food" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Thức ăn
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productGroup" value="tobacco" onchange="filterProducts()">
                        <span class="checkmark"></span>
                        Thuốc lá
                    </label>
                </div>
            </div>
        </div>

        <!-- Right Content - Product List -->
        <div class="main-content">
            <!-- Toolbar -->
            <div class="toolbar">
                <div>
                    <a href="#" class="btn btn-success" onclick="addProduct()">➕ Thêm mới</a>
                    <button class="btn btn-primary" onclick="exportProducts()">📊 Xuất file</button>
                    <button class="btn btn-primary" onclick="importProducts()">📥 Import</button>
                </div>
            </div>

            <!-- Product Table -->
            <div class="product-table">
                <c:choose>
                    <c:when test="${empty products}">
                        <div class="empty-state">
                            <h3>📦 Chưa có sản phẩm nào</h3>
                            <p>Hãy thêm sản phẩm đầu tiên để bắt đầu quản lý kho hàng</p>
                            <a href="#" class="btn btn-success" onclick="addProduct()" style="margin-top: 1rem;">➕ Thêm sản phẩm</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th class="sortable" onclick="sortTable(0, 'string')">
                                        Mã hàng
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(1, 'string')">
                                        Tên hàng
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(2, 'string')">
                                        Kích thước
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(3, 'string')">
                                        Danh mục
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(4, 'number')">
                                        Giá bán
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(5, 'number')">
                                        Tồn kho
                                        <span class="sort-icon"></span>
                                    </th>
                                    <th class="sortable" onclick="sortTable(6, 'string')">
                                        Trạng thái
                                        <span class="sort-icon"></span>
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${products}">
                                    <tr>
                                        <td>
                                            <span class="product-code">${p.productCode}</span>
                                        </td>
                                        <td>
                                            <div class="product-name">${p.productName}</div>
                                            <c:if test="${not empty p.imageUrl}">
                                                <img src="${pageContext.request.contextPath}/${p.imageUrl}" 
                                                     alt="${p.productName}" class="product-image" 
                                                     onerror="this.style.display='none'">
                                            </c:if>
                                        </td>
                                        <td>${p.size}</td>
                                        <td>
                                            <span class="category">
                                                ${p.categoryName != null ? p.categoryName : 'Chưa phân loại'}
                                            </span>
                                        </td>
                                        <td>
                                            <span class="price">
                                                <fmt:formatNumber value="${p.price}" pattern="#,###" /> ₫
                                            </span>
                                        </td>
                                        <td>
                                            <span class="stock 
                                                  <c:choose>
                                                      <c:when test="${p.stockAmount <= 10}">low</c:when>
                                                      <c:when test="${p.stockAmount <= 50}">medium</c:when>
                                                      <c:otherwise>high</c:otherwise>
                                                  </c:choose>">
                                                <fmt:formatNumber value="${p.stockAmount}" pattern="#,###" />
                                            </span>
                                        </td>
                                        <td>
                                            <span class="status ${p.isDeleted ? 'inactive' : 'active'}">
                                                ${p.isDeleted ? 'Đã ẩn' : 'Đang bán'}
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

        <script>
            // Biến để theo dõi trạng thái sắp xếp
            let currentSortColumn = -1;
            let currentSortDirection = 'asc';

            function searchProducts() {
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
                    const productCode = row.querySelector('.product-code').textContent.toLowerCase();
                    const productName = row.querySelector('.product-name').textContent.toLowerCase();
                    const productSize = row.cells[2].textContent.toLowerCase();
                    const category = row.cells[3].querySelector('.category').textContent.toLowerCase();

                    // Tìm kiếm trong mã sản phẩm, tên sản phẩm, kích thước và danh mục
                    if (productCode.includes(searchTerm) || 
                        productName.includes(searchTerm) || 
                        productSize.includes(searchTerm) ||
                        category.includes(searchTerm)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }

            function filterProducts() {
                // Áp dụng tất cả bộ lọc
                applyAllFilters();
            }

            function applyAllFilters() {
                const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
                const categoryFilters = Array.from(document.querySelectorAll('input[name="categoryFilter"]:checked')).map(cb => cb.value);
                const productTypeFilters = Array.from(document.querySelectorAll('input[name="productType"]:checked')).map(cb => cb.value);
                const productGroupFilters = Array.from(document.querySelectorAll('input[name="productGroup"]:checked')).map(cb => cb.value);
                const rows = document.querySelectorAll('.table tbody tr');

                // Debug logging
                console.log('🔍 Filtering products...');
                console.log('Search term:', searchTerm);
                console.log('Category filters:', categoryFilters);
                console.log('Total rows:', rows.length);

                rows.forEach((row, index) => {
                    let showRow = true;
                    
                    // Áp dụng tìm kiếm
                    if (searchTerm !== '') {
                        const productCode = row.querySelector('.product-code').textContent.toLowerCase();
                        const productName = row.querySelector('.product-name').textContent.toLowerCase();
                        const productSize = row.cells[2].textContent.toLowerCase();
                        const category = row.cells[3].querySelector('.category').textContent.toLowerCase();
                        
                        if (!productCode.includes(searchTerm) && 
                            !productName.includes(searchTerm) && 
                            !productSize.includes(searchTerm) &&
                            !category.includes(searchTerm)) {
                            showRow = false;
                        }
                    }
                    
                    // Áp dụng lọc theo danh mục từ sản phẩm
                    if (showRow && categoryFilters.length > 0) {
                        const category = row.cells[3].querySelector('.category').textContent.trim();
                        console.log(`Row ${index}: category="${category}", filters=[${categoryFilters.join(', ')}]`);
                        
                        if (!categoryFilters.includes(category)) {
                            showRow = false;
                            console.log(`Row ${index}: HIDDEN - category "${category}" not in filters`);
                        } else {
                            console.log(`Row ${index}: SHOWN - category "${category}" matches filter`);
                        }
                    }
                    
                    if (showRow && productTypeFilters.length > 0) {
                        // Logic lọc theo loại hàng
                    }
                    
                    if (showRow && productGroupFilters.length > 0) {
                        // Logic lọc theo nhóm hàng
                    }

                    row.style.display = showRow ? '' : 'none';
                });
                
                console.log('✅ Filtering completed');
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

            function toggleSelectAll() {
                const selectAll = document.getElementById('selectAll');
                const checkboxes = document.querySelectorAll('.product-checkbox');
                
                checkboxes.forEach(checkbox => {
                    checkbox.checked = selectAll.checked;
                });
            }

            function toggleGridView() {
                // Toggle between table and grid view
                const productTable = document.querySelector('.product-table');
                const isGridView = productTable.classList.contains('grid-view');
                
                if (isGridView) {
                    productTable.classList.remove('grid-view');
                } else {
                    productTable.classList.add('grid-view');
                }
            }

            function orderProduct(productId) {
                alert('Chức năng đặt hàng sẽ được triển khai cho ID: ' + productId);
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
                    
                    if (columnIndex === 0) { // Mã hàng
                        aValue = a.cells[0].querySelector('.product-code').textContent.trim();
                        bValue = b.cells[0].querySelector('.product-code').textContent.trim();
                    } else if (columnIndex === 1) { // Tên hàng
                        aValue = a.cells[1].querySelector('.product-name').textContent.trim();
                        bValue = b.cells[1].querySelector('.product-name').textContent.trim();
                    } else if (columnIndex === 2) { // Kích thước
                        aValue = a.cells[2].textContent.trim();
                        bValue = b.cells[2].textContent.trim();
                    } else if (columnIndex === 3) { // Danh mục
                        aValue = a.cells[3].querySelector('.category').textContent.trim();
                        bValue = b.cells[3].querySelector('.category').textContent.trim();
                    } else if (columnIndex === 4) { // Giá bán
                        aValue = parseFloat(a.cells[4].querySelector('.price').textContent.replace(/[^\d]/g, ''));
                        bValue = parseFloat(b.cells[4].querySelector('.price').textContent.replace(/[^\d]/g, ''));
                    } else if (columnIndex === 5) { // Tồn kho
                        aValue = parseFloat(a.cells[5].querySelector('.stock').textContent.replace(/[^\d]/g, ''));
                        bValue = parseFloat(b.cells[5].querySelector('.stock').textContent.replace(/[^\d]/g, ''));
                    } else if (columnIndex === 6) { // Trạng thái
                        aValue = a.cells[6].querySelector('.status').textContent.trim();
                        bValue = b.cells[6].querySelector('.status').textContent.trim();
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

            function addProduct() {
                document.getElementById('addProductModal').style.display = 'block';
            }

            function closeAddProductModal() {
                document.getElementById('addProductModal').style.display = 'none';
                document.getElementById('addProductForm').reset();
            }

            function toggleCustomSize() {
                const customSizeCheck = document.getElementById('customSizeCheck');
                const customSizeInput = document.getElementById('customSizeInput');
                const sizeCheckboxes = document.querySelectorAll('input[name="size"]');

                if (customSizeCheck.checked) {
                    // Nếu chọn tùy chọn nhập chữ, bỏ chọn tất cả S,M,L
                    sizeCheckboxes.forEach(checkbox => {
                        checkbox.checked = false;
                    });
                    customSizeInput.disabled = false;
                    customSizeInput.focus();
                } else {
                    // Nếu bỏ chọn tùy chọn nhập chữ, disable input
                    customSizeInput.disabled = true;
                    customSizeInput.value = '';
                }
            }

            function submitAddProduct() {
                const form = document.getElementById('addProductForm');
                const formData = new FormData(form);

                // Validate required fields
                const name = formData.get('name');
                const description = formData.get('description');
                const price = formData.get('price');
                const stock = formData.get('stock');

                if (!name || name.trim() === '') {
                    alert('Vui lòng nhập tên sản phẩm');
                    document.getElementById('name').focus();
                    return;
                }

                if (!price || parseFloat(price) <= 0) {
                    alert('Vui lòng nhập giá bán hợp lệ');
                    document.getElementById('price').focus();
                    return;
                }

                if (!stock || parseInt(stock) < 0) {
                    alert('Vui lòng nhập số lượng tồn kho hợp lệ');
                    document.getElementById('stock').focus();
                    return;
                }

                if (!description || description.trim() === '') {
                    alert('Vui lòng nhập mô tả sản phẩm');
                    document.getElementById('description').focus();
                    return;
                }

                // Validate name length
                if (name.trim().length > 100) {
                    alert('Tên sản phẩm không được vượt quá 100 ký tự');
                    document.getElementById('name').focus();
                    return;
                }

                // Validate size selection
                const sizeCheckboxes = document.querySelectorAll('input[name="size"]:checked');
                const customSizeCheck = document.getElementById('customSizeCheck');
                const customSizeInput = document.getElementById('customSizeInput');

                if (customSizeCheck.checked) {
                    if (!customSizeInput.value || customSizeInput.value.trim() === '') {
                        alert('Vui lòng nhập size tùy chỉnh');
                        customSizeInput.focus();
                        return;
                    }
                } else if (sizeCheckboxes.length === 0) {
                    alert('Vui lòng chọn ít nhất một size (S, M, L) hoặc nhập size tùy chỉnh');
                    return;
                }

                // Validate URL format if provided
                const imageUrl = formData.get('imageUrl');
                if (imageUrl && imageUrl.trim() !== '') {
                    try {
                        new URL(imageUrl.trim());
                    } catch (e) {
                        alert('URL hình ảnh không hợp lệ');
                        document.getElementById('imageUrl').focus();
                        return;
                    }
                }

                // Show loading state
                const submitBtn = document.querySelector('#addProductForm button[type="button"]');
                const originalText = submitBtn.textContent;
                submitBtn.textContent = '⏳ Đang thêm...';
                submitBtn.disabled = true;

                // Submit form
                form.submit();
            }

            function editProduct(productId) {
                alert('Chức năng sửa sản phẩm sẽ được triển khai cho ID: ' + productId);
            }

            function hideProduct(productId) {
                if (confirm('Bạn có chắc muốn ẩn sản phẩm này?')) {
                    alert('Chức năng ẩn sản phẩm sẽ được triển khai cho ID: ' + productId);
                }
            }

            function showProduct(productId) {
                if (confirm('Bạn có chắc muốn hiện sản phẩm này?')) {
                    alert('Chức năng hiện sản phẩm sẽ được triển khai cho ID: ' + productId);
                }
            }

            function exportProducts() {
                alert('Chức năng xuất file sẽ được triển khai');
            }

            function importProducts() {
                alert('Chức năng import sẽ được triển khai');
            }

            // Auto search khi gõ
            document.getElementById('searchInput').addEventListener('input', searchProducts);
            
            // Thêm event listener cho các checkbox filter
            document.querySelectorAll('input[name="menuType"], input[name="productType"], input[name="productGroup"]').forEach(checkbox => {
                checkbox.addEventListener('change', applyAllFilters);
            });

            // Close modal when clicking outside
            window.onclick = function (event) {
                const modal = document.getElementById('addProductModal');
                if (event.target === modal) {
                    closeAddProductModal();
                }
            }
        </script>

        <!-- Add Product Modal -->
        <div id="addProductModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>➕ Thêm sản phẩm mới</h2>
                    <span class="close" onclick="closeAddProductModal()">&times;</span>
                </div>
                <form id="addProductForm" action="products" method="post">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-body">
                        <!-- Row 1: Tên sản phẩm và Giá bán -->
                        <div class="form-row">
                            <div class="form-group">
                                <label for="name">Tên sản phẩm *</label>
                                <input type="text" id="name" name="name" required 
                                       placeholder="Nhập tên sản phẩm">
                            </div>
                            <div class="form-group">
                                <label for="price">Giá bán *</label>
                                <input type="number" id="price" name="price" required 
                                       min="0" step="1000" placeholder="Nhập giá bán (VND)">
                            </div>
                        </div>

                        <!-- Row 2: Size (full width) -->
                        <div class="form-row size-section">
                            <div class="form-group">
                                <label>Size *</label>
                                <div class="size-options">
                                    <div class="size-checkboxes">
                                        <label class="size-checkbox">
                                            <input type="checkbox" name="size" value="S" onchange="toggleCustomSize()">
                                            <span>S</span>
                                        </label>
                                        <label class="size-checkbox">
                                            <input type="checkbox" name="size" value="M" onchange="toggleCustomSize()">
                                            <span>M</span>
                                        </label>
                                        <label class="size-checkbox">
                                            <input type="checkbox" name="size" value="L" onchange="toggleCustomSize()">
                                            <span>L</span>
                                        </label>
                                    </div>
                                    <div class="custom-size">
                                        <label class="size-checkbox">
                                            <input type="checkbox" id="customSizeCheck" onchange="toggleCustomSize()">
                                            <span>Tùy chọn nhập chữ</span>
                                        </label>
                                        <input type="text" id="customSizeInput" name="customSize" 
                                               placeholder="Nhập size tùy chỉnh" disabled>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="form-group">
                                    <label for="description">Mô tả sản phẩm *</label>
                                    <textarea id="description" name="description" required 
                                              placeholder="Nhập mô tả chi tiết về sản phẩm" rows="8"></textarea>
                                </div>
                            </div>
                        </div>


                        <!-- Row 4: Stock và Image URL -->
                        <div class="form-row">
                            <div class="form-group">
                                <label for="stock">Số lượng tồn kho *</label>
                                <input type="number" id="stock" name="stock" required 
                                       min="0" placeholder="Nhập số lượng tồn kho">
                            </div>
                            <div class="form-group">
                                <label for="imageUrl">URL hình ảnh</label>
                                <input type="url" id="imageUrl" name="imageUrl" 
                                       placeholder="https://example.com/image.jpg">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-warning" onclick="closeAddProductModal()">
                            ❌ Hủy
                        </button>
                        <button type="button" class="btn btn-success" onclick="submitAddProduct()">
                            ✅ Thêm sản phẩm
                        </button>
                    </div>
                </form>
            </div>
        </div>

<jsp:include page="../includes/footer.jsp" />
