param logAnalyticsWorkspaceName string
param location string

module LogAnalyticsWorkspace './LogAnalyticsWorkspace.bicep' = {
  name: 'Module-LogAnalyticsWorkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
  }
}
