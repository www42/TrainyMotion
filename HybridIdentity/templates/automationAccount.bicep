//
// Azure automation account
// DSC module 'ActiveDirectoryDsc'
// DSC configuration 'newForest'
//
param location string
param aaName string 
param aaModuleName string = 'ActiveDirectoryDsc'
param aaModuleContentLink string = 'https://psg-prod-eastus.azureedge.net/packages/activedirectorydsc.6.0.1.nupkg'
param aaConfigurationName string = 'newForest'
param aaConfigurationSourceUri string = 'https://heidelberg.fra1.digitaloceanspaces.com/newForest.ps1'
param createAaJob bool
param domainName string
param domainAdminName string
@secure()
param domainAdminPassword string

var aaJobName = '${aaConfigurationName}-Compile'

resource aa 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: aaName
  location: location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}
resource aaModule 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = {
  // name: '${aaName}/${aaModuleName}'
  // Does not work 
  //   "The Resource 'Microsoft.Automation/automationAccounts/DSC-pull'
  //    under resource group 'Oauth-RG' was not found."

  name: '${aa.name}/${aaModuleName}'
  properties: {
    contentLink: {
      uri: aaModuleContentLink
    }
  }
}
resource aaConfiguration 'Microsoft.Automation/automationAccounts/configurations@2019-06-01' = {
  name: '${aa.name}/${aaConfigurationName}'
  location: location
  properties: {
    source: {
      type: 'uri'
      value: aaConfigurationSourceUri
    }
    logProgress: true
    logVerbose: true
  }
}
resource aaJob 'Microsoft.Automation/automationAccounts/compilationjobs@2020-01-13-preview' = if (createAaJob) {
  name: '${aa.name}/${aaJobName}'
  dependsOn: [
    aaModule
    aaConfiguration
  ]
  properties: {
    configuration: {
      name: aaConfigurationName
    }
    parameters: {
      DomainName: domainName
      DomainAdminName: domainAdminName
      DomainAdminPassword: domainAdminPassword      
    }
  }
}

output aaId string = aa.id
output aaName string = aa.name
output aaJobState string = aaJob.properties.provisioningState
