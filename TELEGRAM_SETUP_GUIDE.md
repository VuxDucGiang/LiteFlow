# Hướng dẫn cấu hình Telegram Notifications cho Purchase Orders

## Vấn đề
Khi tạo/duyệt/từ chối Purchase Order, không có thông báo được gửi đến Telegram.

## Các bước kiểm tra và cấu hình

### 1. Kiểm tra Telegram Bot Token

#### 1.1. Tạo file `.env` trong project root (nếu chưa có)
Tạo file `.env` tại thư mục gốc của project (cùng cấp với `pom.xml`):

```env
TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
```

**Lưu ý:** 
- Token có dạng: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`
- Phải có dấu `:` trong token
- Không có khoảng trắng trước/sau token

#### 1.2. Hoặc set System Environment Variable
```bash
# Windows (PowerShell)
$env:TELEGRAM_BOT_TOKEN="your_telegram_bot_token_here"

# Windows (CMD)
set TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here

# Linux/Mac
export TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
```

### 2. Kiểm tra Database - UserAlertPreferences

#### 2.1. Kiểm tra user có Telegram Chat ID chưa
Chạy query sau trong SQL Server:

```sql
USE LiteFlowDBO;
GO

SELECT 
    u.UserID,
    u.Email,
    uap.TelegramUserID,
    uap.EnableTelegram,
    uap.EnableNotifications
FROM Users u
LEFT JOIN UserAlertPreferences uap ON u.UserID = uap.UserID
WHERE u.Email = 'your_email@example.com'; -- Thay email của bạn
```

#### 2.2. Cấu hình Telegram Chat ID cho user
Chạy script `database/telegram_data.sql` hoặc chạy query sau:

```sql
USE LiteFlowDBO;
GO

-- Thay đổi Email và TelegramUserID theo nhu cầu
DECLARE @UserID UNIQUEIDENTIFIER = (SELECT TOP 1 UserID FROM Users WHERE Email = 'your_email@example.com');
DECLARE @TelegramChatID NVARCHAR(50) = 'your_telegram_chat_id'; -- Ví dụ: '6969473762'

-- Update hoặc tạo UserAlertPreference
IF EXISTS (SELECT 1 FROM UserAlertPreferences WHERE UserID = @UserID)
BEGIN
    UPDATE UserAlertPreferences
    SET TelegramUserID = @TelegramChatID,
        EnableTelegram = 1,
        EnableNotifications = 1,
        UpdatedAt = SYSDATETIME()
    WHERE UserID = @UserID;
    
    PRINT '✅ Updated UserAlertPreference';
END
ELSE
BEGIN
    INSERT INTO UserAlertPreferences (
        UserID,
        EnableNotifications,
        EnableTelegram,
        TelegramUserID,
        CreatedAt,
        UpdatedAt
    )
    VALUES (
        @UserID,
        1,  -- EnableNotifications
        1,  -- EnableTelegram
        @TelegramChatID,
        SYSDATETIME(),
        SYSDATETIME()
    );
    
    PRINT '✅ Created UserAlertPreference';
END
GO
```

### 3. Lấy Telegram Chat ID

#### Cách 1: Sử dụng Bot @userinfobot
1. Mở Telegram, tìm bot `@userinfobot`
2. Gửi lệnh `/start`
3. Bot sẽ trả về Chat ID của bạn (số dài, ví dụ: `6969473762`)

#### Cách 2: Sử dụng Bot của bạn
1. Tạo bot mới qua @BotFather trên Telegram
2. Lấy Bot Token từ @BotFather
3. Gửi tin nhắn bất kỳ cho bot của bạn
4. Truy cập: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
5. Tìm `"chat":{"id":123456789}` trong response - đó là Chat ID của bạn

### 4. Kiểm tra Logs

Sau khi tạo/duyệt/từ chối PO, kiểm tra console logs để xem:

#### Logs thành công:
```
🔔 Initiating PO notification for POID: ...
🔍 Found X users to notify
✅ [POAlert] Telegram bot token loaded
🔍 [POAlert] Calling sendTelegramToUser with:
✅ [Telegram] Telegram message sent to user: ...
✅ PO notification sent to User ...
```

#### Logs lỗi thường gặp:

**Lỗi 1: Không có Telegram Bot Token**
```
❌ [POAlert] Telegram bot token not configured
❌ [POAlert] Checked .env file and system environment variable TELEGRAM_BOT_TOKEN
```
**Giải pháp:** Tạo file `.env` hoặc set environment variable

**Lỗi 2: Không có users để notify**
```
⚠️ No users configured for Telegram notifications - Check UserAlertPreferences table
```
**Giải pháp:** Cấu hình UserAlertPreferences với TelegramUserID và EnableTelegram = 1

**Lỗi 3: User không có Chat ID**
```
⚠️ User ... does not have Telegram Chat ID configured
```
**Giải pháp:** Cập nhật TelegramUserID trong UserAlertPreferences

**Lỗi 4: Telegram API error**
```
❌ [Telegram] API returned error code: 400
❌ [Telegram] Error response body: {"ok":false,"error_code":400,"description":"Bad Request: chat not found"}
```
**Giải pháp:** Kiểm tra lại Chat ID có đúng không

### 5. Test Telegram Notification

Sau khi cấu hình xong, test bằng cách:
1. Tạo một Purchase Order mới
2. Kiểm tra console logs
3. Kiểm tra Telegram xem có nhận được thông báo không

### 6. Troubleshooting

#### Vấn đề: Token không được load từ .env
- Kiểm tra file `.env` có ở project root không
- Kiểm tra format: `TELEGRAM_BOT_TOKEN=token` (không có dấu cách)
- Restart server sau khi tạo/sửa .env

#### Vấn đề: Chat ID không đúng
- Lấy lại Chat ID từ @userinfobot
- Đảm bảo đã gửi tin nhắn cho bot trước khi lấy Chat ID
- Kiểm tra Chat ID trong database có đúng format không (số nguyên)

#### Vấn đề: Notification bị disable
- Kiểm tra `notification.enable_telegram` trong database (AIAgentConfigurations table)
- Kiểm tra `EnableTelegram = 1` trong UserAlertPreferences

## Checklist

- [ ] File `.env` đã được tạo với `TELEGRAM_BOT_TOKEN`
- [ ] Bot Token đã được lấy từ @BotFather
- [ ] Telegram Chat ID đã được lấy và cấu hình trong database
- [ ] UserAlertPreferences đã có `EnableTelegram = 1` và `TelegramUserID` đã set
- [ ] Server đã được restart sau khi cấu hình
- [ ] Đã test bằng cách tạo PO mới và kiểm tra logs

