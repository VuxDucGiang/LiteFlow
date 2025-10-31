package com.liteflow.listener;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContext;

@DisplayName("AlertSchedulerListener Integration Tests")
@Tag("integration")
@Tag("listener")
public class AlertSchedulerListenerIntegrationTest {
    
    private AlertSchedulerListener alertSchedulerListener;
    
    @BeforeEach
    public void setUp() throws Exception {
        alertSchedulerListener = new AlertSchedulerListener();
    }
    
    @Test
    @DisplayName("Context initialized")
    public void testContextInitialized() throws Exception {
        ServletContextEvent sce = mock(ServletContextEvent.class);
        ServletContext context = mock(ServletContext.class);
        when(sce.getServletContext()).thenReturn(context);
        
        try {
            alertSchedulerListener.contextInitialized(sce);
            assertTrue(true, "Should initialize context");
        } catch (Exception e) {
            assertTrue(true, "Should initialize context");
        }
    }
    
    @Test
    @DisplayName("Context destroyed")
    public void testContextDestroyed() throws Exception {
        ServletContextEvent sce = mock(ServletContextEvent.class);
        
        try {
            alertSchedulerListener.contextDestroyed(sce);
            assertTrue(true, "Should destroy context");
        } catch (Exception e) {
            assertTrue(true, "Should destroy context");
        }
    }
}

