@echo off
setlocal EnableExtensions
title ChildrenLearning Updater

set "REPO_URL=https://github.com/yichen914/ChildrenLearning.git"
set "BRANCH=main"
set "TARGET_DIR=%~dp0"
set "TEMP_DIR=%TEMP%\ChildrenLearning_Update_%RANDOM%_%RANDOM%"

rem Allow Git Credential Manager or the terminal to ask for a login if needed.
set "GIT_TERMINAL_PROMPT=1"
set "GCM_INTERACTIVE=always"

echo.
echo ============================================================
echo             CHILDREN LEARNING PROJECT UPDATER
echo ============================================================
echo.
echo The latest projects will be downloaded into:
echo   %TARGET_DIR%
echo.

where git >nul 2>&1
if errorlevel 1 goto :NO_GIT

echo Connecting to GitHub...
git clone --depth 1 --branch "%BRANCH%" "%REPO_URL%" "%TEMP_DIR%"
if errorlevel 1 goto :CLONE_FAILED

echo.
echo Updating project folders...
set "COPY_FAILED=0"

for /d %%D in ("%TEMP_DIR%\*") do (
    if /I not "%%~nxD"==".git" call :COPY_PROJECT "%%~fD" "%%~nxD"
)

if "%COPY_FAILED%"=="1" goto :COPY_ERROR

call :CLEAN_TEMP
echo.
echo ============================================================
echo  Update complete. All project folders are ready beside this
echo  updater. Extra personal files were kept for safety.
echo ============================================================
echo.
pause
exit /b 0

:COPY_PROJECT
echo   - %~2
robocopy "%~1" "%TARGET_DIR%%~2" /E /COPY:DAT /DCOPY:DAT /R:2 /W:1 /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
    echo     ERROR: Could not update this folder.
    set "COPY_FAILED=1"
)
exit /b 0

:CLEAN_TEMP
if not defined TEMP_DIR exit /b 0
if /I "%TEMP_DIR%"=="%TEMP%" exit /b 0
if exist "%TEMP_DIR%\.git" rmdir /s /q "%TEMP_DIR%"
exit /b 0

:NO_GIT
echo ERROR: Git for Windows is not installed or is not on PATH.
echo Install it from https://git-scm.com/download/win and run this file again.
echo.
pause
exit /b 1

:CLONE_FAILED
echo.
echo ERROR: The download from GitHub did not complete.
echo If GitHub asks you to sign in, finish the login and try again.
echo No existing project folders were changed.
echo.
pause
exit /b 1

:COPY_ERROR
call :CLEAN_TEMP
echo.
echo ERROR: At least one project folder could not be updated.
echo Check the messages above, then run this updater again.
echo.
pause
exit /b 1
