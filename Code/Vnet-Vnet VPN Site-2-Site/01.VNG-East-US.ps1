Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CreateVng.ps1"

New-Vng -Location "EastUs" -LocationTag "East-Us" -AddressSpaceInitialisers "10.0" -Asn "65001"
