# Exchange Online Login
# ======================
Disconnect-ExchangeOnline -Confirm:$false
Connect-ExchangeOnline -ShowBanner:$false



# Module Update
# =============
Get-Module -ListAvailable -Name ExchangeOnlineManagement
Find-Module -Name ExchangeOnlineManagement -Repository PSGallery -AllowPrerelease

# Update Windows: Run as Administrator(Windows Terminal) -> PowerShell 7          -> Update-Module -> exit
# Update Windows: Run as Administrator(Windows Terminal) -> WindowsPowerShell 5.1 -> Update-Module -> exit
# Update MacOS: Bash -> sudo pwsh -> Update-Module -> exit

Find-Module -Name ExchangeOnlineManagement -Repository PSGallery -AllowPrerelease | Update-Module -Scope AllUsers -Force
