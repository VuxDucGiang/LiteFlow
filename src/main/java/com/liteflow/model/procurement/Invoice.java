package com.liteflow.model.procurement;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "Invoices")
public class Invoice {

    @Id
    @Column(name = "InvoiceID", columnDefinition = "uniqueidentifier")
    private UUID invoiceID;

    @PrePersist
    public void prePersist() {
        if (invoiceID == null) invoiceID = UUID.randomUUID();
    }

    @Column(name = "POID", columnDefinition = "uniqueidentifier")
    private UUID poid;

    @Column(name = "SupplierID", columnDefinition = "uniqueidentifier")
    private UUID supplierID;

    @Column(name = "InvoiceDate")
    private LocalDateTime invoiceDate = LocalDateTime.now();
    
    @Column(name = "TotalAmount")
    private Double totalAmount;
    
    @Column(name = "Matched")
    private Boolean matched = false;
    
    @Column(name = "MatchNote")
    private String matchNote;

    // Getters & Setters
    public UUID getInvoiceID() { return invoiceID; }
    public void setInvoiceID(UUID invoiceID) { this.invoiceID = invoiceID; }
    public UUID getPoid() { return poid; }
    public void setPoid(UUID poid) { this.poid = poid; }
    public UUID getSupplierID() { return supplierID; }
    public void setSupplierID(UUID supplierID) { this.supplierID = supplierID; }
    public LocalDateTime getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(LocalDateTime invoiceDate) { this.invoiceDate = invoiceDate; }
    public Double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Double totalAmount) { this.totalAmount = totalAmount; }
    public Boolean getMatched() { return matched; }
    public void setMatched(Boolean matched) { this.matched = matched; }
    public String getMatchNote() { return matchNote; }
    public void setMatchNote(String matchNote) { this.matchNote = matchNote; }
}
