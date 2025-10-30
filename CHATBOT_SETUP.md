# 🤖 LiteFlow ChatBot - Setup Guide

## Tổng Quan
LiteFlow ChatBot sử dụng OpenAI GPT API để cung cấp trợ lý AI thông minh cho hệ thống quản lý nhà hàng.

---

## 📋 Yêu Cầu

- **Java 17+**
- **Maven 3.6+**
- **OpenAI API Key** (đăng ký tại [OpenAI Platform](https://platform.openai.com/api-keys))

---

## 🔧 Hướng Dẫn Setup

### Bước 1: Lấy OpenAI API Key

1. Truy cập: https://platform.openai.com/api-keys
2. Đăng nhập/Đăng ký tài khoản OpenAI
3. Click **"Create new secret key"**
4. Copy API key (bắt đầu với `sk-proj-...` hoặc `sk-...`)
5. **Lưu ý:** Key chỉ hiển thị 1 lần, hãy lưu lại ngay!

### Bước 2: Cấu Hình API Key

#### **Cách 1: Sử dụng `.env` file (Khuyến nghị cho Development)**

1. Copy file template:
   ```bash
   copy .env.example .env
   ```

2. Mở file `.env` và thêm API key:
   ```env
   OPENAI_API_KEY=sk-proj-your-actual-api-key-here
   ```

3. **QUAN TRỌNG:** File `.env` đã được thêm vào `.gitignore` - **KHÔNG BAO GIỜ** commit file này lên Git!

#### **Cách 2: System Environment Variable (Khuyến nghị cho Production)**

**Windows:**
```powershell
# PowerShell (Administrator)
[System.Environment]::SetEnvironmentVariable('OPENAI_API_KEY', 'sk-proj-your-key-here', 'Machine')

# Hoặc qua GUI:
# Control Panel → System → Advanced → Environment Variables → New
```

**Linux/Mac:**
```bash
# Thêm vào ~/.bashrc hoặc ~/.zshrc
export OPENAI_API_KEY="sk-proj-your-key-here"

# Reload
source ~/.bashrc
```

**Docker:**
```yaml
# docker-compose.yml
environment:
  - OPENAI_API_KEY=sk-proj-your-key-here
```

---

## 🚀 Build & Deploy

### Build Project
```bash
mvn clean compile war:war
```

### Deploy to Tomcat
```bash
# Copy WAR file
copy target\LiteFlow.war C:\path\to\tomcat\webapps\

# Restart Tomcat
```

---

## ✅ Verify Setup

### 1. Check Server Logs
Khi Tomcat khởi động, bạn sẽ thấy:
```
✅ OpenAI API Key loaded successfully
   Key preview: sk-proj-xb...ELkA
🤖 LiteFlow ChatBot initialized
```

### 2. Test ChatBot API
```bash
# Check status
curl http://localhost:8080/LiteFlow/api/chatbot

# Expected response:
{
  "status": "active",
  "model": "gpt-3.5-turbo",
  "configured": true,
  "message": "LiteFlow ChatBot API is ready"
}
```

### 3. Test trên UI
1. Mở bất kỳ trang nào trong LiteFlow
2. Click vào nút ChatBot (góc dưới bên phải)
3. Gửi tin nhắn: "Xin chào"
4. Nếu nhận được phản hồi → **Setup thành công!** ✨

---

## 🔒 Bảo Mật API Key

### ✅ DO (Nên làm):
- ✅ Lưu API key trong `.env` hoặc environment variables
- ✅ Thêm `.env` vào `.gitignore`
- ✅ Sử dụng `.env.example` làm template (không chứa key thật)
- ✅ Rotate (thay đổi) API key định kỳ
- ✅ Giới hạn quyền truy cập API key (chỉ cho developers cần thiết)

### ❌ DON'T (Không nên):
- ❌ **KHÔNG BAO GIỜ** hardcode API key trong source code
- ❌ **KHÔNG BAO GIỜ** commit file `.env` lên Git
- ❌ **KHÔNG BAO GIỜ** chia sẻ API key qua email/chat
- ❌ **KHÔNG BAO GIỜ** public API key trên GitHub/GitLab

---

## 🐛 Troubleshooting

### ❌ "ChatBot is not configured"
**Nguyên nhân:** API key không được tải

**Giải pháp:**
1. Kiểm tra file `.env` có tồn tại không
2. Kiểm tra `OPENAI_API_KEY` có đúng format không
3. Restart Tomcat server
4. Xem server logs để biết chi tiết

### ❌ "Invalid API Key"
**Nguyên nhân:** API key sai hoặc hết hạn

**Giải pháp:**
1. Verify API key tại https://platform.openai.com/api-keys
2. Tạo key mới nếu cần
3. Update `.env` với key mới
4. Restart server

### ❌ "Rate limit exceeded"
**Nguyên nhân:** Đã sử dụng quá quota OpenAI

**Giải pháp:**
1. Kiểm tra usage tại https://platform.openai.com/usage
2. Nâng cấp plan nếu cần
3. Chờ quota reset (thường là đầu tháng)

### ❌ ".env file not loading"
**Nguyên nhân:** File `.env` không đúng vị trí

**Giải pháp:**
1. Đảm bảo `.env` nằm ở **project root** (cùng cấp với `pom.xml`)
2. Kiểm tra file encoding là UTF-8
3. Không có khoảng trắng thừa trong file

---

## 📊 API Usage & Cost

### Model hiện tại: `gpt-3.5-turbo`
- **Input:** ~$0.0005 / 1K tokens
- **Output:** ~$0.0015 / 1K tokens

### Ước tính chi phí:
- 100 tin nhắn/ngày ≈ $0.50/tháng
- 1000 tin nhắn/ngày ≈ $5/tháng

**Lưu ý:** Giá có thể thay đổi, xem chi tiết tại: https://openai.com/pricing

---

## 🔄 Update API Key

### Khi cần thay đổi API key:

1. **Update .env file:**
   ```env
   OPENAI_API_KEY=sk-proj-new-key-here
   ```

2. **Restart Tomcat:**
   ```bash
   # Stop
   C:\path\to\tomcat\bin\shutdown.bat
   
   # Start
   C:\path\to\tomcat\bin\startup.bat
   ```

3. **Verify:**
   - Check server logs
   - Test ChatBot trên UI

---

## 📞 Support

Nếu gặp vấn đề, liên hệ:
- **Email:** dev-team@liteflow.com
- **Slack:** #liteflow-support
- **GitHub Issues:** [LiteFlow Repository](https://github.com/your-org/liteflow)

---

## 📝 Notes

- ChatBot feature là **optional** - hệ thống vẫn hoạt động bình thường nếu không có API key
- Không có API key → ChatBot hiển thị thông báo "Not configured"
- API key chỉ được sử dụng cho ChatBot, không ảnh hưởng đến các tính năng khác

---

**Cập nhật lần cuối:** 2025-10-30  
**Version:** 1.0  
**Tác giả:** LiteFlow Dev Team

