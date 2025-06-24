Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CommonFunctions.ps1"

New-Vng -Location "WestEurope" -LocationTag "West-Europe" -AddressSpaceInitialisers "172.16" -Asn "65003"