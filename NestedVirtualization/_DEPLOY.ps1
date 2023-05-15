# ------------------------------------------------------------------------------------
# Scenario Nested Virtualization
# ------------------------------------------------------------------------------------
# This deploys a Hyper-V host for nested virtualization scenario
# ------------------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription




# ------------------------------------------------------------------------------------
# DEPLOYMENT
#
$templateFile = 'NestedVirtualization/templates/main.bicep'
$templateParams = @{
    location = 'westeurope'
    resourceGroupName = 'rg-nested'
    virtualNetworkName = 'vnet-nested'
    _artifactsLocation = 'https://heidelberg.fra1.digitaloceanspaces.com/NestedVirtualization/'
    HostAdminUsername = 'LocalAdmin'
    HostAdminPassword = ''
}
$templateParams['HostAdminPassword'] = ''

New-AzSubscriptionDeployment -Name 'Nested-Virtualization-Scenario' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $templateParams.location -ResourceGroupName $templateParams.resourceGroupName
#
# ------------------------------------------------------------------------------------





# Problem with artifacts location
# _artifactsLocation = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization'   # Error downloading https://github.com/www42/TrainyMotion/tree/master/dsc/dscinstallwindowsfeatures.zip after 17 attempts
# _artifactsLocation = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization/'  # Error: The DSC Extension failed to execute: Error unpacking 'dscinstallwindowsfeatures.zip'; verify this is a valid ZIP package.
#
# Try https://raw.githubusercontent.com/www42/TrainyMotion/tree/master/NestedVirtualization/


# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
Get-AzContext | Format-List *
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState
Get-AzSubscriptionDeployment
Get-AzSubscriptionDeployment | Sort-Object Timestamp | ft DeploymentName, ProvisioningState, Timestamp

Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp
Get-AzResource -ResourceGroupName $resourceGroupName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $resourceGroupName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $resourceGroupName -Force -AsJob


# -------------------------------------------------------------------
# Peering HybridIdentity <--> NestedVirtualization
#                  VNet1 <--> VNet2
$VNet1 = Get-AzVirtualNetwork -Name 'VNet-HybridIdentity' -ResourceGroupName 'RG-HybridIdentity'
$VNet2 = Get-AzVirtualNetwork -Name 'VNet-NestedVirtualization' -ResourceGroupName 'RG-NestedVirtualization'
Add-AzVirtualNetworkPeering -Name 'VNet1-to-VNet2' -VirtualNetwork $VNet1 -RemoteVirtualNetworkId $VNet2.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'VNet2-to-VNet1' -VirtualNetwork $VNet2 -RemoteVirtualNetworkId $VNet1.Id -AllowForwardedTraffic -AllowGatewayTransit

Get-AzVirtualNetworkPeering -VirtualNetworkName $VNet1.Name -ResourceGroupName 'RG-HybridIdentity' | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit
Get-AzVirtualNetworkPeering -VirtualNetworkName $VNet2.Name -ResourceGroupName 'RG-NestedVirtualization' | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit

Remove-AzVirtualNetworkPeering -Name 'VNet1-to-VNet2' -VirtualNetworkName $VNet1.Name -ResourceGroupName 'RG-HybridIdentity' -Force
# -------------------------------------------------------------------