package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import com.liteflow.model.procurement.PurchaseOrderItem;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.UUID;

public class PurchaseOrderItemDAO extends GenericDAO<PurchaseOrderItem, Integer> {
    public PurchaseOrderItemDAO() { 
        super(PurchaseOrderItem.class); 
    }
    
    /**
     * Lấy tất cả items của một Purchase Order
     */
    public List<PurchaseOrderItem> findByPOID(UUID poid) {
        System.out.println("PurchaseOrderItemDAO.findByPOID() called with POID: " + poid);
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            System.out.println("EntityManager created, executing query...");
            
            TypedQuery<PurchaseOrderItem> query = em.createQuery(
                "SELECT p FROM PurchaseOrderItem p WHERE p.poid = :poid ORDER BY p.itemID",
                PurchaseOrderItem.class
            );
            query.setParameter("poid", poid);
            
            List<PurchaseOrderItem> results = query.getResultList();
            System.out.println("Query executed, found " + results.size() + " items");
            
            return results;
        } catch (Exception e) {
            System.err.println("ERROR in PurchaseOrderItemDAO.findByPOID(): " + e.getMessage());
            e.printStackTrace();
            return List.of();
        } finally {
            if (em != null) {
                em.close();
                System.out.println("EntityManager closed");
            }
        }
    }
}
