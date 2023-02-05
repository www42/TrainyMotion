# MSAL
# -----------
Get-Help Get-MsalToken -Examples
$MsalToken = Get-MsalToken -ClientId '00000000-0000-0000-0000-000000000000' -Scope 'https://graph.microsoft.com/User.Read' # Does not work - ClientId needed
Invoke-RestMethod -Method Get -Uri 'https://graph.microsoft.com/v1.0/me' -Headers @{ Authorization = $MsalToken.CreateAuthorizationHeader() }

Get-MgContext


# https://tech.nicolonsky.ch/explaining-microsoft-graph-access-token-acquisition/