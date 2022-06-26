# Create OnPrem AD Users
# ----------------------
Import-Module -Name activedirectory
Get-ADComputer -Filter *
New-ADOrganizationalUnit -Name Production
$SecurePW = ConvertTo-SecureString -String 'Pa55w.rd1234' -AsPlainText -Force

for ($i = 1; $i -le 9; $i++)
{
    $Name = "Prod$i"
    New-ADUser -AccountPassword $SecurePW -UserPrincipalName "$Name@trainymotion.com" -Name $Name -PasswordNeverExpires $true -Path 'OU=Production,DC=trainymotion,DC=com' -Enabled $true
}


# Manage Sync
# ------------

# AzureAD Connect installs two PowerShell modules: ADSync and MSOnline
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