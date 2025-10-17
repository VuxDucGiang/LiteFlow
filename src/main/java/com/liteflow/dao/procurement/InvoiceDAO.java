package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.Invoice;
import java.util.UUID;

public class InvoiceDAO extends GenericDAO<Invoice, UUID> {
    public InvoiceDAO() { super(Invoice.class); }
}
