# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This script removes the Azure AD user 'AzureAdSyncAdmin'
# ------------------------------------------------------------------------------------
# Requires Windows Powershell 5.1 (wegen AzureAD)

$syncUser = Get-AzureADUser -Filter "startswith(UserPrincipalName,'AzureAdSyncAdmin')"
Remove-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId -MemberId $syncUser.ObjectId
