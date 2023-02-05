$scopes = @(
    "ManagedTenants.Read.All"
    "ManagedTenants.ReadWrite.All"
)
Connect-MgGraph -Scope $scopes 

Get-MgContext
Get-MgContext | % Scopes

Get-MgProfile

# Get-TenantDetailsFromGraph
Get-MgSecurityProviderTenantSetting


Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/me

Find-MgGraphCommand -Command Get-MgUser
Find-MgGraphCommand -Command Get-MgUser | Measure-Object
Find-MgGraphCommand -Command Get-MgUser | Select-Object -First 1 -ExpandProperty Permissions

Disconnect-MgGraph 