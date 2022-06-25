# ----------------------------------------
# Two steps
#   1) Self elevate to UAA
#   2) Assign role HSA at root scope 
#
#   UAA = User Access Administrator 
#   HSA = Hierarchy Settings Administrator
# ----------------------------------------

# Step 1)
# -------
# List Global Administrators - only a Global Administrator can self elevate to UAA
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

# See role definition UAA
Get-AzRoleDefinition -Name "User Access Administrator"

# Who is UAA (at Root level)?
Get-AzRoleAssignment | Where-Object {$_.RoleDefinitionName -eq "User Access Administrator" -and $_.Scope -eq "/"}

# Simple role assignement does not work ("Operation returned an invalid status code 'Forbidden'"
# New-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName 'User Access Administrator' -Scope '/'

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

Invoke-RestMethod @Params
# No response?!

# Remove role assignment is simple (Cleanup at the end of this file)
# Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "User Access Administrator" -Scope "/"





# Hierarchy Settings Administrator
# ----------------------------------
Get-AzRoleDefinition -Name "Hierarchy Settings Administrator" 

Get-AzRoleAssignment | Where-Object Scope -eq "/" | Format-Table SignInName,RoleDefinitionName

# Maybe logout and login again to Azure
New-AzRoleAssignment -SignInName "Paul@trainymotion.com" -Scope "/" -RoleDefinitionName "Hierarchy Settings Administrator"

# Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -Scope "/" -RoleDefinitionName "Hierarchy Settings Administrator"




# Management Groups
# -----------------
Get-AzManagementGroup | Format-Table Name,DisplayName,Id
# "Management Groups are not enabled in this tenant." --> Ignore

# Enterprise level
New-AzManagementGroup -DisplayName "Trainymotion" -GroupName (New-Guid)
$EnterpriseMgId = Get-AzManagementGroup | Where-Object DisplayName -EQ "Trainymotion" | % Name

# Top level
$TopLevelManagementGroups = @("Production","Testing","Development")
foreach ($Name in $TopLevelManagementGroups) {
    New-AzManagementGroup -DisplayName $Name `
                          -GroupName (New-Guid) `
                          -ParentId "/providers/Microsoft.Management/managementGroups/$EnterpriseMgId"
}


# It takes some time until the Management Groups appear
Get-AzManagementGroup | Format-Table Name,DisplayName,Id
$ProductionMgId  = Get-AzManagementGroup | Where-Object DisplayName -EQ "Production"  | % Name
$TestingMgId     = Get-AzManagementGroup | Where-Object DisplayName -EQ "Testing"     | % Name
$DevelopmentMgId = Get-AzManagementGroup | Where-Object DisplayName -EQ "Development" | % Name

# Second level (Parent "Production")
$SecondLevelManagementGroups = @("East","West","Central")
foreach ($Name in $SecondLevelManagementGroups) {
    New-AzManagementGroup -DisplayName $Name `
    -GroupName (New-Guid) `
    -ParentId "/providers/Microsoft.Management/managementGroups/$ProductionMgId"
}
$EastMgId    = Get-AzManagementGroup | Where-Object DisplayName -EQ "East"    | % Name
$WestMgId    = Get-AzManagementGroup | Where-Object DisplayName -EQ "West"    | % Name
$CentralMgId = Get-AzManagementGroup | Where-Object DisplayName -EQ "Central" | % Name


# Add subscription to management group
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
New-AzManagementGroupSubscription -SubscriptionId $Subscription -GroupName $CentralMgId


# Clean up role assignments
# -------------------------
Get-AzManagementGroup | Format-Table DisplayName,Name

Get-AzRoleAssignment | Sort-Object Scope | Format-Table DisplayName,RoleDefinitionName,Scope

# Remove Paul -- Owner -- East|West|Central
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/$EastMgId"
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/$WestMgId"
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/$CentralMgId"

# Remove Paul -- Owner -- Production|Testing|Development
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/$ProductionMgId"
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/$TestingMgId"
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/$DevelopmentMgId"

# Remove Paul -- Owner -- Enterprise
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/$EnterpriseMgId"

# Remove Paul--UserAccessAdministrator--Root
Remove-AzRoleAssignment -SignInName "Paul@trainymotion.com" -RoleDefinitionName "User Access Administrator" -Scope "/"

# Bleibt übrig:  
#   Paul -- Hierarchy Settings Administrator -- Root
#   Paul -- Owner -- Subscription
Get-AzRoleAssignment | Sort-Object Scope | Format-Table DisplayName,RoleDefinitionName,Scope