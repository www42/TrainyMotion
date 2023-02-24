// Test automation account reference

param aaName string

// Does not work
// var aaRegistrationUrl = reference(aaName, '2020-01-13-preview', 'full').RegistrationUrl
// output aaRegistrationUrl string = aaRegistrationUrl

// Works great
resource aa 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: aaName
}
output aa object = aa

// Does not work
// output aaRegistrationUrl string = aa.properties.RegistrationUrl

