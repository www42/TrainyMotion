//
// Bastion host basic sku for an existing vnet
//
param location string
param vnetName string
param subnetId string

var bastionName = 'bas-${vnetName}'
var bastionPipName = 'pip-${bastionName}'

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  location: location
  name: bastionName
  sku: {
    name: 'Standard'
  }
  properties: {
    enableShareableLink: true
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          publicIPAddress: {
            id: bastionPip.id
          }
          subnet: {
            id: subnetId
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

output bastionName string = bastion.name
output bastionType string = bastion.sku.name
output bastionSharebleLink bool = bastion.properties.enableShareableLink
output pipBastion string = bastionPip.properties.ipAddress
