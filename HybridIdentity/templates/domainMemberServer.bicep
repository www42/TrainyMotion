param location string = 'westeurope'

param vmName string
param vmSize string = 'Standard_D2s_v3'
param vmIp string = '172.17.0.201'
param vmAdminUserName string 
@secure()
param vmAdminPassword string
param vmSubnetId string

var vmOsDiskName = '${vmName}-Disk'
var vmComputerName = vmName
var vmNicName = '${vmName}-Nic'

resource svr 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
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
          id: svrNic.id
        }
      ]
    }
  }
}

resource svrNic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: vmNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: vmIp
          subnet: {
            id: vmSubnetId
          }
        }
      }
    ]
    dnsSettings: {
      dnsServers: [
        dcIp
      ]
    }
  }
}


param domainToJoin string
param ouPath string
param domainUsername string
@secure()
param domainPassword string
param domainJoinOptions int

resource svrExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  name: '${svr.name}/joindomain'
  location: location
  properties: {
    type: 'JsonADDomainExtension'
    publisher: 'Microsoft.Compute'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      "Name": "[parameters('domainToJoin')]",
      "OUPath": "[parameters('ouPath')]",
      "User": "[concat(parameters('domainToJoin'), '\\', parameters('domainUsername'))]",
      "Restart": "true",
      "Options": "[parameters('domainJoinOptions')]"
    }
  }
}



output svrId string = svr.id
