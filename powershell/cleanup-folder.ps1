Set-Variable -Name "path" -Value ""
Set-Variable -Name "days" -Value 28
Get-ChildItem -path "$path\*.*" `
	| Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$days)} `
	| Remove-Item