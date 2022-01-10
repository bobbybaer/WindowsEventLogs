
$EventLogPath = "C:\Users\Bastian.BACHELOR\Documents\emotetImitationsDurchführung4.evtx"
$argsP = @{}
    $argsP.Add("ID", "4688")
    $argsP.Add("Path", $EventLogPath)

$supEvents = Get-WinEvent -FilterHashtable $argsP | where {($_.message -match "Erstellerprozessname.*.*\\powershell.exe" -and ($_.message -match "Neuer Prozessname.*.*\\rundll32.exe")) } | select TimeCreated,Id,RecordId,ProcessId,MachineName,Message
$count = 0
foreach($item in $supEvents){ #.Count klappt nicht wenn es nur ein Event ist -.-
    $count +=1 
}
if ($count -gt 0){
    echo "Die folgenden Aufrufe von rundll32.exe aus einer PowerShell wurden aufgezeichnet:"
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo $supEvents
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++`n`n"
}
echo "Methode4 hat $count Verdachtsfälle ermittelt"