# Azure modules
# -------------
Get-Module -ListAvailable -Name Az

# Azure modules - update
Get-PackageSource
Find-Module -Name Az -Repository PSGallery

#       MacOS: bash -> sudo pwsh -> exit
#       Windows: Run as Administrator -> Windows Terminal
Find-Module -Name Az -Repository PSGallery | Update-Module -Scope AllUsers -Force


# Azure AD module
# ---------------

##       Windows PowerShell
Get-Module -ListAvailable -Name AzureAD
Import-Module -Name AzureAD

##       Windows: PowerShell 7
Get-Module -ListAvailable -Name AzureAD
# Import-Module -Name AzureAD -SkipEditionCheck     # Does not work!
Import-Module -Name AzureAD -UseWindowsPowerShell   # Warning: ... please note that all input and output of commands from this module will be deserialized objects

##       MacOs: PowerShell 7
Get-Module -ListAvailable -Name AzureAD.Standard.Preview
Import-Module -Name AzureAD.Standard.Preview


# Azure AD module - update

##       Windows PowerShell
##       Windows: PowerShell 7
##       MacOs: PowerShell 7
# Vorsicht! Nimm nur die Version, die auch in der CloudShell installiert ist.
Find-Module -Name AzureAD.Standard.Preview -Repository PoshTestGallery -AllVersions
