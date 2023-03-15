//
// Virtual network with two subnets. 
//
param location string
param vnetName string
param vnetAddressSpace string = '172.17.0.0/16'
param vnetSubnet0Name string = 'Subnet0'
param vnetSubnet0AddressPrefix string = '172.17.0.0/24'
param vnetSubnet1Name string = 'AzureBastionSubnet'
param vnetSubnet1AddressPrefix string = '172.17.255.64/26'

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
    ]
  }
}

output vnet object = vnet
output vnetName string = vnet.name
output vnetId string = vnet.id
