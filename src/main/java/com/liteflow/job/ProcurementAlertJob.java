package com.liteflow.job;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Logger;

@WebListener
public class ProcurementAlertJob implements ServletContextListener {
    private Timer timer;
    private static final Logger log = Logger.getLogger(ProcurementAlertJob.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        timer = new Timer(true);
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                checkAlerts();
            }
        }, 10_000, 6 * 60 * 60 * 1000); // 6 giờ
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) timer.cancel();
    }

    private void checkAlerts() {
        try (Connection c = DriverManager.getConnection(
                System.getenv("LITEFLOW_JDBC_URL"),
                System.getenv("LITEFLOW_DB_USER"),
                System.getenv("LITEFLOW_DB_PASS"))) {

            try (Statement st = c.createStatement()) {
                // Kiểm tra PO trễ
                ResultSet rs = st.executeQuery(
                        "SELECT POID, DATEDIFF(DAY, ExpectedDelivery, GETUTCDATE()) AS Delay FROM PurchaseOrders " +
                                "WHERE Status IN ('PENDING','APPROVED','RECEIVING') AND GETUTCDATE() > ExpectedDelivery");
                while (rs.next()) {
                    log.warning("⚠ PO " + rs.getString("POID") + " bị trễ " + rs.getInt("Delay") + " ngày.");
                }
                rs.close();

                // Kiểm tra PO vượt giá
                rs = st.executeQuery(
                        "SELECT p.POID, p.TotalAmount AS PO_Amount, " +
                                "ISNULL((SELECT SUM(i.TotalAmount) FROM Invoices i WHERE i.POID = p.POID),0) AS Invoiced " +
                                "FROM PurchaseOrders p WHERE ISNULL((SELECT SUM(i.TotalAmount) FROM Invoices i WHERE i.POID = p.POID),0) > p.TotalAmount");
                while (rs.next()) {
                    log.warning("⚠ PO " + rs.getString("POID") + " bị vượt giá: " +
                            rs.getBigDecimal("Invoiced") + " > " + rs.getBigDecimal("PO_Amount"));
                }
            }
        } catch (Exception e) {
            log.severe("AlertJob Error: " + e.getMessage());
        }
    }
}
