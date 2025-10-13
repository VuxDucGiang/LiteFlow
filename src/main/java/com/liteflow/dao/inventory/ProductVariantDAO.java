package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.ProductVariant;
import java.util.UUID;

public class ProductVariantDAO extends GenericDAO<ProductVariant, UUID> {

    public ProductVariantDAO() {
        super(ProductVariant.class, UUID.class);
    }
}
