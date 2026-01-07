@echo off
echo ============================================
echo XLM-RoBERTa Training Pipeline
echo Urdu ^& Pakistani Punjabi Language Model
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from python.org
    pause
    exit /b 1
)

echo Step 1: Setting up virtual environment...
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment
        pause
        exit /b 1
    )
) else (
    echo Virtual environment already exists
)

echo.
echo Step 2: Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ERROR: Failed to activate virtual environment
    pause
    exit /b 1
)

echo.
echo Step 3: Installing dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Step 4: Training XLM-RoBERTa model...
echo This will take 15-30 minutes depending on your hardware
python train_xlm_roberta.py
if errorlevel 1 (
    echo ERROR: Training failed
    pause
    exit /b 1
)

echo.
echo Step 5: Converting to TFLite format...
python convert_to_tflite.py
if errorlevel 1 (
    echo ERROR: Conversion failed
    pause
    exit /b 1
)

echo.
echo Step 6: Copying model to Flutter assets...
if not exist "..\assets\models" mkdir "..\assets\models"
copy trained_model\xlm_roberta_model.tflite ..\assets\models\ >nul 2>&1
copy trained_model\vocab.json ..\assets\models\ >nul 2>&1
copy trained_model\tokenizer_config.json ..\assets\models\ >nul 2>&1

if exist "..\assets\models\xlm_roberta_model.tflite" (
    echo ✓ Model files copied successfully
) else (
    echo WARNING: Could not copy model files to assets
    echo Please copy manually from trained_model\ to assets\models\
)

echo.
echo ============================================
echo ✓ TRAINING COMPLETE!
echo ============================================
echo.
echo Model files created:
echo   - trained_model\xlm_roberta_model.tflite
echo   - trained_model\vocab.json
echo   - trained_model\tokenizer_config.json
echo.
echo Dataset created:
echo   - data\urdu_punjabi_dataset.csv
echo   - data\urdu_punjabi_dataset.json
echo.
echo Next steps:
echo   1. Update pubspec.yaml to include model assets
echo   2. Run 'flutter pub get'
echo   3. Test the app with new model
echo.
pause
