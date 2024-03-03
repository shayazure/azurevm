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

function _setSubscription {
    # Set the Azure context to the specified subscription
    Set-AzContext -SubscriptionId $subscriptionId | Out-Null
    Write-Host "Azure context set to subscription: $subscriptionId"
}
function Get-SqlServers {
    _login
    _setSubscription

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
