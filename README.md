💰 Budget Tracking System

A full-stack Budget Tracking System built using Flask (Python), MySQL, HTML, CSS, and JavaScript to help users manage income, expenses, and budgets efficiently.

📌 Project Overview

This application allows users to:

Track income and expenses
Categorize financial transactions
Set monthly budgets
Analyze spending patterns through reports and dashboards
🗂️ Project Structure
budget/
├── app.py                      # Flask backend application
├── budget_tracking_system.sql  # Database schema and SQL scripts
├── requirements.txt            # Python dependencies
├── templates/                  # HTML templates
│   ├── base.html
│   ├── login.html
│   ├── register.html
│   ├── dashboard.html
│   ├── transactions.html
│   ├── budgets.html
│   ├── reports.html
│   └── 404.html
└── static/
    ├── css/
    │   └── style.css
    └── js/
        └── main.js
⚙️ Installation & Setup
🔹 Prerequisites
Python 3.7+
MySQL Server
pip
🔹 Step 1: Install Dependencies
pip install -r requirements.txt
🔹 Step 2: Setup MySQL Database
CREATE DATABASE budget_tracker;
USE budget_tracker;
Import budget_tracking_system.sql into MySQL
Or paste SQL script manually
🔹 Step 3: Configure Flask App

Update MySQL credentials in app.py:

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'your_password'
app.config['MYSQL_DB'] = 'budget_tracker'
🔹 Step 4: Run Application
python app.py

🌐 Open in browser:
👉 http://localhost:5000

🚀 Features
🔐 Authentication
User registration & login
Password hashing
Session management
📊 Dashboard
Monthly income vs expenses
Recent transactions
Budget overview
Charts and analytics
💸 Transactions
Add / Edit / Delete transactions
Categorize (Income / Expense)
Search and filter options
📅 Budgets
Set monthly category budgets
Track spending vs limits
Budget alerts (On Track / Warning / Over Budget)
📈 Reports
Monthly financial trends
Category-wise analysis
Savings insights
🗄️ Database Schema
Tables
Users – User details
Categories – Income/Expense categories
Transactions – Financial records
Budgets – Monthly limits
Monthly_Summary – Auto-calculated data
🧠 SQL Features
🔹 Procedures
Monthly spending calculation
Budget overview generation
🔹 Functions
Check budget exceeded
Calculate income/expenses
🔹 Triggers
Auto-update summary table
🔹 Views
Monthly summary
Budget vs actual
Category analysis
🔌 API Endpoints
Authentication
POST /register
POST /login
GET /logout
Dashboard
GET /dashboard
GET /api/dashboard-data
Transactions
GET /api/categories
GET /api/transactions
POST /api/transactions
DELETE /api/transactions/<id>
Budgets
GET /api/budgets
POST /api/budgets
DELETE /api/budgets/<id>
Reports
GET /api/monthly-summary
GET /api/category-analysis
⚠️ Troubleshooting
🔹 MySQL Connection Error
Ensure MySQL server is running
Verify credentials in app.py
Check database exists
🔹 Module Errors
pip install --upgrade -r requirements.txt
🔹 Port Already in Use
app.run(port=5001)
🔮 Future Enhancements
PDF report export
Email notifications
Multi-currency support
Mobile application
Advanced analytics
Receipt upload
Recurring transactions
🔒 Security Notes
Change secret_key in production
Use environment variables
Enable HTTPS
Add CSRF protection
Implement rate limiting

👩‍💻 Author
TEJASWANI ADIGARLA

⭐ Contributing

Feel free to fork this repository and submit pull requests!
