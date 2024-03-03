param(
    [string] $subscriptionId
)

function _login {
    $isUserConnected = Get-AzContext
    if (-not $isUserConnected) {
        try {
            $WarningPreference = 'SilentlyContinue'
            Connect-AzAccount | Out-Null 
            $WarningPreference = 'Continue'
            Write-Host "logged in"
    
        }
        catch {
            Write-Error "couldn't log in ,please try again"
        }    
    }
}

function Get-StorageAccounts {
    # Connect-AzAccount
    _login    

    # Set the context to the specific subscription, if provided
    if ($subscriptionId) {
        Write-Host "Setting context to subscription ID: $subscriptionId"
        Set-AzContext -SubscriptionId $subscriptionId | Out-Null
    }

    # Get the storage accounts for the current subscription context
    $storageAccounts = Get-AzStorageAccount

    # Output the storage account names
    $storageAccounts | ForEach-Object {
        Write-Output $_.StorageAccountName
    }
}

# Call the function
Get-StorageAccounts
