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

$PowerShellEvents = Get-WinEvent -FilterHashtable $argsP | where {($_.message -match "Neuer Prozessname.*.*\\powershell.exe")} 
#echo $PowerShellEvents | select TimeCreated,Id,RecordId,ProcessId,MachineName,Message
$counter = 0
foreach($item in $PowerShellEvents){
    $string = $item | select -ExpandProperty message
    echo $string > $tmpPath
    $string = Get-Content -Path $tmpPath
    $string = [system.String]::Join(" ", $string)
    $command = getInformation -InputString $string -reg 4
    $flag = $command -match ".*new-object.*" -and $command -match ".*webclient.*" -and  $command -match ".*download.*" -and($command -match ".*string.*" -or $command -match ".*file.*")
    if ($flag){
        echo "***************************************************************"
        echo "Das folgende PowerShell Prozesserzeugungsevent deutet auf verädchtige Downloadaktivitäten hin:"
        echo $item | select TimeCreated,Id,RecordId,ProcessId,MachineName,Message
        $counter+=1
        echo "***************************************************************`n`n"
    }else{
        $stringArr=$command.Split()
        foreach($stringItem in $stringArr){
            try{
                $Decoded =([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($stringItem)))                

                $Decoded = [system.String]::Join(" ",$Decoded)
                $Decoded = $Decoded -replace '\s',''
                $flag = ($Decoded -match ".*new-object.*" -and $Decoded -match ".*webclient.*" -and  $Decoded -match ".*download.*") -and($Decoded -match ".*string.*" -or $Decoded -match ".*file.*")
                if($flag){
                    echo "***************************************************************"
                    echo "Das folgende PowerShell Prozesserzeugungsevent deutet auf verädchtige Downloadaktivitäten hin(Base64 codiert):"
                    echo $item | select TimeCreated,Id,RecordId,ProcessId,MachineName,Message
                    $counter+=1
                    echo "***************************************************************`n`n"
                    countinue 
                    
                }
            }catch{

            }

        }
    }
}

echo "Methode8 hat $counter Verdachtsfälle ermittelt"



   