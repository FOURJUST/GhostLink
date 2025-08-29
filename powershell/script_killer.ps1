Add-Type @"
using System;
using System.Runtime.InteropServices;

public class BlockInputHelper {
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
}
"@

$blockDurationSeconds = 30

Write-Host "Toute action est inutile, j'ai l'emprise sur ton clavier et ta souris. pour $blockDurationSeconds" -ForegroundColor Red

[BlockInputHelper]::BlockInput($true)

try {
    Start-Sleep -Seconds $blockDurationSeconds
} finally {
    [BlockInputHelper]::BlockInput($false)
    Write-Host "Le clavier et la souris sont maintenant débloqués." -ForegroundColor Green
}