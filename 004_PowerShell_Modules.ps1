# Note:
# Update as root/Administrator!
#   MacOS: Bash -> sudo pwsh 
#   Windows: Run as Administrator(Windows Terminal) -> PowerShell 7 
#                                                   -> Windows PowerShell 5


# ----------------------------------------------------------
# Azure PowerShell (Module Az)
# ----------------------------------------------------------

Get-Module  -Name Az -ListAvailable
Find-Module -Name Az -Repository PSGallery

# Note:
#    Get-Module  -Name Az -ListAvailable
# does not work in Windows PowerShell 5.1. To display the installed version in 5.1 use PowerShell 7.

# Update procedure:
#   a) Remove all old versions of Az and Az.* by calling Remove-OldAzModule
#   b) Install new version of 'Az'

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
Install-Module -Name Az -Repository PSGallery -Scope AllUsers -Force

# Unclarified:
# Does the following command remove the old module versions?löscht Update-Module die alten Versionen? Wenn ja dann kann man sich a) und b) sparen.
# Statt dessen simpel (run as Administrator)
Update-Module -Name Az -Repository PSGallery -Scope AllUsers -Force



# ----------------------------------------------------------
# Azure AD PowerShell for Graph (Module AzureAD)
# ----------------------------------------------------------

# Note:
# Azure AD, Azure AD Preview and MSOnline PowerShell modules are planned for deprecation. 
# Use Microsoft Graph PowerShell instead.
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/migration-steps

# Note:
# Azure AD uses Azure AD Graph - not Microsoft Graph.

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
Update-Module -Name AzureAD -Repository PSGallery -Scope AllUsers -Force



# ----------------------------------------------------------
# Microsoft Graph PowerShell (Module Microsoft.Graph)
# ----------------------------------------------------------
Get-Module    -Name Microsoft.Graph -ListAvailable
Find-Module   -Name Microsoft.Graph -Repository PSGallery
Update-Module -Name Microsoft.Graph -Repository PSGallery -Scope AllUsers -Force


# ----------------------------------------------------------
# MSAL.PS
# ----------------------------------------------------------
Get-Module    -Name MSAL.PS -ListAvailable
Find-Module   -Name MSAL.PS -Repository PSGallery
Update-Module -Name MSAL.PS -Repository PSGallery -Scope AllUsers -Force
