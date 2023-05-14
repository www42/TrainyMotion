// implicit target scope resouceGroup
targetScope = 'subscription'

param location string 
param resourceGroupName string
param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string = ''
param virtualNetworkName string 
param HostAdminUsername string
@secure()
param HostAdminPassword string


resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module hypervHost './hypervHost.bicep' = {
  scope: resourceGroup
  name: 'HyperV-Host-Deployment'
  params: {
    location: location
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    virtualNetworkName: virtualNetworkName
    HostAdminUsername: HostAdminUsername
    HostAdminPassword: HostAdminPassword
  }
}
