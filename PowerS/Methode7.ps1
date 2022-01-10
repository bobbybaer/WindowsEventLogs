$EventLogPath = "C:\Users\Bastian.BACHELOR\Documents\emotetImitationsDurchführung1.evtx"
$argsP = @{}
    $argsP.Add("ID", "4697")
    $argsP.Add("Path", $EventLogPath)

$Events = Get-WinEvent -FilterHashtable $argsP | where { ( $_.message -match "Dienstdateiname.*.*rundll32.*") } | select TimeCreated,Id,RecordId,ProcessId,MachineName,Message
$counter = 0 
foreach ($item in $Events){
$counter+=1
}
echo "**************************************"
echo "Die folgenden Services wurden hinzugefügt und scheinen rundll32.exe zu nutzen:"
echo $Events
echo "**************************************`n`n"
echo "Methode 7 hat $counter Verdachtsfälle ermittelt"