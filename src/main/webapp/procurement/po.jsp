<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Đơn đặt hàng - LiteFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/design-system.css">
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <script src="${pageContext.request.contextPath}/js/dropdown-simple.js"></script>
    
    <style>
        /* ========== DESIGN SYSTEM ========== */
        :root {
            --primary-50: #f2f7ff;
            --primary-100: #e6f0ff;
            --primary-500: #0080FF;
            --primary-600: #0066cc;
            --primary-700: #004d99;
            --secondary-500: #00c6ff;
            --color-primary: #0080FF;
            --color-secondary: #00c6ff;
            --color-accent: #7d2ae8;
            
            --success-50: #f0fdf4;
            --success-100: #dcfce7;
            --success-500: #10b981;
            --success-600: #059669;
            
            --warning-50: #fffbeb;
            --warning-100: #fef3c7;
            --warning-500: #f59e0b;
            --warning-600: #d97706;
            
            --danger-50: #fef2f2;
            --danger-100: #fee2e2;
            --danger-500: #ef4444;
            --danger-600: #dc2626;
            
            --gray-50: #f9fafb;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-300: #d1d5db;
            --gray-400: #9ca3af;
            --gray-500: #6b7280;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --gray-900: #111827;
            
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            
            --radius-sm: 6px;
            --radius: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 24px;
            
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        * { 
            box-sizing: border-box;
        }
        
        html, body {
            overflow-x: hidden;
            width: 100%;
            max-width: 100vw;
        }
        
        body {
            background: var(--gray-50, #f9fafb);
            background-attachment: fixed;
            min-height: 100vh;
            margin: 0;
            padding: 0;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        /* ========== LAYOUT ========== */
        .container {
            max-width: 1700px;
            margin: 0 auto;
            padding: 30px 20px;
            width: 100%;
            box-sizing: border-box;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 35px;
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border: 2px solid rgba(255,255,255,0.3);
            position: relative;
            overflow: hidden;
            width: 100%;
            box-sizing: border-box;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .page-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--secondary-500));
        }
        
        .page-title {
            font-size: 32px;
            font-weight: 700;
            background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .page-title .icon {
            background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
            color: white;
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: 0 4px 12px rgba(0, 128, 255, 0.3);
            -webkit-text-fill-color: initial;
            -webkit-background-clip: initial;
            background-clip: initial;
        }
        
        /* ========== BUTTONS ========== */
        .btn-primary {
            background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
            color: white;
            padding: 14px 28px;
            border: none;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            box-shadow: var(--shadow-md);
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }
        
        .btn-primary::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            transition: left 0.5s;
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, var(--primary-600), var(--secondary-500));
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 128, 255, 0.4);
        }
        
        .btn-success {
            background: linear-gradient(135deg, var(--success-500, #22c55e), var(--success-600, #16a34a));
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(34, 197, 94, 0.3);
            transition: all 0.2s;
        }
        
        .btn-success:hover {
            background: linear-gradient(135deg, var(--success-600, #16a34a), var(--success-700, #15803d));
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(34, 197, 94, 0.4);
        }
        
        .btn-warning {
            background: linear-gradient(135deg, var(--warning-600), var(--warning-500));
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            box-shadow: var(--shadow);
            transition: var(--transition);
        }
        
        .btn-warning:hover {
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }
        
        .btn-danger {
            background: linear-gradient(135deg, var(--danger-600), var(--danger-500));
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            box-shadow: var(--shadow);
            transition: var(--transition);
        }
        
        .btn-danger:hover {
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }
        
        .btn-info {
            background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(0, 128, 255, 0.3);
            transition: all 0.2s;
        }
        
        .btn-info:hover {
            background: linear-gradient(135deg, var(--primary-600), var(--secondary-500));
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 128, 255, 0.4);
        }
        
        /* ========== FILTERS ========== */
        .filters {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
            align-items: stretch;
            flex-wrap: wrap;
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border: 1px solid var(--color-primary);
            position: relative;
            overflow: hidden;
            width: 100%;
            box-sizing: border-box;
        }
        
        .filters::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--secondary-500));
        }
        
        .search-box {
            position: relative;
            flex: 1;
            min-width: 320px;
            margin-top: 4px;
            box-sizing: border-box;
        }
        
        .search-box input {
            width: 100%;
            padding: 14px 45px 14px 18px;
            border: 2px solid var(--color-primary);
            border-radius: var(--radius);
            font-size: 14px;
            transition: all 0.2s;
            background: white;
            box-sizing: border-box;
        }
        
        .search-box input:focus {
            outline: none;
            border-color: var(--secondary-500);
            background: white;
            box-shadow: 0 0 0 3px rgba(0, 198, 255, 0.1);
        }
        
        .search-box::after {
            content: '🔍';
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 18px;
            opacity: 0.6;
        }
        
        .filter-select {
            padding: 14px 18px;
            border: 2px solid var(--color-primary);
            border-radius: var(--radius);
            background: white;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            min-width: 180px;
            margin-top: 4px;
            box-sizing: border-box;
        }
        
        .filter-select:hover {
            border-color: var(--secondary-500);
            background: white;
        }
        
        .filter-select:focus {
            outline: none;
            border-color: var(--secondary-500);
            background: white;
            box-shadow: 0 0 0 3px rgba(0, 198, 255, 0.1);
        }
        
        /* ========== STATS CARDS ========== */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%);
            padding: 28px;
            border-radius: var(--radius-md);
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border: 1px solid var(--color-primary);
            position: relative;
            overflow: hidden;
            transition: all 0.2s;
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--accent-color), var(--accent-light));
        }
        
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }
        
        .stat-card.pending { 
            --accent-color: var(--warning-500, #f59e0b);
            --accent-light: var(--warning-600, #d97706);
        }
        .stat-card.approved { 
            --accent-color: var(--success-500, #22c55e);
            --accent-light: var(--success-600, #16a34a);
        }
        .stat-card.rejected { 
            --accent-color: var(--error-500, #ef4444);
            --accent-light: var(--error-600, #dc2626);
        }
        .stat-card.total { 
            --accent-color: var(--primary-500);
            --accent-light: var(--secondary-500);
        }
        
        .stat-number {
            font-size: 3em;
            font-weight: 800;
            background: linear-gradient(135deg, var(--accent-color), var(--accent-light));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 8px;
            line-height: 1;
        }
        
        .stat-label {
            color: var(--gray-600);
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1.2px;
        }
        
        /* ========== TABLE ========== */
        .table-wrapper {
            width: 100%;
            overflow-x: auto;
            overflow-y: visible;
            -webkit-overflow-scrolling: touch;
            box-sizing: border-box;
        }
        
        .po-table {
            width: 100%;
            min-width: 1300px;
            border-collapse: separate;
            border-spacing: 0;
            background: white;
            border-radius: var(--radius-md);
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border: 1px solid var(--color-primary);
            position: relative;
            table-layout: fixed;
        }
        
        .po-table::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--secondary-500));
        }
        
        .po-table thead {
            background: linear-gradient(135deg, var(--primary-50, #f2f7ff) 0%, var(--secondary-50, #f0f9ff) 100%);
        }
        
        .po-table th {
            padding: 18px 20px;
            text-align: left;
            font-weight: 600;
            color: var(--gray-800, #1f2937);
            font-size: 14px;
            border-bottom: 2px solid var(--color-primary);
            position: sticky;
            top: 0;
            z-index: 10;
            white-space: nowrap;
        }
        
        .po-table th:nth-child(1) { width: 10%; } /* Mã PO */
        .po-table th:nth-child(2) { width: 18%; } /* Nhà cung cấp */
        .po-table th:nth-child(3) { width: 12%; } /* Ngày tạo */
        .po-table th:nth-child(4) { width: 12%; } /* Ngày giao dự kiến */
        .po-table th:nth-child(5) { width: 12%; } /* Tổng tiền */
        .po-table th:nth-child(6) { width: 12%; } /* Trạng thái */
        .po-table th:nth-child(7) { width: 12%; } /* Người tạo */
        .po-table th:nth-child(8) { width: 12%; } /* Thao tác */
        
        .po-table td {
            padding: 18px 20px;
            border-bottom: 1px solid var(--gray-200, #e5e7eb);
            transition: all 0.2s ease;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        
        .po-table td:nth-child(2) {
            white-space: normal;
            max-width: 0;
        }
        
        .po-table tbody tr {
            transition: all 0.2s ease;
        }
        
        .po-table tbody tr:hover {
            background: rgba(0, 128, 255, 0.05);
        }
        
        @media (min-width: 1024px) {
            .po-table tbody tr:hover {
                transform: translateX(2px);
            }
        }
        
        .po-table tr:last-child td {
            border-bottom: none;
        }
        
        /* ========== STATUS BADGES ========== */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            white-space: nowrap;
        }
        
        .status-pending {
            background: linear-gradient(135deg, var(--warning-500, #f59e0b), var(--warning-600, #d97706));
            color: white;
        }
        
        .status-approved {
            background: linear-gradient(135deg, var(--success-500, #22c55e), var(--success-600, #16a34a));
            color: white;
        }
        
        .status-rejected {
            background: linear-gradient(135deg, var(--error-500, #ef4444), var(--error-600, #dc2626));
            color: white;
        }
        
        .status-receiving {
            background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
            color: white;
        }
        
        .status-completed {
            background: linear-gradient(135deg, var(--success-500, #22c55e), var(--success-600, #16a34a));
            color: white;
        }
        
        /* ========== MISC ========== */
        .amount {
            font-weight: 800;
            color: var(--success-600);
            font-size: 16px;
        }
        
        .po-id {
            font-family: 'SF Mono', 'Monaco', 'Courier New', monospace;
            background: var(--gray-100);
            padding: 6px 10px;
            border-radius: var(--radius-sm);
            font-size: 12px;
            font-weight: 600;
            color: var(--gray-700);
            border: 1px solid var(--gray-200);
        }
        
        .date-display {
            font-family: 'SF Mono', 'Monaco', 'Courier New', monospace;
            font-size: 13px;
            font-weight: 500;
            color: var(--gray-700);
        }
        
        .debug-info {
            background: var(--primary-50);
            padding: 20px;
            margin: 20px 0;
            border-radius: var(--radius-md);
            border-left: 4px solid var(--primary-500);
            box-shadow: var(--shadow);
        }
        
        .error-info {
            background: var(--danger-50);
            padding: 20px;
            margin: 20px 0;
            border-radius: var(--radius-md);
            border-left: 4px solid var(--danger-500);
            color: var(--danger-600);
            box-shadow: var(--shadow);
        }
        
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: var(--gray-500);
        }
        
        .empty-state h3 {
            font-size: 1.8em;
            margin-bottom: 15px;
            color: var(--gray-700);
            font-weight: 700;
        }
        
        .empty-state p {
            margin-bottom: 25px;
            font-size: 15px;
        }
        
        /* ========== MODALS ========== */
        .modal {
            display: none;
            position: fixed;
            z-index: 999999;
            left: 0;
            top: 0;
            width: 100%;
            height: 100vh;
            background: rgba(17, 24, 39, 0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            overflow-y: auto;
            overflow-x: hidden;
            animation: fadeIn 0.2s ease;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-40px) scale(0.95);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }
        
        .modal-content {
            background: white;
            margin: 60px auto 30px auto;
            padding: 0;
            border-radius: 16px;
            width: 92%;
            max-width: 900px;
            max-height: calc(100vh - 100px);
            overflow-y: auto;
            overflow-x: hidden;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4);
            animation: modalSlideIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
            position: relative;
            border: 1px solid var(--color-primary);
            box-sizing: border-box;
        }
        
        .modal-header {
            background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
            color: white;
            padding: 25px 35px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            overflow: hidden;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .modal-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--secondary-500));
        }
        
        .modal-header h2 {
            margin: 0;
            margin-top: 4px;
            font-size: 24px;
            font-weight: 800;
            color: white;
            display: flex;
            align-items: center;
            gap: 12px;
            position: relative;
            z-index: 1;
        }
        
        .modal-header .close {
            color: white;
            margin-top: 4px;
        }
        
        .modal-header .close:hover {
            color: rgba(255, 255, 255, 0.8);
        }
        
        .close {
            color: var(--gray-600, #6b7280);
            font-size: 28px;
            font-weight: bold;
            line-height: 1;
            cursor: pointer;
            transition: all 0.2s;
            background: rgba(255,255,255,0.15);
            width: 40px;
            height: 40px;
            min-width: 40px;
            min-height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            position: relative;
            z-index: 1;
            flex-shrink: 0;
        }
        
        .close:hover {
            background: rgba(239, 68, 68, 0.9);
            transform: rotate(90deg) scale(1.1);
        }
        
        .modal-body {
            padding: 35px;
            max-height: calc(100vh - 260px);
            overflow-y: auto;
        }
        
        .modal-body::-webkit-scrollbar {
            width: 8px;
        }
        
        .modal-body::-webkit-scrollbar-track {
            background: var(--gray-100);
            border-radius: 10px;
        }
        
        .modal-body::-webkit-scrollbar-thumb {
            background: var(--gray-400);
            border-radius: 10px;
        }
        
        .modal-body::-webkit-scrollbar-thumb:hover {
            background: var(--gray-500);
        }
        
        .modal-footer {
            padding: 25px 35px;
            border-top: 2px solid var(--gray-100);
            background: var(--gray-50);
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        
        /* ========== FORMS ========== */
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 10px;
            font-weight: 700;
            color: var(--gray-800);
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid var(--gray-200);
            border-radius: var(--radius);
            font-size: 15px;
            font-family: inherit;
            transition: var(--transition);
            box-sizing: border-box;
            background: white;
        }
        
        .form-group input:hover,
        .form-group select:hover,
        .form-group textarea:hover {
            border-color: var(--gray-300);
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--primary-500);
            box-shadow: 0 0 0 4px var(--primary-100);
            transform: translateY(-1px);
        }
        
        .form-group.required label::after {
            content: ' *';
            color: var(--danger-500);
            font-weight: 900;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        
        .form-row.full {
            grid-template-columns: 1fr;
        }
        
        /* ========== ITEMS SECTION ========== */
        .items-section {
            border: 3px solid var(--gray-200);
            border-radius: var(--radius-md);
            padding: 25px;
            margin-bottom: 24px;
            background: linear-gradient(135deg, var(--gray-50), white);
            position: relative;
            overflow: hidden;
        }
        
        .items-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--success-500));
        }
        
        .items-section h4 {
            margin: 0 0 20px 0;
            color: var(--gray-800);
            font-size: 18px;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .items-section h4::before {
            content: '📝';
            font-size: 24px;
        }
        
        .item-row {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr auto;
            gap: 15px;
            align-items: end;
            margin-bottom: 16px;
            padding: 18px;
            background: white;
            border-radius: var(--radius);
            border: 2px solid var(--gray-200);
            transition: var(--transition);
        }
        
        .item-row:hover {
            border-color: var(--primary-300);
            box-shadow: var(--shadow-md);
            transform: translateX(4px);
        }
        
        .item-row input {
            margin-bottom: 0;
        }
        
        .btn-remove-item {
            background: linear-gradient(135deg, var(--danger-600), var(--danger-500));
            color: white;
            border: none;
            border-radius: var(--radius);
            padding: 10px 14px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 700;
            transition: var(--transition);
            box-shadow: var(--shadow);
        }
        
        .btn-remove-item:hover {
            transform: scale(1.1) rotate(5deg);
            box-shadow: var(--shadow-md);
        }
        
        .btn-add-item {
            background: linear-gradient(135deg, var(--success-600), var(--success-500));
            color: white;
            border: none;
            border-radius: var(--radius);
            padding: 12px 24px;
            cursor: pointer;
            font-weight: 700;
            font-size: 14px;
            transition: var(--transition);
            box-shadow: var(--shadow);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-add-item::before {
            content: '+';
            font-size: 20px;
            font-weight: 900;
        }
        
        .btn-add-item:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        /* ========== TOTAL SECTION ========== */
        .total-section {
            background: linear-gradient(135deg, var(--success-50), white);
            padding: 25px;
            border-radius: var(--radius-md);
            border: 3px solid var(--success-200);
            margin-bottom: 24px;
            position: relative;
            overflow: hidden;
        }
        
        .total-section::before {
            content: '💰';
            position: absolute;
            font-size: 100px;
            right: -20px;
            top: 50%;
            transform: translateY(-50%);
            opacity: 0.1;
        }
        
        .total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 18px;
            font-weight: bold;
        }
        
        .total-amount {
            color: #10b981;
            font-size: 24px;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
        }
        
        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .item-row {
                grid-template-columns: 1fr;
                gap: 10px;
            }
            
            .form-actions {
                flex-direction: column;
            }
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .page-header {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
                padding: 20px;
            }
            
            .page-title {
                font-size: 24px;
            }
            
            .filters {
                flex-direction: column;
                padding: 20px;
            }
            
            .search-box {
                min-width: auto;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .po-table {
                min-width: 1000px;
            }
            
            .po-table th,
            .po-table td {
                padding: 14px 12px;
                font-size: 13px;
            }
            
            .modal-content {
                width: 95%;
                margin: 20px auto;
            }
        }
        
        @media (max-width: 480px) {
            .page-title {
                font-size: 20px;
            }
            
            .po-table {
                min-width: 900px;
            }
            
            .po-table th,
            .po-table td {
                padding: 12px 10px;
                font-size: 12px;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/includes/header.jsp">
        <jsp:param name="page" value="procurement"/>
    </jsp:include>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">
                <span class="icon">📦</span>
                Quản lý Đơn đặt hàng
            </h1>
            <div>
                <button class="btn-success" onclick="openCreateModal()">
                    <i class='bx bx-plus'></i>
                    Tạo Đơn hàng
                </button>
                <button class="btn-primary" onclick="exportPOs()">
                    <i class='bx bx-download'></i>
                    Xuất báo cáo
                </button>
            </div>
        </div>


        <!-- Error Display -->
        <c:if test="${not empty param.error}">
            <div class="error-info" style="background: #fee; border-left: 4px solid #e00; padding: 20px; margin-bottom: 20px; border-radius: 8px;">
                <h3 style="color: #c00; margin: 0 0 10px 0;">⚠️ Lỗi</h3>
                <p style="margin: 0; color: #333;">${param.error}</p>
            </div>
        </c:if>
        
        <!-- Success Display -->
        <c:if test="${not empty param.status}">
            <div class="success-info" style="background: #efe; border-left: 4px solid #0a0; padding: 20px; margin-bottom: 20px; border-radius: 8px;">
                <h3 style="color: #0a0; margin: 0 0 10px 0;">✅ Thành công</h3>
                <p style="margin: 0; color: #333;">
                    <c:choose>
                        <c:when test="${param.status == 'created'}">Đã tạo đơn hàng thành công!</c:when>
                        <c:when test="${param.status == 'approved'}">Đã duyệt đơn hàng thành công!</c:when>
                        <c:when test="${param.status == 'rejected'}">Đã từ chối đơn hàng!</c:when>
                        <c:otherwise>Thao tác thành công!</c:otherwise>
                    </c:choose>
                </p>
            </div>
        </c:if>

        <!-- Filters -->
        <div class="filters">
            <div class="search-box">
                <input type="text" id="searchInput" placeholder="Tìm kiếm đơn hàng, nhà cung cấp..." onkeyup="filterTable()">
            </div>
            <select class="filter-select" id="statusFilter" onchange="filterTable()">
                <option value="">Tất cả trạng thái</option>
                <option value="PENDING">Chờ duyệt</option>
                <option value="APPROVED">Đã duyệt</option>
                <option value="REJECTED">Từ chối</option>
                <option value="RECEIVING">Đang nhận hàng</option>
                <option value="COMPLETED">Hoàn thành</option>
            </select>
            <input type="date" class="filter-select" id="dateFilter" onchange="filterTable()">
        </div>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card pending">
                <div class="stat-number" id="pendingCount">0</div>
                <div class="stat-label">Chờ duyệt</div>
            </div>
            <div class="stat-card approved">
                <div class="stat-number" id="approvedCount">0</div>
                <div class="stat-label">Đã duyệt</div>
            </div>
            <div class="stat-card rejected">
                <div class="stat-number" id="rejectedCount">0</div>
                <div class="stat-label">Từ chối</div>
            </div>
            <div class="stat-card total">
                <div class="stat-number" id="totalCount">0</div>
                <div class="stat-label">Tổng đơn hàng</div>
            </div>
        </div>

        <!-- Purchase Orders Table -->
        <div class="table-wrapper">
        <table class="po-table" id="poTable">
            <thead>
                <tr>
                    <th>Mã PO</th>
                    <th>Nhà cung cấp</th>
                    <th>Ngày tạo</th>
                    <th>Ngày giao dự kiến</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th>Người tạo</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty purchaseOrders}">
                        <tr>
                            <td colspan="8" class="empty-state">
                                <c:choose>
                                    <c:when test="${not empty error}">
                                        <h3>⚠️ Lỗi tải dữ liệu</h3>
                                        <p>${error}</p>
                                        <a href="/LiteFlow/dashboard" class="btn-primary">Quay về Dashboard</a>
                                    </c:when>
                                    <c:otherwise>
                                        <h3>📋 Chưa có đơn đặt hàng</h3>
                                        <p>Hãy tạo đơn hàng đầu tiên hoặc kiểm tra kết nối database.</p>
                                        <button class="btn-success" onclick="openCreateModal()">Tạo đơn hàng đầu tiên</button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="po" items="${purchaseOrders}">
                            <tr>
                                <td>
                                    <span class="po-id">PO-${po.poid.toString().substring(0,8)}</span>
                                </td>
                                <td>
                                    <c:forEach var="supplier" items="${suppliers}">
                                        <c:if test="${supplier.supplierID.toString() == po.supplierID.toString()}">
                                            ${supplier.name}
                                        </c:if>
                                    </c:forEach>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.createDate != null}">
                                            <span class="date-display" data-date="${po.createDate}">${po.createDate}</span>
                                        </c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${po.expectedDelivery != null}">
                                            <span class="date-display" data-date="${po.expectedDelivery}">${po.expectedDelivery}</span>
                                        </c:when>
                                        <c:otherwise>Chưa xác định</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="amount">
                                    <c:choose>
                                        <c:when test="${po.totalAmount != null}">
                                            ${po.totalAmount} ₫
                                        </c:when>
                                        <c:otherwise>0 ₫</c:otherwise>
                                    </c:choose>
                                </td>
                                <td data-status="${po.status}">
                                    <c:choose>
                                        <c:when test="${po.status == 'PENDING'}">
                                            <span class="status-badge status-pending">Chờ duyệt</span>
                                        </c:when>
                                        <c:when test="${po.status == 'APPROVED'}">
                                            <span class="status-badge status-approved">Đã duyệt</span>
                                        </c:when>
                                        <c:when test="${po.status == 'REJECTED'}">
                                            <span class="status-badge status-rejected">Từ chối</span>
                                        </c:when>
                                        <c:when test="${po.status == 'RECEIVING'}">
                                            <span class="status-badge status-receiving">Đang nhận hàng</span>
                                        </c:when>
                                        <c:when test="${po.status == 'COMPLETED'}">
                                            <span class="status-badge status-completed">Hoàn thành</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-pending">${po.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    ${po.createdBy != null ? po.createdBy.toString().substring(0,8) : 'N/A'}
                                </td>
                                <td>
                                    <div style="display: flex; gap: 5px; flex-wrap: wrap;">
                                        <c:if test="${po.status == 'PENDING'}">
                                            <button class="btn-success" onclick="approvePO('${po.poid}')">Duyệt</button>
                                            <button class="btn-danger" onclick="rejectPO('${po.poid}')">Từ chối</button>
                                        </c:if>
                                        <c:if test="${po.status == 'APPROVED'}">
                                            <button class="btn-info" onclick="receiveGoods('${po.poid}')">Nhận hàng</button>
                                        </c:if>
                                        <c:if test="${po.status == 'RECEIVING'}">
                                            <button class="btn-info" onclick="receiveGoods('${po.poid}')">Tiếp tục nhận hàng</button>
                                        </c:if>
                                        <button class="btn-warning" onclick="viewDetails('${po.poid}')">Chi tiết</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        </div>
    </div>

    <!-- Create PO Modal -->
    <div id="createModal" class="modal">
        <div class="modal-content" style="max-width: 1000px;">
            <div class="modal-header">
                <h2>📋 Tạo Đơn đặt hàng mới</h2>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="createPOForm" action="${pageContext.request.contextPath}/procurement/po" method="post" onsubmit="return validateAndCleanForm()">
                    <input type="hidden" name="action" value="create">
                    
                    <!-- Basic Information -->
                    <div class="form-row">
                        <div class="form-group required">
                            <label for="supplierSelect">Nhà cung cấp</label>
                            <select id="supplierSelect" name="supplierID" required>
                                <option value="">Chọn nhà cung cấp</option>
                                <c:forEach var="supplier" items="${suppliers}">
                                    <option value="${supplier.supplierID}">${supplier.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group required">
                            <label for="expectedDelivery">Ngày giao dự kiến</label>
                            <input type="datetime-local" id="expectedDelivery" name="expectedDelivery" required>
                        </div>
                    </div>
                    
                    <div class="form-row full">
                        <div class="form-group">
                            <label for="notes">Ghi chú</label>
                            <textarea id="notes" name="notes" rows="3" placeholder="Nhập ghi chú cho đơn hàng..."></textarea>
                        </div>
                    </div>
                    
                    <!-- Items Section -->
                    <div class="items-section">
                        <h4>📦 Chi tiết sản phẩm</h4>
                        <div id="itemsContainer">
                            <div class="item-row">
                                <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                                <input type="text" name="quantity" placeholder="Số lượng" required oninput="formatNumber(this)" onblur="formatNumber(this)">
                                <input type="text" name="unitPrice" placeholder="Đơn giá (₫)" required oninput="formatNumber(this)" onblur="formatNumber(this)">
                                <input type="text" name="total" placeholder="Thành tiền" readonly>
                                <button type="button" class="btn-remove-item" onclick="removeItem(this)" style="display: none;">🗑️</button>
                            </div>
                        </div>
                        <button type="button" class="btn-add-item" onclick="addItem()">
                            ➕ Thêm sản phẩm
                        </button>
                    </div>
                    
                    <!-- Total Section -->
                    <div class="total-section">
                        <div class="total-row">
                            <span>Tổng tiền:</span>
                            <span id="totalAmount" class="total-amount">0 ₫</span>
                        </div>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="form-actions">
                        <button type="button" class="btn-primary" onclick="closeModal()">Hủy</button>
                        <button type="submit" class="btn-success">✅ Tạo đơn hàng</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Details Modal -->
    <div id="detailsModal" class="modal">
        <div class="modal-content" style="max-width: 900px;">
            <div class="modal-header">
                <h2>📋 Chi tiết Đơn đặt hàng</h2>
                <span class="close" onclick="closeDetailsModal()">&times;</span>
            </div>
            <div class="modal-body" id="detailsContent">
                <div style="text-align: center; padding: 40px;">
                    <div class="spinner"></div>
                    <p>Đang tải...</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Receive Goods Modal -->
    <div id="receiveModal" class="modal">
        <div class="modal-content" style="max-width: 1000px;">
            <div class="modal-header">
                <h2>📦 Nhận hàng</h2>
                <span class="close" onclick="closeReceiveModal()">&times;</span>
            </div>
            <div class="modal-body" id="receiveContent">
                <div style="text-align: center; padding: 40px;">
                    <div class="spinner"></div>
                    <p>Đang tải...</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Statistics calculation
        function updateStatistics() {
            const rows = document.querySelectorAll('#poTable tbody tr');
            let pending = 0, approved = 0, rejected = 0, receiving = 0, completed = 0, total = 0;
            
            rows.forEach(row => {
                // Skip empty state row AND hidden rows
                if (row.cells.length > 1 && row.style.display !== 'none') {
                    total++;
                    const statusCell = row.cells[5];
                    if (statusCell) {
                        // Use data-status attribute instead of text content
                        const status = statusCell.getAttribute('data-status');
                        if (status === 'PENDING') pending++;
                        else if (status === 'APPROVED') approved++;
                        else if (status === 'REJECTED') rejected++;
                        else if (status === 'RECEIVING') receiving++;
                        else if (status === 'COMPLETED') completed++;
                    }
                }
            });
            
            document.getElementById('pendingCount').textContent = pending;
            document.getElementById('approvedCount').textContent = approved;
            document.getElementById('rejectedCount').textContent = rejected;
            document.getElementById('totalCount').textContent = total;
        }

        // Filter table
        function filterTable() {
            const statusFilter = document.getElementById('statusFilter').value;
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const dateFilter = document.getElementById('dateFilter').value;
            const table = document.getElementById('poTable');
            const rows = table.getElementsByTagName('tr');

            console.log('Filter - Status:', statusFilter, 'Search:', searchInput, 'Date:', dateFilter);

            for (let i = 1; i < rows.length; i++) {
                const row = rows[i];
                if (row.cells.length <= 1) continue; // Skip empty state row
                
                const statusCell = row.cells[5];
                const supplierCell = row.cells[1];
                const dateCell = row.cells[2];
                
                let show = true;

                // Status filter - use data-status attribute instead of text
                if (statusFilter) {
                    const statusValue = statusCell.getAttribute('data-status');
                    if (statusValue !== statusFilter) {
                        show = false;
                    }
                }

                // Search filter
                if (searchInput) {
                    const rowText = row.textContent.toLowerCase();
                    if (!rowText.includes(searchInput)) {
                        show = false;
                    }
                }

                // Date filter - compare dates properly
                if (dateFilter) {
                    const cellDateText = dateCell.textContent.trim();
                    // Extract date from format "dd/MM/yyyy HH:mm" or "dd/MM/yyyy"
                    const cellDate = cellDateText.split(' ')[0]; // Get date part only
                    // Convert filter date from yyyy-MM-dd to dd/MM/yyyy for comparison
                    const filterParts = dateFilter.split('-');
                    const filterDateFormatted = filterParts[2] + '/' + filterParts[1] + '/' + filterParts[0];
                    if (cellDate !== filterDateFormatted) {
                        show = false;
                    }
                }

                row.style.display = show ? '' : 'none';
            }
            
            updateStatistics();
        }

        // Action functions
        function approvePO(poId) {
            if (confirm('Bạn có chắc chắn muốn duyệt đơn hàng này?')) {
                console.log('=== approvePO START ===');
                console.log('POID:', poId);
                
                // Create form and submit
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/procurement/po';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'approve';
                
                const poidInput = document.createElement('input');
                poidInput.type = 'hidden';
                poidInput.name = 'poid';
                poidInput.value = poId;
                
                const levelInput = document.createElement('input');
                levelInput.type = 'hidden';
                levelInput.name = 'level';
                levelInput.value = '1'; // Default approval level
                
                form.appendChild(actionInput);
                form.appendChild(poidInput);
                form.appendChild(levelInput);
                
                document.body.appendChild(form);
                console.log('Form created, submitting...');
                form.submit();
            }
        }

        function rejectPO(poId) {
            const reason = prompt('Lý do từ chối:');
            if (reason && reason.trim() !== '') {
                console.log('=== rejectPO START ===');
                console.log('POID:', poId);
                console.log('Reason:', reason);
                
                // Create form and submit
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/procurement/po';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'reject';
                
                const poidInput = document.createElement('input');
                poidInput.type = 'hidden';
                poidInput.name = 'poid';
                poidInput.value = poId;
                
                const reasonInput = document.createElement('input');
                reasonInput.type = 'hidden';
                reasonInput.name = 'reason';
                reasonInput.value = reason;
                
                form.appendChild(actionInput);
                form.appendChild(poidInput);
                form.appendChild(reasonInput);
                
                document.body.appendChild(form);
                console.log('Form created, submitting...');
                form.submit();
            }
        }

        function receiveGoods(poId) {
            console.log('=== receiveGoods START ===');
            console.log('POID:', poId);
            
            const modal = document.getElementById('receiveModal');
            const content = document.getElementById('receiveContent');
            
            if (!modal) {
                console.error('ERROR: receiveModal not found!');
                alert('Lỗi: Không tìm thấy modal nhận hàng');
                return;
            }
            
            // Store POID for later use
            modal.setAttribute('data-poid', poId);
            
            console.log('Modal found, showing...');
            modal.style.display = 'block';
            modal.style.visibility = 'visible';
            modal.style.opacity = '1';
            
            // Show loading
            content.innerHTML = '<div style="text-align:center;padding:40px;"><div style="border:4px solid #f3f4f6;border-top:4px solid #3b82f6;border-radius:50%;width:40px;height:40px;animation:spin 1s linear infinite;margin:0 auto;"></div><p style="margin-top:20px;">Đang tải thông tin đơn hàng...</p></div>';
            
            // Fetch PO details
            const contextPath = '${pageContext.request.contextPath}';
            const url = contextPath + '/procurement/po?action=details&poid=' + poId;
            console.log('Fetching URL:', url);
            
            fetch(url)
                .then(response => {
                    console.log('Response received. Status:', response.status);
                    if (!response.ok) {
                        throw new Error('HTTP ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Data parsed successfully:', data);
                    if (data.error) {
                        console.error('Server returned error:', data.error);
                        content.innerHTML = '<div style="color:red;padding:20px;"><strong>❌ Lỗi:</strong> ' + data.error + '</div>';
                        return;
                    }
                    console.log('Rendering receive goods form...');
                    renderReceiveGoodsForm(data);
                    console.log('=== receiveGoods END SUCCESS ===');
                })
                .catch(error => {
                    console.error('=== FETCH ERROR ===', error);
                    content.innerHTML = '<div style="color:red;padding:20px;"><strong>❌ Lỗi kết nối:</strong> ' + error.message + '</div>';
                });
        }
        
        function renderReceiveGoodsForm(po) {
            console.log('=== renderReceiveGoodsForm START ===');
            console.log('PO data:', po);
            console.log('PO status:', po.status);
            console.log('Received quantities:', po.receivedQuantities);
            
            const content = document.getElementById('receiveContent');
            
            if (!content) {
                console.error('ERROR: receiveContent not found!');
                return;
            }
            
            let itemsHtml = '';
            let totalOrdered = 0;
            const receivedQuantities = po.receivedQuantities || {};
            const isReceiving = po.status === 'RECEIVING';
            
            console.log('isReceiving:', isReceiving);
            console.log('receivedQuantities:', receivedQuantities);
            
            if (!po.items || po.items.length === 0) {
                itemsHtml = '<tr><td colspan="6" style="text-align:center;padding:20px;color:#999;">Không có sản phẩm</td></tr>';
            } else {
                po.items.forEach((item, idx) => {
                    const qty = parseFloat(item.quantity) || 0;
                    const price = parseFloat(item.unitPrice) || 0;
                    const itemTotal = qty * price;
                    totalOrdered += itemTotal;
                    
                    // Get already received quantity (tổng từ tất cả các lần nhận trước)
                    const alreadyReceived = receivedQuantities[item.itemName] || 0;
                    const remainingQty = Math.max(0, qty - alreadyReceived);
                    
                    // Status badge
                    let statusHtml = '';
                    if (isReceiving && alreadyReceived > 0) {
                        if (alreadyReceived >= qty) {
                            statusHtml = '<span style="color:#10b981;font-size:0.85em;">✓ Đã nhận đủ</span>';
                        } else {
                            statusHtml = '<span style="color:#f59e0b;font-size:0.85em;">📦 Đã nhận: ' + alreadyReceived + '/' + qty + '</span>';
                        }
                    }
                    
                    let cellsHtml = '';
                    
                    if (isReceiving) {
                        // Trạng thái RECEIVING: hiển thị Số lượng đặt, Số lượng đã nhận, Số lượng tiếp tục nhận
                        const defaultValue = remainingQty > 0 ? remainingQty : 0;
                        const maxValue = remainingQty * 2; // Allow some over-receipt
                        
                        cellsHtml = 
                        '<td style="text-align:right">' + qty.toLocaleString('vi-VN') + '</td>' +
                        '<td style="text-align:right;color:#10b981;font-size:0.95em;font-weight:600;">' + 
                            alreadyReceived.toLocaleString('vi-VN') + 
                        '</td>' +
                        '<td style="text-align:center">' +
                            '<input type="number" ' +
                            'class="received-qty-input" ' +
                            'data-item-name="' + (item.itemName || '').replace(/"/g, '&quot;') + '" ' +
                            'data-ordered-qty="' + qty + '" ' +
                            'data-already-received="' + alreadyReceived + '" ' +
                            'min="0" ' +
                            'max="' + (maxValue > 0 ? maxValue : qty * 2) + '" ' +
                            'value="' + defaultValue + '" ' +
                            'placeholder="0" ' +
                            'style="width:80px;padding:5px;text-align:center;border:1px solid #ddd;border-radius:4px;" ' +
                            'onchange="validateReceivedQuantity(this)" ' +
                            (remainingQty <= 0 && alreadyReceived > 0 ? 'disabled title="Đã nhận đủ số lượng"' : 'required') + '>' +
                        '</td>';
                    } else {
                        // Trạng thái APPROVED: hiển thị Số lượng đặt, Số lượng nhận
                        cellsHtml = 
                        '<td style="text-align:right">' + qty.toLocaleString('vi-VN') + '</td>' +
                        '<td style="text-align:center">' +
                            '<input type="number" ' +
                            'class="received-qty-input" ' +
                            'data-item-name="' + (item.itemName || '').replace(/"/g, '&quot;') + '" ' +
                            'data-ordered-qty="' + qty + '" ' +
                            'data-already-received="0" ' +
                            'min="0" ' +
                            'max="' + (qty * 2) + '" ' +
                            'value="' + qty + '" ' +
                            'style="width:80px;padding:5px;text-align:center;border:1px solid #ddd;border-radius:4px;" ' +
                            'onchange="validateReceivedQuantity(this)" ' +
                            'required>' +
                        '</td>';
                    }
                    
                    itemsHtml += '<tr>' +
                        '<td>' + (idx + 1) + '</td>' +
                        '<td><strong>' + (item.itemName || 'N/A') + '</strong><br/>' + statusHtml + '</td>' +
                        cellsHtml +
                        '<td style="text-align:center">' +
                            '<select class="quality-status-select" style="padding:5px;border:1px solid #ddd;border-radius:4px;">' +
                            '<option value="OK" selected>OK</option>' +
                            '<option value="DEFECTIVE">Lỗi</option>' +
                            '<option value="DAMAGED">Hư hỏng</option>' +
                            '<option value="EXPIRED">Hết hạn</option>' +
                            '</select>' +
                        '</td>' +
                        '</tr>';
                });
            }
            
            const shortPoid = (po.poid || '').length > 8 ? po.poid.substring(0,8).toUpperCase() : (po.poid || 'N/A');
            
            content.innerHTML = '<div style="padding: 20px;">' +
                '<div style="background:#f0f9ff;padding:15px;border-radius:8px;margin-bottom:20px;border-left:4px solid #3b82f6;">' +
                '<p style="margin:5px 0;"><strong>Mã đơn:</strong> ' + shortPoid + '</p>' +
                '<p style="margin:5px 0;"><strong>Nhà cung cấp:</strong> ' + (po.supplierName || 'N/A') + '</p>' +
                '<p style="margin:5px 0;"><strong>Tổng tiền đặt hàng:</strong> <span style="color:#10b981;font-weight:bold">' + (po.totalAmount || 0).toLocaleString('vi-VN') + ' ₫</span></p>' +
                '</div>' +
                '<h3 style="margin-bottom:15px;">' + 
                    (isReceiving ? '📦 Tiếp tục nhận hàng - Danh sách sản phẩm' : '📦 Danh sách sản phẩm nhận hàng') + 
                '</h3>' +
                (isReceiving && Object.keys(receivedQuantities).length > 0 && Object.values(receivedQuantities).some(qty => qty > 0) ? 
                    '<div style="background:#fff3cd;padding:10px;border-radius:6px;margin-bottom:15px;border-left:4px solid #ffc107;"><strong>ℹ️ Lưu ý:</strong> Đơn hàng này đã nhận một phần. Vui lòng nhập số lượng tiếp tục nhận cho từng sản phẩm.</div>' : '') +
                '<table class="po-table" style="width:100%;">' +
                '<thead>' +
                '<tr>' +
                '<th style="width:50px">#</th>' +
                '<th>Tên sản phẩm</th>' +
                '<th style="width:100px">Số lượng đặt</th>' +
                (isReceiving ? 
                    '<th style="width:120px">Số lượng đã nhận</th>' +
                    '<th style="width:120px">Số lượng tiếp tục nhận</th>' :
                    '<th style="width:120px">Số lượng nhận</th>'
                ) +
                '<th style="width:150px">Trạng thái chất lượng</th>' +
                '</tr>' +
                '</thead>' +
                '<tbody>' +
                itemsHtml +
                '</tbody>' +
                '</table>' +
                '<div style="margin-top:20px;">' +
                '<label for="receiveNotes" style="display:block;margin-bottom:8px;font-weight:bold;">Ghi chú nhận hàng:</label>' +
                '<textarea id="receiveNotes" rows="3" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:4px;font-family:inherit;" placeholder="Ghi chú về tình trạng hàng hóa, chất lượng, lý do chênh lệch (nếu có)..."></textarea>' +
                '</div>' +
                '<div style="margin-top:20px;text-align:right;">' +
                '<button type="button" class="btn" onclick="closeReceiveModal()" style="margin-right:10px;">Hủy</button>' +
                '<button type="button" class="btn btn-success" onclick="submitReceiveGoods()">Xác nhận nhận hàng</button>' +
                '</div>' +
                '</div>';
            
            console.log('=== renderReceiveGoodsForm END SUCCESS ===');
        }
        
        function validateReceivedQuantity(input) {
            const orderedQty = parseInt(input.getAttribute('data-ordered-qty')) || 0;
            const alreadyReceived = parseInt(input.getAttribute('data-already-received')) || 0;
            const receivedQty = parseInt(input.value) || 0;
            const remainingQty = Math.max(0, orderedQty - alreadyReceived);
            const totalReceivedAfter = alreadyReceived + receivedQty;
            
            // Reset styles
            input.style.borderColor = '#ddd';
            input.style.backgroundColor = '#fff';
            
            // Remove existing warning message
            const existingWarning = input.parentElement.querySelector('.over-receipt-warning');
            if (existingWarning) {
                existingWarning.remove();
            }
            
            if (receivedQty < 0) {
                input.value = 0;
                return;
            }
            
            // Check if receiving more than ordered quantity
            if (totalReceivedAfter > orderedQty) {
                const overAmount = totalReceivedAfter - orderedQty;
                const overPercent = ((overAmount / orderedQty) * 100).toFixed(1);
                
                // Visual warning
                input.style.borderColor = '#f59e0b';
                input.style.backgroundColor = '#fffbeb';
                
                // Add warning message
                const warningMsg = document.createElement('div');
                warningMsg.className = 'over-receipt-warning';
                warningMsg.style.cssText = 'margin-top:5px;padding:8px;background:#fff3cd;border-left:3px solid #ffc107;border-radius:4px;font-size:0.85em;color:#856404;';
                warningMsg.innerHTML = '⚠️ <strong>Nhận vượt số lượng đặt:</strong> Đã nhận ' + totalReceivedAfter.toLocaleString('vi-VN') + 
                                     ' / Đặt ' + orderedQty.toLocaleString('vi-VN') + 
                                     ' (<span style="color:#dc2626;font-weight:bold">+' + overAmount.toLocaleString('vi-VN') + ' (' + overPercent + '%)</span>)';
                
                input.parentElement.appendChild(warningMsg);
                
                // If over-receipt is too high (more than 20%), show stronger warning
                if (overPercent > 20) {
                    input.style.borderColor = '#ef4444';
                    input.style.backgroundColor = '#fee2e2';
                    warningMsg.style.background = '#fee2e2';
                    warningMsg.style.borderLeftColor = '#ef4444';
                    warningMsg.style.color = '#991b1b';
                }
            } else if (totalReceivedAfter === orderedQty) {
                // Exactly ordered quantity - green
                input.style.borderColor = '#10b981';
                input.style.backgroundColor = '#ecfdf5';
            } else if (totalReceivedAfter < orderedQty && totalReceivedAfter > 0) {
                // Partial receipt - blue
                input.style.borderColor = '#3b82f6';
                input.style.backgroundColor = '#eff6ff';
            }
        }
        
        function submitReceiveGoods() {
            const modal = document.getElementById('receiveModal');
            const poid = modal.getAttribute('data-poid');
            
            if (!poid) {
                alert('❌ Lỗi: Không tìm thấy mã đơn hàng');
                return;
            }
            
            // Collect received items
            const inputs = document.querySelectorAll('.received-qty-input');
            const items = [];
            
            inputs.forEach((input, idx) => {
                const itemName = input.getAttribute('data-item-name');
                const orderedQty = parseInt(input.getAttribute('data-ordered-qty')) || 0;
                const receivedQty = parseInt(input.value) || 0;
                
                // Get quality status from corresponding select
                const qualitySelects = document.querySelectorAll('.quality-status-select');
                const qualityStatus = qualitySelects[idx] ? qualitySelects[idx].value : 'OK';
                
                items.push({
                    itemName: itemName,
                    orderedQuantity: orderedQty,
                    receivedQuantity: receivedQty,
                    qualityStatus: qualityStatus
                });
            });
            
            // Validate at least one item has received quantity > 0
            const hasReceived = items.some(item => item.receivedQuantity > 0);
            if (!hasReceived) {
                alert('⚠️ Vui lòng nhập số lượng nhận cho ít nhất 1 sản phẩm');
                return;
            }
            
            // Check for over-receipt (total received > ordered)
            let hasOverReceipt = false;
            let overReceiptItems = [];
            items.forEach(item => {
                const orderedQty = item.orderedQuantity;
                const receivedQty = item.receivedQuantity;
                
                // Get already received quantity from input attribute
                const input = Array.from(inputs).find(inp => inp.getAttribute('data-item-name') === item.itemName);
                const alreadyReceived = input ? parseInt(input.getAttribute('data-already-received')) || 0 : 0;
                const totalReceived = alreadyReceived + receivedQty;
                
                if (totalReceived > orderedQty) {
                    hasOverReceipt = true;
                    const overAmount = totalReceived - orderedQty;
                    const overPercent = ((overAmount / orderedQty) * 100).toFixed(1);
                    overReceiptItems.push(item.itemName + ' (+' + overAmount + ', +' + overPercent + '%)');
                }
            });
            
            // Get notes
            const notes = document.getElementById('receiveNotes') ? document.getElementById('receiveNotes').value : '';
            
            // Confirm with over-receipt warning if needed
            let confirmMsg = 'Xác nhận nhận hàng cho đơn ' + poid.substring(0, 8).toUpperCase() + '?';
            if (hasOverReceipt) {
                confirmMsg = '⚠️ PHÁT HIỆN NHẬN VƯỢT SỐ LƯỢNG ĐẶT:\n\n' +
                            overReceiptItems.join('\n') +
                            '\n\nBạn có chắc chắn muốn tiếp tục? Hệ thống sẽ ghi nhận chênh lệch này.';
            }
            
            if (!confirm(confirmMsg)) {
                return;
            }
            
            // Submit
            const contextPath = '${pageContext.request.contextPath}';
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = contextPath + '/procurement/po';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'receive';
            
            const poidInput = document.createElement('input');
            poidInput.type = 'hidden';
            poidInput.name = 'poid';
            poidInput.value = poid;
            
            const itemsInput = document.createElement('input');
            itemsInput.type = 'hidden';
            itemsInput.name = 'items';
            itemsInput.value = JSON.stringify(items);
            
            const notesInput = document.createElement('input');
            notesInput.type = 'hidden';
            notesInput.name = 'notes';
            notesInput.value = notes;
            
            form.appendChild(actionInput);
            form.appendChild(poidInput);
            form.appendChild(itemsInput);
            form.appendChild(notesInput);
            
            document.body.appendChild(form);
            console.log('Submitting receive goods form...');
            form.submit();
        }
        
        function closeReceiveModal() {
            const modal = document.getElementById('receiveModal');
            if (modal) {
                modal.style.display = 'none';
                modal.removeAttribute('data-poid');
            }
        }
        
        // Close modal when clicking outside
        window.addEventListener('click', function(event) {
            const receiveModal = document.getElementById('receiveModal');
            if (receiveModal && event.target === receiveModal) {
                closeReceiveModal();
            }
        });

        function viewDetails(poId) {
            console.log('=== viewDetails START ===');
            console.log('POID:', poId);
            
            const modal = document.getElementById('detailsModal');
            const content = document.getElementById('detailsContent');
            
            if (!modal) {
                console.error('ERROR: detailsModal not found!');
                alert('Lỗi: Không tìm thấy modal');
                return;
            }
            if (!content) {
                console.error('ERROR: detailsContent not found!');
                alert('Lỗi: Không tìm thấy content');
                return;
            }
            
            console.log('Modal found, showing...');
            // Force show modal
            modal.style.display = 'block';
            modal.style.visibility = 'visible';
            modal.style.opacity = '1';
            content.innerHTML = '<div style="text-align:center;padding:40px;"><div style="border:4px solid #f3f4f6;border-top:4px solid #3b82f6;border-radius:50%;width:40px;height:40px;animation:spin 1s linear infinite;margin:0 auto;"></div><p style="margin-top:20px;">Đang tải...</p></div>';
            console.log('Modal display set to:', modal.style.display);
            
            // Fetch PO details
            const contextPath = '${pageContext.request.contextPath}';
            const url = contextPath + '/procurement/po?action=details&poid=' + poId;
            console.log('Fetching URL:', url);
            
            fetch(url)
                .then(response => {
                    console.log('Response received. Status:', response.status);
                    if (!response.ok) {
                        throw new Error('HTTP ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Data parsed successfully:', data);
                    if (data.error) {
                        console.error('Server returned error:', data.error);
                        content.innerHTML = '<div style="color:red;padding:20px;"><strong>❌ Lỗi:</strong> ' + data.error + '</div>';
                        return;
                    }
                    console.log('Rendering PO details...');
                    renderPODetails(data);
                    console.log('=== viewDetails END SUCCESS ===');
                })
                .catch(error => {
                    console.error('=== FETCH ERROR ===', error);
                    content.innerHTML = '<div style="color:red;padding:20px;"><strong>❌ Lỗi kết nối:</strong> ' + error.message + '<br><small>Kiểm tra Console và Tomcat logs</small></div>';
                });
        }
        
        function renderPODetails(po) {
            console.log('=== renderPODetails START ===');
            const content = document.getElementById('detailsContent');
            
            if (!content) {
                console.error('ERROR: detailsContent not found in renderPODetails!');
                return;
            }
            
            // Helper function for safe date formatting
            const safeFormatDate = (dateStr) => {
                if (!dateStr || dateStr === '') return 'N/A';
                try {
                    // If it's already formatted or not a valid date, return as-is
                    if (dateStr.includes('/') || dateStr.includes('-')) {
                        return dateStr;
                    }
                    const date = new Date(dateStr);
                    if (isNaN(date.getTime())) return dateStr;
                    return date.toLocaleDateString('vi-VN');
                } catch (e) {
                    console.warn('Date format error:', e);
                    return dateStr;
                }
            };
            
            let itemsHtml = '';
            let total = 0;
            
            if (!po.items || po.items.length === 0) {
                itemsHtml = '<tr><td colspan="5" style="text-align:center;padding:20px;color:#999;">Không có sản phẩm</td></tr>';
            } else {
                po.items.forEach((item, idx) => {
                    const qty = parseFloat(item.quantity) || 0;
                    const price = parseFloat(item.unitPrice) || 0;
                    const itemTotal = qty * price;
                    total += itemTotal;
                    itemsHtml += '<tr>' +
                        '<td>' + (idx + 1) + '</td>' +
                        '<td>' + (item.itemName || 'N/A') + '</td>' +
                        '<td style="text-align:right">' + qty.toLocaleString('vi-VN') + '</td>' +
                        '<td style="text-align:right">' + price.toLocaleString('vi-VN') + ' ₫</td>' +
                        '<td style="text-align:right"><strong>' + itemTotal.toLocaleString('vi-VN') + ' ₫</strong></td>' +
                        '</tr>';
                });
            }
            
            const statusBadge = getStatusBadge(po.status || 'PENDING');
            const shortPoid = (po.poid || '').length > 8 ? po.poid.substring(0,8) + '...' : (po.poid || 'N/A');
            
            content.innerHTML = '<div style="padding: 20px;">' +
                '<div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px;">' +
                '<div>' +
                '<p><strong>Mã đơn:</strong> ' + shortPoid + '</p>' +
                '<p><strong>Nhà cung cấp:</strong> ' + (po.supplierName || 'N/A') + '</p>' +
                '<p><strong>Ngày tạo:</strong> ' + safeFormatDate(po.createDate) + '</p>' +
                '<p><strong>Ngày giao dự kiến:</strong> ' + safeFormatDate(po.expectedDelivery) + '</p>' +
                '</div>' +
                '<div>' +
                '<p><strong>Trạng thái:</strong> ' + statusBadge + '</p>' +
                '<p><strong>Tổng tiền:</strong> <span style="color:#10b981;font-size:1.2em;font-weight:bold">' + total.toLocaleString('vi-VN') + ' ₫</span></p>' +
                '<p><strong>Ghi chú:</strong> ' + (po.notes || 'Không có') + '</p>' +
                '</div>' +
                '</div>' +
                '<h3 style="margin-top:20px;margin-bottom:10px;">📦 Chi tiết sản phẩm</h3>' +
                '<table class="po-table">' +
                '<thead>' +
                '<tr>' +
                '<th style="width:50px">#</th>' +
                '<th>Tên sản phẩm</th>' +
                '<th style="width:100px">Số lượng</th>' +
                '<th style="width:150px">Đơn giá</th>' +
                '<th style="width:150px">Thành tiền</th>' +
                '</tr>' +
                '</thead>' +
                '<tbody>' +
                itemsHtml +
                '</tbody>' +
                '<tfoot>' +
                '<tr style="background:#f3f4f6;font-weight:bold;">' +
                '<td colspan="4" style="text-align:right;padding:15px;">TỔNG CỘNG:</td>' +
                '<td style="text-align:right;color:#10b981;font-size:1.1em;">' + total.toLocaleString('vi-VN') + ' ₫</td>' +
                '</tr>' +
                '</tfoot>' +
                '</table>' +
                '</div>';
            console.log('=== renderPODetails END SUCCESS ===');
        }
        
        function closeDetailsModal() {
            console.log('Closing modal');
            const modal = document.getElementById('detailsModal');
            if (modal) {
                modal.style.display = 'none';
            }
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('detailsModal');
            if (event.target === modal) {
                closeDetailsModal();
            }
        }
        
        function getStatusBadge(status) {
            const badges = {
                'PENDING': '<span class="status-badge pending">⏳ Chờ duyệt</span>',
                'APPROVED': '<span class="status-badge approved">✅ Đã duyệt</span>',
                'REJECTED': '<span class="status-badge rejected">❌ Từ chối</span>',
                'RECEIVING': '<span class="status-badge receiving">📦 Đang nhận hàng</span>',
                'COMPLETED': '<span class="status-badge completed">✔️ Hoàn thành</span>'
            };
            return badges[status] || status;
        }

        function openCreateModal() {
            const modal = document.getElementById('createModal');
            const mainNav = document.querySelector('.main-nav');
            const body = document.body;
            
            // Show modal
            modal.style.display = 'block';
            
            // Hide main-nav
            if (mainNav) {
                mainNav.style.display = 'none';
            }
            
            // Lock body scroll
            body.style.overflow = 'hidden';
        }

        function closeModal() {
            const modal = document.getElementById('createModal');
            const mainNav = document.querySelector('.main-nav');
            const body = document.body;
            
            // Hide modal
            modal.style.display = 'none';
            
            // Show main-nav again
            if (mainNav) {
                mainNav.style.display = 'flex';
            }
            
            // Unlock body scroll
            body.style.overflow = 'auto';
        }

        function exportPOs() {
            alert('📊 Xuất báo cáo đơn hàng');
            // TODO: Implement export functionality
        }

        // Form management functions
        function addItem() {
            const container = document.getElementById('itemsContainer');
            const newRow = document.createElement('div');
            newRow.className = 'item-row';
            newRow.innerHTML = `
                <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                <input type="text" name="quantity" placeholder="Số lượng" required oninput="formatNumber(this)" onblur="formatNumber(this)">
                <input type="text" name="unitPrice" placeholder="Đơn giá (₫)" required oninput="formatNumber(this)" onblur="formatNumber(this)">
                <input type="text" name="total" placeholder="Thành tiền" readonly>
                <button type="button" class="btn-remove-item" onclick="removeItem(this)">🗑️</button>
            `;
            container.appendChild(newRow);
            updateRemoveButtons();
        }

        function removeItem(button) {
            const container = document.getElementById('itemsContainer');
            if (container.children.length > 1) {
                button.parentElement.remove();
                updateRemoveButtons();
                calculateTotal();
            }
        }

        function updateRemoveButtons() {
            const container = document.getElementById('itemsContainer');
            const removeButtons = container.querySelectorAll('.btn-remove-item');
            
            removeButtons.forEach((button, index) => {
                if (container.children.length === 1) {
                    button.style.display = 'none';
                } else {
                    button.style.display = 'block';
                }
            });
        }

        // Format number with thousand separator
        function formatNumber(input) {
            // Get raw value (remove all non-digits)
            let value = input.value.replace(/\D/g, '');
            
            // Don't format if empty
            if (!value) {
                input.value = '';
                return;
            }
            
            // Validate: must be positive number
            const numValue = parseInt(value);
            if (isNaN(numValue) || numValue <= 0) {
                input.value = '';
                return;
            }
            
            // Format with thousand separator
            const formatted = numValue.toLocaleString('vi-VN');
            input.value = formatted;
            
            // Trigger calculation after formatting
            if (input.name === 'quantity' || input.name === 'unitPrice') {
                calculateItemTotal(input);
            }
        }
        
        // Validate and clean form before submit
        function validateAndCleanForm() {
            console.log('=== Form Validation START ===');
            
            // Get all quantity and unitPrice inputs
            const quantityInputs = document.querySelectorAll('input[name="quantity"]');
            const priceInputs = document.querySelectorAll('input[name="unitPrice"]');
            
            // Validate: at least one item
            if (quantityInputs.length === 0) {
                alert('Vui lòng thêm ít nhất 1 sản phẩm!');
                return false;
            }
            
            // Clean and validate each input
            let hasValidItem = false;
            for (let i = 0; i < quantityInputs.length; i++) {
                const qtyInput = quantityInputs[i];
                const priceInput = priceInputs[i];
                const nameInput = qtyInput.parentElement.querySelector('input[name="itemName"]');
                
                // Parse raw values
                const qtyRaw = qtyInput.value.replace(/\D/g, '');
                const priceRaw = priceInput.value.replace(/\D/g, '');
                const name = nameInput ? nameInput.value.trim() : '';
                
                // Check if this row has data
                if (name && qtyRaw && priceRaw) {
                    const qty = parseInt(qtyRaw);
                    const price = parseInt(priceRaw);
                    
                    // Validate positive numbers
                    if (qty <= 0 || price <= 0) {
                        alert(`Sản phẩm "${name}": Số lượng và đơn giá phải lớn hơn 0!`);
                        return false;
                    }
                    
                    // Convert formatted value to raw number for submission
                    qtyInput.value = qtyRaw;
                    priceInput.value = priceRaw;
                    
                    hasValidItem = true;
                    console.log(`✅ Item ${i+1}: ${name} - Qty: ${qtyRaw}, Price: ${priceRaw}`);
                }
            }
            
            if (!hasValidItem) {
                alert('Vui lòng nhập đầy đủ thông tin cho ít nhất 1 sản phẩm!');
                return false;
            }
            
            console.log('=== Form Validation PASSED ===');
            return true; // Allow submit
        }
        
        function calculateItemTotal(input) {
            const row = input.parentElement;
            const quantityInput = row.querySelector('input[name="quantity"]');
            const unitPriceInput = row.querySelector('input[name="unitPrice"]');
            const totalInput = row.querySelector('input[name="total"]');
            
            // Parse raw values (remove formatting)
            const quantity = quantityInput.value.replace(/\D/g, '');
            const unitPrice = unitPriceInput.value.replace(/\D/g, '');
            
            if (quantity && unitPrice) {
                const total = parseInt(quantity) * parseInt(unitPrice);
                totalInput.value = total.toLocaleString('vi-VN') + ' ₫';
                calculateTotal();
            } else {
                totalInput.value = '';
                calculateTotal();
            }
        }

        function calculateTotal() {
            const totalInputs = document.querySelectorAll('input[name="total"]');
            let total = 0;
            
            totalInputs.forEach(input => {
                const value = input.value.replace(/[^\d]/g, '');
                if (value) {
                    total += parseInt(value);
                }
            });
            
            document.getElementById('totalAmount').textContent = total.toLocaleString('vi-VN') + ' ₫';
        }

        function resetForm() {
            document.getElementById('createPOForm').reset();
            const container = document.getElementById('itemsContainer');
            container.innerHTML = `
                <div class="item-row">
                    <input type="text" name="itemName" placeholder="Tên sản phẩm" required>
                    <input type="text" name="quantity" placeholder="Số lượng" required oninput="formatNumber(this)" onblur="formatNumber(this)">
                    <input type="text" name="unitPrice" placeholder="Đơn giá (₫)" required oninput="formatNumber(this)" onblur="formatNumber(this)">
                    <input type="text" name="total" placeholder="Thành tiền" readonly>
                    <button type="button" class="btn-remove-item" onclick="removeItem(this)" style="display: none;">🗑️</button>
                </div>
            `;
            calculateTotal();
        }

        function closeModal() {
            const modal = document.getElementById('createModal');
            const mainNav = document.querySelector('.main-nav');
            const body = document.body;
            
            // Hide modal
            modal.style.display = 'none';
            
            // Show main-nav again
            if (mainNav) {
                mainNav.style.display = 'flex';
            }
            
            // Unlock body scroll
            body.style.overflow = 'auto';
            
            // Reset form
            resetForm();
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('createModal');
            if (event.target === modal) {
                closeModal();
            }
        }

        // Format date function
        function formatDate(dateString) {
            if (!dateString || dateString === 'null' || dateString === 'N/A') {
                return 'N/A';
            }
            
            try {
                const date = new Date(dateString);
                if (isNaN(date.getTime())) {
                    return dateString; // Return original if can't parse
                }
                
                return date.toLocaleDateString('vi-VN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch (e) {
               
                return dateString; // Return original if error
            }
        }

        // Format all dates on page load
        function formatAllDates() {
            const dateElements = document.querySelectorAll('.date-display');
            dateElements.forEach(element => {
                const originalDate = element.getAttribute('data-date');
                if (originalDate) {
                    const formattedDate = formatDate(originalDate);
                    element.textContent = formattedDate;
                }
            });
        }

        // Initialize on page load
        window.onload = function() {
            formatAllDates();
            updateStatistics();
            updateRemoveButtons();
            calculateTotal();
            
            // Set default date to tomorrow
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const dateString = tomorrow.toISOString().slice(0, 16);
            document.getElementById('expectedDelivery').value = dateString;
            
          
        };
    </script>
</body>
</html>
</html>