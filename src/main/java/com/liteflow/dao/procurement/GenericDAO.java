package com.liteflow.dao.procurement;

import com.liteflow.dao.BaseDAO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.List;

public abstract class GenericDAO<T, ID> extends BaseDAO<T, ID> {

    private final Class<T> clazz;
    protected GenericDAO(Class<T> clazz) { this.clazz = clazz; }

    @Override
    public boolean insert(T entity) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            System.out.println("GenericDAO.insert() - Inserting: " + entity.getClass().getSimpleName());
            tx.begin(); 
            em.persist(entity); 
            tx.commit();
            System.out.println("GenericDAO.insert() - SUCCESS for " + entity.getClass().getSimpleName());
            return true;
        } catch (Exception e) {
            System.err.println("❌ GenericDAO.insert() FAILED for " + entity.getClass().getSimpleName());
            System.err.println("ERROR: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            if (tx.isActive()) tx.rollback();
            return false;
        } finally { em.close(); }
    }

    @Override
    public boolean update(T entity) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            System.out.println("GenericDAO.update() - Updating: " + entity.getClass().getSimpleName());
            tx.begin();
            
            // CRITICAL: merge() returns managed entity and attaches detached entity to context
            em.merge(entity);
            
            // Force synchronization to database before commit
            em.flush();
            
            tx.commit();
            System.out.println("GenericDAO.update() - SUCCESS for " + entity.getClass().getSimpleName());
            return true;
        } catch (Exception e) {
            System.err.println("❌ GenericDAO.update() FAILED for " + entity.getClass().getSimpleName());
            System.err.println("ERROR: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            if (tx.isActive()) tx.rollback();
            return false;
        } finally { em.close(); }
    }

    @Override
    public boolean delete(ID id) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            T obj = em.find(clazz, id);
            if (obj != null) em.remove(obj);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            return false;
        } finally { em.close(); }
    }

    @Override
    public T findById(ID id) {
        EntityManager em = emf.createEntityManager();
        try { return em.find(clazz, id); }
        finally { em.close(); }
    }

    @Override
    public List<T> getAll() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createQuery("SELECT e FROM " + clazz.getSimpleName() + " e", clazz).getResultList();
        } finally { em.close(); }
    }
}
