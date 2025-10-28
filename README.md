# 🚀 LiteFlow - Enterprise Resource Planning System

**A comprehensive ERP solution for restaurant and hospitality management with advanced POS, inventory control, and workforce management capabilities.**

---

## 📘 Overview

**LiteFlow** is a full-featured Enterprise Resource Planning (ERP) system specifically designed for the restaurant and hospitality industry. Built with modern Java technologies and enterprise-grade security, LiteFlow streamlines operations across multiple business domains including point-of-sale transactions, kitchen operations, inventory tracking, employee scheduling, and procurement management.

The system addresses critical pain points in restaurant management by providing:
- **Real-time order processing** with kitchen integration
- **Intelligent inventory tracking** with automated stock alerts
- **Workforce management** with attendance and scheduling
- **Secure multi-role access control** with 2FA authentication
- **Procurement automation** with supplier and invoice management

**Key Concept:** Unified platform that integrates front-of-house operations (POS, table management) with back-office functions (inventory, procurement, HR) to optimize efficiency and reduce operational costs.

---

## ⚙️ Tech Stack

### Backend
- **Language:** Java 11/16
- **Framework:** Jakarta EE 11 (Servlets, JSP, JSTL)
- **ORM:** Hibernate 6.4.4 + JPA
- **Build Tool:** Maven 3.6+
- **Application Server:** Apache Tomcat 10+

### Database & Caching
- **Primary Database:** Microsoft SQL Server
- **JDBC Driver:** MS SQL Server JDBC 12.6.1
- **Caching Layer:** Redis (Jedis 5.1.0)

### Security & Authentication
- **Password Hashing:** BCrypt (jBCrypt 0.4)
- **JWT Authentication:** JJWT 0.11.5
- **Two-Factor Authentication:** TOTP (java-otp 0.4.0)
- **OAuth2:** Google Sign-In Integration

### Additional Libraries
- **Excel Processing:** Apache POI 5.2.5
- **Email Service:** Jakarta Mail 2.0.1
- **JSON Processing:** Jackson Databind 2.17.2

### Testing & Quality Assurance
- **Testing Framework:** JUnit 5.10.0
- **Mocking:** Mockito 5.5.0
- **Assertions:** AssertJ 3.24.2
- **Code Coverage:** JaCoCo 0.8.10

---

## 🧠 Key Features

### 🔐 Authentication & User Management
- Multi-role access control (Admin, Manager, Cashier, Kitchen Staff, Employee)
- Secure login with BCrypt password hashing
- Two-Factor Authentication (2FA) with TOTP
- Google OAuth2 integration
- Password recovery via email OTP
- Session management with JWT tokens

### 💰 Point of Sale (POS) System
- Real-time table/room management with status tracking
- Interactive menu browsing and order creation
- Split bill and payment processing
- Order history and session tracking
- Kitchen notification integration

### 🍳 Kitchen Management
- Real-time order queue display
- Order status workflow (Pending → Preparing → Ready → Served)
- Multi-station order distribution
- Priority order handling

### 📦 Inventory Management
- Product catalog with variants (size, options)
- Stock level tracking with low-stock alerts
- Room/table-based inventory organization
- Dynamic pricing management
- Excel import/export functionality

### 👥 Employee & HR Management
- Employee profile management
- Attendance tracking system
- Schedule management and shift planning
- Payroll calculation (paysheet generation)
- Role-based access assignment

### 🛒 Procurement System
- Supplier database management
- Purchase Order (PO) creation and tracking
- Goods receipt recording
- Invoice matching and verification
- Procurement dashboard with analytics

### 📊 Dashboard & Analytics
- Real-time business metrics
- Sales performance tracking
- Inventory status overview
- Employee performance monitoring

---

## 🧩 Project Structure

```
LiteFlow-master/
├── src/
│   ├── main/
│   │   ├── java/com/liteflow/
│   │   │   ├── controller/          # Servlets (CashierServlet, CreateOrderServlet, etc.)
│   │   │   ├── dao/                 # Data Access Objects
│   │   │   ├── model/               # Entity models (User, Order, Product, etc.)
│   │   │   ├── service/             # Business logic layer
│   │   │   ├── filter/              # Authentication & authorization filters
│   │   │   ├── util/                # Helper utilities (PasswordUtil, JWTUtil, etc.)
│   │   │   └── config/              # Configuration classes
│   │   ├── resources/
│   │   │   └── META-INF/
│   │   │       └── persistence.xml  # JPA configuration
│   │   └── webapp/
│   │       ├── auth/                # Login, signup, OTP pages
│   │       ├── cart/                # Cashier/POS interface
│   │       ├── employee/            # Employee management pages
│   │       ├── inventory/           # Inventory management
│   │       ├── kitchen/             # Kitchen display system
│   │       ├── procurement/         # Procurement module
│   │       ├── css/                 # Stylesheets
│   │       ├── js/                  # JavaScript files
│   │       ├── includes/            # Header, footer components
│   │       └── WEB-INF/
│   │           └── web.xml          # Servlet configuration
│   └── test/
│       └── java/com/liteflow/       # Unit & integration tests
├── database/
│   ├── liteflow_schema.sql          # Database schema
│   ├── liteflow_data.sql            # Sample data
│   ├── PROCUREMENT_SAMPLE_DATA.sql  # Procurement test data
│   └── Pro_ipdate.sql               # Procurement updates
├── target/
│   ├── LiteFlow.war                 # Deployable WAR file
│   └── site/jacoco/                 # Code coverage reports
├── prompts/                         # AI-assisted development logs
├── pom.xml                          # Maven configuration
└── README.md                        # This file
```

---

## 🚀 How to Run

### Prerequisites
Before running LiteFlow, ensure you have the following installed:
- **Java Development Kit (JDK) 11 or higher**
- **Apache Maven 3.6+**
- **Microsoft SQL Server** (2019 or later recommended)
- **Apache Tomcat 10+** (or compatible Jakarta EE server)
- **Redis Server** (optional, for caching)
- **Git** (for cloning the repository)

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-username/LiteFlow.git
cd LiteFlow-master
```

---

### Step 2: Set Up the Database

#### 2.1 Create Database
1. Open **SQL Server Management Studio (SSMS)** or your preferred SQL client
2. Execute the schema creation script:
```sql
-- Run this file to create database structure
source database/liteflow_schema.sql
```

#### 2.2 Load Sample Data
```sql
-- Load initial data (users, roles, products, etc.)
source database/liteflow_data.sql

-- [Optional] Load procurement test data
source database/PROCUREMENT_SAMPLE_DATA.sql
```

#### 2.3 Update Database Connection
Edit the file: `src/main/resources/META-INF/persistence.xml`

```xml
<property name="jakarta.persistence.jdbc.url" 
          value="jdbc:sqlserver://localhost:1433;databaseName=LiteFlowDBO;encrypt=false"/>
<property name="jakarta.persistence.jdbc.user" value="YOUR_USERNAME"/>
<property name="jakarta.persistence.jdbc.password" value="YOUR_PASSWORD"/>
```

**Note:** Replace `YOUR_USERNAME` and `YOUR_PASSWORD` with your SQL Server credentials.

---

### Step 3: Configure Redis (Optional)
If using Redis for caching:
1. Install and start Redis server on default port `6379`
2. No additional configuration needed (Jedis client auto-connects to localhost:6379)

---

### Step 4: Build the Project
```bash
# Clean and compile the project
mvn clean install

# Skip tests during build (optional)
mvn clean install -DskipTests
```

**Expected output:**
```
[INFO] BUILD SUCCESS
[INFO] Total time: 45.123 s
```

The WAR file will be generated at: `target/LiteFlow.war`

---

### Step 5: Deploy to Tomcat

#### Option A: Manual Deployment
1. Copy `target/LiteFlow.war` to Tomcat's `webapps/` directory
2. Start Tomcat:
```bash
# Windows
catalina.bat start

# Linux/Mac
./catalina.sh start
```

#### Option B: Maven Tomcat Plugin (Development)
Add this to your `pom.xml` (if not already present):
```xml
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <url>http://localhost:8080/manager/text</url>
        <server>TomcatServer</server>
        <path>/LiteFlow</path>
    </configuration>
</plugin>
```

Then deploy:
```bash
mvn tomcat7:deploy
```

---

### Step 6: Access the Application

Once Tomcat is running, open your browser and navigate to:

```
http://localhost:8080/LiteFlow
```

#### Default Login Credentials
After loading sample data, use these accounts to test different roles:

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@liteflow.com | 1 |
| **Manager** | manager@liteflow.com | Manager123! |
| **Cashier** | cashier@liteflow.com | Cashier123! |
| **Kitchen** | kitchen@liteflow.com | Kitchen123! |

**⚠️ Security Warning:** Change default passwords immediately in production environments!

---

### Step 7: Run Tests (Optional)
```bash
# Run all unit tests
mvn test

# Generate code coverage report
mvn jacoco:report

# View coverage report
open target/site/jacoco/index.html
```

**Expected Coverage:**
- Line Coverage: ≥85%
- Branch Coverage: ≥80%
- Method Coverage: ≥90%

---

### Troubleshooting

#### Issue: Database Connection Failed
**Solution:** Verify SQL Server is running and credentials in `persistence.xml` are correct.

#### Issue: Port 8080 Already in Use
**Solution:** Change Tomcat port in `conf/server.xml` or kill the process using port 8080.

#### Issue: 404 Error After Deployment
**Solution:** Ensure WAR file is properly extracted in `webapps/LiteFlow/` directory.

#### Issue: JWT Token Errors
**Solution:** Check that JWT secret key is properly configured in environment variables or config files.

---

## 🧑‍💻 Contributors

**Development Team - FPT University SWP391 Project (Fall 2025)**

| Member | Student ID | Role | Responsibilities |
|--------|------------|------|------------------|
| **[Your Name]** | SE123456 | Project Lead & Backend Developer | System architecture, authentication, core servlets |
| **[Member 2]** | SE123457 | Frontend Developer | UI/UX design, JSP pages, CSS styling |
| **[Member 3]** | SE123458 | Database Administrator | Database design, SQL optimization, data migration |
| **[Member 4]** | SE123459 | QA Engineer | Testing strategy, unit tests, coverage reports |
| **[Member 5]** | SE123460 | DevOps & Integration | Deployment, CI/CD, documentation |

> **Note:** This is a university project developed as part of the Software Project (SWP391) course at FPT University.

---

## 📞 Contact & Support

- **Project Repository:** [GitHub - LiteFlow](https://github.com/your-username/LiteFlow)
- **Issues & Bug Reports:** [GitHub Issues](https://github.com/your-username/LiteFlow/issues)
- **Documentation:** [Wiki](https://github.com/your-username/LiteFlow/wiki)
- **Email:** liteflow.team@fpt.edu.vn

---

## 🧾 License

**Educational Use Only**

This project is developed by students at **FPT University** as part of the **SWP391 - Software Project** course. All rights are owned by the development team.

### Terms of Use
- ✅ Free to use for **educational and learning purposes**
- ✅ Can be modified and extended for **academic projects**
- ❌ **Not licensed for commercial use** without permission
- ❌ **Not for redistribution** as a standalone product

For commercial licensing inquiries, please contact the development team.

---

## 🙏 Acknowledgments

- **FPT University** - For providing the learning environment and resources
- **Instructor Team** - For guidance and support throughout the project
- **Open Source Community** - For the amazing libraries and tools used in this project
- **Stack Overflow & GitHub** - For countless solutions and inspirations

---

## 📚 Additional Documentation

- 📖 [API Documentation](docs/API.md)
- 🧪 [Testing Guide](prompts/CASHIER_TESTING_README.md)
- 🗄️ [Database Schema](database/liteflow_schema.sql)
- 📝 [Development Logs](prompts/log.md)
- 🎨 [UI/UX Guidelines](docs/UI_GUIDELINES.md)

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | October 2025 | Initial release with core ERP modules |
| **0.9.0** | September 2025 | Beta release with procurement module |
| **0.8.0** | August 2025 | Alpha release with POS and inventory |

---

## 🌟 Features Roadmap

### ✅ Completed
- User authentication with 2FA
- POS system with table management
- Kitchen display system
- Basic inventory management
- Employee management
- Procurement module

### 🚧 In Progress
- Advanced analytics dashboard
- Mobile responsive design
- REST API for mobile app integration

### 📋 Planned
- Multi-language support (English, Vietnamese)
- Cloud deployment (AWS/Azure)
- Mobile application (iOS/Android)
- Advanced reporting with PDF export
- Integration with payment gateways
- Customer loyalty program

---

<div align="center">

**Made with ❤️ by the LiteFlow Team**

⭐ Star this repository if you find it helpful!

[Report Bug](https://github.com/your-username/LiteFlow/issues) · [Request Feature](https://github.com/your-username/LiteFlow/issues) · [Documentation](https://github.com/your-username/LiteFlow/wiki)

---

*© 2025 LiteFlow Development Team - FPT University*

</div>

