<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/includes/header.jsp">
  <jsp:param name="page" value="employees"/>
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/setup-employee.css">

<div class="setup-container">
    <!-- Sidebar -->
    <aside class="setup-sidebar">
        <h2>Thiết lập nhân viên</h2>
        <ul class="sidebar-menu">
            <li>
                <a href="#" class="active">
                    <i class='bx bx-cog'></i>
                    <span>Khởi tạo</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-time'></i>
                    <span>Ca làm việc</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-clipboard'></i>
                    <span>Chấm công</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-dollar'></i>
                    <span>Tính lương</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-calendar'></i>
                    <span>Ngày làm & Nghỉ</span>
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="setup-main">
        <div class="setup-header">
            <h1>Thiết lập nhanh</h1>
            <p>Chỉ vài bước cài đặt để quản lý nhân viên hiệu quả, tối ưu vận hành và tính lương chính xác</p>
        </div>

        <div class="setup-checklist">
            <!-- Thêm nhân viên -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Thêm nhân viên</h3>
                        <p>Cửa hàng đang có 3 nhân viên. <a href="${pageContext.request.contextPath}/employees">Xem danh sách</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="${pageContext.request.contextPath}/employees" class="btn-setup">Thêm nhân viên</a>
                </div>
            </div>

            <!-- Tạo ca làm việc -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Tạo ca làm việc</h3>
                        <p>Cửa hàng đang có 3 ca làm việc. <a href="${pageContext.request.contextPath}/schedule">Xem danh sách</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="${pageContext.request.contextPath}/schedule" class="btn-setup">Tạo ca</a>
                </div>
            </div>

            <!-- Xếp lịch làm việc -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Xếp lịch làm việc</h3>
                        <p>Đã xếp lịch cho 1/3 nhân viên trong cửa hàng. <a href="${pageContext.request.contextPath}/schedule">Xem lịch</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="${pageContext.request.contextPath}/schedule" class="btn-setup">Xếp lịch</a>
                </div>
            </div>

            <!-- Hình thức chấm công -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Hình thức chấm công</h3>
                        <p>Cửa hàng đã thiết lập hình thức chấm công. <a href="#">Xem chi tiết</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="#" class="btn-setup">Thiết lập</a>
                </div>
            </div>

            <!-- Thiết lập lương -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Thiết lập lương</h3>
                        <p>Đã thiết lập lương cho 1/3 nhân viên. <a href="#">Xem chi tiết</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="#" class="btn-setup">Thiết lập</a>
                </div>
            </div>

            <!-- Thiết lập bảng lương -->
            <div class="checklist-item">
                <div class="checklist-left">
                    <div class="check-icon">
                        <i class='bx bx-check'></i>
                    </div>
                    <div class="checklist-content">
                        <h3>Thiết lập bảng lương</h3>
                        <p>Theo dõi chính xác và tự động tính lương của nhân viên. <a href="#">Xem danh sách</a></p>
                    </div>
                </div>
                <div class="checklist-action">
                    <a href="#" class="btn-setup">Tạo bảng lương</a>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/includes/footer.jsp"/>


