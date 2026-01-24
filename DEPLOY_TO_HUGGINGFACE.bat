@echo off
echo ========================================
echo  Deploy to Hugging Face
echo ========================================
echo.
echo This will upload your model to Hugging Face
echo.

cd ml_model

REM Check if logged in
echo Checking Hugging Face login...
venv\Scripts\huggingface-cli.exe whoami >nul 2>&1
if errorlevel 1 (
    echo.
    echo You need to login first!
    echo.
    echo Please run: huggingface-cli login
    echo Then paste your token from: https://huggingface.co/settings/tokens
    echo.
    venv\Scripts\huggingface-cli.exe login
    echo.
)

echo.
echo Starting deployment...
echo.
venv\Scripts\python.exe deploy_to_huggingface.py

echo.
echo ========================================
echo  Deployment Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Copy your model URL
echo 2. Update lib/services/ai_service.dart with:
echo    - Your model URL
echo    - Your Hugging Face token
echo 3. Run: flutter run
echo.
pause
