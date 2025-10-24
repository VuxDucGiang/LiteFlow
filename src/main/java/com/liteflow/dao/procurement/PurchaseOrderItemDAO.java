package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.PurchaseOrderItem;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.UUID;

public class PurchaseOrderItemDAO extends GenericDAO<PurchaseOrderItem, Integer> {
    public PurchaseOrderItemDAO() { super(PurchaseOrderItem.class); }
    
    /**
     * Lấy tất cả items của một Purchase Order
     */
    public List<PurchaseOrderItem> findByPOID(UUID poid) {
        EntityManager em = emf.createEntityManager();
        try {
            TypedQuery<PurchaseOrderItem> query = em.createQuery(
                "SELECT p FROM PurchaseOrderItem p WHERE p.poid = :poid ORDER BY p.itemID",
                PurchaseOrderItem.class
            );
            query.setParameter("poid", poid);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return List.of();
        } finally {
            em.close();
        }
    }
}
