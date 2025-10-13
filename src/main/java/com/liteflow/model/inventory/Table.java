/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.liteflow.model.inventory;

import jakarta.persistence.*;
import java.util.*;

@Entity
@jakarta.persistence.Table(name = "Tables")
public class Table {

    @Id
    @Column(name = "TableID", columnDefinition = "uniqueidentifier")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID tableId;

    @ManyToOne
    @JoinColumn(name = "RoomID")
    private Room room;

    @Column(name = "TableNumber", nullable = false, length = 50)
    private String tableNumber;

    // @Column(name = "TableName", nullable = false, length = 100)
    // private String tableName;

    // @Column(name = "Capacity", nullable = false)
    // private Integer capacity = 4;

    @Column(name = "Status", length = 50)
    private String status = "Available";

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive = true;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "CreatedAt")
    private Date createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "UpdatedAt")
    private Date updatedAt;

    @OneToMany(mappedBy = "table", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<TableSession> tableSessions;

    public Table() {
        this.tableSessions = new ArrayList<>();
        this.status = "Available";
        this.isActive = true;
        // this.capacity = 4;
    }

    public UUID getTableId() {
        return tableId;
    }

    public void setTableId(UUID tableId) {
        this.tableId = tableId;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(String tableNumber) {
        this.tableNumber = tableNumber;
    }

    // public String getTableName() {
    //     return tableName;
    // }

    // public void setTableName(String tableName) {
    //     this.tableName = tableName;
    // }

    // public Integer getCapacity() {
    //     return capacity;
    // }

    // public void setCapacity(Integer capacity) {
    //     this.capacity = capacity;
    // }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<TableSession> getTableSessions() {
        return tableSessions;
    }

    public void setTableSessions(List<TableSession> tableSessions) {
        this.tableSessions = tableSessions;
    }

    public void addTableSession(TableSession tableSession) {
        if (tableSessions == null) {
            tableSessions = new ArrayList<>();
        }
        tableSessions.add(tableSession);
        tableSession.setTable(this);
    }

    public void removeTableSession(TableSession tableSession) {
        if (tableSessions != null) {
            tableSessions.remove(tableSession);
            tableSession.setTable(null);
        }
    }

    // Helper methods
    public boolean isAvailable() {
        return "Available".equals(status) && Boolean.TRUE.equals(isActive);
    }

    public boolean isOccupied() {
        return "Occupied".equals(status);
    }

    public boolean isReserved() {
        return "Reserved".equals(status);
    }

    public boolean isMaintenance() {
        return "Maintenance".equals(status);
    }
}
