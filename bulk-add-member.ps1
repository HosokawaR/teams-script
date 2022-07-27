$groupId = "<GroupID>"
$csvPath = "<CSV のパス>"

Connect-MicrosoftTeams
Import-Csv -Path $csvPath | ForEach-Object {
    Add-TeamUser -GroupId $groupId -user $_.email;
    Write-Output "Added $($_.email)"; 
    Start-Sleep 10;
}
