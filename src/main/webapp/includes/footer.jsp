<%@ page contentType="text/html; charset=UTF-8" %>
    </div>
  </main>

  <!-- UTF-8 Standard Footer -->
  <footer class="utf8-footer">
    <div class="footer-container">
      <div class="footer-main">
        <div class="footer-brand">
          <div class="footer-logo">
            <div class="logo-icon">LF</div>
            <span class="brand-name">LiteFlow</span>
          </div>
          <p class="brand-description">
            Hệ thống quản lý bán hàng toàn diện, giúp doanh nghiệp tối ưu hóa quy trình kinh doanh và tăng trưởng bền vững.
          </p>
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

<script>
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
</script>
</body>
</html>
