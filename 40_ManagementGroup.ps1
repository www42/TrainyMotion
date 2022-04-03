# User Access Administrator (UAA)
# -------------------------------

# List Global Administrators - only a Global Administrator can self elevate to UAA
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

# See role definition UAA
Get-AzRoleDefinition -Name 'User Access Administrator'

# Who is UAA (at Root level)?
Get-AzRoleAssignment | Where-Object {$_.RoleDefinitionName -eq "User Access Administrator" -and $_.Scope -eq "/"}

# Simple role assignement does not work ("Operation returned an invalid status code 'Forbidden'"
New-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName 'User Access Administrator' -Scope '/'

# Instead: Self elevate by API call
$Method = 'POST'
$Uri = 'https://management.azure.com/providers/Microsoft.Authorization/elevateAccess?api-version=2015-07-01'
$Token = Get-AzAccessToken | % Token
$Headers = @{"authorization" = "Bearer $Token"}
$Body = ''

$Params = @{
    Method  = $Method
    Uri     = $Uri
    Headers = $Headers
    Body    = $Body
    ContentType = "application/json"
}

$Response = Invoke-RestMethod @Params
$Response.value  # No response?!

# Remove role assignment is simple
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "User Access Administrator" -Scope "/"





# Hierarchy Settings Administrator (HSA)
# --------------------------------------
Get-AzRoleDefinition -Name "Hierarchy Settings Administrator" 

Get-AzRoleAssignment | Where-Object Scope -eq "/"
New-AzRoleAssignment -SignInName "Paul@trainymotion.com" -Scope "/" -RoleDefinitionName "Hierarchy Settings Administrator"





# Management Groups
# -----------------
Get-AzManagementGroup | Format-Table DisplayName,Name

# Top level
$TopLevelManagementGroups = @("Production","Testing","Development")
foreach ($Name in $TopLevelManagementGroups) {
    New-AzManagementGroup -DisplayName $Name -GroupName (New-Guid)
}

# Second level (Parent "Production")
$ProductionMgId = Get-AzManagementGroup | Where-Object DisplayName -EQ "Production" | % Name

$SecondLevelManagementGroups = @("East","West","Central")
foreach ($Name in $SecondLevelManagementGroups) {
    New-AzManagementGroup -DisplayName $Name -GroupName (New-Guid) -ParentId "/providers/Microsoft.Management/managementGroups/$ProductionMgId"
}



# Add subscription to management group
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
$WestMgId = Get-AzManagementGroup | Where-Object DisplayName -EQ "West" | % Name

New-AzManagementGroupSubscription -SubscriptionId $Subscription -GroupName $WestMgId


# Clean up role assignments
Get-AzManagementGroup | Format-Table Id,DisplayName
Get-AzRoleAssignment | Sort-Object Scope | Format-Table DisplayName,RoleDefinitionName,Scope