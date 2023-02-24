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
// Domain controller and automation account together in a singe template - works great
module aaDc 'templates/automationAccount_domainController.bicep' = {
  scope: resourceGroup
  name: 'aaDcDeployment'
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


// module automationAccount 'templates/automationAccount.bicep' = {
//   scope: resourceGroup
//   name: 'AutomationAccountDeployment'
//   params: {
//     location: location
//     aaName: automationAccountName
//     domainName: domainName
//     domainAdminName: domainAdminName
//     domainAdminPassword: domainAdminPassword
//   }
// }
// module domainController 'templates/domainController.bicep' = {
//   scope: resourceGroup
//   name: 'DomainControllerDeployment'
//   params: {
//     location: location
//     vmAdminUserName: domainAdminName
//     vmAdminPassword: domainAdminPassword
//     vnet: virtualNetwork.outputs.vnet
//     aaName: automationAccountName
//   }
// }
// Deployment template validation failed: 'The template reference 'Digital-AutomationAccount' is not valid: 
//      could not find template resource or resource copy with this name. Please see https://aka.ms/arm-function-reference for usage details.'. 
//      (Code:InvalidTemplate)

// --------------------------------------------------------------
// param localAdminName string
// @secure()
// param localAdminPassword string

// module svr1 'templates/domainMemberServer.bicep' = {
//   scope: resourceGroup
//   name: 'SVR1Deployment'
//   params: {
//     location: location
//     vmName: 'SVR1'
//     vmAdminUserName: localAdminName
//     vmAdminPassword: localAdminPassword 
//     domainJoinOptions: domainName
//     domainPassword: 
//     domainToJoin: 
//     domainUsername: 
//     ouPath: 
//     vmSubnetId: 
//   }
// }
