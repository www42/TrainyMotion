# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This deploys infrastructure for hybrid identity scenario
#     * Domain controller VM representing on prem AD-DS
#     * Automation Account
#     * Virtual network
# 
# ------------------------------------------------------------------------------------
# DSC compile job (compilation .ps1 --> .mof) is not idempotent.
# So for the first time create a compile job by 'createAaJob = $true'. In subsequent deployments say 'createAaJob = $false'
# ------------------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription

# ------------------------------------------------------------------------------------
$templateFile = 'HybridIdentity/templates/main.bicep'
$templateParams = @{
    location = 'westeurope'
    resourceGroupName = 'rg-hybrid'
    vnetName = 'vnet-hybrid'
    automationAccountName = 'aa-hybrid'
    createAaJob = $true
    domainName = 'trainymotion.com'
    domainAdminName = 'DomainAdmin'
    domainAdminPassword = ''
}
$templateParams['domainName'] = 'adatum.com'
$templateParams['createAaJob'] = $false
$templateParams['domainAdminPassword'] = ''

New-AzSubscriptionDeployment -Name 'Hybrid-Identity-Scenario' -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $templateParams.location -ResourceGroupName $templateParams.resourceGroupName
# ------------------------------------------------------------------------------------


# Resource group
$rgName = $templateParams.resourceGroupName
Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# Deployments
Get-AzSubscriptionDeployment | Sort-Object Timestamp | ft DeploymentName, ProvisioningState, Timestamp
Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp | ft DeploymentName,ProvisioningState,Timestamp

New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
Remove-AzResourceGroup -Name $rgName -Force -AsJob


# Virtual network https://learn.microsoft.com/en-us/powershell/module/az.network/?view=azps-9.4.0#virtual-network
Get-AzVirtualNetwork | ft Name,AddressSpace,Subnets
Get-AzVirtualNetwork | % { $_.Subnets } | ft Name,AddressPrefix
# $vnetName = $templateParams.vnetName
$vnetName = 'vnet-hybrid'
Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName | fl Name,Subnets
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName) -Name 'default' | Tee-Object -Variable subnet| fl Name,AddressPrefix,NetworkSecurityGroup,RouteTable
$subnet.Id

New-AzResourceGroupDeployment `
    -Name 'WindowsClient-Deployment' `
    -ResourceGroupName $rgName `
    -TemplateFile 'HybridIdentity/templates/windowsClient.bicep' `
    -TemplateParameterObject @{
        location = 'westeurope';
        vmName = 'Client001';
        vmAdminUserName = 'localadmin'
        vmAdminPassword = ''
        vmSubnetId = $subnet.Id
    }





# Automation account https://learn.microsoft.com/en-us/powershell/module/az.automation/?view=azps-9.4.0#automation
$aaName = $templateParams.automationAccountName
Get-AzAutomationAccount -ResourceGroupName $rgName -Name $aaName | fl AutomationAccountName,Plan,State
Get-AzAutomationRegistrationInfo -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,PrimaryKey,SecondaryKey,Endpoint
Get-AzAutomationDscConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,Name,State
Get-AzAutomationDscCompilationJob -ResourceGroupName $rgName -AutomationAccountName $aaName | Tee-Object -Variable aaJob | fl AutomationAccountName,ConfigurationName,Status
Get-AzAutomationDscCompilationJobOutput -ResourceGroupName $rgName -AutomationAccountName $aaName -Id $aaJob.Id | Format-Table Time,Type,Summary
Get-AzAutomationDscNodeConfiguration -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,ConfigurationName,Name,RollupStatus
Get-AzAutomationDscNode -ResourceGroupName $rgName -AutomationAccountName $aaName | fl AutomationAccountName,Name,NodeConfigurationName,LastSeen,Status


# TODO
# * DC's ip address is not related to it's subnet, instead it's hard coded (in domainController.bicep)
# * DC's ip address is not set as DNS server address on vnet