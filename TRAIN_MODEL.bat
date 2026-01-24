@echo off
echo ========================================
echo   XLM-RoBERTa Model Training Setup
echo   AI Urdu/Punjabi Language Learning
echo ========================================
echo.

REM Check if Python is installed
python --version > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.8+ from python.org
    pause
    exit /b 1
)

echo [1/5] Python found!
echo.

REM Navigate to ml_model directory
cd /d "%~dp0ml_model"

echo [2/5] Creating virtual environment...
if not exist "venv" (
    python -m venv venv
    echo Virtual environment created!
) else (
    echo Virtual environment already exists.
)
echo.

echo [3/5] Activating virtual environment...
call venv\Scripts\activate
echo.

echo [4/5] Installing dependencies...
echo This may take a few minutes...
python -m pip install --upgrade pip --quiet
pip install torch --index-url https://download.pytorch.org/whl/cpu --quiet
pip install transformers datasets pandas numpy scikit-learn flask flask-cors --quiet
echo Dependencies installed!
echo.

echo [5/5] Training XLM-RoBERTa model...
echo This will take 15-30 minutes depending on your hardware.
echo Please be patient...
echo.
python train_xlm_roberta.py

echo.
echo ========================================
echo   Training Complete!
echo ========================================
echo.
echo Model saved to: trained_model/xlm_roberta_urdu_punjabi/
echo.
echo Next steps:
echo 1. Run START_MODEL_SERVER.bat to start the API server
echo 2. Run your Flutter app with: flutter run
echo.
pause
