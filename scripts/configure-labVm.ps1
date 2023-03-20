param($sourceFileUrl = '', $destinationFolder = '')

# "commandToExecute": "[concat('powershell -ExecutionPolicy Unrestricted -File ', variables('customScriptUriScriptFileName'), ' -sourceFileUrl ', parameters('studentFilesUrl'), ' -destinationFolder ', parameters('studentFilesDestination'))]"

Start-Transcript 'C:\scriptlog.txt'
$ErrorActionPreference = 'SilentlyContinue'

if ([string]::IsNullOrEmpty($sourceFileUrl) -eq $false -and [string]::IsNullOrEmpty($destinationFolder) -eq $false) {
    if (Test-Path $destinationFolder -eq $false){
        Write-Output "Creating destination folder $destinationFolder"
        New-Item -ItemType Directory -Path $destinationFolder
    }
    $splitPath = $sourceFileUrl.Split('/')
    $fileName = $sourceFileUrl[$splitPath.Length-1]
    $destinationPath = Join-Path $destinationFolder $fileName

    Write-Output "Starting download: $sourceFileUrl to $destinationPath"
    (New-Object Net.WebClient).DownloadFile($sourceFileUrl,$destinationPath)

    Write-Output "Unzipping $destinationPath to $destinationFolder"
    (new-object -com shell.application).namespace($destinationFolder).CopyHere((new-object -com shell.application).namespace($destinationPath).Items(),16)
}

# Disable IE ESC
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer

# Hide Server Manager
$HKLM = "HKLM:\SOFTWARE\Microsoft\ServerManager"
New-ItemProperty -Path $HKLM -Name "DoNotOpenServerManagerAtLogon" -Value 1 -PropertyType DWORD
Set-ItemProperty -Path $HKLM -Name "DoNotOpenServerManagerAtLogon" -Value 1 -Type DWord

# Hide Server Manager
$HKCU = "HKEY_CURRENT_USER\Software\Microsoft\ServerManager"
New-ItemProperty -Path $HKCU -Name "CheckedUnattendLaunchSetting" -Value 0 -PropertyType DWORD
Set-ItemProperty -Path $HKCU -Name "CheckedUnattendLaunchSetting" -Value 0 -Type DWord

# Install Azure PowerShell
Write-Output "Installing NuGet package provider"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Write-Output "Installing Az PowerShell module"
Install-Module -Name Az -AllowClobber -Scope AllUsers -Force -Confirm:$false

# Uninstall AzureRM PowerShell
# This image has AzureRM PS installed from MSI, so this is how we uninstall
Write-Output "Check for AzureRm PowerShell"
$app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Azure PowerShell*" }
if ($null -ne $app) {
    Write-Output "Uninstalling AzureRm PowerShell via MSI"
    $app.Uninstall()
}
else {
    Write-Output "Could not find AzureRM PowerShell MSI"
}

# Create temp folder
# (Azure VM custom script extension cannot use user profile as destination, C:\Users\Student does not exist at that time)
New-Item -ItemType Directory -Path C:\temp -Force

# Download files for demo "Managed Identity"
$source = 'https://raw.githubusercontent.com/www42/AZ-303-Microsoft-Azure-Architect-Technologies/master/tj/demo-Mi/demo-Mi-Token.ps1'
$destination =  'C:\temp\demo-Mi-Token.ps1'
Invoke-WebRequest -Uri $source -OutFile $destination

$source = 'https://raw.githubusercontent.com/www42/AZ-303-Microsoft-Azure-Architect-Technologies/master/tj/demo-Mi/demo-Mi-AzContext.ps1'
$destination =  'C:\temp\demo-Mi-AzContext.ps1'
Invoke-WebRequest -Uri $source -OutFile $destination

# Download zoomit ver 4.50 (works with pen)
$source = 'https://github.com/www42/TrainyMotion/raw/master/tools/ZoomIt.exe'
$destination = 'C:\temp\ZoomIt.exe'
Invoke-WebRequest -Uri $source -OutFile $destination

# Download CpuStress
$source = 'https://download.sysinternals.com/files/CPUSTRES.zip'
$destination = 'C:\temp\CPUSTRES.zip'
Invoke-WebRequest -Uri $source -OutFile $destination

# Download WmiExplorer
$source = 'https://github.com/www42/TrainyMotion/raw/master/tools/WmiExplorer.exe'
$destination = 'C:\temp\WmiExplorer.exe'
Invoke-WebRequest -Uri $source -OutFile $destination
Stop-Transcript
