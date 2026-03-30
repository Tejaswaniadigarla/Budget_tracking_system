#!/bin/bash

# Budget Tracking System - Installation Script for macOS/Linux

echo ""
echo "================================"
echo "Budget Tracking System Setup"
echo "================================"
echo ""

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed."
    echo "Please install Python 3.7+ from https://www.python.org/"
    exit 1
fi

echo "Checking Python installation..."
python3 --version
echo ""

# Install pip
echo "Installing/Updating pip..."
python3 -m pip install --upgrade pip
echo ""

# Install Flask and dependencies
echo "Installing required packages..."
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
fi

echo ""
echo "================================"
echo "Installation Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Setup MySQL database:"
echo "   - Create database: CREATE DATABASE budget_tracker;"
echo "   - Import SQL file: budget_tracking_system.sql"
echo ""
echo "2. Configure MySQL credentials in app.py:"
echo "   - Edit the file and update your MySQL username and password"
echo ""
echo "3. Run the application:"
echo "   python3 app.py"
echo ""
echo "4. Open browser and visit: http://localhost:5000"
echo ""
