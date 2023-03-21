# ------------------------------------------------------------------------------------
# Hybrid Identity
# ------------------------------------------------------------------------------------
# Manage Sync
# Run this script on the domain controller VM.
# ------------------------------------------------------------------------------------

# AzureAD Connect installs both ADSync and MSOnline modules
#
#   ADSync --> Connectors, Scheduler, SyncCycl etc
#   ------
Import-Module -Name "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"
Get-Module -Name ADSync

Get-ADSyncAADCompanyFeature
Get-ADSyncConnector | ft Name,Type
Get-ADSyncScheduler
Start-ADSyncSyncCycle -PolicyType Delta

#   MSOnline --> Stop Sync
#   --------
Get-Module -Name MSOnline -ListAvailable
#   AzureAD Connect setup puts it on strange place:
Import-Module -Name "C:\Program Files\Microsoft Azure Active Directory Connect\AADPowerShell\MSOnline.psd1"

Connect-MsolService
Set-MsolDirSyncEnabled -EnableDirSync $false -Force
Get-MsolCompanyInformation | fl DirectorySynchronizationEnabled,LastDirSyncTime,LastPasswordSyncTime
