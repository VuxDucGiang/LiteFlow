package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.ProductStock;
import java.util.UUID;

public class ProductStockDAO extends GenericDAO<ProductStock, UUID> {

    public ProductStockDAO() {
        super(ProductStock.class, UUID.class);
    }
}
