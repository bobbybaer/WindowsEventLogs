$EventLogPath = "C:\Users\Bastian.BACHELOR\Documents\emotetImitationsDurchführung4.evtx"
$argsP = @{}
    $argsP.Add("ID", "4688")
    $argsP.Add("Path", $EventLogPath)

$Events= Get-WinEvent -FilterHashtable $argsP | where { ((($_.message -match "Neuer Prozessname.*.*\\rundll32.exe") -and ($_.message -match "Prozessbefehlszeile.*.*RunDLL" -or $_.message -match "Prozessbefehlszeile.*.*Control_RunDLL")) -and  -not (($_.message -match "Erstellerprozessname.*.*\\tracker.exe"))) } | select TimeCreated,Id,RecordId,ProcessId,MachineName,Message
$counter = $Events.Count
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Die folgenden Prozessaufrufe von rundll32.exe mit 'RunDLL' oder 'Control_RunDLL' wurden ermittelt:"
echo $Events
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++`n`n"
echo "Methode6 hat $counter Verdachtsfälle ermittelt"