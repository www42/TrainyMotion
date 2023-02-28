# At domain controller
# ---------------------
Install-Module -Name Az -Force

# PowerShell module 'AzFilesHybrid'
Start-Process https://github.com/Azure-Samples/azure-files-samples/releases
# download and extract to $folder 
$folder = 'C:\temp\AzFilesHybrid'
dir $folder -File | Unblock-File
cd $folder
Import-Module -Name AzFilesHybrid.psd1

Connect-AzAccount
$subscriptionId = (Get-AzContext).Subscription.Id
$storageAccountName = 'fs69118'
$ResourceGroupName = 'Storage-RG'
$Ou = 'OU=Theoretical Physics,DC=az,DC=training'

Join-AzStorageAccountForAuth `
   -ResourceGroupName $ResourceGroupName `
   -StorageAccountName $StorageAccountName `
   -DomainAccountType 'ComputerAccount' `
   -OrganizationalUnitDistinguishedName $Ou

# List computer accounts
Import-Module -Name activedirectory
Get-ADComputer