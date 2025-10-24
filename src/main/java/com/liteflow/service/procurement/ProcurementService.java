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
        PurchaseOrder po = new PurchaseOrder();
        po.setSupplierID(supplierID);
        po.setCreatedBy(createdBy);
        po.setExpectedDelivery(expectedDate);
        po.setNotes(notes);
        po.setStatus("PENDING");
        poDAO.insert(po);

        double total = 0;
        for (PurchaseOrderItem it : items) {
            it.setPoid(po.getPoid());
            total += it.getQuantity() * it.getUnitPrice();
            itemDAO.insert(it);
        }
        po.setTotalAmount(total);
        poDAO.update(po);
        return po.getPoid();
    }

    public List<PurchaseOrder> getAllPOs() { return poDAO.getAll(); }
    
    public List<PurchaseOrderItem> getPOItems(UUID poid) {
        // Use DAO's optimized query instead of filtering getAll()
        return itemDAO.findByPOID(poid);
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
        return poDAO.update(po);
    }

    public boolean rejectPO(UUID poid, UUID approver, String reason) {
        PurchaseOrder po = poDAO.findById(poid);
        if (po == null) return false;
        po.setApprovedBy(approver);
        po.setNotes(reason);
        po.setStatus("REJECTED");
        return poDAO.update(po);
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
        if (po == null) return null;
        
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
