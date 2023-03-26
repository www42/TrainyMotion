# ----------------------------------------------------------
# Microsoft.Graph Login
# ----------------------------------------------------------
Get-MgProfile
Select-MgProfile -Name v1.0


# Find available scopes by object type e.g. user
Find-MgGraphPermission -SearchString user -PermissionType Delegated

# Find rquired scopes by Graph uri
Find-MgGraphCommand -Uri "/users"
Find-MgGraphCommand -Uri "/users"      -ApiVersion v1.0 -Method POST   | % Permissions
Find-MgGraphCommand -Uri "/users/{id}" -ApiVersion v1.0 -Method DELETE | % Permissions


Disconnect-MgGraph