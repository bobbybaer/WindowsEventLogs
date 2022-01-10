$EventLogPath = "C:\Users\Bastian.BACHELOR\Documents\emotetImitationsDurchführung4.evtx"
$argsP = @{}
    $argsP.Add("ID", "4688")
    $argsP.Add("Path", $EventLogPath)

$argsH = @{}
    $argsH.Add("ID", "4663")
    $argsH.Add("Path", $EventLogPath)

$EventProcessCreation = Get-WinEvent -FilterHashtable $argsP | where {($_.message -match "Neuer Prozessname.*.*\\rundll32.exe") -and ($_.message -match "Prozessbefehlszeile.*.*\\Users\\.*")}
echo "*****************************************************"
echo "Durch ProcessCreation Events wurden die folgenden Zugriffe von rundll32.exe auf dll Dateien im Userverzeichnissen gefuden:"
echo $EventProcessCreation | select -ExpandProperty message
echo "*****************************************************`n`n"
echo "Durch ObjectZugriffs Events wurden die folgenden Zugriffe von rundll32.exe auf dll Dateien im Userverzeichnissen gefuden:"
$EventObjectAccess=Get-WinEvent -FilterHashtable $argsH | where {($_.message -match "Prozessname.*.*\\rundll32.exe") -and ($_.message -match "Objektname.*.*\\Users\\.*") } 
echo $EventObjectAccess | select -ExpandProperty message
echo "*****************************************************`n`n"
$c1 = $EventProcessCreation.Count
$c2 = $EventObjectAccess.Count

echo "Methode5 hat $c1 Verdachtsfälle durch ProcessCreationEvents und $c2 Verdachtsfälle durch Objektzugriffs Events ermittelt"