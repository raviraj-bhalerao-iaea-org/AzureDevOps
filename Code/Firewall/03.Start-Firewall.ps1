
$rgName = 'AzureTryOuts-Central-India'
$fwName = 'FW-VNet-Central-India'
$vnetName = 'VNet-Central-India'
$fwPiPName = 'FW-PiP-Central-India'
#Starting firewall 
$fw = Get-AzFirewall -ResourceGroupName $rgName -Name $fwName
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName
$ip = Get-AzPublicIpAddress -ResourceGroupName $rgName -Name $fwPiPName
# $manip = Get-AzPublicIpAddress -ResourceGroupName <RG-Name> -Name <Management-IP-Name>
# $fw.Allocate($vnet, $ip,$manip)
$fw.Allocate($vnet, @($ip))
# $fw.Allocate($vnet)
Set-AzFirewall -AzureFirewall $fw

