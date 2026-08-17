@echo off
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo          Flutter Release Build
echo ========================================
echo.

REM ========================================
REM 1. ตรวจสอบ Git Repository
REM ========================================

git rev-parse --is-inside-work-tree >nul 2>&1

if errorlevel 1 (
    echo ERROR: This folder is not a Git repository.
    pause
    exit /b 1
)

echo [1/7] Git repository OK
echo.

REM ========================================
REM 2. อ่าน Version ปัจจุบัน
REM ========================================

for /f "tokens=2" %%A in ('findstr /b "version:" pubspec.yaml') do set VERSION=%%A

if "!VERSION!"=="" (
    echo ERROR: Cannot find version in pubspec.yaml
    pause
    exit /b 1
)

for /f "tokens=1,2 delims=+" %%A in ("!VERSION!") do (
    set APP_VERSION=%%A
    set OLD_BUILD=%%B
)

if "!OLD_BUILD!"=="" (
    set OLD_BUILD=0
)

set /a NEW_BUILD=!OLD_BUILD!+1

echo Current Version : !APP_VERSION!+!OLD_BUILD!
echo New Version     : !APP_VERSION!+!NEW_BUILD!
echo.

REM ========================================
REM 3. แก้ Version ชั่วคราว
REM ========================================

echo [2/7] Updating pubspec.yaml...

powershell -Command "(Get-Content pubspec.yaml) -replace '^version:.*', 'version: !APP_VERSION!+!NEW_BUILD!' | Set-Content pubspec.yaml"

if errorlevel 1 (
    echo ERROR: Failed to update pubspec.yaml
    pause
    exit /b 1
)

echo.
echo Temporary Version:
findstr /b "version:" pubspec.yaml
echo.

REM ========================================
REM 4. Flutter Pub Get
REM ========================================

echo [3/7] Running flutter pub get...

call flutter pub get

if errorlevel 1 (
    echo.
    echo ========================================
    echo ERROR: flutter pub get failed
    echo ========================================
    echo.
    echo Restoring Version...
    
    powershell -Command "(Get-Content pubspec.yaml) -replace '^version:.*', 'version: !APP_VERSION!+!OLD_BUILD!' | Set-Content pubspec.yaml"

    echo Restored:
    findstr /b "version:" pubspec.yaml

    pause
    exit /b 1
)

REM ========================================
REM 5. Flutter Build
REM ========================================

echo.
echo [4/7] Building APK...

call flutter build apk --release

if errorlevel 1 (
    echo.
    echo ========================================
    echo ERROR: Flutter build failed
    echo ========================================
    echo.

    echo Restoring Version...

    powershell -Command "(Get-Content pubspec.yaml) -replace '^version:.*', 'version: !APP_VERSION!+!OLD_BUILD!' | Set-Content pubspec.yaml"

    echo.
    echo Version restored:
    findstr /b "version:" pubspec.yaml

    echo.
    echo Git was NOT modified.
    echo No commit or tag was created.
    echo.

    pause
    exit /b 1
)

REM ========================================
REM 6. Git Commit
REM ========================================

echo.
echo [5/7] Git add...

git add .

if errorlevel 1 (
    echo ERROR: git add failed
    pause
    exit /b 1
)

echo.
echo [6/7] Git commit...

git commit -m "Release !APP_VERSION!+!NEW_BUILD!"

if errorlevel 1 (
    echo.
    echo ERROR: git commit failed
    echo.
    echo Version remains:
    findstr /b "version:" pubspec.yaml
    pause
    exit /b 1
)

REM ========================================
REM 7. Git Tag + Push
REM ========================================

echo.
echo Creating Git tag...

git tag "v!APP_VERSION!+!NEW_BUILD!"

if errorlevel 1 (
    echo.
    echo ERROR: Git tag failed
    pause
    exit /b 1
)

echo.
echo Pushing commit...

git push

if errorlevel 1 (
    echo.
    echo ERROR: git push failed
    pause
    exit /b 1
)

echo.
echo Pushing tag...

git push origin "v!APP_VERSION!+!NEW_BUILD!"

if errorlevel 1 (
    echo.
    echo ERROR: Git tag push failed
    pause
    exit /b 1
)

REM ========================================
REM SUCCESS
REM ========================================

echo.
echo ========================================
echo          RELEASE SUCCESS
echo ========================================
echo.
echo Version : !APP_VERSION!
echo Build   : !NEW_BUILD!
echo Tag     : v!APP_VERSION!+!NEW_BUILD!
echo.
echo APK:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo ========================================

pause