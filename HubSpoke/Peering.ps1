# Peerings
# -------------------------------------------------------------------
#
$Hub    = Get-AzVirtualNetwork -Name 'vnet-hub'            -ResourceGroupName 'rg-hub'
$Hybrid = Get-AzVirtualNetwork -Name 'vnet-hybrididentity' -ResourceGroupName 'rg-hybrididentity'
$Nested = Get-AzVirtualNetwork -Name 'vnet-nested'         -ResourceGroupName 'rg-nested'

# if error
#   Add-AzVirtualNetworkPeering: Authentication failed for auxiliary token...
# then
#   Clear-AzContext

# Hub <--> Hybrid
Add-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetwork $Hub    -RemoteVirtualNetworkId $Hybrid.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetwork $Hybrid -RemoteVirtualNetworkId $Hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# Hub <--> Nested
Add-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetwork $Hub    -RemoteVirtualNetworkId $Nested.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetwork $Nested -RemoteVirtualNetworkId $Hub.Id    -AllowForwardedTraffic #-UseRemoteGateways

# Show
Get-AzVirtualNetworkPeering -VirtualNetworkName $Hub.Name    -ResourceGroupName 'rg-hub'            | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $Hybrid.Name -ResourceGroupName 'rg-hybrididentity' | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways
Get-AzVirtualNetworkPeering -VirtualNetworkName $Nested.Name -ResourceGroupName 'rg-nested'         | ft Name,PeeringState,AllowForwardedTraffic,AllowGatewayTransit,UseRemoteGateways

# Set 'UseRemoteGateways'
$HybridToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $Hybrid.Name -ResourceGroupName 'rg-hybrididentity'
$HybridToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $HybridToHub

$NestedToHub = Get-AzVirtualNetworkPeering -VirtualNetworkName $Nested.Name -ResourceGroupName 'rg-nested'
$NestedToHub.UseRemoteGateways = $true
Set-AzVirtualNetworkPeering -VirtualNetworkPeering $NestedToHub


# Remove
Remove-AzVirtualNetworkPeering -Name 'peer-hub-hybrid' -VirtualNetworkName $Hub.Name    -ResourceGroupName 'rg-hub'            -Force
Remove-AzVirtualNetworkPeering -Name 'peer-hybrid-hub' -VirtualNetworkName $Hybrid.Name -ResourceGroupName 'rg-hybrididentity' -Force

Remove-AzVirtualNetworkPeering -Name 'peer-hub-nested' -VirtualNetworkName $Hub.Name    -ResourceGroupName 'rg-hub'    -Force
Remove-AzVirtualNetworkPeering -Name 'peer-nested-hub' -VirtualNetworkName $Nested.Name -ResourceGroupName 'rg-nested' -Force