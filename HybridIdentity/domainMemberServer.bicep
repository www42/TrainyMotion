param svrName string = 'SVR1'
param svrIp string = '172.17.0.201'

var svrOsDiskName = '${svrName}-Disk'
var svrComputerName = svrName
var svrNicName = '${svrName}-Nic'

resource svr 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: svrName
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
        name: svrOsDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: svrComputerName
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



resource svrNic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: svrNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: svrIp
          subnet: {
            id: vnet.properties.subnets[0].id
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

output svrId string = svr.id
