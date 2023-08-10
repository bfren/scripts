$PackageId = Read-Host "Please enter the package you wish to unlist"
$ApiKey = "***"

$package = Find-Package $PackageId -AllVersions -AllowPrereleaseVersions -Source https://api.nuget.org/v3/index.json

foreach($version in $package.version)
{
  Write-Host "Unlisting $PackageId, Ver $version"
  Invoke-Expression "nuget delete $PackageId $version $ApiKey -source https://api.nuget.org/v3/index.json -NonInteractive"
}
