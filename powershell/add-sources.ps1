$Path = "Q:\Work\Parish\Online Services"
$Sources = "D:\OneDrive - bcg design\Online Services"
Write-Host "Current path: $Path"

$Dirs = Get-ChildItem -Path "$Path" -Name -Directory ` | Where-Object {$_ -ne "Night Prayer"}
foreach ($D in $Dirs)
{
    $From = "$Path\$D"
    $To = "$Sources\$D"
    Write-Host "Creating link from $From\Sources to $To"
    New-Item -ItemType SymbolicLink -Path "$From" -Name "Sources" -Target "$To" -Force
}