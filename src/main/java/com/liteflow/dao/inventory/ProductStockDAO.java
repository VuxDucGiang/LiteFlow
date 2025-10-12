package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.ProductStock;

public class ProductStockDAO extends GenericDAO<ProductStock, String> {

    public ProductStockDAO() {
        super(ProductStock.class, String.class);
    }
}
