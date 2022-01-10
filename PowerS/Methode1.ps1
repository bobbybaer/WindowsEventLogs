$Array = Get-WinEvent -Path C:\Users\Bastian.BACHELOR\Documents\emotetImitationsDurchführung1.evtx | where {($_.ID -eq "4663" -and ($_.message -match "Objektname.*.*.docm" -or $_.message -match "Objektname.*.*.dotm" -or $_.message -match "Objektname.*.*.xlm" -or $_.message -match "Objektname.*.*.xlsm" -or $_.message -match "Objektname.*.*.xltm" -or $_.message -match "Objektname.*.*.xlam" -or $_.message -match "Objektname.*.*.ppam" -or $_.message -match "Objektname.*.*.pptm" -or $_.message -match "Objektname.*.*.potm" -or $_.message -match "Objektname.*.*.ppsm" -or $_.message -match "Objektname.*.*.sldm" -or $_.message -match "Objektname.*.*.docm:Zone.Identifier" -or $_.message -match "Objektname.*.*.dotm:Zone.Identifier" -or $_.message -match "Objektname.*.*.xlm:Zone.Identifier" -or $_.message -match "Objektname.*.*.xlsm:Zone.Identifier" -or $_.message -match "Objektname.*.*.xltm:Zone.Identifier" -or $_.message -match "Objektname.*.*.xlam:Zone.Identifier" -or $_.message -match "Objektname.*.*.ppam:Zone.Identifier" -or $_.message -match "Objektname.*.*.pptm:Zone.Identifier" -or $_.message -match "Objektname.*.*.potm:Zone.Identifier" -or $_.message -match "Objektname.*.*.ppsm:Zone.Identifier" -or $_.message -match "Objektname.*.*.sldm:Zone.Identifier")) } | select -ExpandProperty message
$RegexObject = [Regex]::new("(?<=File)(.*)(?=Handle)") 
$result =@()
foreach($item in $Array){
    echo $item > test17.txt
    $string = Get-Content test17.txt
    $Match = $RegexObject.Match($string)           
    if($Match.Success)           
    {   
       if(-Not $result.Contains($Match.Value))
       {        
        $result+=$Match.Value           
        }
    }
}
$ArrayC=$Array.Count
if($ArrayC -gt 0){
    $resultC=$result.Count

    $OutString = "Die Methode 1 hat insgesamt $ArrayC Einträge zu Dateien gefunden, welche potentiell VBA-Code enthalten.\n Diese Einträge bezogen sich auf die folgenden $resultC Dateipfade:"
    echo $Outstring
    $count = 1
    foreach($item in $result){
        echo "$count. $item"
        $count+=1
    }
}else{
    echo "Methode1 hat keine Angriffe detektiert"
}