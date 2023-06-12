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
$role = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Application Administrator'"
$role.RolePermissions.AllowedResourceActions

$globalAdministrator = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Global Administrator'"

$user = Get-AzureADUser -Filter "userPrincipalName eq 'Wolfgang.Pauli@trainymotion.com'"
$paul = Get-AzureADUser -Filter "userPrincipalName eq 'Paul@trainymotion.com'"

# OData Filter
$globalAdministrator.Id
                                Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '62e90394-69f5-4237-9190-012177145e10'" # Works
                                Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$globalAdministrator.Id'"              # Does not work
$foo = $globalAdministrator.Id; Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$foo'"                                 # Works
                                Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$($globalAdministrator.Id)'"           # Works - magic!

New-AzureADMSRoleAssignment -RoleDefinitionId $role.Id -PrincipalId $user.ObjectId -DirectoryScopeId '/'

Get-AzureADMSRoleAssignment -Filter "principalId eq '$($user.ObjectId)'"
Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"
$foo = $Role.Id
Get-AzureADMSRoleAssignment -Filter "roleDefinitionId eq '$foo'"
Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId | ft DisplayName,UserType


Get-AzureADMSRoleAssignment | gm -MemberType Properties

# ------------------------
# Azure AD custom role
# ------------------------

# Reminder: Azure AD custom roles require premium license

$displayName = 'Foo App Support Admin'
$description = 'Can manage basic aspects of *Foo* application registrations.'
$templateId = (New-Guid).Guid
$allowedResourceActions = @(
    "microsoft.directory/applications/basic/update",
    "microsoft.directory/applications/credentials/update"
)
$rolePermissions = @{
    'AllowedResourceActions' = $allowedResourceActions
}
$resourceScropes = @(
    '/'
)

$customRole = New-AzureADMSRoleDefinition `
    -DisplayName $displayName `
    -Description $description `
    -TemplateId $templateId `
    -RolePermissions $rolePermissions `
    -ResourceScopes $resourceScropes `
    -IsEnabled $true 

# Get role assignments with fancy output
Get-AzureADMSRoleAssignment # This has no fancy output


Get-AzureADMSRoleAssignment | ForEach-Object {
    try {$userDisplayName = Get-AzureADUser -ObjectId $_.PrincipalId | % DisplayName}
    catch {$userDisplayName = '<not a user>'}
    $roleDisplayName = Get-AzureADMSRoleDefinition -Id $_.RoleDefinitionId | % DisplayName
    $userDisplayName,$roleDisplayName | Format-Table
}

Get-AzureADMSRoleAssignment | Measure-Object