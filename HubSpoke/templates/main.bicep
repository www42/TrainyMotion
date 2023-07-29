param location string
param bastionName string
param bastionSubnetId string 
param deployGateway bool
param gatewayName string
param gatewaySubnetId string
param rootCertificateName string
param rootCertificateData string

module virtualGateway './virtualGateway.bicep' = if (deployGateway) {
  name: 'Module-VirtualGateway'
  params: {
    location: location
    name: gatewayName 
    subnetId: gatewaySubnetId
    rootCertificateData: rootCertificateData
    rootCertificateName: rootCertificateName
  }
}
module bastion './bastionHost.bicep' = {
  name: 'Module-BastionHost'
  params: {
    location: location
    name: bastionName
    subnetId: bastionSubnetId
  }
}
