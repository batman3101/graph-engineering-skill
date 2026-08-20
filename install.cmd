@echo off
setlocal enabledelayedexpansion

rem ==== graph-engineering skill installer (Windows cmd) ====
rem Usage:
rem   install.cmd            -> global install (auto-detects Claude Code / Codex)
rem   install.cmd -g         -> same as above, explicit global
rem   install.cmd -p         -> install into current project folder only

set "REPO_USER=batman3101"
set "REPO_NAME=graph-engineering-skill"
set "BRANCH=main"
set "SKILL_DIR=graph-engineering"

set "ZIP_URL=https://github.com/%REPO_USER%/%REPO_NAME%/archive/refs/heads/%BRANCH%.zip"
set "TMP_DIR=%TEMP%\ge-install-%RANDOM%"

set "MODE=global"
if "%~1"=="-p" set "MODE=project"
if "%~1"=="--project" set "MODE=project"
if "%~1"=="-g" set "MODE=global"
if "%~1"=="--global" set "MODE=global"

echo.
echo [graph-engineering] Downloading skill from GitHub...
mkdir "%TMP_DIR%" >nul 2>&1
curl -fsSL "%ZIP_URL%" -o "%TMP_DIR%\repo.zip"
if errorlevel 1 (
  echo [ERROR] Download failed. Check your internet connection or REPO_USER/REPO_NAME in this script.
  exit /b 1
)

echo [graph-engineering] Extracting...
tar -xf "%TMP_DIR%\repo.zip" -C "%TMP_DIR%" >nul 2>&1
if errorlevel 1 (
  echo   tar failed, falling back to PowerShell Expand-Archive...
  powershell -NoProfile -Command "Expand-Archive -Path '%TMP_DIR%\repo.zip' -DestinationPath '%TMP_DIR%' -Force"
  if errorlevel 1 (
    echo [ERROR] Extraction failed via tar and PowerShell.
    exit /b 1
  )
)

set "SRC=%TMP_DIR%\%REPO_NAME%-%BRANCH%\%SKILL_DIR%"
if not exist "%SRC%" (
  echo [ERROR] Skill folder not found in downloaded repo: %SRC%
  exit /b 1
)

set "DID_INSTALL=0"

if "%MODE%"=="global" (
  echo [graph-engineering] Installing globally for %USERNAME%...

  where claude >nul 2>&1
  if not errorlevel 1 (
    xcopy /E /I /Y "%SRC%" "%USERPROFILE%\.claude\skills\%SKILL_DIR%" >nul
    echo   -^> Claude Code: %USERPROFILE%\.claude\skills\%SKILL_DIR%
    set "DID_INSTALL=1"
  )

  where codex >nul 2>&1
  if not errorlevel 1 (
    xcopy /E /I /Y "%SRC%" "%USERPROFILE%\.agents\skills\%SKILL_DIR%" >nul
    echo   -^> Codex: %USERPROFILE%\.agents\skills\%SKILL_DIR%
    set "DID_INSTALL=1"
  )

  if "!DID_INSTALL!"=="0" (
    echo   [!] Neither 'claude' nor 'codex' found in PATH.
    echo       Installing to both default locations anyway.
    xcopy /E /I /Y "%SRC%" "%USERPROFILE%\.claude\skills\%SKILL_DIR%" >nul
    xcopy /E /I /Y "%SRC%" "%USERPROFILE%\.agents\skills\%SKILL_DIR%" >nul
    echo   -^> %USERPROFILE%\.claude\skills\%SKILL_DIR%
    echo   -^> %USERPROFILE%\.agents\skills\%SKILL_DIR%
  )
) else (
  echo [graph-engineering] Installing into current project: %CD%
  xcopy /E /I /Y "%SRC%" "%CD%\.claude\skills\%SKILL_DIR%" >nul
  xcopy /E /I /Y "%SRC%" "%CD%\.agents\skills\%SKILL_DIR%" >nul
  echo   -^> %CD%\.claude\skills\%SKILL_DIR%
  echo   -^> %CD%\.agents\skills\%SKILL_DIR%
)

rmdir /s /q "%TMP_DIR%" >nul 2>&1

echo.
echo [graph-engineering] Install complete.
echo   Claude Code : type /graph-engineering
echo   Codex       : mention "graph-engineering skill" in your prompt
echo.

endlocal
