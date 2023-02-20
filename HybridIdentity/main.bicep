targetScope = 'subscription'

param resourceGroupName string
param location string = 'westeurope'
param domainName string = 'trainymotion.com'
param domainAdminName string = 'DomainAdmin'
@secure()
param domainPassword string
param vnetName string = ''

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module domainController 'domainController_aA_bastionHost.bicep' = {
  scope: resourceGroup
  name: 'DomainControllerDeployment'
  params: {
    location: location
    vmAdminUserName: domainAdminName
    vmAdminPassword: domainPassword
    domainName: domainName
    vnetName: vnetName
  }
}
