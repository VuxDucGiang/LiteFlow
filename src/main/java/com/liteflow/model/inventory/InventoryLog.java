/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.liteflow.model.inventory;

import jakarta.persistence.*;
import java.util.*;

@Entity
@jakarta.persistence.Table(name = "InventoryLogs")
public class InventoryLog {

    @Id
    @Column(name = "LogID", columnDefinition = "uniqueidentifier")
    private UUID logId;

    @ManyToOne
    @JoinColumn(name = "ProductVariantID", nullable = false)
    private ProductVariant productVariant;

    @Column(name = "ActionType", length = 10, nullable = false)
    private String actionType; // IN, OUT, ADJUST

    @Column(name = "QuantityChanged", nullable = false)
    private int quantityChanged;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "ActionDate")
    private Date actionDate;

    @Column(name = "StoreLocation", length = 100)
    private String storeLocation;

    public UUID getLogId() {
        return logId;
    }

    public void setLogId(UUID logId) {
        this.logId = logId;
    }

    public ProductVariant getProductVariant() {
        return productVariant;
    }

    public void setProductVariant(ProductVariant productVariant) {
        this.productVariant = productVariant;
    }

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public int getQuantityChanged() {
        return quantityChanged;
    }

    public void setQuantityChanged(int quantityChanged) {
        this.quantityChanged = quantityChanged;
    }

    public Date getActionDate() {
        return actionDate;
    }

    public void setActionDate(Date actionDate) {
        this.actionDate = actionDate;
    }

    public String getStoreLocation() {
        return storeLocation;
    }

    public void setStoreLocation(String storeLocation) {
        this.storeLocation = storeLocation;
    }

}
