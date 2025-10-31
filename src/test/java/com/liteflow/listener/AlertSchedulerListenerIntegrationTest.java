package com.liteflow.listener;

import com.liteflow.service.alert.AlertSchedulerService;
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
    @DisplayName("Context initialized - success case")
    public void testContextInitializedSuccess() throws Exception {
        ServletContextEvent sce = mock(ServletContextEvent.class);
        ServletContext context = mock(ServletContext.class);
        when(sce.getServletContext()).thenReturn(context);
        
        // Test that context initialization completes without throwing
        assertDoesNotThrow(() -> {
            alertSchedulerListener.contextInitialized(sce);
        });
        
        // Verify that servlet context attribute was set
        verify(context, atLeastOnce()).setAttribute(eq("alertScheduler"), any(AlertSchedulerService.class));
    }
    
    @Test
    @DisplayName("Context initialized - exception handling")
    public void testContextInitializedWithException() throws Exception {
        ServletContextEvent sce = mock(ServletContextEvent.class);
        ServletContext context = mock(ServletContext.class);
        
        // Make getServletContext throw exception on first call, return context on second
        when(sce.getServletContext())
            .thenThrow(new RuntimeException("Test exception"))
            .thenReturn(context);
        
        // Should handle exception gracefully
        assertDoesNotThrow(() -> {
            alertSchedulerListener.contextInitialized(sce);
        });
    }
    
    @Test
    @DisplayName("Context destroyed - with schedulerService")
    public void testContextDestroyedWithSchedulerService() throws Exception {
        ServletContextEvent sce = mock(ServletContextEvent.class);
        ServletContext context = mock(ServletContext.class);
        when(sce.getServletContext()).thenReturn(context);
        
        // First initialize to create schedulerService
        alertSchedulerListener.contextInitialized(sce);
        
        // Now test destruction
        assertDoesNotThrow(() -> {
            alertSchedulerListener.contextDestroyed(sce);
        });
    }
    
    @Test
    @DisplayName("Context destroyed - without schedulerService (null)")
    public void testContextDestroyedWithoutSchedulerService() throws Exception {
        ServletContextEvent sce = mock(ServletContextEvent.class);
        
        // Test destruction when schedulerService is null (no initialization)
        assertDoesNotThrow(() -> {
            alertSchedulerListener.contextDestroyed(sce);
        });
    }
}

