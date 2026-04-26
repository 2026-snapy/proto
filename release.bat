@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: release.bat ^<version^>
    echo Example: release.bat 0.1.5
    exit /b 1
)

set "VERSION=%~1"
set "TAG=v%VERSION%"
set "GRADLE_FILE=java\build.gradle"

echo [1/4] Updating version in %GRADLE_FILE% to %VERSION%
powershell -NoProfile -Command "$f='%GRADLE_FILE%'; (Get-Content $f) -replace \"^version = '.*'\", \"version = '%VERSION%'\" | Set-Content $f -Encoding UTF8"
if errorlevel 1 (
    echo Failed to update build.gradle
    exit /b 1
)

echo [2/4] Running go-build.bat
call go-build.bat
if errorlevel 1 (
    echo go-build.bat failed
    exit /b 1
)

echo [3/4] Staging changes
git add %GRADLE_FILE% go/
if errorlevel 1 exit /b 1

echo [4/4] Creating tag %TAG%
git tag %TAG%
if errorlevel 1 (
    echo Failed to create tag
    exit /b 1
)

echo.
echo Done. To publish:
echo   git push ^&^& git push origin %TAG%

endlocal
