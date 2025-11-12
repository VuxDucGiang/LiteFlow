# VNPay Parameter Fix - Remove vnp_SecureHashType

## Vấn đề phát hiện

**Ví dụ VNPay:**
```
vnp_Amount=1806000&vnp_Command=pay&...&vnp_SecureHash=3e0d61a0c0534b2e36680b3f7277743e...
```
❌ **KHÔNG có** `vnp_SecureHashType`

**Code hiện tại (trước khi fix):**
```
vnp_Amount=11000000&vnp_Command=pay&...&vnp_SecureHashType=SHA512&vnp_SecureHash=ec9c883dfa02b5b9...
```
❌ **CÓ** `vnp_SecureHashType=SHA512` (thừa tham số)

## Nguyên nhân

1. VNPay **KHÔNG yêu cầu** tham số `vnp_SecureHashType` trong payment URL
2. VNPay tự động detect hash type dựa trên độ dài hash:
   - **128 ký tự** = HMAC SHA512
   - **64 ký tự** = SHA256
3. Gửi thêm `vnp_SecureHashType` có thể gây lỗi "sai chữ ký" vì:
   - VNPay không mong đợi tham số này
   - Có thể ảnh hưởng đến cách VNPay validate hash

## Thay đổi đã thực hiện

### 1. Xóa `vnp_SecureHashType` khỏi Payment URL

**Trước:**
```java
query.append("&vnp_SecureHashType=").append(encodeForVNPay(hashType));
query.append("&vnp_SecureHash=").append(secureHash);
```

**Sau:**
```java
// VNPay automatically detects hash type from hash length
query.append("&vnp_SecureHash=").append(secureHash);
```

### 2. Cập nhật Validation Logic

**Cập nhật:** Tự động detect hash type từ độ dài hash nếu VNPay không gửi `vnp_SecureHashType` trong callback:

```java
String hashType = params.get("vnp_SecureHashType");
if (hashType == null || hashType.isEmpty()) {
    // Auto-detect hash type from hash length
    if (receivedHash.length() == 128) {
        hashType = "SHA512"; // HMAC SHA512
    } else if (receivedHash.length() == 64) {
        hashType = "SHA256"; // SHA256
    } else {
        hashType = "SHA512"; // Default
    }
}
```

## So sánh URL

### Trước khi fix:
```
https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?
  vnp_Amount=11000000&
  vnp_Command=pay&
  ...
  vnp_SecureHashType=SHA512&  ← THỪA
  vnp_SecureHash=ec9c883dfa02b5b9...
```

### Sau khi fix:
```
https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?
  vnp_Amount=11000000&
  vnp_Command=pay&
  ...
  vnp_SecureHash=ec9c883dfa02b5b9...  ← ĐÚNG (giống ví dụ VNPay)
```

## Kết quả

✅ **URL giờ đây giống với ví dụ VNPay:**
- Không có `vnp_SecureHashType` trong URL
- Chỉ có `vnp_SecureHash`
- VNPay sẽ tự detect hash type từ độ dài (128 chars = HMAC SHA512)

✅ **Validation vẫn hoạt động:**
- Tự động detect hash type từ độ dài nếu VNPay không gửi `vnp_SecureHashType`
- Vẫn hỗ trợ cả SHA512 và SHA256

## Test

Sau khi rebuild và restart server:
1. Tạo payment request
2. Kiểm tra URL không còn `vnp_SecureHashType`
3. Test thanh toán và kiểm tra validation logs

## Lưu ý

- `vnp_SecureHashType` **KHÔNG** được bao gồm trong hash input (đã đúng từ trước)
- `vnp_SecureHashType` **KHÔNG** nên có trong payment URL
- VNPay tự động detect hash type từ độ dài hash

