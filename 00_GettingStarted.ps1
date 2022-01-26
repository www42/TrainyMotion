# Azure
Get-Module -ListAvailable -Name Az
Import-Module -Name Az
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription

# Tenant
#       Windows PowerShell
Get-Module -ListAvailable -Name AzureAD
Import-Module -Name AzureAD
#       PowerShell 7
Get-Module -ListAvailable -Name AzureAD.Standard.Preview
Import-Module -Name AzureAD.Standard.Preview

Connect-AzureAD
# If connecting with a federated Microsoft account (e.g. paul@outlook.com) you have to know the Tenant Id
#    $TenantId = 'dda1d48b-2865-4e24-a89a-c0ac16184484'
#    Connect-AzureAD -TenantId $TenantId

Get-AzureADTenantDetail | Format-List ObjectId,DisplayName,VerifiedDomains
