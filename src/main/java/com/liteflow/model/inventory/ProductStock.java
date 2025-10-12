/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.liteflow.model.inventory;

import jakarta.persistence.*;
import java.util.*;

@Entity
@jakarta.persistence.Table(name = "ProductStock")
public class ProductStock {

    @Id
    @Column(name = "ProductStockID", columnDefinition = "uniqueidentifier")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID productStockId;

    @ManyToOne
    @JoinColumn(name = "ProductVariantID", nullable = false)
    private ProductVariant productVariant;

    @ManyToOne
    @JoinColumn(name = "InventoryID", nullable = false)
    private Inventory inventory;

    @Column(name = "Amount", nullable = false)
    private int amount;

    public UUID getProductStockId() {
        return productStockId;
    }

    public void setProductStockId(UUID productStockId) {
        this.productStockId = productStockId;
    }

    public ProductVariant getProductVariant() {
        return productVariant;
    }

    public void setProductVariant(ProductVariant productVariant) {
        this.productVariant = productVariant;
    }

    public Inventory getInventory() {
        return inventory;
    }

    public void setInventory(Inventory inventory) {
        this.inventory = inventory;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }


}
