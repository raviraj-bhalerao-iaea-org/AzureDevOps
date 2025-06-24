$vng = Get-AzVirtualNetworkGateway -Name "VNG-East-US" -ResourceGroupName "AzureTryOuts"
Write-Host "$($vng.ProvisioningState)"

$vng = Get-AzVirtualNetworkGateway -Name "VNG-Central-India" -ResourceGroupName "AzureTryOuts-CentralIndia"
Write-Host "Central-India : $($vng.ProvisioningState)"