//
// Hub virtual network with four subnets. 
//
param location string
param vnetName string
param vnetAddressSpace string = '10.255.0.0/16'
param vnetSubnet0Name string = 'default'
param vnetSubnet0AddressPrefix string = '10.255.0.0/24'
param vnetSubnet1Name string = 'AzureBastionSubnet'
param vnetSubnet1AddressPrefix string = '10.255.255.0/26'
param vnetSubnet2Name string = 'AzureFirewallSubnet'
param vnetSubnet2AddressPrefix string = '10.255.255.64/26'
param vnetSubnet3Name string = 'GatewaySubnet'
param vnetSubnet3AddressPrefix string = '10.255.255.128/27'

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: vnetSubnet0Name
        properties: {
          addressPrefix: vnetSubnet0AddressPrefix
        }
      }
      {
        name: vnetSubnet1Name
        properties: {
          addressPrefix: vnetSubnet1AddressPrefix
        }
      }
      {
        name: vnetSubnet2Name
        properties: {
          addressPrefix: vnetSubnet2AddressPrefix
        }
      }
      {
        name: vnetSubnet3Name
        properties: {
          addressPrefix: vnetSubnet3AddressPrefix
        }
      }
    ]
  }
}

output hubName string = vnet.name
output hubId string = vnet.id
output hubBastionSubnetId string = vnet.properties.subnets[1].id
output hubFirewallSubnetId string = vnet.properties.subnets[2].id
output hubGatewaySubnetId string = vnet.properties.subnets[3].id
