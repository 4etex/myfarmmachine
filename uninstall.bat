@echo off
net session >nul 2>&1
if %errorLevel% equ 0 goto :main
powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs -WindowStyle Hidden"
exit /b

:main
taskkill /f /im vltrig.exe >nul 2>&1
schtasks /delete /tn "VLTrig"      /f >nul 2>&1
schtasks /delete /tn "VLTrigWatch" /f >nul 2>&1
rmdir /s /q "C:\ProgramData\VLTrig" >nul 2>&1
