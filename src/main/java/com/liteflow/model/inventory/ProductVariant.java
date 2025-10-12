/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.liteflow.model.inventory;

import jakarta.persistence.*;
import java.util.*;

@Entity
@jakarta.persistence.Table(name = "ProductVariant")
public class ProductVariant {

    @Id
    @Column(name = "ProductVariantID", columnDefinition = "uniqueidentifier")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID productVariantId;

    @ManyToOne
    @JoinColumn(name = "ProductID", nullable = false)
    private Product product;

    @Column(name = "Size", length = 50, nullable = false)
    private String size;

    @Column(name = "OriginalPrice", nullable = false)
    private Double originalPrice;

    @Column(name = "Price", nullable = false)
    private Double price;

    @Column(name = "IsDeleted")
    private Boolean isDeleted;

    @Column(name = "DiscountPrice")
    private Double discountPrice;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "DiscountExpiry")
    private Date discountExpiry;

    public UUID getProductVariantId() {
        return productVariantId;
    }

    public void setProductVariantId(UUID productVariantId) {
        this.productVariantId = productVariantId;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public Double getOriginalPrice() {
        return originalPrice;
    }

    public void setOriginalPrice(Double originalPrice) {
        this.originalPrice = originalPrice;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }

    public Boolean getIsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(Boolean isDeleted) {
        this.isDeleted = isDeleted;
    }

    public Double getDiscountPrice() {
        return discountPrice;
    }

    public void setDiscountPrice(Double discountPrice) {
        this.discountPrice = discountPrice;
    }

    public Date getDiscountExpiry() {
        return discountExpiry;
    }

    public void setDiscountExpiry(Date discountExpiry) {
        this.discountExpiry = discountExpiry;
    }


}
