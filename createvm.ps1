
param(
    [Parameter(Mandatory = $true)]
    [string] $subscriptionId,

    [Parameter(Mandatory = $true)]
    [string] $resourceGroupName,

    [ValidateSet("Windows", "Linux")]
    [string] $osType = "Linux",

    [string] $location = "East US"
)

function _validateLogin {
    $isUserConnected = Get-AzContext
    if (-not $isUserConnected) {
        try {
            $WarningPreference = 'SilentlyContinue'
            Connect-AzAccount | Out-Null 
            $WarningPreference = 'Continue'
            Write-Host "logged in"
    
        }
        catch {
            Write-Error "login error"
        }    
    }
}

function _setSubscription {
    try {
        # Set the Azure context to the specified subscription
        Set-AzContext -SubscriptionId $subscriptionId | Out-Null
        Write-Host "Azure context set to subscription: $subscriptionId"   
    }
    catch {
        Write-Error "set subscription error"
    }
}

function _setRG {
    try {
        # Check if the specified resource group exists
        $existingRG = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
        if (-not $existingRG) {
            New-AzResourceGroup -Name $resourceGroupName -Location $location | Out-Null
            Write-Host "Specified resource group does not exist. New resource group created: $resourceGroupName"
        }
        else {
            Write-Host "Using existing resource group: $resourceGroupName"
        }    
    }
    catch {
        Write-Error "set resource group error"
    }
    
}

try {
    _validateLogin
    _setSubscription
    _setRG

    # Generate a unique name for the VM
    $vmName = "vm-" + [Guid]::NewGuid().ToString("N").Substring(0, 12)

    Write-Host "Generated VM name: $vmName"

    # Generate a secure password
    $password = [System.Web.Security.Membership]::GeneratePassword(12, 2)
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

    # Create a public IP address
    $publicIp = New-AzPublicIpAddress -Name "ip-$vmName" -ResourceGroupName $resourceGroupName `
        -Location $location -AllocationMethod Static
    Write-Host "Public IP created: $($publicIp.Name)"

    $openPorts = if ($osType -eq "Linux") { @(22) } else { @(88, 3389) }
    $imageName = if ($osType -eq "Linux") { "Ubuntu2204" } else { "Win2019Datacenter" }

    $CreatedBy = [Environment]::UserName.toString()

    $vm = New-AzVM `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Name $vmName `
        -Credential $cred `
        -ImageName $imageName `
        -PublicIpAddressName $publicIp.Name `
        -OpenPorts $openPorts
    
    # Add Created By Tag
    $tags = @{CreatedBy = $CreatedBy }
    Update-AzTag -ResourceId $vm.Id -Tag $tags -Operation Merge

    Write-Host "done creating VM"
    Write-Output "azureuser"
    Write-Output $password
}
catch {
    Write-Error "An error occurred line 103"
}



