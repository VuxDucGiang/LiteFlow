/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.liteflow.model.inventory;

import jakarta.persistence.*;
import java.util.*;

@Entity
@jakarta.persistence.Table(name = "ProductsCategories")
public class ProductCategory {

    @Id
    @Column(name = "ProductCategoryID", columnDefinition = "uniqueidentifier")
    private UUID productCategoryId;

    @ManyToOne
    @JoinColumn(name = "ProductID", nullable = false)
    private Product product;

    @ManyToOne
    @JoinColumn(name = "CategoryID", nullable = false)
    private Category category;

    public UUID getProductCategoryId() {
        return productCategoryId;
    }

    public void setProductCategoryId(UUID productCategoryId) {
        this.productCategoryId = productCategoryId;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

 
}
