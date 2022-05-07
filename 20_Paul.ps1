# Paul - Admin account for daily work
# (Don't use the Account Admin for daily work.)
# -------------------------------------------------------------------------
# Paul --> Global Administrator --> Tenant
# Paul --> Owner                --> Subscription

$Domains = (Get-AzureAdTenantDetail).VerifiedDomains
$Domains | Format-Table Name,Initial,_Default

# $Domain = $Domains | Where-Object Initial -EQ $true | Select-Object -ExpandProperty Name
$Domain = 'trainymotion.com'

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = 'xxxxxxxxxxxxxx'
$PasswordProfile.ForceChangePasswordNextLogin = $false

$Params = @{
    DisplayName       = 'Paul'
    UserPrincipalName = "Paul@$Domain"
    MailNickName      = 'Paul'
    UsageLocation     = 'DE'
    PasswordProfile   = $PasswordProfile
    AccountEnabled    = $true
}
New-AzureADUser @Params

$Paul = Get-AzureADUser -ObjectId "Paul@$Domain"

#Remove-AzureADUser -ObjectId "Paul@$Domain"

# Tenant role Global Administrator
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Add-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId -RefObjectId $Paul.ObjectId
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

# Remove-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId -MemberId $Paul.ObjectId

# Subscription role Owner
$SubscriptionId = (Get-AzSubscription).Id
New-AzRoleAssignment -ObjectId $Paul.ObjectId -RoleDefinitionName 'Owner' -Scope "/subscriptions/$SubscriptionId"
Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" | Sort-Object RoleDefinitionName | Format-Table ObjectId,DisplayName,RoleDefinitionName

# Remove-AzRoleAssignment -ObjectId $Paul.ObjectId -RoleDefinitionName 'Owner' -Scope "/subscriptions/$SubscriptionId"