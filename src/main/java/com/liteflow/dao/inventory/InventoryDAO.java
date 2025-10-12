package com.liteflow.dao.inventory;

import com.liteflow.dao.GenericDAO;
import com.liteflow.model.inventory.Inventory;

public class InventoryDAO extends GenericDAO<Inventory, String> {

    public InventoryDAO() {
        super(Inventory.class, String.class);
    }
}
