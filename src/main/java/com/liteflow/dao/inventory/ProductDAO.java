package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.Product;
import java.util.UUID;

public class ProductDAO extends GenericDAO<Product, UUID> {

    public ProductDAO() {
        super(Product.class, UUID.class);
    }
}
