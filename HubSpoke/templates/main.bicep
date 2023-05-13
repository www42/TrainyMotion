// implicit target scope resouceGroup
targetScope = 'subscription'

param location string 
param resourceGroupName string
param vnetName string
param gatewayName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}
module virtualNetwork './virtualNetwork.bicep' = {
  scope: resourceGroup
  name: 'NetworkHubDeployment'
  params: {
    location: location 
    vnetName: vnetName
  }
}
module virtualGateway './virtualGateway.bicep' = {
  scope: resourceGroup
  name: 'VirtualGatewayDeployment'
  params: {
    location: location
    gatewayName: gatewayName 
    subnetId: virtualNetwork.outputs.hubGatewaySubnetId
  }
}
