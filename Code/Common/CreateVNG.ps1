$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\CommonFunctions.ps1"

function New-Vng {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [string]$LocationTag,

        [Parameter(Mandatory = $true)]
        [string]$AddressSpaceInitialisers,

        [Parameter(Mandatory = $true)]
        [string]$Asn = "65001"


    )
    $startTime = Get-Date
    Write-Host "Script started at: $startTime"

    # Define variables with dynamic naming using LocationTag
    $resourceGroupName = "AzureTryOuts-$LocationTag"
    $vnetName = "VNet-$LocationTag"

    $gatewaySubnetName = "GatewaySubnet"
    $gatewaySubnetPrefix = "$AddressSpaceInitialisers.255.0/27"

    $gatewayPipName = "PiP-VNG-$LocationTag"
    $vngName = "VNG-$LocationTag"

    Write-Host "Script started at: $startTime"
    Write-host "Creating Virtual Network Gateway in location - $Location : location tag- $LocationTag : Address Prefix - $addressprefix : Gateway Subnet Prefix - $gatewaySubnetPrefix : ASN - $Asn"

    # Create the resource group
    New-ResourceGroup -Location $Location -LocationTag $LocationTag

    $vnet = New-Vnet -Location $Location -LocationTag $LocationTag -AddressSpaceInitialisers $AddressSpaceInitialisers

    # Check if GatewaySubnet already exists
    $gatewaySubnet = $vnet.Subnets | Where-Object { $_.Name -eq $gatewaySubnetName }

    if (-not $gatewaySubnet) {
        Write-Host "Adding GatewaySubnet to existing VNet '$vnetName'..."

        $gatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name $gatewaySubnetName -AddressPrefix $gatewaySubnetPrefix

        # Add the new subnet to the list of existing subnets
        $vnet.Subnets += $gatewaySubnet

        # Update the VNet with the new subnet
        Set-AzVirtualNetwork -VirtualNetwork $vnet

        Write-Host "GatewaySubnet added."

        Write-Host "Creating IP configuration for gateway with gateway subnet id ### - '$($gatewaySubnet.Id)' ..."

        $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
        $gatewaySubnet = $vnet.Subnets | Where-Object { $_.Name -eq $gatewaySubnetName }
    }
    else {
        Write-Host "GatewaySubnet already exists in VNet '$vnetName'."
    }

    Write-Host "Virtual network '$($vnet.Name)' created."
    Write-Host "Creating IP configuration for gateway with gateway subnet id - '$($gatewaySubnet.Id)' ..."

    # Create Public IP for Virtual Network Gateway
    Write-Host "Creating Public IP '$gatewayPipName'..."
    $gatewayPip = New-AzPublicIpAddress -Name $gatewayPipName `
        -ResourceGroupName $resourceGroupName `
        -Location $Location `
        -AllocationMethod Static `
        -Sku Standard `
        -IpAddressVersion IPv4 `
        -Zone @()

    #Create IP Configuration for the Gateway

    $gatewayIpConfig = New-AzVirtualNetworkGatewayIpConfig -Name "vnetGatewayIpConfig" `
        -SubnetId $gatewaySubnet.Id `
        -PublicIpAddressId $gatewayPip.Id

    # Create the Virtual Network Gateway
    Write-Host "Creating Virtual Network Gateway '$vngName'..."
    # Start creation as a job
    $job = New-AzVirtualNetworkGateway -Name $vngName `
        -ResourceGroupName $resourceGroupName `
        -Location $Location `
        -IpConfigurations $gatewayIpConfig `
        -GatewayType Vpn `
        -VpnType RouteBased `
        -EnableBgp:$true `
        -Asn $Asn `
        -GatewaySku VpnGw2 `
        -VpnGatewayGeneration Generation2 `
        -EnablePrivateIpAddress:$true `
        -EnableActiveActiveFeature:$false `
        -AsJob `
        -Verbose

    Wait-ForJobs -Jobs @($job) -DoNotRemoveJobs

    if ($job.JobStateInfo.State -eq 'Completed') {
        Write-Host "Virtual Network Gateway creation completed."
        # Receive the output — this will be the Virtual Network Gateway object(s)
        $vngObjects = Receive-Job -Job $job

        # Usually, there's only one object, so you can do:
        $vng = $vngObjects | Select-Object -First 1

        # Now $vng contains the created Virtual Network Gateway object
        Write-Host "VNG Name: $($vng.Name)"
        Write-Host "Provisioning State: $($vng.ProvisioningState)"


        Write-Host "Virtual Network Gateway '$vngName' created."

        # Check provisioning state
        $vngStatus = Get-AzVirtualNetworkGateway -Name $vngName -ResourceGroupName $resourceGroupName
        Write-Host "Provisioning state: $($vngStatus.ProvisioningState)"    

    }
    else {
        Write-Warning "Job ended with state: $($job.JobStateInfo.State)"
    }

    Remove-Job -Job $job

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host "Script started at: $startTime"
    Write-Host "Script ended at:   $endTime"
    Write-Host "Total time taken:  $($duration.ToString())"
}


function New-Vng-Connection {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location1,

        [Parameter(Mandatory = $true)]
        [string]$Location1Tag,

        [Parameter(Mandatory = $true)]
        [string]$Location2,

        [Parameter(Mandatory = $true)]
        [string]$Location2Tag
    )

    $rg1 = "AzureTryOuts-$Location1Tag"
    $rg2 = "AzureTryOuts-$Location2Tag"
    
    $vngName1 = "VNG-$Location1Tag"           
    $vngName2 = "VNG-$Location2Tag"     

    Write-host "Creating Virtual Network Gateways between $vngName1[$Location1] and $vngName2[$Location2] : '$Location1Tag-2-$Location2Tag' and '$Location2Tag-2-$Location1Tag'"
    
    $sharedKey = "ShreeRam@Test1234$"

    # Get existing Virtual Network Gateways
    $vng1 = Get-AzVirtualNetworkGateway -Name $vngName1 -ResourceGroupName $rg1
    $vng2 = Get-AzVirtualNetworkGateway -Name $vngName2 -ResourceGroupName $rg2

    #Start both connections in background
    $job1 = New-AzVirtualNetworkGatewayConnection -Name "$Location1Tag-2-$Location2Tag" `
        -ResourceGroupName $rg1 -Location $location1 `
        -VirtualNetworkGateway1 $vng1 -VirtualNetworkGateway2 $vng2 `
        -ConnectionType Vnet2Vnet -SharedKey $sharedKey `
        -EnableBgp:$true  `
        -AsJob

    $job2 = New-AzVirtualNetworkGatewayConnection -Name "$Location2Tag-2-$Location1Tag" `
        -ResourceGroupName $rg2 -Location $location2 `
        -VirtualNetworkGateway1 $vng2 -VirtualNetworkGateway2 $vng1 `
        -ConnectionType Vnet2Vnet -SharedKey $sharedKey `
        -EnableBgp:$true  `
        -AsJob    

    return @($job1, $job2)
}