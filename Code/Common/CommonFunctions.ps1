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
function New-ResourceGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [string]$LocationTag
    )
    $resourceGroupName = "AzureTryOuts-$LocationTag"
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

    if (-not $resourceGroup) {
        Write-Host "Creating resource group '$resourceGroupName' in location '$Location'..."
        $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $Location
        Write-Host "Resource group '$($resourceGroup.ResourceGroupName)' created."
    }
    else {
        Write-Host "Resource group '$resourceGroupName' already exists in location '$($resourceGroup.Location)'."
    }

    return $resourceGroup

}
function New-Nsg {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [string]$LocationTag,

        [Parameter(Mandatory = $false)]
        [string]$AddressSpaceInitial
    )

    $resourceGroupName = "AzureTryOuts-$LocationTag"

    $nsgName = "NSG-$LocationTag"
    # Create a Network Security Group for remote access
    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $nsgName
    
    # Add inbound SSH rule (port 22)
    Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg `
        -Name "Allow-SSH" `
        -Protocol "Tcp" `
        -Direction "Inbound" `
        -Priority 1000 `
        -SourceAddressPrefix "*" `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange 22 `
        -Access "Allow" | Out-Null
    # Add inbound RDP rule (port 3389)
    Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg `
        -Name "Allow-RDP" `
        -Protocol "Tcp" `
        -Direction "Inbound" `
        -Priority 1010 `
        -SourceAddressPrefix "*" `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange 3389 `
        -Access "Allow" | Out-Null
    # Apply the rules to the NSG
    $nsgJob = Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg -AsJob
    Wait-ForJobs -Jobs @($nsgJob) -DoNotRemoveJobs
    $nsg = Receive-Job -Job $nsgJob
    Write-Host "Network Security Group '$($nsg.Name)' created with inbound rules for SSH and RDP."
    return $nsg
}
function New-Vnet {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [string]$LocationTag,

        [Parameter(Mandatory = $true)]
        [string]$AddressSpaceInitialisers
    )
    $vnetName = "VNet-$LocationTag"
    $addressPrefix = "$AddressSpaceInitialisers.0.0/16"

    $subnet1Name = "Subnet1"
    $subnet1Prefix = "$AddressSpaceInitialisers.1.0/24"

    $subnet2Name = "Subnet2"
    $subnet2Prefix = "$AddressSpaceInitialisers.2.0/24"

    # Check if the VNet already exists
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue

    if (-not $vnet) {
        Write-Host "Creating new VNet '$vnetName' with subnets..."

        $nsg = New-Nsg -Location $Location -LocationTag $LocationTag -AddressSpaceInitial $AddressSpaceInitialisers

        $subnet1 = New-AzVirtualNetworkSubnetConfig -Name $subnet1Name -AddressPrefix $subnet1Prefix -NetworkSecurityGroup $nsg
        $subnet2 = New-AzVirtualNetworkSubnetConfig -Name $subnet2Name -AddressPrefix $subnet2Prefix -NetworkSecurityGroup $nsg
        # $gatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name $gatewaySubnetName -AddressPrefix $gatewaySubnetPrefix

        $vnet = New-AzVirtualNetwork -Name $vnetName `
            -ResourceGroupName $resourceGroupName `
            -Location $Location `
            -AddressPrefix $addressPrefix `
            -Subnet $subnet1, $subnet2
        # , $gatewaySubnet

        Write-Host "VNet '$vnetName' created with all subnets; NSG attached to the Subnets."
    }
    else {
        Write-Host "VNet '$vnetName' already exists. Skipping creation."
    }
    return $vnet
}

function IsJobCompleted {
    param([string]$JobState)
    return $JobState -eq 'Completed' -or $JobState -eq 'Failed' -or $JobState -eq 'Stopped'
}

function Wait-ForJobs {
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Job[]]$Jobs,
        
        [int]$DelaySeconds = 10,

        [switch]$DoNotRemoveJobs
    )

    # Simple check for completed states

    while ($true) {
        $statuses = @()
        foreach ($job in $Jobs) {
            # Use Get-Job to get fresh state each time
            $currentJob = Get-Job -Id $job.Id
            $state = if ($currentJob) { $currentJob.State.ToString() } else { 'Unknown' }
            $statuses += "[$($job.Name)]: $state"
        }

        Write-Host "$(Get-Date -Format 'HH:mm:ss') - $($statuses -join ' | ')"

        $allCompleted = $true
        foreach ($job in $Jobs) {
            $currentJob = Get-Job -Id $job.Id
            $state = if ($currentJob) { $currentJob.State.ToString() } else { 'Unknown' }
            if (-not (IsJobCompleted -JobState $state)) {
                $allCompleted = $false
                break
            }
        }

        if ($allCompleted) {
            Write-Host "All jobs completed."


            # Check for failed jobs
            $failedJobs = @()
            foreach ($job in $Jobs) {
                $currentJob = Get-Job -Id $job.Id
                if ($currentJob.State -eq 'Failed') {
                    $reason = $currentJob.ChildJobs[0].JobStateInfo.Reason
                    $failedJobs += [PSCustomObject]@{
                        Name   = $job.Name
                        Reason = $reason
                    }
                }
            }

            if ($failedJobs.Count -gt 0) {
                foreach ($failedJob in $failedJobs) {
                    Write-Error "Job '$($failedJob.Name)' failed: '$($failedJob.Reason)'"
                }

                throw "One or more jobs failed. See error messages above."
            }

            if (-not $DoNotRemoveJobs) {
                Write-Host "Removing completed jobs..."
                foreach ($job in $Jobs) {
                    Remove-Job -Job $job -Force
                }
            }
            break
        }

        Start-Sleep -Seconds $DelaySeconds
    }
}
