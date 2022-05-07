# Azure login
# -----------
Logout-AzAccount
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
$TenantId     = Get-AzSubscription | Where-Object State -EQ 'enabled' | % TenantId


# Azure AD login
# --------------
Disconnect-AzureAD
Connect-AzureAD

# If connecting with a federated Microsoft account (e.g. paul@outlook.com) you have to specify the Tenant Id
# Connect-AzureAD -TenantId $TenantId


Get-AzureADTenantDetail | Format-List DisplayName, `
                                      @{n="TenantId";e={$_.ObjectId}}, `
                                      @{n="VerifiedDomains";e={$_.VerifiedDomains.Name}} 