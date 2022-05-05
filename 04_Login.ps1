# Azure login
Logout-AzAccount
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId


# Azure AD login
# --------------
##       Windows: PowerShell 7
#Connect-AzureAD   # Does not work
# Could not load type 'System.Security.Cryptography.SHA256Cng' from assembly ...

##       Windows: Windows PowerShell
Connect-AzureAD


#   If connecting with a federated Microsoft account (e.g. paul@outlook.com) you have to know the Tenant Id
#      $TenantId = 'dda1d48b-2865-4e24-a89a-c0ac16184484'
#      Connect-AzureAD -TenantId $TenantId

Get-AzureADTenantDetail | Format-List ObjectId,DisplayName,VerifiedDomains
