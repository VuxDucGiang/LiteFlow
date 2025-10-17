<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>LiteFlow - Hệ thống quản lý</title>
  
  <!-- Icons + Fonts -->
  <link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  
  <!-- Custom CSS -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/design-system.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/animations.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ui-components.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
  
  <!-- Dropdown Fix Script -->
  <script src="${pageContext.request.contextPath}/js/dropdown-fix.js"></script>
  
  <!-- Inline Dropdown Fix -->
  <script>
    // Simple inline dropdown fix
    document.addEventListener('DOMContentLoaded', function() {
      console.log('🔧 Inline dropdown fix loaded');
      
      const dropdowns = document.querySelectorAll('.nav-item.dropdown');
      console.log('Found dropdowns:', dropdowns.length);
      
      dropdowns.forEach((dropdown, index) => {
        const toggle = dropdown.querySelector('.nav-link.dropdown-toggle');
        const menu = dropdown.querySelector('.dropdown-menu');
        
        console.log(`Dropdown ${index}:`, {
          element: dropdown,
          toggle: toggle,
          menu: menu
        });
        
        if (toggle && menu) {
          let hoverTimeout;
          
          // Click handler
          toggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            console.log('🖱️ Click on dropdown:', dropdown);
            
            // Close all other dropdowns
            dropdowns.forEach(otherDropdown => {
              if (otherDropdown !== dropdown) {
                otherDropdown.classList.remove('show', 'active');
              }
            });
            
            // Toggle current dropdown
            const isOpen = dropdown.classList.contains('show');
            
            if (isOpen) {
              dropdown.classList.remove('show', 'active');
              console.log('❌ Closed dropdown');
            } else {
              dropdown.classList.add('show', 'active');
              console.log('✅ Opened dropdown');
            }
          });
          
          // No hover effects - click only for dropdown
        }
      });
      
      // Close dropdowns when clicking outside or on dropdown items
      document.addEventListener('click', function(e) {
        if (!e.target.closest('.nav-item.dropdown')) {
          console.log('🖱️ Clicked outside, closing dropdowns');
          dropdowns.forEach(dropdown => {
            dropdown.classList.remove('show', 'active');
          });
        }
      });
      
      // Close dropdown when clicking on dropdown items
      document.querySelectorAll('.dropdown-item').forEach(item => {
        item.addEventListener('click', function() {
          console.log('🖱️ Dropdown item clicked:', this.textContent.trim());
          const dropdown = this.closest('.nav-item.dropdown');
          if (dropdown) {
            dropdown.classList.remove('show', 'active');
          }
        });
      });
    });
  </script>
</head>
<body>

<div class="app">
  <!-- Top Header Bar -->
  <header class="top-header">
    <div class="top-header-content">
      <a href="${pageContext.request.contextPath}/dashboard" class="nav-brand">
        <img src="${pageContext.request.contextPath}/img/logo.png" alt="LiteFlow Logo" class="nav-logo">
        <span class="nav-brand-name">LiteFlow</span>
      </a>
      <nav class="top-header-nav">
        <a href="#"><i class='bx bx-dollar'></i> Thanh toán</a>
        <a href="#"><i class='bx bx-dollar'></i> Vay vốn</a>
        <a href="#"><i class='bx bx-file'></i> Hoá đơn điện tử</a>
        <a href="#"><i class='bx bx-palette'></i> Chủ đề</a>
        <a href="#"><i class='bx bx-help-circle'></i> Hỗ trợ</a>
        <a href="#"><i class='bx bx-map-pin'></i> Chi nhánh trung tâm</a>
      </nav>
      <div class="top-header-right">
        <div class="language-selector">
          <span> (VN)</span>
          <i class='bx bx-chevron-down'></i>
        </div>
        <div class="header-icons">
          <div class="header-icon">
            <i class='bx bx-bell'></i>
          </div>
          <div class="header-icon">
            <i class='bx bx-cog'></i>
          </div>
          <div class="header-icon">
            <i class='bx bx-user'></i>
          </div>
        </div>
      </div>
    </div>
  </header>

  <!-- Main Navigation Bar -->
  <nav class="main-nav">
    <div class="nav-content">
      <div class="nav-menu">
        <a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-item ${param.page == 'dashboard' ? 'active' : ''}">
          <i class='bx bxs-dashboard'></i> Tổng quan
        </a>
        <div class="nav-item dropdown ${param.page == 'products' || param.page == 'setprice' ? 'active' : ''}">
          <a href="#" class="nav-link dropdown-toggle">
            <i class='bx bxs-package'></i> Hàng hóa
            <i class='bx bx-chevron-down' style="margin-left: 4px; font-size: 14px;"></i>
          </a>
          <div class="dropdown-menu">
            <a href="${pageContext.request.contextPath}/products" class="dropdown-item">
              <i class='bx bxs-category'></i> Danh mục
            </a>
            <a href="${pageContext.request.contextPath}/setprice" class="dropdown-item">
              <i class='bx bx-dollar'></i> Thiết lập giá
            </a>
          </div>
        </div>
        <a href="${pageContext.request.contextPath}/roomtable" class="nav-item ${param.page == 'rooms' ? 'active' : ''}">
          <i class='bx bx-store'></i> Phòng/Bàn
        </a>
        <a href="#" class="nav-item">
          <i class='bx bx-receipt'></i> Giao dịch
        </a>
        <a href="#" class="nav-item">
          <i class='bx bx-group'></i> Đối tác
        </a>
        <div class="nav-item dropdown">
          <a href="#" class="nav-link dropdown-toggle">
            <i class='bx bx-user'></i> Nhân viên
            <i class='bx bx-chevron-down' style="margin-left: 4px; font-size: 14px;"></i>
          </a>
          <div class="dropdown-menu">
            <a href="${pageContext.request.contextPath}/employees" class="dropdown-item">
              <i class='bx bx-group'></i> Danh sách nhân viên
            </a>
            <a href="${pageContext.request.contextPath}/schedule" class="dropdown-item">
              <i class='bx bx-calendar'></i> Lịch làm việc
            </a>
            <a href="#" class="dropdown-item">
              <i class='bx bx-time'></i> Bảng chấm công
            </a>
            <a href="#" class="dropdown-item">
              <i class='bx bx-money'></i> Bảng lương
            </a>
            <a href="${pageContext.request.contextPath}/employee/setupEmployee.jsp" class="dropdown-item">
              <i class='bx bx-cog'></i> Thiết lập nhân viên
            </a>
          </div>
        </div>
        <div class="nav-item dropdown">
          <a href="#" class="nav-link dropdown-toggle">
            <i class='bx bx-shopping-bag'></i> Mua sắm
            <i class='bx bx-chevron-down' style="margin-left: 4px; font-size: 14px;"></i>
          </a>
          <div class="dropdown-menu">
            <a href="${pageContext.request.contextPath}/procurement/dashboard" class="dropdown-item">
              <i class='bx bxs-dashboard'></i> Tổng quan
            </a>
            <a href="${pageContext.request.contextPath}/procurement/supplier" class="dropdown-item">
              <i class='bx bx-store'></i> Nhà cung cấp
            </a>
            <a href="${pageContext.request.contextPath}/procurement/po" class="dropdown-item">
              <i class='bx bx-receipt'></i> Đơn đặt hàng
            </a>
            <a href="${pageContext.request.contextPath}/procurement/gr" class="dropdown-item">
              <i class='bx bx-package'></i> Nhận hàng
            </a>
            <a href="${pageContext.request.contextPath}/procurement/invoice" class="dropdown-item">
              <i class='bx bx-file'></i> Hóa đơn
            </a>
          </div>
        </div>
        <a href="#" class="nav-item">
          <i class='bx bx-cart'></i> Bán Online
        </a>
        <a href="#" class="nav-item">
          <i class='bx bx-wallet'></i> Sổ quỹ
        </a>
        <a href="#" class="nav-item">
          <i class='bx bx-bar-chart'></i> Báo cáo
        </a>
     
      </div>
      <div class="nav-right">
        <div class="nav-icon" title="Nhà bếp">
          <i class='bx bx-home'></i>
        </div>
        <div class="nav-icon" title="Lễ tân">
          <i class='bx bx-calendar'></i>
        </div>
        <a href="${pageContext.request.contextPath}/cashier" class="nav-icon" title="Thu ngân" target="_blank">
          <i class='bx bx-file'></i>
        </a>
      </div>
    </div>
  </nav>

  <!-- Main Content -->
  <main class="main">
    <div class="content">
