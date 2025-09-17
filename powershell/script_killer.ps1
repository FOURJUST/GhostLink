Add-Type @"
using System;
using System.Runtime.InteropServices;

public class BlockInputHelper {
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
}
"@
$blockDurationSeconds = 3

[BlockInputHelper]::BlockInput($true)

$isBlock = $true

while ($isBlock) {
    try {
    Start-Sleep -Seconds $blockDurationSeconds
    } finally {
        [BlockInputHelper]::BlockInput($true)
        $isBlock = $true
    }
}