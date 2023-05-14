// implicit target scope resouceGroup
targetScope = 'subscription'

param location string 
param resourceGroupName string
param vnetName string
param gatewayDeploymentYesNo bool
param gatewayName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}
module hub './virtualNetwork.bicep' = {
  scope: resourceGroup
  name: 'Hub-Network-Deployment'
  params: {
    location: location 
    vnetName: vnetName
  }
}
module virtualGateway './virtualGateway.bicep' = if (gatewayDeploymentYesNo) {
  scope: resourceGroup
  name: 'Virtual-Gateway-Deployment'
  params: {
    location: location
    gatewayName: gatewayName 
    subnetId: hub.outputs.hubGatewaySubnetId
  }
}
module bastion './bastionHost.bicep' = {
  scope: resourceGroup
  name: 'Bastion-Host-Deployment'
  params: {
    location: location
    vnetName: hub.outputs.hubName
    subnetId: hub.outputs.hubBastionSubnetId
  }
}
