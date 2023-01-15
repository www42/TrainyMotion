# Add System Assigned Managed Identity to VM
#
# https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-powershell-windows-vm

$vmName = 'ArcBox-Client'
$rgName = 'ArcBox-RG'

$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName

Update-AzVM -ResourceGroupName $rgName -VM $vm -IdentityType SystemAssigned

$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName
$vm | % Identity

Get-AzADServicePrincipal -DisplayName $vmName

# Remove System Assigned Managed Identity
Update-AzVM -ResourceGroupName $rgName -VM $vm -IdentityType None