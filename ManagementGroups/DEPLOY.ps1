$Root = Get-AzManagementGroup | Where-Object DisplayName -EQ "Root Management Group" | % Name

$MgDisplayName = "Trainymotion"

New-AzManagementGroupDeployment `
    -ManagementGroupId $Root `
    -Name demoDeployment4 `
    -Location westeurope `
    -TemplateFile main.bicep `
    -TemplateParameterObject @{mgDisplayName=$MgDisplayName}

Get-AzManagementGroupDeployment -ManagementGroupId $Root | 
    Sort-Object Timestamp | 
    Format-Table DeploymentName,Location,ProvisioningState

Get-AzManagementGroup | Format-Table DisplayName,Name

$Mg = Get-AzManagementGroup | Where-Object DisplayName -EQ $MgDisplayName
Remove-AzManagementGroup -GroupName $Mg.Name