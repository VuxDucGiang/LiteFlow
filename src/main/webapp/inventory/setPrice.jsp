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
                    <p style="color: #666; font-style: italic;">Chưa có danh mục nào</p>
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
                                    <th>Mã sản phẩm</th>
                                    <th>Tên sản phẩm</th>
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
                                            <input type="number" class="price-input original-price" 
                                                   value="${p.originalPrice}" 
                                                   data-product-id="${p.productId}"
                                                   data-field="originalPrice"
                                                   min="0" step="1000">
                                        </td>
                                        <td>
                                            <input type="number" class="price-input selling-price" 
                                                   value="${p.sellingPrice}" 
                                                   data-product-id="${p.productId}"
                                                   data-field="sellingPrice"
                                                   min="0" step="1000">
                                        </td>
                                        <td>
                                            <span class="profit-amount">
                                                <fmt:formatNumber value="${p.sellingPrice - p.originalPrice}" pattern="#,###" /> ₫
                                            </span>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-primary" onclick="updateProductPrice('${p.productId}')">
                                                💾 Lưu
                                            </button>
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
</style>

<script>
    function updateProductPrice(productId) {
        const row = document.querySelector(`input[data-product-id="${productId}"]`).closest('tr');
        const originalPrice = row.querySelector('.original-price').value;
        const sellingPrice = row.querySelector('.selling-price').value;
        
        if (!originalPrice || !sellingPrice || parseFloat(originalPrice) < 0 || parseFloat(sellingPrice) < 0) {
            alert('Vui lòng nhập giá hợp lệ');
            return;
        }
        
        alert(`Cập nhật giá cho sản phẩm ${productId}: Giá vốn ${originalPrice}, Giá bán ${sellingPrice}`);
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
