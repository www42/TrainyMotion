targetScope = 'subscription'

param resourceGroupName string
param location string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module LogAnalyticsWorkspace 'LogAnalyticsWorkspace.bicep' = {
  name: 'LogAnalyticsWorkspaceDeployment'
  scope: resourceGroup
  params: {
    logAnalyticsWorkspaceName: 'log-workspace1'
    location: location
  }
}
