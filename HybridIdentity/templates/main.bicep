param subnetId string = '/subscriptions/fa366244-df54-48f8-83c2-e1739ef3c4f1/resourceGroups/RG-HybridIdentity/providers/Microsoft.Network/virtualNetworks/VNet-HybridIdentity/subnets/Subnet0'
param automationAccountName string
param createAaJob bool
param domainName string
param domainAdminName string
@secure()
param domainAdminPassword string
param dcName string 
param dcIp string
param clientName string
param localAdminName string
@secure()
param localAdminPassword string
param clientVirtualMachineAdministratorLoginRoleAssigneeId string
param location string


module automationAccount './automationAccount.bicep' = {
  name: 'AutomationAccount-Deployment'
  params: {
    location: location
    aaName: automationAccountName
    createAaJob: createAaJob
    domainAdminName: domainAdminName
    domainAdminPassword: domainAdminPassword
    domainName: domainName
  }
}
module domainController './domainController.bicep' = {
  name: 'DomainController-Deployment'
  params: {
    location: location
    vmName: dcName
    vmIp: dcIp
    // Getting 'aaName' from the output of 'automationAccountDeployment' creates a dependency.
    // Effectivly module 'domainController' depends on module 'automationAccount'. This is needed obviously.
    aaName: automationAccount.outputs.aaName
    vmAdminUserName: domainAdminName
    vmAdminPassword: domainAdminPassword
    subnetId: subnetId
  }
}
module clientVm './windowsClient.bicep' = {
  name: 'ClientVM-Deployment'
  params: {
    location: location
    vmName: clientName
    vmAdminPassword: localAdminPassword
    vmAdminUserName: localAdminName
    subnetId: subnetId
    roleAsigneeId: clientVirtualMachineAdministratorLoginRoleAssigneeId
  }
}
module storageAccount './storageAccount.bicep' = {
  name: 'StorageAccount-Deployment'
  params: {
    location: location
  }
}
