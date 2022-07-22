param  location string = resourceGroup().location

param vmName string = 'VM1'
param vmSize string = 'Standard_D2as_v5'
param vmAdminUserName string = 'localadmin'
@secure()
param vmAdminPassword string
param script string = 'script42.ps1'

param vnet object

var vmComputerName = vmName
var vmOsDiskName = '${vmName}-Disk'
var vmNsgName = '${vmName}-NSG'
var nicName = '${vmName}-Nic'
// var scriptUri = 'https://raw.githubusercontent.com/www42/TrainyMotion/master/scripts/${script}'
var scriptUri = 'https://lab69118.blob.core.windows.net/scripts/${script}'
var scriptcommand = 'powershell.exe -ExecutionPolicy Unrestricted -File ${script}'


resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference:{
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: vmOsDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmComputerName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
      windowsConfiguration: {
        timeZone: 'W. Europe Standard Time'
      }
    }
    networkProfile:{
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }    
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: vmNsgName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource vmScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'customScript'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        scriptUri
      ]
    commandToExecute: scriptcommand
    }

  }
}
