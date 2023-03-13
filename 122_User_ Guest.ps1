# ------------------
# Invite Guest User
# ------------------
# Requires Windows PowerShell 5.1  (wegen Module 'AzureAD')

$displayName = 'Anton Zeilinger'
$emailAddress = 'Anton.Zeilinger@outlook.com'
$usageLocation = 'AT'

New-AzureADMSInvitation `
    -InvitedUserDisplayName $displayName `
    -InvitedUserEmailAddress $emailAddress `
    -SendInvitationMessage $true `
    -InviteRedirectUrl 'https://portal.azure.com' `
    -OutVariable user
    
# Start (private) browser, login, consent to permissions. Guest user will be redirected to Azure portal.
$user.InviteRedeemUrl

$objectId = $user.InvitedUser.Id
Get-AzureADUser -ObjectId $objectId | fl DisplayName,UserPrincipalName,UserType,UserState

# Optional:
#   Change domain suffix in UPN to 'trainymotion.com'
#   Set UsageLocation
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault
$domainName = Get-AzureADDomain | ? IsDefault -EQ $true | % Name
$upnOld = Get-AzureADUser -ObjectId $objectId | % UserPrincipalName
$upnNew = $upnOld.split('@')[0] + "@" + "$domainName"

Set-AzureADUser -ObjectId $objectId -UserPrincipalName $upnNew -UsageLocation $usageLocation