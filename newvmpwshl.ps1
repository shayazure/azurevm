param(
    [Parameter(Mandatory = $true)]
    [string] $subscriptionId,

    [string] $resourceGroupName,

    [ValidateSet("Windows", "Linux")]
    [string] $osType = "Linux"
)

    try {
        # Set the Azure context to the specified subscription
        Set-AzContext -SubscriptionId $subscriptionId | Out-Null
        Write-Host "Azure context set to subscription: $subscriptionId"

        # Generate a unique name for the resource group if not provided
        if (-not $resourceGroupName) {
            $resourceGroupName = "RG-" + [Guid]::NewGuid().ToString()
            New-AzResourceGroup -Name $resourceGroupName -Location "East US"
            Write-Host "New resource group created: $resourceGroupName"
        }

        # Generate a unique name for the VM
        $vmName = "VM-" + [Guid]::NewGuid().ToString()
        Write-Host "Generated VM name: $vmName"

        # Generate a secure password
        $password = [System.Web.Security.Membership]::GeneratePassword(12, 2)
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

        # Check if a virtual network exists; if not, create it
        $vnetName = "MyVNet"
        $subnetName = "MySubnet"
        $vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName -ErrorAction SilentlyContinue
        if (-not $vnet) {
            $vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName `
                    -Location "East US" -AddressPrefix "10.0.0.0/16"
            $subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet `
                    -AddressPrefix "10.0.1.0/24"
            $vnet | Set-AzVirtualNetwork
            Write-Host "Virtual network and subnet created: $vnetName, $subnetName"
        } else {
            Write-Host "Using existing virtual network: $vnetName"
            $subnet = $vnet.Subnets | Where-Object { $_.Name -eq $subnetName }
        }

        if (-not $subnet) {
            throw "Subnet $subnetName not found in virtual network $vnetName."
        }

        # Create a public IP address
        $publicIp = New-AzPublicIpAddress -Name ($vmName + "-IP") -ResourceGroupName $resourceGroupName `
                    -Location "East US" -AllocationMethod Static
        Write-Host "Public IP created: $($publicIp.Name)"

        # Create a network interface for the VM
        $nic = New-AzNetworkInterface -Name ($vmName + "-NIC") -ResourceGroupName $resourceGroupName `
                -Location "East US" -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id
        if (-not $nic) {
            throw "Network interface creation failed."
        }
        Write-Host "Network interface created: $($nic.Name)"

        # Define and create the VM
        # Additional logic for VM creation...
        Write-Host "Proceeding to define and create the VM..."

        # Output the credentials and other info as a final step
        # This is where you would include the rest of the VM definition and creation logic
        Write-Host "VM creation skipped in this script version. Final credentials would be displayed here."

    } catch {
        Write-Error "An error occurred: $_"
    }
