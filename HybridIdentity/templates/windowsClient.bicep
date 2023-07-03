//
// Virtual machine with Windows 11 
//    * VM is AzureAD joined due to the 'AADLoginForWindows' extension
//    * VM is ready to get Kerberos tickets from AzureAD (registry setting)
//
param location string
param vmName string
param vmSize string = 'Standard_D2s_v3'
param vmAdminUserName string
@secure()
param vmAdminPassword string
param vnet object


var vmImagePublisher = 'MicrosoftWindowsDesktop'
var vmImageOffer = 'windows-11'
var vmImageSku = 'win11-22h2-ent'
var vmImageVersion = 'latest'
var vmOsDiskName = '${vmName}-Disk'
var vmComputerName = vmName
var vmNicName = '${vmName}-Nic'
var vmNsgName = '${vmName}-Nsg'
var vmPipName = '${vmName}-Pip'

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
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: vmImageVersion
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
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
             id: vmPip.id
          }
        }
      }
    ]
  }
}
resource vmNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: vmNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP-Inbound'
        properties: {
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          access: 'Allow'
          priority: 200
        }
      }
    ]
  }
}
resource vmPip 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: vmPipName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
  }
}

output publicIp string = vmPip.properties.ipAddress
output managedIdentity string = vm.identity.principalId
