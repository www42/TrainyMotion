# This requires module 'AzureAD' (running on Windows PowerShell only).
# Module 'AzureAD.Standard.Preview' lacks the AzureADMS* cmdlets :-(
# Test:
Get-Command -Name Get-AzureADMSRoleDefinition

# Hint: Do not use 
#   Get-AzureADDirectoryRole
#   Get-AzureADDirectoryRoleTemplate


# -----------------------
# Azure AD built in roles
# -----------------------
Get-AzureADMSRoleDefinition | Sort-Object DisplayName | Format-Table DisplayName,Description
$Role = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Application Administrator'"
$Role.RolePermissions.AllowedResourceActions

$GlobalAdministrator = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Global Administrator'"

$User = Get-AzureADUser -Filter "userPrincipalName eq 'Wolfgang.Pauli@trainymotion.com'"
$Paul = Get-AzureADUser -Filter "userPrincipalName eq 'Paul@trainymotion.com'"

# OData Filter
$GlobalAdministrator.Id
                                Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '62e90394-69f5-4237-9190-012177145e10'" # Works
                                Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$GlobalAdministrator.Id'"              # Does not work
$foo = $GlobalAdministrator.Id; Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$foo'"                                 # Works
                                Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$($GlobalAdministrator.Id)'"           # Works - magic!

New-AzureADMSRoleAssignment -RoleDefinitionId $Role.Id -PrincipalId $User.ObjectId -DirectoryScopeId '/'

Get-AzureADMSRoleAssignment -Filter "principalId eq '$($User.ObjectId)'"
Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$($Role.Id)'"
$foo = $Role.Id
Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$foo'"
Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId | ft DisplayName,UserType




# ------------------------
# Azure AD custom in roles
# ------------------------

# Reminder: Azure AD custom roles require premium license
Get-AzureADMSRoleDefinition -Filter "displayName eq 'TM Foo Administrator'"