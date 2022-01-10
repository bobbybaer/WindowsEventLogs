function getInformation{
        [CmdletBinding()]
        param(
        [Parameter()]
		[string] $InputString,
        $reg)
            
        if($reg -eq 1){
            $reg = [Regex]::new("(?<=ID des neuen Prozesses:)(.*)(?=Neuer Prozessname:)")
        }elseif($reg -eq 2){
            $reg = [Regex]::new("(?<=Neuer Prozessname:)(.*)(?=Tokenerhöhungstyp:)")
        }elseif($reg -eq 3){
             $reg =[Regex]::new("(?<=Erstellerprozess-ID:)(.*)(?=Erstellerprozessname:)")
        }elseif($reg -eq 4){
            $reg = [Regex]::new("(?<=Prozessbefehlszeile:)(.*)(?=Der Tokenerhöhungstyp gibt den Typ des Tokens an, das dem neuen Prozess gemäß der Benutzerkontensteuerungs-Richtlinie zugewiesen wurde.)")
        }

        
        $Match = $reg.Match($InputString)
         if($Match.Success)           
        {  
         $Value = $Match.Value.Trim()
        }
        $Value
}


$EventLogPath = "C:\Users\Bastian.BACHELOR\Documents\emotetImitationsDurchführung4.evtx"

$argsP = @{}
    $argsP.Add("ID", "4688")
    $argsP.Add("Path", $EventLogPath)

$EventsSeed = Get-WinEvent  -FilterHashtable $argsP |  where {($_.message -match "Erstellerprozessname.*.*\\WmiPrvSE.exe") -and ($_.message -match "Neuer Prozessname.*.*\\cmd.exe") -and  -not ($_.message -match "Neuer Prozessname.*null") } 
$EventsShells = Get-WinEvent -FilterHashtable $argsP |  where { ($_.message -match "Erstellerprozessname.*.*\\cmd.exe") -and (($_.message -match "Neuer Prozessname.*.*\\powershell.exe") -or ($_.message -match "Neuer Prozessname.*.*\\cmd.exe")) }
$count = 0
foreach($item in $EventsSeed){

    $string = $item | select -ExpandProperty message
    echo $string > $tmpPath
    $string = Get-Content -Path $tmpPath
    $string = [system.String]::Join(" ", $string)
    $SeedPID = getInformation -InputString $string -reg 1
    $SeedPPID = getInformation -InputString $string -reg 3
    $SeedCommand =getInformation -InputString $string -reg 4
    $pIds =@()
    $powerShells=@()
    $pIds += $SeedPID
    $flag = $true;
    while($flag){
        $flag = $false
        foreach($item2 in $EventsShells){
              $string2 = $item2 | select -ExpandProperty message
              echo $string2 > $tmpPath
              $string2 = Get-Content -Path $tmpPath
              $string2 = [system.String]::Join(" ", $string2)
              $ppID =  getInformation -InputString $string2 -reg 3
              if($pIDs.Contains($ppID)){
                $sID = getInformation -InputString $string2 -reg 1
                
                if(-not $pIDs.Contains($sID)){
                    $flag = $true
                    $pIds+=$sID
                
                    $shellName = getInformation -InputString $string2 -reg 2
                    if($shellName -match ".*.*\\powershell.exe"){
                        $powerShells+=$item2
                    }                
                }
              }
        }
    }
    if($powerShells.Count -gt 0){
        $count +=1
        $zeit = $item.TimeCreated.ToString()
        echo "**************************************************"
        echo "Die folgende WmiPrvSE Instanz hat über mindestens eine CMD.exe eine PowerShell Instanz erzeugt:"
        echo "Zeitpunkt: $zeit"
        echo "WmiPrvSE.exe ProzessID: $SeedPPID"
        echo "Prozessaufruf der ersten CMD: $SeedCommand"
        echo "Es resultierten die folgenden PowerShellaufrufe:"
        echo "--------------------------------------------------"
        foreach($item3 in $powerShells){
            $string3 = $item3 | select -ExpandProperty message
            echo $string3 > $tmpPath
            $string3 = Get-Content -Path $tmpPath
            $string3 = [system.String]::Join(" ", $string3)
            $ppID =  getInformation -InputString $string3 -reg 3
            $sID = getInformation -InputString $string3 -reg 1
            $shellCommand = $ppID =  getInformation -InputString $string3 -reg 4
            $zeit = $item3.TimeCreated.ToString()
            echo "Zeitpunkt: $zeit"
            echo "Ersteller ProzessID: $ppID"
            echo "ProzessID: $sID"
            echo "Prozessaufruf: $shellCommand"
            echo "--------------------------------------------------"
        }
         echo "**************************************************`n`n"
    }
}
echo "Methode3 hat  $count Verdachtsfälle gefunden" 