package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.PurchaseOrderItem;

public class PurchaseOrderItemDAO extends GenericDAO<PurchaseOrderItem, Integer> {
    public PurchaseOrderItemDAO() { super(PurchaseOrderItem.class); }
}
