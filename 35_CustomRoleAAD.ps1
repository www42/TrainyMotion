
# Want to have a list of Azure AD roles, but only 3 roles appear
Get-AzureADDirectoryRole

# This is expected. Only roles with an active assignment appear in the list.
# If you want to use other roles (without active assignement) you have to enable this role
Get-AzureADDirectoryRoleTemplate | Sort-Object DisplayName | Format-Table DisplayName, Description
$Role = Get-AzureADDirectoryRoleTemplate | Where-Object DisplayName -EQ "Application Administrator" 
Enable-AzureADDirectoryRole -RoleTemplateId $Role.ObjectId

Get-AzureADDirectoryRole
$AppAdminRole = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Application Administrator'

Get-AzureADUser -All:$true
$Admin = Get-AzureADUser -All:$true | Where-Object DisplayName -EQ "MOD Administrator"

Get-AzureADUserOAuth2PermissionGrant -ObjectId $Admin.ObjectId
Get-AzureADUserOAuth2PermissionGrant -ObjectId $Admin.ObjectId | Where-Object ResourceId -EQ a4d00705-a19e-425e-b48f-629992629850 | Format-List *

Get-Command -Name Get-AzureADMSRoleDefinition
Get-AzureADMSRoleDefinition -ObjectId $AppAdminRole.ObjectId

$AppAdminRole           = Get-AzureADDirectoryRoleTemplate | Where-Object DisplayName -EQ "Application Administrator"
$AppAdminRoleDefinition = Get-AzureADMSRoleDefinition -Id $AppAdminRole.ObjectId
$AppAdminRoleDefinition | % RolePermissions | % AllowedResourceActions