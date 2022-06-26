$Domains = (Get-AzureAdTenantDetail).VerifiedDomains
$Domains | Format-Table Name,Initial,_Default

# $Domain = $Domains | Where-Object Initial -EQ $true | Select-Object -ExpandProperty Name
$Domain = 'trainymotion.com'

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = 'xxxxxxxxxxxxxx'
$PasswordProfile.ForceChangePasswordNextLogin = $false

$Params = @{
    DisplayName       = 'Sync'
    UserPrincipalName = "Sync@$Domain"
    MailNickName      = 'Sync'
    UsageLocation     = 'DE'
    PasswordProfile   = $PasswordProfile
    AccountEnabled    = $true
}
$SyncUser = New-AzureADUser @Params

# Tenant role Global Administrator
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Add-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId -RefObjectId $SyncUser.ObjectId
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

# Remove-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId -MemberId $SyncUser.ObjectId
