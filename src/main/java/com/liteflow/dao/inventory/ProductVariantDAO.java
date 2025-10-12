package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.ProductVariant;

public class ProductVariantDAO extends GenericDAO<ProductVariant, String> {

    public ProductVariantDAO() {
        super(ProductVariant.class, String.class);
    }
}
