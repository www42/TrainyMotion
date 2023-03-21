# --------------------------------------------------------------------------
# Hybrid Identity
# This creates OnPrem AD users. Run this script on the domain controller vm.
# --------------------------------------------------------------------------
Import-Module -Name activedirectory
$Domain = Get-ADDomain | % forest
$OU = New-ADOrganizationalUnit -Name 'Classical Physics' -PassThru
$Group = New-ADGroup -Name 'Classical Physics' -DisplayName 'Classical Physics' -GroupScope Global -Path $OU.DistinguishedName -PassThru
$SecurePW = ConvertTo-SecureString -String 'Pa55w.rd1234' -AsPlainText -Force
$Names = @(
    'Isaac Newton'
    'Wilhem Leibniz'
    'Willy Wien'
    'Ludwig Boltzmann'
    'James Maxwell'
)
foreach ($Name in $Names) {
    $FirstName = $Name.Split(' ')[0] 
    $User = New-ADUser -Name $Name `
                       -UserPrincipalName "$FirstName@$Domain" `
                       -SamAccountName $FirstName `
                       -Path $OU.DistinguishedName `
                       -AccountPassword $SecurePW `
                       -PasswordNeverExpires $true `
                       -Enabled $true `
                       -PassThru
    Add-ADGroupMember -Members $User -Identity $Group 
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