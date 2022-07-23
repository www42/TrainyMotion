/*
Virtual machine for demo use in course AZ-040 "Automating Administration with PowerShell"
(formerly known as M10961) 

VM      Windows Server 2022
        user: localadmin
        connect via bastion
        custom script
        dsc configuration
*/

targetScope = 'subscription'

param location        string
param rgName          string
param vmName          string = 'VM1'
param vmAdminUserName string = 'localadmin'
@secure()
param vmAdminPassword string
param vmScript        string = 'script42.ps1'
param vmDsc           string = 'config42'

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
    script: vmScript
    dsc: vmDsc
    vnet: networkDeployment.outputs.network
  }
}

module autoShutdown '../bicep/autoShutdown.bicep' = {
  scope: rg
  name: 'autoShutdown'
  params: {
    location: location
    vmName: vmDeployment.outputs.virtualMachineName
    vmId: vmDeployment.outputs.virtualMachineId
  }
}
