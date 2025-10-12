package com.liteflow.model.auth;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * UserSession: Lưu session (JWT, device, IP, thời gian hết hạn).
 */
@Entity
@Table(name = "UserSessions") // ✅ sửa tên đúng với DB
public class UserSession implements Serializable {

    @Id
    @Column(name = "SessionID", columnDefinition = "uniqueidentifier")
    private UUID sessionId;

    @Column(name = "UserID", columnDefinition = "uniqueidentifier", nullable = false)
    private UUID userId;

    @Column(name = "JWT", length = 2000)
    private String jwt;

    @Column(name = "DeviceInfo", length = 500)
    private String deviceInfo;

    @Column(name = "IPAddress", length = 100)
    private String ipAddress;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "ExpiresAt")
    private LocalDateTime expiresAt;

    @Column(name = "Revoked", nullable = false)
    private boolean revoked = false;

    @Column(name = "Last2faVerifiedAt")
    private LocalDateTime last2faVerifiedAt;

    @PrePersist
    protected void onCreate() {
        if (sessionId == null) {
            sessionId = UUID.randomUUID();
        }
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    // Getters & Setters
    public UUID getSessionId() {
        return sessionId;
    }

    public void setSessionId(UUID sessionId) {
        this.sessionId = sessionId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public String getJwt() {
        return jwt;
    }

    public void setJwt(String jwt) {
        this.jwt = jwt;
    }

    public String getDeviceInfo() {
        return deviceInfo;
    }

    public void setDeviceInfo(String deviceInfo) {
        this.deviceInfo = deviceInfo;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isRevoked() {
        return revoked;
    }

    public void setRevoked(boolean revoked) {
        this.revoked = revoked;
    }

    public LocalDateTime getLast2faVerifiedAt() {
        return last2faVerifiedAt;
    }

    public void setLast2faVerifiedAt(LocalDateTime last2faVerifiedAt) {
        this.last2faVerifiedAt = last2faVerifiedAt;
    }
}
