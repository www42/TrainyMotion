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



# ----------------------------------------------------------
# Microsoft.Graph Login
# ----------------------------------------------------------
Connect-MgGraph
Connect-MgGraph -TenantId $tenantId

$scopes = @(
    "Directory.Read.All"
    "Group.Read.All"
    "Chat.Read.All"
)
Connect-MgGraph -Scope $scopes 
Get-MgProfile
Get-MgContext
Get-MgContext | % Scopes

Disconnect-MgGraph 

Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/me

Find-MgGraphCommand -Command Get-MgUser
Find-MgGraphCommand -Command Get-MgUser | Measure-Object
Find-MgGraphCommand -Command Get-MgUser | Select-Object -First 1 -ExpandProperty Permissions

# MSAL
# -----------
Get-Help Get-MsalToken -Examples
$MsalToken = Get-MsalToken -ClientId '00000000-0000-0000-0000-000000000000' -Scope 'https://graph.microsoft.com/User.Read' # Does not work - ClientId needed
Invoke-RestMethod -Method Get -Uri 'https://graph.microsoft.com/v1.0/me' -Headers @{ Authorization = $MsalToken.CreateAuthorizationHeader() }

Get-MgContext

# App registration
az ad app list
az ad app list --query "length([*])"
az ad app list --query "[*].{displayName:displayName,appId:appId}" --output table
$DisplayName = 'fooApp'
az ad app list --query "[?displayName=='$DisplayName'].{displayName:displayName,appId:appId}" --output table
$AppId = az ad app list --query "[?displayName=='$DisplayName'].appId" --output tsv

# https://tech.nicolonsky.ch/explaining-microsoft-graph-access-token-acquisition/