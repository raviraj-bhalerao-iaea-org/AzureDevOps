Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CreateVng.ps1"

$Location = "CentralIndia"
$LocationTag = "Central-India"

New-Vng -Location $Location -LocationTag $LocationTag -AddressSpaceInitialisers "192.168" -Asn "65002"
