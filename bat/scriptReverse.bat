@ECHO OFF
SET Directory=%~dp0
SET ScriptPath="%Directory%scriptInteraction.ps1"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%ScriptPath%""' -Verb RunAs}"
