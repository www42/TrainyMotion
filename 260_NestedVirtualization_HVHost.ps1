# ------------------------------------------------------------------------------------
# Scenario Nested Virtualization
# ------------------------------------------------------------------------------------
# This deploys a Hyper-V host for nested virtualization scenario

# Resource group deployment
$resourceGroupName = 'RG-NestedVirtualization'
$location = 'westeurope'
New-AzResourceGroup -Name $resourceGroupName -Location $location

$templateFile = 'NestedVirtualization/main.bicep'
$templateParams = @{
    virtualNetworkName = 'VNet-NestedVirtualization'
    _artifactsLocation = 'https://heidelberg.fra1.digitaloceanspaces.com'
}

# _artifactsLocation = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization'   # Error downloading https://github.com/www42/TrainyMotion/tree/master/dsc/dscinstallwindowsfeatures.zip after 17 attempts
# _artifactsLocation = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization/'  # Error: The DSC Extension failed to execute: Error unpacking 'dscinstallwindowsfeatures.zip'; verify this is a valid ZIP package.

New-AzResourceGroupDeployment -Name 'HyperV-Host' -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -TemplateParameterObject $templateParams 



# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
Get-AzContext | Format-List *
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState
Get-AzSubscriptionDeployment
Get-AzSubscriptionDeployment | Sort-Object Timestamp | ft DeploymentName, ProvisioningState, Timestamp

Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort-Object Timestamp | ft DeploymentName,ProvisioningState,Timestamp
Get-AzResource -ResourceGroupName $resourceGroupName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $resourceGroupName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $resourceGroupName -Force -AsJob
