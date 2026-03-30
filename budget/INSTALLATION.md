# Budget Tracking System - Complete Installation Guide

## 📋 Pre-requisites

Before starting, ensure you have:
- **Python 3.7 or higher** - Download from https://www.python.org/
- **MySQL Server 5.7 or higher** - Download from https://www.mysql.com/downloads/
- **Git** (Optional) - For version control
- **A text editor or IDE** - VS Code, PyCharm, etc.

## 🔧 Installation Steps

### Step 1: Verify Python Installation
Open Command Prompt/Terminal and run:
```bash
python --version
# or
python3 --version
```
Should output: `Python 3.x.x`

### Step 2: Verify MySQL Installation
```bash
mysql --version
```
Should output: `mysql Ver x.x.x`

### Step 3: Start MySQL Service

**Windows:**
- MySQL should auto-start, or use Services app to start it

**macOS:**
```bash
mysql.server start
```

**Linux:**
```bash
sudo systemctl start mysql
```

### Step 4: Create Database

Open MySQL Command Line:
```bash
mysql -u root -p
# Enter your MySQL password
```

Then run these commands:
```sql
CREATE DATABASE budget_tracker;
USE budget_tracker;
SOURCE /path/to/budget_tracking_system.sql;
SHOW TABLES;
```

You should see 5 tables created:
- Categories
- Users
- Transactions
- Budgets
- Monthly_Summary

### Step 5: Install Python Dependencies

Navigate to the budget project directory:
```bash
cd d:\budget
```

Install required packages:
```bash
pip install Flask==2.3.0
pip install Flask-MySQLdb==1.0.1
pip install MySQLdb==1.2.5
pip install Werkzeug==2.3.0
```

Or install all at once:
```bash
pip install -r requirements.txt
```

### Step 6: Configure Database Connection

Edit `app.py` with your text editor. Find lines 13-17:

```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''          # Add your MySQL password here
app.config['MYSQL_DB'] = 'budget_tracker'
```

Update the `MYSQL_PASSWORD` with your MySQL root password.

### Step 7: Test MySQL Connection

Create a test file `test_connection.py`:

```python
import MySQLdb

try:
    connection = MySQLdb.connect(
        host='localhost',
        user='root',
        passwd='your_password',     # Your MySQL password
        db='budget_tracker'
    )
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM Users")
    print("✅ Connection successful!")
    print(f"Found {cursor.rowcount} users")
    connection.close()
except Exception as e:
    print(f"❌ Connection failed: {e}")
```

Run it:
```bash
python test_connection.py
```

## 🚀 Running the Application

### Start the Flask Server

```bash
python app.py
```

You should see:
```
 * Running on http://127.0.0.1:5000
 * Debug mode: on
```

### Access the Application

Open your web browser and go to:
```
http://localhost:5000
```

### First-Time Setup

1. **Register a new account**
   - Click "Register here" on the login page
   - Enter your details
   - Submit the form

2. **Login**
   - Use your registered email and password
   - You're logged in! 🎉

3. **Create categories** (If needed)
   - Categories are pre-populated from SQL file
   - View them in the Transactions page

4. **Add test transactions**
   - Go to Transactions → Add Transaction
   - Add income: $5000 - Salary
   - Add expense: $100 - Groceries

5. **Create a budget**
   - Go to Budgets → Create Budget
   - Set monthly limit for a category
   - View on Dashboard

## ✅ Verification Checklist

- [ ] Python installed and accessible
- [ ] MySQL server running
- [ ] Database created
- [ ] SQL schema imported
- [ ] Flask dependencies installed
- [ ] MySQL credentials updated in app.py
- [ ] Flask server starts without errors
- [ ] Can access http://localhost:5000
- [ ] Can register new account
- [ ] Can login with credentials
- [ ] Dashboard displays correctly
- [ ] Can add transactions
- [ ] Can create budgets
- [ ] Charts render properly

## 🐛 Common Issues & Solutions

### Issue: "ModuleNotFoundError: No module named 'flask'"
**Solution:**
```bash
pip install Flask
```

### Issue: "Can't connect to MySQL server"
**Solution:**
1. Check MySQL is running:
   ```bash
   mysql -u root -p
   ```
2. Verify credentials in app.py
3. Check database exists:
   ```sql
   SHOW DATABASES;
   ```

### Issue: "Port 5000 already in use"
**Solution:**
Change port in app.py (line 278):
```python
app.run(debug=True, host='127.0.0.1', port=5001)
```

### Issue: "Static files or CSS not loading"
**Solution:**
Verify folder structure:
```
budget/
├── static/
│   ├── css/style.css
│   ├── js/main.js
├── templates/
│   ├── base.html
│   ├── login.html
│   ...
```

### Issue: "Login always fails"
**Solution:**
1. Check user exists in database:
   ```sql
   SELECT * FROM Users;
   ```
2. Clear browser cookies and try again
3. Check password hashing:
   ```python
   from werkzeug.security import check_password_hash
   check_password_hash('hashed_pwd', 'plain_password')
   ```

### Issue: "Charts not appearing"
**Solution:**
1. Check Chart.js is loaded (network tab in DevTools)
2. Check browser console for JavaScript errors
3. Ensure data is fetched properly

## 📊 Database Maintenance

### Backup Database
```bash
mysqldump -u root -p budget_tracker > budget_backup.sql
```

### Restore Database
```bash
mysql -u root -p budget_tracker < budget_backup.sql
```

### View Tables
```sql
USE budget_tracker;
SHOW TABLES;
DESC Users;
DESC Transactions;
```

### Check Data
```sql
SELECT * FROM Users;
SELECT * FROM Categories;
SELECT * FROM Transactions LIMIT 5;
```

## 🔐 Production Deployment

Before deploying to production:

1. **Change Secret Key**
   ```python
   app.secret_key = 'generate_a_new_secure_key_here'
   ```

2. **Disable Debug Mode**
   ```python
   app.run(debug=False)
   ```

3. **Use Environment Variables**
   ```python
   import os
   app.config['MYSQL_PASSWORD'] = os.getenv('DB_PASSWORD')
   ```

4. **Enable HTTPS**
   - Use SSL certificates
   - Redirect HTTP to HTTPS

5. **Database Security**
   - Create dedicated MySQL user
   - Grant specific permissions only
   - Regular backups

## 📱 Browser Compatibility

The application works on:
- ✅ Chrome/Chromium (Latest)
- ✅ Firefox (Latest)
- ✅ Safari (Latest)
- ✅ Edge (Latest)
- ✅ Mobile browsers

## 🎓 Learning Resources

- Flask: https://flask.palletsprojects.com/
- MySQL: https://dev.mysql.com/
- Python: https://www.python.org/
- JavaScript: https://developer.mozilla.org/

## 📞 Getting Help

If you encounter issues:

1. Check error messages in browser console (F12)
2. Check Flask server console output
3. Check MySQL logs
4. Review documentation in README.md
5. Check source code comments

## 🎉 Success!

Your Budget Tracking System is now ready to use!

**Start managing your finances today!**

---

For more information, see:
- [QUICKSTART.md](QUICKSTART.md) - Quick reference guide
- [README.md](README.md) - Full documentation
- [app.py](app.py) - Backend code with comments

**Happy budgeting! 💰**
