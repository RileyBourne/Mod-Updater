@echo off

powershell -Command "if (Get-Module -ListAvailable -Name PS2EXE) {Write-Host "Module exists"} else {Write-Host "Module does not exist, downloading";Install-Module PS2EXE}; Invoke-PS2EXE updater.ps1 -title 'Mod Updater' -description 'Mod Updater' -version 1.0.0 -requireAdmin"

pause