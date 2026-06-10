@echo off
echo.
echo  Drift Clock - requesting administrator access...
echo  (Click "Yes" on the popup)
echo.
powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0install.ps1\"'"
