@echo off
setlocal enabledelayedexpansion
title Microsoft Defender Exclusion Tool

:: Automatically check and request Administrator rights
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%~dp0"
    set "currentDir=%~dp0"
    :: Remove trailing backslash for consistent comparison
    if "%currentDir:~-1%"=="\" set "currentDir=%currentDir:~0,-1%"

    :: Define ANSI Escape Codes
    for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
    set "Yellow=%ESC%[33m"
    set "Green=%ESC%[32m"
    set "Red=%ESC%[31m"
    set "Reset=%ESC%[0m"

:check_status
:: Refresh status by calling PowerShell and capturing output
set "isExcluded=false"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "$p=(Get-MpPreference).ExclusionPath; if($p -contains '%currentDir%'){'true'}else{'false'}"`) do (
    set "isExcluded=%%i"
)

:menu
cls
echo ====================================================
echo         MICROSOFT DEFENDER EXCLUSION TOOL
echo ====================================================
echo  Current Folder: %Yellow%"%currentDir%"%Reset%
echo.

if "!isExcluded!"=="true" (
    echo  Status: %Green%ALREADY EXCLUDED%Reset%
    echo.
    echo  1. Remove current folder from Exclusion list
) else (
    echo  Status: %Red%NOT EXCLUDED%Reset%
    echo.
    echo  1. Add current folder to Exclusion list
)
echo  2. Exit
echo ====================================================
set "choice="
set /p choice="Enter your choice (1-2): "

:: Exit if Enter is pressed or choice is 2
if "%choice%"=="" exit
if "%choice%"=="2" exit

if "%choice%"=="1" (
    cls
    echo.
    echo Exclusions
    echo.
    if "!isExcluded!"=="true" (
        echo [ACTION] Removing current folder from Microsoft Defender exclusions...
        echo.
        cmd /c "powershell -NoProfile -Command "Remove-MpPreference -ExclusionPath '%currentDir%'""
        echo [SUCCESS] Folder has been removed from the exclusion list.
    ) else (
        echo Add or remove items that you want to exclude from Microsoft Defender Antivirus scans.
        echo.
        echo [ACTION] Adding current folder to Microsoft Defender exclusions...
        echo.
        cmd /c "powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%currentDir%'""
        echo [SUCCESS] Folder has been added to the exclusion list.
    )
    
    echo.
    echo Done. Refreshing status...
    timeout /t 2 >nul
    goto check_status
)

:: Refresh menu if input is invalid
goto menu