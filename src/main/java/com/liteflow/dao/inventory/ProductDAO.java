package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.Product;

public class ProductDAO extends GenericDAO<Product, String> {

    public ProductDAO() {
        super(Product.class, String.class);
    }
}
