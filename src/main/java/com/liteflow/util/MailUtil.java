package com.liteflow.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.UnsupportedEncodingException;

import java.util.Properties;
import java.util.logging.Logger;

public class MailUtil {

    private static final Logger LOG = Logger.getLogger(MailUtil.class.getName());

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SMTP_USER = "iloveaifu@gmail.com";
    private static final String SMTP_PASS = "mbtiraewyuhnpijt";  // App Password

    public static void sendOtpMail(String to, String otp) throws MessagingException, UnsupportedEncodingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SMTP_USER, "LiteFlow Security"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject("🔐 LiteFlow Email Verification - Your OTP Code");

        // HTML template - Fixed for Java 11 compatibility
        String html = "<div style=\"font-family: Arial, sans-serif; padding: 20px; background: #f5f7fa;\">" +
            "<h2 style=\"color: #333;\">Welcome to <span style=\"color:#0066ff;\">LiteFlow</span> 🎉</h2>" +
            "<p>Thank you for signing up. To complete your registration, please use the following One-Time Password (OTP):</p>" +
            "<div style=\"margin: 20px 0; text-align: center;\">" +
                "<div style=\"display:inline-block; padding: 20px 40px; background:#0066ff; color:#fff; font-size:28px; font-weight:bold; letter-spacing:8px; border-radius:8px;\">" +
                    otp +
                "</div>" +
            "</div>" +
            "<p>This code is valid for <b>5 minutes</b>. Please do not share it with anyone.</p>" +
            "<p>If you did not request this, please ignore this email.</p>" +
            "<hr style=\"margin:30px 0;\"/>" +
            "<p style=\"font-size:12px; color:#555;\">" +
                "LiteFlow Security Team<br/>" +
                "This is an automated email, please do not reply." +
            "</p>" +
        "</div>";

        message.setContent(html, "text/html; charset=UTF-8");

        Transport.send(message);
        LOG.info("✅ OTP mail sent to " + to);
    }

    /**
     * Send reservation confirmation email to customer
     * @param to Customer email address
     * @param customerName Customer name
     * @param reservationCode Reservation code (e.g., 30102025-001)
     * @param arrivalTime Arrival date and time
     * @param numberOfGuests Number of guests
     * @param tableName Table name (can be null)
     * @param depositAmount Deposit amount (deprecated, ignored)
     * @param preOrderedItems List of pre-ordered items (can be null)
     */
    public static void sendReservationConfirmationMail(
            String to, 
            String customerName, 
            String reservationCode,
            String arrivalTime,
            int numberOfGuests,
            String tableName,
            String depositAmount,
            String preOrderedItems) throws MessagingException, UnsupportedEncodingException {
        
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SMTP_USER, "LiteFlow Restaurant"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject("✅ Xác Nhận Đặt Bàn - LiteFlow Restaurant");

        // Professional HTML email template
        String html = 
            "<!DOCTYPE html>" +
            "<html>" +
            "<head>" +
                "<meta charset=\"UTF-8\">" +
                "<style>" +
                    "body { margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }" +
                    ".container { max-width: 600px; margin: 0 auto; background: #ffffff; }" +
                    ".header { background: linear-gradient(135deg, #0080FF 0%, #00c6ff 50%, #7d2ae8 100%); padding: 30px 20px; text-align: center; }" +
                    ".header h1 { color: #ffffff; margin: 0; font-size: 28px; font-weight: bold; }" +
                    ".header p { color: #ffffff; margin: 10px 0 0 0; font-size: 14px; opacity: 0.9; }" +
                    ".content { padding: 30px 20px; }" +
                    ".greeting { font-size: 18px; color: #333; margin-bottom: 20px; }" +
                    ".success-badge { background: #d4edda; border: 2px solid #28a745; border-radius: 8px; padding: 15px; text-align: center; margin: 20px 0; }" +
                    ".success-badge h2 { color: #28a745; margin: 0 0 10px 0; font-size: 24px; }" +
                    ".success-badge .code { font-size: 32px; font-weight: bold; color: #0080FF; letter-spacing: 2px; }" +
                    ".details-box { background: #f8f9fa; border-left: 4px solid #0080FF; padding: 20px; margin: 20px 0; border-radius: 4px; }" +
                    ".detail-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #e9ecef; }" +
                    ".detail-row:last-child { border-bottom: none; }" +
                    ".detail-label { font-weight: 600; color: #555; }" +
                    ".detail-value { color: #333; text-align: right; }" +
                    ".items-section { margin: 20px 0; }" +
                    ".items-title { font-weight: 600; color: #333; margin-bottom: 10px; }" +
                    ".item { background: #fff; border: 1px solid #e9ecef; padding: 10px; margin: 5px 0; border-radius: 4px; }" +
                    ".important-note { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px; }" +
                    ".important-note strong { color: #856404; }" +
                    ".footer { background: #f8f9fa; padding: 20px; text-align: center; border-top: 1px solid #e9ecef; }" +
                    ".footer p { color: #6c757d; font-size: 12px; margin: 5px 0; }" +
                    ".contact-info { margin: 15px 0; }" +
                    ".contact-info a { color: #0080FF; text-decoration: none; }" +
                "</style>" +
            "</head>" +
            "<body>" +
                "<div class=\"container\">" +
                    "<!-- Header -->" +
                    "<div class=\"header\">" +
                        "<h1>🍽️ LiteFlow Restaurant</h1>" +
                        "<p>Where Every Meal Tells a Story</p>" +
                    "</div>" +
                    
                    "<!-- Content -->" +
                    "<div class=\"content\">" +
                        "<p class=\"greeting\">Xin chào <strong>" + customerName + "</strong>,</p>" +
                        
                        "<p>Cảm ơn quý khách đã chọn <strong>LiteFlow Restaurant</strong>! Chúng tôi rất vui được phục vụ quý khách.</p>" +
                        
                        "<!-- Success Badge -->" +
                        "<div class=\"success-badge\">" +
                            "<h2>✅ Đặt Bàn Thành Công</h2>" +
                            "<p>Mã đặt bàn của quý khách:</p>" +
                            "<div class=\"code\">" + reservationCode + "</div>" +
                        "</div>" +
                        
                        "<!-- Reservation Details -->" +
                        "<div class=\"details-box\">" +
                            "<h3 style=\"margin-top: 0; color: #0080FF;\">📋 Thông Tin Đặt Bàn</h3>" +
                            "<div class=\"detail-row\">" +
                                "<span class=\"detail-label\">👤 Tên khách hàng:</span>" +
                                "<span class=\"detail-value\">" + customerName + "</span>" +
                            "</div>" +
                            "<div class=\"detail-row\">" +
                                "<span class=\"detail-label\">📅 Thời gian đến:</span>" +
                                "<span class=\"detail-value\">" + arrivalTime + "</span>" +
                            "</div>" +
                            "<div class=\"detail-row\">" +
                                "<span class=\"detail-label\">👥 Số lượng khách:</span>" +
                                "<span class=\"detail-value\">" + numberOfGuests + " người</span>" +
                            "</div>" +
                            (tableName != null && !tableName.isEmpty() ? 
                                "<div class=\"detail-row\">" +
                                    "<span class=\"detail-label\">🪑 Bàn:</span>" +
                                    "<span class=\"detail-value\">" + tableName + "</span>" +
                                "</div>" : "") +
                            "" +
                        "</div>" +
                        
                        "<!-- Pre-ordered Items -->" +
                        (preOrderedItems != null && !preOrderedItems.isEmpty() ?
                            "<div class=\"items-section\">" +
                                "<div class=\"items-title\">🍴 Món Đặt Trước:</div>" +
                                preOrderedItems +
                            "</div>" : "") +
                        
                        "<!-- Important Note -->" +
                        "<div class=\"important-note\">" +
                            "<strong>⚠️ Lưu Ý Quan Trọng:</strong>" +
                            "<ul style=\"margin: 10px 0; padding-left: 20px;\">" +
                                "<li>Vui lòng đến <strong>trước giờ đặt 5-10 phút</strong> để check-in.</li>" +
                                "<li>Nếu quý khách <strong>đến trễ quá 30 phút</strong>, đặt bàn có thể bị hủy tự động.</li>" +
                                "<li>Nếu có thay đổi, vui lòng liên hệ chúng tôi trước <strong>ít nhất 2 giờ</strong>.</li>" +
                                "<li>Mang theo <strong>mã đặt bàn</strong> khi đến nhà hàng.</li>" +
                            "</ul>" +
                        "</div>" +
                        
                        "<p>Nếu quý khách cần hỗ trợ hoặc thay đổi thông tin đặt bàn, vui lòng liên hệ chúng tôi qua:</p>" +
                        "<div class=\"contact-info\">" +
                            "📞 Hotline: <a href=\"tel:1900-1234\">1900-1234</a><br>" +
                            "📧 Email: <a href=\"mailto:reservation@liteflow.com\">reservation@liteflow.com</a>" +
                        "</div>" +
                        
                        "<p style=\"margin-top: 20px;\">Chúng tôi rất mong được đón tiếp quý khách!</p>" +
                        "<p><strong>Trân trọng,</strong><br>Đội ngũ LiteFlow Restaurant 🍽️</p>" +
                    "</div>" +
                    
                    "<!-- Footer -->" +
                    "<div class=\"footer\">" +
                        "<p><strong>LiteFlow Restaurant</strong></p>" +
                        "<p>123 Nguyễn Huệ, Quận 1, TP.HCM</p>" +
                        "<p>Website: <a href=\"https://liteflow.com\">www.liteflow.com</a></p>" +
                        "<hr style=\"margin: 15px 0; border: none; border-top: 1px solid #dee2e6;\">" +
                        "<p style=\"font-size: 11px; color: #999;\">Đây là email tự động, vui lòng không trả lời email này.</p>" +
                        "<p style=\"font-size: 11px; color: #999;\">© 2025 LiteFlow Restaurant. All rights reserved.</p>" +
                    "</div>" +
                "</div>" +
            "</body>" +
            "</html>";

        message.setContent(html, "text/html; charset=UTF-8");

        Transport.send(message);
        LOG.info("✅ Reservation confirmation email sent to " + to + " - Code: " + reservationCode);
    }
}
