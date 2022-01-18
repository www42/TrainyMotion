# Paul ist der zweite Benutzer nach dem AccountAdmin
# Paul erhält die Rolle Global Administrator

Import-Module -Name AzureAD                     # on WindowsPowershell
Import-Module -Name AzureAD.Standard.Preview    # on PowerShell 7

Connect-AzureAD
Get-AzureADDomain

# If connecting with a federated Microsoft account (outlook.com etc) you have to know the TenantId
#    $TenantId = 'dda1d48b-2865-4e24-a89a-c0ac16184484'
#    Connect-AzureAD -TenantId $TenantId
#    Get-AzureADDomain

$DomainName = ((Get-AzureAdTenantDetail).VerifiedDomains)[0].Name

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = 'Pa55w.rd1234'

$Paul = New-AzureADUser `
    -DisplayName 'Paul' `
    -UserPrincipalName "Paul@$DomainName" `
    -MailNickName 'Paul' `
    -UsageLocation 'DE' `
    -PasswordProfile $PasswordProfile `
    -AccountEnabled $true

#Remove-AzureADUser -ObjectId "Paul@$DomainName"

$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Add-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId -RefObjectId $Paul.ObjectId

Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId