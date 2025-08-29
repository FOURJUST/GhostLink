Add-Type @"
using System;
using System.Runtime.InteropServices;

public class BlockInputHelper {
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
}
"@

# Durée du blocage en secondes
$blockDurationSeconds = 30

Write-Host "Le clavier et la souris seront bloqués pour $blockDurationSeconds secondes. Pour arrêter, fermez le programme dans le gestionnaire des tâches." -ForegroundColor Red

# Bloque le clavier et la souris
[BlockInputHelper]::BlockInput($true)

try {
    # Attend la durée spécifiée
    Start-Sleep -Seconds $blockDurationSeconds
} finally {
    # Débloque le clavier et la souris, peu importe ce qui se passe
    [BlockInputHelper]::BlockInput($false)
    Write-Host "Le clavier et la souris sont maintenant débloqués." -ForegroundColor Green
}