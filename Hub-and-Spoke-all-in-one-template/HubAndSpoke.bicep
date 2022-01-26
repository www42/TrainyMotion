// Parameters to customize deployment
param deployPeeringHubSpoke2 bool = false
param deployRouting          bool = true
param deployVmHub            bool = true
param deployVmSpoke1         bool = true
param deployVmSpoke2         bool = true
param deployBastion          bool = true

// Location
param location string = resourceGroup().location

// Hub
param hubName                    string = 'Hub'
param hubAddressSpace            array  = [
                                          '10.0.0.0/16'
                                          ]
param hubSubnet1Name             string = 'Subnet0'
param hubSubnet1AddressPrefix    string = '10.0.0.0/24'
param hubSubnet2Name             string = 'Subnet1'
param hubSubnet2AddressPrefix    string = '10.0.1.0/24'
param hubSubnet3Name             string = 'GatewaySubnet'       // Do not change!
param hubSubnet3AddressPrefix    string = '10.0.255.0/27'
param hubSubnet4Name             string = 'AzureBastionSubnet'  // Do not change!
param hubSubnet4AddressPrefix    string = '10.0.255.32/27'
param hubSubnet5Name             string = 'AzureFirewallSubnet' // Do not change!
param hubSubnet5AddressPrefix    string = '10.0.255.64/26'
// Spoke 1
param spoke1Name                 string = 'Spoke1'
param spoke1AddressSpace         array  = [
                                          '10.1.0.0/16'
                                          ]
param spoke1Subnet1Name          string = 'Subnet0'
param spoke1Subnet1AddressPrefix string = '10.1.0.0/24'
// Spoke 2
param spoke2Name                 string = 'Spoke2'
param spoke2AddressSpace         array  = [
                                          '10.2.0.0/16'
                                          ]
param spoke2Subnet1Name          string = 'Subnet0'
param spoke2Subnet1AddressPrefix string = '10.2.0.0/24'
// Gateway
param gatewayName                string = 'Gateway1'
param gatewayAddressPool         string = '172.20.20.0/25'
param gatewayRootCertName        string = 'rootcert'
param gatewayRootCertPublicData  string = 'MIIC/TCCAeWgAwIBAgIQLkXhAXtvLpNLhIyjznYWvDANBgkqhkiG9w0BAQsFADAhMR8wHQYDVQQDDBZDb250b3NvUm9vdENlcnRpZmljYXRlMB4XDTIxMDQwMzE3MDYzM1oXDTIyMDQwMzE3MjYzM1owITEfMB0GA1UEAwwWQ29udG9zb1Jvb3RDZXJ0aWZpY2F0ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPuJ3KWFvVYrewuSQxVelRbORNtNkSqMrHUj9N73XzkxEBODjfb3IJd/bGNNn70Z9YUDElFbKEVfHs2icZfCqiLNT4ejnN49La/Zp17qYDumFtiUErc5PVJA8Op1swURcFeHeuHsZdq1ADi8+M51o4nWFh80mJay2g/GUwE0UxOyDNerVLIXkZPQ89UngKb3cZN7TtCQXW6CJGMFLY07KbNiwpQuFg9DbxVR0bOoMi2MgnYalweBt/JHCMwLFfzZ4DwuNVYwGWFtnaBjTv5XgBQrxVvXzCxHUXhznSLClqJ8PTTTM6ZgPC4l1BuIVWZfyI5S3WdvyT8dhVmpVTaQc/kCAwEAAaMxMC8wDgYDVR0PAQH/BAQDAgIEMB0GA1UdDgQWBBRfYo+dRHQ5rVdtOyo27ez1Odc5ijANBgkqhkiG9w0BAQsFAAOCAQEArg3ElQzE8537qJUGQIvYU1JwI6tpeyBta7bmV3qg8G0ha02rn7gPJHpLhwgVhQU3kuFm0+Lfyza8Jk3PMSCueD80MKocxnEd9m147lCDBbTmXHAWe5OcaW8fzemf574jxl1XVS2/4FBvU0/Al6XwneRcRblr0mvhhiUbWBu9dhWSIkqnvOqu6zPbJIIwaXcV7qZ0e1GthI/QL4jSu02XtogJ01ESTWvJPFYntoWsuk5R/2z6gAImQvb9PAhm7nAqz8MkXmcfQFmo7VYiiL1+tzAVryAqNkQFKrJnR368xGIFzKLF/YNqOYPn0xYNfL9rIoi+yMT7fgq61U/4Cj/AKA=='
// Route Table
param routeTableName             string = 'Table1'
// All VMs
param vmSize                     string = 'Standard_DS2_v2'
param vmAdminUserName            string = 'Student'
param vmAdminPassword            string = 'Pa55w.rd1234'
// VMs
param vmHubName                  string = 'NVA'
param vmSpoke1Name               string = 'VM1'
param vmSpoke2Name               string = 'VM2'
// Bastion Host
param bastionName                string = 'Bastion1'


// Virtual Networks
resource hub 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: hubName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: hubAddressSpace
    }
    subnets: [
      {
        name: hubSubnet1Name
        properties: {
          addressPrefix: hubSubnet1AddressPrefix
          routeTable: {
            id: routeTable.id
          }
        }
      }
      {
        name: hubSubnet2Name
        properties: {
          addressPrefix: hubSubnet2AddressPrefix
        }
      }
      {
        name: hubSubnet3Name
        properties: {
          addressPrefix: hubSubnet3AddressPrefix
        }
      }
      {
        name: hubSubnet4Name
        properties: {
          addressPrefix: hubSubnet4AddressPrefix
        }
      }
      {
        name: hubSubnet5Name
        properties: {
          addressPrefix: hubSubnet5AddressPrefix
        }
      }
    ]
  }
}
resource spoke1 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: spoke1Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: spoke1AddressSpace
    }
    subnets: [
      {
        name: spoke1Subnet1Name
        properties: {
          addressPrefix: spoke1Subnet1AddressPrefix
          routeTable: {
            id: routeTable.id
          }
        }
      }
    ]
  }
}
resource spoke2 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: spoke2Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: spoke2AddressSpace
    }
    subnets: [
      {
        name: spoke2Subnet1Name
        properties: {
          addressPrefix: spoke2Subnet1AddressPrefix
          routeTable: {
            id: routeTable.id
          }
        }
      }
    ]
  }
}

// Virtual Network Peerings
resource hubSpoke1Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${hubName}/${hubName}-to-${spoke1Name}-Peering'
  properties: {
    remoteVirtualNetwork: {
      id: spoke1.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}
resource spoke1HubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: '${spoke1Name}/${spoke1Name}-to-${hubName}-Peering'
  properties: {
    remoteVirtualNetwork: {
      id: hub.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
  }
  dependsOn: [
    gateway
  ]
}
resource hubSpoke2Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = if (deployPeeringHubSpoke2) {
  name: '${hubName}/${hubName}-to-${spoke2Name}-Peering'
  properties: {
    remoteVirtualNetwork: {
      id: spoke2.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}
resource spoke2HubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = if (deployPeeringHubSpoke2) {
  name: '${spoke2Name}/${spoke2Name}-to-${hubName}-Peering'
  properties: {
    remoteVirtualNetwork: {
      id: hub.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
  }
  dependsOn: [
    gateway
  ]
}

// Virtual Gateway
resource gateway 'Microsoft.Network/virtualNetworkGateways@2020-08-01' = {
  name: gatewayName
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          publicIPAddress: {
            id: gatewayPip.id
          }
          subnet: {
            id: hub.properties.subnets[2].id
          }
        }
      }
    ]
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          gatewayAddressPool
        ]
      }
      vpnClientProtocols: [
        'SSTP'
        'IkeV2'
      ]
      vpnClientRootCertificates: [
        {
          name: gatewayRootCertName
          properties: {
            publicCertData: gatewayRootCertPublicData
          }
        }
      ]
    }
  }
}
resource gatewayPip 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${gatewayName}-Pip'
  location: location
  sku: {
    name: 'Basic'    
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Routing
resource routeTable 'Microsoft.Network/routeTables@2020-08-01' = if (deployRouting) {
  name: routeTableName
  location: location
  properties: {
    routes:[
      {
        name: 'Route-to-Hub-${hubSubnet1Name}'
        properties: {
          nextHopType: 'VirtualNetworkGateway'
          addressPrefix: hubSubnet1AddressPrefix
        }
      }
      {
        name: 'Route-to-Spoke1-${spoke1Subnet1Name}'
        properties: {
          nextHopType:'VirtualNetworkGateway'
          addressPrefix: spoke1Subnet1AddressPrefix
        }
      }
      {
        name: 'Route-to-Spoke2-${spoke2Subnet1Name}'
        properties: {
          nextHopType: 'VirtualNetworkGateway'
          addressPrefix: spoke2Subnet1AddressPrefix
        }
      }
    ]
  }
}

// Virtual Machines
//   VmHub (NVA, Hub)
resource vmHub 'Microsoft.Compute/virtualMachines@2020-12-01' = if (deployVmHub) {
  name: vmHubName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference:{
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmHubName}-Disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmHubName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
    }
    networkProfile:{
      networkInterfaces: [
        {
          id: vmHubNic.id
        }
      ]
    }
  }
}
resource vmHubNic 'Microsoft.Network/networkInterfaces@2020-11-01' = if (deployVmHub) {
  name: '${vmHubName}-Nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: hub.properties.subnets[0].id
          }
        }
      }
    ]
  }
}
resource vmHubDsc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if (deployVmHub) {
  parent: vmHub
  name: 'InstallRRAS'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url:      'https://raw.githubusercontent.com/www42/test1/Hub-Spoke/DSC/dscConfigs.zip'
        script:   'dscConfigs.ps1'
        function: 'InstallRRAS-PrettyWindows'
      }
    }
  }
}
//   VmSpoke1 (VM1, Spoke1) 
resource vmSpoke1 'Microsoft.Compute/virtualMachines@2020-12-01' = if (deployVmSpoke1) {
  name: vmSpoke1Name
  location: location  
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference:{
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmSpoke1Name}-Disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmSpoke1Name
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
    }
    networkProfile:{
      networkInterfaces: [
        {
          id: vmSpoke1Nic.id
        }
      ]
    }
  }
}
resource vmSpoke1Nic 'Microsoft.Network/networkInterfaces@2020-11-01' = if (deployVmSpoke1) {
  name: '${vmSpoke1Name}-Nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: spoke1.properties.subnets[0].id
          }
        }
      }
    ]
  }
}
resource vmSpoke1Dsc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if (deployVmSpoke1) {
  parent: vmSpoke1
  name: 'PrettyWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url:      'https://raw.githubusercontent.com/www42/test1/Hub-Spoke/DSC/dscConfigs.zip'
        script:   'dscConfigs.ps1'
        function: 'PrettyWindows'
      }
    }
  }
}
//   VmSpoke2 (VM2, Spoke2)
resource vmSpoke2 'Microsoft.Compute/virtualMachines@2020-12-01' = if (deployVmSpoke2) {
  name: vmSpoke2Name
  location: location  
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference:{
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmSpoke2Name}-Disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmSpoke2Name
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
    }
    networkProfile:{
      networkInterfaces: [
        {
          id: vmSpoke2Nic.id
        }
      ]
    }
  }
}
resource vmSpoke2Nic 'Microsoft.Network/networkInterfaces@2020-11-01' = if (deployVmSpoke2) {
  name: '${vmSpoke2Name}-Nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: spoke2.properties.subnets[0].id
          }
        }
      }
    ]
  }
}
resource vmSpoke2Dsc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = if (deployVmSpoke2) {
  parent: vmSpoke2
  name: 'PrettyWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url:      'https://raw.githubusercontent.com/www42/test1/Hub-Spoke/DSC/dscConfigs.zip'
        script:   'dscConfigs.ps1'
        function: 'PrettyWindows'
      }
    }
  }
}

// Bastion Host
resource bastion 'Microsoft.Network/bastionHosts@2020-08-01' = if (deployBastion) {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          publicIPAddress: {
            id: bastionPip.id
          }
          subnet: {
            id: hub.properties.subnets[3].id
          }
        }
      }
    ]
  }
}
resource bastionPip 'Microsoft.Network/publicIPAddresses@2020-11-01' = if (deployBastion) {
  name: '${bastionName}-Pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
