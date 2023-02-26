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
$templateParams['createAaJob'] = $false

New-AzSubscriptionDeployment -Name 'HybridIdentity' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $templateParams.location -ResourceGroupName $templateParams.resourceGroupName


# -------------------------------------------------------------------
# Tests, useful commands, clean up
# -------------------------------------------------------------------
Get-AzContext | Format-List *
Get-AzResourceGroup | ft ResourceGroupName,Location,ProvisioningState
Get-AzSubscriptionDeployment
$rgName = $templateParams.resourceGroupName
Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp | ft DeploymentName,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location
New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $rgName -Force -AsJob


# Automation account https://learn.microsoft.com/en-us/powershell/module/az.automation/?view=azps-9.4.0#automation
$aaName = $templateParams.automationAccountName
Get-AzAutomationAccount -ResourceGroupName $rgName -Name $aaName
Get-AzAutomationRegistrationInfo -ResourceGroupName $rgName -AutomationAccountName $aaName
Get-AzAutomationDscConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName
Get-AzAutomationDscCompilationJob -ResourceGroupName $rgName -AutomationAccountName $aaName -OutVariable aaJob
Get-AzAutomationDscCompilationJobOutput -ResourceGroupName $rgName -AutomationAccountName $aaName -Id $aaJob.Id | Format-Table Time,Type,Summary
Get-AzAutomationDscNodeConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName
Get-AzAutomationDscNode -ResourceGroupName $rgName -AutomationAccountName $aaName


