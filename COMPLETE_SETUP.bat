@echo off
title Complete Setup - AI Language Learning App

echo ========================================
echo   Complete Setup Script
echo   AI Urdu/Punjabi Language Learning
echo ========================================
echo.

echo This script will:
echo 1. Install Python dependencies
echo 2. Train the XLM-RoBERTa model (15-30 min)
echo 3. Install Flutter dependencies
echo 4. Start the model server
echo 5. Run the Flutter app
echo.
echo Total time: 20-40 minutes (first time only)
echo.
pause

REM Step 1: Train model
echo.
echo ========================================
echo   STEP 1: Training XLM-RoBERTa Model
echo ========================================
echo.
call TRAIN_MODEL.bat
if errorlevel 1 (
    echo [ERROR] Model training failed!
    pause
    exit /b 1
)

REM Step 2: Install Flutter dependencies
echo.
echo ========================================
echo   STEP 2: Installing Flutter Dependencies
echo ========================================
echo.
call flutter pub get
if errorlevel 1 (
    echo [WARNING] Flutter pub get failed. Run manually: flutter pub get
)

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Now running the app...
echo.
echo Please:
echo 1. Keep this terminal open (model server)
echo 2. Open a NEW terminal
echo 3. Run: flutter run
echo.

REM Start model server in this window
call START_MODEL_SERVER.bat

pause
