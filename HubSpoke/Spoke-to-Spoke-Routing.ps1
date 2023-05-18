# Spoke to Spoke Routing
# -------------------------------------------------------------------

# Microsoft.Network/routeTables/routes
$UdrToNested = New-AzRouteConfig -Name 'udr-to-nested' -AddressPrefix '10.2.0.0/16' -NextHopType VirtualNetworkGateway

# Microsoft.Network/routeTables
New-AzRouteTable -Name 'rt-hybrid-to-nested' -ResourceGroupName 'rg-hybrid' -Location 'westeurope' -Route $UdrToNested