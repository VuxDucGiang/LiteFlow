package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.PurchaseOrder;
import java.util.UUID;

public class PurchaseOrderDAO extends GenericDAO<PurchaseOrder, UUID> {
    public PurchaseOrderDAO() { super(PurchaseOrder.class); }
}
