package com.liteflow.util;

import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.UUID;

/**
 * Utility class for VNPay payment integration. Handles payment URL generation,
 * checksum creation, and validation.
 */
public class VNPayUtil {

    private static final String VNPAY_VERSION = "2.1.0";
    private static final String VNPAY_COMMAND = "pay";
    private static final String VNPAY_CURRENCY = "VND";
    private static final String VNPAY_LOCALE = "vn";
    private static final String VNPAY_ORDER_TYPE = "180000";
    // Default IP address for VNPay (fallback when cannot get real IP)
    private static final String DEFAULT_IP_ADDRESS = "171.225.184.135";

    /**
     * Create payment URL for VNPay.
     *
     * @param amount Amount to pay (in VND)
     * @param orderInfo Order information description
     * @param ipAddress Client IP address
     * @param returnUrl URL to redirect after payment
     * @param transactionId Transaction ID (UUID) - will be used as vnp_TxnRef
     * @param tmnCode VNPay Terminal Code
     * @param hashSecret VNPay Hash Secret
     * @param vnpayUrl VNPay payment URL
     * @return Complete payment URL with checksum
     */
    public static String createPaymentUrl(
            BigDecimal amount,
            String orderInfo,
            String ipAddress,
            String returnUrl,
            UUID transactionId,
            String tmnCode,
            String hashSecret,
            String vnpayUrl) {

        try {
            // Format amount: multiply by 100 (VNPay requires amount in cents)
            long vnpAmount = amount.multiply(new BigDecimal("100")).longValue();

            // Create transaction reference (use UUID without dashes)
            String vnpTxnRef = transactionId.toString().replace("-", "");

            // Create date string in format yyyyMMddHHmmss
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnpCreateDate = dateFormat.format(new Date());

            // Ensure IP is IPv4 (critical for VNPay)
            if (ipAddress == null || ipAddress.isEmpty()) {
                ipAddress = DEFAULT_IP_ADDRESS;
                System.out.println("⚠️ IP address is null/empty, using default: " + DEFAULT_IP_ADDRESS);
            }

            // Final IPv6 to IPv4 conversion check
            if (ipAddress.equals("0:0:0:0:0:0:0:1") || ipAddress.equals("::1")) {
                ipAddress = DEFAULT_IP_ADDRESS;
                System.out.println("🔄 Converted IPv6 localhost to default IP: " + DEFAULT_IP_ADDRESS);
            } else if (ipAddress.contains(":") && !ipAddress.contains(".")) {
                // Any other IPv6 address - convert to IPv4 default
                ipAddress = DEFAULT_IP_ADDRESS;
                System.out.println("⚠️ Warning: IPv6 address detected, using default IP: " + DEFAULT_IP_ADDRESS);
            }

            // Normalize orderInfo - ensure it's not null and trim whitespace
            String normalizedOrderInfo = orderInfo;
            if (normalizedOrderInfo == null || normalizedOrderInfo.trim().isEmpty()) {
                normalizedOrderInfo = "Thanh toan don hang";
            } else {
                normalizedOrderInfo = normalizedOrderInfo.trim();
            }

            // Normalize returnUrl - ensure it's a valid URL
            String normalizedReturnUrl = returnUrl;
            if (normalizedReturnUrl == null || normalizedReturnUrl.trim().isEmpty()) {
                throw new IllegalArgumentException("Return URL cannot be null or empty");
            }
            normalizedReturnUrl = normalizedReturnUrl.trim();

            // Build parameter map (TreeMap để tự động sắp xếp theo thứ tự alphabet)
            // VNPay yêu cầu các tham số phải được sắp xếp theo thứ tự alphabet
            // CRITICAL: Must include ALL required parameters, order matters for hash calculation
            Map<String, String> vnpParams = new TreeMap<>();

            // Required parameters (must be in alphabetical order for hash calculation)
            vnpParams.put("vnp_Amount", String.valueOf(vnpAmount));
            vnpParams.put("vnp_Command", VNPAY_COMMAND);
            vnpParams.put("vnp_CreateDate", vnpCreateDate);
            vnpParams.put("vnp_CurrCode", VNPAY_CURRENCY);
            vnpParams.put("vnp_IpAddr", ipAddress);
            vnpParams.put("vnp_Locale", VNPAY_LOCALE);
            vnpParams.put("vnp_OrderInfo", normalizedOrderInfo);
            vnpParams.put("vnp_OrderType", VNPAY_ORDER_TYPE);
            vnpParams.put("vnp_ReturnUrl", normalizedReturnUrl);
            vnpParams.put("vnp_TmnCode", tmnCode.trim());
            vnpParams.put("vnp_TxnRef", vnpTxnRef);
            vnpParams.put("vnp_Version", VNPAY_VERSION);

            // Note: vnp_SecureHash and vnp_SecureHashType are added AFTER hash calculation
            // VNPay hash calculation: 
            // 1. Sắp xếp tham số theo alphabet (đã dùng TreeMap)
            // 2. Tạo query string RAW (không encode) để tính hash
            // 3. Tạo query string ENCODED để đưa vào URL
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();

            // Build query string for hash (raw, not encoded) and URL (encoded)
            // CRITICAL: Must process parameters in SAME ORDER as TreeMap (alphabetical)
            // TreeMap automatically sorts by key, so iteration order is guaranteed
            for (Map.Entry<String, String> entry : vnpParams.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();

                // Ensure value is not null (VNPay may reject null values)
                if (value == null) {
                    value = "";
                }

                // For hash calculation: use raw values (NOT URL encoded)
                // VNPay requires: key1=value1&key2=value2 (raw, no encoding)
                // Format must be exactly: key=value (no spaces, no encoding)
                if (hashData.length() > 0) {
                    hashData.append("&");
                }
                hashData.append(entry.getKey())
                        .append("=")
                        .append(URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII.toString()));

                // For URL: encode both key and value for safe transmission
                // IMPORTANT: VNPay requires space to be encoded as "+" not "%20"
                // Java's URLEncoder.encode() encodes space as "%20", so we need to convert it
                if (query.length() > 0) {
                    query.append("&");
                }
                String encodedKey = encodeForVNPay(key);
                String encodedValue = encodeForVNPay(value);
                query.append(encodedKey).append("=").append(encodedValue);
            }

            // Calculate hash from RAW query string (VNPay requirement)
            // Hash secret must be exactly as provided by VNPay
            // Using HMAC SHA512 (VNPay recommended)
            String hashInput = hashData.toString();
            String hashType = "SHA512"; // Using HMAC SHA512
            String secureHash = hmacSHA512(hashSecret, hashInput);

            // Logging for debugging
            System.out.println("═══════════════════════════════════════════════════════");
            System.out.println("🔐 VNPay Payment URL Generation");
            System.out.println("═══════════════════════════════════════════════════════");
            System.out.println("📋 TMN Code: " + tmnCode);
            System.out.println("💰 Amount: " + amount + " VND (vnp_Amount: " + vnpAmount + ")");
            System.out.println("📝 Order Info: " + normalizedOrderInfo);
            System.out.println("🌐 IP Address: " + ipAddress);
            System.out.println("🔗 Return URL: " + normalizedReturnUrl);
            System.out.println("📅 Create Date: " + vnpCreateDate);
            System.out.println("🔢 Transaction Ref: " + vnpTxnRef);
            System.out.println("🔐 Hash Type: " + hashType + " (HMAC SHA512)");
            System.out.println("───────────────────────────────────────────────────────");
            System.out.println("🔐 Hash Input (raw query string):");
            System.out.println(hashInput);
            System.out.println("───────────────────────────────────────────────────────");
            System.out.println("🔐 Hash Secret (first 10 chars): " + (hashSecret != null && hashSecret.length() > 10 ? hashSecret.substring(0, 10) + "..." : hashSecret));
            System.out.println("🔐 Secure Hash (HMAC " + hashType + "):");
            System.out.println(secureHash);
            System.out.println("═══════════════════════════════════════════════════════");

            // Append hash to URL-encoded query string
            // VNPay automatically detects hash type from hash length:
            // - 128 chars = HMAC SHA512
            // - 64 chars = SHA256
            // So we don't need to send vnp_SecureHashType parameter
            query.append("&vnp_SecureHash=").append(secureHash);

            // Build final URL
            String finalUrl = vnpayUrl + "?" + query.toString();

            // Log encoded query string to verify space encoding
            System.out.println("───────────────────────────────────────────────────────");
            System.out.println("🔗 Encoded Query String (for URL):");
            String encodedQuery = query.toString();
            System.out.println(encodedQuery.substring(0, Math.min(500, encodedQuery.length())) + (encodedQuery.length() > 500 ? "..." : ""));

            // Verify space encoding (should be + not %20)
            if (encodedQuery.contains("%20")) {
                System.err.println("⚠️ WARNING: Query string contains %20 (should be + for VNPay)");
            }
            if (encodedQuery.contains("+")) {
                System.out.println("✅ Verified: Query string uses + for spaces (VNPay requirement)");
            }

            System.out.println("───────────────────────────────────────────────────────");
            System.out.println("🔗 Final Payment URL (first 400 chars):");
            System.out.println(finalUrl.substring(0, Math.min(400, finalUrl.length())) + (finalUrl.length() > 400 ? "..." : ""));
            System.out.println("═══════════════════════════════════════════════════════");

            return finalUrl;

        } catch (Exception e) {
            throw new RuntimeException("Error creating VNPay payment URL: " + e.getMessage(), e);
        }
    }

    /**
     * Validate secure hash from VNPay callback. Supports both SHA256 and SHA512
     * based on vnp_SecureHashType parameter.
     *
     * @param params All parameters from VNPay callback (including
     * vnp_SecureHash)
     * @param hashSecret VNPay Hash Secret
     * @return true if hash is valid, false otherwise
     */
    public static boolean validateSecureHash(Map<String, String> params, String hashSecret) {
        try {
            String receivedHash = params.get("vnp_SecureHash");
            if (receivedHash == null || receivedHash.isEmpty()) {
                System.err.println("❌ vnp_SecureHash is missing or empty");
                return false;
            }

            // Get hash type from parameter or auto-detect from hash length
            // VNPay may or may not send vnp_SecureHashType
            // If not provided, auto-detect from hash length:
            // - 128 chars = HMAC SHA512
            // - 64 chars = SHA256
            String hashType = params.get("vnp_SecureHashType");
            if (hashType == null || hashType.trim().isEmpty()) {
                // Auto-detect hash type from hash length
                if (receivedHash.length() == 128) {
                    hashType = "SHA512"; // HMAC SHA512 (128 hex chars = 64 bytes)
                } else if (receivedHash.length() == 64) {
                    hashType = "SHA256"; // SHA256 (64 hex chars = 32 bytes)
                } else {
                    // Default to SHA512 for HMAC SHA512 (VNPay recommended)
                    hashType = "SHA512";
                }
                System.out.println("📋 Auto-detected Hash Type: " + hashType + " (from hash length: " + receivedHash.length() + ")");
            } else {
                System.out.println("📋 Received Hash Type from parameter: " + hashType);
            }

            System.out.println("═══════════════════════════════════════════════════════");
            System.out.println("🔐 VNPay Hash Validation");
            System.out.println("═══════════════════════════════════════════════════════");
            System.out.println("📋 Hash Type: " + hashType);
            System.out.println("📋 Received Hash: " + receivedHash);
            System.out.println("📋 Hash Length: " + receivedHash.length() + " chars");
            System.out.println("📋 Total params received: " + params.size());

            // Collect ALL parameters EXCEPT vnp_SecureHash and vnp_SecureHashType
            // CRITICAL: Must include ALL params from VNPay for hash calculation
            Map<String, String> paramsForHash = new TreeMap<>();
            for (Map.Entry<String, String> entry : params.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();

                // Skip only vnp_SecureHash and vnp_SecureHashType
                if (key.equals("vnp_SecureHash") || key.equals("vnp_SecureHashType")) {
                    continue;
                }

                // Include ALL other parameters (even if value is empty)
                // VNPay may send empty values and we must include them in hash calculation
                if (value == null) {
                    value = ""; // Convert null to empty string
                }

                paramsForHash.put(key, value);
                System.out.println("   ✅ Including param: " + key + " = "
                        + (value.length() > 50 ? value.substring(0, 50) + "..." : value));
            }

            System.out.println("───────────────────────────────────────────────────────");
            System.out.println("📋 Params for hash calculation: " + paramsForHash.size());

            // Build query string WITHOUT encoding for hash calculation
            // VNPay uses raw query string (not URL encoded) for hash validation
            // IMPORTANT: Must use TreeMap to ensure alphabetical order
            StringBuilder hashData = new StringBuilder();
            for (Map.Entry<String, String> entry : paramsForHash.entrySet()) {
                if (hashData.length() > 0) {
                    hashData.append("&");
                }
                // Use raw values for hash calculation (VNPay requirement)
                // Format: key=value (no URL encoding)
                hashData.append(entry.getKey()).append("=").append(entry.getValue());
            }

            String hashInput = hashData.toString();
            System.out.println("───────────────────────────────────────────────────────");
            System.out.println("🔐 Hash Input (raw query string):");
            System.out.println(hashInput);
            System.out.println("───────────────────────────────────────────────────────");

            // Calculate hash based on hash type
            // VNPay uses HMAC SHA512 (recommended)
            String calculatedHash;
            if ("SHA512".equalsIgnoreCase(hashType) || "HMACSHA512".equalsIgnoreCase(hashType)) {
                // Use HMAC SHA512 (VNPay recommended)
                calculatedHash = hmacSHA512(hashSecret, hashInput);
                System.out.println("🔐 Using HMAC SHA512");
            } else if ("SHA256".equalsIgnoreCase(hashType)) {
                // Support SHA256 if explicitly specified (backward compatibility)
                calculatedHash = sha256(hashSecret, hashInput);
                System.out.println("🔐 Using SHA256 (not HMAC)");
            } else if ("HMACSHA256".equalsIgnoreCase(hashType)) {
                // Support HMAC SHA256 if explicitly specified (backward compatibility)
                calculatedHash = hmacSHA256(hashSecret, hashInput);
                System.out.println("🔐 Using HMAC SHA256");
            } else {
                // Default to HMAC SHA512 (VNPay recommended)
                calculatedHash = hmacSHA512(hashSecret, hashInput);
                System.out.println("🔐 Using HMAC SHA512 (default)");
            }

            System.out.println("🔐 Calculated Hash: " + calculatedHash);
            System.out.println("🔐 Received Hash:   " + receivedHash);
            System.out.println("───────────────────────────────────────────────────────");

            // Compare hashes (case-insensitive)
            boolean isValid = calculatedHash.equalsIgnoreCase(receivedHash);

            if (isValid) {
                System.out.println("✅ Hash validation: SUCCESS");
            } else {
                System.err.println("❌ Hash validation: FAILED");
                System.err.println("   Expected: " + calculatedHash);
                System.err.println("   Received: " + receivedHash);
            }
            System.out.println("═══════════════════════════════════════════════════════");

            return isValid;

        } catch (Exception e) {
            System.err.println("❌ Error validating VNPay secure hash: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get client IP address from request. Handles proxy headers
     * (X-Forwarded-For, X-Real-IP). Converts IPv6 to IPv4 for VNPay
     * compatibility.
     *
     * @param request HTTP request
     * @return Client IP address (always IPv4 format for VNPay)
     */
    public static String getIpAddress(HttpServletRequest request) {
        String ipAddress = null;

        // Try headers first (for proxy/load balancer)
        ipAddress = request.getHeader("X-Forwarded-For");
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("X-Real-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("Proxy-Client-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("WL-Proxy-Client-IP");
        }

        // Fallback to remote address
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getRemoteAddr();
        }

        // If IP contains multiple addresses (from X-Forwarded-For), take the first one
        if (ipAddress != null && ipAddress.contains(",")) {
            ipAddress = ipAddress.split(",")[0].trim();
        }

        // Convert IPv6 localhost to IPv4 (VNPay requires IPv4 format)
        if (ipAddress != null) {
            // Check for IPv6 localhost formats
            if (ipAddress.equals("0:0:0:0:0:0:0:1")
                    || ipAddress.equals("::1")
                    || ipAddress.startsWith("0:0:0:0:0:0:0:1")
                    || ipAddress.startsWith("::1")) {
                ipAddress = DEFAULT_IP_ADDRESS;
                System.out.println("🔄 Converted IPv6 localhost to default IP: " + DEFAULT_IP_ADDRESS);
            } // Check if it's an IPv6 address (contains colons but not IPv4)
            else if (ipAddress.contains(":") && !ipAddress.contains(".")) {
                // For other IPv6 addresses, convert to default IPv4
                // VNPay typically requires IPv4
                System.out.println("⚠️ Warning: IPv6 address detected: " + ipAddress + ", using default IP: " + DEFAULT_IP_ADDRESS);
                ipAddress = DEFAULT_IP_ADDRESS;
            }
        }

        // Default to configured IP address if still empty
        if (ipAddress == null || ipAddress.isEmpty()) {
            ipAddress = DEFAULT_IP_ADDRESS;
            System.out.println("⚠️ IP address is null/empty, using default: " + DEFAULT_IP_ADDRESS);
        }

        System.out.println("🌐 Final IP address for VNPay: " + ipAddress);
        return ipAddress;
    }

    /**
     * Encode string for VNPay URL. VNPay requires spaces to be encoded as "+"
     * not "%20". This method encodes the string and then converts %20 to +.
     *
     * @param value Value to encode
     * @return Encoded string with spaces as "+"
     */
    private static String encodeForVNPay(String value) {
        if (value == null) {
            return "";
        }
        try {
            // First, encode using URLEncoder (will encode space as %20)
            String encoded = URLEncoder.encode(value, StandardCharsets.UTF_8);
            // VNPay requires space to be encoded as "+" not "%20"
            // Convert %20 to + (VNPay's requirement)
            encoded = encoded.replace("%20", "+");
            // Also handle other common cases that VNPay might expect
            // But keep other encoded characters as is
            return encoded;
        } catch (Exception e) {
            System.err.println("Error encoding value for VNPay: " + value);
            return value;
        }
    }

    /**
     * Create HMAC SHA512 hash. VNPay uses HMAC SHA512 for secure hash
     * generation (default).
     *
     * @param key Secret key
     * @param data Data to hash
     * @return Hexadecimal hash string (lowercase)
     */
    private static String hmacSHA512(String key, String data) {
        try {
            // VNPay uses HMAC SHA512
            // Java's Mac class provides HMAC functionality
            javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA512");
            javax.crypto.spec.SecretKeySpec secretKeySpec = new javax.crypto.spec.SecretKeySpec(
                    key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            mac.init(secretKeySpec);

            // Convert data to bytes using UTF-8 encoding
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] hashBytes = mac.doFinal(dataBytes);

            // Convert to hexadecimal string (lowercase)
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }

            return hexString.toString();

        } catch (Exception e) {
            System.err.println("❌ Error creating HMAC SHA512 hash: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error creating HMAC SHA512 hash: " + e.getMessage(), e);
        }
    }

    /**
     * Create SHA256 hash (not HMAC). VNPay requires SHA256 (not HMAC SHA256)
     * for signature. Format: SHA256(hashSecret + data) - hashSecret
     * concatenated with data, then SHA256
     *
     * @param hashSecret Secret key from VNPay
     * @param data Data to hash (raw query string)
     * @return Hexadecimal hash string (lowercase)
     */
    private static String sha256(String hashSecret, String data) {
        try {
            // VNPay requires SHA256 (not HMAC SHA256)
            // Format: SHA256(hashSecret + data)
            // Concatenate hashSecret and data, then apply SHA256
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");

            // Concatenate hashSecret + data
            String input = hashSecret + data;
            byte[] inputBytes = input.getBytes(StandardCharsets.UTF_8);

            // Calculate SHA256 hash
            byte[] hashBytes = digest.digest(inputBytes);

            // Convert to hexadecimal string (lowercase)
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }

            return hexString.toString();

        } catch (Exception e) {
            System.err.println("❌ Error creating SHA256 hash: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error creating SHA256 hash: " + e.getMessage(), e);
        }
    }

    /**
     * Create HMAC SHA256 hash (kept for backward compatibility). VNPay may use
     * HMAC SHA256 in some cases (based on vnp_SecureHashType).
     *
     * @param key Secret key
     * @param data Data to hash
     * @return Hexadecimal hash string (lowercase)
     */
    private static String hmacSHA256(String key, String data) {
        try {
            // VNPay may use HMAC SHA256
            javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
            javax.crypto.spec.SecretKeySpec secretKeySpec = new javax.crypto.spec.SecretKeySpec(
                    key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKeySpec);

            // Convert data to bytes using UTF-8 encoding
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] hashBytes = mac.doFinal(dataBytes);

            // Convert to hexadecimal string (lowercase)
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }

            return hexString.toString();

        } catch (Exception e) {
            System.err.println("❌ Error creating HMAC SHA256 hash: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error creating HMAC SHA256 hash: " + e.getMessage(), e);
        }
    }

    /**
     * Parse transaction ID from vnp_TxnRef. VNPay uses UUID without dashes as
     * transaction reference.
     *
     * @param vnpTxnRef Transaction reference from VNPay
     * @return UUID transaction ID, or null if invalid
     */
    public static UUID parseTransactionId(String vnpTxnRef) {
        try {
            if (vnpTxnRef == null || vnpTxnRef.length() != 32) {
                return null;
            }

            // Insert dashes to form UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
            String uuidString = vnpTxnRef.substring(0, 8) + "-"
                    + vnpTxnRef.substring(8, 12) + "-"
                    + vnpTxnRef.substring(12, 16) + "-"
                    + vnpTxnRef.substring(16, 20) + "-"
                    + vnpTxnRef.substring(20, 32);

            return UUID.fromString(uuidString);

        } catch (Exception e) {
            System.err.println("Error parsing transaction ID from vnp_TxnRef: " + vnpTxnRef);
            return null;
        }
    }

    /**
     * Format amount from VNPay format (cents) to BigDecimal (VND). VNPay
     * returns amount in cents (multiplied by 100).
     *
     * @param vnpAmount Amount in cents
     * @return Amount in VND as BigDecimal
     */
    public static BigDecimal parseAmount(String vnpAmount) {
        try {
            long amountInCents = Long.parseLong(vnpAmount);
            return BigDecimal.valueOf(amountInCents).divide(new BigDecimal("100"));
        } catch (Exception e) {
            System.err.println("Error parsing amount: " + vnpAmount);
            return BigDecimal.ZERO;
        }
    }

    /**
     * Check if response code indicates successful payment. VNPay returns "00"
     * for successful transactions.
     *
     * @param responseCode Response code from VNPay
     * @return true if payment is successful
     */
    public static boolean isSuccessResponse(String responseCode) {
        return "00".equals(responseCode);
    }
}
