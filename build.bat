@echo off
echo ==============================
echo Flutter Build
echo ==============================

call flutter pub get

if errorlevel 1 (
    echo.
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
)

call flutter build apk --release

if errorlevel 1 (
    echo.
    echo ERROR: Flutter build failed
    pause
    exit /b 1
)

echo.
echo ==============================
echo BUILD SUCCESS
echo ==============================
echo.
echo APK:
echo build\app\outputs\flutter-apk\app-release.apk
echo.

pause