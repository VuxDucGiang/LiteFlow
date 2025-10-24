# 📊 Hướng Dẫn Sử Dụng Chức Năng Import/Export Excel

## 🎯 Tổng Quan

Hệ thống LiteFlow đã được nâng cấp với chức năng **Import/Export Excel** chuyên nghiệp, cho phép:

- ✅ **Nhập dữ liệu hàng loạt** từ file Excel (.xlsx, .xls)
- ✅ **Xuất toàn bộ dữ liệu** ra file Excel với định dạng đẹp
- ✅ **Validation dữ liệu** tự động
- ✅ **Xử lý lỗi** chi tiết và thông báo rõ ràng
- ✅ **Drag & Drop** file Excel
- ✅ **Progress tracking** real-time

## 🚀 Cách Sử Dụng

### 📥 **Import Excel**

1. **Truy cập trang Room Table Management**
2. **Click nút "📥 Nhập Excel"** trên toolbar
3. **Chọn file Excel** hoặc kéo thả vào vùng upload
4. **Cấu hình tùy chọn:**
   - ☑️ Bỏ qua dữ liệu trùng lặp
   - ☑️ Kiểm tra tính hợp lệ của dữ liệu  
   - ☐ Tự động tạo phòng nếu chưa tồn tại
5. **Click "✅ Bắt đầu nhập"**
6. **Theo dõi tiến trình** và xem kết quả

### 📤 **Export Excel**

1. **Click nút "📤 Xuất Excel"** trên toolbar
2. **File Excel sẽ được tải xuống** tự động
3. **Tên file:** `roomtable_data.xlsx`

## 📋 **Định Dạng File Excel**

### 🏢 **Sheet "Rooms" (Phòng)**

| Cột | Tên Cột | Bắt Buộc | Mô Tả | Ví Dụ |
|-----|---------|----------|-------|-------|
| A | Tên phòng | ✅ | Tên phòng | "Phòng VIP" |
| B | Mô tả phòng | ❌ | Mô tả chi tiết | "Phòng cao cấp với view đẹp" |
| C | Số lượng bàn | ✅ | Số bàn tối đa (1-100) | 8 |
| D | Tổng sức chứa | ✅ | Tổng người (1-1000) | 32 |

**Ví dụ dữ liệu:**
```
Tên phòng          Mô tả                    Số lượng bàn  Tổng sức chứa
Phòng VIP          Phòng cao cấp với view đẹp  8           32
Phòng Thường       Phòng tiêu chuẩn           12          48
Phòng Gia Đình     Phòng rộng cho gia đình    6           24
```

### 🪑 **Sheet "Tables" (Bàn)**

| Cột | Tên Cột | Bắt Buộc | Mô Tả | Ví Dụ |
|-----|---------|----------|-------|-------|
| A | Số bàn | ✅ | Mã số bàn | "B001" |
| B | Tên bàn | ✅ | Tên hiển thị | "Bàn VIP 1" |
| C | Phòng | ❌ | Tên phòng | "Phòng VIP" |
| D | Sức chứa | ✅ | Số người (1-20) | 4 |
| E | Trạng thái | ❌ | Available/Occupied/Reserved/Maintenance | "Available" |

**Ví dụ dữ liệu:**
```
Số bàn  Tên bàn      Phòng      Sức chứa  Trạng thái
B001    Bàn VIP 1    Phòng VIP  4         Available
B002    Bàn VIP 2    Phòng VIP  4         Available
T001    Bàn Thường 1 Phòng Thường 4      Available
```

## ⚙️ **Tùy Chọn Import**

### 🔄 **Bỏ qua dữ liệu trùng lặp**
- **Bật:** Hệ thống sẽ bỏ qua các bản ghi đã tồn tại
- **Tắt:** Sẽ báo lỗi khi gặp dữ liệu trùng

### ✅ **Kiểm tra tính hợp lệ**
- **Bật:** Validate nghiêm ngặt theo quy tắc
- **Tắt:** Chấp nhận dữ liệu mà không kiểm tra

### 🏗️ **Tự động tạo phòng**
- **Bật:** Tự động tạo phòng mới nếu chưa tồn tại
- **Tắt:** Báo lỗi nếu phòng không tồn tại

## 📊 **Kết Quả Import**

Sau khi import, hệ thống sẽ hiển thị:

### 📈 **Thống Kê Tổng Quan**
- ✅ **Phòng thành công:** Số phòng được thêm thành công
- ❌ **Phòng lỗi:** Số phòng bị lỗi
- ✅ **Bàn thành công:** Số bàn được thêm thành công  
- ❌ **Bàn lỗi:** Số bàn bị lỗi

### 📝 **Chi Tiết Lỗi**
- Danh sách các lỗi cụ thể
- Dòng nào bị lỗi và nguyên nhân
- Gợi ý cách sửa lỗi

## 🎨 **Tính Năng Nổi Bật**

### 🎯 **User Experience**
- **Drag & Drop:** Kéo thả file Excel trực tiếp
- **Progress Bar:** Theo dõi tiến trình real-time
- **Notifications:** Thông báo đẹp mắt với animation
- **Responsive:** Hoạt động tốt trên mobile

### 🔒 **Bảo Mật & Validation**
- **File Type Check:** Chỉ chấp nhận .xlsx, .xls
- **File Size Limit:** Tối đa 10MB
- **Data Validation:** Kiểm tra tính hợp lệ nghiêm ngặt
- **Error Handling:** Xử lý lỗi chi tiết và an toàn

### ⚡ **Performance**
- **Streaming:** Xử lý file lớn mà không tốn RAM
- **Batch Processing:** Xử lý dữ liệu theo batch
- **Memory Efficient:** Tối ưu bộ nhớ

## 🛠️ **Troubleshooting**

### ❌ **Lỗi Thường Gặp**

1. **"Định dạng file không hợp lệ"**
   - ✅ Kiểm tra file có đúng định dạng .xlsx hoặc .xls
   - ✅ Đảm bảo file không bị hỏng

2. **"File quá lớn"**
   - ✅ File không được vượt quá 10MB
   - ✅ Chia nhỏ file thành nhiều phần

3. **"Tên phòng không được để trống"**
   - ✅ Kiểm tra cột A trong sheet Rooms
   - ✅ Đảm bảo không có dòng trống

4. **"Số lượng bàn phải từ 1-100"**
   - ✅ Kiểm tra giá trị trong cột C
   - ✅ Đảm bảo là số nguyên hợp lệ

### 🔧 **Tips & Tricks**

1. **Template File:** Sử dụng file mẫu để đảm bảo định dạng đúng
2. **Test Small:** Test với file nhỏ trước khi import file lớn
3. **Backup Data:** Backup dữ liệu trước khi import hàng loạt
4. **Check Results:** Luôn kiểm tra kết quả sau khi import

## 📞 **Hỗ Trợ**

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra log console để xem chi tiết lỗi
2. Đảm bảo file Excel đúng định dạng
3. Liên hệ team phát triển với thông tin lỗi chi tiết

---

**🎉 Chúc bạn sử dụng thành công chức năng Import/Export Excel!**
