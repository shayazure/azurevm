param(
    [string] $subscriptionId
)

function Get-SqlServers {
    # Authenticate if you haven't already
    # Connect-AzAccount

    # Set the context to the specific subscription, if provided
    if ($subscriptionId) {
        Write-Host "Setting context to subscription ID: $subscriptionId"
        Set-AzContext -SubscriptionId $subscriptionId | Out-Null
    }

    # Get the SQL servers for the current subscription context
    $sqlServers = Get-AzResourceGroup | Get-AzSqlServer
    if(!$sqlServers){
        Write-Output "No SQL Servers"
    }
    # Output the SQL server names and an indicator if a database exists
    $sqlServers | ForEach-Object {
        $serverName = $_.ServerName
        $databases = Get-AzSqlDatabase -ServerName $serverName -ResourceGroupName $_.ResourceGroupName
        $dbExistIndicator = if ($databases.Count -gt 1) { "Databases exist" } else { "No databases" }
        
        Write-Output "Server Name: $serverName - $dbExistIndicator"
    }
}

# Call the function
Get-SqlServers
