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
module automationAccountDomainController 'templates/automationAccount_domainController.bicep' = {
  scope: resourceGroup
  name: 'automationAccountDomainControllerDeployment'
  params: {
    location: location
    aaName: automationAccountName
    createAaJob: createAaJob
    domainAdminName: domainAdminName
    domainAdminPassword: domainAdminPassword
    domainName: domainName
    vmAdminUserName: domainAdminName
    vmAdminPassword: domainAdminPassword
    vnet: virtualNetwork.outputs.vnet
  }
}
