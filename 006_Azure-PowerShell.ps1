# Azure Login
# ===========
Logout-AzAccount
Login-AzAccount

Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzSubscription
$Subscription = Get-AzSubscription | Where-Object State -EQ 'enabled' | % SubscriptionId
$TenantId     = Get-AzSubscription | Where-Object State -EQ 'enabled' | % TenantId



# Update module Az
# =================

# Update as root/Administrator!
#   MacOS: Bash -> sudo pwsh 
#   Windows: Run as Administrator(Windows Terminal) -> PowerShell 7 

# PowerShell 7
# ------------
Get-Module -ListAvailable -Name Az
Get-Module -ListAvailable -Name Az.* | Measure-Object | % Count
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

# Update module Az:
#   a) Remove all old versions of Az and Az.* by calling Remove-OldAzModule
#   b) Install new version of 'Az'
Remove-OldAzModule
Find-Module -Name Az -Re4pository PSGallery | Install-Module -Scope AllUsers -Force



# WindowsPowerShell 5.1
# ---------------------
# Get-Module -ListAvailable -Name Az     # Does not work
# 
# Die in WindowsPowerShell installierte Version wird angezeigt, 
# wenn man diesen Befehl unter PowerShell 7 laufen lässt.

# Update module Az:  wie oben
Remove-OldAzModule
Find-Module -Name Az -Re4pository PSGallery | Install-Module -Scope AllUsers -Force