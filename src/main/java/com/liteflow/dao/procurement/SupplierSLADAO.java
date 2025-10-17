package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.SupplierSLA;
import java.util.UUID;

public class SupplierSLADAO extends GenericDAO<SupplierSLA, UUID> {
    public SupplierSLADAO() { super(SupplierSLA.class); }
}
