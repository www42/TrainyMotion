# Azure Login
# ===========
Logout-AzAccount
Login-AzAccount

Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
$TenantId     = Get-AzSubscription | Where-Object State -EQ 'enabled' | % TenantId



# Module Update / Uninstall 
# =========================

# PowerShell 7
# ------------
Get-Module -ListAvailable -Name Az
Find-Module -Name Az -Repository PSGallery

# Update MacOS: Bash -> sudo pwsh -> Update-Module -> exit
# Update Windows: Run as Administrator(Windows Terminal) -> PowerShell 7 -> Update-Module -> exit
Find-Module -Name Az -Repository PSGallery | Update-Module -Scope AllUsers -Force

Uninstall-Module -Name Az -RequiredVersion 7.3.2


# WindowsPowerShell 5.1
# ---------------------
# Get-Module -ListAvailable -Name Az     # Does not work
# 
# Die in WindowsPowerShell installierte Version wird angezeigt, 
# wenn man diesen Befehl unter PowerShell 7 laufen lässt.

# Update: Run as Administrator(Windows Terminal) -> WindowsPowerShell -> Update-Module -> exit
Find-Module -Name Az -Repository PSGallery | Update-Module -Scope AllUsers -Force

Uninstall-Module -Name Az -RequiredVersion 7.3.2
