param(
    [string] $subscriptionId
)

function Get-StorageAccounts {
    # Authenticate if you haven't already
    # Connect-AzAccount

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
