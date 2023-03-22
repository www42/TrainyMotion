# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This script removes the Azure AD user 'AzureAdSyncAdmin'
# ------------------------------------------------------------------------------------
# Requires Windows Powershell 5.1 (wegen AzureAD)

$syncUser = Get-AzureADUser -Filter "startswith(UserPrincipalName,'AzureAdSyncAdmin')"
Remove-AzureADUser -ObjectId $syncUser.ObjectId

# List all Global Administrators
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId
