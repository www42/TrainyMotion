# ----------------------------------------------------------
# Azure Login
# ----------------------------------------------------------
Logout-AzAccount
Login-AzAccount

Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
$TenantId     = Get-AzSubscription | Where-Object State -EQ 'enabled' | % TenantId



# ----------------------------------------------------------
# AzureAD Login (Windows PowerShell 5.1 only)
# ----------------------------------------------------------
Disconnect-AzureAD
Connect-AzureAD

# If connecting with a federated Microsoft account (e.g. paul@outlook.com) you have to specify the Tenant Id
# Connect-AzureAD -TenantId $TenantId


Get-AzureADTenantDetail | Format-List DisplayName, `
    @{n="TenantId";e={$_.ObjectId}}, `
    @{n="VerifiedDomains";e={$_.VerifiedDomains.Name}} 


# ---------------------------------------------
# MSOnline Login  (Windows PowerShell 5.1 only)
# ---------------------------------------------
Connect-MsolService





# ----------------------------------------------------------
# Microsoft.Graph Login
# ----------------------------------------------------------
Get-MgProfile
Select-MgProfile -Name v1.0

# Minimal scopes (permissions)
Connect-MgGraph

Get-MgContext
Get-MgContext | % Scopes

# Scopes (= permissions) can be added cumulatively
$Scopes = @(
    "User.Read.All"
    "Group.Read.All"
)
Connect-MgGraph -Scopes $Scopes

# Find available scopes by object type e.g. user
Find-MgGraphPermission -SearchString user -PermissionType Delegated

# Find rquired scopes by Graph uri
Find-MgGraphCommand -Uri "/users"
Find-MgGraphCommand -Uri "/users"      -ApiVersion v1.0 -Method POST   | % Permissions
Find-MgGraphCommand -Uri "/users/{id}" -ApiVersion v1.0 -Method DELETE | % Permissions


Disconnect-MgGraph