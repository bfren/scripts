Set-Variable -Name "path" -Value ""
Set-Variable -Name "days" -Value 28
Get-ChildItem -path "$path\*.*" |? {$_.LastWriteTime -lt (Get-Date).AddDays(-$days)} | del