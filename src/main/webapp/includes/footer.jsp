<%@ page contentType="text/html; charset=UTF-8" %>
    </div>
  </main>

  <!-- UTF-8 Standard Footer -->
  <footer class="utf8-footer">
    <div class="footer-container">
      <div class="footer-main">
        <div class="footer-brand">
          <div class="footer-logo">
            <img src="${pageContext.request.contextPath}/img/logo.png" alt="LiteFlow Logo" class="logo-image">
            <span class="brand-name">LiteFlow</span>
          </div>
          <p class="brand-description">
            Hệ thống quản lý bán hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình kinh doanh và tăng trưởng bền vững.
          </p>
          <div class="social-links">
            <a href="#" class="social-link facebook" data-tooltip="Facebook">
              <i class='bx bxl-facebook'></i>
            </a>
            <a href="#" class="social-link twitter" data-tooltip="Twitter">
              <i class='bx bxl-twitter'></i>
            </a>
            <a href="#" class="social-link linkedin" data-tooltip="LinkedIn">
              <i class='bx bxl-linkedin'></i>
            </a>
            <a href="#" class="social-link youtube" data-tooltip="YouTube">
              <i class='bx bxl-youtube'></i>
            </a>
          </div>
        </div>
        
        <div class="footer-sections">
          <div class="footer-column">
            <h4 class="column-title">Sản phẩm</h4>
            <ul class="footer-menu">
              <li><a href="#" class="footer-link">Quản lý kho hàng</a></li>
              <li><a href="#" class="footer-link">Bán hàng đa kênh</a></li>
              <li><a href="#" class="footer-link">Báo cáo thống kê</a></li>
              <li><a href="#" class="footer-link">Tích hợp API</a></li>
              <li><a href="#" class="footer-link">Ứng dụng di động</a></li>
            </ul>
          </div>
          
          <div class="footer-column">
            <h4 class="column-title">Hỗ trợ</h4>
            <ul class="footer-menu">
              <li><a href="#" class="footer-link">Trung tâm trợ giúp</a></li>
              <li><a href="#" class="footer-link">Tài liệu hướng dẫn</a></li>
              <li><a href="#" class="footer-link">Video hướng dẫn</a></li>
              <li><a href="#" class="footer-link">Liên hệ hỗ trợ</a></li>
              <li><a href="#" class="footer-link">Cộng đồng người dùng</a></li>
            </ul>
          </div>
          
          <div class="footer-column">
            <h4 class="column-title">Công ty</h4>
            <ul class="footer-menu">
              <li><a href="#" class="footer-link">Giới thiệu về chúng tôi</a></li>
              <li><a href="#" class="footer-link">Tin tức & Sự kiện</a></li>
              <li><a href="#" class="footer-link">Tuyển dụng</a></li>
              <li><a href="#" class="footer-link">Đối tác</a></li>
              <li><a href="#" class="footer-link">Liên hệ</a></li>
            </ul>
          </div>
          
          <div class="footer-column">
            <h4 class="column-title">Liên hệ</h4>
            <div class="contact-info">
              <div class="contact-row">
                <i class='bx bx-phone'></i>
                <span>Hotline: 1900 1234</span>
              </div>
              <div class="contact-row">
                <i class='bx bx-envelope'></i>
                <span>Email: support@liteflow.com</span>
              </div>
              <div class="contact-row">
                <i class='bx bx-map'></i>
                <span>Địa chỉ: Hà Nội, Việt Nam</span>
              </div>
              <div class="contact-row">
                <i class='bx bx-time'></i>
                <span>Giờ làm việc: 8:00 - 18:00</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
     
    </div>
       <div class="footer-bottom">
        <div class="footer-bottom-content">
          <div class="copyright">
            <p>&copy; 2024 LiteFlow. Tất cả quyền được bảo lưu.</p>
          </div>
          <div class="legal-links">
            <a href="#" class="legal-link">Điều khoản sử dụng</a>
            <a href="#" class="legal-link">Chính sách bảo mật</a>
            <a href="#" class="legal-link">Chính sách cookie</a>
          </div>
        </div>
      </div>
  </footer>

  <!-- Floating Support Button -->
  <button class="floating-support">
    <i class='bx bx-message-dots'></i>
    <span>Hỗ trợ</span>
  </button>
</div>

<!-- LiteFlow UI Enhancement Scripts -->
<script src="${pageContext.request.contextPath}/js/performance-system.js"></script>
<script src="${pageContext.request.contextPath}/js/ui-enhancements.js"></script>

<script>
  // Navigation dropdown functionality
  document.addEventListener('DOMContentLoaded', function() {
    // Handle dropdown menus
    document.querySelectorAll('.nav-item.dropdown').forEach(dropdown => {
      const dropdownToggle = dropdown.querySelector('.nav-item');
      const dropdownMenu = dropdown.querySelector('.dropdown-menu');
      
      if (dropdownToggle && dropdownMenu) {
        dropdownToggle.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          
          // Close other dropdowns
          document.querySelectorAll('.nav-item.dropdown').forEach(otherDropdown => {
            if (otherDropdown !== dropdown) {
              otherDropdown.classList.remove('show');
              const otherMenu = otherDropdown.querySelector('.dropdown-menu');
              if (otherMenu) {
                otherMenu.style.display = 'none';
              }
            }
          });
          
          // Toggle current dropdown
          dropdown.classList.toggle('show');
          if (dropdown.classList.contains('show')) {
            dropdownMenu.style.display = 'block';
            // Add animation
            dropdownMenu.style.opacity = '0';
            dropdownMenu.style.transform = 'translateY(-10px)';
            setTimeout(() => {
              dropdownMenu.style.opacity = '1';
              dropdownMenu.style.transform = 'translateY(0)';
            }, 10);
          } else {
            dropdownMenu.style.display = 'none';
          }
        });
      }
    });
    
    // Close dropdowns when clicking outside
    document.addEventListener('click', function(e) {
      if (!e.target.closest('.nav-item.dropdown')) {
        document.querySelectorAll('.nav-item.dropdown').forEach(dropdown => {
          dropdown.classList.remove('show');
          const dropdownMenu = dropdown.querySelector('.dropdown-menu');
          if (dropdownMenu) {
            dropdownMenu.style.display = 'none';
          }
        });
      }
    });
    
    // Handle dropdown item clicks
    document.querySelectorAll('.dropdown-item').forEach(item => {
      item.addEventListener('click', function() {
        // Close parent dropdown
        const dropdown = this.closest('.nav-item.dropdown');
        if (dropdown) {
          dropdown.classList.remove('show');
          const dropdownMenu = dropdown.querySelector('.dropdown-menu');
          if (dropdownMenu) {
            dropdownMenu.style.display = 'none';
          }
        }
      });
    });
  });

  // Navigation item interactions
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', function() {
      document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
      this.classList.add('active');
    });
  });

  // Language selector dropdown
  document.querySelector('.language-selector')?.addEventListener('click', function() {
    // Add dropdown functionality here
    console.log('Language selector clicked');
  });

  // Floating support button
  document.querySelector('.floating-support')?.addEventListener('click', function() {
    // Add support functionality here
    console.log('Support button clicked');
  });

  // Footer Enhancements
  document.addEventListener('DOMContentLoaded', function() {
    // Animate footer elements on scroll
    const footerElements = document.querySelectorAll('.footer-column, .footer-brand');
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-fade-in-up');
        }
      });
    }, { threshold: 0.1 });

    footerElements.forEach(el => observer.observe(el));

    // Social links hover effects
    document.querySelectorAll('.social-link').forEach(link => {
      link.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-3px) scale(1.1)';
        this.style.boxShadow = '0 8px 25px rgba(0, 128, 255, 0.3)';
      });
      
      link.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0) scale(1)';
        this.style.boxShadow = '0 4px 15px rgba(0, 128, 255, 0.2)';
      });
    });

    // Footer links hover effects
    document.querySelectorAll('.footer-link').forEach(link => {
      link.addEventListener('mouseenter', function() {
        this.style.color = '#00c6ff';
        this.style.transform = 'translateX(5px)';
      });
      
      link.addEventListener('mouseleave', function() {
        this.style.color = '#ccc';
        this.style.transform = 'translateX(0)';
      });
    });

    // Contact info hover effects
    document.querySelectorAll('.contact-row').forEach(row => {
      row.addEventListener('mouseenter', function() {
        this.style.backgroundColor = 'rgba(0, 128, 255, 0.1)';
        this.style.transform = 'translateX(10px)';
      });
      
      row.addEventListener('mouseleave', function() {
        this.style.backgroundColor = 'transparent';
        this.style.transform = 'translateX(0)';
      });
    });

    // Tooltip functionality
    document.querySelectorAll('[data-tooltip]').forEach(element => {
      element.addEventListener('mouseenter', function() {
        const tooltip = document.createElement('div');
        tooltip.className = 'tooltip';
        tooltip.textContent = this.dataset.tooltip;
        tooltip.style.cssText = `
          position: absolute;
          background: rgba(0, 0, 0, 0.8);
          color: white;
          padding: 8px 12px;
          border-radius: 6px;
          font-size: 12px;
          z-index: 1000;
          pointer-events: none;
          opacity: 0;
          transition: opacity 0.3s ease;
          bottom: 100%;
          left: 50%;
          transform: translateX(-50%);
          margin-bottom: 8px;
        `;
        
        this.style.position = 'relative';
        this.appendChild(tooltip);
        
        setTimeout(() => {
          tooltip.style.opacity = '1';
        }, 10);
      });
      
      element.addEventListener('mouseleave', function() {
        const tooltip = this.querySelector('.tooltip');
        if (tooltip) {
          tooltip.style.opacity = '0';
          setTimeout(() => {
            tooltip.remove();
          }, 300);
        }
      });
    });

    // Newsletter subscription (if added)
    const newsletterForm = document.querySelector('.newsletter-form');
    if (newsletterForm) {
      newsletterForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const email = this.querySelector('input[type="email"]').value;
        
        // Show success animation
        const button = this.querySelector('button');
        const originalText = button.textContent;
        button.textContent = 'Đang gửi...';
        button.style.background = 'linear-gradient(135deg, #00c6ff, #0080FF)';
        
        setTimeout(() => {
          button.textContent = 'Đã đăng ký!';
          button.style.background = 'linear-gradient(135deg, #7d2ae8, #00c6ff)';
          
          setTimeout(() => {
            button.textContent = originalText;
            button.style.background = 'linear-gradient(135deg, #0080FF, #00c6ff)';
            this.reset();
          }, 2000);
        }, 1000);
      });
    }
  });
</script>
</body>
</html>
