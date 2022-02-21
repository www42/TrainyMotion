# Azure login
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | Select-Object -ExpandProperty SubscriptionId


# Azure AD login
Connect-AzureAD
#   If connecting with a federated Microsoft account (e.g. paul@outlook.com) you have to know the Tenant Id
#      $TenantId = 'dda1d48b-2865-4e24-a89a-c0ac16184484'
#      Connect-AzureAD -TenantId $TenantId

Get-AzureADTenantDetail | Format-List ObjectId,DisplayName,VerifiedDomains
