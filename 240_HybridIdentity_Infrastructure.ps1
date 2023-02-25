# ---------------------------------------------------------------------------------------
# Deployment virtual network, bastion host, automation account, and domain controller-vm
# ---------------------------------------------------------------------------------------
$templateFile='HybridIdentity/main.bicep'
$templateParams = @{
    location = 'westeurope'
    resourceGroupName = 'OnPrem-RG'
    vnetName = 'OnPrem-VNet'
    automationAccountName = 'Hybrid-AutomationAccount'
    createAaJob = $true
    domainName = 'az.training'
    domainAdminName = 'DomainAdmin'
    domainAdminPassword = 'Pa55w.rd1234'
}
New-AzSubscriptionDeployment -Name 'HybridIdentity' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $templateParams.location



# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
Get-AzContext | Format-List *
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState
Get-AzSubscriptionDeployment
Get-AzResourceGroupDeployment -ResourceGroupName $templateParams.resourceGroupName | Sort-Object Timestamp | ft DeploymentName,ProvisioningState
Get-AzResource -ResourceGroupName $templateParams.resourceGroupName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location
New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $templateParams.resourceGroupName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $templateParams.resourceGroupName -Force -AsJob