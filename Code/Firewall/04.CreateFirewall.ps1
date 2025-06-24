Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CreateVM.ps1"

$rgName = 'AzureTryOuts-Central-India'
$fwName = 'FW-VNet-Central-India'
$vnetName = 'VNet-Central-India'
$fwPiPName = 'PiP-FW-VNet-Central-India'


$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName
$pip = Get-AzPublicIpAddress -ResourceGroupName $rgName -Name $fwPiPName
New-AzFirewall -Name $fwName -ResourceGroupName $rgName -Location "CentralIndia" -VirtualNetwork $vnet -PublicIpAddress $pip -Zone $null
# $fwJob = New-AzFirewall -Name $fwName -ResourceGroupName $rgName -Location centralus -VirtualNetwork $vnet -PublicIpAddress $pip -Zone $null -AsJob

# Wait-ForJobs -Jobs @($fwJob) -DoNotRemoveJobs
