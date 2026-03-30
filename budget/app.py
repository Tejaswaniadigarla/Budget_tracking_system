from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3
from datetime import datetime, timedelta
from functools import wraps
import os
import json

app = Flask(__name__)
app.secret_key = 'budget_system_secret_key_2026'

# SQLite Database Configuration
DATABASE = 'd:\\budget\\budget_tracker.db'

def get_db():
    """Get database connection"""
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

def init_db():
    """Initialize database with tables"""
    db = get_db()
    cursor = db.cursor()
    
    # Create tables if they don't exist
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Users (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Categories (
            category_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('Income', 'Expense'))
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Transactions (
            transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            category_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            transaction_date DATE NOT NULL,
            description TEXT,
            FOREIGN KEY(user_id) REFERENCES Users(user_id),
            FOREIGN KEY(category_id) REFERENCES Categories(category_id)
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Budgets (
            budget_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            category_id INTEGER NOT NULL,
            limit_amount REAL NOT NULL,
            month TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES Users(user_id),
            FOREIGN KEY(category_id) REFERENCES Categories(category_id)
        )
    ''')
    
    # Insert sample categories if not exist
    cursor.execute("SELECT COUNT(*) FROM Categories")
    if cursor.fetchone()[0] == 0:
        categories = [
            ('Salary', 'Income'),
            ('Rent', 'Expense'),
            ('Food', 'Expense'),
            ('Groceries', 'Expense'),
            ('Transport', 'Expense'),
            ('Entertainment', 'Expense'),
            ('Utilities', 'Expense'),
            ('Healthcare', 'Expense')
        ]
        for name, type_ in categories:
            cursor.execute("INSERT INTO Categories (name, type) VALUES (?, ?)", (name, type_))
    
    db.commit()
    db.close()

# Initialize database on startup
init_db()

# Login Required Decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# ============================================================================
# AUTHENTICATION ROUTES
# ============================================================================

@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        confirm_password = data.get('confirm_password')

        if not all([name, email, password, confirm_password]):
            return jsonify({'success': False, 'message': 'All fields are required'}), 400

        if password != confirm_password:
            return jsonify({'success': False, 'message': 'Passwords do not match'}), 400

        db = get_db()
        cursor = db.cursor()
        
        try:
            cursor.execute('SELECT * FROM Users WHERE email = ?', (email,))
            existing_user = cursor.fetchone()

            if existing_user:
                return jsonify({'success': False, 'message': 'Email already exists'}), 400

            hashed_password = generate_password_hash(password)
            cursor.execute('INSERT INTO Users (name, email, password) VALUES (?, ?, ?)',
                          (name, email, hashed_password))
            db.commit()
            
            return jsonify({'success': True, 'message': 'Registration successful! Please login'}), 201
        except Exception as e:
            return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500
        finally:
            db.close()

    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return jsonify({'success': False, 'message': 'Email and password required'}), 400

        db = get_db()
        cursor = db.cursor()
        
        try:
            cursor.execute('SELECT * FROM Users WHERE email = ?', (email,))
            user = cursor.fetchone()

            if user and check_password_hash(user['password'], password):
                session['user_id'] = user['user_id']
                session['user_name'] = user['name']
                return jsonify({'success': True, 'message': 'Login successful'}), 200
            else:
                return jsonify({'success': False, 'message': 'Invalid email or password'}), 401
        except Exception as e:
            return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500
        finally:
            db.close()

    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

# ============================================================================
# DASHBOARD ROUTES
# ============================================================================

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html', user_name=session['user_name'])

@app.route('/api/dashboard-data')
@login_required
def get_dashboard_data():
    user_id = session['user_id']
    db = get_db()
    cursor = db.cursor()
    
    current_month = datetime.now().strftime('%Y-%m')
    
    try:
        # Get monthly income and expenses
        cursor.execute("""
            SELECT c.type, COALESCE(SUM(t.amount), 0) as total
            FROM Categories c
            LEFT JOIN Transactions t ON c.category_id = t.category_id
            WHERE t.user_id = ? AND strftime('%Y-%m', t.transaction_date) = ?
            GROUP BY c.type
        """, (user_id, current_month))
        
        data = {}
        for row in cursor.fetchall():
            data[row[0]] = float(row[1])
        
        income = data.get('Income', 0)
        expenses = data.get('Expense', 0)
        
        # Get recent transactions
        cursor.execute("""
            SELECT t.transaction_id, c.name, t.amount, 
                   t.transaction_date, t.description, c.type
            FROM Transactions t
            JOIN Categories c ON t.category_id = c.category_id
            WHERE t.user_id = ?
            ORDER BY t.transaction_date DESC
            LIMIT 5
        """, (user_id,))
        
        recent_transactions = []
        for row in cursor.fetchall():
            recent_transactions.append({
                'transaction_id': row[0],
                'category_name': row[1],
                'amount': row[2],
                'transaction_date': row[3],
                'description': row[4],
                'type': row[5]
            })
        
        # Get budget status
        cursor.execute("""
            SELECT b.budget_id, c.name, b.limit_amount, 
                   COALESCE(SUM(t.amount), 0) as spent
            FROM Budgets b
            JOIN Categories c ON b.category_id = c.category_id
            LEFT JOIN Transactions t ON b.user_id = t.user_id 
                AND b.category_id = t.category_id 
                AND strftime('%Y-%m', t.transaction_date) = b.month
            WHERE b.user_id = ? AND b.month = ?
            GROUP BY b.budget_id, c.name, b.limit_amount
        """, (user_id, current_month))
        
        budget_data = []
        for row in cursor.fetchall():
            spent = float(row[3])
            limit = float(row[2])
            percentage = (spent / limit * 100) if limit > 0 else 0
            budget_data.append({
                'category': row[1],
                'limit': limit,
                'spent': spent,
                'remaining': limit - spent,
                'percentage': min(percentage, 100),
                'status': 'Over Budget' if spent > limit else 'On Track'
            })
        
        return jsonify({
            'income': income,
            'expenses': expenses,
            'balance': income - expenses,
            'recent_transactions': recent_transactions,
            'budgets': budget_data
        })
    finally:
        db.close()

# ============================================================================
# TRANSACTION ROUTES
# ============================================================================

@app.route('/api/categories')
@login_required
def get_categories():
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute('SELECT category_id, name, type FROM Categories ORDER BY name')
        categories = []
        for row in cursor.fetchall():
            categories.append({
                'category_id': row[0],
                'name': row[1],
                'type': row[2]
            })
        return jsonify(categories)
    finally:
        db.close()

@app.route('/api/transactions', methods=['GET', 'POST'])
@login_required
def transactions():
    user_id = session['user_id']
    db = get_db()
    cursor = db.cursor()
    
    try:
        if request.method == 'POST':
            data = request.get_json()
            category_id = data.get('category_id')
            amount = data.get('amount')
            transaction_date = data.get('transaction_date')
            description = data.get('description')
            
            if not all([category_id, amount, transaction_date]):
                return jsonify({'success': False, 'message': 'Missing required fields'}), 400
            
            cursor.execute("""
                INSERT INTO Transactions (user_id, category_id, amount, transaction_date, description)
                VALUES (?, ?, ?, ?, ?)
            """, (user_id, category_id, amount, transaction_date, description))
            db.commit()
            
            return jsonify({'success': True, 'message': 'Transaction added successfully'}), 201
        
        # GET request - fetch transactions
        cursor.execute("""
            SELECT t.transaction_id, t.user_id, c.name, c.type,
                   t.amount, t.transaction_date, t.description
            FROM Transactions t
            JOIN Categories c ON t.category_id = c.category_id
            WHERE t.user_id = ?
            ORDER BY t.transaction_date DESC
        """, (user_id,))
        
        transactions_list = []
        for row in cursor.fetchall():
            transactions_list.append({
                'transaction_id': row[0],
                'user_id': row[1],
                'category_name': row[2],
                'type': row[3],
                'amount': row[4],
                'transaction_date': row[5],
                'description': row[6]
            })
        return jsonify(transactions_list)
    finally:
        db.close()

@app.route('/api/transactions/<int:transaction_id>', methods=['DELETE'])
@login_required
def delete_transaction(transaction_id):
    user_id = session['user_id']
    db = get_db()
    cursor = db.cursor()
    
    try:
        # Verify ownership
        cursor.execute('SELECT user_id FROM Transactions WHERE transaction_id = ?', (transaction_id,))
        transaction = cursor.fetchone()
        
        if not transaction or transaction[0] != user_id:
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        cursor.execute('DELETE FROM Transactions WHERE transaction_id = ?', (transaction_id,))
        db.commit()
        
        return jsonify({'success': True, 'message': 'Transaction deleted'})
    finally:
        db.close()

# ============================================================================
# BUDGET ROUTES
# ============================================================================

@app.route('/api/budgets', methods=['GET', 'POST'])
@login_required
def budgets():
    user_id = session['user_id']
    db = get_db()
    cursor = db.cursor()
    
    try:
        if request.method == 'POST':
            data = request.get_json()
            category_id = data.get('category_id')
            limit_amount = data.get('limit_amount')
            month = data.get('month')
            
            if not all([category_id, limit_amount, month]):
                return jsonify({'success': False, 'message': 'Missing required fields'}), 400
            
            cursor.execute("""
                INSERT INTO Budgets (user_id, category_id, limit_amount, month)
                VALUES (?, ?, ?, ?)
            """, (user_id, category_id, limit_amount, month))
            db.commit()
            
            return jsonify({'success': True, 'message': 'Budget created'}), 201
        
        # GET request
        cursor.execute("""
            SELECT b.budget_id, c.name, b.limit_amount, b.month,
                   COALESCE(SUM(t.amount), 0) as spent
            FROM Budgets b
            JOIN Categories c ON b.category_id = c.category_id
            LEFT JOIN Transactions t ON b.user_id = t.user_id 
                AND b.category_id = t.category_id 
                AND strftime('%Y-%m', t.transaction_date) = b.month
            WHERE b.user_id = ?
            GROUP BY b.budget_id, c.name, b.limit_amount, b.month
            ORDER BY b.month DESC
        """, (user_id,))
        
        budgets_list = []
        for row in cursor.fetchall():
            budgets_list.append({
                'budget_id': row[0],
                'category_name': row[1],
                'limit_amount': row[2],
                'month': row[3],
                'spent': row[4]
            })
        return jsonify(budgets_list)
    except Exception as e:
        print(f"Error in budgets endpoint: {str(e)}")
        return jsonify({'error': 'Error loading budgets', 'details': str(e)}), 500
    finally:
        db.close()

@app.route('/api/budgets/<int:budget_id>', methods=['DELETE'])
@login_required
def delete_budget(budget_id):
    user_id = session['user_id']
    db = get_db()
    cursor = db.cursor()
    
    try:
        cursor.execute('SELECT user_id FROM Budgets WHERE budget_id = ?', (budget_id,))
        budget = cursor.fetchone()
        
        if not budget or budget[0] != user_id:
            return jsonify({'success': False, 'message': 'Unauthorized'}), 403
        
        cursor.execute('DELETE FROM Budgets WHERE budget_id = ?', (budget_id,))
        db.commit()
        
        return jsonify({'success': True, 'message': 'Budget deleted'})
    finally:
        db.close()

# ============================================================================
# REPORTS ROUTES
# ============================================================================

@app.route('/api/monthly-summary')
@login_required
def monthly_summary():
    user_id = session['user_id']
    db = get_db()
    cursor = db.cursor()
    
    try:
        cursor.execute("""
            SELECT strftime('%Y-%m', t.transaction_date) as month, 
                   c.type, 
                   COALESCE(SUM(t.amount), 0) as total
            FROM Transactions t
            JOIN Categories c ON t.category_id = c.category_id
            WHERE t.user_id = ?
            GROUP BY strftime('%Y-%m', t.transaction_date), c.type
            ORDER BY month DESC
        """, (user_id,))
        
        # Organize by month
        summary = {}
        for row in cursor.fetchall():
            month = row[0]
            if month not in summary:
                summary[month] = {'Income': 0, 'Expense': 0}
            summary[month][row[1]] = float(row[2])
        
        return jsonify(summary)
    finally:
        db.close()

@app.route('/api/category-analysis')
@login_required
def category_analysis():
    user_id = session['user_id']
    db = get_db()
    cursor = db.cursor()
    
    try:
        cursor.execute("""
            SELECT c.name, c.type, COALESCE(SUM(t.amount), 0) as total
            FROM Categories c
            LEFT JOIN Transactions t ON c.category_id = t.category_id AND t.user_id = ?
            GROUP BY c.category_id, c.name, c.type
            ORDER BY total DESC
        """, (user_id,))
        
        result = {'income': [], 'expense': []}
        for row in cursor.fetchall():
            item = {'category': row[0], 'amount': float(row[2])}
            if row[1] == 'Income':
                result['income'].append(item)
            else:
                result['expense'].append(item)
        
        return jsonify(result)
    finally:
        db.close()

@app.route('/reports')
@login_required
def reports():
    return render_template('reports.html', user_name=session['user_name'])

# ============================================================================
# PAGES
# ============================================================================

@app.route('/transactions')
@login_required
def transactions_page():
    return render_template('transactions.html', user_name=session['user_name'])

@app.route('/budgets')
@login_required
def budgets_page():
    return render_template('budgets.html', user_name=session['user_name'])

# Error handling
@app.errorhandler(404)
def not_found(error):
    return render_template('404.html'), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({'error': 'Server error'}), 500

if __name__ == '__main__':
    print("\n" + "="*60)
    print("BUDGET TRACKING SYSTEM STARTED")
    print("="*60)
    print("\nApplication is running!")
    print("\nOpen this link in your browser:")
    print("   >>> http://127.0.0.1:5000 <<<")
    print("\nDefault Login:")
    print("   Email: user@example.com")
    print("   Password: password123")
    print("\nPress CTRL+C to stop the server")
    print("="*60 + "\n")
    app.run(debug=True, host='127.0.0.1', port=5000)
