$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\CommonFunctions.ps1"


function New-VM {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [string]$LocationTag,

        [Parameter(Mandatory = $false)]
        [string] $VMNumberPrefix = "01",

        [Parameter(Mandatory = $true)]
        [string]$AddressSpaceInitialisers = "192.168", # Default address space for the VNet,

        [Parameter(Mandatory = $false)]
        [string]$SubnetName = "Subnet1", # Default Subnet for the VM

        [switch]$Windows = $false # If true, creates a Windows VM, otherwise creates a Linux VM


    )

    # Variables
    $resourceGroupName = "AzureTryOuts-$LocationTag"
    if ($Windows) {
        $osPrefix = "Win"
        $vmSize = "Standard_B2l_v2s"
    }
    else {
        $osPrefix = "Linux"
        $vmSize = "Standard_B1ls"
    }

    $vmName = "VM-$VMNumberPrefix-$osPrefix-$LocationTag"
    $computerName = $vmName
    if ($Windows) {
        $computerName = $vmName.Substring(0, [Math]::Min(15, $vmName.Length))
    }
    
    $vnetName = "VNet-$LocationTag"

    $publicIpName = "PiP-$vmName"
    $nicName = "Nic-$vmname"
    $username = "bhaleraor"
    $password = ConvertTo-SecureString "Pass@word1234$" -AsPlainText -Force

    Write-Host "Creating VM $vmName in location: $Location with tag: $LocationTag and VM number prefix: $VMNumberPrefix"

    New-ResourceGroup -Location $Location -LocationTag $LocationTag

    $vnet = New-Vnet -Location $Location -LocationTag $LocationTag -AddressSpaceInitialisers $AddressSpaceInitialisers


    Write-Host "Creating VM: $vmName in resource group: $resourceGroupName in location: $Location"

    # Get Virtual Network and Subnet
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

    # Create Public IP
    $publicIpJob = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location `
        -AllocationMethod Static -Sku Standard -AsJob

    # Wait for Public IP creation to complete
    Wait-ForJobs -Jobs @($publicIpJob) -DoNotRemoveJobs
    $publicIp = Receive-Job -Job $publicIpJob 
    Write-Host "Public IP created: $($publicIp.IpAddress)"
    # Create Network Interface
    $nicJob = New-AzNetworkInterface -Name $nicName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $publicIp.Id `
        -EnableAcceleratedNetworking:$false -AsJob

    # Wait for Public IP creation to complete
    Wait-ForJobs -Jobs @($nicJob) -DoNotRemoveJobs
    $nic = Receive-Job -Job $nicJob
    Write-Host "Nic card created: $($nic.Name)"

    # Configure VM
    # 1. Create base VM config
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

    # 2. Set the OS (Linux with username/password)
    $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
    if ($Windows) {
        $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
    }
    else {
        $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $computerName -Credential $cred -DisablePasswordAuthentication:$false        
    }


    # 3. Set the source image
    # $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "24_04-lts" -Version "latest"
    if ($Windows) {
        $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsDesktop" -Offer "windows-10" -Skus "win10-22h2-pro-g2" -Version "latest"
    }
    else {
        $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "ubuntu-24_04-lts" -Skus "server" -Version "latest"
    }


    # 4. Add network interface
    $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id -DeleteOption "Delete"


    # Create the VM
    # New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
    $vmJob = New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig -AsJob 
    Wait-ForJobs -Jobs @($vmJob) -DoNotRemoveJobs
    $vm = Receive-Job -Job $vmJob

    Write-Host "VM created: $($vm.Name)"
}

