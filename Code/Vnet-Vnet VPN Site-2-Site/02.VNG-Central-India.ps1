Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CreateVng.ps1"


New-Vng -Location "CentralIndia" -LocationTag "Central-India" -AddressSpaceInitialisers "192.168" -Asn "65002"