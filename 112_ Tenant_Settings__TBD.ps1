# ----------------------------------
# Tenant
#    --> Disable Security Defaults
# ----------------------------------

$scopes = @(
    "ManagedTenants.Read.All"
    "ManagedTenants.ReadWrite.All"
)
Connect-MgGraph -Scope $scopes 

Get-MgContext
Get-MgContext | % Scopes


#  GET /policies/identitySecurityDefaultsEnforcementPolicy
