@echo off
echo Installing dependencies...
pip install -r requirements.txt

echo Initializing database...
python -c "from main import init_db; init_db()"

echo Setup complete!
pause
