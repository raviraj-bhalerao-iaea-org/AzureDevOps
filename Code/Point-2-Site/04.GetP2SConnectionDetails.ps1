Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CommonFunctions.ps1"

$Location = "CentralIndia"
$LocationTag = "Central-India"

$startTime = Get-Date
Write-Host "Script started at: $startTime"

# Variables
$resourceGroupName = "AzureTryOuts-$LocationTag"
$gatewayName = "VNG-$LocationTag"
$rootCertFilePath = "$scriptPath\Certs\AzureP2SRootCert.pem"
$rootCertName = "AzureP2SRootCert"
$vpnClientAddressPool = "172.16.201.0/24"

Write-host "Configuring VNet Gateway P2S : $gatewayName in resource group: $resourceGroupName"


# # Read root cert public key Base64 content without headers
# $rootCertRawData = Get-Content -Path $rootCertFilePath -Raw
# $rootCertBase64 = ($rootCertRawData -replace '-----BEGIN CERTIFICATE-----', '') `
#     -replace '-----END CERTIFICATE-----', '' `
#     -replace '\s', ''
# write-host "Root certificate Base64 data read from file: $rootCertFilePath - "
# Write-Host "'$rootCertBase64'"

# Get the gateway object
$gateway = Get-AzVirtualNetworkGateway -Name $gatewayName -ResourceGroupName $resourceGroupName
#| Select-Object -Property VpnClientConfiguration
# Write-Host $($gateway)
# $gateway
$gateway | format-list *
# Write-Host $gateway.VpnClientConfiguration.VpnClientAddressPool.AddressPrefixes
# Write-Host "$($gateway.VpnClientConfiguration.VpnClientAddressPool.AddressPrefixes)"

# $addressSpace = New-Object -TypeName Microsoft.Azure.Commands.Network.Models.PSAddressSpace
# $addressSpace.AddressPrefixes = $vpnClientAddressPool
# $addressSpace | Format-List *


# # Update VpnClientConfiguration property manually
# $gateway.VpnClientConfiguration = New-Object -TypeName Microsoft.Azure.Commands.Network.Models.PSVpnClientConfiguration

# # Set the VPN client address pool
# $gateway.VpnClientConfiguration.VpnClientAddressPool = New-Object -TypeName Microsoft.Azure.Commands.Network.Models.PSAddressSpace
# $gateway.VpnClientConfiguration.VpnClientAddressPool.AddressPrefixes = $vpnClientAddressPool

# # Set the VPN client root certificate
# $rootCert = New-Object -TypeName Microsoft.Azure.Commands.Network.Models.PSVpnClientRootCertificate
# $rootCert.Name = $rootCertName
# $rootCert.PublicCertData = $rootCertBase64

# # Create the List<T> object
# $rootCertList = New-Object 'System.Collections.Generic.List[Microsoft.Azure.Commands.Network.Models.PSVpnClientRootCertificate]'

# # Add rootCert to list
# $rootCertList.Add($rootCert)

# # Assign the list to the gateway object
# $gateway.VpnClientConfiguration.VpnClientRootCertificates = $rootCertList

# # $gateway.VpnClientConfiguration.VpnClientRootCertificates  = @($rootCert)

# # Specify VPN client protocols: IKEv2 and OpenVPN
# $gateway.VpnClientConfiguration.VpnClientProtocols = @("IkeV2", "OpenVPN")


# Set-AzVirtualNetworkGateway -VirtualNetworkGateway $gateway

# # # Commit the update to Azure
# # $jobUpdateGateway = Set-AzVirtualNetworkGateway -VirtualNetworkGateway $gateway -AsJob

# # Wait-ForJobs -Jobs @($jobUpdateGateway)

# # $endTime = Get-Date
# # $duration = $endTime - $startTime

# # Write-Host "Script started at: $startTime"
# # Write-Host "Script ended at:   $endTime"
# # Write-Host "Total time taken:  $($duration.ToString())"
