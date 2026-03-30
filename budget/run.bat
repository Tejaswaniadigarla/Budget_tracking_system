@echo off
REM Budget Tracking System - Quick Run Script
REM This batch file automatically runs the Flask application

echo.
echo ======================================
echo  BUDGET TRACKING SYSTEM
echo ======================================
echo.
echo Starting the application...
echo.

REM Change to the budget directory
cd /d "%~dp0"

REM Activate virtual environment (if it exists)
if exist .venv\Scripts\activate.bat (
    call .venv\Scripts\activate.bat
)

REM Run the Flask application
python app.py

REM Pause to see any error messages
pause
