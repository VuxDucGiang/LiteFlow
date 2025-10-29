package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.PurchaseOrder;
import jakarta.persistence.EntityManager;
import java.util.List;
import java.util.UUID;

public class PurchaseOrderDAO extends GenericDAO<PurchaseOrder, UUID> {
    public PurchaseOrderDAO() { 
        super(PurchaseOrder.class); 
    }
    
    @Override
    public List<PurchaseOrder> getAll() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createQuery(
                "SELECT po FROM PurchaseOrder po ORDER BY po.createDate DESC", 
                PurchaseOrder.class
            ).getResultList();
        } finally {
            em.close();
        }
    }
}
