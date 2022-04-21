
$AppAdminRole           = Get-AzureADDirectoryRoleTemplate | Where-Object DisplayName -EQ "Application Administrator"
$AppAdminRoleDefinition = Get-AzureADMSRoleDefinition -Id $AppAdminRole.ObjectId
$AppAdminRoleDefinition | % RolePermissions | % AllowedResourceActions