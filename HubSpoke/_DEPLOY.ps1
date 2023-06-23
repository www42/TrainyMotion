# ------------------------------------------------------------------------------------
# Scenario Hub-and-Spoke
# ------------------------------------------------------------------------------------
# This deploys
#    * Hub virtual network
#    * Bastion host
#    * Optional: Virtual gateway 
#                   with certificates
#                   with VPN client Windows
# ------------------------------------------------------------------------------------
Connect-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription
az login
az account show --query "{name:name,user:user.name,tenant:tenantId,subscription:id}"




# ------------------------------------------------------------------------------------
# DEPLOYMENT
#
$templateFile = 'HubSpoke/templates/main.bicep'
$templateParams = @{
    location = 'westeurope'
    resourceGroupName = 'rg-hub'
    vnetName = 'vnet-hub'
    gatewayDeploymentYesNo = $false
    gatewayName = 'vgw-trainymotion'
}
$templateParams['gatewayDeploymentYesNo'] = $true

New-AzSubscriptionDeployment -Name 'Hub-and-Spoke-Scenario' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $templateParams.location -ResourceGroupName $templateParams.resourceGroupName
#
# ------------------------------------------------------------------------------------

# Next steps
#   --> ClientCertificate
#   --> Peering
#   --> Spoke-to-Spoke-Routing




# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState
Get-AzSubscriptionDeployment
Get-AzSubscriptionDeployment | Sort-Object Timestamp -Descending | ft DeploymentName, ProvisioningState, Timestamp
$rgName = $templateParams.resourceGroupName
Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $rgName -Force -AsJob

$hubBastionSubnetId = Get-AzResourceGroupDeployment -Name 'Hub-Network-Deployment' -ResourceGroupName $rgName | % Outputs | % hubBastionSubnetId | % value
$hubBastionSubnetId.split('Microsoft.Network/virtualNetworks/')[1]