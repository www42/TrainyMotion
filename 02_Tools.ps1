# Azure modules
# -------------
Get-Module -ListAvailable -Name Az

# Azure modules - update
Get-PackageSource
Find-Module -Name Az -Repository PSGallery

#       MacOS: bash -> sudo pwsh -> update module -> exit
#       Windows: Run as Administrator -> Windows Terminal
Find-Module -Name Az -Repository PSGallery | Update-Module -Scope AllUsers -Force


# Azure AD module
# ---------------

##       Windows: Windows PowerShell
Get-Module -Name AzureAD -ListAvailable
Import-Module -Name AzureAD

##       Windows: PowerShell 7
# Man kann das Modul zwar installieren und auch importieren, aber es funktioniert dann doch nicht.
# Connect-AzureAD  funktioniert nicht

##       MacOs: PowerShell 7
Get-Module -ListAvailable -Name AzureAD.Standard.Preview
Import-Module -Name AzureAD.Standard.Preview


# Azure AD module - update

##       Windows: Windows PowerShell
Find-Module -Name AzureAD
##       Windows: PowerShell 7
##       MacOs:   PowerShell 7
# Vorsicht! Nimm nur die Version, die auch in der CloudShell installiert ist.
Find-Module -Name AzureAD.Standard.Preview -Repository PoshTestGallery -AllVersions


# ------------------------------------------------------------------------------------------
# MacOs: PowerShell 7
#
# Install AzureAD.Standard.Preview from nupkg package -- because PoshTestGallery is offline
# ------------------------------------------------------------------------------------------

# https://docs.microsoft.com/en-us/powershell/scripting/gallery/how-to/working-with-packages/manual-download?view=powershell-7.2

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
Get-ChildItem -Path $Destination

# Copy as root
# bash --> sudo pwsh
Copy-Item -Path tmp -Destination $Destination -Recurse
Move-Item -Path $Destination/tmp -Destination $Destination/0.1.599.7
Exit

# Import module (new shell?)
Remove-Module -Name AzureAD.Standard.Preview
Import-Module -Name AzureAD.Standard.Preview
Get-Module -Name AzureAD.Standard.Preview

# Clean up
Remove-Item -Path tmp -Recurse
Remove-Item -Path $Nupkg