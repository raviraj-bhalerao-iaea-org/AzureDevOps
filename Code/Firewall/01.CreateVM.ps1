Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CreateVM.ps1"

$Location = "CentralIndia"
$LocationTag = "Central-India"

$startTime = Get-Date
Write-Host "Script started at: $startTime for location: $Location with tag: $LocationTag"

# New-VM -Location $Location -LocationTag $LocationTag -AddressSpaceInitialisers "192.168" -Windows
New-VM -Location $Location -LocationTag $LocationTag -AddressSpaceInitialisers "192.168"
# New-VM -Location $Location -LocationTag $LocationTag -AddressSpaceInitialisers "192.168" -VMNumberPrefix "02"
# New-VM -Location $Location -LocationTag $LocationTag -AddressSpaceInitialisers "192.168" -VMNumberPrefix "03" -SubnetName "Subnet2"

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "Script started at: $startTime"
Write-Host "Script ended at:   $endTime"
Write-Host "Total time taken:  $($duration.ToString())"