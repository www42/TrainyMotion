param logAnalyticsWorkspaceName string
param dcrName string
param location string

module logAnalyticsWorkspace './logAnalyticsWorkspace.bicep' = {
  name: 'Module-LogAnalyticsWorkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
  }
}

module dataCollectionRule './dataCollectionRule.bicep' = {
  name: 'Module-DataCollectionRule'
  params: {
    name: dcrName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
}
