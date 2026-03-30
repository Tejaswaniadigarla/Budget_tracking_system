@echo off
REM Budget Tracking System - Installation Script for Windows

echo.
echo ================================
echo Budget Tracking System Setup
echo ================================
echo.

REM Check Python installation
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH.
    echo Please install Python 3.7+ from https://www.python.org/
    pause
    exit /b 1
)

echo Checking Python installation...
python --version
echo.

REM Install pip
echo Installing/Updating pip...
python -m pip install --upgrade pip
echo.

REM Install Flask and dependencies
echo Installing required packages...
pip install -r requirements.txt

if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo ================================
echo Installation Complete!
echo ================================
echo.
echo Next steps:
echo 1. Setup MySQL database:
echo    - Create database: CREATE DATABASE budget_tracker;
echo    - Import SQL file: budget_tracking_system.sql
echo.
echo 2. Configure MySQL credentials in app.py:
echo    - Edit the file and update your MySQL username and password
echo.
echo 3. Run the application:
echo    python app.py
echo.
echo 4. Open browser and visit: http://localhost:5000
echo.

pause
