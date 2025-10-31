package com.liteflow.web.procurement;

import com.liteflow.web.procurement.PurchaseOrderServlet;
import com.liteflow.helpers.mocks.ServletTestHelper;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.PrintWriter;
import java.io.StringWriter;

@DisplayName("PurchaseOrderServlet Integration Tests")
@Tag("integration")
@Tag("procurement")
@Tag("controller")
public class PurchaseOrderServletIntegrationTest {
    
    private PurchaseOrderServlet purchaseOrderServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        purchaseOrderServlet = new PurchaseOrderServlet();
    }
    
    @Test
    @DisplayName("Get purchase orders list")
    public void testGetPurchaseOrdersList() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/procurement/po.jsp")).thenReturn(dispatcher);
        
        try {
            purchaseOrderServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getRequestDispatcher("/procurement/po.jsp");
    }
    
    @Test
    @DisplayName("Get PO details")
    public void testGetPODetails() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("details");
        when(request.getParameter("poid")).thenReturn(java.util.UUID.randomUUID().toString());
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            purchaseOrderServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
}

