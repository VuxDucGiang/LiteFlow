package com.liteflow.service.procurement;

import com.liteflow.dao.procurement.*;
import com.liteflow.model.procurement.*;
import java.time.LocalDateTime;
import java.util.*;

/**
 * Dịch vụ nghiệp vụ Procurement:
 * - Quản lý nhà cung cấp & SLA
 * - Lập / duyệt / nhận hàng / đối chiếu hóa đơn
 */
public class ProcurementService {

    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final SupplierSLADAO slaDAO = new SupplierSLADAO();
    private final PurchaseOrderDAO poDAO = new PurchaseOrderDAO();
    private final PurchaseOrderItemDAO itemDAO = new PurchaseOrderItemDAO();
    private final GoodsReceiptDAO grDAO = new GoodsReceiptDAO();
    private final GoodsReceiptItemDAO grItemDAO = new GoodsReceiptItemDAO();
    private final InvoiceDAO invDAO = new InvoiceDAO();
    private final InvoiceItemDAO invItemDAO = new InvoiceItemDAO();
    private final InvoiceMatchingService matchingService = new InvoiceMatchingService();

    /* ============================================================
       1. QUẢN LÝ NHÀ CUNG CẤP & SLA
    ============================================================ */
    public UUID createSupplier(String name, UUID createdBy, String email) {
        Supplier s = new Supplier();
        s.setName(name);
        s.setCreatedBy(createdBy);
        s.setEmail(email);
        supplierDAO.insert(s);

        SupplierSLA sla = new SupplierSLA();
        sla.setSupplierID(s.getSupplierID());
        slaDAO.insert(sla);

        return s.getSupplierID();
    }

    public List<Supplier> getAllSuppliers() { return supplierDAO.getAll(); }
    
    public Supplier getSupplierById(UUID supplierID) {
        return supplierDAO.findById(supplierID);
    }
    
    public boolean updateSupplier(Supplier supplier) {
        return supplierDAO.update(supplier);
    }

    public boolean updateSupplierRating(UUID supplierID, double rating) {
        Supplier s = supplierDAO.findById(supplierID);
        if (s == null) return false;
        s.setRating(rating);
        return supplierDAO.update(s);
    }

    /* ============================================================
       2. LẬP ĐƠN ĐẶT HÀNG (PO)
    ============================================================ */
    public UUID createPurchaseOrder(UUID supplierID, UUID createdBy, LocalDateTime expectedDate, String notes, List<PurchaseOrderItem> items) {
        System.out.println("=== ProcurementService.createPurchaseOrder START ===");
        System.out.println("SupplierID: " + supplierID);
        System.out.println("CreatedBy: " + createdBy);
        System.out.println("ExpectedDate: " + expectedDate);
        System.out.println("Items count: " + items.size());
        
        PurchaseOrder po = new PurchaseOrder();
        po.setSupplierID(supplierID);
        po.setCreatedBy(createdBy);
        po.setExpectedDelivery(expectedDate);
        po.setNotes(notes);
        po.setStatus("PENDING");
        
        // Insert PO and check result
        boolean poInserted = poDAO.insert(po);
        if (!poInserted) {
            System.err.println("❌ FAILED to insert PurchaseOrder!");
            throw new RuntimeException("Không thể tạo đơn hàng. Vui lòng kiểm tra dữ liệu và thử lại.");
        }
        System.out.println("✅ PurchaseOrder inserted successfully. POID: " + po.getPoid());

        // Insert items and calculate total
        double total = 0;
        for (int i = 0; i < items.size(); i++) {
            PurchaseOrderItem it = items.get(i);
            it.setPoid(po.getPoid());
            total += it.getQuantity() * it.getUnitPrice();
            
            boolean itemInserted = itemDAO.insert(it);
            if (!itemInserted) {
                System.err.println("❌ FAILED to insert PurchaseOrderItem #" + (i+1));
                throw new RuntimeException("Không thể thêm sản phẩm vào đơn hàng. Vui lòng thử lại.");
            }
            System.out.println("✅ Item #" + (i+1) + " inserted: " + it.getItemName());
        }
        
        // Update total amount
        po.setTotalAmount(total);
        boolean poUpdated = poDAO.update(po);
        if (!poUpdated) {
            System.err.println("❌ FAILED to update PurchaseOrder total amount!");
            throw new RuntimeException("Không thể cập nhật tổng tiền. Vui lòng thử lại.");
        }
        System.out.println("✅ PurchaseOrder total updated: " + total);
        System.out.println("=== ProcurementService.createPurchaseOrder END - SUCCESS ===");
        
        // Send Telegram notification for new PO (async) - notify all users with Telegram enabled
        try {
            POAlertService poAlertService = new POAlertService();
            poAlertService.sendPOCreationNotification(po.getPoid(), null); // null = notify all users with Telegram enabled
            System.out.println("🔔 PO notification check initiated for POID: " + po.getPoid());
        } catch (Exception e) {
            // Don't fail PO creation if notification fails
            System.err.println("⚠️ Warning: PO notification check failed (PO creation still successful): " + e.getMessage());
            e.printStackTrace();
        }
        
        return po.getPoid();
    }

    public List<PurchaseOrder> getAllPOs() { return poDAO.getAll(); }
    
    public List<PurchaseOrderItem> getPOItems(UUID poid) {
        System.out.println("ProcurementService.getPOItems() called with POID: " + poid);
        List<PurchaseOrderItem> items = itemDAO.findByPOID(poid);
        System.out.println("DAO returned " + (items != null ? items.size() : "null") + " items");
        if (items != null && !items.isEmpty()) {
            items.forEach(item -> {
                System.out.println("  - Item: " + item.getItemName() + " (Qty: " + item.getQuantity() + ", Price: " + item.getUnitPrice() + ")");
            });
        }
        return items;
    }
    
    /**
     * Tính tổng số lượng đã nhận cho mỗi item trong PO từ tất cả các GoodsReceiptItems
     * @param poid PO ID
     * @return Map với key là itemName, value là tổng số lượng đã nhận (chỉ tính hàng OK)
     */
    public Map<String, Integer> getTotalReceivedQuantities(UUID poid) {
        Map<String, Integer> receivedMap = new HashMap<>();
        jakarta.persistence.EntityManager em = null;
        try {
            em = com.liteflow.dao.BaseDAO.emf.createEntityManager();
            
            // First, check if there are any GoodsReceipts for this PO
            jakarta.persistence.Query receiptsQuery = em.createQuery(
                "SELECT gr.receiptID FROM com.liteflow.model.procurement.GoodsReceipt gr WHERE gr.poid = :poid");
            receiptsQuery.setParameter("poid", poid);
            @SuppressWarnings("unchecked")
            List<UUID> receiptIDs = receiptsQuery.getResultList();
            
            System.out.println("📊 Found " + receiptIDs.size() + " GoodsReceipt(s) for PO " + poid);
            
            if (receiptIDs.isEmpty()) {
                System.out.println("📊 No receipts found for PO " + poid + ", returning empty map");
                return receivedMap;
            }
            
            // Query tổng số lượng đã nhận cho mỗi POItemID (chỉ tính hàng OK)
            String jpql = "SELECT gri.poItemID, SUM(gri.receivedQuantity) " +
                         "FROM com.liteflow.model.procurement.GoodsReceiptItem gri " +
                         "WHERE gri.receiptID IN :receiptIDs " +
                         "AND gri.qualityStatus = 'OK' " +
                         "GROUP BY gri.poItemID";
            
            jakarta.persistence.Query query = em.createQuery(jpql);
            query.setParameter("receiptIDs", receiptIDs);
            
            @SuppressWarnings("unchecked")
            List<Object[]> results = query.getResultList();
            
            System.out.println("📊 Query returned " + results.size() + " rows for PO " + poid);
            
            // Map POItemID -> tổng số lượng đã nhận
            Map<Integer, Integer> poItemReceivedMap = new HashMap<>();
            for (Object[] row : results) {
                Integer poItemID = (Integer) row[0];
                Long sumReceived = ((Number) row[1]).longValue();
                poItemReceivedMap.put(poItemID, sumReceived.intValue());
                System.out.println("📊 POItemID " + poItemID + " has total received: " + sumReceived);
            }
            
            // Lấy danh sách POItems để map POItemID -> ItemName
            jakarta.persistence.Query poItemsQuery = em.createQuery(
                "SELECT poi FROM com.liteflow.model.procurement.PurchaseOrderItem poi WHERE poi.poid = :poid");
            poItemsQuery.setParameter("poid", poid);
            @SuppressWarnings("unchecked")
            List<PurchaseOrderItem> poItems = poItemsQuery.getResultList();
            
            for (PurchaseOrderItem poi : poItems) {
                Integer totalReceived = poItemReceivedMap.getOrDefault(poi.getItemID(), 0);
                receivedMap.put(poi.getItemName(), totalReceived);
                System.out.println("📊 Item " + poi.getItemName() + " (POItemID: " + poi.getItemID() + ") has total received: " + totalReceived);
            }
            
            System.out.println("📊 Total received quantities for PO " + poid + ": " + receivedMap);
            
        } catch (Exception e) {
            System.err.println("❌ Error calculating received quantities: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        
        return receivedMap;
    }
    
    public List<PurchaseOrder> getPOsPendingApproval() {
        return poDAO.getAll().stream()
                .filter(po -> "PENDING".equals(po.getStatus()))
                .collect(java.util.stream.Collectors.toList());
    }

    /* ============================================================
       3. DUYỆT PO (1 cấp hoặc nhiều cấp)
    ============================================================ */
    public boolean approvePO(UUID poid, UUID approver, int level) {
        PurchaseOrder po = poDAO.findById(poid);
        if (po == null || !"PENDING".equals(po.getStatus())) return false;
        po.setApprovalLevel(level);
        po.setApprovedBy(approver);
        po.setApprovedAt(LocalDateTime.now());
        po.setStatus("APPROVED");
        boolean updated = poDAO.update(po);
        
        // Send Telegram notification for status update (async)
        if (updated) {
            try {
                POAlertService poAlertService = new POAlertService();
                poAlertService.sendPOStatusUpdateNotification(poid, "APPROVED", approver);
                System.out.println("🔔 PO approval notification check initiated for POID: " + poid);
            } catch (Exception e) {
                // Don't fail approval if notification fails
                System.err.println("⚠️ Warning: PO approval notification failed (approval still successful): " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        return updated;
    }

    public boolean rejectPO(UUID poid, UUID approver, String reason) {
        PurchaseOrder po = poDAO.findById(poid);
        if (po == null) return false;
        po.setApprovedBy(approver);
        po.setNotes(reason);
        po.setStatus("REJECTED");
        boolean updated = poDAO.update(po);
        
        // Send Telegram notification for status update (async)
        if (updated) {
            try {
                POAlertService poAlertService = new POAlertService();
                poAlertService.sendPOStatusUpdateNotification(poid, "REJECTED", approver);
                System.out.println("🔔 PO rejection notification check initiated for POID: " + poid);
            } catch (Exception e) {
                // Don't fail rejection if notification fails
                System.err.println("⚠️ Warning: PO rejection notification failed (rejection still successful): " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        return updated;
    }

    /* ============================================================
       4. NHẬN HÀNG MỘT PHẦN (Partial Receiving)
    ============================================================ */
    public UUID receivePartial(UUID poid, UUID receivedBy, String note) {
        PurchaseOrder po = poDAO.findById(poid);
        if (po == null) return null;
        GoodsReceipt gr = new GoodsReceipt();
        gr.setPoid(poid);
        gr.setReceivedBy(receivedBy);
        gr.setNotes(note);
        gr.setStatus("PARTIAL");
        grDAO.insert(gr);
        po.setStatus("RECEIVING");
        poDAO.update(po);
        return gr.getReceiptID();
    }

    /**
     * Nhận hàng với chi tiết từng sản phẩm
     * @param poid PO ID
     * @param receivedBy User ID người nhận
     * @param items List of items với receivedQuantity và qualityStatus
     * @param notes Ghi chú
     * @return Receipt ID
     */
    public UUID receiveGoods(UUID poid, UUID receivedBy, List<Map<String, Object>> items, String notes) {
        jakarta.persistence.EntityManager em = null;
        try {
            em = com.liteflow.dao.BaseDAO.emf.createEntityManager();
            em.getTransaction().begin();
            
            System.out.println("=== receiveGoods START ===");
            System.out.println("POID: " + poid);
            System.out.println("ReceivedBy: " + receivedBy);
            System.out.println("Items count: " + items.size());
            
            // Get PO using the same EntityManager to keep it managed
            PurchaseOrder po = em.find(PurchaseOrder.class, poid);
            if (po == null) {
                throw new RuntimeException("Purchase Order not found: " + poid);
            }
            System.out.println("✅ Found PO with status: " + po.getStatus());
            
            // Get PO items using query with same EM
            jakarta.persistence.Query poItemsQuery = em.createQuery(
                "SELECT poi FROM com.liteflow.model.procurement.PurchaseOrderItem poi WHERE poi.poid = :poid");
            poItemsQuery.setParameter("poid", poid);
            @SuppressWarnings("unchecked")
            List<PurchaseOrderItem> poItems = poItemsQuery.getResultList();
            if (poItems.isEmpty()) {
                throw new RuntimeException("Purchase Order has no items");
            }
            
            // Initialize notes string for collecting over-receipt warnings
            StringBuilder receiptNotes = new StringBuilder();
            if (notes != null && !notes.trim().isEmpty()) {
                receiptNotes.append(notes);
            }
            
            // Create GoodsReceipt
            GoodsReceipt gr = new GoodsReceipt();
            gr.setPoid(poid);
            gr.setReceivedBy(receivedBy);
            gr.setNotes(notes); // Set initial notes, will update later if there are over-receipt warnings
            
            // CRITICAL: Persist GoodsReceipt FIRST to generate ReceiptID via @PrePersist
            em.persist(gr);
            em.flush(); // Force flush to get the generated ReceiptID
            UUID receiptID = gr.getReceiptID();
            System.out.println("✅ GoodsReceipt created with ReceiptID: " + receiptID);
            
            // Determine status: FULL if all items received fully, otherwise PARTIAL
            boolean allFull = true;
            int totalReceived = 0;
            int totalOrdered = 0;
            
            // Create GoodsReceiptItems and update inventory
            com.liteflow.dao.inventory.InventoryDAO inventoryDAO = new com.liteflow.dao.inventory.InventoryDAO();
            
            // Get default inventory (usually ID = 1 or first one)
            com.liteflow.model.inventory.Inventory defaultInventory = null;
            try {
                List<com.liteflow.model.inventory.Inventory> inventories = inventoryDAO.getAll();
                if (!inventories.isEmpty()) {
                    defaultInventory = inventories.get(0);
                    System.out.println("Using default inventory: " + defaultInventory.getInventoryId());
                }
            } catch (Exception e) {
                System.err.println("⚠️ Warning: Could not get default inventory: " + e.getMessage());
            }
            
            // Get already received quantities if this is a continuing receive
            Map<String, Integer> alreadyReceivedMap = new HashMap<>();
            if ("RECEIVING".equals(po.getStatus())) {
                // Query total received quantities from database
                String receivedJpql = "SELECT gri.poItemID, SUM(gri.receivedQuantity) " +
                                     "FROM com.liteflow.model.procurement.GoodsReceiptItem gri " +
                                     "WHERE gri.receiptID IN " +
                                     "(SELECT gr.receiptID FROM com.liteflow.model.procurement.GoodsReceipt gr WHERE gr.poid = :poid) " +
                                     "AND gri.qualityStatus = 'OK' " +
                                     "GROUP BY gri.poItemID";
                jakarta.persistence.Query receivedQuery = em.createQuery(receivedJpql);
                receivedQuery.setParameter("poid", poid);
                @SuppressWarnings("unchecked")
                List<Object[]> receivedResults = receivedQuery.getResultList();
                
                Map<Integer, Integer> poItemReceivedMap = new HashMap<>();
                for (Object[] row : receivedResults) {
                    Integer poItemID = (Integer) row[0];
                    Long sumReceived = ((Number) row[1]).longValue();
                    poItemReceivedMap.put(poItemID, sumReceived.intValue());
                }
                
                // Map POItemID -> ItemName
                for (PurchaseOrderItem poi : poItems) {
                    Integer alreadyReceivedQty = poItemReceivedMap.getOrDefault(poi.getItemID(), 0);
                    alreadyReceivedMap.put(poi.getItemName(), alreadyReceivedQty);
                }
                
                System.out.println("📊 Already received quantities: " + alreadyReceivedMap);
            }
            
            for (Map<String, Object> itemData : items) {
                String itemName = (String) itemData.get("itemName");
                Integer orderedQty = ((Number) itemData.get("orderedQuantity")).intValue();
                Integer receivedQty = ((Number) itemData.get("receivedQuantity")).intValue();
                String qualityStatus = (String) itemData.getOrDefault("qualityStatus", "OK");
                
                // Calculate total received (already + new)
                Integer alreadyReceived = alreadyReceivedMap.getOrDefault(itemName, 0);
                Integer totalReceivedForItem = alreadyReceived + receivedQty;
                
                totalOrdered += orderedQty;
                totalReceived += totalReceivedForItem;
                
                if (totalReceivedForItem < orderedQty) {
                    allFull = false;
                }
                
                // Find matching POItem
                PurchaseOrderItem poItem = null;
                for (PurchaseOrderItem poi : poItems) {
                    if (poi.getItemName().equals(itemName)) {
                        poItem = poi;
                        break;
                    }
                }
                
                if (poItem == null) {
                    System.err.println("⚠️ Warning: POItem not found for: " + itemName);
                    continue;
                }
                
                // Check for over-receipt (received more than ordered)
                Integer overReceipt = receivedQty > orderedQty ? receivedQty - orderedQty : 0;
                if (overReceipt > 0) {
                    double overPercent = (overReceipt.doubleValue() / orderedQty.doubleValue()) * 100.0;
                    System.out.println("⚠️ OVER-RECEIPT WARNING: " + itemName + 
                                     " - Ordered: " + orderedQty + 
                                     ", Received: " + receivedQty + 
                                     ", Over: +" + overReceipt + " (" + String.format("%.1f", overPercent) + "%)");
                    
                    // Log to receipt notes if significant over-receipt (>10%)
                    if (overPercent > 10) {
                        if (receiptNotes.length() > 0) {
                            receiptNotes.append("\n");
                        }
                        receiptNotes.append("[OVER-RECEIPT] ").append(itemName)
                                   .append(": Đặt ").append(orderedQty)
                                   .append(", Nhận ").append(receivedQty)
                                   .append(" (+").append(overReceipt)
                                   .append(", ").append(String.format("%.1f", overPercent)).append("%)");
                    }
                }
                
                // Create GoodsReceiptItem with the generated ReceiptID
                GoodsReceiptItem gri = new GoodsReceiptItem();
                gri.setReceiptID(receiptID); // Use the generated ReceiptID from flush
                gri.setPoItemID(poItem.getItemID());
                gri.setProductName(itemName);
                gri.setOrderedQuantity(orderedQty);
                gri.setReceivedQuantity(receivedQty);
                gri.setUnitPrice(poItem.getUnitPrice());
                gri.setQualityStatus(qualityStatus);
                
                // Set discrepancy reason if over-receipt is significant (>10%)
                if (overReceipt > 0 && (overReceipt.doubleValue() / orderedQty.doubleValue()) > 0.1) {
                    String reason = "Nhận vượt số lượng đặt: +" + overReceipt + " đơn vị (" + 
                                   String.format("%.1f", (overReceipt.doubleValue() / orderedQty.doubleValue()) * 100.0) + "%)";
                    gri.setDiscrepancyReason(reason);
                    System.out.println("📝 Set discrepancy reason for " + itemName + ": " + reason);
                }
                
                // Calculate defective quantity if quality is not OK
                if (!"OK".equals(qualityStatus)) {
                    gri.setDefectiveQuantity(receivedQty);
                }
                
                // Insert GoodsReceiptItem using same EM
                em.persist(gri);
                System.out.println("✅ GoodsReceiptItem created for " + itemName + ": " + receivedQty + 
                                 " (ReceiptID: " + receiptID + ", POItemID: " + poItem.getItemID() + ")");
                
                // Update inventory if quality is OK and we have default inventory
                if ("OK".equals(qualityStatus) && defaultInventory != null && receivedQty > 0) {
                    try {
                        // Find product by name using EntityManager query
                        jakarta.persistence.Query productQuery = em.createQuery(
                            "SELECT p FROM com.liteflow.model.inventory.Product p WHERE LOWER(p.name) = LOWER(:name) AND (p.isDeleted = false OR p.isDeleted IS NULL)");
                        productQuery.setParameter("name", itemName);
                        @SuppressWarnings("unchecked")
                        List<com.liteflow.model.inventory.Product> products = productQuery.getResultList();
                        
                        if (!products.isEmpty()) {
                            com.liteflow.model.inventory.Product product = products.get(0);
                            
                            // Get first variant using query
                            jakarta.persistence.Query variantQuery = em.createQuery(
                                "SELECT pv FROM com.liteflow.model.inventory.ProductVariant pv WHERE pv.product.productId = :productId AND (pv.isDeleted = false OR pv.isDeleted IS NULL)");
                            variantQuery.setParameter("productId", product.getProductId());
                            variantQuery.setMaxResults(1);
                            @SuppressWarnings("unchecked")
                            List<com.liteflow.model.inventory.ProductVariant> variants = variantQuery.getResultList();
                            
                            if (!variants.isEmpty()) {
                                com.liteflow.model.inventory.ProductVariant variant = variants.get(0);
                                
                                // Find or create ProductStock using query
                                jakarta.persistence.Query stockQuery = em.createQuery(
                                    "SELECT ps FROM com.liteflow.model.inventory.ProductStock ps WHERE ps.productVariant.productVariantId = :variantId AND ps.inventory.inventoryId = :inventoryId");
                                stockQuery.setParameter("variantId", variant.getProductVariantId());
                                stockQuery.setParameter("inventoryId", defaultInventory.getInventoryId());
                                @SuppressWarnings("unchecked")
                                List<com.liteflow.model.inventory.ProductStock> stocks = stockQuery.getResultList();
                                
                                com.liteflow.model.inventory.ProductStock stock;
                                if (stocks.isEmpty()) {
                                    // Create new ProductStock
                                    stock = new com.liteflow.model.inventory.ProductStock();
                                    stock.setProductVariant(variant);
                                    stock.setInventory(defaultInventory);
                                    stock.setAmount(receivedQty);
                                    em.persist(stock);
                                    System.out.println("✅ Created new ProductStock for " + itemName + " (+" + receivedQty + ")");
                                } else {
                                    // Update existing stock
                                    stock = stocks.get(0);
                                    int currentAmount = stock.getAmount() != null ? stock.getAmount() : 0;
                                    stock.setAmount(currentAmount + receivedQty);
                                    em.merge(stock);
                                    System.out.println("✅ Updated ProductStock for " + itemName + ": " + currentAmount + " -> " + (currentAmount + receivedQty));
                                }
                                
                                // Create InventoryLog
                                com.liteflow.model.inventory.InventoryLog log = new com.liteflow.model.inventory.InventoryLog();
                                log.setProductVariant(variant);
                                log.setActionType("Purchase Receipt");
                                log.setQuantityChanged(receivedQty);
                                log.setActionDate(java.time.LocalDateTime.now());
                                log.setStoreLocation(defaultInventory.getStoreLocation() != null ? defaultInventory.getStoreLocation() : "Main Warehouse");
                                em.persist(log);
                                
                            } else {
                                System.err.println("⚠️ Warning: No variants found for product: " + itemName);
                            }
                        } else {
                            System.err.println("⚠️ Warning: Product not found in inventory: " + itemName);
                        }
                    } catch (Exception e) {
                        System.err.println("⚠️ Warning: Failed to update inventory for " + itemName + ": " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            
            // Set final notes including over-receipt warnings
            gr.setNotes(receiptNotes.length() > 0 ? receiptNotes.toString() : notes);
            
            // Update receipt status (already persisted, just update status)
            gr.setStatus(allFull ? "FULL" : "PARTIAL");
            em.merge(gr);
            System.out.println("✅ Updated GoodsReceipt status to: " + gr.getStatus());
            
            // Update PO status using same EM (po is already managed)
            String oldStatus = po.getStatus();
            if (allFull && totalReceived >= totalOrdered) {
                po.setStatus("COMPLETED");
            } else {
                po.setStatus("RECEIVING");
            }
            em.merge(po);
            em.flush(); // Force flush to database
            System.out.println("✅ Updated PO status from " + oldStatus + " to " + po.getStatus());
            
            em.getTransaction().commit();
            System.out.println("✅ Transaction committed successfully");
            
            System.out.println("✅ receiveGoods SUCCESS - Receipt ID: " + gr.getReceiptID());
            System.out.println("=== receiveGoods END ===");
            
            return gr.getReceiptID();
            
        } catch (Exception e) {
            if (em != null && em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.err.println("❌ receiveGoods FAILED: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to receive goods: " + e.getMessage(), e);
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    /* ============================================================
       5. ĐỐI CHIẾU HÓA ĐƠN NHÀ CUNG CẤP (3-WAY MATCHING)
    ============================================================ */
    
    /**
     * DTO for Invoice Items
     */
    public static class InvoiceItemDTO {
        public String productName;
        public int quantity;
        public double unitPrice;
    }
    
    /**
     * Create invoice from PO with actual invoice items and perform 3-way matching
     * @param poid Purchase Order ID
     * @param supplierID Supplier ID
     * @param invoiceNumber Invoice number from supplier
     * @param invoiceDate Invoice date
     * @param invoiceItems Actual items from supplier invoice
     * @return Created invoice ID
     */
    public UUID matchInvoice(UUID poid, UUID supplierID, String invoiceNumber, 
                            LocalDateTime invoiceDate, List<InvoiceItemDTO> invoiceItems) {
        PurchaseOrder po = poDAO.findById(poid);
        if (po == null) {
            throw new RuntimeException("Purchase Order not found");
        }
        
        // Only allow invoice creation for COMPLETED purchase orders
        if (!"COMPLETED".equals(po.getStatus())) {
            throw new RuntimeException("Chỉ có thể tạo hóa đơn cho đơn hàng đã hoàn thành (COMPLETED). Đơn hàng hiện tại có trạng thái: " + po.getStatus());
        }
        
        // Calculate total from actual invoice items
        double totalAmount = 0;
        for (InvoiceItemDTO item : invoiceItems) {
            totalAmount += item.quantity * item.unitPrice;
        }
        
        // Create invoice with actual data
        Invoice inv = new Invoice();
        inv.setPoid(poid);
        inv.setSupplierID(supplierID);
        inv.setTotalAmount(totalAmount);
        inv.setInvoiceDate(invoiceDate != null ? invoiceDate : LocalDateTime.now());
        inv.setMatchStatus("PENDING");
        invDAO.insert(inv);
        
        // Get PO items to find matching poItemID
        List<PurchaseOrderItem> poItems = itemDAO.findByPOID(poid);
        Map<String, Integer> poItemMap = new HashMap<>();
        for (PurchaseOrderItem poItem : poItems) {
            poItemMap.put(poItem.getItemName().toLowerCase().trim(), poItem.getItemID());
        }
        
        // Create invoice items from ACTUAL invoice data (not copied from PO)
        for (InvoiceItemDTO itemDTO : invoiceItems) {
            InvoiceItem invItem = new InvoiceItem();
            invItem.setInvoiceID(inv.getInvoiceID());
            invItem.setProductName(itemDTO.productName);
            invItem.setQuantity(itemDTO.quantity);
            invItem.setUnitPrice(itemDTO.unitPrice);
            
            // Try to match with PO item by name
            String itemKey = itemDTO.productName.toLowerCase().trim();
            if (poItemMap.containsKey(itemKey)) {
                invItem.setPoItemID(poItemMap.get(itemKey));
            }
            
            invItemDAO.insert(invItem);
        }
        
        // Perform 3-way matching (now comparing actual invoice items vs PO items)
        InvoiceMatchingService.MatchingResult result = matchingService.performThreeWayMatch(inv.getInvoiceID());
        
        // Update PO status if matched
        if (result.matched) {
            po.setStatus("COMPLETED");
            poDAO.update(po);
        }
        
        return inv.getInvoiceID();
    }
    
    /**
     * Legacy method - kept for backward compatibility
     * @deprecated Use matchInvoice with items instead
     */
    @Deprecated
    public UUID matchInvoice(UUID poid, UUID supplierID, double invoiceAmount) {
        // Create dummy items from PO for backward compatibility
        List<PurchaseOrderItem> poItems = itemDAO.findByPOID(poid);
        List<InvoiceItemDTO> items = new ArrayList<>();
        for (PurchaseOrderItem poItem : poItems) {
            InvoiceItemDTO dto = new InvoiceItemDTO();
            dto.productName = poItem.getItemName();
            dto.quantity = poItem.getQuantity();
            dto.unitPrice = poItem.getUnitPrice();
            items.add(dto);
        }
        return matchInvoice(poid, supplierID, null, LocalDateTime.now(), items);
    }
    
    /**
     * Perform 3-way matching on existing invoice
     */
    public InvoiceMatchingService.MatchingResult performMatching(UUID invoiceID) {
        return matchingService.performThreeWayMatch(invoiceID);
    }
    
    /**
     * Auto-approve invoice if within tolerance
     */
    public boolean autoApproveInvoice(UUID invoiceID, UUID approvedBy) {
        return matchingService.autoApproveIfEligible(invoiceID, approvedBy);
    }

    /**
     * Create manual invoice (without PO)
     */
    public UUID createManualInvoice(Invoice invoice) {
        if (invoice.getInvoiceID() == null) {
            invoice.setInvoiceID(UUID.randomUUID());
        }
        if (invoice.getInvoiceDate() == null) {
            invoice.setInvoiceDate(LocalDateTime.now());
        }
        invDAO.insert(invoice);
        return invoice.getInvoiceID();
    }

    /* ============================================================
       6. CẬP NHẬT SLA (Đánh giá định kỳ)
    ============================================================ */
    public void evaluateSLA(UUID supplierID, boolean onTime, double delayDays) {
        SupplierSLA sla = slaDAO.getAll()
                .stream().filter(x -> x.getSupplierID().equals(supplierID))
                .findFirst().orElse(null);
        if (sla == null) return;
        sla.setTotalOrders(sla.getTotalOrders() + 1);
        if (onTime) sla.setOnTimeDeliveries(sla.getOnTimeDeliveries() + 1);
        sla.setAvgDelayDays((sla.getAvgDelayDays() + delayDays) / 2);
        sla.setLastEvaluated(LocalDateTime.now());
        slaDAO.update(sla);
    }

    /* ============================================================
       7. BUSINESS RULES & VALIDATION
    ============================================================ */
    
    /**
     * Kiểm tra quyền duyệt PO theo approval level
     */
    public boolean canApprovePO(UUID userID, UUID poid, int requestedLevel) {
        PurchaseOrder po = poDAO.findById(poid);
        if (po == null) return false;
        
        // Business rules:
        // Level 1: Owner/Manager (có thể duyệt tất cả)
        // Level 2: Department Head (có thể duyệt PO < 10M)
        // Level 3: Supervisor (có thể duyệt PO < 5M)
        
        double poAmount = po.getTotalAmount() != null ? po.getTotalAmount() : 0;
        
        switch (requestedLevel) {
            case 1: // Owner/Manager
                return true; // Có thể duyệt tất cả
            case 2: // Department Head
                return poAmount < 10_000_000; // < 10M VND
            case 3: // Supervisor
                return poAmount < 5_000_000; // < 5M VND
            default:
                return false;
        }
    }
    
    /**
     * Tính toán reorder point cho sản phẩm
     */
    public int calculateReorderPoint(String itemName, int avgDailyUsage, int leadTimeDays) {
        // Business rule: Reorder Point = (Average Daily Usage × Lead Time) + Safety Stock
        int safetyStock = (int) (avgDailyUsage * 0.2); // 20% safety stock
        return (avgDailyUsage * leadTimeDays) + safetyStock;
    }
    
    /**
     * Kiểm tra supplier có đủ điều kiện đặt hàng không
     */
    public boolean isSupplierEligible(UUID supplierID) {
        Supplier supplier = supplierDAO.findById(supplierID);
        if (supplier == null || !supplier.getIsActive()) return false;
        
        // Business rule: Rating >= 3.0 và OnTimeRate >= 80%
        return supplier.getRating() >= 3.0 && supplier.getOnTimeRate() >= 80.0;
    }
    
    /**
     * Tự động cập nhật inventory sau khi nhận hàng
     */
    public boolean updateInventoryAfterReceipt(UUID receiptID) {
        GoodsReceipt receipt = grDAO.findById(receiptID);
        if (receipt == null) return false;
        
        // TODO: Integrate with inventory system
        // This should update ProductStock table
        return true;
    }
    
    /**
     * Gửi cảnh báo khi PO sắp đến hạn
     */
    public List<PurchaseOrder> getPOsNearDeadline(int daysAhead) {
        LocalDateTime deadline = LocalDateTime.now().plusDays(daysAhead);
        return poDAO.getAll().stream()
                .filter(po -> po.getExpectedDelivery() != null && 
                             po.getExpectedDelivery().isBefore(deadline) &&
                             "APPROVED".equals(po.getStatus()))
                .collect(java.util.stream.Collectors.toList());
    }
    
    /**
     * Lấy danh sách PO đã trễ hạn
     */
    public List<PurchaseOrder> getOverduePOs() {
        LocalDateTime now = LocalDateTime.now();
        return poDAO.getAll().stream()
                .filter(po -> po.getExpectedDelivery() != null && 
                             po.getExpectedDelivery().isBefore(now) &&
                             ("APPROVED".equals(po.getStatus()) || "RECEIVING".equals(po.getStatus())))
                .collect(java.util.stream.Collectors.toList());
    }
    
    /**
     * Tính toán tổng giá trị đơn hàng với discount
     */
    public double calculatePOWithDiscount(double baseAmount, double discountPercent) {
        if (discountPercent < 0 || discountPercent > 100) return baseAmount;
        return baseAmount * (1 - discountPercent / 100);
    }
    
    /**
     * Kiểm tra budget còn lại cho supplier
     */
    public double getRemainingBudget(UUID supplierID, double monthlyBudget) {
        // TODO: Implement budget tracking
        // This should query actual spending from completed POs
        return monthlyBudget; // Placeholder
    }
    
    /**
     * Tạo báo cáo hiệu suất supplier
     */
    public Map<String, Object> generateSupplierPerformanceReport(UUID supplierID) {
        Supplier supplier = supplierDAO.findById(supplierID);
        SupplierSLA sla = slaDAO.getAll().stream()
                .filter(s -> s.getSupplierID().equals(supplierID))
                .findFirst().orElse(null);
        
        Map<String, Object> report = new HashMap<>();
        if (supplier != null) {
            report.put("supplierName", supplier.getName());
            report.put("rating", supplier.getRating());
            report.put("onTimeRate", supplier.getOnTimeRate());
            report.put("defectRate", supplier.getDefectRate());
        }
        
        if (sla != null) {
            report.put("totalOrders", sla.getTotalOrders());
            report.put("onTimeDeliveries", sla.getOnTimeDeliveries());
            report.put("avgDelayDays", sla.getAvgDelayDays());
            report.put("onTimePercentage", sla.getTotalOrders() > 0 ? 
                (double) sla.getOnTimeDeliveries() / sla.getTotalOrders() * 100 : 0);
        }
        
        return report;
    }
    
    /* ============================================================
       8. INVOICE MANAGEMENT (Quản lý hóa đơn)
    ============================================================ */
    
    /**
     * Lấy tất cả invoices
     */
    public List<Invoice> getAllInvoices() {
        return invDAO.getAll();
    }
    
    /**
     * Lấy invoice theo ID
     */
    public Invoice getInvoiceById(UUID invoiceID) {
        return invDAO.findById(invoiceID);
    }
    
    /**
     * Lấy invoices theo PO
     */
    public List<Invoice> getInvoicesByPO(UUID poid) {
        return invDAO.getAll().stream()
                .filter(inv -> inv.getPoid() != null && inv.getPoid().equals(poid))
                .collect(java.util.stream.Collectors.toList());
    }
    
    /**
     * Lấy invoices theo supplier
     */
    public List<Invoice> getInvoicesBySupplier(UUID supplierID) {
        return invDAO.getAll().stream()
                .filter(inv -> inv.getSupplierID() != null && inv.getSupplierID().equals(supplierID))
                .collect(java.util.stream.Collectors.toList());
    }
    
    /**
     * Lấy invoices chưa khớp
     */
    public List<Invoice> getUnmatchedInvoices() {
        return invDAO.getAll().stream()
                .filter(inv -> inv.getMatched() != null && !inv.getMatched())
                .collect(java.util.stream.Collectors.toList());
    }
    
    /**
     * Resolve invoice discrepancy
     */
    public boolean resolveInvoiceDiscrepancy(UUID invoiceID, String note) {
        Invoice invoice = invDAO.findById(invoiceID);
        if (invoice == null) return false;
        
        invoice.setMatched(true);
        invoice.setMatchNote(note);
        return invDAO.update(invoice);
    }
    
    /**
     * Update invoice
     */
    public boolean updateInvoice(Invoice invoice) {
        return invDAO.update(invoice);
    }
    
    /**
     * Delete invoice
     */
    public boolean deleteInvoice(UUID invoiceID) {
        return invDAO.delete(invoiceID);
    }
    
    /**
     * Get total invoice amount by supplier
     */
    public double getTotalInvoiceAmountBySupplier(UUID supplierID) {
        return invDAO.getAll().stream()
                .filter(inv -> inv.getSupplierID() != null && inv.getSupplierID().equals(supplierID))
                .mapToDouble(inv -> inv.getTotalAmount() != null ? inv.getTotalAmount() : 0.0)
                .sum();
    }
    
    /**
     * Get invoices by date range
     */
    public List<Invoice> getInvoicesByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return invDAO.getAll().stream()
                .filter(inv -> inv.getInvoiceDate() != null && 
                              !inv.getInvoiceDate().isBefore(startDate) && 
                              !inv.getInvoiceDate().isAfter(endDate))
                .collect(java.util.stream.Collectors.toList());
    }
}
