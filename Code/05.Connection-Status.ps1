# Function to check connection status
function Wait-For-Connection {
    param (
        [string]$ResourceGroupName,
        [string]$ConnectionName
    )

    while ($true) {
        $connection = Get-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $ResourceGroupName
        $status = $connection.ConnectionStatus
        Write-Host "Connection '$ConnectionName' status: $status"

        if ($status -eq "Connected") {
            Write-Host "Connection '$ConnectionName' is now Connected."
            break
        }

        Start-Sleep -Seconds 10
    }
}

# Wait-ForVpnConnection -resourceGroupName "AzureTryOuts-West-Europe" -connectionName "West-Europe-2-Central-India"
# Wait-ForVpnConnection -resourceGroupName "AzureTryOuts-Central-India" -connectionName "Central-India-2-West-Europe"

# Error : 
# The connection cannot be established because the other VPN device is unreachable
# Detail
# If the on-premises VPN device is unreachable or not responding to the Azure VPN gateway IKE handshake, the VPN connection cannot establish
# Last run