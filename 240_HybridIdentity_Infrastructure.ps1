# ---------------------------------------------------------------------------
# Deployment OnPrem Domain Controller and Automation Account and Bastion Host
# ---------------------------------------------------------------------------
$templateFile='HybridIdentity/main.bicep'
$location = 'westeurope'
$templateParams = @{
    resourceGroupName = 'OnPrem-RG'
    location = $location
    domainName = 'az.training'
    domainAdminName = 'DomainAdmin'
    domainPassword = 'g1uxRMqczhhY'
    vnetName = "OnPrem-VNet"
}
New-AzSubscriptionDeployment -Name 'HybridIdentity' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $location



# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
# az account show
Get-AzContext | fl *

# az group list --output table
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState

az deployment group list --resource-group $rgName \
    --query "reverse(sort_by([].{Name:name,provisioningState:properties.provisioningState,timestamp:properties.timestamp}, &timestamp))" --output table
Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp | ft DeploymentName,ProvisioningState

az resource list --resource-group $rgName --query "sort_by([].{name:name,Type:type,location:location},&Type)" --output table

# Tabula rasa resource group
az deployment group create --name 'tabulaRasa' --resource-group $rgName --mode Complete --template-uri "https://raw.githubusercontent.com/www42/arm/master/templates/empty.json" --no-wait

# Delete resource group
az group delete --resource-group $rgName --yes --no-wait
