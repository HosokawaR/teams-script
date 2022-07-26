$teamId = "<TeamsID>"
$csvPath = "<CSV のフルパス>"

Import-Csv -Path $csvPath | foreach {
    Write-Output $_.email;
    Add-TeamUser -GroupId $teamId -user $_.email;
    Write-Output "Done"; 
    Start-Sleep 10
}
