package com.liteflow.web.procurement;

import com.liteflow.model.procurement.Invoice;
import com.liteflow.model.procurement.PurchaseOrder;
import com.liteflow.model.procurement.Supplier;
import com.liteflow.service.procurement.ProcurementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * DTO for Invoice Items from form
 */
class InvoiceItemDTO {
    public String productName;
    public int quantity;
    public double unitPrice;
}

@WebServlet(urlPatterns = {"/procurement/invoice"})
public class InvoiceServlet extends HttpServlet {
    private final ProcurementService service = new ProcurementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        try {
            System.out.println("=== InvoiceServlet.doGet START ===");
            
            // Set response headers
            resp.setContentType("text/html; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            resp.setHeader("Transfer-Encoding", "identity");
            resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            
            // Load all invoices
            List<Invoice> invoices = service.getAllInvoices();
            System.out.println("Loaded invoices: " + (invoices != null ? invoices.size() : "null"));
            
            // Load all POs for matching
            List<PurchaseOrder> allPOs = service.getAllPOs();
            System.out.println("Loaded all POs: " + (allPOs != null ? allPOs.size() : "null"));
            
            // Filter approved POs for dropdown
            List<PurchaseOrder> approvedPOs = allPOs != null ? 
                allPOs.stream()
                    .filter(po -> "APPROVED".equals(po.getStatus()) || "COMPLETED".equals(po.getStatus()))
                    .collect(Collectors.toList()) : 
                new ArrayList<>();
            System.out.println("Filtered approved POs: " + approvedPOs.size());
            
            // Load suppliers
            List<Supplier> suppliers = service.getAllSuppliers();
            System.out.println("Loaded suppliers: " + (suppliers != null ? suppliers.size() : "null"));
            
            // Create invoice data with extended information
            List<InvoiceData> invoiceDataList = new ArrayList<>();
            if (invoices != null) {
                for (Invoice inv : invoices) {
                    InvoiceData data = new InvoiceData();
                    data.setInvoice(inv);
                    
                    // Find related PO
                    if (inv.getPoid() != null && allPOs != null) {
                        PurchaseOrder po = allPOs.stream()
                            .filter(p -> p.getPoid().equals(inv.getPoid()))
                            .findFirst()
                            .orElse(null);
                        data.setPurchaseOrder(po);
                    }
                    
                    // Find supplier
                    if (inv.getSupplierID() != null && suppliers != null) {
                        Supplier supplier = suppliers.stream()
                            .filter(s -> s.getSupplierID().equals(inv.getSupplierID()))
                            .findFirst()
                            .orElse(null);
                        data.setSupplier(supplier);
                    }
                    
                    invoiceDataList.add(data);
                }
            }
            
            // Set attributes
            req.setAttribute("invoices", invoiceDataList);
            req.setAttribute("completedPOs", approvedPOs);
            req.setAttribute("suppliers", suppliers);
            
            // Check for status message
            String status = req.getParameter("status");
            if ("matched".equals(status)) {
                req.setAttribute("successMessage", "Đối chiếu hóa đơn thành công!");
            } else if ("created".equals(status)) {
                req.setAttribute("successMessage", "Tạo hóa đơn thành công!");
            }
            
            System.out.println("Forwarding to invoice-matching.jsp");
            req.getRequestDispatcher("/procurement/invoice-matching.jsp").forward(req, resp);
            System.out.println("=== InvoiceServlet.doGet END ===");
            
        } catch (Exception e) {
            System.err.println("ERROR in InvoiceServlet.doGet: " + e.getMessage());
            e.printStackTrace();
            resp.setContentType("text/html; charset=UTF-8");
            resp.getWriter().write("<html><body><h1>Error loading invoices</h1><p>" + e.getMessage() + "</p></body></html>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            System.out.println("=== InvoiceServlet.doPost START ===");
            
            String action = req.getParameter("action");
            System.out.println("Action: " + action);
            
            if ("match".equals(action)) {
                // Match invoice from PO with actual invoice items
                String poidStr = req.getParameter("poid");
                String supplierIDStr = req.getParameter("supplierID");
                String invoiceNumber = req.getParameter("invoiceNumber");
                String invoiceDateStr = req.getParameter("invoiceDate");
                
                // Get invoice items from form
                String[] itemNames = req.getParameterValues("itemName[]");
                String[] itemQuantities = req.getParameterValues("itemQuantity[]");
                String[] itemUnitPrices = req.getParameterValues("itemUnitPrice[]");
                
                System.out.println("=== Match Invoice from PO ===");
                System.out.println("POID: " + poidStr);
                System.out.println("SupplierID: " + supplierIDStr);
                System.out.println("Invoice Number: " + invoiceNumber);
                System.out.println("Invoice Date: " + invoiceDateStr);
                System.out.println("Items count: " + (itemNames != null ? itemNames.length : 0));
                
                // Validate input
                if (poidStr == null || supplierIDStr == null || itemNames == null || itemNames.length == 0) {
                    resp.sendRedirect(req.getContextPath() + "/procurement/invoice?error=missing_data");
                    return;
                }
                
                UUID poid = UUID.fromString(poidStr);
                UUID supplierID = UUID.fromString(supplierIDStr);
                
                // Parse invoice date
                LocalDateTime invoiceDate = LocalDateTime.now();
                if (invoiceDateStr != null && !invoiceDateStr.isEmpty()) {
                    invoiceDate = LocalDateTime.parse(invoiceDateStr + "T00:00:00");
                }
                
                // Create InvoiceItemDTO list (use ProcurementService.InvoiceItemDTO)
                List<ProcurementService.InvoiceItemDTO> items = new ArrayList<>();
                for (int i = 0; i < itemNames.length; i++) {
                    ProcurementService.InvoiceItemDTO item = new ProcurementService.InvoiceItemDTO();
                    item.productName = itemNames[i];
                    item.quantity = Integer.parseInt(itemQuantities[i]);
                    item.unitPrice = Double.parseDouble(itemUnitPrices[i]);
                    items.add(item);
                    
                    System.out.println("  Item " + (i+1) + ": " + itemNames[i] + 
                                     " | Qty: " + itemQuantities[i] + 
                                     " | Price: " + itemUnitPrices[i]);
                }
                
                // Call service with items
                UUID invoiceID = service.matchInvoice(poid, supplierID, invoiceNumber, invoiceDate, items);
                System.out.println("Created invoice ID: " + invoiceID);
                System.out.println("=== Match Complete ===");
                
                resp.sendRedirect(req.getContextPath() + "/procurement/invoice?status=matched");
                
            } else if ("resolve".equals(action)) {
                // Resolve discrepancy
                String invoiceIDStr = req.getParameter("invoiceID");
                String note = req.getParameter("note");
                
                UUID invoiceID = UUID.fromString(invoiceIDStr);
                service.resolveInvoiceDiscrepancy(invoiceID, note);
                
                resp.sendRedirect(req.getContextPath() + "/procurement/invoice?status=resolved");
                
            } else if ("createManual".equals(action)) {
                // Create manual invoice (no PO)
                String supplierIDStr = req.getParameter("supplierID");
                String invoiceNumber = req.getParameter("invoiceNumber");
                String totalAmountStr = req.getParameter("totalAmount");
                String invoiceDateStr = req.getParameter("invoiceDate");
                String note = req.getParameter("note");
                
                System.out.println("Creating manual invoice:");
                System.out.println("SupplierID: " + supplierIDStr);
                System.out.println("Invoice Number: " + invoiceNumber);
                System.out.println("Total Amount: " + totalAmountStr);
                System.out.println("Invoice Date: " + invoiceDateStr);
                System.out.println("Note: " + note);
                
                UUID supplierID = UUID.fromString(supplierIDStr);
                double totalAmount = Double.parseDouble(totalAmountStr);
                
                // Parse invoice date
                LocalDateTime invoiceDate = LocalDateTime.now();
                if (invoiceDateStr != null && !invoiceDateStr.isEmpty()) {
                    invoiceDate = LocalDateTime.parse(invoiceDateStr + "T00:00:00");
                }
                
                // Create invoice object
                Invoice invoice = new Invoice();
                invoice.setSupplierID(supplierID);
                invoice.setPoid(null); // No PO for manual invoice
                invoice.setInvoiceDate(invoiceDate);
                invoice.setTotalAmount(totalAmount);
                invoice.setMatched(true); // Manual invoices are auto-matched
                invoice.setMatchNote(note != null ? note : "Nhập thủ công - Không có PO");
                
                // Save invoice
                UUID invoiceID = service.createManualInvoice(invoice);
                System.out.println("Created manual invoice ID: " + invoiceID);
                
                resp.sendRedirect(req.getContextPath() + "/procurement/invoice?status=created");
                
            } else {
                resp.sendRedirect(req.getContextPath() + "/procurement/invoice");
            }
            
            System.out.println("=== InvoiceServlet.doPost END ===");
            
        } catch (Exception e) {
            System.err.println("ERROR in InvoiceServlet.doPost: " + e.getMessage());
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/procurement/invoice?error=" + e.getMessage());
        }
    }
    
    // Inner class to hold invoice data with related entities
    public static class InvoiceData {
        private Invoice invoice;
        private PurchaseOrder purchaseOrder;
        private Supplier supplier;
        
        public Invoice getInvoice() { return invoice; }
        public void setInvoice(Invoice invoice) { this.invoice = invoice; }
        
        public PurchaseOrder getPurchaseOrder() { return purchaseOrder; }
        public void setPurchaseOrder(PurchaseOrder purchaseOrder) { this.purchaseOrder = purchaseOrder; }
        
        public Supplier getSupplier() { return supplier; }
        public void setSupplier(Supplier supplier) { this.supplier = supplier; }
        
        // Helper methods for JSP
        public UUID getInvoiceID() { return invoice != null ? invoice.getInvoiceID() : null; }
        public UUID getPoid() { return invoice != null ? invoice.getPoid() : null; }
        public LocalDateTime getInvoiceDate() { return invoice != null ? invoice.getInvoiceDate() : null; }
        public Double getTotalAmount() { return invoice != null ? invoice.getTotalAmount() : 0.0; }
        public Boolean getMatched() { return invoice != null ? invoice.getMatched() : false; }
        public String getMatchNote() { return invoice != null ? invoice.getMatchNote() : ""; }
        
        public String getSupplierName() { return supplier != null ? supplier.getName() : "N/A"; }
        public Double getPOAmount() { return purchaseOrder != null ? purchaseOrder.getTotalAmount() : 0.0; }
        
        public Double getDifference() {
            if (invoice == null || purchaseOrder == null) return 0.0;
            return invoice.getTotalAmount() - purchaseOrder.getTotalAmount();
        }
    }
}
