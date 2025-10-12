/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.liteflow.model.inventory;

import jakarta.persistence.*;
import java.util.*;

@Entity
@jakarta.persistence.Table(name = "Inventory")
public class Inventory {

    @Id
    @Column(name = "InventoryID", columnDefinition = "uniqueidentifier")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID inventoryId;

    @Column(name = "StoreLocation", length = 100)
    private String storeLocation;

    public UUID getInventoryId() {
        return inventoryId;
    }

    public void setInventoryId(UUID inventoryId) {
        this.inventoryId = inventoryId;
    }

    public String getStoreLocation() {
        return storeLocation;
    }

    public void setStoreLocation(String storeLocation) {
        this.storeLocation = storeLocation;
    }

    
}
