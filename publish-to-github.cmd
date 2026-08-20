@echo off
setlocal enabledelayedexpansion

rem ==== One-shot GitHub publisher for the graph-engineering skill ====
rem Creates a PUBLIC repo, rewrites the placeholder username in the
rem installers and README, commits, and pushes.
rem
rem Requires: git, gh (GitHub CLI). Install gh: winget install GitHub.cli

set "REPO_NAME=graph-engineering-skill"

echo.
echo === graph-engineering skill : GitHub publisher ===
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] git not found. Install: winget install Git.Git
  exit /b 1
)

where gh >nul 2>&1
if errorlevel 1 (
  echo [ERROR] GitHub CLI not found. Install: winget install GitHub.cli
  echo         Then run: gh auth login
  exit /b 1
)

gh auth status >nul 2>&1
if errorlevel 1 (
  echo [INFO] Not logged in to GitHub. Starting login...
  gh auth login
  if errorlevel 1 exit /b 1
)

rem --- resolve the GitHub username automatically ---
for /f "delims=" %%u in ('gh api user --jq .login') do set "GH_USER=%%u"
if "%GH_USER%"=="" (
  echo [ERROR] Could not resolve your GitHub username.
  exit /b 1
)
echo [INFO] GitHub user: %GH_USER%
echo [INFO] Repo to create: %GH_USER%/%REPO_NAME% (public)
echo.

rem --- replace the placeholder username in installers and README ---
rem NOTE: Get-Content/Set-Content must be forced to UTF-8. Windows PowerShell 5.1
rem defaults to the ANSI codepage (e.g. CP949 on Korean Windows), which corrupts
rem non-ASCII text. We use .NET UTF8 APIs so this is safe on every locale.
echo [INFO] Rewriting placeholders...
powershell -NoProfile -Command ^
  "$u='%GH_USER%';" ^
  "$enc = New-Object System.Text.UTF8Encoding($false);" ^
  "foreach ($f in @('install.cmd','install.sh','README.md')) {" ^
  "  if (Test-Path $f) {" ^
  "    $p = (Resolve-Path $f).Path;" ^
  "    $c = [System.IO.File]::ReadAllText($p, $enc);" ^
  "    $c = $c -replace 'YOUR_GITHUB_USERNAME', $u;" ^
  "    $c = $c -replace 'https://raw\.githubusercontent\.com/USER/', ('https://raw.githubusercontent.com/' + $u + '/');" ^
  "    $c = $c -replace 'https://github\.com/USER/', ('https://github.com/' + $u + '/');" ^
  "    [System.IO.File]::WriteAllText($p, $c, $enc);" ^
  "  }" ^
  "}"

rem --- init and push ---
if not exist ".git" (
  git init -q
)
git add -A
git -c user.useConfigOnly=false commit -q -m "graph-engineering skill v4" 2>nul
git branch -M main

gh repo view "%GH_USER%/%REPO_NAME%" >nul 2>&1
if errorlevel 1 (
  echo [INFO] Creating public repository...
  gh repo create "%REPO_NAME%" --public --source=. --remote=origin --push
  if errorlevel 1 (
    echo [ERROR] Repository creation failed.
    exit /b 1
  )
) else (
  echo [INFO] Repository already exists. Pushing...
  git remote remove origin >nul 2>&1
  git remote add origin "https://github.com/%GH_USER%/%REPO_NAME%.git"
  git push -u origin main --force
)

echo.
echo === Done ===
echo Repo : https://github.com/%GH_USER%/%REPO_NAME%
echo.
echo Anyone can now install with one line:
echo.
echo   curl -fsSL https://raw.githubusercontent.com/%GH_USER%/%REPO_NAME%/main/install.cmd -o "%%TEMP%%\ge-install.cmd" ^&^& "%%TEMP%%\ge-install.cmd"
echo.

endlocal
