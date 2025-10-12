/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.liteflow.dao;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TestConnection {
    public static String driverName = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    public static String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=LiteFlowDBO;encrypt=true;trustServerCertificate=true;";
    public static String userDB = "sa";
    public static String passDB = "123";

    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName(driverName);
            con = DriverManager.getConnection(dbURL, userDB, passDB);
            return con;
        } catch (Exception ex) {
            Logger.getLogger(TestConnection.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    public static void main(String[] args) {
        try (Connection con = getConnection()) {
            if (con != null) {
                System.out.println("Connect to LiteFlow successfully");
            }
        } catch (SQLException e) {
            Logger.getLogger(TestConnection.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}
