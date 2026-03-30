-- Budget Tracking System Database Schema
-- This script creates all necessary tables, procedures, functions, views, and sample data

-- ============================================================================
-- 1. CREATE TABLES
-- ============================================================================

-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(10) NOT NULL CHECK (type IN ('Income', 'Expense'))
);

-- Transactions Table
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_date DATE NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Budgets Table
CREATE TABLE Budgets (
    budget_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    limit_amount DECIMAL(10, 2) NOT NULL,
    month VARCHAR(20) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Summary Table (for trigger to update)
CREATE TABLE Monthly_Summary (
    summary_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    month VARCHAR(20) NOT NULL,
    total_income DECIMAL(10, 2) DEFAULT 0,
    total_expenses DECIMAL(10, 2) DEFAULT 0,
    net_amount DECIMAL(10, 2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ============================================================================
-- 2. INSERT SAMPLE DATA
-- ============================================================================

-- Insert Users
INSERT INTO Users (name, email, password) 
VALUES ('Ravi', 'ravi@example.com', 'encryptedpwd');

-- Insert Categories
INSERT INTO Categories (name, type) 
VALUES 
('Salary', 'Income'),
('Rent', 'Expense'),
('Food', 'Expense'),
('Groceries', 'Expense');

-- Insert Transactions
INSERT INTO Transactions (user_id, category_id, amount, transaction_date, description) 
VALUES 
(1, 1, 30000, '2025-04-01', 'Monthly Salary'),
(1, 2, 8000, '2025-04-02', 'April Rent'),
(1, 3, 1500, '2025-04-03', 'Food expenses');

-- Insert Budgets
INSERT INTO Budgets (user_id, category_id, limit_amount, month) 
VALUES 
(1, 2, 8000, 'April'),
(1, 3, 5000, 'April');

-- ============================================================================
-- 3. PROCEDURES
-- ============================================================================

-- Procedure 1: Calculate monthly spending per category
DELIMITER //
CREATE PROCEDURE CalculateMonthlyCategorySpending(
    IN p_user_id INT,
    IN p_month VARCHAR(20)
)
BEGIN
    SELECT 
        c.category_id,
        c.name AS category_name,
        c.type,
        COALESCE(SUM(t.amount), 0) AS total_amount
    FROM Categories c
    LEFT JOIN Transactions t ON c.category_id = t.category_id 
        AND t.user_id = p_user_id 
        AND DATE_FORMAT(t.transaction_date, '%Y-%m') = p_month
    GROUP BY c.category_id, c.name, c.type
    ORDER BY total_amount DESC;
END //
DELIMITER ;

-- Procedure 2: Get budget overview for a user
DELIMITER //
CREATE PROCEDURE GetBudgetOverview(IN p_user_id INT)
BEGIN
    SELECT 
        b.budget_id,
        b.month,
        c.name AS category_name,
        b.limit_amount,
        COALESCE(SUM(t.amount), 0) AS spent_amount,
        (b.limit_amount - COALESCE(SUM(t.amount), 0)) AS remaining_amount,
        CASE 
            WHEN COALESCE(SUM(t.amount), 0) > b.limit_amount THEN 'Over Budget'
            WHEN COALESCE(SUM(t.amount), 0) > (b.limit_amount * 0.8) THEN 'Warning'
            ELSE 'On Track'
        END AS status
    FROM Budgets b
    JOIN Categories c ON b.category_id = c.category_id
    LEFT JOIN Transactions t ON b.user_id = t.user_id 
        AND b.category_id = t.category_id 
        AND DATE_FORMAT(t.transaction_date, '%Y-%m') = b.month
    WHERE b.user_id = p_user_id
    GROUP BY b.budget_id, b.month, c.name, b.limit_amount;
END //
DELIMITER ;

-- ============================================================================
-- 4. FUNCTIONS
-- ============================================================================

-- Function 1: Check if budget limit exceeded
DELIMITER //
CREATE FUNCTION CheckBudgetExceeded(
    p_budget_id INT
) 
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_limit DECIMAL(10, 2);
    DECLARE v_spent DECIMAL(10, 2);
    
    SELECT b.limit_amount INTO v_limit
    FROM Budgets b
    WHERE b.budget_id = p_budget_id;
    
    SELECT COALESCE(SUM(t.amount), 0) INTO v_spent
    FROM Transactions t
    JOIN Budgets b ON t.user_id = b.user_id 
        AND t.category_id = b.category_id
    WHERE b.budget_id = p_budget_id
        AND DATE_FORMAT(t.transaction_date, '%Y-%m') = b.month;
    
    RETURN v_spent > v_limit;
END //
DELIMITER ;

-- Function 2: Get total monthly income for user
DELIMITER //
CREATE FUNCTION GetMonthlyIncome(
    p_user_id INT,
    p_month VARCHAR(20)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_income DECIMAL(10, 2);
    
    SELECT COALESCE(SUM(t.amount), 0) INTO v_income
    FROM Transactions t
    JOIN Categories c ON t.category_id = c.category_id
    WHERE t.user_id = p_user_id
        AND c.type = 'Income'
        AND DATE_FORMAT(t.transaction_date, '%Y-%m') = p_month;
    
    RETURN v_income;
END //
DELIMITER ;

-- Function 3: Get total monthly expenses for user
DELIMITER //
CREATE FUNCTION GetMonthlyExpenses(
    p_user_id INT,
    p_month VARCHAR(20)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_expenses DECIMAL(10, 2);
    
    SELECT COALESCE(SUM(t.amount), 0) INTO v_expenses
    FROM Transactions t
    JOIN Categories c ON t.category_id = c.category_id
    WHERE t.user_id = p_user_id
        AND c.type = 'Expense'
        AND DATE_FORMAT(t.transaction_date, '%Y-%m') = p_month;
    
    RETURN v_expenses;
END //
DELIMITER ;

-- ============================================================================
-- 5. TRIGGERS
-- ============================================================================

-- Trigger: Auto-update Monthly_Summary when transaction is inserted
DELIMITER //
CREATE TRIGGER UpdateSummaryOnTransactionInsert
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE v_month VARCHAR(20);
    DECLARE v_income DECIMAL(10, 2);
    DECLARE v_expenses DECIMAL(10, 2);
    
    SET v_month = DATE_FORMAT(NEW.transaction_date, '%Y-%m');
    
    -- Get income and expenses
    SET v_income = GetMonthlyIncome(NEW.user_id, v_month);
    SET v_expenses = GetMonthlyExpenses(NEW.user_id, v_month);
    
    -- Update or insert into summary
    INSERT INTO Monthly_Summary (user_id, month, total_income, total_expenses, net_amount)
    VALUES (NEW.user_id, v_month, v_income, v_expenses, (v_income - v_expenses))
    ON DUPLICATE KEY UPDATE
        total_income = v_income,
        total_expenses = v_expenses,
        net_amount = (v_income - v_expenses);
END //
DELIMITER ;

-- Trigger: Auto-update Monthly_Summary when transaction is updated
DELIMITER //
CREATE TRIGGER UpdateSummaryOnTransactionUpdate
AFTER UPDATE ON Transactions
FOR EACH ROW
BEGIN
    DECLARE v_month VARCHAR(20);
    DECLARE v_income DECIMAL(10, 2);
    DECLARE v_expenses DECIMAL(10, 2);
    
    SET v_month = DATE_FORMAT(NEW.transaction_date, '%Y-%m');
    
    -- Get income and expenses
    SET v_income = GetMonthlyIncome(NEW.user_id, v_month);
    SET v_expenses = GetMonthlyExpenses(NEW.user_id, v_month);
    
    -- Update summary
    INSERT INTO Monthly_Summary (user_id, month, total_income, total_expenses, net_amount)
    VALUES (NEW.user_id, v_month, v_income, v_expenses, (v_income - v_expenses))
    ON DUPLICATE KEY UPDATE
        total_income = v_income,
        total_expenses = v_expenses,
        net_amount = (v_income - v_expenses);
END //
DELIMITER ;

-- ============================================================================
-- 6. VIEWS
-- ============================================================================

-- View 1: Monthly summary of income and expenses
CREATE VIEW v_monthly_income_expense_summary AS
SELECT 
    u.user_id,
    u.name,
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,
    c.type,
    COALESCE(SUM(t.amount), 0) AS total_amount
FROM Users u
LEFT JOIN Transactions t ON u.user_id = t.user_id
LEFT JOIN Categories c ON t.category_id = c.category_id
GROUP BY u.user_id, u.name, DATE_FORMAT(t.transaction_date, '%Y-%m'), c.type
ORDER BY u.user_id, month;

-- View 2: Budget vs actual expenses
CREATE VIEW v_budget_vs_actual AS
SELECT 
    b.budget_id,
    u.name AS user_name,
    b.month,
    c.name AS category_name,
    b.limit_amount,
    COALESCE(SUM(t.amount), 0) AS actual_spent,
    (b.limit_amount - COALESCE(SUM(t.amount), 0)) AS remaining_budget,
    ROUND((COALESCE(SUM(t.amount), 0) / b.limit_amount) * 100, 2) AS utilization_percentage,
    CASE 
        WHEN COALESCE(SUM(t.amount), 0) > b.limit_amount THEN 'Over Budget'
        WHEN COALESCE(SUM(t.amount), 0) > (b.limit_amount * 0.8) THEN 'Warning'
        ELSE 'On Track'
    END AS status
FROM Budgets b
JOIN Users u ON b.user_id = u.user_id
JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Transactions t ON b.user_id = t.user_id 
    AND b.category_id = t.category_id 
    AND DATE_FORMAT(t.transaction_date, '%Y-%m') = b.month
GROUP BY b.budget_id, u.name, b.month, c.name, b.limit_amount
ORDER BY b.month DESC, u.name;

-- View 3: Category-wise transaction history
CREATE VIEW v_category_transaction_history AS
SELECT 
    t.transaction_id,
    u.name AS user_name,
    c.name AS category_name,
    c.type,
    t.amount,
    t.transaction_date,
    t.description
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Categories c ON t.category_id = c.category_id
ORDER BY t.transaction_date DESC, u.user_id;

-- ============================================================================
-- 7. NESTED QUERIES (as Views for easier access)
-- ============================================================================

-- Query 1: Highest expense category in a month
CREATE VIEW v_highest_expense_category AS
SELECT 
    u.user_id,
    u.name,
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,
    c.name AS category_name,
    SUM(t.amount) AS total_expense
FROM Users u
JOIN Transactions t ON u.user_id = t.user_id
JOIN Categories c ON t.category_id = c.category_id
WHERE c.type = 'Expense'
GROUP BY u.user_id, u.name, DATE_FORMAT(t.transaction_date, '%Y-%m'), c.name
HAVING SUM(t.amount) = (
    SELECT MAX(category_total)
    FROM (
        SELECT SUM(amount) AS category_total
        FROM Transactions t2
        JOIN Categories c2 ON t2.category_id = c2.category_id
        WHERE t2.user_id = u.user_id
            AND c2.type = 'Expense'
            AND DATE_FORMAT(t2.transaction_date, '%Y-%m') = DATE_FORMAT(t.transaction_date, '%Y-%m')
        GROUP BY t2.category_id
    ) AS category_totals
)
ORDER BY month DESC;

-- Query 2: Users with expenses exceeding income
CREATE VIEW v_expenses_exceeding_income AS
SELECT 
    u.user_id,
    u.name,
    u.email,
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,
    GetMonthlyIncome(u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m')) AS total_income,
    GetMonthlyExpenses(u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m')) AS total_expenses,
    (GetMonthlyExpenses(u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m')) - 
     GetMonthlyIncome(u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m'))) AS deficit
FROM Users u
JOIN Transactions t ON u.user_id = t.user_id
GROUP BY u.user_id, u.name, u.email, DATE_FORMAT(t.transaction_date, '%Y-%m')
HAVING GetMonthlyExpenses(u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m')) > 
       GetMonthlyIncome(u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m'))
ORDER BY month DESC, deficit DESC;

-- Query 3: Top 3 categories by expense
CREATE VIEW v_top_3_expense_categories AS
SELECT 
    u.user_id,
    u.name,
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,
    c.name AS category_name,
    SUM(t.amount) AS total_spent,
    RANK() OVER (PARTITION BY u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m') ORDER BY SUM(t.amount) DESC) AS rank_position
FROM Users u
JOIN Transactions t ON u.user_id = t.user_id
JOIN Categories c ON t.category_id = c.category_id
WHERE c.type = 'Expense'
GROUP BY u.user_id, u.name, DATE_FORMAT(t.transaction_date, '%Y-%m'), c.name
HAVING RANK() OVER (PARTITION BY u.user_id, DATE_FORMAT(t.transaction_date, '%Y-%m') ORDER BY SUM(t.amount) DESC) <= 3
ORDER BY month DESC, rank_position;

-- ============================================================================
-- 8. JOIN-BASED QUERIES (as Views)
-- ============================================================================

-- Query 1: Transaction details with category names
CREATE VIEW v_transaction_details AS
SELECT 
    t.transaction_id,
    u.user_id,
    u.name AS user_name,
    c.category_id,
    c.name AS category_name,
    c.type,
    t.amount,
    t.transaction_date,
    t.description
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Categories c ON t.category_id = c.category_id
ORDER BY t.transaction_date DESC;

-- Query 2: Budget utilization per category
CREATE VIEW v_budget_utilization_per_category AS
SELECT 
    b.budget_id,
    u.name AS user_name,
    c.name AS category_name,
    b.month,
    b.limit_amount,
    COALESCE(SUM(t.amount), 0) AS amount_spent,
    ROUND((COALESCE(SUM(t.amount), 0) / b.limit_amount) * 100, 2) AS utilization_percentage,
    (b.limit_amount - COALESCE(SUM(t.amount), 0)) AS remaining_amount
FROM Budgets b
JOIN Users u ON b.user_id = u.user_id
JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Transactions t ON b.user_id = t.user_id 
    AND b.category_id = t.category_id 
    AND DATE_FORMAT(t.transaction_date, '%Y-%m') = b.month
GROUP BY b.budget_id, u.name, c.name, b.month, b.limit_amount
ORDER BY utilization_percentage DESC;

-- Query 3: User financial overview with income and expenses
CREATE VIEW v_user_financial_overview AS
SELECT 
    u.user_id,
    u.name,
    u.email,
    COUNT(DISTINCT CASE WHEN c.type = 'Income' THEN t.transaction_id END) AS income_transactions,
    COUNT(DISTINCT CASE WHEN c.type = 'Expense' THEN t.transaction_id END) AS expense_transactions,
    COALESCE(SUM(CASE WHEN c.type = 'Income' THEN t.amount ELSE 0 END), 0) AS total_income,
    COALESCE(SUM(CASE WHEN c.type = 'Expense' THEN t.amount ELSE 0 END), 0) AS total_expenses,
    (COALESCE(SUM(CASE WHEN c.type = 'Income' THEN t.amount ELSE 0 END), 0) - 
     COALESCE(SUM(CASE WHEN c.type = 'Expense' THEN t.amount ELSE 0 END), 0)) AS net_balance
FROM Users u
LEFT JOIN Transactions t ON u.user_id = t.user_id
LEFT JOIN Categories c ON t.category_id = c.category_id
GROUP BY u.user_id, u.name, u.email
ORDER BY u.user_id;

-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================

/*
-- Call procedures
CALL CalculateMonthlyCategorySpending(1, '2025-04');
CALL GetBudgetOverview(1);

-- Call functions
SELECT CheckBudgetExceeded(1);
SELECT GetMonthlyIncome(1, '2025-04');
SELECT GetMonthlyExpenses(1, '2025-04');

-- Query views
SELECT * FROM v_monthly_income_expense_summary;
SELECT * FROM v_budget_vs_actual;
SELECT * FROM v_category_transaction_history;
SELECT * FROM v_highest_expense_category;
SELECT * FROM v_expenses_exceeding_income;
SELECT * FROM v_top_3_expense_categories;
SELECT * FROM v_transaction_details;
SELECT * FROM v_budget_utilization_per_category;
SELECT * FROM v_user_financial_overview;
*/
