# REQUIREMENT & DESIGN SPECIFICATION (RDS) DOCUMENT

**Project Name:** LiteFlow - Enterprise Resource Planning System  
**Project Code:** SWP391  
**Organization:** FPT University  
**Academic Term:** Fall 2025  
**Document Version:** 1.0  
**Last Updated:** November 2, 2025

---

## Record of Changes

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| **1.0.0** | October 2025 | LiteFlow Development Team | **Initial Release with Core ERP Modules**<br>- Implemented Authentication & Authorization with 2FA and Google OAuth2<br>- Completed Point of Sale (POS) system with table management<br>- Deployed Kitchen Display System with order status workflow<br>- Implemented basic Inventory Management with stock tracking<br>- Completed Employee Management with role-based access<br>- Deployed Procurement module with PO, GR, and Invoice Matching<br>- Integrated Dashboard & Analytics with real-time metrics<br>- Implemented Alert System with low-stock notifications<br>- Added Attendance & Timesheet tracking<br>- Completed Payroll calculation module<br>- Code coverage achieved: ≥85% (line), ≥80% (branch)<br>- Full system integration testing completed<br>- Production deployment ready |
| **0.9.0** | September 2025 | LiteFlow Development Team | **Beta Release with Procurement Module**<br>- Implemented Procurement Management (Supplier, PO, GR)<br>- Added Invoice Matching Service with validation logic<br>- Integrated Procurement Dashboard with analytics<br>- Implemented scheduled jobs (ProcurementAlertJob)<br>- Added Goods Receipt recording with inventory update<br>- Created Supplier SLA tracking<br>- Enhanced database schema with procurement tables<br>- Integration testing for Procurement ↔ Inventory<br>- Bug fixes for Order and Inventory modules<br>- Performance optimization for large datasets |
| **0.8.0** | August 2025 | LiteFlow Development Team | **Alpha Release with POS and Inventory**<br>- Implemented Core Authentication (Email/Password login)<br>- Basic JWT token management<br>- Cashier/POS functionality with order creation<br>- Product catalog with variants (size, options)<br>- Basic inventory tracking with stock levels<br>- Table/Room management for restaurant operations<br>- Order history and session tracking<br>- Database schema design v1.0<br>- Initial JPA/Hibernate integration<br>- Basic UI/UX design for core screens<br>- Unit testing framework setup (JUnit 5, Mockito)<br>- Development environment setup documentation |
| **0.7.0** | July 2025 | LiteFlow Development Team | **Pre-Alpha Release - Project Setup**<br>- Project initialization with Maven structure<br>- Database design and initial schema creation<br>- Technology stack selection (Java 16, Jakarta EE 11, Hibernate)<br>- Development team formation and role assignment<br>- Requirements gathering from stakeholders<br>- Use case analysis and documentation<br>- UI/UX wireframes and mockups<br>- Development guidelines and coding standards<br>- Git repository setup and branching strategy<br>- CI/CD pipeline planning |

---

## Table of Contents

- [Record of Changes](#record-of-changes)
- [I. Overview](#i-overview)
  - [1. User Requirements](#1-user-requirements)
    - [1.1 Actors](#11-actors)
    - [1.2 Use Cases](#12-use-cases)
  - [2. Overall Functionalities](#2-overall-functionalities)
    - [2.1 Screens Flow](#21-screens-flow)
    - [2.2 Screen Descriptions](#22-screen-descriptions)
    - [2.3 Screen Authorization](#23-screen-authorization)
    - [2.4 Non-UI Functions](#24-non-ui-functions)
  - [3. System High Level Design](#3-system-high-level-design)
    - [3.1 Database Design](#31-database-design)
    - [3.2 Code Packages](#32-code-packages)
- [II. Requirement Specifications](#ii-requirement-specifications)
  - [1. Authentication & Authorization Feature](#1-authentication--authorization-feature)
  - [2. Common Functions](#2-common-functions)
  - [3. POS/Cashier Feature](#3-poscashier-feature)
  - [4. Kitchen Management Feature](#4-kitchen-management-feature)
  - [5. Inventory Management Feature](#5-inventory-management-feature)
  - [6. Employee & HR Feature](#6-employee--hr-feature)
  - [7. Procurement Feature](#7-procurement-feature)
  - [8. Reporting Feature](#8-reporting-feature)
- [III. Design Specifications](#iii-design-specifications)
  - [1. Authentication & Authorization Design](#1-authentication--authorization-design)
  - [2. POS/Cashier Design](#2-poscashier-design)
  - [3. Kitchen Management Design](#3-kitchen-management-design)
  - [4. Inventory Management Design](#4-inventory-management-design)
  - [5. Employee & HR Design](#5-employee--hr-design)
  - [6. Procurement Design](#6-procurement-design)
  - [7. Reporting Design](#7-reporting-design)
- [IV. Appendix](#iv-appendix)
  - [1. Assumptions & Dependencies](#1-assumptions--dependencies)
  - [2. Limitations & Exclusions](#2-limitations--exclusions)
  - [3. Business Rules](#3-business-rules)
  - [4. Glossary of Terms](#4-glossary-of-terms)
  - [5. References](#5-references)

---

## I. Overview

### 1. User Requirements

#### 1.1 Actors

The LiteFlow system supports the following user roles with distinct responsibilities:

| Actor ID | Actor Name | Description | Primary Responsibilities |
|----------|------------|-------------|--------------------------|
| **ACT-01** | **Owner** | Business owner with full system control | - Full system access and configuration<br>- User management and role assignment<br>- Business metrics monitoring<br>- Strategic decision-making support<br>- System-wide reporting |
| **ACT-02** | **Admin** | System administrator with technical privileges | - User account management<br>- System configuration<br>- Security settings<br>- Database maintenance<br>- Audit log review<br>- Technical troubleshooting |
| **ACT-03** | **Cashier** | Point of Sale operator | - Process customer orders<br>- Table/room management<br>- Payment processing (Cash, Card, Transfer)<br>- Invoice generation<br>- Order history review<br>- Customer service at checkout |
| **ACT-04** | **Kitchen Staff** | Chef/Cook managing kitchen operations | - View incoming orders<br>- Update order status (Pending → Preparing → Ready → Served)<br>- Manage order queue by priority<br>- Notify front-of-house when orders are ready<br>- Handle special instructions |
| **ACT-05** | **Inventory Manager** | Stock and product catalog manager | - Product catalog management (CRUD operations)<br>- Stock level tracking and updates<br>- Low-stock alert monitoring<br>- Price management<br>- Import/export product data (Excel)<br>- Category management |
| **ACT-06** | **Procurement Officer** | Purchase order and supplier manager | - Supplier management<br>- Purchase Order (PO) creation and approval<br>- Goods Receipt (GR) recording<br>- Invoice matching and verification<br>- Supplier performance tracking<br>- Procurement analytics |
| **ACT-07** | **HR Officer** | Human resources and payroll manager | - Employee profile management<br>- Attendance tracking<br>- Shift scheduling<br>- Leave request approval<br>- Payroll calculation and generation<br>- Employee performance monitoring |
| **ACT-08** | **Employee** | General staff member | - View personal dashboard<br>- Clock in/out for attendance<br>- View personal schedule<br>- Submit leave requests<br>- View personal timesheet<br>- View payroll information<br>- Receive system notifications |
| **ACT-09** | **Guest/Patron** *(Future)* | Restaurant customer | - Make table reservations<br>- Pre-order meals<br>- View menu and prices<br>- Provide feedback<br>- View order history<br>***Note:** Currently limited implementation* |

**Role Hierarchy:**
```
Owner/Admin (Full Access)
├── Procurement Officer (Procurement, Inventory)
├── Inventory Manager (Products, Stock)
├── HR Officer (Employees, Payroll, Attendance)
├── Cashier (POS, Orders, Payment)
├── Kitchen Staff (Kitchen Display, Order Status)
└── Employee (Personal Dashboard, Attendance)
```

---

#### 1.2 Use Cases

The system implements the following use cases organized by functional module:

##### **Module 1: Authentication & Authorization**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-01** | Login System | All Users | User logs in with email/password, Google OAuth2, or 2FA verification |
| **UC-02** | Password Recovery | All Users | User requests OTP via email, verifies OTP, and resets password |
| **UC-03** | User Registration | Admin, Owner | Create new user account with email, password, and role assignment |
| **UC-04** | Logout System | All Users | User logs out and session is terminated |
| **UC-05** | Manage User Roles | Admin, Owner | Assign, update, or revoke user roles and permissions |

##### **Module 2: Point of Sale (POS) / Cashier**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-06** | Select Table/Room | Cashier | Cashier selects available table to start order session |
| **UC-07** | Create Order | Cashier | Cashier adds products to cart, validates stock, and submits order |
| **UC-08** | Modify Order | Cashier | Cashier adds/removes items from existing order before payment |
| **UC-09** | Apply Discount | Cashier | Apply discount code or manual discount to order total |
| **UC-10** | Process Payment | Cashier | Process payment via Cash, Card, or Transfer and generate invoice |
| **UC-11** | Split Bill | Cashier | Divide order items and amounts across multiple payments |
| **UC-12** | View Order History | Cashier | Review past orders filtered by date, table, or order number |
| **UC-13** | Close Table Session | Cashier | Mark table as available after payment completion |

##### **Module 3: Kitchen Management**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-14** | View Order Queue | Kitchen Staff | Display all pending/preparing orders sorted by priority |
| **UC-15** | Update Order Status | Kitchen Staff | Change order status: Pending → Preparing → Ready → Served |
| **UC-16** | Notify Cashier | Kitchen Staff | Send notification when order is ready for pickup |
| **UC-17** | View Order Details | Kitchen Staff | View detailed order items, quantities, and special instructions |

##### **Module 4: Inventory Management**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-18** | Create Product | Inventory Manager | Add new product with name, category, variants, prices, and images |
| **UC-19** | Update Product | Inventory Manager | Modify product details, prices, or status (active/inactive) |
| **UC-20** | Delete Product | Inventory Manager | Soft delete product (mark as deleted, retain data) |
| **UC-21** | Manage Stock Levels | Inventory Manager | Update inventory quantities (IN/OUT transactions) |
| **UC-22** | View Low Stock Alerts | Inventory Manager | Monitor products below minimum stock threshold |
| **UC-23** | Set Product Prices | Inventory Manager | Configure base price, discount price, and discount expiry |
| **UC-24** | Import Products from Excel | Inventory Manager | Bulk import product data via Excel file upload |
| **UC-25** | Export Products to Excel | Inventory Manager | Download product catalog as Excel spreadsheet |
| **UC-26** | Manage Categories | Inventory Manager | Create, update, or delete product categories |

##### **Module 5: Employee & HR Management**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-27** | Create Employee Profile | HR Officer | Add new employee with personal info, role, and compensation |
| **UC-28** | Update Employee Profile | HR Officer | Modify employee details, role, or status (active/inactive) |
| **UC-29** | Assign Employee Role | HR Officer, Admin | Link employee to system roles (Cashier, Kitchen, etc.) |
| **UC-30** | Create Shift Schedule | HR Officer | Define shift templates (time, days, pay rules) |
| **UC-31** | Assign Employee to Shift | HR Officer | Schedule employees to specific shifts |
| **UC-32** | Clock In/Out | Employee | Record attendance by clocking in at shift start and out at end |
| **UC-33** | View Personal Schedule | Employee | Employee views assigned shifts and upcoming schedule |
| **UC-34** | Submit Leave Request | Employee | Request time off with reason and date range |
| **UC-35** | Approve/Reject Leave | HR Officer | Review and approve or deny employee leave requests |
| **UC-36** | Submit Forgot Clock Request | Employee | Request correction for missed clock in/out |
| **UC-37** | View Timesheet | Employee, HR Officer | View attendance records and hours worked |
| **UC-38** | Generate Paysheet | HR Officer | Calculate payroll based on attendance, shifts, and pay policy |

##### **Module 6: Procurement**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-39** | Manage Suppliers | Procurement Officer | Create, update, or view supplier information and SLA |
| **UC-40** | Create Purchase Order | Procurement Officer | Generate PO with items, quantities, supplier, and delivery date |
| **UC-41** | Approve Purchase Order | Procurement Officer, Admin | Review and approve PO for processing |
| **UC-42** | Track PO Status | Procurement Officer | Monitor PO workflow: Draft → Submitted → Approved → In Transit → Completed |
| **UC-43** | Record Goods Receipt | Procurement Officer | Log received items, quantities, and quality check |
| **UC-44** | Update Inventory from GR | System (Auto) | Automatically update inventory stock upon GR confirmation |
| **UC-45** | Match Invoice with PO/GR | Procurement Officer | Validate invoice amounts against PO and GR, approve payment |
| **UC-46** | View Procurement Dashboard | Procurement Officer | View analytics on PO status, supplier performance, spending |

##### **Module 7: Table/Room Management**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-47** | Manage Rooms | Inventory Manager | Create, update, or delete room configurations |
| **UC-48** | Manage Tables | Inventory Manager | Add tables to rooms with capacity and status |
| **UC-49** | View Table Availability | Cashier | Check real-time table status (Available, Occupied, Reserved) |
| **UC-50** | Create Reservation | Cashier, Guest | Book table for future date with customer details |
| **UC-51** | Confirm Reservation | Cashier | Change reservation status to CONFIRMED |
| **UC-52** | Seat Reservation | Cashier | Convert reservation to active table session |
| **UC-53** | Cancel Reservation | Cashier, Guest | Cancel booking and release table |

##### **Module 8: Reporting & Analytics**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-54** | View Dashboard | Owner, Admin, Manager | Real-time metrics: sales, orders, inventory, attendance |
| **UC-55** | Generate Revenue Report | Owner, Admin | Sales report by date range with charts and totals |
| **UC-56** | View Top Products | Owner, Inventory Manager | Analyze best-selling products by quantity or revenue |
| **UC-57** | Generate Attendance Report | HR Officer | Summary of employee attendance, late, early leave |
| **UC-58** | Generate Procurement Report | Procurement Officer | PO spending, supplier performance, delivery times |

##### **Module 9: Notification & Alert System**

| Use Case ID | Use Case Name | Primary Actor | Description |
|-------------|---------------|---------------|-------------|
| **UC-59** | Configure Alert Rules | Admin | Set thresholds for low stock, overdue PO, etc. |
| **UC-60** | Send System Notification | System (Auto) | Trigger notifications for configured events |
| **UC-61** | View Notifications | All Users | Users view unread notifications in notification center |
| **UC-62** | Mark Notification as Read | All Users | Dismiss or acknowledge notifications |

---

### 2. Overall Functionalities

#### 2.1 Screens Flow

**Main Application Flow:**

```
┌─────────────────────────────────────────────────────────────────┐
│                      LOGIN (auth/login.jsp)                     │
│         Email/Password | Google OAuth2 | 2FA Verification        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                ┌────────────┴─────────────┐
                │  Authentication Filter   │
                │  (Role-Based Redirect)   │
                └────────────┬─────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌──────────────┐   ┌──────────────┐    ┌──────────────┐
│   Owner/     │   │   Employee   │    │   Cashier/   │
│    Admin     │   │  Dashboard   │    │   Kitchen    │
│  Dashboard   │   │              │    │              │
└──────┬───────┘   └──────────────┘    └──────┬───────┘
       │                                       │
       │                                       │
   [Full Access]                          [Role-Based Access]
```

**Cashier POS Flow:**

```
1. Login → Dashboard
2. Select Table/Room (inventory/roomtable.jsp)
   ├─ View table status (Available, Occupied, Reserved)
   └─ Create new session or continue existing
3. Add Items to Cart (cart/cashier.jsp)
   ├─ Browse product catalog
   ├─ Select variant (size, options)
   ├─ Add to cart → Stock validation
   └─ Modify quantities
4. Submit Order
   ├─ System deducts inventory
   └─ Notify Kitchen (KitchenServlet)
5. Process Payment
   ├─ Apply discount (optional)
   ├─ Select payment method (Cash/Card/Transfer)
   ├─ Generate invoice
   └─ Close table session
6. Print Receipt → Return to Dashboard
```

**Kitchen Display Flow:**

```
1. Login → Kitchen Dashboard (kitchen/kitchen.jsp)
2. View Order Queue
   ├─ Display all orders with Status = Pending or Preparing
   ├─ Sort by priority (time, table)
   └─ Auto-refresh (polling/WebSocket)
3. Select Order → View Details
   ├─ Order items, quantities
   ├─ Special instructions
   └─ Customer table/name
4. Update Order Status
   ├─ Pending → [Start Preparing]
   ├─ Preparing → [Mark as Ready]
   └─ Ready → [Served] (by Cashier)
5. Notification sent to Cashier when Ready
6. Loop back to Queue
```

**Inventory Management Flow:**

```
1. Login → Dashboard → Products (inventory/productlist.jsp)
2. Product List View
   ├─ Filter by category, status
   ├─ Search by name
   └─ View stock levels (color-coded alerts)
3. Create/Edit Product
   ├─ Basic info (name, description, category)
   ├─ Upload image
   ├─ Add variants (size, price)
   └─ Set initial stock
4. Set Prices (inventory/setPrice.jsp)
   ├─ Base price, discount price
   └─ Discount expiry date
5. Import/Export Excel
   ├─ Upload Excel file → Parse → Validate → Import
   └─ Export current catalog to Excel
6. Low Stock Alerts
   └─ Dashboard notification → Restock or create PO
```

**Employee & Attendance Flow:**

```
1. Login → Employee Dashboard (dashboard-employee.jsp)
2. Clock In (attendance.jsp)
   ├─ Record CheckInTime
   └─ Link to EmployeeShift
3. View Personal Schedule (schedule.jsp)
   ├─ Upcoming shifts
   └─ Leave requests status
4. Submit Leave Request (LeaveRequestServlet)
   ├─ Select date range, reason
   └─ Await approval
5. Clock Out
   ├─ Record CheckOutTime
   └─ Calculate hours worked
6. View Timesheet (TimesheetServlet)
   ├─ Hours worked, late/early flags
   └─ Payroll summary
```

**Procurement Flow:**

```
1. Login → Procurement Dashboard (procurement/dashboard.jsp)
2. Manage Suppliers (procurement/supplier-list-simple.jsp)
   ├─ Create/update supplier
   └─ Track SLA performance
3. Create Purchase Order (procurement/po.jsp)
   ├─ Select supplier
   ├─ Add items (product, quantity, unit price)
   ├─ Set delivery date
   └─ Submit for approval
4. Approve PO
   ├─ Review PO details
   └─ Approve → Status = Approved
5. Record Goods Receipt (procurement/goods-receipt.jsp)
   ├─ Link to PO
   ├─ Record received items
   ├─ Update inventory (auto)
   └─ PO Status → Completed (if full receipt)
6. Invoice Matching (procurement/invoice-matching.jsp)
   ├─ Link invoice to PO and GR
   ├─ Validate amounts
   └─ Approve payment
```

---

#### 2.2 Screen Descriptions

##### **Authentication Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-01** | Login | `auth/login.jsp` | User login with email/password or Google OAuth2 | - Email/Password form<br>- "Sign in with Google" button<br>- "Forgot Password" link<br>- "Sign Up" link (if enabled) |
| **SCR-02** | Signup | `auth/signup.jsp` | New user registration form | - Email, Password, Display Name fields<br>- Password strength indicator<br>- Submit button<br>- Email verification trigger |
| **SCR-03** | OTP Verification | `auth/verify-otp.jsp` | Two-Factor Authentication verification | - 6-digit OTP input<br>- Resend OTP button<br>- Timer countdown |
| **SCR-04** | Forgot Password | `auth/forgot.jsp` | Password recovery request | - Email input<br>- "Send OTP" button<br>- Redirect to verify-forgot.jsp |
| **SCR-05** | Reset Password | `auth/reset.jsp` | Set new password after OTP verification | - New password input<br>- Confirm password input<br>- Submit button |
| **SCR-06** | Access Denied | `accessDenied.jsp` | Error page for unauthorized access | - Error message<br>- Return to Dashboard link |

##### **Dashboard Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-07** | Owner/Admin Dashboard | `dashboard.jsp` | Main dashboard with business metrics | - Sales chart (daily/weekly/monthly)<br>- Total revenue, orders, customers<br>- Low stock alerts<br>- Recent orders table<br>- Quick actions (navigation links) |
| **SCR-08** | Employee Dashboard | `dashboard-employee.jsp` | Personal dashboard for general staff | - Attendance status (Clocked In/Out)<br>- Personal schedule (upcoming shifts)<br>- Leave request status<br>- Notifications<br>- Timesheet summary |

##### **POS/Cashier Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-09** | Table/Room Management | `inventory/roomtable.jsp` | View and select tables | - Room tabs<br>- Table grid with status colors<br>- Filter (Available/Occupied/Reserved)<br>- Table capacity info |
| **SCR-10** | Cashier POS | `cart/cashier.jsp` | Point of Sale order creation | - Product catalog (left panel)<br>- Cart items (right panel)<br>- Search product<br>- Add/Remove items<br>- Quantity selector<br>- Special instructions input<br>- Total calculation<br>- Payment buttons (Cash/Card/Split) |

##### **Kitchen Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-11** | Kitchen Display | `kitchen/kitchen.jsp` | Order queue and status management | - Order cards (sorted by time)<br>- Status buttons (Start, Ready, Served)<br>- Order details modal<br>- Auto-refresh indicator<br>- Notification bell |

##### **Inventory Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-12** | Product List | `inventory/productlist.jsp` | Product catalog management | - Product table (Name, Category, Price, Stock)<br>- Add Product button<br>- Edit/Delete actions<br>- Search and filter<br>- Pagination<br>- Stock level badges (Low/OK/High) |
| **SCR-13** | Set Prices | `inventory/setPrice.jsp` | Price management for product variants | - Product selection dropdown<br>- Variant list<br>- Base price input<br>- Discount price input<br>- Discount expiry date picker<br>- Save button |

##### **Employee & HR Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-14** | Employee List | `employee/employeeList.jsp` | View all employees | - Employee table (Code, Name, Role, Status)<br>- Add Employee button<br>- Edit/Delete actions<br>- Search by name/code<br>- Filter by role |
| **SCR-15** | Setup Employee | `employee/setupEmployee.jsp` | Create/edit employee profile | - Personal info form (Name, Gender, DOB, ID)<br>- Contact details (Phone, Email, Address)<br>- Employment info (Code, Hire Date, Role)<br>- Compensation details<br>- Submit button |
| **SCR-16** | Schedule | `schedule.jsp` | Shift scheduling | - Calendar view (week/month)<br>- Shift templates<br>- Drag-and-drop shift assignment<br>- Employee availability<br>- Save schedule button |
| **SCR-17** | Attendance | `attendance.jsp` | Attendance tracking | - Clock In/Out buttons<br>- Current shift info<br>- Attendance history table<br>- Late/Early flags<br>- Forgot clock request link |
| **SCR-18** | Paysheet | `employee/paysheet.jsp` | Payroll summary | - Employee selection<br>- Pay period selection<br>- Payroll breakdown table<br>- Total hours, base pay, bonuses, deductions<br>- Generate payslip button |

##### **Procurement Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-19** | Procurement Dashboard | `procurement/dashboard.jsp` | Procurement analytics | - PO status chart (Draft, Approved, Completed)<br>- Spending trends<br>- Supplier performance<br>- Overdue POs alert<br>- Quick actions |
| **SCR-20** | Supplier List | `procurement/supplier-list-simple.jsp` | Supplier management | - Supplier table (Name, Contact, Rating)<br>- Add Supplier button<br>- Edit/Delete actions<br>- Search by name |
| **SCR-21** | Purchase Order | `procurement/po.jsp` | Create/view POs | - PO form (Supplier, Items, Quantities, Prices)<br>- Add Item button<br>- Total calculation<br>- Expected delivery date picker<br>- Submit/Approve buttons<br>- PO history table |
| **SCR-22** | Goods Receipt | `procurement/goods-receipt.jsp` | Record goods receipt | - PO selection dropdown<br>- GR items table (Item, Ordered, Received)<br>- Quantity received input<br>- Quality check notes<br>- Confirm receipt button |
| **SCR-23** | Invoice Matching | `procurement/invoice-matching.jsp` | Match invoice with PO/GR | - Invoice upload/input<br>- PO and GR selection<br>- Comparison table (Invoice vs PO vs GR)<br>- Discrepancy alerts<br>- Approve payment button |

##### **Reporting Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-24** | Revenue Report | `report/revenue.jsp` | Sales and revenue analytics | - Date range picker<br>- Revenue chart (line/bar)<br>- Top products table<br>- Sales by category<br>- Export PDF button |

##### **Reception/Reservation Screens**

| Screen ID | Screen Name | File Path | Description | Key Components |
|-----------|-------------|-----------|-------------|----------------|
| **SCR-25** | Reception | `reception/reception.jsp` | Reservation management | - Create reservation form<br>- Reservation list (upcoming, today)<br>- Confirm/Cancel/Seat buttons<br>- Customer search<br>- Pre-order items |

---

#### 2.3 Screen Authorization

**Role-Based Access Control Matrix:**

| Screen/Module | Owner | Admin | Cashier | Kitchen Staff | Inventory Mgr | Procurement Officer | HR Officer | Employee |
|--------------|-------|-------|---------|---------------|---------------|---------------------|------------|----------|
| **Authentication** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Login/Logout | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Forgot Password | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| User Management | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅* | ❌ |
| **Dashboard** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Owner Dashboard | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Employee Dashboard | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **POS/Cashier** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Table Management | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Create Order | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Process Payment | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Kitchen** | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Order Queue | ✅ | ✅ | ✅* | ✅ | ❌ | ❌ | ❌ | ❌ |
| Update Order Status | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Inventory** | ✅ | ✅ | ❌ | ❌ | ✅ | ✅* | ❌ | ❌ |
| Product Management | ✅ | ✅ | ❌ | ❌ | ✅ | ✅* | ❌ | ❌ |
| Stock Tracking | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |
| Set Prices | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Employee & HR** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅* |
| Employee Management | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Schedule | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅* (view only) |
| Attendance | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Payroll | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅* (view only) |
| **Procurement** | ✅ | ✅ | ❌ | ❌ | ✅* | ✅ | ❌ | ❌ |
| Supplier Management | ✅ | ✅ | ❌ | ❌ | ✅* | ✅ | ❌ | ❌ |
| Purchase Orders | ✅ | ✅ | ❌ | ❌ | ✅* | ✅ | ❌ | ❌ |
| Goods Receipt | ✅ | ✅ | ❌ | ❌ | ✅* | ✅ | ❌ | ❌ |
| Invoice Matching | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **Reports** | ✅ | ✅ | ✅* | ❌ | ✅* | ✅* | ✅* | ❌ |
| Revenue Report | ✅ | ✅ | ✅* (limited) | ❌ | ❌ | ❌ | ❌ | ❌ |
| Top Products | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Attendance Report | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |

**Legend:**
- ✅ Full Access
- ✅* Limited/View Only Access
- ❌ No Access

**Authorization Implementation:**
- **Filter:** `AuthenticationFilter.java` validates JWT token and session
- **Role Check:** `ROLE_FUNCTIONS` map in filter checks role permissions
- **Redirect:** Unauthorized access → `accessDenied.jsp` (HTTP 403)

---

#### 2.4 Non-UI Functions

##### **API Endpoints (RESTful Services)**

| Endpoint | Method | Servlet | Description | Auth Required |
|----------|--------|---------|-------------|---------------|
| `/api/cashier/*` | GET, POST | CashierAPIServlet | POS operations (cart, order, payment) | ✅ Cashier |
| `/api/kitchen/orders` | GET | KitchenServlet | Fetch order queue | ✅ Kitchen |
| `/api/kitchen/notifications` | GET | KitchenServlet | Kitchen notifications | ✅ Kitchen |
| `/api/order/status` | PUT | UpdateOrderStatusServlet | Update order status | ✅ Kitchen/Cashier |
| `/api/order/table/*` | GET | GetSessionOrdersServlet | Get orders by table | ✅ Cashier |
| `/api/notification/*` | GET, POST | NotificationAPIServlet | Notification management | ✅ All Users |
| `/api/send-notification` | POST | SendNotificationServlet | Send system notification | ✅ Admin |
| `/api/notices/*` | GET, POST, PUT, DELETE | NoticeServlet | Notice board CRUD | ✅ Employee+ |
| `/api/timesheet/*` | GET, POST | TimesheetServlet | Timesheet operations | ✅ Employee/HR |
| `/api/leave-request/*` | GET, POST, PUT | LeaveRequestServlet | Leave request CRUD | ✅ Employee/HR |
| `/api/forgot-clock/*` | GET, POST, PUT | ForgotClockRequestServlet | Forgot clock requests | ✅ Employee/HR |
| `/api/personal-schedule/*` | GET | PersonalScheduleServlet | Personal schedule view | ✅ Employee |
| `/api/reports/*` | GET | DailyReportServlet | Daily report data | ✅ Owner/Admin |
| `/api/demand-forecast` | GET | DemandForecastServlet | Demand forecasting data | ✅ Inventory Mgr |
| `/api/chatbot` | POST | ChatBotServlet | AI chatbot interaction | ✅ All Users |

##### **Background Jobs & Scheduled Tasks**

| Job Name | Class | Schedule | Description |
|----------|-------|----------|-------------|
| **Reservation Overdue Job** | `ReservationOverdueJob.java` | Every 5 minutes | Check for expired reservations (ArrivalTime + 30 min), update status to NO_SHOW, release table |
| **Procurement Alert Job** | `ProcurementAlertJob.java` | Every 1 hour | Check for overdue POs, low stock items linked to pending POs, trigger alerts |
| **Alert Scheduler** | `AlertSchedulerListener.java` | On application startup | Initialize Quartz Scheduler for scheduled jobs |

##### **Service Layer (Business Logic)**

| Service | Package | Key Methods | Description |
|---------|---------|-------------|-------------|
| **AuthService** | `service.auth` | `login()`, `register()`, `verifyOtp()`, `resetPassword()` | User authentication and session management |
| **UserService** | `service.auth` | `createUser()`, `updateUser()`, `assignRole()`, `getUserByEmail()` | User CRUD operations |
| **RoleService** | `service.auth` | `getRoleByName()`, `getAllRoles()`, `assignRoleToUser()` | Role management |
| **OrderService** | `service` | `createOrder()`, `updateOrderStatus()`, `calculateTotal()`, `getOrdersBySession()` | Order processing logic |
| **InventoryService** | `service.inventory` | `updateStock()`, `checkLowStock()`, `logInventoryChange()` | Inventory management |
| **ProcurementService** | `service.procurement` | `createPO()`, `approvePO()`, `recordGR()`, `matchInvoice()` | Procurement workflows |
| **InvoiceMatchingService** | `service.procurement` | `matchInvoiceWithPO()`, `validateAmounts()`, `approvePayment()` | Invoice validation logic |
| **EmployeeService** | `service` | `createEmployee()`, `updateEmployee()`, `getEmployeeByCode()` | Employee management |
| **ScheduleService** | `service` | `createShift()`, `assignShift()`, `getScheduleByEmployee()` | Shift scheduling |
| **TimesheetService** | `service` | `calculateHours()`, `generateTimesheet()`, `getAttendanceFlags()` | Timesheet calculations |
| **CompensationService** | `service` | `calculatePayroll()`, `applyPayPolicy()`, `generatePayslip()` | Payroll processing |
| **AlertService** | `service.alert` | `triggerAlert()`, `sendNotification()`, `getUserPreferences()` | Alert and notification system |
| **RevenueReportService** | `service.report` | `generateRevenue()`, `getTopProducts()`, `getSalesByPeriod()` | Reporting and analytics |

##### **Utility Classes**

| Utility | Package | Key Methods | Description |
|---------|---------|-------------|-------------|
| **JwtUtil** | `security` | `generateToken()`, `validateToken()`, `extractUsername()` | JWT token operations |
| **TotpUtil** | `security` | `generateSecret()`, `generateCode()`, `verifyCode()` | TOTP 2FA operations |
| **PasswordUtil** | `util` | `hashPassword()`, `verifyPassword()` | BCrypt password hashing |
| **MailUtil** | `util` | `sendOtpEmail()`, `sendWelcomeEmail()`, `sendInvoice()` | Email service integration |
| **Utils** | `util` | `generateOrderNumber()`, `formatCurrency()`, `parseDate()` | General utility functions |
| **OrderDataUtil** | `util` | `generateTestOrders()`, `populateSampleData()` | Test data generation |

##### **Filters (Request Interceptors)**

| Filter | URL Pattern | Order | Description |
|--------|-------------|-------|-------------|
| **CommonFilter** | `/*` | 1 | Sets character encoding to UTF-8 |
| **AuthenticationFilter** | `/*` | 2 | Validates JWT token, checks session, enforces role-based access |
| **LoginFilter** | `/login` | 3 | Prevents already-logged-in users from accessing login page |
| **LogoutFilter** | `/logout` | 4 | Invalidates session and clears JWT token |

---

### 3. System High Level Design

#### 3.1 Database Design

**Database Management System:** Microsoft SQL Server  
**Database Name:** `LiteFlowDBO`  
**Schema Version:** 1.0 (October 2025)

##### **Entity Relationship Overview**

The database is organized into 10 functional modules:

```
┌─────────────────────────────────────────────────────────────────┐
│                      LITEFLOW DATABASE SCHEMA                   │
└─────────────────────────────────────────────────────────────────┘

[Users] 1──────────────* [UserRoles] *───────────1 [Roles]
   │                           │
   │ 1                         │
   │                           │
   ├─* [UserSessions]          │
   ├─* [OtpTokens]             │
   ├─* [AuditLogs]             │
   │                           │
   │ 1                         │ 1
   └─────────1 [Employees] ────┘
               │
               ├─* [EmployeeShifts]
               ├─* [EmployeeAttendance]
               ├─* [EmployeeCompensations]
               └─* [PayrollEntries]

[Categories] *───────* [ProductsCategories] *───────* [Products]
                                                          │
                                                          │ 1
                                                          │
                                                          ├─* [ProductVariant]
                                                          │     │ 1
                                                          │     └─* [ProductStock] *───1 [Inventory]
                                                          │
                                                          └─* [UserInteractions]

[Rooms] 1──────* [Tables] 1──────* [TableSessions] 1──────* [Orders]
                    │                    │                     │
                    │                    │ 1                   │ 1
                    │                    └─* [Reservations]    │
                    │                         │                │
                    └─────────────────────────┘                ├─* [OrderDetails] *───1 [ProductVariant]
                                                                │
                                                                ├─* [OrderStatusHistory]
                                                                │
                                                                └─* [PaymentTransactions]

[Suppliers] 1──────* [PurchaseOrders] 1──────* [PurchaseOrderItems] *───1 [Products]
              │            │
              │            │ 1
              │            ├─* [GoodsReceipts] 1──────* [GoodsReceiptItems]
              │            │
              │            └─* [Invoices] 1──────* [InvoiceItems]
              │
              └─1 [SupplierSLA]

[ShiftTemplates] 1──────* [EmployeeShifts]
                              │
                              ├─* [EmployeeShiftAssignments]
                              │
                              └─* [EmployeeShiftTimesheets]

[AlertConfigurations] ────* [AlertHistory]
[NotificationChannels] ───* [UserAlertPreferences] *───1 [Users]
```

##### **Database Module Breakdown**

**Module 1: Authentication & Authorization (7 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `Users` | UserID (GUID) | 1-* UserRoles, UserSessions, OtpTokens | User accounts with email, password hash, 2FA secret |
| `Roles` | RoleID (GUID) | 1-* UserRoles | System roles (Owner, Admin, Cashier, etc.) |
| `UserRoles` | UserID + RoleID | *-1 Users, *-1 Roles | Many-to-many link between users and roles |
| `UserSessions` | SessionID (GUID) | *-1 Users | Active user sessions with JWT tokens |
| `OtpTokens` | OtpID (GUID) | *-1 Users | One-time password tokens for 2FA and password reset |
| `AuditLogs` | AuditID (GUID) | *-1 Users | System audit trail for security |
| `Employees` | EmployeeID (GUID) | 1-1 Users | Employee profiles linked to user accounts |

**Module 2: Product & Inventory (9 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `Products` | ProductID (GUID) | 1-* ProductVariant, ProductsCategories | Product catalog (name, description, image) |
| `Categories` | CategoryID (GUID) | 1-* ProductsCategories | Product categories for organization |
| `ProductsCategories` | ProductCategoryID (GUID) | *-1 Products, *-1 Categories | Many-to-many link products to categories |
| `ProductVariant` | ProductVariantID (GUID) | *-1 Products, 1-* ProductStock, OrderDetails | Product size/option variants with prices |
| `Inventory` | InventoryID (GUID) | 1-* ProductStock | Warehouse/location for stock storage |
| `ProductStock` | ProductStockID (GUID) | *-1 ProductVariant, *-1 Inventory | Actual stock quantities by variant and location |
| `InventoryLogs` | LogID (GUID) | *-1 ProductVariant | Audit trail for stock changes (IN/OUT) |
| `LowStockItem` | (View) | Based on ProductStock | Virtual view for low stock alerts |
| `UserInteractions` | InteractionID (GUID) | *-1 Users, *-1 Products | Track user interactions for recommendations |

**Module 3: Room, Table & Order Management (9 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `Rooms` | RoomID (GUID) | 1-* Tables | Dining rooms/areas configuration |
| `Tables` | TableID (GUID) | *-1 Rooms, 1-* TableSessions | Individual tables with capacity and status |
| `TableSessions` | SessionID (GUID) | *-1 Tables, 1-* Orders | Active session for a table (check-in to check-out) |
| `Orders` | OrderID (GUID) | *-1 TableSessions, 1-* OrderDetails | Customer orders within a session |
| `OrderDetails` | OrderDetailID (GUID) | *-1 Orders, *-1 ProductVariant | Individual order line items |
| `OrderStatusHistory` | HistoryID (GUID) | *-1 Orders | Audit trail for order status changes |
| `PaymentTransactions` | TransactionID (GUID) | *-1 TableSessions, *-1 Orders | Payment records (Cash, Card, Transfer) |
| `Reservations` | ReservationID (GUID) | *-1 Tables, *-1 Rooms | Table reservations by customers |
| `ReservationItems` | ReservationItemID (GUID) | *-1 Reservations, *-1 Products | Pre-ordered items for reservations |

**Module 4: Employee & HR Management (6 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `Employees` | EmployeeID (GUID) | 1-1 Users | Employee details (code, full name, DOB, contact) |
| `ShiftTemplates` | ShiftTemplateID (GUID) | 1-* EmployeeShifts | Reusable shift patterns (time, days, pay rules) |
| `EmployeeShifts` | ShiftID (GUID) | *-1 Employees, *-1 ShiftTemplates | Scheduled shifts for employees |
| `EmployeeShiftAssignments` | AssignmentID (GUID) | *-1 EmployeeShifts, *-1 Employees | Many-to-many link for shift assignments |
| `EmployeeAttendance` | AttendanceID (GUID) | *-1 Employees | Clock in/out records |
| `EmployeeShiftTimesheets` | TimesheetID (GUID) | *-1 EmployeeShifts, *-1 Employees | Calculated timesheet data |

**Module 5: Attendance & Leave (3 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `LeaveRequests` | LeaveRequestID (GUID) | *-1 Employees | Employee leave/time-off requests |
| `ForgotClockRequests` | RequestID (GUID) | *-1 Employees | Requests to correct missed clock in/out |
| `PersonalSchedules` | ScheduleID (GUID) | *-1 Employees | Personal notes/events on employee calendars |

**Module 6: Payroll (6 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `PayrollRuns` | PayrollRunID (GUID) | 1-* PayrollEntries | Payroll processing batch (monthly/weekly) |
| `PayrollEntries` | EntryID (GUID) | *-1 PayrollRuns, *-1 Employees | Individual payroll records per employee |
| `EmployeeCompensations` | CompensationID (GUID) | *-1 Employees | Employee salary and compensation details |
| `PayPolicies` | PolicyID (GUID) | - | Payroll calculation rules |
| `PayPeriods` | PeriodID (GUID) | - | Pay period definitions (start/end dates) |
| `PayrollAdjustments` | AdjustmentID (GUID) | *-1 PayrollEntries | Manual adjustments to payroll (bonus, deduction) |

**Module 7: Procurement (8 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `Suppliers` | SupplierID (GUID) | 1-* PurchaseOrders, 1-1 SupplierSLA | Supplier master data |
| `SupplierSLA` | SLAID (GUID) | 1-1 Suppliers | Service Level Agreement tracking |
| `PurchaseOrders` | POID (GUID) | *-1 Suppliers, 1-* PurchaseOrderItems | Purchase orders to suppliers |
| `PurchaseOrderItems` | POItemID (GUID) | *-1 PurchaseOrders, *-1 Products | Line items in a PO |
| `GoodsReceipts` | GRID (GUID) | *-1 PurchaseOrders | Goods received from supplier |
| `GoodsReceiptItems` | GRItemID (GUID) | *-1 GoodsReceipts, *-1 Products | Items received in GR |
| `Invoices` | InvoiceID (GUID) | *-1 PurchaseOrders | Supplier invoices |
| `InvoiceItems` | InvoiceItemID (GUID) | *-1 Invoices, *-1 Products | Line items in invoice |

**Module 8: Alert & Notification System (5 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `AlertConfigurations` | AlertConfigID (GUID) | - | Alert rule definitions (low stock, overdue PO) |
| `AlertHistory` | AlertHistoryID (GUID) | *-1 AlertConfigurations | Log of triggered alerts |
| `NotificationChannels` | ChannelID (GUID) | - | Notification delivery methods (Email, SMS, In-App) |
| `UserAlertPreferences` | PreferenceID (GUID) | *-1 Users, *-1 NotificationChannels | User notification preferences |
| `GPTInteraction` | InteractionID (GUID) | *-1 Users | ChatGPT/AI chatbot conversation history |

**Module 9: Notice Board (1 table)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `Notices` | NoticeID (GUID) | *-1 Users (CreatedBy) | Company-wide notices/announcements |

**Module 10: External Data (2 tables)**

| Table | Primary Key | Key Relationships | Description |
|-------|-------------|-------------------|-------------|
| `ExchangeRates` | RateID (GUID) | - | Currency exchange rates (future use) |
| `HolidayCalendar` | HolidayID (GUID) | - | Public holidays for attendance rules |

##### **Key Database Constraints & Indexes**

**Foreign Key Constraints:**
- **ON DELETE CASCADE:** UserRoles, OrderDetails, ReservationItems (child records deleted with parent)
- **ON DELETE SET NULL:** AuditLogs.UserID, Orders.CreatedBy (preserve data, nullify reference)
- **ON DELETE NO ACTION:** PaymentTransactions (prevent deletion if transactions exist)

**Unique Constraints:**
- Users.Email, Users.Phone (no duplicates)
- Employees.EmployeeCode (unique employee numbers)
- Products.Name (no duplicate product names)
- Reservations.ReservationCode (unique booking codes)

**Indexes for Performance:**
- `IX_Users_Email`, `IX_Users_IsActive`
- `IX_Orders_SessionID`, `IX_Orders_OrderDate`, `IX_Orders_Status`
- `IX_OrderDetails_OrderID`, `IX_OrderDetails_ProductVariantID`
- `IX_TableSessions_TableID`, `IX_TableSessions_Status`
- `IX_Reservations_ArrivalTime`, `IX_Reservations_Status`
- `IX_EmployeeAttendance_EmployeeID`, `IX_EmployeeAttendance_Date`
- `IX_PurchaseOrders_SupplierID`, `IX_PurchaseOrders_Status`

**Database Triggers:**
- `TRG_Cleanup_OtpTokens`: Auto-delete expired/used OTP tokens
- `TRG_Orders_StatusChange`: Log order status changes to OrderStatusHistory
- `TRG_Reservations_UpdatedAt`: Auto-update timestamp on reservation changes

---

#### 3.2 Code Packages

**Java Package Structure (Maven Project):**

```
com.liteflow/
│
├── controller/                     # HTTP Servlet Controllers (24 servlets)
│   ├── AttendanceServlet.java      # Clock in/out, attendance tracking
│   ├── CashierServlet.java         # POS UI rendering
│   ├── CashierAPIServlet.java      # POS RESTful API (AJAX)
│   ├── CompensationServlet.java    # Payroll compensation management
│   ├── DailyReportServlet.java     # Daily business reports
│   ├── DashboardServlet.java       # Owner/Admin dashboard
│   ├── DashboardEmployeeServlet.java # Employee personal dashboard
│   ├── EmployeeServlet.java        # Employee CRUD operations
│   ├── ForgotClockRequestServlet.java # Handle forgot clock requests
│   ├── GetSessionOrdersServlet.java # Fetch orders by table session
│   ├── KitchenServlet.java         # Kitchen display system
│   ├── LeaveRequestServlet.java    # Leave request management
│   ├── NotificationAPIServlet.java # Notification center API
│   ├── PersonalScheduleServlet.java # Personal schedule view
│   ├── ProductServlet.java         # Product catalog management
│   ├── RecalculateAttendanceFlagsServlet.java # Admin tool
│   ├── ReceptionServlet.java       # Reservation management
│   ├── RoomTableServlet.java       # Room and table configuration
│   ├── ScheduleServlet.java        # Shift scheduling
│   ├── SetPriceServlet.java        # Product pricing
│   ├── SetupEmployeeServlet.java   # Employee setup wizard
│   ├── TestServlet.java            # Development testing
│   ├── TimesheetServlet.java       # Timesheet operations
│   └── UpdateOrderStatusServlet.java # Kitchen order status updates
│
├── web/                            # Web Layer (Additional Servlets)
│   ├── auth/                       # Authentication servlets (12 classes)
│   │   ├── LoginServlet.java       # Email/password login
│   │   ├── LoginGoogleServlet.java # Google OAuth2 login
│   │   ├── OAuth2CallbackServlet.java # OAuth2 callback handler
│   │   ├── LogoutServlet.java      # Session termination
│   │   ├── SignupServlet.java      # User registration
│   │   ├── VerifyOtpServlet.java   # OTP verification (2FA)
│   │   ├── ForgotPasswordServlet.java # Password recovery request
│   │   ├── ResetPasswordServlet.java # Set new password
│   │   ├── SendOtpServlet.java     # Resend OTP
│   │   ├── RefreshServlet.java     # JWT token refresh
│   │   ├── DebugOtpServlet.java    # Dev: OTP testing
│   │   └── DebugHashServlet.java   # Dev: Password hash testing
│   │
│   ├── procurement/                # Procurement servlets (6 classes)
│   │   ├── PurchaseOrderServlet.java # PO CRUD operations
│   │   ├── SupplierServlet.java    # Supplier management
│   │   ├── POItemsServlet.java     # PO items API
│   │   ├── GoodsReceiptServlet.java # GR recording
│   │   ├── InvoiceServlet.java     # Invoice management
│   │   └── ProcurementDashboardServlet.java # Procurement analytics
│   │
│   ├── sales/                      # Sales servlets (3 classes)
│   │   ├── SalesInvoiceServlet.java # Invoice generation
│   │   ├── SalesInvoicePageServlet.java # Invoice UI
│   │   └── SalesInvoiceTestServlet.java # Dev testing
│   │
│   ├── report/                     # Reporting servlets (3 classes)
│   │   ├── RevenueReportServlet.java # Revenue analytics
│   │   ├── TestRevenueAPIServlet.java # Dev: API testing
│   │   └── TestJPQLServlet.java    # Dev: JPQL testing
│   │
│   ├── alert/                      # Alert servlets (3 classes)
│   │   ├── AlertServlet.java       # Alert management API
│   │   ├── AlertTestServlet.java   # Dev: Alert testing
│   │   └── SendNotificationServlet.java # Admin notification sender
│   │
│   ├── api/                        # API servlets (3 classes)
│   │   ├── ChatBotServlet.java     # AI chatbot (OpenAI integration)
│   │   ├── ChatBotDebugServlet.java # Dev: Chatbot testing
│   │   └── DemandForecastServlet.java # Demand forecasting API
│   │
│   └── notice/                     # Notice board (1 class)
│       └── NoticeServlet.java      # Notice CRUD API
│
├── service/                        # Business Logic Layer
│   ├── auth/                       # Authentication services (5 classes)
│   │   ├── AuthService.java        # Login, logout, session management
│   │   ├── UserService.java        # User CRUD operations
│   │   ├── RoleService.java        # Role management
│   │   ├── AuditService.java       # Audit logging
│   │   └── OtpService.java         # OTP generation and verification
│   │
│   ├── inventory/                  # Inventory services (4 classes)
│   │   ├── ExcelService.java       # Excel import/export
│   │   ├── RoomTableService.java   # Room/table management
│   │   ├── ReservationService.java # Reservation logic
│   │   └── InventoryService.java   # (Future placeholder)
│   │
│   ├── procurement/                # Procurement services (2 classes)
│   │   ├── ProcurementService.java # PO, GR workflows
│   │   └── InvoiceMatchingService.java # Invoice validation
│   │
│   ├── alert/                      # Alert services (4 classes)
│   │   ├── AlertService.java       # Alert triggering
│   │   ├── AlertSchedulerService.java # Scheduled alert checks
│   │   ├── NotificationService.java # Notification delivery
│   │   └── UserAlertPreferenceService.java # User preferences
│   │
│   ├── analytics/                  # Analytics services (1 class)
│   │   └── DemandForecastService.java # Demand prediction
│   │
│   ├── ai/                         # AI services (1 class)
│   │   └── GPTService.java         # OpenAI ChatGPT integration
│   │
│   ├── notice/                     # Notice services (1 class)
│   │   └── NoticeService.java      # Notice business logic
│   │
│   ├── report/                     # Report services (1 class)
│   │   └── RevenueReportService.java # Report generation
│   │
│   ├── OrderService.java           # Order processing logic
│   ├── EmployeeService.java        # Employee management
│   ├── ScheduleService.java        # Shift scheduling logic
│   ├── TimesheetService.java       # Timesheet calculations
│   ├── CompensationService.java    # Payroll calculations
│   ├── LeaveRequestService.java    # Leave request workflows
│   ├── ForgotClockRequestService.java # Forgot clock logic
│   └── PersonalScheduleService.java # Personal schedule logic
│
├── dao/                            # Data Access Layer (Repository Pattern)
│   ├── employee/                   # Employee DAOs (3 classes)
│   │   ├── EmployeeDAO.java        # Employee CRUD
│   │   ├── EmployeeShiftDAO.java   # Shift data access
│   │   └── ShiftTemplateDAO.java   # Shift template CRUD
│   │
│   ├── inventory/                  # Inventory DAOs (9 classes)
│   │   ├── ProductDAO.java         # Product CRUD
│   │   ├── ProductVariantDAO.java  # Variant CRUD
│   │   ├── ProductStockDAO.java    # Stock CRUD
│   │   ├── InventoryDAO.java       # Inventory operations
│   │   ├── OrderDAO.java           # Order CRUD
│   │   ├── TableDAO.java           # Table CRUD
│   │   ├── RoomDAO.java            # Room CRUD
│   │   ├── ReservationDAO.java     # Reservation CRUD
│   │   └── ReservationItemDAO.java # Reservation item CRUD
│   │
│   ├── procurement/                # Procurement DAOs (8 classes)
│   │   ├── SupplierDAO.java        # Supplier CRUD
│   │   ├── SupplierSLADAO.java     # SLA data access
│   │   ├── PurchaseOrderDAO.java   # PO CRUD
│   │   ├── PurchaseOrderItemDAO.java # PO item CRUD
│   │   ├── GoodsReceiptDAO.java    # GR CRUD
│   │   ├── GoodsReceiptItemDAO.java # GR item CRUD
│   │   ├── InvoiceDAO.java         # Invoice CRUD
│   │   ├── InvoiceItemDAO.java     # Invoice item CRUD
│   │   └── GenericDAO.java         # Generic DAO utilities
│   │
│   ├── timesheet/                  # Timesheet DAOs (5 classes)
│   │   ├── EmployeeAttendanceDAO.java # Attendance CRUD
│   │   ├── EmployeeShiftTimesheetDAO.java # Timesheet CRUD
│   │   ├── LeaveRequestDAO.java    # Leave request CRUD
│   │   ├── ForgotClockRequestDAO.java # Forgot clock CRUD
│   │   └── PersonalScheduleDAO.java # Personal schedule CRUD
│   │
│   ├── payroll/                    # Payroll DAOs (1 class)
│   │   └── EmployeeCompensationDAO.java # Compensation CRUD
│   │
│   ├── alert/                      # Alert DAOs (5 classes)
│   │   ├── AlertConfigurationDAO.java # Alert config CRUD
│   │   ├── AlertHistoryDAO.java    # Alert history CRUD
│   │   ├── NotificationChannelDAO.java # Channel CRUD
│   │   ├── UserAlertPreferenceDAO.java # Preference CRUD
│   │   └── GPTInteractionDAO.java  # GPT history CRUD
│   │
│   ├── analytics/                  # Analytics DAOs (1 class)
│   │   └── DemandForecastDAO.java  # Forecast data access
│   │
│   ├── notice/                     # Notice DAOs (1 class)
│   │   └── NoticeDAO.java          # Notice CRUD
│   │
│   ├── report/                     # Report DAOs (1 class)
│   │   └── RevenueReportDAO.java   # Report data queries
│   │
│   ├── sales/                      # Sales DAOs (1 class)
│   │   └── SalesInvoiceDAO.java    # Invoice data access
│   │
│   ├── BaseDAO.java                # Abstract base DAO (JPA EntityManager)
│   ├── GenericDAO.java             # Generic CRUD operations
│   ├── DBTest.java                 # Database connection testing
│   └── TestConnection.java         # Dev: Connection testing
│
├── model/                          # JPA Entity Models
│   ├── auth/                       # Auth entities (11 classes)
│   │   ├── User.java               # User entity
│   │   ├── Role.java               # Role entity
│   │   ├── UserRole.java           # User-Role link entity
│   │   ├── UserRoleId.java         # Composite key for UserRole
│   │   ├── UserSession.java        # Session entity
│   │   ├── OtpToken.java           # OTP token entity
│   │   ├── AuditLog.java           # Audit log entity
│   │   ├── Employee.java           # Employee entity
│   │   ├── EmployeeShift.java      # Shift entity
│   │   ├── EmployeeShiftAssignment.java # Shift assignment entity
│   │   └── ShiftTemplate.java      # Shift template entity
│   │
│   ├── inventory/                  # Inventory entities (19 classes)
│   │   ├── Product.java            # Product entity
│   │   ├── Category.java           # Category entity
│   │   ├── ProductCategory.java    # Product-Category link
│   │   ├── ProductVariant.java     # Product variant entity
│   │   ├── Inventory.java          # Inventory entity
│   │   ├── ProductStock.java       # Stock entity
│   │   ├── InventoryLog.java       # Inventory log entity
│   │   ├── Room.java               # Room entity
│   │   ├── Table.java              # Table entity
│   │   ├── TableSession.java       # Table session entity
│   │   ├── Order.java              # Order entity
│   │   ├── OrderDetail.java        # Order detail entity
│   │   ├── PaymentTransaction.java # Payment entity
│   │   ├── Reservation.java        # Reservation entity
│   │   ├── ReservationItem.java    # Reservation item entity
│   │   ├── UserInteraction.java    # User interaction entity
│   │   ├── LowStockItem.java       # Low stock DTO
│   │   ├── ProductDisplayDTO.java  # Product display DTO
│   │   └── ProductPriceDTO.java    # Product price DTO
│   │
│   ├── procurement/                # Procurement entities (8 classes)
│   │   ├── Supplier.java           # Supplier entity
│   │   ├── SupplierSLA.java        # SLA entity
│   │   ├── PurchaseOrder.java      # PO entity
│   │   ├── PurchaseOrderItem.java  # PO item entity
│   │   ├── GoodsReceipt.java       # GR entity
│   │   ├── GoodsReceiptItem.java   # GR item entity
│   │   ├── Invoice.java            # Invoice entity
│   │   └── InvoiceItem.java        # Invoice item entity
│   │
│   ├── timesheet/                  # Timesheet entities (6 classes)
│   │   ├── EmployeeAttendance.java # Attendance entity
│   │   ├── EmployeeShiftTimesheet.java # Timesheet entity
│   │   ├── LeaveRequest.java       # Leave request entity
│   │   ├── ForgotClockRequest.java # Forgot clock entity
│   │   ├── PersonalSchedule.java   # Personal schedule entity
│   │   └── ShiftPayRule.java       # Shift pay rule entity
│   │
│   ├── payroll/                    # Payroll entities (6 classes)
│   │   ├── PayrollRun.java         # Payroll run entity
│   │   ├── PayrollEntry.java       # Payroll entry entity
│   │   ├── EmployeeCompensation.java # Compensation entity
│   │   ├── PayPolicy.java          # Pay policy entity
│   │   ├── PayPeriod.java          # Pay period entity
│   │   └── PayrollAdjustment.java  # Payroll adjustment entity
│   │
│   ├── alert/                      # Alert entities (5 classes)
│   │   ├── AlertConfiguration.java # Alert config entity
│   │   ├── AlertHistory.java       # Alert history entity
│   │   ├── NotificationChannel.java # Channel entity
│   │   ├── UserAlertPreference.java # Preference entity
│   │   └── GPTInteraction.java     # GPT interaction entity
│   │
│   ├── notice/                     # Notice entities (1 class)
│   │   └── Notice.java             # Notice entity
│   │
│   └── external/                   # External data entities (2 classes)
│       ├── ExchangeRate.java       # Exchange rate entity
│       └── HolidayCalendar.java    # Holiday entity
│
├── dto/                            # Data Transfer Objects
│   └── reservation/                # Reservation DTOs (3 classes)
│       ├── ReservationDTO.java     # Reservation DTO
│       ├── PreOrderItemDTO.java    # Pre-order item DTO
│       └── ValidationResult.java   # Validation result DTO
│
├── filter/                         # HTTP Request Filters
│   ├── AuthenticationFilter.java   # JWT validation, role-based access
│   ├── LoginFilter.java            # Prevent re-login for authenticated users
│   ├── LogoutFilter.java           # Session cleanup
│   ├── CommonFilter.java           # UTF-8 encoding, CORS headers
│   └── BaseFilter.java             # Abstract base filter
│
├── security/                       # Security Utilities
│   ├── JwtUtil.java                # JWT token generation/validation
│   ├── TotpUtil.java               # TOTP 2FA utilities
│   ├── AuthUtils.java              # Authentication helper methods
│   └── AuthControllerHelper.java   # Auth controller utilities
│
├── util/                           # Utility Classes
│   ├── PasswordUtil.java           # BCrypt password hashing
│   ├── MailUtil.java               # Email sending (Jakarta Mail)
│   ├── Utils.java                  # General utilities (date, number format)
│   ├── OrderDataUtil.java          # Test data generation
│   └── HashGenerator.java          # Dev: Hash generation tool
│
├── job/                            # Scheduled Jobs (Quartz)
│   ├── ReservationOverdueJob.java  # Check overdue reservations
│   └── ProcurementAlertJob.java    # Check overdue POs, low stock
│
├── listener/                       # Application Listeners
│   └── AlertSchedulerListener.java # Initialize Quartz Scheduler on startup
│
└── config/                         # Configuration (if any)
    └── (Future: AppConfig.java, etc.)
```

**Layer Dependencies:**

```
┌──────────────────────────────────────────┐
│          Presentation Layer              │
│  (Servlets, Filters, JSP)                │
│  controller/*, web/*, filter/*           │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│          Business Logic Layer            │
│  (Services)                               │
│  service/*, security/*, util/*           │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│          Data Access Layer               │
│  (DAOs, Repositories)                     │
│  dao/*                                    │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│          Persistence Layer               │
│  (JPA Entities, Hibernate)               │
│  model/*, persistence.xml                │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│          Database                        │
│  (MS SQL Server: LiteFlowDBO)            │
└──────────────────────────────────────────┘
```

**Key Package Responsibilities:**

- **controller/**, **web/**: Handle HTTP requests, route to services, return responses
- **service/**: Implement business logic, orchestrate DAO operations, transaction management
- **dao/**: Database CRUD operations, JPA queries, entity management
- **model/**: JPA entity definitions, database schema mapping
- **filter/**: Request/response interception, authentication, authorization
- **security/**: JWT, TOTP, password hashing, auth utilities
- **util/**: Reusable helper functions (email, date, currency)
- **job/**: Background scheduled tasks (Quartz jobs)
- **listener/**: Application lifecycle event handlers

---

---

## II. Requirement Specifications

### 1. Authentication & Authorization Feature

#### 1.1 UC-1_Login System

**Use Case ID:** UC-01  
**Use Case Name:** Login System  
**Primary Actor:** All Users  
**Priority:** High  
**Complexity:** Medium

**Description:**  
Users authenticate into the LiteFlow system using email/password, Google OAuth2, or two-factor authentication (2FA) with TOTP codes. The system supports multiple authentication methods and role-based redirection after successful login.

**Inputs:**
- Email address (String, required for email/password login)
- Password (String, required for email/password login)
- Google OAuth2 token (String, optional, for Google Sign-In)
- OTP code (String, required if 2FA is enabled)
- "Remember Me" checkbox (Boolean, optional)

**Preconditions:**
- User account exists in the system (Users table)
- User account is active (IsActive = true)
- For email/password: User has a valid password hash stored
- For Google OAuth2: User has GoogleID configured or can be created
- For 2FA: User has TwoFactorSecret configured (if required)

**Main Flow:**

**1.1 Email/Password Login Flow:**

1. User navigates to `/login` page (auth/login.jsp)
2. User enters email and password in login form
3. User submits form (POST to `/login`)
4. System validates CSRF token
5. System retrieves User by email from database (UserService.getUserByEmail())
6. System validates password hash using BCrypt (AuthUtils.verifyPassword())
7. **If password invalid:**
   - System logs failed login attempt (AuditService.logLoginFail())
   - System displays error: "Đăng nhập thất bại. Vui lòng kiểm tra email/mật khẩu."
   - Use case ends with failure
8. **If password valid:**
   - System checks if 2FA is required (AuthService.is2faRequired())
   - System evaluates 2FA requirement based on:
     - Admin users: Always required (uses fixed OTP "000000")
     - Regular users: Required if Last2FAVerifiedAt is null or > 24 hours ago
     - System checks active session within last 24 hours
9. **If 2FA required:**
   - System generates OTP:
     - Admin: Fixed OTP "000000" (OtpService.issueFixedOtp())
     - Regular users: Random 6-digit OTP sent via email (OtpService.issueOtp())
   - System sends OTP email (MailUtil.sendOtpMail())
   - System stores pending user ID and access token in session
   - System sets session attribute: "otpContext" = "login"
   - System redirects to `/auth/verify` (verify-login.jsp)
   - User enters OTP code
   - System verifies OTP (VerifyOtpServlet)
   - **If OTP invalid/expired:** Display error, allow resend
   - **If OTP valid:** Continue to step 10
10. **If 2FA not required or OTP verified:**
    - System generates JWT token (JwtUtil.issue()) with:
      - UserID, Email, DisplayName in claims
      - User roles from UserRoles table
      - Expiration: 3600 seconds (1 hour)
    - System creates UserSession record in database:
      - SessionID (GUID)
      - UserID (FK to Users)
      - JWT token
      - DeviceInfo (User-Agent header)
      - IPAddress
      - CreatedAt, ExpiresAt
      - Revoked = false
    - System updates User.Last2FAVerifiedAt if 2FA was verified
    - System sets session attribute: "UserLogin" = user object
    - System sets HTTP cookie: "accessToken" = JWT (if Remember Me: 7 days, otherwise session cookie)
    - System logs successful login (AuditService.logLoginAttempt())
11. System determines redirect URL based on user role:
    - Owner/Admin → `/dashboard`
    - Cashier → `/cashier`
    - Kitchen Staff → `/kitchen`
    - Employee → `/dashboard-employee`
    - Default → `/dashboard`
12. System redirects user to appropriate dashboard
13. Use case ends with success

**1.2 Google OAuth2 Login Flow:**

1. User clicks "Sign in with Google" button on login page
2. System redirects to Google OAuth2 authorization endpoint
3. User authenticates with Google and grants permissions
4. Google redirects back to `/oauth2callback` (OAuth2CallbackServlet)
5. System receives authorization code from Google
6. System exchanges code for access token via Google API
7. System retrieves user info from Google (email, name, GoogleID)
8. System checks if user exists by email (UserService.getUserByEmail())
9. **If user does not exist:**
   - System creates new User:
     - Email from Google
     - DisplayName from Google
     - GoogleID stored
     - PasswordHash set to random hash (user must set password later)
     - IsActive = true
   - System assigns default role "Employee"
10. **If user exists:**
    - System updates GoogleID if not set
    - System updates DisplayName if changed
11. System generates JWT and creates UserSession (same as step 10 in email/password flow)
12. System redirects to dashboard based on role
13. Use case ends with success

**Alternative Flows:**

**A1. Account Inactive:**
- **At step 6:** If user.IsActive = false
- System logs failed login attempt
- System displays error: "Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên."
- Use case ends with failure

**A2. OTP Expired:**
- **At OTP verification:** If OTP code expired (>5 minutes) or already used
- System displays error: "Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới."
- User can request new OTP (resend button)
- Flow returns to step 9

**A3. Invalid OTP:**
- **At OTP verification:** If OTP code does not match
- System displays error: "Mã OTP không đúng. Vui lòng thử lại."
- User can retry OTP entry
- Flow returns to OTP verification

**A4. Session Expired:**
- **At step 5:** If JWT token expired or session revoked
- System redirects to login page
- System displays message: "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."
- Use case ends with failure

**A5. CSRF Token Invalid:**
- **At step 4:** If CSRF token mismatch or missing
- System displays error: "Invalid request. Please refresh and try again."
- User must refresh page and retry
- Flow returns to step 1

**A6. Email Not Found:**
- **At step 5:** If user email does not exist in database
- System logs failed login attempt
- System displays generic error (security: no information leak)
- Use case ends with failure

**Outputs:**
- JWT access token (stored in HTTP cookie and session)
- UserSession record created in database
- Redirect to role-based dashboard
- Session cookie set with user information

**Postconditions:**
- User is authenticated and logged into system
- UserSession record exists with active status
- JWT token is valid and stored
- User can access protected resources based on role
- Audit log entry created for login attempt (success/failure)

**Business Rules:**
- Password must be hashed with BCrypt before storage
- JWT token expires after 1 hour (configurable)
- 2FA is required for admin users on every login
- 2FA is required for regular users if last verification was > 24 hours ago
- OTP codes expire after 5 minutes
- Failed login attempts are logged for security auditing
- "Remember Me" extends session cookie to 7 days

---

#### 1.2 UC-2_Password Recovery

**Use Case ID:** UC-02  
**Use Case Name:** Password Recovery  
**Primary Actor:** All Users  
**Priority:** High  
**Complexity:** Low

**Description:**  
Users can recover forgotten passwords by requesting a one-time password (OTP) via email, verifying the OTP, and setting a new password.

**Inputs:**
- Email address (String, required)
- OTP code (String, required, 6 digits)
- New password (String, required, min 8 characters)
- Confirm password (String, required, must match new password)

**Preconditions:**
- User account exists with the provided email
- User account is active (IsActive = true)
- User has access to registered email address
- No active OTP request pending (or previous OTP expired)

**Main Flow:**

1. User navigates to `/auth/forgot` (forgot.jsp)
2. User enters email address and submits form
3. System validates email format
4. **If email invalid:** Display error, return to step 2
5. System retrieves User by email (UserService.getUserByEmail())
6. **If user not found:**
   - System displays generic success message (security: no information leak)
   - "Nếu email tồn tại, bạn sẽ nhận được mã OTP trong vài phút."
   - Use case ends (prevent email enumeration)
7. **If user found:**
   - System generates 6-digit random OTP (OtpService.issueOtp())
   - System creates OtpToken record:
     - OtpID (GUID)
     - UserID (FK to Users)
     - Code (6-digit string)
     - ExpiresAt (now + 5 minutes)
     - Used = false
     - IPAddress
     - TargetEmail
   - System sends OTP via email (MailUtil.sendOtpMail())
   - System logs OTP issuance (AuditService.logOtpIssued())
   - System redirects to `/auth/verify-forgot` (verify-forgot.jsp)
8. User enters OTP code from email
9. User submits OTP for verification
10. System validates OTP:
    - Checks OtpToken record by UserID and Code
    - Verifies OTP not expired (ExpiresAt > now)
    - Verifies OTP not used (Used = false)
11. **If OTP invalid:**
    - Display error: "Mã OTP không đúng hoặc đã hết hạn."
    - Allow user to request new OTP
    - Flow returns to step 7
12. **If OTP valid:**
    - System marks OtpToken as Used = true
    - System stores verified user ID in session
    - System redirects to `/auth/reset` (reset.jsp)
13. User enters new password and confirmation
14. System validates password:
    - Minimum 8 characters
    - Must match confirmation
15. **If password invalid:** Display error, return to step 13
16. **If password valid:**
    - System hashes new password with BCrypt (PasswordUtil.hashPassword())
    - System updates User.PasswordHash in database
    - System invalidates all existing OTP tokens for user
    - System logs password reset (AuditService.logAction())
    - System sends confirmation email (MailUtil.sendPasswordResetConfirmation())
    - System displays success message: "Mật khẩu đã được đặt lại thành công."
    - System redirects to `/login`
17. Use case ends with success

**Alternative Flows:**

**A1. Email Not Found (Security):**
- **At step 6:** System does not reveal if email exists
- System always displays success message
- No email is sent if user does not exist
- Prevents email enumeration attacks

**A2. OTP Expired:**
- **At step 10:** If OTP expired (>5 minutes)
- System displays error
- User must request new OTP
- Flow returns to step 2

**A3. Multiple OTP Requests:**
- **At step 7:** If user requests multiple OTPs
- System invalidates previous unused OTPs
- Only latest OTP is valid
- Previous OTPs marked as Used

**A4. Invalid Password Format:**
- **At step 14:** If password does not meet requirements
- System displays: "Mật khẩu phải có ít nhất 8 ký tự."
- Flow returns to step 13

**A5. Password Mismatch:**
- **At step 14:** If new password ≠ confirm password
- System displays: "Mật khẩu xác nhận không khớp."
- Flow returns to step 13

**Outputs:**
- OTP email sent to user (if account exists)
- Password updated in database (BCrypt hash)
- Confirmation email sent
- Redirect to login page

**Postconditions:**
- User password is updated (if OTP verified)
- All OTP tokens for user are invalidated
- User can login with new password
- Audit log entry created for password reset

**Business Rules:**
- OTP expires after 5 minutes
- OTP can only be used once
- Password must be minimum 8 characters
- New password cannot be same as old password (not enforced in current implementation)
- Only one active OTP per user (new request invalidates old)

---

#### 1.3 UC-3_User Registration

**Use Case ID:** UC-03  
**Use Case Name:** User Registration  
**Primary Actor:** Admin, Owner  
**Priority:** Medium  
**Complexity:** Low

**Description:**  
Administrators create new user accounts in the system with email, password, display name, and role assignment. New users receive welcome emails with login credentials.

**Inputs:**
- Email address (String, required, unique)
- Password (String, required, min 8 characters)
- Display Name (String, required)
- Phone number (String, optional)
- Role(s) (Array of Role names, required)
- Is Active (Boolean, default: true)

**Preconditions:**
- User performing registration is authenticated as Admin or Owner
- Email address is not already registered in system
- Password meets security requirements
- Selected roles exist in Roles table

**Main Flow:**

1. Admin navigates to user management page or signup page
2. Admin fills registration form:
   - Email
   - Password
   - Display Name
   - Phone (optional)
   - Role selection (checkboxes)
3. Admin submits form (POST to `/register` or UserService.createUser())
4. System validates CSRF token
5. System validates email format
6. **If email invalid:** Display error, return to step 2
7. System checks if email already exists (UserService.getUserByEmail())
8. **If email exists:**
    - System displays error: "Email đã được sử dụng. Vui lòng chọn email khác."
    - Flow returns to step 2
9. **If email unique:**
    - System validates password strength
    - System hashes password with BCrypt (PasswordUtil.hashPassword())
    - System creates User record:
      - UserID (GUID)
      - Email (unique)
      - PasswordHash (BCrypt)
      - DisplayName
      - Phone (optional)
      - IsActive = true (default)
      - CreatedAt = now
      - UpdatedAt = now
10. System assigns roles to user:
    - For each selected role:
      - System retrieves Role by name (RoleService.getRoleByName())
      - System creates UserRole record:
        - UserID + RoleID (composite key)
        - AssignedAt = now
        - AssignedBy = current admin UserID
        - IsActive = true
11. System logs user creation (AuditService.logAction())
12. System sends welcome email (MailUtil.sendWelcomeEmail()):
    - Email contains login URL
    - Email contains temporary password (if auto-generated)
    - Email contains instructions for first login
13. System displays success message: "Tài khoản đã được tạo thành công."
14. System redirects to user management page or dashboard
15. Use case ends with success

**Alternative Flows:**

**A1. Invalid Password:**
- **At step 9:** If password does not meet requirements
- System displays: "Mật khẩu phải có ít nhất 8 ký tự."
- Flow returns to step 2

**A2. Role Not Found:**
- **At step 10:** If selected role does not exist
- System displays: "Vai trò không hợp lệ."
- Flow returns to step 2

**A3. Email Already Exists:**
- **At step 8:** If email is duplicate
- System prevents duplicate registration
- Flow returns to step 2 with error

**A4. Missing Required Fields:**
- **At step 4:** If email or password is empty
- System displays: "Vui lòng điền đầy đủ thông tin bắt buộc."
- Flow returns to step 2

**A5. No Role Selected:**
- **At step 10:** If no role is selected
- System displays: "Người dùng phải có ít nhất một vai trò."
- Flow returns to step 2

**Outputs:**
- User record created in Users table
- UserRole records created in UserRoles table
- Welcome email sent to new user
- Success confirmation message

**Postconditions:**
- New user account exists in system
- User has assigned roles and can login
- User receives welcome email with credentials
- Audit log entry created for user creation

**Business Rules:**
- Email must be unique across all users
- User must have at least one role assigned
- Password must be minimum 8 characters
- User account is active by default
- Created user can login immediately (unless 2FA required)
- Welcome email must be sent successfully (best-effort)

---

### 2. Common Functions

#### 2.1 UC-2_Login System (Detailed)

**Note:** This is a detailed version of UC-01_Login System with additional implementation details for reference.

**Technical Implementation Details:**

**Components Involved:**
- `LoginServlet.java`: HTTP request handler
- `AuthService.java`: Authentication business logic
- `UserService.java`: User data operations
- `OtpService.java`: OTP generation and verification
- `JwtUtil.java`: JWT token generation
- `AuthenticationFilter.java`: Session validation
- `verify-otp.jsp`: OTP verification UI
- `login.jsp`: Login form UI

**Session Management:**
- HTTP Session (Jakarta Servlet Session)
- JWT token in HTTP cookie
- UserSession table in database
- Session expiry: 1 hour (JWT), configurable

**Security Features:**
- CSRF token protection
- Password hashing (BCrypt)
- JWT token signing (HMAC SHA-256)
- OTP expiration (5 minutes)
- Failed login attempt logging
- IP address tracking

**Error Handling:**
- Generic error messages (no information leakage)
- Audit logging for security events
- Graceful degradation for email failures
- Session timeout handling

---

### 3. POS/Cashier Feature

#### 3.1 UC-5_Order a Meal

**Use Case ID:** UC-07 (Note: UC-05 in original list, but renumbered here)  
**Use Case Name:** Order a Meal  
**Primary Actor:** Cashier  
**Priority:** High  
**Complexity:** High

**Description:**  
Cashiers create customer orders by selecting a table, browsing the product catalog, adding items to cart, validating stock availability, and submitting orders. The system automatically deducts inventory and notifies the kitchen when orders are created.

**Inputs:**
- TableID (GUID, required)
- Product items (Array of):
  - ProductVariantID (GUID, required)
  - Quantity (Integer, required, > 0)
  - Special Instructions (String, optional)
- Order Note (String, optional)
- Invoice Name (String, optional, e.g., "Bàn 1 - HD 1")

**Preconditions:**
- User is authenticated as Cashier role
- Table exists and is available (Status = 'Available' or has active session)
- Products exist and are not deleted
- Product variants have stock available (Quantity <= ProductStock.Amount)

**Main Flow:**

1. Cashier logs in and navigates to Cashier dashboard (`/cashier`)
2. Cashier selects table/room (`inventory/roomtable.jsp`):
   - System displays available tables with status (Available, Occupied, Reserved)
   - Cashier clicks on a table
3. System checks table status:
   - **If table is Available:**
     - System creates new TableSession:
       - SessionID (GUID)
       - TableID (FK)
       - CheckInTime = now
       - Status = 'Active'
       - PaymentStatus = 'Unpaid'
       - CreatedBy = current user
     - System updates Table.Status = 'Occupied'
   - **If table has active session:**
     - System retrieves existing TableSession
     - System continues with existing session
4. Cashier navigates to POS screen (`cart/cashier.jsp`)
5. System loads product catalog:
   - System queries Products (IsDeleted = false, Status = 'Đang bán')
   - System loads ProductVariant with prices
   - System displays products grouped by Category
   - System shows stock levels (ProductStock.Amount)
6. Cashier browses products and adds items to cart:
   - Cashier selects product variant (size, options)
   - Cashier sets quantity
   - Cashier adds special instructions (optional)
   - System adds item to cart (in-memory, JavaScript array)
7. System calculates cart totals:
   - Subtotal = Sum(UnitPrice × Quantity) for all items
   - VAT = Subtotal × 0.1 (10%, configurable)
   - Discount = 0 (or applied discount code)
   - TotalAmount = Subtotal + VAT - Discount
8. Cashier clicks "Submit Order" button
9. System validates cart:
   - Cart must not be empty
   - Each item must have valid ProductVariantID
   - Each item quantity must be > 0
10. **If validation fails:** Display error, return to step 6
11. **If validation passes:**
    - System starts database transaction
    - System validates stock availability for each item:
      - Query ProductStock by ProductVariantID and InventoryID
      - Check: ProductStock.Amount >= requested Quantity
    - **If any item out of stock:**
      - System rolls back transaction
      - System displays error: "Sản phẩm [ProductName] đã hết hàng."
      - Flow returns to step 6
12. **If stock available:**
    - System generates OrderNumber (format: "ORD" + YYYYMMDD + 001)
    - System creates Order record:
      - OrderID (GUID)
      - SessionID (FK to TableSessions)
      - OrderNumber (unique)
      - OrderDate = now
      - Status = 'Pending'
      - PaymentStatus = 'Unpaid'
      - SubTotal = calculated subtotal
      - VAT = calculated VAT
      - Discount = calculated discount
      - TotalAmount = calculated total
      - Notes = order note
      - CreatedBy = current user
    - System creates OrderDetails for each cart item:
      - OrderDetailID (GUID)
      - OrderID (FK)
      - ProductVariantID (FK)
      - Quantity
      - UnitPrice (from ProductVariant.Price)
      - TotalPrice = UnitPrice × Quantity
      - SpecialInstructions
      - Status = 'Pending'
    - System deducts inventory:
      - For each OrderDetail:
        - Update ProductStock: Amount = Amount - Quantity
        - Create InventoryLog record:
          - ActionType = 'OUT'
          - QuantityChanged = -Quantity
          - ProductVariantID
          - ActionDate = now
    - System commits transaction
13. System updates TableSession.TotalAmount:
    - TotalAmount = Sum of all Orders.TotalAmount in session
14. System triggers kitchen notification:
    - System creates notification (NotificationAPIServlet)
    - System sends real-time update to Kitchen Display System
    - Kitchen receives new order in queue
15. System displays success message: "Đơn hàng [OrderNumber] đã được tạo thành công."
16. System clears cart
17. System refreshes product list (stock updated)
18. System displays order in order history
19. Use case ends with success

**Alternative Flows:**

**A1. Table Already Occupied:**
- **At step 3:** If table Status = 'Occupied' and no active session
- System displays warning: "Bàn đang được sử dụng. Bạn có muốn tiếp tục?"
- Cashier can choose to:
  - Create new session (override)
  - Cancel and select different table

**A2. Stock Insufficient:**
- **At step 11:** If ProductStock.Amount < requested Quantity
- System identifies specific out-of-stock items
- System displays error with item names
- Cashier can:
  - Remove out-of-stock items
  - Reduce quantities
  - Cancel order

**A3. Product Deleted:**
- **At step 5:** If product IsDeleted = true or Status ≠ 'Đang bán'
- System hides product from catalog
- Product not available for selection

**A4. Concurrent Order Modification:**
- **At step 11:** If another user modifies same table session
- System detects conflict
- System displays: "Bàn đang được cập nhật. Vui lòng làm mới trang."
- Flow returns to step 4

**A5. Payment Before Order:**
- **At step 8:** If cashier attempts payment before order submission
- System prevents payment (no order exists)
- System displays: "Vui lòng tạo đơn hàng trước khi thanh toán."

**A6. Cart Empty:**
- **At step 9:** If cart is empty when submitting
- System displays: "Giỏ hàng trống. Vui lòng thêm sản phẩm."
- Flow returns to step 6

**Outputs:**
- Order record created (OrderID, OrderNumber)
- OrderDetails records created
- Inventory stock deducted
- InventoryLog records created
- Kitchen notification sent
- Success confirmation message

**Postconditions:**
- Order exists with Status = 'Pending'
- Inventory stock levels reduced
- Table session active with unpaid status
- Kitchen notified of new order
- Order appears in kitchen queue
- Order history updated

**Business Rules:**
- Order cannot be created if any item is out of stock
- Stock deduction is atomic (all-or-nothing transaction)
- Order number is unique per day (format: ORDYYYYMMDD001)
- Order status workflow: Pending → Preparing → Ready → Served
- Inventory cannot go negative (enforced by validation)
- Order total includes VAT (10% default, configurable)
- Special instructions are stored per order detail item

---

---

### 4. Kitchen Management Feature

#### 4.1 UC-15_Update Order Status

**Use Case ID:** UC-15  
**Use Case Name:** Update Order Status  
**Primary Actor:** Kitchen Staff  
**Priority:** High  
**Complexity:** Medium

**Description:**  
Kitchen staff updates order status through the workflow: Pending → Preparing → Ready → Served. The system tracks status changes and notifies cashiers when orders are ready for pickup.

**Inputs:**
- OrderID (GUID, required)
- New Status (String, required: "Preparing", "Ready", "Served")
- Notes (String, optional)

**Preconditions:**
- User is authenticated as Kitchen Staff role
- Order exists with valid OrderID
- Order status allows transition to new status (workflow validation)
- Order has not been cancelled

**Main Flow:**

1. Kitchen staff logs in and navigates to Kitchen Display (`/kitchen`)
2. System loads pending orders queue:
   - System queries Orders with Status IN ('Pending', 'Preparing')
   - System sorts by OrderDate (oldest first)
   - System displays order cards with:
     - OrderNumber
     - Table/Room name
     - Order items (ProductVariant name, Quantity)
     - Special instructions
     - Current status
3. Kitchen staff selects an order
4. System displays order details modal:
   - All order items with quantities
   - Special instructions per item
   - Customer table information
   - Order timestamp
5. Kitchen staff clicks status action button:
   - **If status = 'Pending':** Button "Bắt đầu làm" → Transition to "Preparing"
   - **If status = 'Preparing':** Button "Hoàn thành" → Transition to "Ready"
   - **If status = 'Ready':** Button "Đã phục vụ" → Transition to "Served"
6. System validates status transition:
   - Valid transitions: Pending → Preparing → Ready → Served
   - Invalid transitions: Served → Ready (cannot reverse)
   - Cancelled orders cannot change status
7. **If transition invalid:** Display error, flow returns to step 3
8. **If transition valid:**
    - System starts database transaction
    - System updates Order.Status = newStatus
    - System updates Order.UpdatedAt = now
    - System updates all OrderDetails.Status = newStatus
    - System creates OrderStatusHistory record:
      - OrderID (FK)
      - OldStatus
      - NewStatus
      - ChangedAt = now
      - ChangedBy = current user
      - OrderDetailsSnapshot (JSON)
    - System commits transaction
9. **If newStatus = 'Ready':**
    - System creates notification for Cashier
    - System sends real-time update (AJAX polling or WebSocket)
    - Kitchen notification bell appears for Cashier
10. **If newStatus = 'Served':**
    - System removes order from kitchen queue
    - System updates order completion time
11. System refreshes kitchen order queue
12. System displays success: "Đã cập nhật trạng thái thành công!"
13. Use case ends with success

**Alternative Flows:**

**A1. Order Not Found:**
- **At step 6:** If OrderID does not exist
- System displays: "Không tìm thấy đơn hàng."
- Flow returns to step 2

**A2. Invalid Status Transition:**
- **At step 6:** If attempting invalid transition (e.g., Served → Ready)
- System displays: "Không thể chuyển trạng thái này."
- Flow returns to step 5

**A3. Order Already Cancelled:**
- **At step 6:** If Order.Status = 'Cancelled'
- System prevents status update
- System displays: "Đơn hàng đã bị hủy, không thể cập nhật trạng thái."

**A4. Concurrent Status Update:**
- **At step 8:** If another user updates same order simultaneously
- System detects conflict (Status changed since load)
- System displays: "Đơn hàng đã được cập nhật. Vui lòng làm mới."
- Flow returns to step 2

**Outputs:**
- Order.Status updated in database
- OrderDetails.Status updated
- OrderStatusHistory record created
- Kitchen notification sent (if Ready)
- Queue refresh triggered

**Postconditions:**
- Order status changed to new status
- Status history logged for audit
- Cashier notified (if Ready)
- Kitchen queue updated
- Order removed from queue (if Served)

**Business Rules:**
- Status workflow is sequential: Pending → Preparing → Ready → Served
- Cannot skip steps (e.g., Pending → Ready)
- Cannot reverse status (e.g., Ready → Preparing)
- Cancelled orders cannot change status
- Status change triggers audit log entry
- Ready status triggers cashier notification

---

### 5. Inventory Management Feature

#### 5.1 UC-18_Create Product

**Use Case ID:** UC-18  
**Use Case Name:** Create Product  
**Primary Actor:** Inventory Manager  
**Priority:** High  
**Complexity:** Medium

**Description:**  
Inventory managers create new products in the catalog with basic information, categories, variants, prices, images, and initial stock levels.

**Inputs:**
- Product Name (String, required, unique)
- Description (String, optional)
- Category IDs (Array of GUID, optional)
- Image File (File upload, optional)
- Variants (Array of):
  - Size (String, required, e.g., "S", "M", "L")
  - OriginalPrice (Decimal, required)
  - Price (Decimal, required)
  - DiscountPrice (Decimal, optional)
  - DiscountExpiry (DateTime, optional)
- Initial Stock Amount (Integer, default: 0)
- Product Type (String, optional)
- Status (String, default: "Đang bán")
- Unit (String, optional, e.g., "chai", "gói")

**Preconditions:**
- User is authenticated as Inventory Manager or Admin
- Product name is unique (not already exists)
- Categories exist (if provided)
- Image file format is valid (JPG, PNG, max 5MB)

**Main Flow:**

1. Inventory manager navigates to Product List (`inventory/productlist.jsp`)
2. Inventory manager clicks "Add Product" button
3. System displays product creation form
4. Inventory manager fills form:
   - Product Name
   - Description
   - Category selection (multiple)
   - Image upload
   - Variant information
   - Stock amount
5. Inventory manager submits form (POST to `/products`)
6. System validates CSRF token
7. System validates product name uniqueness (ProductService.isProductNameExists())
8. **If name exists:** Display error: "Tên sản phẩm đã tồn tại." → Return to step 4
9. **If name unique:**
    - System starts database transaction
    - System creates Product record:
      - ProductID (GUID)
      - Name (unique)
      - Description
      - ImageURL (if uploaded, saved to `/uploads/products/`)
      - ProductType
      - Status = "Đang bán"
      - Unit
      - IsDeleted = false
      - ImportDate = now
    - System creates ProductCategories (if categories selected):
      - ProductID + CategoryID (many-to-many)
    - System creates ProductVariant records (for each variant):
      - ProductVariantID (GUID)
      - ProductID (FK)
      - Size
      - OriginalPrice
      - Price
      - DiscountPrice (if provided)
      - DiscountExpiry (if provided)
      - IsDeleted = false
    - System creates ProductStock records:
      - ProductStockID (GUID)
      - ProductVariantID (FK)
      - InventoryID (default: Main Warehouse)
      - Amount = Initial Stock Amount
    - System creates InventoryLog record:
      - ActionType = 'IN'
      - QuantityChanged = Initial Stock Amount
      - ProductVariantID
      - ActionDate = now
    - System commits transaction
10. System displays success: "Sản phẩm đã được tạo thành công."
11. System redirects to product list
12. Use case ends with success

**Alternative Flows:**

**A1. Duplicate Product Name:**
- **At step 8:** If product name already exists
- System prevents creation
- Flow returns to step 4

**A2. Invalid Image Format:**
- **At step 6:** If image file is not JPG/PNG or > 5MB
- System displays: "File ảnh không hợp lệ. Chỉ chấp nhận JPG/PNG, tối đa 5MB."
- Flow returns to step 4

**A3. Missing Variants:**
- **At step 9:** If no variants provided
- System creates product with default variant (Price = 0)
- System displays warning: "Sản phẩm chưa có biến thể. Vui lòng cập nhật sau."

**A4. Invalid Price:**
- **At step 9:** If Price < 0 or DiscountPrice > Price
- System displays: "Giá sản phẩm không hợp lệ."
- Flow returns to step 4

**Outputs:**
- Product record created
- ProductCategories created
- ProductVariant records created
- ProductStock records created
- InventoryLog record created
- Image file saved (if uploaded)

**Postconditions:**
- Product exists in catalog
- Product is available for order creation
- Stock initialized
- Inventory log entry created

**Business Rules:**
- Product name must be unique (case-insensitive)
- Product must have at least one variant
- Stock amount cannot be negative
- Product status defaults to "Đang bán" (available for sale)
- Image upload is optional but recommended

---

#### 5.2 UC-21_Manage Stock Levels

**Use Case ID:** UC-21  
**Use Case Name:** Manage Stock Levels  
**Primary Actor:** Inventory Manager  
**Priority:** High  
**Complexity:** Low

**Description:**  
Inventory managers update stock quantities through IN/OUT transactions. Stock changes are logged in InventoryLogs for audit purposes. Low stock alerts are triggered automatically.

**Inputs:**
- ProductVariantID (GUID, required)
- Action Type (String, required: "IN" or "OUT")
- Quantity (Integer, required, > 0)
- Store Location (String, default: "Main Warehouse")
- Notes (String, optional)

**Preconditions:**
- User is authenticated as Inventory Manager or Admin
- ProductVariant exists
- Inventory exists for store location

**Main Flow:**

1. Inventory manager navigates to Product List
2. Inventory manager selects a product variant
3. System displays stock management form:
   - Current stock level (ProductStock.Amount)
   - Action type dropdown (IN/OUT)
   - Quantity input
   - Store location
   - Notes
4. Inventory manager fills form:
   - Selects action (Restock = IN, Sale/Adjustment = OUT)
   - Enters quantity
   - Optionally adds notes
5. Inventory manager submits form
6. System validates:
   - Quantity > 0
   - For OUT: Current stock >= quantity (prevent negative)
7. **If validation fails:** Display error, return to step 4
8. **If validation passes:**
    - System starts database transaction
    - System retrieves ProductStock:
      - Query by ProductVariantID and InventoryID
    - **If ProductStock not found:**
      - System creates new ProductStock record
      - Amount = 0 (initial)
    - System updates ProductStock.Amount:
      - **If Action = "IN":** Amount = Amount + Quantity
      - **If Action = "OUT":** Amount = Amount - Quantity (cannot go below 0)
    - System creates InventoryLog record:
      - ProductVariantID (FK)
      - ActionType (IN/OUT)
      - QuantityChanged (+Quantity for IN, -Quantity for OUT)
      - ActionDate = now
      - StoreLocation
    - System commits transaction
9. System checks low stock threshold:
    - System queries low stock configuration
    - **If ProductStock.Amount <= threshold:**
      - System triggers alert (AlertService.triggerAlert())
      - System sends notification to Inventory Manager
      - System creates AlertHistory record
10. System displays success: "Đã cập nhật tồn kho thành công."
11. System refreshes product list (updated stock displayed)
12. Use case ends with success

**Alternative Flows:**

**A1. Insufficient Stock (OUT transaction):**
- **At step 7:** If ProductStock.Amount < Quantity for OUT action
- System displays: "Số lượng tồn kho không đủ. Hiện có: [Amount]"
- Flow returns to step 4

**A2. ProductVariant Not Found:**
- **At step 8:** If ProductVariantID does not exist
- System displays: "Sản phẩm không tồn tại."
- Use case ends with failure

**A3. Negative Quantity:**
- **At step 6:** If Quantity <= 0
- System displays: "Số lượng phải lớn hơn 0."
- Flow returns to step 4

**Outputs:**
- ProductStock.Amount updated
- InventoryLog record created
- Low stock alert triggered (if applicable)
- Success confirmation message

**Postconditions:**
- Stock level updated in database
- Stock change logged for audit
- Low stock alert triggered (if below threshold)
- Product list reflects updated stock

**Business Rules:**
- Stock cannot go negative (enforced by validation)
- All stock changes must be logged (InventoryLog)
- Low stock threshold is configurable per product
- Stock updates are atomic (transaction)
- OUT transactions require sufficient stock

---

### 6. Employee & HR Feature

#### 6.1 UC-32_Clock In/Out

**Use Case ID:** UC-32  
**Use Case Name:** Clock In/Out  
**Primary Actor:** Employee  
**Priority:** High  
**Complexity:** Medium

**Description:**  
Employees record attendance by clocking in at shift start and clocking out at shift end. The system links attendance to scheduled shifts and calculates hours worked. Late/early flags are automatically set based on shift rules.

**Inputs:**
- Action Type (String, required: "IN" or "OUT")
- EmployeeID (GUID, optional, auto-filled from session)
- Timestamp (DateTime, optional, default: now)
- Notes (String, optional)

**Preconditions:**
- User is authenticated as Employee role
- Employee record exists (linked to User)
- Shift exists for current date (if required by business rule)

**Main Flow:**

**6.1 Clock In Flow:**

1. Employee logs in and navigates to Attendance page (`attendance.jsp`)
2. System displays current shift information:
   - Scheduled shift time (from EmployeeShift)
   - Current status (Not Clocked In / Clocked In)
   - Today's attendance summary
3. Employee clicks "Clock In" button
4. System validates:
   - Employee has not already clocked in today (no active attendance record)
   - Current time is within acceptable range (optional: within 2 hours of shift start)
5. **If validation fails:** Display error, flow returns to step 2
6. **If validation passes:**
    - System creates EmployeeAttendance record:
      - AttendanceID (GUID)
      - EmployeeID (FK)
      - CheckInTime = now
      - CheckOutTime = null
      - Date = today
      - IsLate = false (will be calculated)
      - IsEarlyLeave = false
      - Notes
    - System links attendance to EmployeeShift (if shift exists):
      - Query EmployeeShift by EmployeeID and date
      - Link Attendance to Shift
    - System calculates late flag:
      - Compare CheckInTime with Shift.StartTime
      - **If CheckInTime > Shift.StartTime + grace period (e.g., 15 min):**
        - Set IsLate = true
        - System logs late arrival
    - System updates EmployeeShiftTimesheet:
      - Create or update timesheet entry
      - Set CheckInTime
      - Status = "In Progress"
    - System commits transaction
7. System displays success: "Đã chấm công vào thành công."
8. System refreshes attendance page
9. Use case ends with success

**6.2 Clock Out Flow:**

1. Employee navigates to Attendance page (after clocking in)
2. System displays active attendance record:
   - CheckInTime
   - Current shift information
   - Time elapsed since check-in
3. Employee clicks "Clock Out" button
4. System validates:
   - Employee has clocked in today (active attendance exists)
   - Current time is after CheckInTime
5. **If validation fails:** Display error, flow returns to step 2
6. **If validation passes:**
    - System starts database transaction
    - System updates EmployeeAttendance:
      - CheckOutTime = now
      - Calculate hours worked = (CheckOutTime - CheckInTime)
    - System calculates early leave flag:
      - Compare CheckOutTime with Shift.EndTime
      - **If CheckOutTime < Shift.EndTime - grace period:**
        - Set IsEarlyLeave = true
        - System logs early leave
    - System updates EmployeeShiftTimesheet:
      - Set CheckOutTime
      - Calculate TotalHours = hours worked
      - Status = "Completed"
      - Calculate flags (Late, EarlyLeave, Overtime)
    - System commits transaction
7. System displays success: "Đã chấm công ra thành công. Tổng giờ làm: [Hours]"
8. System refreshes attendance page
9. Use case ends with success

**Alternative Flows:**

**A1. Already Clocked In:**
- **At step 4 (Clock In):** If employee already has active attendance today
- System displays: "Bạn đã chấm công vào hôm nay."
- System shows existing CheckInTime
- Employee can only clock out

**A2. Not Clocked In:**
- **At step 4 (Clock Out):** If employee has not clocked in
- System displays: "Vui lòng chấm công vào trước."
- System prevents clock out
- Flow returns to step 1

**A3. Forgot Clock In/Out:**
- Employee can submit ForgotClockRequest (UC-36)
- Requires HR approval to correct attendance

**A4. Late Arrival:**
- **At step 6 (Clock In):** If CheckInTime > Shift.StartTime + grace period
- System sets IsLate = true
- System displays warning: "Bạn đã đến muộn."
- Attendance still recorded
- Late flag logged for payroll

**A5. Early Leave:**
- **At step 6 (Clock Out):** If CheckOutTime < Shift.EndTime - grace period
- System sets IsEarlyLeave = true
- System displays warning: "Bạn đã về sớm."
- Attendance still recorded
- Early leave flag logged

**Outputs:**
- EmployeeAttendance record created/updated
- EmployeeShiftTimesheet updated
- Late/Early flags calculated
- Success confirmation message

**Postconditions:**
- Attendance recorded in database
- Timesheet calculated with hours worked
- Flags set for payroll processing
- Attendance history updated

**Business Rules:**
- Employee can only clock in once per day
- Employee must clock in before clocking out
- Late grace period: 15 minutes (configurable)
- Early leave grace period: 15 minutes (configurable)
- Hours worked calculated automatically
- Flags (Late, EarlyLeave) affect payroll calculation

---

### 7. Procurement Feature

#### 7.1 UC-40_Create Purchase Order

**Use Case ID:** UC-40  
**Use Case Name:** Create Purchase Order  
**Primary Actor:** Procurement Officer  
**Priority:** High  
**Complexity:** High

**Description:**  
Procurement officers create purchase orders (PO) to suppliers with items, quantities, prices, and expected delivery dates. POs go through approval workflow before being sent to suppliers.

**Inputs:**
- SupplierID (GUID, required)
- Expected Delivery Date (DateTime, required)
- Items (Array of):
  - ItemName (String, required)
  - Quantity (Integer, required, > 0)
  - UnitPrice (Decimal, required, > 0)
- Notes (String, optional)
- Approval Level (Integer, default: 1)

**Preconditions:**
- User is authenticated as Procurement Officer or Admin
- Supplier exists and is active
- All items have valid names and prices
- Expected delivery date is in the future

**Main Flow:**

1. Procurement officer navigates to Procurement Dashboard (`procurement/dashboard.jsp`)
2. Procurement officer clicks "Create PO" button
3. System displays PO creation form (`procurement/po.jsp`)
4. Procurement officer selects supplier:
   - System loads supplier list (SupplierDAO.getAll())
   - Procurement officer selects from dropdown
5. Procurement officer sets expected delivery date:
   - Date picker widget
   - System validates date >= today
6. Procurement officer adds items:
   - Clicks "Add Item" button
   - Enters ItemName, Quantity, UnitPrice
   - System calculates item total = Quantity × UnitPrice
   - Adds to items table
   - Can add multiple items
7. System calculates PO total:
   - TotalAmount = Sum(Quantity × UnitPrice) for all items
   - Displays total in form
8. Procurement officer adds notes (optional)
9. Procurement officer clicks "Submit" button
10. System validates:
    - SupplierID exists
    - At least one item provided
    - All items have Quantity > 0 and UnitPrice > 0
    - Expected delivery date >= today
11. **If validation fails:** Display errors, return to step 4
12. **If validation passes:**
     - System starts database transaction
     - System creates PurchaseOrder record:
       - POID (GUID)
       - SupplierID (FK)
       - CreatedBy = current user
       - CreateDate = now
       - ExpectedDelivery = selected date
       - TotalAmount = calculated total
       - Status = "PENDING"
       - ApprovalLevel = 1
       - Notes
     - System creates PurchaseOrderItems for each item:
       - ItemID (auto-increment)
       - POID (FK)
       - ItemName
       - Quantity
       - UnitPrice
       - Total = Quantity × UnitPrice (persisted)
     - System commits transaction
13. System displays success: "Đơn hàng [POID] đã được tạo thành công."
14. System redirects to PO list
15. PO status = "PENDING" (awaits approval)
16. Use case ends with success

**Alternative Flows:**

**A1. Supplier Not Found:**
- **At step 10:** If SupplierID does not exist
- System displays: "Nhà cung cấp không tồn tại."
- Flow returns to step 4

**A2. No Items:**
- **At step 10:** If items array is empty
- System displays: "Vui lòng thêm ít nhất một sản phẩm."
- Flow returns to step 6

**A3. Invalid Date:**
- **At step 10:** If expected delivery date < today
- System displays: "Ngày giao hàng không hợp lệ."
- Flow returns to step 5

**A4. Negative Quantity/Price:**
- **At step 10:** If any item has Quantity <= 0 or UnitPrice <= 0
- System displays: "Số lượng và giá phải lớn hơn 0."
- Flow returns to step 6

**Outputs:**
- PurchaseOrder record created
- PurchaseOrderItems created
- PO total calculated
- Success confirmation message

**Postconditions:**
- PO exists with Status = "PENDING"
- PO items recorded
- PO ready for approval workflow
- Supplier can be notified (manual step)

**Business Rules:**
- PO must have at least one item
- PO total = Sum of all item totals
- PO status workflow: PENDING → APPROVED → RECEIVING → COMPLETED
- PO requires approval before sending to supplier
- PO items cannot be modified after approval (new PO must be created)

---

#### 7.2 UC-43_Record Goods Receipt

**Use Case ID:** UC-43  
**Use Case Name:** Record Goods Receipt  
**Primary Actor:** Procurement Officer  
**Priority:** High  
**Complexity:** Medium

**Description:**  
Procurement officers record goods received from suppliers against purchase orders. Stock is automatically updated in inventory, and PO status is updated based on receipt completeness.

**Inputs:**
- POID (GUID, required)
- Received Items (Array of):
  - PurchaseOrderItemID (GUID, required)
  - Quantity Received (Integer, required, > 0)
- Receive Date (DateTime, default: now)
- Quality Check Notes (String, optional)
- Status (String: "PARTIAL" or "FULL")

**Preconditions:**
- User is authenticated as Procurement Officer or Admin
- Purchase Order exists and is APPROVED
- PO items exist
- Received quantities <= ordered quantities

**Main Flow:**

1. Procurement officer navigates to Goods Receipt page (`procurement/goods-receipt.jsp`)
2. Procurement officer selects PO:
   - System loads approved POs (Status = "APPROVED")
   - Procurement officer selects PO from dropdown
3. System loads PO items:
   - System queries PurchaseOrderItems by POID
   - System displays items with:
     - ItemName
     - Ordered Quantity
     - Previously Received Quantity (if partial receipt exists)
     - Remaining Quantity
4. Procurement officer enters received quantities:
   - For each item, enters Quantity Received
   - Can enter partial quantities (less than ordered)
   - System calculates remaining = Ordered - Received
5. Procurement officer adds quality check notes (optional)
6. System determines receipt status:
   - **If all items fully received:** Status = "FULL"
   - **If any item partially received:** Status = "PARTIAL"
7. Procurement officer clicks "Confirm Receipt" button
8. System validates:
   - PO exists and is APPROVED
   - Received quantities <= Ordered quantities
   - At least one item has Quantity Received > 0
9. **If validation fails:** Display errors, return to step 4
10. **If validation passes:**
     - System starts database transaction
     - System creates GoodsReceipt record:
       - ReceiptID (GUID)
       - POID (FK)
       - ReceivedBy = current user
       - ReceiveDate = now
       - Status (PARTIAL or FULL)
       - Notes = quality check notes
     - System creates GoodsReceiptItems for each received item:
       - ItemID (auto-increment)
       - ReceiptID (FK)
       - PurchaseOrderItemID (FK)
       - QuantityReceived
     - **System updates inventory (auto):**
       - For each received item:
         - Find or create ProductStock by ItemName (or ProductID if linked)
         - Update ProductStock.Amount = Amount + QuantityReceived
         - Create InventoryLog record:
           - ActionType = "IN"
           - QuantityChanged = +QuantityReceived
           - ActionDate = now
     - **System updates PO status:**
       - **If Status = "FULL":** PO.Status = "COMPLETED"
       - **If Status = "PARTIAL":** PO.Status = "RECEIVING"
     - System commits transaction
11. System triggers low stock alert check (if applicable)
12. System displays success: "Đã ghi nhận nhận hàng thành công."
13. System redirects to PO list
14. Use case ends with success

**Alternative Flows:**

**A1. PO Not Approved:**
- **At step 8:** If PO.Status ≠ "APPROVED"
- System displays: "Đơn hàng chưa được duyệt. Vui lòng duyệt trước khi nhận hàng."
- Use case ends with failure

**A2. Over-Receipt:**
- **At step 8:** If QuantityReceived > Ordered Quantity
- System displays: "Số lượng nhận không được vượt quá số lượng đặt."
- Flow returns to step 4

**A3. PO Not Found:**
- **At step 8:** If POID does not exist
- System displays: "Không tìm thấy đơn hàng."
- Use case ends with failure

**A4. No Items Received:**
- **At step 8:** If all QuantityReceived = 0
- System displays: "Vui lòng nhập số lượng nhận hàng."
- Flow returns to step 4

**Outputs:**
- GoodsReceipt record created
- GoodsReceiptItems created
- ProductStock updated (inventory increased)
- InventoryLog records created
- PO status updated
- Success confirmation message

**Postconditions:**
- Goods receipt recorded
- Inventory stock increased
- PO status updated (COMPLETED or RECEIVING)
- Inventory log entries created for audit
- Low stock alerts checked

**Business Rules:**
- GR can only be created for APPROVED POs
- Received quantity cannot exceed ordered quantity
- Partial receipts allowed (Status = "PARTIAL")
- Full receipt updates PO to COMPLETED
- Inventory updated automatically on GR confirmation
- Multiple GRs can be created for same PO (for partial receipts)

---

**Document Status:** Section II (Requirement Specifications) - Completed (8 Key Use Cases documented)  
**Next Update:** TODO 4 - Design Specifications  
**Prepared By:** LiteFlow Development Team - FPT University SWP391 Fall 2025

