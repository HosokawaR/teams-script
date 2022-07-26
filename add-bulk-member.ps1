$groupId = "<TeamsID>"
$csvPath = "<CSV のフルパス>"

Import-Csv -Path $csvPath | foreach {
    Write-Output $_.email;
    Add-TeamUser -GroupId $groupId -user $_.email;
    Write-Output "Done"; 
    Start-Sleep 10
}
