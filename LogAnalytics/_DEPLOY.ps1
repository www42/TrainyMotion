# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription

# --- Parameters ---------------------------------------------------------------------
$rgName = 'rg-hybrididentity'
$location = 'westeurope'
$templateFile = 'LogAnalytics/templates/main.bicep'
$logAnalyticsWorkspaceName = 'log-hybrididentity'
$dcrName = 'dcr-windows-perf'

$templateParams = @{
    location = $location
    logAnalyticsWorkspaceName = $logAnalyticsWorkspaceName
    dcrName = $dcrName
}


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob



# --- Log Analytics Workspace, Data Collection Rule, Association to SVR1 -------------
New-AzResourceGroupDeployment -Name 'Scenario-LogAnalytics' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp

Get-AzOperationalInsightsWorkspace -ResourceGroupName $rgName | Sort-Object Name | ft Name,Location,ProvisioningState,Sku

Get-AzDataCollectionRule | ft Name,Location,ProvisioningState
Get-AzDataCollectionRuleAssociation -ResourceGroupName $rgName -RuleName 'testDCR' 
Get-AzDataCollectionRuleAssociation -ResourceGroupName $rgName -RuleName $dcrName 
Start-AzVM -Name 'SVR1' -ResourceGroupName $rgName

Get-AzVMExtension -VMName 'DC1' -ResourceGroupName $rgName -Name 'MicrosoftMonitoringAgent' | fl Name,Location,ProvisioningState,PublicSettings
Get-AzVMExtension -VMName 'DC1' -ResourceGroupName $rgName -Name 'MicrosoftMonitoringAgent' | % PublicSettings | ConvertFrom-Json | fl