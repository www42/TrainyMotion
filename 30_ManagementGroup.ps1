Get-AzManagementGroup | Format-Table Name, DisplayName

$Name = 'Production'
$Name = 'Testing'
$Guid = New-Guid 
New-AzManagementGroup -GroupName $Guid -DisplayName $Name
