$scopes = @(
    "ManagedTenants.Read.All"
    "ManagedTenants.ReadWrite.All"
)
Connect-MgGraph -Scope $scopes 
Get-MgContext

# Get-TenantDetailsFromGraph
Get-MgSecurityProviderTenantSetting