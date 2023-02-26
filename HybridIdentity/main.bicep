// implicit target scope resouceGroup
targetScope = 'subscription'

param location string 
param resourceGroupName string
param vnetName string
param automationAccountName string
param createAaJob bool
param domainName string
param domainAdminName string
@secure()
param domainAdminPassword string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}
module virtualNetwork 'templates/virtualNetwork.bicep' = {
  scope: resourceGroup
  name: 'VirtualNetworkDeployment'
  params: {
    location: location 
    vnetName: vnetName
  }
}
module bastionHost 'templates/bastionHost.bicep' = {
  scope: resourceGroup
  name: 'BastionHostDeployment'
  params: {
    location: location
    vnet: virtualNetwork.outputs.vnet
    vnetName: virtualNetwork.outputs.vnetName
  }
}
module automationAccount 'templates/automationAccount.bicep' = {
  scope: resourceGroup
  name: 'automationAccountDeployment'
  params: {
    location: location
    aaName: automationAccountName
    createAaJob: createAaJob
    domainAdminName: domainAdminName
    domainAdminPassword: domainAdminPassword
    domainName: domainName
  }
}
module domainController 'templates/domainController.bicep' = {
  scope: resourceGroup
  name: 'domainControllerDeployment'
  params: {
    location: location
    // Getting 'aaName' from the output of 'automationAccountDeployment' creates a dependency.
    // Effectivly module 'domainController' depends on module 'automationAccount'. This is needed obviously.
    // 
    aaName: automationAccount.outputs.aaName
    vmAdminUserName: domainAdminName
    vmAdminPassword: domainAdminPassword
    vnet: virtualNetwork.outputs.vnet
  }
}
