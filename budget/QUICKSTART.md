# Budget Tracking System - Quick Start Guide

## Overview
A complete personal finance management system with database, backend API, and responsive web interface.

## Complete File Structure

```
📦 budget/
├── 📄 app.py                          # Flask backend (ALL API routes & logic)
├── 📄 budget_tracking_system.sql      # Complete database schema
├── 📄 requirements.txt                # Python dependencies
├── 📄 README.md                       # Full documentation
├── 📄 install.bat                     # Windows installer
├── 📄 install.sh                      # macOS/Linux installer
├── 📄 QUICKSTART.md                   # This file
│
├── 📁 templates/                      # HTML Templates
│   ├── base.html                      # Navigation & base layout
│   ├── login.html                     # Login interface
│   ├── register.html                  # Registration interface
│   ├── dashboard.html                 # Main dashboard with charts
│   ├── transactions.html              # Transaction management
│   ├── budgets.html                   # Budget management
│   ├── reports.html                   # Financial reports
│   └── 404.html                       # Error page
│
└── 📁 static/                         # Static Assets
    ├── 📁 css/
    │   └── style.css                  # Complete responsive styling
    └── 📁 js/
        └── main.js                    # JavaScript utilities
```

## Getting Started (5 Minutes)

### Step 1: Install Python Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Setup Database
```sql
-- Run in MySQL
CREATE DATABASE budget_tracker;
```

Then import `budget_tracking_system.sql` into the database.

### Step 3: Configure Database Connection
Edit `app.py` line 13-17:
```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'          # Your MySQL username
app.config['MYSQL_PASSWORD'] = 'password'  # Your MySQL password
app.config['MYSQL_DB'] = 'budget_tracker'
```

### Step 4: Run Application
```bash
python app.py
```

Open browser: `http://localhost:5000`

## What's Included

### Frontend Features ✨
- **Responsive Design** - Desktop and mobile optimized
- **Interactive Dashboard** - Real-time financial overview
- **Transaction Management** - Add, edit, delete transactions
- **Budget Tracking** - Monitor spending against limits
- **Financial Reports** - Charts and historical analysis
- **Authentication** - Secure login and registration

### Backend Features 🔧
- **Flask REST API** - 12+ endpoints
- **Security** - Password hashing, session management
- **Database Integration** - Full MySQL connectivity
- **Data Processing** - Complex financial calculations
- **Error Handling** - Comprehensive error management

### Database Features 💾
- **5 Core Tables** - Users, Categories, Transactions, Budgets, Summary
- **Complex Procedures** - Monthly spending analysis
- **Functions** - Income/expense calculations
- **Triggers** - Auto-update summaries
- **Views** - Pre-built queries for reports

## Key Sections

### 1. Dashboard (`/dashboard`)
- Monthly income & expenses overview
- Real-time balance calculation
- Recent transactions list
- Budget status indicators
- Interactive charts

### 2. Transactions (`/transactions`)
- Add new income/expense transactions
- Categorize all transactions
- Search and filter capabilities
- Transaction history view
- Detailed transaction management

### 3. Budgets (`/budgets`)
- Create monthly budgets
- Track spending against limits
- Visual progress indicators
- Budget status alerts
- Easy budget management

### 4. Reports (`/reports`)
- Monthly trend analysis
- Category-wise breakdown
- Visual charts and graphs
- Summary statistics
- Financial insights

## API Endpoints

### Authentication
```
POST   /register              - Create new account
POST   /login                 - Login with email/password
GET    /logout                - Logout user
```

### Data Management
```
GET    /api/categories        - Fetch all expense categories
GET    /api/transactions      - Get user transactions
POST   /api/transactions      - Add new transaction
DELETE /api/transactions/<id> - Remove transaction

GET    /api/budgets           - Get user budgets
POST   /api/budgets           - Create new budget
DELETE /api/budgets/<id>      - Delete budget
```

### Reports & Analytics
```
GET    /api/dashboard-data    - Dashboard overview
GET    /api/monthly-summary   - Monthly statistics
GET    /api/category-analysis - Category breakdown
```

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Backend | Flask (Python) |
| Frontend | HTML5, CSS3, JavaScript |
| Database | MySQL 5.7+ |
| Charts | Chart.js |
| Icons | Font Awesome 6 |
| Security | Werkzeug (password hashing) |

## Database Schema

### Tables Overview
| Table | Purpose |
|-------|---------|
| Users | User accounts & authentication |
| Categories | Transaction categories (Income/Expense) |
| Transactions | All financial transactions |
| Budgets | Monthly budget limits |
| Monthly_Summary | Auto-calculated summaries |

### Key Features
- ✅ Foreign key relationships
- ✅ Data validation constraints
- ✅ Auto-increment IDs
- ✅ Timestamp tracking
- ✅ Calculated fields via triggers

## Security Features

✅ **Password Hashing** - Werkzeug.security  
✅ **Session Management** - Flask sessions  
✅ **User Authentication** - Login required decorator  
✅ **Data Validation** - Input sanitization  
✅ **Error Handling** - Try-catch blocks  
✅ **CSRF Protection** - Ready for enhancement  

## Customization Guide

### Change Color Scheme
Edit `static/css/style.css` - CSS variables at line 4:
```css
:root {
    --primary-color: #3498db;      /* Change this */
    --success-color: #27ae60;      /* Change this */
    --danger-color: #e74c3c;       /* Change this */
}
```

### Add New Categories
Add to `budget_tracking_system.sql` INSERT statement:
```sql
INSERT INTO Categories (name, type) 
VALUES ('New Category', 'Income');  -- or 'Expense'
```

### Modify Exchange Rate
Edit `app.py` to add conversion logic before storing amounts

### Add New Reports
Create new route in `app.py` and new template in `templates/`

## Troubleshooting

| Problem | Solution |
|---------|----------|
| MySQL not connecting | Check server is running, verify credentials |
| Port 5000 in use | Change `app.run(port=5001)` in app.py |
| Missing CSS/JS | Verify static folder exists with correct path |
| Database schema errors | Re-import SQL file after dropping database |
| Login fails | Check password hashing in Werkzeug |

## Testing the Application

1. **Register Account**
   - Go to `/register`
   - Create test account with email

2. **Add Sample Data**
   - Create categories
   - Add income transaction
   - Add expense transactions

3. **Create Budget**
   - Set monthly budget for expense category
   - View budget status on dashboard

4. **View Reports**
   - Check charts update
   - Analyze spending patterns

## Performance Tips

- ✅ Add database indexes for frequent queries
- ✅ Use caching for category lists
- ✅ Optimize chart queries with limits
- ✅ Enable gzip compression
- ✅ Minify CSS and JavaScript

## File Permissions (Linux/Mac)
```bash
chmod +x install.sh          # Make installer executable
chmod 755 app.py             # Make app executable
chmod 644 budget_tracking_system.sql
```

## Support & Resources

- **Flask Documentation**: https://flask.palletsprojects.com/
- **MySQL Documentation**: https://dev.mysql.com/doc/
- **Chart.js Documentation**: https://www.chartjs.org/
- **Bootstrap Classes Used**: Native CSS (no framework)

## Next Steps

1. ✅ Complete installation
2. ✅ Add sample transactions
3. ✅ Create budgets
4. ✅ Review reports
5. 🔄 Customize to your needs
6. 🚀 Deploy to production

---

**Version**: 1.0  
**Created**: 2026  
**Status**: Production Ready
