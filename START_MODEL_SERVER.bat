echo off
echo ============================================
echo Starting XLM-RoBERTa Model Server
echo ============================================
echo.
echo Training Data: 8,197 total examples
echo   - Urdu: 4,106 phrases/words
echo   - Punjabi: 4,091 phrases/words  
echo.
echo Model: xlm-roberta-base (fine-tuned)
echo Server: http://localhost:5000
echo.
echo Please wait, loading model...
echo ============================================
echo.

REM Change to the directory where this batch file is located
cd /d "%~dp0"
echo Current directory: %CD%
echo.

cd ml_model
call venv\Scripts\activate.bat
python model_api.py

pause
