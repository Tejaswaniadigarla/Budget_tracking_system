# Budget Tracking System - Setup Guide

## Project Structure

```
budget/
├── app.py                      # Flask backend application
├── budget_tracking_system.sql  # Database schema and SQL scripts
├── requirements.txt            # Python dependencies
├── templates/                  # HTML templates
│   ├── base.html              # Base template with navigation
│   ├── login.html             # Login page
│   ├── register.html          # Registration page
│   ├── dashboard.html         # Main dashboard
│   ├── transactions.html      # Transactions management
│   ├── budgets.html           # Budget management
│   ├── reports.html           # Financial reports
│   └── 404.html               # Error page
└── static/                     # Static files
    ├── css/
    │   └── style.css          # Main stylesheet
    └── js/
        └── main.js            # JavaScript utilities
```

## Installation & Setup

### Prerequisites
- Python 3.7+
- MySQL Server
- pip (Python package manager)

### Step 1: Install Python Dependencies

```bash
pip install -r requirements.txt
```

### Step 2: Setup MySQL Database

1. **Open MySQL Command Line or MySQL Workbench**

2. **Create the database:**
   ```sql
   CREATE DATABASE budget_tracker;
   USE budget_tracker;
   ```

3. **Run the SQL schema file:**
   - Import the `budget_tracking_system.sql` file into your MySQL database
   - Or copy and paste the entire SQL script into MySQL command line

### Step 3: Configure Flask App

Edit `app.py` and update MySQL credentials:

```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'        # Your MySQL username
app.config['MYSQL_PASSWORD'] = ''         # Your MySQL password
app.config['MYSQL_DB'] = 'budget_tracker'
```

### Step 4: Run the Application

```bash
python app.py
```

The application will start on `http://localhost:5000`

## Features

### Authentication
- User registration with email validation
- Secure login with password hashing
- Session management

### Dashboard
- Monthly income and expense summary
- Recent transactions view
- Budget status overview
- Income vs Expenses chart
- Category distribution chart

### Transactions
- Add/edit/delete transactions
- Categorize transactions as Income or Expense
- Filter by category or search
- View transaction history

### Budgets
- Create monthly budgets for expense categories
- Track spending against budget limits
- Visual progress indicators
- Budget status alerts (On Track / Warning / Over Budget)

### Reports
- Monthly income and expense trends
- Category-wise expense breakdown
- Financial summary table
- Savings rate analysis

## Database Schema

### Tables
1. **Users** - User account information
2. **Categories** - Transaction categories (Income/Expense)
3. **Transactions** - Income and expense records
4. **Budgets** - Monthly budget goals
5. **Monthly_Summary** - Auto-updated summary data

### SQL Features
- **Procedures**: Calculate spending, get budget overview
- **Functions**: Check budget exceeded, calculate monthly income/expenses
- **Triggers**: Auto-update summary on transaction insert/update
- **Views**: Monthly summary, budget vs actual, category analysis

## API Endpoints

### Authentication
- `POST /register` - Register new user
- `POST /login` - Login user
- `GET /logout` - Logout user

### Dashboard
- `GET /dashboard` - Dashboard page
- `GET /api/dashboard-data` - Dashboard data (JSON)

### Transactions
- `GET /api/categories` - Get all categories
- `GET /api/transactions` - Get user transactions
- `POST /api/transactions` - Add new transaction
- `DELETE /api/transactions/<id>` - Delete transaction

### Budgets
- `GET /api/budgets` - Get user budgets
- `POST /api/budgets` - Create new budget
- `DELETE /api/budgets/<id>` - Delete budget

### Reports
- `GET /api/monthly-summary` - Monthly summary data
- `GET /api/category-analysis` - Category breakdown

## Troubleshooting

### MySQL Connection Error
- Ensure MySQL server is running
- Check credentials in `app.py`
- Verify database `budget_tracker` exists

### Module Import Errors
- Reinstall dependencies: `pip install --upgrade -r requirements.txt`
- Try using a virtual environment

### Port Already in Use
- Change port in `app.py`: `app.run(port=5001)`

## Future Enhancements
- Export reports to PDF
- Email notifications for budget alerts
- Multi-currency support
- Mobile app
- Advanced analytics
- Receipt image upload
- Recurring transactions

## Security Notes
- Change `app.secret_key` for production
- Use environment variables for sensitive data
- Enable HTTPS in production
- Implement rate limiting
- Add CSRF protection
- Regular security audits

## Support
For issues or questions, check the code comments or refer to Flask and MySQL documentation.
