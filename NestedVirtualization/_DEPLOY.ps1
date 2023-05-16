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
# Try    https://raw.githubusercontent.com/www42/TrainyMotion/tree/master/NestedVirtualization/


# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState
Get-AzSubscriptionDeployment
Get-AzSubscriptionDeployment | Sort-Object Timestamp | ft DeploymentName, ProvisioningState, Timestamp

Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp
Get-AzResource -ResourceGroupName $resourceGroupName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $resourceGroupName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $resourceGroupName -Force -AsJob


# -------------------------------------------------------------------
# Peerings
#
$Hub    = Get-AzVirtualNetwork -Name 'vnet-hub'    -ResourceGroupName 'rg-hub'
$Hybrid = Get-AzVirtualNetwork -Name 'vnet-hybrid' -ResourceGroupName 'rg-hybrid'
$Nested = Get-AzVirtualNetwork -Name 'vnet-nested' -ResourceGroupName 'rg-nested'

# Hub <--> Hybrid
Add-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetwork $Hub    -RemoteVirtualNetworkId $Hybrid.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetwork $Hybrid -RemoteVirtualNetworkId $Hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# Hub <--> Nested
Add-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetwork $Hub    -RemoteVirtualNetworkId $Nested.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetwork $Nested -RemoteVirtualNetworkId $Hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# Show
Get-AzVirtualNetworkPeering -VirtualNetworkName $Hub.Name    -ResourceGroupName 'rg-hub'    | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $Hybrid.Name -ResourceGroupName 'rg-hybrid' | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $Nested.Name -ResourceGroupName 'rg-nested' | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways

# Set 'UseRemoteGateways'
$HybridToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $Hybrid.Name -ResourceGroupName 'rg-hybrid'
$HybridToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $HybridToHub

$NestedToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $Nested.Name -ResourceGroupName 'rg-nested'
$NestedToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $NestedToHub


# Remove
Remove-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetworkName $Hub.Name    -ResourceGroupName 'rg-hub'    -Force
Remove-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetworkName $Hybrid.Name -ResourceGroupName 'rg-hybrid' -Force

Remove-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetworkName $Hub.Name    -ResourceGroupName 'rg-hub'    -Force
Remove-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetworkName $Nested.Name -ResourceGroupName 'rg-nested' -Force
# -------------------------------------------------------------------