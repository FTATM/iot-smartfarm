@echo off
echo Starting Python scripts...

start cmd /k python socket_server.py
timeout /t 4
start cmd /k python taskcamera_server.py

echo Scripts started.
pause
