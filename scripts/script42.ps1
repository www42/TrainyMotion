# Install NuGet in order to install modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Install more DSC resources e.g. 'TimeZone'
Install-Module -Name ComputerManagementDsc -Force

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