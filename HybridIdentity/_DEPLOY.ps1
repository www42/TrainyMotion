# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This deploys infrastructure for hybrid identity scenario
#
#   1. Create a resource group by PowerShell
#   2. Create a virtual network by Powershell 
#      (Virtual network by ARM template is fine for the first time. But for subsequent deployments, it's not idempotent. So we use PowerShell)
#   3. Create by ARM template
#          an automation account (used as DSC pull server)
#          a domain controller
#          a Windows 11 client
# 
# ------------------------------------------------------------------------------------
# DSC compile job (compilation .ps1 --> .mof) is not idempotent.
# So for the first time create a compile job by 'createAaJob = $true'. In subsequent deployments say 'createAaJob = $false'
# ------------------------------------------------------------------------------------

# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription


# --- Resource group -----------------------------------------------------------------
$rgName = 'RG-HybridIdentity'
$rgName = 'TEST-HybridIdentity'
$location = 'westeurope'

New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'tabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob




# --- Virtual network ----------------------------------------------------------------
$vnetName = 'VNet-HybridIdentity'
$addressPrefix = '172.17.0.0/16'

$subnet0 = New-AzVirtualNetworkSubnetConfig -Name 'Subnet0'            -AddressPrefix '172.17.0.0/24'
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'AzureBastionSubnet' -AddressPrefix '172.17.255.0/26'

$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $addressPrefix -Subnet $subnet0, $subnet1 -Force



Get-AzVirtualNetwork | ft Name,Subnets,ResourceGroupName
Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName | % { $_.Subnets } | ft Name,AddressPrefix

Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName) -Name 'Subnet0' | Tee-Object -Variable subnet | fl Name,AddressPrefix,NetworkSecurityGroup,RouteTable

$subnetId = $subnet.Id


# --- Automation Account, Domain Controller, Windows 11 Client -------------------------------------------
$templateFile = 'HybridIdentity/templates/main.bicep'
$aaName = 'aa-hybrid'
$templateParams = @{
    location              = $location
    automationAccountName = $aaName
    createAaJob           = $true
    subnetId              = $subnetId
    domainName            = 'az.training'
    dcName                = 'DC1'
    dcIp                  = '172.17.0.200'
    domainAdminName       = 'DomainAdmin'
    domainAdminPassword   = 'Pa55w.rd1234'
    clientName            = 'Client001'
    localAdminName        = 'localadmin'
    localAdminPassword    = 'Pa55w.rd1234'
    clientVirtualMachineAdministratorLoginRoleAssigneeId = (Get-AzADUser -UserPrincipalName Ludwig@az.training).Id
}
$templateParams['createAaJob'] = $false
$templateParams['clientName'] = 'Client005'
$templateParams['domainAdminPassword'] = ''
$templateParams['localAdminPassword'] = ''


New-AzResourceGroupDeployment -Name 'Hybrid-Identity-Scenario' -ResourceGroupName $rgName -TemplateFile $templateFile -TemplateParameterObject $templateParams -Location $location


# Deployments
Get-AzSubscriptionDeployment | Sort-Object Timestamp | ft DeploymentName, ProvisioningState, Timestamp
Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp | ft DeploymentName,ProvisioningState,Timestamp



# Automation account https://learn.microsoft.com/en-us/powershell/module/az.automation/?view=azps-9.4.0#automation
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