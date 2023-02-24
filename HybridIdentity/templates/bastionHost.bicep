//
// Bastion host basic sku for an existing vnet
//
param location string
param vnet object
param vnetName string

var bastionName = '${vnetName}-Bastion'
var bastionPipName = '${vnetName}-Bastion-Pip'

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  location: location
  name: bastionName
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          publicIPAddress: {
            id: bastionPip.id
          }
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
      }
    ]
  }
}
resource bastionPip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: bastionPipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output bastionId string = bastion.id
