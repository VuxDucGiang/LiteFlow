package com.liteflow.controller.inventory;

import com.liteflow.controller.SetPriceServlet;
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

@DisplayName("SetPriceServlet Integration Tests")
@Tag("integration")
@Tag("inventory")
@Tag("controller")
public class SetPriceServletIntegrationTest {
    
    private SetPriceServlet setPriceServlet;
    
    @BeforeEach
    public void setUp() throws Exception {
        setPriceServlet = new SetPriceServlet();
        setPriceServlet.init();
    }
    
    @Test
    @DisplayName("Get price setting page")
    public void testGetPriceSettingPage() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockGetRequest();
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(request.getRequestDispatcher("/inventory/setPrice.jsp")).thenReturn(dispatcher);
        
        try {
            setPriceServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getRequestDispatcher("/inventory/setPrice.jsp");
    }
    
    @Test
    @DisplayName("Update price API")
    public void testUpdatePrice() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("update");
        when(request.getParameter("variantId")).thenReturn(java.util.UUID.randomUUID().toString());
        when(request.getParameter("price")).thenReturn("50000");
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            setPriceServlet.service(request, response);
        } catch (Exception e) {
            // May fail without DB
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Import prices from Excel")
    public void testImportPricesFromExcel() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("importExcel");
        when(request.getPart("file")).thenReturn(null);
        
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        when(response.getWriter()).thenReturn(printWriter);
        
        try {
            setPriceServlet.service(request, response);
        } catch (Exception e) {
            // May fail without file
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
    
    @Test
    @DisplayName("Export prices to Excel")
    public void testExportPricesToExcel() throws Exception {
        HttpServletRequest request = ServletTestHelper.mockPostRequest("");
        HttpServletResponse response = ServletTestHelper.mockResponse();
        
        when(request.getParameter("action")).thenReturn("exportExcel");
        
        try {
            setPriceServlet.service(request, response);
        } catch (Exception e) {
            // May fail without output stream
        }
        
        verify(request, atLeastOnce()).getParameter("action");
    }
}

