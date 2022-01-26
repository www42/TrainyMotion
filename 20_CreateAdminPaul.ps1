# Paul - admin account for daily work (Don't use the Account Admin for daily work.)
# Paul --> Global Administrator tenant
# Paul --> Owner subscription

$DomainName = ((Get-AzureAdTenantDetail).VerifiedDomains)[0].Name

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = 'Pa55w.rd1234'

New-AzureADUser `
    -DisplayName 'Paul' `
    -UserPrincipalName "Paul@$DomainName" `
    -MailNickName 'Paul' `
    -UsageLocation 'DE' `
    -PasswordProfile $PasswordProfile `
    -AccountEnabled $true

$Paul = Get-AzureADUser -ObjectId "Paul@$DomainName"

#Remove-AzureADUser -ObjectId "Paul@$DomainName"

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