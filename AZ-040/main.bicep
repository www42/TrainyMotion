targetScope = 'subscription'

param location string
param rgName string = 'Lab-RG'
param vmName string = 'VM1'
param vmAdminUserName string = 'localadmin'
@secure()
param vmAdminPassword string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module networkDeployment '../bicep/network.bicep' = {
  name: 'networkDeployment'
  scope: rg
  params: {
    location: location
  }
}

module bastionDeployment '../bicep/bastion.bicep' = {
  name: 'bastionDeployment'
  scope: rg
  params: {
    location: location
    vnet: networkDeployment.outputs.network
    vnetName: networkDeployment.outputs.networkName
  }
}

module vmDeployment '../bicep/vm.bicep' = {
  name: 'vmDeployment'
  scope: rg
  params: {
    location: location
    vmName: vmName
    vmAdminUserName: vmAdminUserName
    vmAdminPassword: vmAdminPassword
    vnet: networkDeployment.outputs.network
    script: 'script42.ps1'
  }
}
