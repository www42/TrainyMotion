# ----------------------------------------------------------------------------------------------------------
# Azure PowerShell (Module Az)
# ----------------------------------------------------------------------------------------------------------
# Both Windows PowerShell 5.1 and PowerShell 7
# ----------------------------------------------------------------------------------------------------------
# Note:
#    Get-Module  -Name Az -ListAvailable
# does not work in Windows PowerShell 5.1. To display the installed version in 5.1 use PowerShell 7.

# Note:
#   Update-Module Az
# does not remove the old version neither of module Az nor the dependent modules. 
# Update procedure:
#   a) Remove all old versions of Az and Az.* by calling Remove-OldAzModule
#   b) Install new version of Az

# Update as root/Administrator!
#   MacOS: Bash -> sudo pwsh 
#   Windows: Run as Administrator(Windows Terminal) -> PowerShell 7 
#                                                   -> Windows PowerShell 5

Get-Module  -Name Az -ListAvailable
Find-Module -Name Az -Repository PSGallery

function Remove-OldAzModule {
    #   a) Uninstall all dependent modules Az.*
    #   b) Uninstall module Az
    #
    #   See https://smarttechways.com/2021/05/18/install-and-uninstall-az-module-in-powershell-for-azure/
    
    #   WindowsPowerShell 5 differs from PowerShell 7:
    #   Get-Module -Name Az   # does not work
    
    switch ($PSVersionTable.PSVersion.Major) {
        '5' {
            $AzVersions = Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules\Az\' 
            $AzModules = ($AzVersions | 
            ForEach-Object {
                Import-Clixml -Path (Join-Path -Path $_.FullName -ChildPath PSGetModuleInfo.xml)
            }).Dependencies.Name | Sort-Object -Unique
        }
        '7' {
            $AzVersions = Get-Module -Name Az -ListAvailable
            $AzModules = ($AzVersions | 
            ForEach-Object {
                Import-Clixml -Path (Join-Path -Path $_.ModuleBase -ChildPath PSGetModuleInfo.xml)
            }).Dependencies.Name | Sort-Object -Unique
        }
    }
    
    #   a) Uninstall all dependent modules Az.*
    $AzModules | ForEach-Object {
        Remove-Module -Name $_ -ErrorAction SilentlyContinue
        Write-Output "Uninstalling module $_ ..."
        Uninstall-Module -Name $_ -AllVersions
    }
    
    #    b) Uninstall module Az
    Remove-Module -Name Az -ErrorAction SilentlyContinue
    Write-Output "Uninstalling module Az"
    Uninstall-Module -Name Az -AllVersions
}
Remove-OldAzModule
Install-Module -Name Az -Scope AllUsers -Force

# Azure Login
Logout-AzAccount
Login-AzAccount

Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
$tenantId     = Get-AzSubscription | Where-Object State -EQ 'enabled' | % TenantId






# ----------------------------------------------------------------------------------------------------------
# Azure AD PowerShell for Graph (Module AzureAD) - planned for deprecation
# ----------------------------------------------------------------------------------------------------------
# Windows PowerShell 5.1 only
# ----------------------------------------------------------------------------------------------------------

# Note:
# 'Azure AD', 'Azure AD Preview' and 'MSOnline' PowerShell modules are planned for deprecation. 
# Use Microsoft Graph PowerShell instead.
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/migration-steps

# Note:
# 'Azure AD' uses Azure AD Graph - not Microsoft Graph.

# Note: 
# The Azure AD PowerShell module is not compatible with PowerShell 7. It is only supported in Windows PowerShell 5.1.
# https://learn.microsoft.com/en-us/powershell/azure/active-directory/install-adv2

# Note:
# There was a module 'AzureAD.Standard.Preview' available from PoshTestGallery. But PoshTestGallery disappeared.
# 'AzureAD.Standard.Preview' was running on PowerShell 7.
#    Register-PackageSource -Name PoshTestGallery -Location https://www.poshtestgallery.com/api/v2/ -ProviderName PowerShellGet
#    Find-Module -Name AzureAD.Standard.Preview -Repository PoshTestGallery -AllVersions

Get-Module    -Name AzureAD -ListAvailable
Find-Module   -Name AzureAD -Repository PSGallery

Disconnect-AzureAD
Connect-AzureAD

# May be you need to specify tenant id (e.g. if you are connecting with a federated Microsoft account paul@outlook.com)
$tenantId = '00a197a8-7b4d-4640-9689-01068da45596'
Connect-AzureAD -TenantId $tenantId

Get-AzureADTenantDetail | Format-List DisplayName, `
    @{n="TenantId";e={$_.ObjectId}}, `
    @{n="VerifiedDomains";e={$_.VerifiedDomains.Name}} 





# ----------------------------------------------------------------------------------------------------------
# Microsoft Azure Active Directory Module for Windows PowerShell (Module MSOnline) - planned for deprecation
# ----------------------------------------------------------------------------------------------------------
# Windows PowerShell 5.1 only
# ----------------------------------------------------------------------------------------------------------
Get-Module -Name MSOnline -ListAvailable
Find-Module -Name MSOnline -Repository PSGallery

Import-Module -Name MSOnline
Connect-MsolService



# ----------------------------------------------------------------------------------------------------------
# Exchange Online PowerShell V3 
# ----------------------------------------------------------------------------------------------------------
# Both Windows PowerShell 5.1 and PowerShell 7
# ----------------------------------------------------------------------------------------------------------
Get-Module  -Name ExchangeOnlineManagement -ListAvailable 
Find-Module -Name ExchangeOnlineManagement -Repository PSGallery
Find-Module -Name ExchangeOnlineManagement -Repository PSGallery -AllowPrerelease  # Powershell 7

Disconnect-ExchangeOnline -Confirm:$false
Connect-ExchangeOnline -ShowBanner:$false






# ----------------------------------------------------------------------------------------------------------
# Microsoft Graph PowerShell (Module Microsoft.Graph)
# ----------------------------------------------------------------------------------------------------------
Get-Module    -Name Microsoft.Graph -ListAvailable
Find-Module   -Name Microsoft.Graph -Repository PSGallery

function Remove-OldGraphModule {
    # Remove all Graph modules except Microsoft.Graph.Authentication
    $Modules = Get-Module Microsoft.Graph* -ListAvailable | Where {$_.Name -ne "Microsoft.Graph.Authentication"} | Select-Object Name -Unique
    Foreach ($Module in $Modules) {
        $ModuleName = $Module.Name
        $Versions = Get-Module $ModuleName -ListAvailable
        Foreach ($Version in $Versions) {
            $ModuleVersion = $Version.Version
            Write-Host "Uninstall-Module $ModuleName $ModuleVersion"
            Uninstall-Module $ModuleName -RequiredVersion $ModuleVersion
        }
    }
    # Remove Microsoft.Graph.Authentication
    $ModuleName = "Microsoft.Graph.Authentication"
    $Versions = Get-Module $ModuleName -ListAvailable
    Foreach ($Version in $Versions) {
        $ModuleVersion = $Version.Version
        Write-Host "Uninstall-Module $ModuleName $ModuleVersion"
        Uninstall-Module $ModuleName -RequiredVersion $ModuleVersion
    }
}
Remove-OldGraphModule
Install-Module -Name Microsoft.Graph -Repository PSGallery -Scope AllUsers -Force

# Microsoft.Graph Login
# ---------------------
# Minimal scopes (permissions)
Connect-MgGraph

Get-MgContext
Get-MgContext | % Scopes

# Scopes (= permissions) can be added cumulatively
$Scopes = @(
    "User.Read.All"
    "Group.Read.All"
)
Connect-MgGraph -Scopes $Scopes
Disconnect-MgGraph




# ----------------------------------------------------------------------------------------------------------
# MSAL.PS
# ----------------------------------------------------------------------------------------------------------
Get-Module    -Name MSAL.PS -ListAvailable
Find-Module   -Name MSAL.PS -Repository PSGallery
Update-Module -Name MSAL.PS -Repository PSGallery -Scope AllUsers -Force
