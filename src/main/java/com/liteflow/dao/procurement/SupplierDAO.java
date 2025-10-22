package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.Supplier;
import java.util.UUID;

public class SupplierDAO extends GenericDAO<Supplier, UUID> {
    public SupplierDAO() { super(Supplier.class); }
}
