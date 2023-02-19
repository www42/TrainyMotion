# -------------------------------------------------------------------
# Deployment
# -------------------------------------------------------------------
$rgName='OnPrem-RG'
$location='westeurope'
$templateFile='Hybrid/hybrid.bicep'
dir $templateFile

# az group create --name $rgName --location $location
New-AzResourceGroup -Name $rgName -Location $location

# read -sp "Enter vmAdminPassword: " adminPassword

# az deployment group create --resource-group $rgName --template-file $templateFile --parameters vmAdminUserName='localadmin' vmAdminPassword=''
$templateParams = @{
    vmAdminUserName = 'localadmin'
    vmAdminPassword = '6kZrBmyy1GjpA5'
    vnetName = "OnPrem-VNet"
}
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $templateFile -TemplateParameterObject $templateParams



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
