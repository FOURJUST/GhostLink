@echo off
set "SCRIPT=%~dp0scriptInterraction.ps1"

if not exist "%SCRIPT%" (
    echo Le fichier scriptInterraction.ps1 est introuvable dans le même dossier que ce fichier .bat.
    pause
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT%\"' -Verb RunAs"
