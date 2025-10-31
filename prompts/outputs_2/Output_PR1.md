## PR1 — Kế hoạch kiểm thử tích hợp hệ thống LiteFlow

### 1) Phân tích hệ thống & các module
- Kiến trúc: Jakarta EE (Servlet/Filter), tầng Service, DAO/Repository, RDBMS; frontend web gọi API/Servlet, session-based auth.
- Module trọng tâm: Authentication & RBAC, Cashier Order (đơn hàng, thanh toán, in hóa đơn), Menu/Pricing, Inventory/Stock, Employee Management, Table/Reservation, Customer, Reporting, Notification.
- Điểm tích hợp chính:
  - Frontend ↔ Servlet/API (form/input, AJAX/fetch, session/cookie).
  - Servlet/Filter ↔ Service (validation, authz, nghiệp vụ, transaction boundary).
  - Service ↔ DAO/DB (CRUD, join, transaction, constraint).
  - Luồng chéo: Order ↔ Inventory ↔ Payment ↔ Receipt/Report; Employee ↔ Auth/RBAC; Reservation ↔ Order/Table.

### 2) Mục tiêu kiểm thử
- Bao phủ tích hợp backend: Servlet ↔ Service ↔ DB (CRUD, transaction, lỗi/rollback) cho các module chính.
- Bao phủ tích hợp frontend: luồng nhập liệu, điều hướng, gọi API, xử lý response/lỗi; session/auth flow.
- E2E ưu tiên (luồng hạnh phúc + lỗi):
  1) Cashier Order: tạo đơn → tính giá/khuyến mãi → thanh toán → in/ghi nhận → cập nhật tồn.
  2) Inventory: nhập/xuất kho → đồng bộ với món và đơn hàng.
  3) Employee Management: đăng nhập → phân quyền → thao tác CRUD phù hợp role.
- Phi chức năng tối thiểu: tính nhất quán giao dịch, đồng thời cơ bản (song song đặt món/cập nhật tồn), hiệu năng đường nóng (tạo đơn), log & truy vết.
- Mục tiêu coverage tích hợp >70% trên tầng Servlet+Service (line/branch ở nghiệp vụ trọng yếu; không đòi hỏi unit-coverage).

### 3) Chiến lược kiểm thử tích hợp
- Cấp độ & thứ tự:
  - Service+DAO+DB (integration): thật DB (schema thật, dữ liệu seed), hạn chế mock; tập trung transaction & constraint.
  - Servlet/API (integration): chạy container/embedded, test filter/auth/session, mapping, status code, payload.
  - UI ↔ API (E2E mỏng): kịch bản đầu-cuối cho 3 luồng ưu tiên; kiểm tra hiển thị, điều hướng, lỗi.
- Dữ liệu & môi trường:
  - Database riêng cho test (migrate schema, seed test fixtures theo module; reset giữa tests để cô lập).
  - Tối thiểu stub/mock các ngoại hệ (payment gateway, email/SMS) để kiểm soát lỗi/timeouts.
- Bao phủ lỗi & biên:
  - Transactional: partial failure (thanh toán thành công nhưng ghi đơn lỗi) → đảm bảo rollback/idempotency.
  - Concurrency: 2 đơn đặt cùng món tồn thấp → kiểm tra lock/optimistic concurrency.
  - Biên số liệu: giá/giảm giá/ làm tròn; ngày/giờ/ca; dữ liệu trống/invalid; input vượt giới hạn.
- Tiêu chí pass/fail:
  - Response đúng (status/payload), trạng thái hệ thống đúng (DB/log), bất biến nghiệp vụ giữ nguyên.
  - Không rò rỉ session, không bypass RBAC, log có trace-id để truy vết.
- Đo lường coverage:
  - Backend: JaCoCo (hoặc tương đương) cấu hình cho tests tích hợp; báo cáo line/branch trên gói Servlet/Service nghiệp vụ.
  - Frontend: chạy E2E với thu thập coverage UI (nếu áp dụng) để bổ trợ; trọng tâm vẫn backend business.

### 4) Tình huống đặc biệt/rủi ro
- Biên giao dịch giữa Payment và cập nhật Inventory (đồng nhất/đảo ngược). Xử lý retry/idempotent key.
- Đồng thời: ghi tồn kho, cập nhật trạng thái đơn; tránh double-spend.
- Tiền tệ & làm tròn: thuế/khuyến mãi/đa đơn vị tính.
- Thời gian & ca làm việc: timezone, đổi ngày, khóa sổ.
- Dữ liệu cũ/ràng buộc DB: khóa ngoại, unique; null/defaults khác môi trường.
- Tích hợp ngoại hệ: timeout/throttling, fallback, kiểm thử lỗi mạng.

### 5) Documentation & Coverage
- Ghi log test run, artifacts (request/response, DB snapshot tối giản, log ứng dụng) theo kịch bản.
- Báo cáo coverage tích hợp >70%: lưu HTML/XML/summary và checklist module đã bao phủ.
- Chuẩn hóa cấu trúc tài liệu:
  - Kế hoạch tổng quan (file này), checklist luồng E2E, cấu hình môi trường, seed data, hướng dẫn chạy.
  - Đầu ra báo cáo và nhật ký test được lưu cùng repo dưới `prompts/outputs_2/`.

— Không sinh code, không liệt kê test case chi tiết ở bước này. Tập trung vào phạm vi và chiến lược để đạt >70% coverage tích hợp.


