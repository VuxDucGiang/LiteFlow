# Thêm chức năng tự động đặt hàng với cấu hình nhà cung cấp

## Mục tiêu
Thêm chức năng cho phép người dùng thiết lập nhà cung cấp cho từng danh mục sản phẩm trong phần AI Agent settings, để AI tự động đặt hàng khi phát hiện tồn kho thấp.

## Yêu cầu
1. Cho phép thiết lập nhà cung cấp cho từng danh mục sản phẩm
2. Nếu có nhiều mặt hàng ở các danh mục/nhà cung cấp khác nhau thì tạo nhiều đơn
3. Giữ nguyên logic kiểm tra: nếu trong ngày đã có đơn đặt hàng thì không đặt thêm
4. Không ảnh hưởng đến các chức năng khác

## Phân tích hiện trạng

### Điểm mạnh
- Tab "PO_AUTO" đã có trong settings
- Logic kiểm tra recent PO đã hoạt động tốt (`hasRecentItemByProductNameAndSize`)
- Logic tạo nhiều đơn cho nhiều supplier đã có sẵn
- `POAutoCreationService` đã group items theo supplier

### Điểm cần cải thiện
- `SupplierMappingService` đang hardcode mapping trong code
- Chưa có UI để user quản lý supplier mapping
- Cần chuyển mapping sang database config

## Giải pháp

### 1. Database - Thêm config cho supplier mapping
**File**: `database/ai_agent_config_data.sql`
- Thêm config key `po.supplier_mapping` với type `JSON`
- Lưu mapping dạng JSON: `{"CategoryName1": "SupplierID1", "CategoryName2": "SupplierID2"}`
- Default value: `{}` (empty object)

### 2. Backend - Cập nhật SupplierMappingService
**File**: `src/main/java/com/liteflow/service/procurement/SupplierMappingService.java`
- Thay thế hardcode mapping bằng đọc từ `AIAgentConfigService`
- Thêm method `getSupplierMappingFromConfig()` để đọc JSON config
- Giữ nguyên interface hiện tại để không ảnh hưởng code khác
- Thêm fallback về hardcode mapping nếu config không có

### 3. Backend - Thêm API để lấy danh sách suppliers và categories
**File**: `src/main/java/com/liteflow/controller/api/AIAgentConfigAPIServlet.java` hoặc tạo mới
- Thêm endpoint `/api/ai-agent-config/suppliers` để lấy danh sách suppliers
- Thêm endpoint `/api/ai-agent-config/categories` để lấy danh sách categories
- Hoặc trả về cùng response với config để frontend có đủ data

### 4. Frontend - Thêm UI quản lý supplier mapping
**File**: `src/main/webapp/js/ai-agent-config.js`
- Thêm custom render cho config key `po.supplier_mapping`
- Hiển thị dạng table với:
  - Column 1: Category name (dropdown từ danh sách categories)
  - Column 2: Supplier (dropdown từ danh sách suppliers)
  - Column 3: Action (Add/Remove button)
- Lưu dưới dạng JSON khi save

### 5. Frontend - Cập nhật renderConfigItem
**File**: `src/main/webapp/js/ai-agent-config.js`
- Thêm case `JSON` type với custom render cho supplier mapping
- Hoặc thêm special handling cho key `po.supplier_mapping`

### 6. Backend - Cập nhật AIAgentConfigService
**File**: `src/main/java/com/liteflow/service/ai/AIAgentConfigService.java`
- Đảm bảo method `getConfig()` hỗ trợ JSON type
- Thêm method `getJSONConfig()` để parse JSON config

## Implementation Steps

### Step 1: Database
1. Thêm config `po.supplier_mapping` vào `ai_agent_config_data.sql`
2. Type: `JSON`, Default: `{}`

### Step 2: Backend - SupplierMappingService
1. Thêm dependency `AIAgentConfigService`
2. Thêm method `getSupplierMappingFromConfig()` để đọc JSON
3. Cập nhật `getSupplierIdForCategory()` để đọc từ config trước, fallback về hardcode
4. Thêm logging để debug

### Step 3: Backend - API
1. Thêm endpoint để lấy suppliers (hoặc dùng existing endpoint)
2. Thêm endpoint để lấy categories (hoặc dùng existing endpoint)
3. Đảm bảo response format phù hợp với frontend

### Step 4: Frontend - UI
1. Thêm custom render function cho `po.supplier_mapping`
2. Fetch danh sách suppliers và categories khi load
3. Render table với add/remove functionality
4. Convert table data thành JSON khi save
5. Parse JSON khi load để hiển thị table

### Step 5: Testing
1. Test với config rỗng (fallback về hardcode)
2. Test với config có mapping
3. Test tạo PO tự động với nhiều categories/suppliers
4. Test logic kiểm tra recent PO vẫn hoạt động
5. Test không ảnh hưởng các chức năng khác

## Files cần thay đổi

1. `database/ai_agent_config_data.sql` - Thêm config mới
2. `src/main/java/com/liteflow/service/procurement/SupplierMappingService.java` - Cập nhật logic
3. `src/main/java/com/liteflow/service/ai/AIAgentConfigService.java` - Thêm JSON support (nếu chưa có)
4. `src/main/java/com/liteflow/controller/api/AIAgentConfigAPIServlet.java` - Thêm endpoints (nếu cần)
5. `src/main/webapp/js/ai-agent-config.js` - Thêm UI quản lý mapping
6. `src/main/webapp/js/ai-agent-config.js` - Cập nhật renderConfigItem

## Lưu ý
- Giữ nguyên logic kiểm tra recent PO (đã hoạt động tốt)
- Giữ nguyên logic tạo nhiều đơn cho nhiều supplier (đã có sẵn)
- Đảm bảo backward compatibility với hardcode mapping hiện tại
- UI phải user-friendly, dễ thêm/xóa mapping

