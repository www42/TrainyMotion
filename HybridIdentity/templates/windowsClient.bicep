param location string
param vmName string = 'Client01'
param vmSize string = 'Standard_D2s_v3'
param vmAdminUserName string
@secure()
param vmAdminPassword string
param vmSubnetId string


var vmOsDiskName = '${vmName}-Disk'
var vmComputerName = vmName
var vmNicName = '${vmName}-Nic'
var vmNsgName = '${vmName}-Nsg'

var customScriptName = 'Enable-CloudKerberosTicketRetrieval.ps1'
var customScriptUri = 'https://raw.githubusercontent.com/www42/TrainyMotion/master/scripts/${customScriptName}'



resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-ent'
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
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
  }
  resource aadLoginExtion 'extensions@2023-03-01' = {
    name: 'AADLoginForWindows'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADLoginForWindows'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true

    }
  }
  resource dscExtension 'extensions@2023-03-01' = {
    name: 'customScript'
    location: location
    properties: {
      type: 'CustomScriptExtension'
      publisher: 'Microsoft.Compute'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings: {
        fileUris: [
          customScriptUri
        ]
        commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${customScriptName}'  
      }
    }
  }
}
resource vmNic 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: vmNicName
  location: location
  properties: {
    networkSecurityGroup: {
      id: vmNsg.id
    }
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnetId
          }
        }
      }
    ]
  }
}
resource vmNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: vmNsgName
  location: location
}
