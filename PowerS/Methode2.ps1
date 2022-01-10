function getInformation{
        [CmdletBinding()]
        param(
        [Parameter()]
		[string] $InputString,
        $reg)
            
        if($reg -eq 1){
            $reg = [Regex]::new("(?<=Objektname:)(.*)(?=Name)")
        }elseif($reg -eq 2){
            $reg = [Regex]::new("(?<=Objektwerts:)(.*)(?=Handle)")
        }elseif($reg -eq 3){
             $reg =[Regex]::new("(?<=Erstellerprozessname:)(.*)(?=Prozessbefehlszeile:)")
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
$argsR = @{}
    $argsR.Add("ID", "4657")
    $argsR.Add("Path", $EventLogPath)
$argsP = @{}
    $argsP.Add("ID", "4688")
    $argsP.Add("Path", $EventLogPath)
$tmpPath =$env:Userprofile
$tmpPath +="\Documents\test123.txt"
$EventsRegister = Get-WinEvent  -FilterHashtable $argsR | where { ($_.message -match "Objektname.*.*\\Security\\Trusted Documents\\TrustRecords" -or $_.message -match "Objektname.*.*\\Security\\AccessVBOM" -or $_.message -match "Objektname.*.*\\Security\\VBAWarnings") } 
$EventsPowershell = Get-WinEvent -FilterHashtable $argsP | where {($_.message -match "Neuer Prozessname.*.*\\powershell.exe") }

$countR = $EventsRegister.Count
$countP = $EventsPowershell.Count
echo "Es wurden $countR Registerwertänderungen festgestellt"
echo "Es wurden $countP PowerShellerstellungen festgestellt"
echo "Beginne Ableich"
echo "--------------------"
echo "********************"
echo "--------------------`n `n `n "




    $incCount =0
foreach($item in $EventsRegister){
    $starttime = $item.TimeCreated 
    $endtime =$starttime.AddMinutes(5)
    $relevantEvents =@()
    foreach($item2 in $EventsPowershell)
    {
       if(($item2.TimeCreated -gt $starttime)-and($item2.TimeCreated -le $endtime)){
          $relevantEvents+=$item2
       }
    }
    if($relevantEvents.Count -gt 0){
            $incCount = $incCount +1
            $c =$relevantEvents.Count
            $string = $item | select -ExpandProperty message
            echo $string > $tmpPath
            $string = Get-Content -Path $tmpPath
            $string = [system.String]::Join(" ", $string)
            $zeit= $zeit = $item2.TimeCreated.toString()
            $verzeichnis = getInformation -InputString $string -reg 1
            
            $pfad = getInformation -InputString $string -reg 2
            echo "Die folgenden Office-Security Registereintragsänderungen (Makro aktivieren|Bearbeitung aktivieren) wurden beobachtet:"
            echo "Zeitpunkt: '$zeit'`nREGISTERVERZEICHNIS: '$verzeichnis' `nWERT:'$pfad' `n"
            echo "Anschließend wurden $c PowerShell-Instanzen mit den folgenden Daten  erstellt:"
            echo "********************************************************************************"
            foreach($item3 in $relevantEvents){
                $string = $item3 | select -ExpandProperty message
                echo $string > $tmpPath
                $string = Get-Content -Path $tmpPath
                $string = [system.String]::Join(" ", $string)
                $ersteller = getInformation -InputString $string -reg 3
                $command = getInformation -InputString $string -reg 4
                $zeit = $item3.TimeCreated.toString()
                echo "Zeitpunkt: $zeit `n"
                echo "Ersteller Prozessname: $ersteller `n"
                echo "Prozessbefehl: $command `n"
                echo "----------------------------------"
            }
        echo "********************************************************************************`n `n "
    }
    
}
echo "Methode 2 hat $incCount Verdachtsfälle gefunden"
 