package com.liteflow.helpers.base;

import com.liteflow.dao.BaseDAO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import org.junit.jupiter.api.*;

/**
 * Base class for all integration tests in LiteFlow.
 * Provides common setup/teardown for JPA EntityManager with H2 in-memory database.
 * 
 * Features:
 * - Automatic EntityManagerFactory creation/cleanup
 * - Per-test EntityManager with transaction management
 * - Automatic rollback after each test for isolation
 * 
 * Usage:
 * <pre>
 * public class MyServiceIntegrationTest extends IntegrationTestBase {
 *     @Test
 *     public void testSomething() {
 *         // Use 'em' (EntityManager) directly
 *         User user = TestDataBuilder.buildUser("test@test.com", "USER");
 *         em.persist(user);
 *         em.flush();
 *         
 *         // Assertions...
 *     }
 * }
 * </pre>
 */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public abstract class IntegrationTestBase {
    
    /**
     * Shared EntityManagerFactory for all tests in the class.
     * Created once before all tests, closed after all tests.
     */
    protected static EntityManagerFactory emf;
    
    /**
     * Per-test EntityManager.
     * Created before each test, closed after each test.
     */
    protected EntityManager em;
    
    /**
     * Setup EntityManagerFactory once before all tests in the class.
     * Uses test-persistence.xml configuration with H2 in-memory database.
     */
    private static final String[] TABLES_TO_TRUNCATE = {
            "AuditLogs",
            "OtpTokens",
            "UserSessions",
            "UserRoles",
            "Roles",
            "Users"
    };

    @BeforeAll
    public static void setUpClass() {
        emf = Persistence.createEntityManagerFactory("LiteFlowTestPU");
        BaseDAO.emf = emf;
    }
    
    /**
     * Cleanup EntityManagerFactory after all tests in the class.
     */
    @AfterAll
    public static void tearDownClass() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
    
    /**
     * Setup EntityManager and begin transaction before each test.
     * This ensures each test starts with a clean database state.
     */
    @BeforeEach
    public void setUp() {
        clearDatabase();
        em = emf.createEntityManager();
        em.getTransaction().begin();
    }
    
    /**
     * Teardown EntityManager after each test.
     * Automatically rolls back any uncommitted transaction to ensure test isolation.
     */
    @AfterEach
    public void tearDown() {
        if (em != null) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            if (em.isOpen()) {
                em.close();
            }
        }
    }
    
    /**
     * Flush and clear the persistence context.
     * Useful when you want to force SQL execution and clear the cache.
     */
    protected void flushAndClear() {
        em.flush();
        em.clear();
    }
    
    /**
     * Commit the current transaction (use sparingly in tests).
     * Note: Transaction will still be rolled back in tearDown() for isolation.
     */
    protected void commit() {
        em.getTransaction().commit();
        em.getTransaction().begin();
    }

    private void clearDatabase() {
        EntityManager cleanupEm = emf.createEntityManager();
        try {
            var tx = cleanupEm.getTransaction();
            tx.begin();
            cleanupEm.createNativeQuery("SET REFERENTIAL_INTEGRITY FALSE").executeUpdate();
            for (String table : TABLES_TO_TRUNCATE) {
                cleanupEm.createNativeQuery("TRUNCATE TABLE " + table).executeUpdate();
            }
            cleanupEm.createNativeQuery("SET REFERENTIAL_INTEGRITY TRUE").executeUpdate();
            tx.commit();
        } catch (RuntimeException ex) {
            var tx = cleanupEm.getTransaction();
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            cleanupEm.close();
        }
    }
}

