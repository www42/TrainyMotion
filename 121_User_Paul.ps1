# ------------------------------------------------------------------------------------
# Azure AD User
# ------------------------------------------------------------------------------------
# Paul Drude - Admin account with custom domain name
# (Use this user for daily  work.)
#   Paul --> Global Administrator --> Tenant
#   Paul --> Owner                --> Subscription
# ------------------------------------------------------------------------------------

# Connect to Graph
# ----------------
Disconnect-MgGraph
$Scopes = @(
    "User.ReadWrite.All"
    "Group.ReadWrite.All"
    "RoleManagement.ReadWrite.Directory"
    "Directory.ReadWrite.All"
)
Connect-MgGraph -Scopes $Scopes
# May be you have to specify tenant id
$tenantId = '00a197a8-7b4d-4640-9689-01068da45596'
Connect-MgGraph -Scopes $Scopes -TenantId $tenantID

Get-MgContext | % Scopes

# Create user
# -----------
$tenantId = Get-MgContext | % TenantId
$domainName = Get-MgOrganization -OrganizationId $tenantId | % VerifiedDomains | ? IsDefault -EQ $true | % Name
$password = Read-Host -Prompt 'Password'
$passwordProfile = @{
    Password = $password
    ForceChangePasswordNextSignIn = $false
}
$params = @{
    GivenName = 'Paul'
    Surname = 'Drude'
    DisplayName = 'Paul Drude'
    UserPrincipalName = "Paul@$domainName"
    MailNickname = 'Adam'
    Country = 'Germany'
    City = 'Berlin'
    UsageLocation = 'DE'
    AccountEnabled = $true
    PasswordProfile = $passwordProfile
}
$user = New-MgUser @params

# Assign P2 License
# -----------------
$P2Sku = Get-MgSubscribedSku -All | ? SkuPartNumber -EQ 'AAD_PREMIUM_P2'
Set-MgUserLicense -UserId $user.Id -AddLicenses @{SkuId = $P2Sku.SkuId} -RemoveLicenses @()


# Assign Global Administrator role
# --------------------------------
$globalAdministratorId = Get-MgDirectoryRole -All | ? DisplayName -eq 'Global Administrator' | % Id
$userId = $user.Id
$params = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$userId"
}
New-MgDirectoryRoleMemberByRef -DirectoryRoleId $globalAdministratorId -BodyParameter $params


# Assign Owner role to subscription
# ---------------------------------
$SubscriptionId = (Get-AzSubscription).Id
New-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionName 'Owner' -Scope "/subscriptions/$SubscriptionId"
Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" | Sort-Object RoleDefinitionName | Format-Table ObjectId,DisplayName,RoleDefinitionName




# Cleanup
# --------
$user = Get-MgUser | ? UserPrincipalName -EQ "Adam@$domainName"
$SubscriptionId = (Get-AzSubscription).Id
Remove-AzRoleAssignment -ObjectId $user.Id -Scope "/subscriptions/$SubscriptionId" -RoleDefinitionName 'Owner'
Remove-MgUser -UserId $user.Id


