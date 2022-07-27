$groupId = "<GroupID>"     # ex) 00000000-0000-0000-0000-000000000000
$csvPath = "<CSV のパス>"   # ex) .\emails.csv

Connect-MicrosoftTeams
Import-Csv -Path $csvPath | ForEach-Object {
    Add-TeamUser -GroupId $groupId -User $_.email;
    Write-Output "Added $($_.email)"; 
    Start-Sleep 10;
}
