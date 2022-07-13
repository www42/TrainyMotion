# Azure modules
# ==============
Get-Module -ListAvailable -Name Az
Find-Module -Name Az -Repository PSGallery

#  MacOS: bash -> sudo pwsh -> update module -> exit
#  Windows: Run as Administrator -> Windows Terminal
Find-Module -Name Az -Repository PSGallery | Update-Module -Scope AllUsers -Force

Uninstall-Module -Name Az -RequiredVersion 7.3.2


# Azure AD module
# ================

# -------------------------------------
##  Windows PowerShell --> AzureAD
# -------------------------------------
Get-Module    -Name AzureAD -ListAvailable
Find-Module   -Name AzureAD -Repository PSGallery
Find-Module   -Name AzureAD -Repository PSGallery | Update-Module
Import-Module -Name AzureAD

# ------------------------------------------------------------------------------------------
##  PowerShell 7 (Windows, MacOS) --> AzureAD.Standard.Preview from PoshTestGallery
# ------------------------------------------------------------------------------------------
# Register-PackageSource -Name PoshTestGallery -Location https://www.poshtestgallery.com/api/v2/ -ProviderName PowerShellGet

Get-Module    -Name AzureAD.Standard.Preview -ListAvailable
Import-Module -Name AzureAD.Standard.Preview

# Vorsicht beim Update! Nimm nur die Version, die auch in der CloudShell installiert ist.
# Find-Module -Name AzureAD.Standard.Preview -Repository PoshTestGallery     -AllVersions | Update-Module
# Find-Module -Name AzureAD.Standard.Preview -Repository "Posh Test Gallery" -AllVersions | Update-Module




# ----------------------------------------------------------------
# PoshTestGallery is offline --> Install from nupkg package
# ----------------------------------------------------------------

# Get the package
$Uri = "https://pscloudshellbuild.blob.core.windows.net/azuread-standard-preview/azuread.standard.preview.0.1.599.7.nupkg"
$Nupkg = "AzureAD.Standard.Preview.nupkg"
Invoke-WebRequest -Uri $Uri -OutFile $Nupkg -UseBasicParsing
Get-ChildItem $Nupkg

# Expand package, remove nuget specific files
Expand-Archive -Path $Nupkg -DestinationPath tmp
Get-ChildItem -Path tmp
Remove-Item -LiteralPath tmp/_rels, tmp/[Content_Types].xml, tmp/AzureAD.Standard.Preview.nuspec, tmp/package -Recurse -Force

# Copy to folder in $env:PSModulePath
$Module = Get-Module -ListAvailable -Name AzureAD.Standard.Preview
Get-ChildItem $Module.ModuleBase
$Destination = '/usr/local/share/powershell/Modules/AzureAD.Standard.Preview'
$Destination = 'C:\Program Files\PowerShell\Modules\AzureAD.Standard.Preview'
Get-ChildItem -Path $Destination

# Copy as root
#   Bash    --> sudo pwsh
#   Windows --> Run as Administrator  pwsh
Copy-Item -Path tmp -Destination $Destination -Recurse
Move-Item -Path $Destination/tmp -Destination $Destination/0.1.599.7
Exit

# Clean up
Remove-Item -Path tmp -Recurse
Remove-Item -Path $Nupkg

# Start a new PowerShell 7
Import-Module -Name AzureAD.Standard.Preview
Get-Module -Name AzureAD.Standard.Preview