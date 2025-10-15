<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="../includes/header.jsp">
  <jsp:param name="page" value="setprice" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/productlist.css">

<div class="content">
    <div class="page-header">
        <h1>💰 Thiết lập giá</h1>
        <p>Quản lý và cập nhật giá sản phẩm</p>
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

    <!-- Statistics -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-number">${productPrices.size()}</div>
            <div class="stat-label">Tổng sản phẩm</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <c:set var="avgPrice" value="0" />
                <c:if test="${not empty productPrices}">
                    <c:set var="totalPrice" value="0" />
                    <c:forEach var="p" items="${productPrices}">
                        <c:set var="totalPrice" value="${totalPrice + p.sellingPrice}" />
                    </c:forEach>
                    <c:set var="avgPrice" value="${totalPrice / productPrices.size()}" />
                    <fmt:formatNumber value="${avgPrice}" pattern="#,###" /> ₫
                </c:if>
            </div>
            <div class="stat-label">Giá bán trung bình</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <c:set var="totalValue" value="0" />
                <c:forEach var="p" items="${productPrices}">
                    <c:set var="totalValue" value="${totalValue + p.originalPrice}" />
                </c:forEach>
                <fmt:formatNumber value="${totalValue}" pattern="#,###" /> ₫
            </div>
            <div class="stat-label">Tổng giá trị vốn</div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-layout">
        <!-- Left Sidebar - Filters -->
        <div class="sidebar">
            <div class="filter-section">
                <h3 class="filter-title">Tìm kiếm</h3>
                <div class="search-box">
                    <input type="text" class="search-input" placeholder="Theo mã, tên hàng">
                </div>
            </div>

            <div class="filter-section">
                <h3 class="filter-title">Danh mục</h3>
                <div class="filter-options">
                    <c:choose>
                        <c:when test="${not empty categories}">
                            <c:forEach var="category" items="${categories}">
                                <label class="filter-option">
                                    <input type="checkbox" name="categoryFilter" value="${category}">
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
                        <input type="checkbox" name="productType" value="regular">
                        <span class="checkmark"></span>
                        Hàng hóa thường
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productType" value="processed">
                        <span class="checkmark"></span>
                        Chế biến
                    </label>
                    <label class="filter-option">
                        <input type="checkbox" name="productType" value="service">
                        <span class="checkmark"></span>
                        Dịch vụ
                    </label>
                </div>
            </div>
        </div>

        <!-- Right Content - Price Management -->
        <div class="main-content">
            <!-- Toolbar -->
            <div class="toolbar">
                <div>
                    <button class="btn btn-success" onclick="saveAllPrices()">💾 Lưu tất cả</button>
                    <button class="btn btn-primary" onclick="exportPriceReport()">📊 Xuất báo cáo giá</button>
                    <button class="btn btn-warning" onclick="bulkUpdatePrices()">🔄 Cập nhật hàng loạt</button>
                </div>
            </div>

            <!-- Price Management Table -->
            <div class="price-table">
                <c:choose>
                    <c:when test="${empty productPrices}">
                        <div class="empty-state">
                            <h3>💰 Chưa có sản phẩm nào để thiết lập giá</h3>
                            <p>Hãy thêm sản phẩm trước để có thể thiết lập giá</p>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-success" style="margin-top: 1rem;">📦 Quản lý sản phẩm</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Chọn</th>
                                    <th>Mã hàng</th>
                                    <th>Tên hàng</th>
                                    <th>Kích thước</th>
                                    <th>Giá vốn</th>
                                    <th>Giá bán</th>
                                    <th>Lợi nhuận</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${productPrices}">
                                    <tr>
                                        <td>
                                            <input type="checkbox" class="row-select" data-product-id="${p.productCode}">
                                        </td>
                                        <td>
                                            <span class="product-code">${p.productCode}</span>
                                        </td>
                                        <td>
                                            <div class="product-name">${p.productName}</div>
                                            <c:if test="${not empty p.categoryName}">
                                                <span class="category-tag">${p.categoryName}</span>
                                            </c:if>
                                        </td>
                                        <td>${p.size}</td>
                                        <td>
                                            <input type="number" min="0" step="100" class="price-input original-price" data-product-id="${p.productCode}" data-field="originalPrice" value="${p.originalPrice}">
                                        </td>
                                        <td>
                                            <input type="number" min="0" step="100" class="price-input selling-price" data-product-id="${p.productCode}" data-field="sellingPrice" value="${p.sellingPrice}">
                                        </td>
                                        <td>
                                            <span class="profit-amount"><fmt:formatNumber value="${p.sellingPrice - p.originalPrice}" pattern="#,###" /> ₫</span>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-success" onclick="updateProductPrice('${p.productId}', '${p.size}')">Lưu</button>
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

<style>
.page-header {
    margin-bottom: 2rem;
}

.page-header h1 {
    color: #1c2b42;
    margin: 0 0 0.5rem 0;
    font-size: 2rem;
    font-weight: 700;
}

.page-header p {
    color: #6b778c;
    margin: 0;
    font-size: 1rem;
}

.empty-state {
    text-align: center;
    padding: 4rem 2rem;
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.empty-state h3 {
    color: #1c2b42;
    margin: 0 0 1rem 0;
    font-size: 1.5rem;
    font-weight: 600;
}

.empty-state p {
    color: #6b778c;
    margin: 0 0 2rem 0;
    font-size: 1rem;
}

.price-table {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    overflow: hidden;
}

.price-input {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 0.9rem;
    text-align: right;
}

.price-input:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
}

.original-price {
    background-color: #fff3cd;
}

.selling-price {
    background-color: #d1ecf1;
}

.profit-amount {
    font-weight: 600;
    color: #28a745;
}

.category-tag {
    display: inline-block;
    background: #e9ecef;
    color: #495057;
    padding: 0.2rem 0.5rem;
    border-radius: 12px;
    font-size: 0.75rem;
    margin-top: 0.25rem;
}

.btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
}

.row-selected {
    background-color: #f0f8ff;
}
</style>

<script>
    async function updateProductPrice(productId, size) {
        const row = Array.from(document.querySelectorAll('tbody tr')).find(tr => {
            const btn = tr.querySelector('button');
            return btn && btn.getAttribute('onclick') && btn.getAttribute('onclick').includes(productId) && btn.getAttribute('onclick').includes(size);
        }) || document.querySelector(`input[data-product-id="${productId}"]`)?.closest('tr');

        if (!row) {
            alert('Không tìm thấy dòng sản phẩm.');
            return;
        }

        const originalPrice = row.querySelector('.original-price').value;
        const sellingPrice = row.querySelector('.selling-price').value;

        if (!originalPrice || !sellingPrice || parseFloat(originalPrice) < 0 || parseFloat(sellingPrice) < 0) {
            alert('Vui lòng nhập giá hợp lệ');
            return;
        }

        try {
            const resp = await fetch(`${pageContext.request.contextPath}/setprice`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                },
                body: new URLSearchParams({
                    productId: productId,
                    size: size,
                    originalPrice: originalPrice,
                    sellingPrice: sellingPrice
                })
            });

            const data = await resp.json().catch(() => ({}));
            if (resp.ok && data.success) {
                alert('✅ Cập nhật giá thành công');
            } else {
                alert('❌ Cập nhật thất bại: ' + (data.message || resp.status));
            }
        } catch (err) {
            alert('❌ Lỗi khi gọi API: ' + err.message);
        }
    }

    function saveAllPrices() {
        const priceInputs = document.querySelectorAll('.price-input');
        const updates = [];
        
        priceInputs.forEach(input => {
            const productId = input.dataset.productId;
            const field = input.dataset.field;
            const value = input.value;
            
            if (value && parseFloat(value) >= 0) {
                updates.push({ productId, field, value });
            }
        });
        
        if (updates.length === 0) {
            alert('Không có thay đổi nào để lưu');
            return;
        }
        
        alert(`Lưu ${updates.length} thay đổi giá`);
    }

    function exportPriceReport() {
        alert('Chức năng xuất báo cáo giá sẽ được triển khai');
    }

    function bulkUpdatePrices() {
        alert('Chức năng cập nhật hàng loạt sẽ được triển khai');
    }

    // Lọc theo danh mục (checkbox bên trái)
    document.addEventListener('change', function(e) {
        if (e.target && e.target.name === 'categoryFilter') {
            filterByCategories();
        }
        if (e.target && e.target.classList.contains('row-select')) {
            const row = e.target.closest('tr');
            if (e.target.checked) {
                row.classList.add('row-selected');
            } else {
                row.classList.remove('row-selected');
            }
        }
    });

    function filterByCategories() {
        const checked = Array.from(document.querySelectorAll('input[name="categoryFilter"]:checked'))
            .map(cb => cb.value.trim());
        const rows = document.querySelectorAll('.price-table table tbody tr');

        rows.forEach(row => {
            const tagEl = row.querySelector('.category-tag');
            const category = tagEl ? tagEl.textContent.trim() : '';
            if (checked.length === 0) {
                row.style.display = '';
            } else {
                row.style.display = checked.includes(category) ? '' : 'none';
            }
        });
    }

    // Cập nhật lợi nhuận khi thay đổi giá
    document.addEventListener('input', function(e) {
        if (e.target.classList.contains('price-input')) {
            const row = e.target.closest('tr');
            const originalPrice = parseFloat(row.querySelector('.original-price').value) || 0;
            const sellingPrice = parseFloat(row.querySelector('.selling-price').value) || 0;
            const profit = sellingPrice - originalPrice;
            
            const profitElement = row.querySelector('.profit-amount');
            profitElement.textContent = new Intl.NumberFormat('vi-VN').format(profit) + ' ₫';
            
            // Thay đổi màu sắc dựa trên lợi nhuận
            if (profit < 0) {
                profitElement.style.color = '#dc3545';
            } else if (profit === 0) {
                profitElement.style.color = '#6c757d';
            } else {
                profitElement.style.color = '#28a745';
            }
        }
    });
</script>

<jsp:include page="../includes/footer.jsp" />
