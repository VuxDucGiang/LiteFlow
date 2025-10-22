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
}
